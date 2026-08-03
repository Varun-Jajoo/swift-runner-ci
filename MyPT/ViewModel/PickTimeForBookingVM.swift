//
//  PickTimeForBookingVM.swift
//  MyPT
//
//  Created by Manik Goel on 02/07/26.
//

import Foundation
import UIKit

// MARK: - PickTimeForBookingVM

final class PickTimeForBookingVM {

    // MARK: - Outputs (VC binds to these closures)

    var getSlotesModelData: GetSlotesModelData?
    /// Fired once after the API response is processed. VC should call `tableView.reloadData()`.
    var onDatesLoaded: (() -> Void)?

    /// Fired when a single row's state changes. VC should call `tableView.reloadRows(at:with:)`.
    var onDateUpdated: ((IndexPath) -> Void)?

    /// Fired when the proceed-button enabled state should change.
    var onProceedStateChanged: ((Bool) -> Void)?

    /// Fired on any network or decode error.
    var onError: ((String) -> Void)?

    // MARK: - State

    /// The flat array of per-date states — index == tableView row.
    private(set) var dateStates: [BookingDateState] = []

    /// Original API request parameters — held so the VC can pass them forward to subsequent screens.
    private(set) var requestParams: NewBookingParmsModel?

    // MARK: - Configuration

    /// Call this once before `fetchSlots()`. Stores the params and wires up the screen.
    func configure(with params: NewBookingParmsModel) {
        self.requestParams = params
    }

    // MARK: - Data Loading

    /// Calls the API and converts the response into `[BookingDateState]`.
    /// Must be called from any thread; all VC callbacks are dispatched to the main queue.
    func fetchSlots(viewController: UIViewController) {
        guard let params = requestParams else {
            onError?("Request parameters are missing.")
            return
        }

        let inputParams = params.getParams()

        NewBookingVM.getNewBookingSlotsApi(
            viewController: viewController,
            inputParms: inputParams,
            completion: { [weak self] result in
                guard let self = self else { return }

                guard let data = result?.data, let dateElements = data.dates else {
                    DispatchQueue.main.async {
                        self.onError?("No dates returned from server.")
                    }
                    return
                }
                getSlotesModelData = data

                // Convert API model → local UI model
                self.dateStates = dateElements.map { BookingDateState.make(from: $0) }

                DispatchQueue.main.async {
                    self.onDatesLoaded?()
                    self.onProceedStateChanged?(self.canProceed())
                }
            }
        )
    }

    // MARK: - Per-Date State Update

    /// Called when the user selects an alternative from `AvailableTrainerPresentVC`.
    /// Mutates only the matching row and notifies the VC to reload just that one cell.
    func updateDateState(with selection: AlternativeSelection) {
        guard let index = dateStates.firstIndex(where: { $0.date == selection.date }) else {
            // Defensive: date not found in list — safe no-op.
            return
        }

        dateStates[index].selectedAlternative = selection

        let indexPath = IndexPath(row: index, section: 0)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onDateUpdated?(indexPath)
            self.onProceedStateChanged?(self.canProceed())
        }
    }

    /// Deletes a date state at the given index locally, updating both the list and the request parameters.
    func deleteDateState(at index: Int) {
        guard index >= 0 && index < dateStates.count else { return }
        let deletedState = dateStates.remove(at: index)
        
        // Also update requestParams (remove the corresponding date)
        if var params = requestParams, let dates = params.dates {
            params.dates = dates.filter { $0 != deletedState.date }
            self.requestParams = params
        }
        
        // Notify proceed state change
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onProceedStateChanged?(self.canProceed())
        }
    }

    // MARK: - Accessors

    /// Safe subscript for use in `cellForRowAt` and `didSelectRowAt`.
    func dateState(at indexPath: IndexPath) -> BookingDateState? {
        guard indexPath.row < dateStates.count else { return nil }
        return dateStates[indexPath.row]
    }

    var numberOfRows: Int {
        dateStates.count
    }

    // MARK: - Proceed Eligibility

    /// Returns `true` when every date is either originally available or manually resolved by the user.
    func canProceed() -> Bool {
        guard !dateStates.isEmpty else { return false }
        return dateStates.allSatisfy { $0.isResolved }
    }

    // MARK: - Payload for Next Screen

    /// Collects all confirmed slot IDs for the booking confirmation payload.
    func buildConfirmedSlotIds() -> [String] {
        dateStates.compactMap { $0.confirmedSlotId }
    }

    /// Returns a copy of `requestParams` updated with the latest confirmed slot IDs.
    /// Pass this to `ReviewBookingViewController`.
    func buildFinalParams() -> NewBookingParmsModel? {
        guard var params = requestParams else { return nil }
        params.slot_ids = buildConfirmedSlotIds()
        return params
    }
}
