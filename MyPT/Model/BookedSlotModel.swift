//
//  BookedSlotModel.swift
//  MyPT
//
//  Created by techsaga corp on 26/03/25.
//

import Foundation

//MARK: ----------- BookedSlotBaseModel
struct BookedSlotBaseModel: Codable {
    var status: Bool?
    var data: BookedSlotData?
    var msg: String?
    let errors: [String: [String]]?
    
}

//MARK: --------- DataClass
struct BookedSlotData: Codable {
    var trainer: BookedTrainerModel?
    var date: SlotDateModel?
    var package: String?
    var qr: String?
    var timing, location: String?
}


//MARK: ---------- DateClass
struct SlotDateModel: Codable {
    var startDate, validTill: String?

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case validTill = "valid_till"
    }
}

//MARK: ----------- BookClassBaseModel
/*
 Shared response model for BOTH `api/book-class` AND `api/join-waitlist`
 (Android returns an identical envelope for the two endpoints:
  status / msg / code / is_blacklisted / data).

 The "data" key is SHAPE-SHIFTING:
 - on plain success  -> booking/waitlist details  -> decoded into `data` (BookingClassDataModel)
 - on free-booking spam-guard success/re-tap -> {waitlist_type, is_already_waitlisted, position, ...}
   -> decoded into `specialWaitlist` (SpecialWaitlistDetailModel). Detected by the presence of the
   `waitlist_type` key, which a plain booking/waitlist-success payload never includes (confirmed live
   against UAT) - only its VALUE ("special" vs "normal") tells you whether the guard actually triggered.
 - on blacklist failure -> {reason, resumes_on, hours_remaining} -> decoded into `blacklistDetail`

 Blacklist detection logic to replicate at every call site (mirrors Android
 GroupTrainingDetailActivity.kt lines 572-586 for book-class and 803-817 for join-waitlist):

    let isBlacklisted = (model.isBlacklisted == true)
        || (model.code == "BLACKLISTED")
        || (model.msg?.lowercased().contains("blacklisted") ?? false)
        || (model.msg?.lowercased().contains("paused") ?? false)

 Android fallbacks when the blacklist payload is missing a field:
 reason -> "2 consecutive no-shows for group classes", resumes_on -> "12 August 2026, 6:00 PM", hours_remaining -> "24".
 */
struct BookClassBaseModel: Codable {
    var status: Bool?
    var data: BookingClassDataModel?
    var msg: String?
    let errors: [String: [String]]?
    var code: String?
    var isBlacklisted: Bool?
    /// Populated only when the "data" key carries the blacklist payload instead of booking details.
    var blacklistDetail: BlacklistDetailModel?
    /// Populated only when the "data" key carries the free-booking spam-guard payload
    /// (fresh special-waitlist join, or a re-tap on one that already exists).
    var specialWaitlist: SpecialWaitlistDetailModel?

    enum CodingKeys: String, CodingKey {
        case status, data, msg, errors, code
        case isBlacklisted = "is_blacklisted"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        status = try? container.decodeIfPresent(Bool.self, forKey: .status)
        msg = try? container.decodeIfPresent(String.self, forKey: .msg)
        errors = try? container.decodeIfPresent([String: [String]].self, forKey: .errors)
        code = try? container.decodeIfPresent(String.self, forKey: .code)
        isBlacklisted = try? container.decodeIfPresent(Bool.self, forKey: .isBlacklisted)

        // "data" means three different things depending on shape, so try all three.
        let decodedBooking = try? container.decodeIfPresent(BookingClassDataModel.self, forKey: .data)
        let decodedSpecialWaitlist = try? container.decodeIfPresent(SpecialWaitlistDetailModel.self, forKey: .data)
        let decodedBlacklist = try? container.decodeIfPresent(BlacklistDetailModel.self, forKey: .data)

        // waitlist_type is present on EVERY spam-guard payload (fresh join carries "special"
        // or "normal"; a re-tap on an existing entry carries whatever it already was) and
        // absent from every plain booking/waitlist-success payload - the one reliable signal.
        if let waitlistPayload = decodedSpecialWaitlist, waitlistPayload.waitlistType != nil {
            data = nil
            blacklistDetail = nil
            specialWaitlist = waitlistPayload
            return
        }

