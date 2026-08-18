//
//  ClassDetailsModel.swift
//  MyPT
//
//  Created by techsaga corp on 16/05/25.
//

import Foundation

// MARK: - ClassDetailsBaseModel
struct ClassDetailsBaseModel: Codable {
    var status: Bool?
    var data: ClassDetailsModel?
    var msg: String?
    var code: String?
    /// `is_blacklisted` at the top level of the response — Android's blacklist
    /// check ORs this together with the same key nested inside `data`.
    var isBlacklisted: Bool?

    enum CodingKeys: String, CodingKey {
        case status, data, msg, code
        case isBlacklisted = "is_blacklisted"
    }
}

// MARK: - ClassDetailsModel
struct ClassDetailsModel: Codable {
    var schduleID: Int?
    /// Needed to subscribe to the `group-class.{classId}` realtime channel -
    /// distinct from `schduleID` (a specific occurrence), this is the parent
    /// class the realtime backend keys its channel/events on.
    var classId: Int?
    var isMember: Bool?
    var className: String?
    var classProfile: String?
    var classDescription, classCategory: String?
    /// FlexibleValue, not String - `classes.price` was migrated to an `INT`
    /// column (`2025_04_01_153536_change_price_column_type.php`), so
    /// `ClassEventController::classDetail()`'s `'price' => $class->price`
    /// serializes as a raw JSON number for any class with a real (paid) price,
    /// not a string. `String` decoding throws on a JSON number, failing the
    /// WHOLE struct decode - same failure mode as `averageRating` below, but
    /// this one trips on price itself rather than the trainer's rating, so it
    /// hits premium/paid classes specifically (a free class's price is more
    /// often an empty/zero string that happens to decode fine). The list
    /// model's own `price` (`UpcomingClassModel`) is already `FlexibleValue`
    /// for the same reason. Read via `.value`.
    var price: FlexibleValue?
    var trainerID: Int?
    var distance: String?
    var capacity: Int?
    var location, time, name: String?
    var profile: String?
    var isVerified: Bool?
    var followers: String?
    var trainWithMe: String?
    var quote, clientCoached: String?
    /// FlexibleValue for the same reason as `price` above - unused by any UI
    /// today, but still decoded, so still a live decode-failure risk.
    var sessions: FlexibleValue?
    /// FlexibleValue, not Int - `ClassEventController::classDetail()` sends
    /// `round($trainer->testimonials->avg('rating'), 1)`, a genuine fractional
    /// value (4.5, 4.7, ...) for any trainer with real testimonials. Decoding
    /// straight into `Int` throws on the first non-whole rating (JSONDecoder's
    /// Int decoding rejects a fractional JSON number outright), which fails
    /// the WHOLE `ClassDetailsModel` decode - and since that decode failure
    /// used to be silently swallowed (see `classDetailsApi`'s catch block),
    /// the entire detail screen (capacity, why-stands-out, what-to-bring,
    /// everything) just never updated for any class whose trainer had a
    /// non-integer average rating. Read via `.doubleValue`.
    var averageRating: FlexibleValue?
    var noOfRating: String?
    var tags: [String]? //[TrainerTagModel]?
    var isFollow: Bool?
    var certificates: [CertificateModel]?
    /// `ClassEventController::classDetail()` always returns a flat array of
    /// already-resolved URL strings here (class's own gallery, or the
    /// trainer's media as fallback) - never `{media_path, is_image, is_video}`
    /// objects like GalleryModel (that shape belongs to the trainer-profile
    /// endpoint). Was mistyped as `[GalleryModel]?` and could never actually
    /// decode for this endpoint.
    var mediaGallery: [String]?
    // FlexibleValue: backend types are inconsistent (Android reads these with the coercing
    // optInt/optDouble accessors). Read via `.intValue` / `.doubleValue` / `.value`.
    var bookedCount: FlexibleValue?
    var remainingSeats: FlexibleValue?
    var waitlistCount: FlexibleValue?
    var isBooked, isWaitlisted: Bool?
    var access: String?
    var studioLat, studioLng: FlexibleValue?
    var classType: String?
    /// `is_blacklisted` nested inside `data` — Android's blacklist check ORs
    /// this together with the same key at the response's top level.
    var isBlacklisted: Bool?
    /// These three only appear when `data` is actually describing a blacklist
    /// (the backend overloads the same `data` key for both shapes), so they sit
    /// alongside the normal class-detail fields rather than a separate type.
    var reason: String?
    var resumesOn: String?
    /// FlexibleValue because Android reads this with `optString` (which coerces
    /// a raw JSON number to a string); read it with `.value` / `.intValue`.
    var hoursRemaining: FlexibleValue?
    /// Free-booking spam guard: tells the client BEFORE the user taps
    /// Book Slot / Join Waitlist whether that tap will land them on the
    /// special double-booking waitlist, so the confirm sheet can be
    /// skipped entirely in favor of the double-booking sheet.
    var willSpecialWaitlist: Bool?
    /// FlexibleValue for the same reason as waitlistCount/daysRemaining above.
    var specialWaitlistNotifyHours: FlexibleValue?
    var normalWaitlistCount: FlexibleValue?
    var specialWaitlistCount: FlexibleValue?
    var onlyExtraBooking: Bool?
    var onlySpecialWaitlist: Bool?
    var isOnlyExtraBooking: Bool?
    var isOnlySpecialWaitlist: Bool?
    var waitlistType: String?
    /// Verified against `ClassEventController::classDetail()`: it never
    /// actually sends either key - `time`/`start_end` are always pre-formatted
    /// strings like "Fri, 14 Aug • 7-8 AM" already. Harmless either way since
    /// `GroupClassCardFormatter.formatTimeForUI` short-circuits on any input
    /// containing "•" before it would ever consult these; kept only so the
    /// `detail.date ?? detail.startDate` fallback in `apply(detail:)` compiles.
    var date: String?
    var startDate: String?
    /// Icon keys are always one of the backend's fixed preset set (see
    /// ClassEventController::APP_DETAIL_ICON_KEYS) - never raw emoji - so a
    /// plain key-to-asset lookup is all the UI needs (checklistIcon(for:) in
    /// GroupTrainingDetailViewController).
    var whatToBring: [ChecklistItemModel]?
    var thingsToKnow: [ChecklistItemModel]?
    /// Title/subtitle pairs an admin configures per class (0-4 of them) - no
    /// icon key, unlike whatToBring/thingsToKnow, so the UI picks an icon by
    /// card position instead (see GroupTrainingDetailViewController's
    /// whyStandsOutIcon(forIndex:)).
    var whyStandsOut: [WhyStandsOutItemModel]?

