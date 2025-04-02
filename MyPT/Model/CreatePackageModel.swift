//
//  CreatePackageModel.swift
//  MyPT
//
//  Created by techsaga corp on 29/03/25.
//

import Foundation


//MARK: ------------------ CreatePackageBaseModel
struct CreatePackageBaseModel: Codable {
    var status: Bool?
    var data: CreatePackageDataModel?
    var msg: String?
    let errors: [String: [String]]?
}

//MARK: --------------- CreatePackageDataModel
struct CreatePackageDataModel: Codable {
    var trainer: CreatePackageTrainerModel?
    var totalPrice, pricePerSession: Double?
    var validity: String?
    var totalDays: Int?
    var details: DetailsModel?
}

//MARK: ------------------ DetailsModel
struct DetailsModel: Codable {
    var packageType: Int?
    var sessions: String?

    enum CodingKeys: String, CodingKey {
        case packageType = "package_type"
        case sessions
    }
}

//MARK: ----------------- CreatePackageTrainerModel
struct CreatePackageTrainerModel: Codable {
    var id: Int?
    var name, image: String?
    var tags: [TrainerTagModel]?
    var studioID: String?

    enum CodingKeys: String, CodingKey {
        case id, name, image, tags
        case studioID = "studio_id"
    }
}


//MARK: --------------------- SetDateBaseModel
struct SetDateBaseModel: Codable {
    var status: Bool?
    var data: SetDateModel?
    var msg: String?
    let errors: [String: [String]]?
}

//MARK: --------------------- SetDateModel
struct SetDateModel: Codable {
    var startDate, endDate, packageType, sessions: String?
    var slots: [SlotModel]?

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
        case packageType = "package_type"
        case sessions, slots
    }
}


//MARK:  ---------------------------- PackageCheckoutBaseModel(Review Package)

//MARK: ---------------- PackageCheckoutBaseModel
 struct PackageCheckoutBaseModel: Codable {
     var status: Bool?
     var data: PackageCheckoutDataModel?
     var msg: String?
     let errors: [String: [String]]?
 }

 //MARK: ------------- PackageCheckoutDataModel
 struct PackageCheckoutDataModel: Codable {
     var trainer: PackageCheckoutTrainerModel?
     var packageDetail: PackageDetailModel?
     var trainingPreference, slotTime: String?
     var slotID: Int?
     var address: AddressDataModel?
     
     enum CodingKeys: String, CodingKey {
         case trainer, packageDetail
         case trainingPreference = "training_preference"
         case slotTime = "slot_time"
         case slotID = "slot_id"
         case address
     }
 }

/*
 address =     {
     "building_name" = "building 22";
     "city_id" = 19;
     "city_name" = "Al Dhafra";
     "country_id" = 231;
     "country_name" = "United Arab Emirates";
     id = 7;
     landmark = shop;
     lat = "28.584125";
     long = "77.2753162";
     "mobile_no" = 7676767687;
     street = "s 444";
     type = office;
     "user_id" = 17;
 };
 */

 //MARK: -------------- PackageDetailModel
 struct PackageDetailModel: Codable {
     var package, startDate, endDate, totalSessions: String?
     var price: String?
     var days: Int?

     enum CodingKeys: String, CodingKey {
         case package
         case startDate = "start_date"
         case endDate = "end_date"
         case totalSessions, price, days
     }
 }

 //MARK: ------------- PackageCheckoutTrainerModel
 struct PackageCheckoutTrainerModel: Codable {
     var id: Int?
     var name: String?
     var profile: String?
     var noOfRating, averageRating: String?
     var tags: [String]?
 }


//MARK: ------------- GET MEMBERS FLOW

struct AddMemberBaseModel: Codable {
    var status: Bool?
    var data: MemberModel?
    var msg: String?
    let errors: [String: [String]]?
}

struct MemberBaseModel: Codable {
    var status: Bool?
    var data: MemberDataModel?
    var msg: String?
}

//MARK: ------------- MemberDataModel
struct MemberDataModel: Codable {
    var members: [MemberModel]?
    var minMember, maxMember, limit: String?

    enum CodingKeys: String, CodingKey {
        case members
        case minMember = "min_member"
        case maxMember = "max_member"
        case limit
    }
}

//MARK: ------------- MemberModel
struct MemberModel: Codable {
    var id: Int?
    var name, gender: String?
    var age: FlexibleValue?
    var memberSelf: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, age, gender
        case memberSelf = "self"
    }
}