        // NOTE: every property of BookingClassDataModel is optional, so it also decodes
        // *successfully* (but completely empty) from a blacklist payload. Success is therefore
        // not a sufficient test - we additionally require it to actually carry booking details,
        // or the response to be a success response (keeps the legacy success path byte-identical).
        specialWaitlist = nil
        if let booking = decodedBooking, booking.hasBookingDetails || (status == true) {
            data = booking
            blacklistDetail = nil
        } else {
            data = nil
            blacklistDetail = decodedBlacklist
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(msg, forKey: .msg)
        try container.encodeIfPresent(errors, forKey: .errors)
        try container.encodeIfPresent(code, forKey: .code)
        try container.encodeIfPresent(isBlacklisted, forKey: .isBlacklisted)
        if let data = data {
            try container.encode(data, forKey: .data)
        } else if let specialWaitlist = specialWaitlist {
            try container.encode(specialWaitlist, forKey: .data)
        } else if let blacklistDetail = blacklistDetail {
            try container.encode(blacklistDetail, forKey: .data)
        }
    }
}

// MARK: --------- Booking Class DataModel (For upcoming sessiogn)
struct BookingClassDataModel: Codable {
    let trainer: BookedTrainerModel?
    let date: String?
    let qr: String?
    let timing, location: String?

    /// True when the payload actually carries booking details (used to tell a real
    /// success payload apart from a blacklist payload sharing the same "data" key).
    var hasBookingDetails: Bool {
        return trainer != nil || date != nil || qr != nil || timing != nil || location != nil
    }
}

// MARK: - BlacklistDetailModel
/// Blacklist payload carried under the "data" key of a FAILED book-class / join-waitlist response.
struct BlacklistDetailModel: Codable {
    var reason: String?
    var resumesOn: String?
    /// FlexibleValue because Android reads this with optString (which coerces a raw JSON
    /// number to a string); read it with `hoursRemaining?.value` / `.intValue`.
    var hoursRemaining: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case reason
        case resumesOn = "resumes_on"
        case hoursRemaining = "hours_remaining"
    }
}

// MARK: - SpecialWaitlistDetailModel
/// Free-booking spam-guard payload carried under the "data" key of a book-class /
/// join-waitlist response, whenever this member already has another active booking.
/// Mirrors Android's raw JSONObject reads in GroupTrainingDetailActivity.kt - `waitlisted`
/// is set on a fresh join, `isAlreadyWaitlisted` on a re-tap of an existing entry; only
/// `waitlistType == "special"` means the guard actually triggered ("normal" just means
/// this member is on the plain waitlist, not double-booked).
struct SpecialWaitlistDetailModel: Codable {
    var waitlisted: Bool?
    var isAlreadyWaitlisted: Bool?
    var waitlistType: String?
    var bottomTab: String?
    /// FlexibleValue for the same reason as ClassDetailsModel.waitlistCount - backend
    /// types are inconsistent.
    var position: FlexibleValue?
    var notificationWindowHours: FlexibleValue?
    var deferredUntil: String?
    var blockedByBookingId: FlexibleValue?
    var canNotifyNow: Bool?
    /// True only when the backend hasn't created the waitlist row yet - see
    /// bookClass()'s pending_confirmation branch on the PHP side. Absent
    /// (nil) on every other response shape, including the confirmed one.
    var pendingConfirmation: Bool?

    enum CodingKeys: String, CodingKey {
        case waitlisted
        case isAlreadyWaitlisted = "is_already_waitlisted"
        case waitlistType = "waitlist_type"
        case bottomTab = "bottom_tab"
        case position
        case notificationWindowHours = "notification_window_hours"
        case deferredUntil = "deferred_until"
        case blockedByBookingId = "blocked_by_booking_id"
        case canNotifyNow = "can_notify_now"
        case pendingConfirmation = "pending_confirmation"
    }

    var isSpecial: Bool { waitlistType == "special" }
}

//MARK: ----------- BookedTrainerModel
struct BookedTrainerModel: Codable {
    var id: Int?
    var name: String?
    var isVerified: Bool?
    var image: String?
    var tags: [String]?
}


//MARK: ----------- Booke MEMBERSHIP BaseModel
struct BookMembershipBaseModel: Codable {
    var status: Bool?
    var data: BookMembershipDataModel?
    var msg: String?
    let errors: [String: [String]]?
    
}


//MARK: --------- BookMembershipDataModel
struct BookMembershipDataModel: Codable {
    var studio: ValityStudioDetailModel?
    var startDate: String?
    var endDate: String?
    var package: String?
    var qr: String?
    var location: String?
    
    enum CodingKeys: String, CodingKey {
        case package, qr, location
        case startDate = "start_date"
        case endDate = "end_date"
        case studio
    }
}

