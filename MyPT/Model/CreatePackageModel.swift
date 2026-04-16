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

//MARK: ------------------ MembershipValidityBaseModel
struct MembershipValidityBaseModel: Codable {
    var status: Bool?
    var data: MembershipValityDataModel?
    var msg: String?
    let errors: [String: [String]]?
}

struct MembershipValityDataModel: Codable {
    var packageDetail : ValityPackageDetailModel?
    var studio : ValityStudioDetailModel?
}

struct ValityPackageDetailModel: Codable {
    var price : FlexibleValue?
    var validity : FlexibleValue?
    var image, name, special_msg: String?
}


struct ValityStudioDetailModel: Codable {
    var avg_rating: String?
    var id: Int?
    var name: String?
    var profile: String?
    var tags: [String]?
    var total_rating: FlexibleValue?
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
    var isPackage: Bool?  //Extra keys
    var main_price: FlexibleValue? //Extra keys
    var price: FlexibleValue? //Extra keys
    
    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
        case packageType = "package_type"
        case sessions, slots
        case isPackage
        case main_price, price
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
     var userMembers: [MemberModel]?
     var trainingPreference, slotTime: String?
     var slotID: Int?
     var address: AddressDataModel?
     var studio: PackageCheckoutStudioModel?
     
     enum CodingKeys: String, CodingKey {
         case trainer, packageDetail
         case trainingPreference = "training_preference"
         case slotTime = "slot_time"
         case slotID = "slot_id"
         case address, studio
         case userMembers
     }
 }


 //MARK: -------------- PackageDetailModel
 struct PackageDetailModel: Codable {
     var package, startDate, endDate, totalSessions, type: String?
     var price: String?
     var days: Int?
     var main_price, tax_price: FlexibleValue?

     enum CodingKeys: String, CodingKey {
         case package
         case startDate = "start_date"
         case endDate = "end_date"
         case totalSessions, price, days
         case main_price, tax_price, type
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


//MARK: ------------- PackageCheckoutStudioModel
struct PackageCheckoutStudioModel: Codable {
    var id: Int?
    var name: String?
    var image: String?
    var noOfRating, averageRating, distance, location: String?
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
    var minMember : FlexibleValue?
    var maxMember: FlexibleValue?
    var limit: String?

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
    var memberSelf, isBuddy, isGroup: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, age, gender
        case memberSelf = "self"
        case isBuddy = "is_buddy"
        case isGroup = "is_group"
    }
}


// MARK: - PaymentStatusResponseModel
struct PaymentStatusResponseModel: Codable {
    let status: Bool?
    let data: PaymentStatusData?
    let msg: String?
}

struct PaymentStatusData: Codable {
    let paymentId: Int?
    let orderRef: String?
    let transactionId: String?
    let gateway: String?
    let amount: String?
    let currency: String?
    let status: String?
    let isSuccess: Bool?
    let paymentFor: String?
    let statusMessage: String?
    let subscription: Subscription?
    let planDetails: PlanDetails?
    
    enum CodingKeys: String, CodingKey {
        case paymentId = "payment_id"
        case orderRef = "order_ref"
        case transactionId = "transaction_id"
        case gateway
        case amount
        case currency
        case status
        case isSuccess = "is_success"
        case paymentFor = "payment_for"
        case statusMessage = "status_message"
        case subscription
        case planDetails = "plan_details"
    }
}

struct Subscription: Codable {
    
    let id: Int?
    let type: String?
    let sessions: Int?
    let remainingSessions: Int?
    let sessionsDisplay: String?
    let validityDisplay: String?
    let status: String?
    let startDate: String?
    let endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case sessions
        case remainingSessions = "remaining_sessions"
        case sessionsDisplay = "sessions_display"
        case validityDisplay = "validity_display"
        case status
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct PlanDetails: Codable {
    
    let planName: String?
    let sessions: Int?
    let sessionsDisplay: String?
    let validity: String?
    let validityDisplay: String?
    let primaryTrainer: String?
    let workoutType: String?
    let trainingMode: String?
    let activationNote: String?
    
    enum CodingKeys: String, CodingKey {
        case planName = "plan_name"
        case sessions
        case sessionsDisplay = "sessions_display"
        case validity
        case validityDisplay = "validity_display"
        case primaryTrainer = "primary_trainer"
        case workoutType = "workout_type"
        case trainingMode = "training_mode"
        case activationNote = "activation_note"
    }
}


struct PaymentResponse: Codable {
    let status: Bool?
    let data: CCPaymentData?
    let msg: String?
}

struct CCPaymentData: Codable {
    let amount: String?
    let status: String?
    let paymentID: Int?
    let transactionID: String?
    let isSuccess: Bool?
    let orderRef: String?
    let paymentFor: String?
    let statusMessage: String?
    let gateway: String?
    let currency: String?
    let planDetails: CCPlanDetails?
    
    enum CodingKeys: String, CodingKey {
        case amount, status, gateway, currency
        case paymentID = "payment_id"
        case transactionID = "transaction_id"
        case isSuccess = "is_success"
        case orderRef = "order_ref"
        case paymentFor = "payment_for"
        case statusMessage = "status_message"
        case planDetails = "plan_details"
    }
}

struct CCPlanDetails: Codable {
    let validityDisplay: String?
    let workoutType: String?
    let trainingMode: String?
    let failureReason: String?
    let isMembership: Bool?
    let planName: String?
    let activationNote: String?
    let primaryTrainer: String?
    let failureNote: String?
    let sessions: Int?
    let validity: String?
    let sessionsDisplay, startDate, endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case validityDisplay = "validity_display"
        case workoutType = "workout_type"
        case trainingMode = "training_mode"
        case failureReason = "failure_reason"
        case isMembership = "is_membership"
        case planName = "plan_name"
        case activationNote = "activation_note"
        case primaryTrainer = "primary_trainer"
        case failureNote = "failure_note"
        case sessions
        case validity
        case sessionsDisplay = "sessions_display"
        case startDate = "start_date"
        case endDate = "end_date"
    }
}
