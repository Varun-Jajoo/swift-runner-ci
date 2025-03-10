//
//  GetTrainerModel.swift
//  MyPT
//
//  Created by techsaga corp on 07/03/25.
//

import Foundation

//MARK: -------- GetTrainerBaseModel
struct GetTrainerBaseModel: Codable {
    var status: Bool?
    var data: MainDataModel?
    var msg: String?
}

//MARK: ----------- MainDataModel
struct MainDataModel: Codable {
    var tags: [TagModel]?
    var trainers: [TrainerModel]?
//    var studios: [StudioModel]?
    var type: String?
}

//MARK: -------------- TagModel
struct TagModel: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var icon: String?
    var image: String?
}

// MARK: ------------- TrainerModel
struct TrainerModel: Codable {
    var id: Int?
    var name, distance, slot: String?
    var isVerified: Bool?
    var location: String?
    var profile, noOfRating: String?
    var averageRating: FlexibleValue?
    var tags: [TrainerTagModel]?
    var address: String?
    var email: String?
    var activity: [TrainerTagModel]?

    enum CodingKeys: String, CodingKey {
        case id, name, distance, slot
        case isVerified = "is_verified"
        case location, profile, averageRating, noOfRating, tags
    }
}

//MARK: ---------- TrainerTagModel
struct TrainerTagModel: Codable {
    var id: Int?
    var name: String?
}

/*
// MARK: - Studio
struct StudioModel: Codable {
    var id: Int?
    var name, distance: String?
    var address: String?
    var email: String?
    var profile: String?
    var averageRating: Double?
    var noOfRating: String?
    var activity: [TrainerTagModel]?
}
*/

//// MARK: - Activity
//struct Activity: Codable {
//    var id: Int?
//    var name: String?
//}

