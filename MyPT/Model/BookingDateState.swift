//
//  BookingDateState.swift
//  MyPT
//
//  Created by Manik Goel on 02/07/26.
//

import Foundation

// MARK: - DateAvailabilityState

/// Tracks the origin and resolution status of each date in the booking flow.
enum DateAvailabilityState {
    /// API returned slots — primary trainer is available.
    case available
    /// API returned no slots — primary trainer is unavailable.
    case unavailable
    /// User picked an alternative trainer/slot for this date.
    case manuallyResolved
}

// MARK: - AlternativeSelection

/// The typed payload fired back from AvailableTrainerPresentVC.
/// Contains everything needed to update a single date's state.
struct AlternativeSelection {
    let date: String          // "2026-07-22"   — used as the lookup key
    let slotId: String
    let trainerId: String
    let trainerName: String
    let timeDisplay: String   // e.g. "08:00 AM - 09:00 AM"
    let startTime: String     // "08:00"
    let endTime: String       // "09:00"
}

// MARK: - BookingDateState

/// Local mutable UI model — one instance per date row.
///
/// This is the *single source of truth* for the cell.
/// The underlying API type (DateElement) is kept immutable and Codable-only.
/// All UI rendering reads from this struct; the ViewController never touches DateElement directly.
struct BookingDateState {

    // MARK: - Identity
    let date: String                    // "2026-07-22"   — primary key
    let dateFormatted: String           // "22 Jul, Wed"  — display label

    // MARK: - Primary trainer info (from API)
    let primaryTrainerId: Int?
    let primaryTrainerName: String?

    // MARK: - Original API slots (immutable after construction)
    let originalSlots: [Slot]

    // MARK: - User override (nil until the user acts on this date)
    var selectedAlternative: AlternativeSelection?

    // MARK: - Computed: availability state

    var availabilityState: DateAvailabilityState {
        if selectedAlternative != nil { return .manuallyResolved }
        return originalSlots.isEmpty ? .unavailable : .available
    }

    var isResolved: Bool {
        availabilityState == .available || availabilityState == .manuallyResolved
    }

    // MARK: - Computed: display values (what the cell shows)

    var displayTrainerName: String? {
        switch availabilityState {
        case .manuallyResolved: return selectedAlternative?.trainerName
        default:                return primaryTrainerName
        }
    }

    /// The time string shown in `lblTime`.
    var displayTimeText: String? {
        switch availabilityState {
        case .available:
            return originalSlots.first?.time_display
        case .manuallyResolved:
            return selectedAlternative?.timeDisplay
        case .unavailable:
            return nil
        }
    }

    /// The slot ID that feeds into the booking confirmation payload.
    var confirmedSlotId: String? {
        switch availabilityState {
        case .available:
            return originalSlots.first?.id?.value
        case .manuallyResolved:
            return selectedAlternative?.slotId
        case .unavailable:
            return nil
        }
    }

    /// Message shown inside the unavailable card.
    var unavailableMessage: String {
        "\(primaryTrainerName ?? "Trainer") is unavailable at this time"
    }
}

// MARK: - Factory

extension BookingDateState {

    /// Builds a `BookingDateState` from the raw API model.
    static func make(from element: DateElement) -> BookingDateState {
        BookingDateState(
            date: element.date ?? "",
            dateFormatted: element.dateFormatted ?? "",
            primaryTrainerId: element.trainerID,
            primaryTrainerName: element.trainerName,
            originalSlots: element.slots ?? [],
            selectedAlternative: nil
        )
    }
}
