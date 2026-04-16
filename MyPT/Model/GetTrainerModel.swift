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
    var studios: [TrainerModel]?
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



// MARK: ------------- TrainerModel / StudioModel
struct TrainerModel: Codable {
    var id: Int?
    var name, description, distance, studioTag : String? //slot
    var slot: FlexibleValue?
    var isVerified, isfull: Bool?
    var location: String?
    var profile, noOfRating: String?
    var averageRating: FlexibleValue?
    var tags: [TrainerTagModel]?
    var address: String?
    var email, timing, trainWithMe: String?
    var totalAvailable: Int?
    var is_group, isPackage: Bool?
    var activity: [TrainerTagModel]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, distance, slot
        case studioTag = "tag"
        case isVerified = "is_verified"
        case isfull = "is_full"
        case totalAvailable = "total_available"
        case trainWithMe = "train_with_me"
        case isPackage = "is_package"
        case location, profile, averageRating, noOfRating, tags, address, email, timing
        case activity, is_group
    }
}

//MARK: ----------
struct TrainerTagModel: Codable {
    var id: Int?
    var name: String?
    var pivot: TrainerPivotModel?
    
}

struct TrainerPivotModel: Codable {
    var trainer_id: FlexibleValue?
    var speciality_id: FlexibleValue?
}
