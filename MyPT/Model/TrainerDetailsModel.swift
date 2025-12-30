//
//  TrainerDetailsModel.swift
//  MyPT
//
//  Created by techsaga corp on 12/03/25.
//

import Foundation

// MARK: ------------ Trainer details base model
struct TrainerDetailsBaseModel: Codable {
    var status: Bool?
    var data: TrainerDetalsModel?
    var msg: String?
}

//MARK: --------------- TrainerDetalsModel
struct TrainerDetalsModel: Codable {
    var id: Int?
    var name: String?
    var profile: String?
    var follower, distance, trainWithMe, location: String?
    var description, quote, clientCoached, experience: String?
    var averageRating, noOfRating: FlexibleValue?
    var isVerified:Bool?
    var isFollowing:Bool?
    var certificates: [CertificateModel]?
    var tags: [TrainerTagModel]?
    var reviews: [ReviewModel]?
    var galleries: [GalleryModel]?

    enum CodingKeys: String, CodingKey {
        case id, name, profile, follower, distance
        case trainWithMe = "train_with_me"
        case location, description, quote, clientCoached, experience, averageRating, noOfRating, certificates, tags, reviews, galleries, isVerified, isFollowing
    }
}


//MARK: --------- CertificateModel
struct CertificateModel: Codable {
    var name, level: String?
}

//MARK: - Gallery
struct GalleryModel: Codable {
    var mediaPath: String?
    var isImage, isVideo: Bool?

    enum CodingKeys: String, CodingKey {
        case mediaPath = "media_path"
        case isImage = "is_image"
        case isVideo = "is_video"
    }
}

//ReviewModel Example Review struct (adjust based on actual data structure)
struct ReviewModel: Codable {
    var user: String?
    var rating: Double?
    var comment: String?
}


