//
//  ProfileModel.swift
//  MyPT
//
//  Created by techsaga corp on 12/06/25.
//

import Foundation

 // MARK: - Profile base model
struct ProfileBaseModel: Codable {
     var status: Bool?
     var msg: String?
    var data: ProfileDataModel?
 }

 // MARK: - Data model
 struct ProfileDataModel: Codable {
     var isActive: Bool?
     var plan: PlanModel?
     var location: LocationModel?
     var trainers: [ProfileTrainerModel]?
     var healthPrefernce: [HealthPrefernceModel]?
//     var achievementStats: [AchievementStatModel]?
     var awards: [AwardsModel]?
     var activityLog: ActivityLogModel?
     var myptChart: [MyptChartModel]?
     var name, image, cover_image: String?

     enum CodingKeys: String, CodingKey {
         case isActive, location, plan, trainers, healthPrefernce, awards, activityLog
         case myptChart = "mypt_chart"
         case name, image, cover_image
     }
 }

 // MARK: ------- AchievementStatModel
 struct AwardsModel: Codable {
     var name, title: String?
     var icon: String?
 }

 // MARK: ------ ActivityLogModel
 struct ActivityLogModel: Codable {
     var msg, notification: Int?
 }

 // MARK: ----- HealthPrefernceModel
 struct HealthPrefernceModel: Codable {
     var icon: String?
     var name: String?
 }

 // MARK: ------ MyptChartModel
 struct MyptChartModel: Codable {
     var day, date: String?
     var score: FlexibleValue?
 }

 // MARK: ------- PlanModel
 struct PlanModel: Codable {
     var isPackage: Bool?
     var getTier: String?
     var remaining_sessions: Int?
     var total_sessions: Int?
     var remaining_days: Int?
 }

 // MARK: ------- TrainerModel
 struct ProfileTrainerModel: Codable {
     var image: String?
 }
 
// MARK: ------- PlanModel
struct LocationModel: Codable {
    var long: String?
    var lat: String?
    var address: String?
}

///--------- ----------------- **********************   User profile information 

// MARK: - User profile information
struct UserProfileBaseModel: Codable {
    var status: Bool?
    var data: UserProfileDataModel?
    var msg: String?
}

// MARK: - User profile information
struct UserProfileDataModel: Codable {
    var userInformation: UserInformationModel?
    var userAddress: UserAddressModel?
}

// MARK: - UserAddressModel
struct UserAddressModel: Codable {
    var id, userID: FlexibleValue?
    var address: String?
    var cityID: FlexibleValue?
    var cityName: String?
    var countryID: FlexibleValue?
    var lat, long, countryName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case address
        case cityID = "city_id"
        case cityName = "city_name"
        case countryID = "country_id"
        case lat, long
        case countryName = "country_name"
    }
}

// MARK: - UserInformationModel
struct UserInformationModel: Codable {
    var name, profile, phone, email, cover_image : String?
    var dob, gender: String?
}


// MARK: ----------- UpdateUserProfileBaseModel
struct UpdateUserProfileBaseModel: Codable {
    var status: Bool?
    var data: UpdateUserDataModel?
    var msg: String?
    var errors: [String: [String]]?
}

// MARK: - UpdateUserDataModel
struct UpdateUserDataModel: Codable {
    var name: String?
    var email: String?
    var gender: String?
    var location: String?
    var address: String?
    var country_id: String?
    var city_id: String?
    var address_id: String?
    var long: String?
    var lat: String?

    enum CodingKeys: String, CodingKey {
        case name, email, gender, location, address, country_id, city_id, address_id, long, lat
    }
}
