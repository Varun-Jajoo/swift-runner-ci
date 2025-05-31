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
    }
}
