//
//  GroupClassBookingRouter.swift
//  MyPT
//

import UIKit

/// Group-class-row navigation shared by the Bookings tab and Home's own
/// "Upcoming Bookings" section - both read the exact same `BookingDataModel`
/// off the same `api/get-booking` response shape, so a tap on the same
/// booking from either place must land on the same screen. Extracted from
/// `BookingListViewController.tableView(_:didSelectRowAt:)` after Home's own
/// tap handler (`ActiveHomepageVCViewController.checkInBtnActn`) turned out
/// to be a much simpler, state-blind copy - it always pushed a plain
/// "confirmed" receipt with a handful of fields, regardless of whether the
/// row was actually waitlisted, had an open spot to claim, or was cancelled
/// by an admin - all of which the Bookings tab already handled correctly.
enum GroupClassBookingRouter {

    /// `isUpcomingTab` mirrors `BookingListViewController`'s own
    /// `selectedTags == 2` check. Home's "Upcoming Bookings" section has no
    /// tabs of its own, but its content is always conceptually the Upcoming
    /// tab's data, so callers there should always pass `true`.
    static func route(row: BookingDataModel, isUpcomingTab: Bool, on navigationController: UINavigationController?) {
        if isUpcomingTab, row.isWaitlistRow {
            // A normal (non-special) waitlist entry whose spot has already
            // opened up gets the claim screen directly instead of the static
            // "you're waitlisted" receipt - no reason to make the member
            // re-discover that a spot they can already take is sitting there.
            if !row.isSpecialWaitlist, row.hasOpenSpot == true, let scheduleId = row.scheduleId?.value, !scheduleId.isEmpty {
                let controller = SlotOpenViewController()
                controller.scheduleId = scheduleId
                controller.hidesBottomBarWhenPushed = true
                controller.onClaimed = { classTitle, time, location, trainer in
                    let confirmed = SlotConfirmedViewController()
                    confirmed.classTitle = classTitle
                    confirmed.classTime = time
                    confirmed.classLocation = location
                    confirmed.trainerName = trainer
                    confirmed.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(confirmed, animated: true)
                }
                navigationController?.pushViewController(controller, animated: true)
                return
            }

            if row.isSpecialWaitlist {
                let wVc = WaitlistConfirmedViewController()
                let bookingType = row.bookingType?.trimmingCharacters(in: .whitespacesAndNewlines)
                wVc.classTitle = (bookingType?.isEmpty == false ? bookingType : row.sessionType?.value) ?? ""
                wVc.classTime = row.timing?.value ?? ""
                wVc.classLocation = row.location?.value ?? ""
                wVc.trainerName = row.trainer?.value ?? ""
                wVc.distance = row.distance?.value ?? ""
                wVc.studioLat = row.studioLat?.doubleValue ?? 0
                wVc.studioLng = row.studioLng?.doubleValue ?? 0
                wVc.waitlistType = "special"
                wVc.bookingId = row.id?.value ?? ""
                wVc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(wVc, animated: true)
                return
            }

            let bookingType = row.bookingType?.trimmingCharacters(in: .whitespacesAndNewlines)
            let controller = SlotConfirmedViewController()
            controller.classTitle = (bookingType?.isEmpty == false ? bookingType : row.sessionType?.value) ?? ""
            controller.classTime = row.timing?.value ?? ""
            controller.classLocation = row.location?.value ?? ""
            controller.trainerName = row.trainer?.value ?? ""
            controller.distance = row.distance?.value ?? ""
            controller.classPrice = row.price?.value ?? ""
            controller.studioLat = Double(row.studioLat?.value ?? "") ?? 0
            controller.studioLng = Double(row.studioLng?.value ?? "") ?? 0
            controller.isReadOnly = true
            controller.bookingId = row.id?.value ?? ""
            controller.canCancelBooking = true
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
            return
        }

        let bookingType = row.bookingType?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTitle = (bookingType?.isEmpty == false ? bookingType : row.sessionType?.value) ?? ""

        // A class the admin cancelled outright (not the member's own cancel)
        // gets the dedicated rejection screen instead of the usual receipt
        // with a plain "CANCELLED" pill.
        if row.bookingStatus == "cancelled", row.cancelledByAdmin == true {
            var input = ClassCancelledByAdminInput()
            input.classTitle = resolvedTitle
            input.classTime = row.timing?.value ?? ""
            input.classLocation = row.location?.value ?? ""
            input.trainerName = row.trainer?.value ?? ""
            input.distance = row.distance?.value ?? ""
            input.studioLat = row.studioLat?.doubleValue ?? 0
            input.studioLng = row.studioLng?.doubleValue ?? 0
            let controller = ClassCancelledByAdminViewController()
            controller.input = input
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
            return
        }

        let controller = SlotConfirmedViewController()
        controller.classTitle = resolvedTitle
        controller.classTime = row.timing?.value ?? ""
        controller.classLocation = row.location?.value ?? ""
        controller.trainerName = row.trainer?.value ?? ""
        controller.distance = row.distance?.value ?? ""
        controller.classPrice = row.price?.value ?? ""
        controller.studioLat = Double(row.studioLat?.value ?? "") ?? 0
        controller.studioLng = Double(row.studioLng?.value ?? "") ?? 0
        controller.isReadOnly = true
        controller.bookingId = row.id?.value ?? ""
        controller.bookingStatus = row.bookingStatus ?? "confirmed"
        controller.cancelledReason = row.cancelledReason ?? ""
        controller.noShowCount = row.noShowCount ?? 0
        controller.noShowBlockedUntil = row.noShowBlockedUntil ?? ""
        // Only the Upcoming context has anything left to cancel.
        controller.canCancelBooking = isUpcomingTab
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
