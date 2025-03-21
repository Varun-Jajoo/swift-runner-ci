//
//  StudioDetailsModel.swift
//  MyPT
//
//  Created by techsaga corp on 19/03/25.
//

import Foundation

//MARK: ----------- StudioDetailsBaseModel
struct StudioDetailsBaseModel: Codable {
     var status: Bool?
     var data: StudioDetailsModel?
     var msg: String?
 }

 //MARK: ------------ DataClass
 struct StudioDetailsModel: Codable {
     var id: Int?
     var name, description, address, noOfRating: String?
     var averageRating: String?
     var timing, latitude, distance, longitude: String?
     var profile: [String]?
     var facility: [FacilityModel]?
     var amenity: [String]?
     var gallery: [GalleryModel]?
     var reviews: [GymReviewModel]?
 }

 //MARK: ------- FacilityModel
 struct FacilityModel: Codable {
     var name: String?
     var icon: String?
 }

struct GymReviewModel: Codable {
    var id: Int?
    var name: String?
    var image: String?
    var rating: String?
}
 
//MARK: --------------- AvailabilityBaseModel
struct AvailabilityBaseModel: Codable {
    var status: Bool?
    var data: [AvailabilityDataModel]?
    var msg: String?
}

//MARK: ---------------- AvailabilityDataModel
struct AvailabilityDataModel: Codable {
    var date: String?
    var status: String?
}
