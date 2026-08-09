//
//  BookingModel.swift
//  MyPT
//
//  Created by techsaga corp on 15/04/25.
//

import Foundation

//MARK: ---------------------- BookingBaseModel
struct BookingBaseModel: Codable {
    var status: Bool?
    var data: [BookingDataModel]?
    var msg: String?
    let errors: String? 
}

//MARK: ------------ BookingDataModel
struct BookingDataModel: Codable {
    var id: FlexibleValue?
    var type, timing, starts_in, trainer_image, selected_slot: FlexibleValue?
    var workoutFocus: [String]?
    var sessionType, duration, trainer, location, distance, scheduleMsg, averageRating, price, studioLat, studioLng: FlexibleValue?
    var isReschedule, isTrainer, isSchedule, isCheckinAvailable, isRefund: Bool?
    var msg, bookingType: String?
    /// 'special' vs 'normal' - only meaningful when `id` carries the "wl-"
    /// waitlist prefix. Matches `GcWaitlist.waitlist_type` verbatim, same key
    /// `BookingListController.php`'s waitlist mapping already returns.
    var waitlistType: String?

    enum CodingKeys: String, CodingKey {
        case id, type, timing, trainer_image, selected_slot
        case workoutFocus = "workout_focus"
        case sessionType = "session_type"
        case duration, trainer, location, distance, price
        case studioLat = "studio_lat"
        case studioLng = "studio_long"
        case isReschedule = "is_reschedule"
        case isRefund = "is_refund"
        case bookingType = "booking_type"
        case waitlistType = "waitlist_type"
        case isSchedule
        case isTrainer
        case msg, scheduleMsg, averageRating, starts_in
    }

    /// True only for a waitlist row (`id` carries the "wl-" prefix
    /// `BookingListController.php` prepends for `GcWaitlist` rows).
    var isWaitlistRow: Bool {
        id?.value.hasPrefix("wl-") == true
    }

    var isSpecialWaitlist: Bool {
        waitlistType == "special"
    }

    /// Port of the `isGroupClass` check in Android's `UpcomingAdapter.kt` /
    /// `UpcomingSessionsAdapter.kt`: `type` CONTAINS "group_class" (not an
    /// exact match - a waitlist row's type is "group_class_waitlist"), or
    /// `booking_type`/`session_type` containing "group", case-insensitive.
    /// An exact-match-only `type` check plus relying on the class NAME
    /// containing "group" (a coincidence that only ever worked while every
    /// class showed the generic "Group Class" fallback name) sent waitlist
    /// rows into the wrong (PT-session) detail screen, which renders blank
    /// for a "wl-" id it doesn't understand.
    var isGroupClass: Bool {
        if let id = id?.value, id.hasPrefix("wl-") { return true }
        if let type = type?.value, type.range(of: "group", options: .caseInsensitive) != nil { return true }
        if let bookingType = bookingType, bookingType.range(of: "group", options: .caseInsensitive) != nil || bookingType.range(of: "waitlist", options: .caseInsensitive) != nil { return true }
        if let sessionType = sessionType?.value, sessionType.range(of: "group", options: .caseInsensitive) != nil { return true }
        return false
    }
}

//MARK: --------------------------- BOOKING DETAILS FLOW

//MARK: - BookingDetailsBaseModel
struct BookingDetailsBaseModel: Codable {
    var status: Bool?
    var data: BookingDetailsDataModel?
    var msg: String?
}

//MARK: ------------- BookingDetailsDataModel
struct BookingDetailsDataModel: Codable {
    var rescheduledStatus, cancelRequest, is_declined, isAction, isPackage, isAlreadyReview: Bool?
    var msg, cancellationPolicyMsg, bookingType, bookedAt, cancelledAtBooking, bookingPrice, trainingPrefernce, booking_id, slot_id, price, main_price, tax_amount: FlexibleValue?
    var bookingDetail: BookingDetailModel?
    var trainerDetail: TrainerDetailModel?
    var cancellationDetail: CancellationDetailModel?
    var cancellationPolicy: CancellationPolicyModel?
    
    enum CodingKeys: String, CodingKey {
        case rescheduledStatus = "rescheduled_status"
        case cancelRequest = "can_cancel_request"
        case is_declined, isAction, isPackage, isAlreadyReview
        case cancellationPolicyMsg
        case bookingType = "booking_type"
        case booking_id, slot_id
        case cancelledAtBooking = "cancelled_at"
        case bookedAt = "booked_at"
        case bookingDetail, trainerDetail, msg, cancellationDetail, cancellationPolicy, bookingPrice
        case trainingPrefernce
        case price, main_price, tax_amount
    }
}


//MARK: ------------- BookingDetailModel
struct BookingDetailModel: Codable {
    var contact, price, location, trainingDate, qr, address_id: FlexibleValue?
    var type: FlexibleValue?
    var msg, otp: FlexibleValue?
    

    enum CodingKeys: String, CodingKey {
        case contact, price, location, qr, address_id
        case trainingDate = "training_date"
        case type
        case msg, otp
    }
}

//MARK: --------------- TrainerDetailModel
struct TrainerDetailModel: Codable {
    var name, distance, location: String?
    var profile: String?
    var averageRating, noOfRating, trainer_id: FlexibleValue?
}

//MARK: --------------- Aancellation Detail MODEL
struct CancellationDetailModel: Codable {
    var cancelledOn: String?
    var reason: String?
    var refundAmount: FlexibleValue?
    var msg: FlexibleValue?
    
    enum CodingKeys: String, CodingKey {
        case cancelledOn = "cancelled_on"
        case reason
        case refundAmount = "refund_amount"
        case msg
    }
}


//MARK: --------------- CancellationPolicy Model
struct CancellationPolicyModel: Codable {
    var shortDescription: FlexibleValue?
    var timeHours: FlexibleValue?
    var max_cancel_time: FlexibleValue?
    var freeMsg: FlexibleValue?
    var cancelMsg: FlexibleValue?
    var cancelMsgText: FlexibleValue?
    var freeMsgText: FlexibleValue?
    
    
    enum CodingKeys: String, CodingKey {
        case shortDescription
        case timeHours
        case max_cancel_time
        case freeMsg
        case cancelMsg
        case cancelMsgText
        case freeMsgText
    }
}


//MARK: ------------------ TRAINER SLOTS
struct TrainerSlotsBaseModel: Codable {
    var status: Bool?
    var data: [AvailabilityStatusModel]?
    var msg: String?
}

//------------ Trainer Details
struct TrainerDeyRequestModel: Codable {
    var id: Int?
    var type, trainer_image: String?
    var trainer, location, distance, scheduleMsg: String?
   
    enum CodingKeys: String, CodingKey {
        case id, type, trainer_image
        case trainer, location, distance
        case scheduleMsg
    }
}
