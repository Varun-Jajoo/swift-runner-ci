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
     var otherSubscriptions: [OtherSubscriptionsModel]?
     
     var name, image, cover_image: String?

     enum CodingKeys: String, CodingKey {
         case isActive, location, plan, trainers, healthPrefernce, awards, activityLog, otherSubscriptions
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

// MARK: ------- OtherSubscriptionsModel
struct OtherSubscriptionsModel: Codable {
    var isPackage : Bool?
    var getTier : String?
    var tier_image : String?
    var isUpgrade : Bool?
    var remaining_sessions : FlexibleValue?
    var total_sessions : FlexibleValue?
    var remaining_days : FlexibleValue?
    var total_days : FlexibleValue?
    var plan_id: FlexibleValue?
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


//MARK: ----------------------- HEALTH STATS
// MARK: ------------ STATS MODEL
struct HealthStatsBaseModel: Codable {
    var status: Bool?
    var data: HealthStatsDataModel?
    var msg: String?
}

// MARK: --------- HealthStatsDataModel
struct HealthStatsDataModel: Codable {
    var healthOverview: HealthOverview?
    var physicalMeasurement: PhysicalMeasurement?
    var bodyComposition: BodyComposition?
    var bodyFat: BodyFat?
    var waistHipRatio: WaistHipRatio?
    var cardiovascular: Cardiovascular?
    var healthData: HealthData?
    var cardioInsights: CardioInsights?
    var customGoal: String?

    enum CodingKeys: String, CodingKey {
        case healthOverview, physicalMeasurement, bodyComposition, bodyFat
        case waistHipRatio = "waist_hip_ratio"
        case cardiovascular, healthData, cardioInsights, customGoal
    }
}

// MARK: - BodyComposition
struct BodyComposition: Codable {
    var bodyMass: FlexibleValue?
    var bodyMassStatus: String?

    enum CodingKeys: String, CodingKey {
        case bodyMass = "body_mass"
        case bodyMassStatus = "body_mass_status"
    }
}

// MARK: - BodyFat
struct BodyFat: Codable {
    var bodyFat: FlexibleValue?
    var bodyFatStatus, thighs, chest: String?
    var abdomen, triceps, subscapular, axila: String?
    var subscapula: String?

    enum CodingKeys: String, CodingKey {
        case bodyFat = "body_fat"
        case bodyFatStatus = "body_fat_status"
        case thighs, chest, abdomen, triceps, subscapular, axila, subscapula
    }
}

// MARK: - Cardiovascular
struct Cardiovascular: Codable {
    var restingHeartRate, maxHeartRate, diastolicBp, systolicBp: String?

    enum CodingKeys: String, CodingKey {
        case restingHeartRate = "resting_heart_rate"
        case maxHeartRate = "max_heart_rate"
        case diastolicBp = "diastolic_bp"
        case systolicBp = "systolic_bp"
    }
}

// MARK: - HealthOverview
struct HealthOverview: Codable {
    var month, activities, calories, exercise: FlexibleValue?
}

// MARK: - PhysicalMeasurement
struct PhysicalMeasurement: Codable {
    var height, weight: String?
}

// MARK: - WaistHipRatio
struct WaistHipRatio: Codable {
    var ratio, hip, waist, status: String?
}

// MARK: - CardioInsights
struct CardioInsights: Codable {
    var cholesterol, hdl: Cholesterol?
}

// MARK: - Cholesterol
struct Cholesterol: Codable {
    var value, status: String?
}

// MARK: - HealthData
struct HealthData: Codable {
    var height, weight: String?
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
     var healthOverview: HealthOverview?
     var physicalMeasurement: PhysicalMeasurement?
     var bodyComposition: BodyComposition?
     var bodyFat: BodyFat?
     var waistHipRatio: WaistHipRatio?
     var cardiovascular: Cardiovascular?

     enum CodingKeys: String, CodingKey {
         case healthOverview, physicalMeasurement, bodyComposition, bodyFat
         case waistHipRatio = "waist_hip_ratio"
         case cardiovascular
     }
 }

 // MARK: - BodyComposition
 struct BodyComposition: Codable {
     var bodyMass: Double?
     var bodyMassStatus: String?

     enum CodingKeys: String, CodingKey {
         case bodyMass = "body_mass"
         case bodyMassStatus = "body_mass_status"
     }
 }

 // MARK: - BodyFat
 struct BodyFat: Codable {
     var bodyFat: Double?
     var bodyFatStatus, thighs, chest, abdomen: String?
     var triceps, subscapular, axila, subscapula: String?

     enum CodingKeys: String, CodingKey {
         case bodyFat = "body_fat"
         case bodyFatStatus = "body_fat_status"
         case thighs, chest, abdomen, triceps, subscapular, axila, subscapula
     }
 }

 // MARK: - Cardiovascular
 struct Cardiovascular: Codable {
     var restingHeartRate, maxHeartRate, diastolicBp, systolicBp: String?

     enum CodingKeys: String, CodingKey {
         case restingHeartRate = "resting_heart_rate"
         case maxHeartRate = "max_heart_rate"
         case diastolicBp = "diastolic_bp"
         case systolicBp = "systolic_bp"
     }
 }

 // MARK: - HealthOverview
 struct HealthOverview: Codable {
     var month, activities, calories, exercise: String?
 }

 // MARK: - PhysicalMeasurement
 struct PhysicalMeasurement: Codable {
     var height, weight: String?
 }

 // MARK: - WaistHipRatio
 struct WaistHipRatio: Codable {
     var ratio, hip, waist, status: String?
 }
 */


// MARK: ------------
/*
struct HealthStatsBaseModel: Codable {
    var status: Bool?
    var data: HealthStatsDataModel?
    var msg: String?
}

// MARK: - DataClass
struct HealthStatsDataModel: Codable {
    var healthData: HealthData?
    var cardioInsights: CardioInsights?
    var customGoal: String?
    
    var healthOverview: HealthOverview?
    var physicalMeasurement: PhysicalMeasurement?
    var bodyComposition: BodyComposition?
    var bodyFat: BodyFat?
    var waistHipRatio: WaistHipRatio?
    var cardiovascular: Cardiovascular?

    enum CodingKeys: String, CodingKey {
        case healthOverview, physicalMeasurement, bodyComposition, bodyFat
        case waistHipRatio = "waist_hip_ratio"
        case cardiovascular
    }
}

// MARK: - CardioInsights
struct CardioInsights: Codable {
    var cholesterol, hdl: Cholesterol?
}

// MARK: - Cholesterol
struct Cholesterol: Codable {
    var value, status: String?
}

// MARK: - HealthData
struct HealthData: Codable {
    var height, weight: String?
}
*/



/*
 // MARK: - Welcome
 struct Welcome: Codable {
     var status: Bool?
     var data: DataClass?
     var msg: String?
 }

 // MARK: - DataClass
 struct DataClass: Codable {
     var healthOverview: HealthOverview?
     var physicalMeasurement: PhysicalMeasurement?
     var bodyComposition: BodyComposition?
     var bodyFat: BodyFat?
     var waistHipRatio: WaistHipRatio?
     var cardiovascular: Cardiovascular?

     enum CodingKeys: String, CodingKey {
         case healthOverview, physicalMeasurement, bodyComposition, bodyFat
         case waistHipRatio = "waist_hip_ratio"
         case cardiovascular
     }
 }

 // MARK: - BodyComposition
 struct BodyComposition: Codable {
     var bodyMass: Double?
     var bodyMassStatus: String?

     enum CodingKeys: String, CodingKey {
         case bodyMass = "body_mass"
         case bodyMassStatus = "body_mass_status"
     }
 }

 // MARK: - BodyFat
 struct BodyFat: Codable {
     var bodyFat, bodyFatStatus, thighs, chest: String?
     var abdomen, triceps, subscapular, axila: String?
     var subscapula: String?

     enum CodingKeys: String, CodingKey {
         case bodyFat = "body_fat"
         case bodyFatStatus = "body_fat_status"
         case thighs, chest, abdomen, triceps, subscapular, axila, subscapula
     }
 }

 // MARK: - Cardiovascular
 struct Cardiovascular: Codable {
     var restingHeartRate, maxHeartRate, diastolicBp, systolicBp: String?

     enum CodingKeys: String, CodingKey {
         case restingHeartRate = "resting_heart_rate"
         case maxHeartRate = "max_heart_rate"
         case diastolicBp = "diastolic_bp"
         case systolicBp = "systolic_bp"
     }
 }

 // MARK: - HealthOverview
 struct HealthOverview: Codable {
     var month, activities, calories, exercise: String?
 }

 // MARK: - PhysicalMeasurement
 struct PhysicalMeasurement: Codable {
     var height, weight: String?
 }

 // MARK: - WaistHipRatio
 struct WaistHipRatio: Codable {
     var ratio, hip, waist, status: String?
 }
 */
