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
    var averageRating, noOfRating: String?
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

/*
 {
   "status": true,
   "data": {
     "id": 5,
     "name": "Ultimate Fitness",
     "address": "G8QX+4VP Foot Over Bridge, Sector 97, Noida, Uttar Pradesh 201313, India",
     "latitude": "28.537220440184296",
     "distance": "191.34 km",
     "longitude": "77.34980676323175",
     "profile": "http://mypt.test/storage",
     "facility": [
       {
         "id": 1,
         "name": "Conference Room",
         "image": "http://mypt.test/storage/facilities/conference_room.png"
       },
       {
         "id": 2,
         "name": "Swimming Pool",
         "image": "http://mypt.test/storage/facilities/swimming_pool.png"
       }
     ],
     "amenity": [],
     "gallery": [
       {
         "media_path": "http://mypt.test/storage/studio/gallery/1740814009_download (1).jpg",
         "is_image": true,
         "is_video": false
       },
       {
         "media_path": "http://mypt.test/storage/studio/gallery/1740814009_download.jpg",
         "is_image": true,
         "is_video": false
       },
       {
         "media_path": "http://mypt.test/storage/studio/gallery/1740814257_SampleVideo_1280x720_10mb.mp4",
         "is_image": false,
         "is_video": true
       }
     ],
     "reviews": [
       {
         "id": 8,
         "name": "Tyson Graham Sr.",
         "image": null,
         "rating": "4"
       }
     ]
   },
   "msg": "Data fetched successfully!"
 }
 */
