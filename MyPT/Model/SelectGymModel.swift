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
    var trainer: GymTrainerModel?
    var type, studioID: String?
    var studios: [StudioModel]?

    enum CodingKeys: String, CodingKey {
        case tags, trainers, type, studios, trainer
        case studioID = "studio_id"
    }
}

//MARK: ----------- GymTrainerModel
struct GymTrainerModel: Codable {
    var id: Int?
    var studioID, name, location, distance: String?
    var slot: String?
    var isVerified, isfull: Bool?
    var profile: String?
    var averageRating: FlexibleValue?
    var noOfRating, trainWithMe: String?
    var tags: [TrainerTagModel]?
    var is_group, isPackage:Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case studioID = "studio_id"
        case isfull = "is_full"
        case name, location, distance, slot
        case isVerified = "is_verified"
        case trainWithMe = "train_with_me"
        case isPackage = "is_package"
        case profile, averageRating, noOfRating, tags, is_group
    }
}

struct StudioModel: Codable {
    var id: Int?
    var address, distance, image, name: String?
    var isSelected: Bool?

    enum CodingKeys: String, CodingKey {
        case id, isSelected
        case address, distance, image, name
    }
}


