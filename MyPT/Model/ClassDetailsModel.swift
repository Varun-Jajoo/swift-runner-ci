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
    var isMember: Bool?
    var className: String?
    var classProfile: String?
    var classDescription, classCategory, price: String?
    var trainerID: Int?
    var distance: String?
    var capacity: Int?
    var location, time, name: String?
    var profile: String?
    var isVerified: Bool?
    var followers: String?
    var trainWithMe: String?
    var quote, sessions, clientCoached: String?
    var averageRating: Int?
    var noOfRating: String?
    var tags: [String]? //[TrainerTagModel]?
    var isFollow: Bool?
    var certificates: [CertificateModel]?
    var mediaGallery: [GalleryModel]?
    // FlexibleValue: backend types are inconsistent (Android reads these with the coercing
    // optInt/optDouble accessors). Read via `.intValue` / `.doubleValue` / `.value`.
    var bookedCount: FlexibleValue?
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
    var daysRemaining: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case schduleID = "schdule_id"
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
        case isBooked = "is_booked"
        case isWaitlisted = "is_waitlisted"
        case access
        case studioLat = "studio_lat"
        case studioLng = "studio_lng"
        case classType = "class_type"
        case isBlacklisted = "is_blacklisted"
        case reason
        case resumesOn = "resumes_on"
        case daysRemaining = "days_remaining"
    }
}
