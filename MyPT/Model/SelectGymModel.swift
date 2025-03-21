//
//  SelectGymModel.swift
//  MyPT
//
//  Created by techsaga corp on 18/03/25.
//

import Foundation

//MARK: ------------- GymTrainerBaseModel
struct GymTrainerBaseModel: Codable {
    var status: Bool?
    var data: GymTrainerDataModel?
    var msg: String?
}

//MARK: ------------- GymTrainerDataModel
struct GymTrainerDataModel: Codable {
    var tags: [TagModel]?
    var trainers: [GymTrainerModel]?
    var type, studioID: String?

    enum CodingKeys: String, CodingKey {
        case tags, trainers, type
        case studioID = "studio_id"
    }
}

//MARK: ----------- GymTrainerModel
struct GymTrainerModel: Codable {
    var id: Int?
    var studioID, name, location, distance: String?
    var slot: String?
    var isVerified: Bool?
    var profile: String?
    var averageRating: Int?
    var noOfRating: String?
    var tags: [TrainerTagModel]?

    enum CodingKeys: String, CodingKey {
        case id
        case studioID = "studio_id"
        case name, location, distance, slot
        case isVerified = "is_verified"
        case profile, averageRating, noOfRating, tags
    }
}


