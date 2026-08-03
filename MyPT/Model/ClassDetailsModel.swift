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
    }
}