    enum CodingKeys: String, CodingKey {
        case schduleID = "schdule_id"
        case classId = "class_id"
        case isMember = "is_member"
        case className = "class_name"
        case classProfile = "class_profile"
        case classDescription = "class_description"
        case classCategory = "class_category"
        case price
        case trainerID = "trainer_id"
        case distance, capacity, location, time, name, profile, isVerified, followers
        case trainWithMe = "train_with_me"
        case quote, sessions, clientCoached, averageRating, noOfRating, tags, isFollow, certificates
        case mediaGallery = "media_gallery"
        case bookedCount = "booked_count"
        case remainingSeats = "remaining_seats"
        case waitlistCount = "waitlist_count"
        case isBooked = "is_booked"
        case isWaitlisted = "is_waitlisted"
        case access
        case studioLat = "studio_lat"
        case studioLng = "studio_lng"
        case classType = "class_type"
        case isBlacklisted = "is_blacklisted"
        case reason
        case resumesOn = "resumes_on"
        case hoursRemaining = "hours_remaining"
        case willSpecialWaitlist = "will_special_waitlist"
        case specialWaitlistNotifyHours = "special_waitlist_notify_hours"
        case normalWaitlistCount = "normal_waitlist_count"
        case specialWaitlistCount = "special_waitlist_count"
        case onlyExtraBooking = "only_extra_booking"
        case onlySpecialWaitlist = "only_special_waitlist"
        case isOnlyExtraBooking = "is_only_extra_booking"
        case isOnlySpecialWaitlist = "is_only_special_waitlist"
        case waitlistType = "waitlist_type"
        case date
        case startDate = "start_date"
        case whatToBring = "what_to_bring"
        case thingsToKnow = "things_to_know"
        case whyStandsOut = "why_stands_out"
    }
}

struct ChecklistItemModel: Codable {
    var text: String?
    var icon: String?
}

struct WhyStandsOutItemModel: Codable {
    var title: String?
    var subtitle: String?
}
