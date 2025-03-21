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
    var name, distance, slot: String?
    var isVerified: Bool?
    var location: String?
    var profile, noOfRating: String?
    var averageRating: FlexibleValue?
    var tags: [TrainerTagModel]?
    var address: String?
    var email, timing: String?
    var activity: [TrainerTagModel]?

    enum CodingKeys: String, CodingKey {
        case id, name, distance, slot
        case isVerified = "is_verified"
        case location, profile, averageRating, noOfRating, tags, address, email, timing
        case activity
    }
}

//MARK: ---------- TrainerTagModel
struct TrainerTagModel: Codable {
    var id: Int?
    var name: String?
}

/*
 // MARK: - Welcome
 struct Welcome: Codable {
     var status: Bool?
     var data: DataClass?
     var msg: String?
 }

 // MARK: - DataClass
 struct DataClass: Codable {
     var id: Int?
     var name, description, address, noOfRating: String?
     var averageRating: JSONNull?
     var timing, latitude, distance, longitude: String?
     var profile: [String]?
     var facility: [Facility]?
     var amenity: [String]?
     var gallery: [Gallery]?
     var reviews: [JSONAny]?
 }

 // MARK: - Facility
 struct Facility: Codable {
     var name: String?
     var icon: String?
 }

 // MARK: - Gallery
gghhh  struct Gallery: Codable {
     var mediaPath: String?
     var isImage, isVideo: Bool?

     enum CodingKeys: String, CodingKey {
         case mediaPath = "media_path"
         case isImage = "is_image"
         case isVideo = "is_video"
     }
 }
 */

/*
 var id: Int?
 var name, distance, location, email: String?
 var profile: String?
 var averageRating: Int?
 var noOfRating: String?
 var activity: [Activity]?
 */

/*
 {"status":true,"data":{"tags":[{"id":1,"name":"Fitness ","description":null,"icon":null,"image":null},{"id":2,"name":"Power Gym","description":null,"icon":null,"image":null},{"id":3,"name":"non Stop","description":null,"icon":null,"image":null},{"id":4,"name":"Good time","description":null,"icon":null,"image":null},{"id":5,"name":"Fitness","description":null,"icon":null,"image":null},{"id":6,"name":"grg","description":"rgrgrgrg","icon":null,"image":"http:\/\/mypt.techsaga.live\/storage\/speciality\/documents\/1739338327_selectedgoalsother.png"}],"trainers":[{"id":1,"studio_id":"5","name":"Energies ","location":"noida sec-15","distance":"24.81 km","slot":"2","is_verified":true,"profile":"http:\/\/mypt.techsaga.live\/storage\/trainer\/picture\/1735298402_download (2).jfif","averageRating":0,"noOfRating":"0","tags":[{"id":4,"name":"Good time"}]}],"type":"gym trainer","studio_id":"5"},"msg":"Data fetched successfully!"}
 */

