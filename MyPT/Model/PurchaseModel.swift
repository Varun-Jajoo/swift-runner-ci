//
//  PurchaseModel.swift
//  MyPT
//
//  Created by Pratham Gupta on 26/01/26.
//

import Foundation

// MARK: - GroupTrainerModel
struct GroupTrainerModel: Codable {
    let status: Bool?
    let data: GroupTrainerData?
    let msg: String?
}

// MARK: - DataClass
struct GroupTrainerData: Codable {
    let group: Group?
    let primaryTrainer: AryTrainer?
    let secondaryTrainers: [AryTrainer]?
    let secondaryTrainersNote: String?

    enum CodingKeys: String, CodingKey {
        case group
        case primaryTrainer = "primary_trainer"
        case secondaryTrainers = "secondary_trainers"
        case secondaryTrainersNote = "secondary_trainers_note"
    }
}

// MARK: - Group
struct Group: Codable {
    let id, name, description: String?
    let image: String?
    let type: String?
}

// MARK: - AryTrainer
struct AryTrainer: Codable {
    let id, name: String?
    let profile: String?
    let phone: String?
    let rating: Int?
    let tags: [String]?
    let badge: String?
}



// MARk: Review package workout
// MARK: - ReviewPackageCheckoutModel
struct ReviewPackageCheckoutModel: Codable {
    let status: Bool?
    let data: ReviewPackageCheckoutData?
    let msg: String?
}

// MARK: - ReviewPackageCheckoutData
struct ReviewPackageCheckoutData: Codable {
    let availablePromos: [AvailablePromo]?
    let appliedOffer: AppliedOffer?
    let address: Address?
    let upgradePlan: UpgradePlan?
    let trainerDetail: ReviewTrainerDetail?
    let packageDetails: PackageDetails?
    let paymentMsg: String?
    let studio: StudioData?
    var best_plans: [BestPlanData]?
    var is_renewal: Bool?
    var renewal_info: RenewalInfo?
    var subscription_id: Int?

    enum CodingKeys: String, CodingKey {
        case availablePromos = "available_promos"
        case appliedOffer = "applied_offer"
        case address, best_plans
        case upgradePlan = "upgrade_plan"
        case trainerDetail = "trainer_detail"
        case packageDetails = "package_details"
        case paymentMsg = "payment_msg"
        case studio, subscription_id, is_renewal
        case renewal_info
    }
}

// MARK: - Address
struct Address: Codable {
    let id, userID: Int?
    let buildingName, street, villa_name, emirate_name: String?
    let landmark: String?
    let mobileNo, type: String?
    let cityID: Int?
    let cityName: String?
    let countryID: Int?
    let lat, long, countryName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case buildingName = "building_name"
        case street, landmark
        case mobileNo = "mobile_no"
        case type
        case cityID = "city_id"
        case cityName = "city_name"
        case countryID = "country_id"
        case lat, long, villa_name, emirate_name
        case countryName = "country_name"
    }
}

// MARK: - StudioData
struct StudioData: Codable {
    let id: Int?
    let address, name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case address
        case name
    }
}

// MARK: - RenewalInfo
struct RenewalInfo: Codable {
    let previous_sessions, remaining_sessions: Int?
    let new_end_date, message, new_start_date, expired_date: String?
    var is_expired: Bool?

    enum CodingKeys: String, CodingKey {
        case previous_sessions, remaining_sessions
        case new_end_date, new_start_date, expired_date
        case message, is_expired
    }
}

// MARK: - AppliedOffer
//struct AppliedOffer: Codable {
//    let id: Int?
//    let code, name, offerMode, benefitType: String?
//    let discountType: String?
//    let discountValue, discountAmount, freeSessions, totalSessions: Int?
//    let description, originalPrice: String?
//    let finalPrice: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case id, code, name
//        case offerMode = "offer_mode"
//        case benefitType = "benefit_type"
//        case discountType = "discount_type"
//        case discountValue = "discount_value"
//        case discountAmount = "discount_amount"
//        case freeSessions = "free_sessions"
//        case totalSessions = "total_sessions"
//        case description
//        case originalPrice = "original_price"
//        case finalPrice = "final_price"
//    }
//}

struct AppliedOffer: Codable {
    let id: Int?
    let code, name, offerMode, benefitType: String?
    let discountType: String?
    let discountValue: Int?
    let discountAmount: Int?
    let freeSessions: Int?
    let totalSessions: Int?
    let description: String?
    let originalPrice: String?
    let finalPrice: Int?
}


// MARK: - AvailablePromo
struct AvailablePromo: Codable {
    let id: Int?
    let offerCode, name, offerDetails: String?
    let productType: Int?
    let offerMode, benefitType, discountType: String?
    let purchaseValue, freeSessions: Int?
    let description, expiryDate: String?
    let isApplied: Bool?
    let discountAmount, discountValue: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case id
        case offerCode = "offer_code"
        case name
        case offerDetails = "offer_details"
        case productType = "product_type"
        case offerMode = "offer_mode"
        case benefitType = "benefit_type"
        case discountType = "discount_type"
        case purchaseValue = "purchase_value"
        case discountValue = "discount_value"
        case discountAmount = "discount_amount"
        case freeSessions = "free_sessions"
        case description
        case isApplied = "is_applied"
        case expiryDate = "expiry_date"
    }
}

// MARK: - PackageDetails
//struct PackageDetails: Codable {
//    let type: String?
//    let sessions, bonusSessions, totalSessions: Int?
//    let packageType, addressID, studioID, trainerID: String?
//    let bestPlanID: String?
//    let isBestPlan: Bool?
//    let price: Int?
//    let pricePerSession, validity: String?
//    let validityDays, taxRate: Int?
//    let taxAmount, mainPrice: Double?
//    let appliedOfferID: Int?
//    let textMsg: String?
//
//    enum CodingKeys: String, CodingKey {
//        case type, sessions
//        case bonusSessions = "bonus_sessions"
//        case totalSessions = "total_sessions"
//        case packageType = "package_type"
//        case addressID = "address_id"
//        case studioID = "studio_id"
//        case trainerID = "trainer_id"
//        case bestPlanID = "best_plan_id"
//        case isBestPlan = "is_best_plan"
//        case price
//        case pricePerSession = "price_per_session"
//        case validity
//        case validityDays = "validity_days"
//        case taxRate = "tax_rate"
//        case taxAmount = "tax_amount"
//        case mainPrice = "main_price"
//        case appliedOfferID = "applied_offer_id"
//        case textMsg = "text_msg"
//    }
//}

struct PackageDetails: Codable {
    let type: String?
    let sessions: Int?
    let bonusSessions: Int?
    let totalSessions: Int?
    let packageType: Int?
    let addressID: Int?
    let studioID: Int?
    let trainerID: Int?
    let bestPlanID: Int?
    let isBestPlan: Bool?
    let price: Double?
    let pricePerSession: FlexibleValue?
    let validity, packageName: String?
    let validityDays: Int?
    let taxRate: Int?
    let taxAmount: Double?
    let mainPrice: Double?
    let appliedOfferID: Int?
    let textMsg, early_renewal_text: String?
    let is_early_renew: Bool?
    let original_price, early_renewal_discount: Double?
    let start_date, end_date: String?

    enum CodingKeys: String, CodingKey {
        case type, sessions
        case bonusSessions = "bonus_sessions"
        case totalSessions = "total_sessions"
        case packageType = "package_type"
        case packageName = "package_name"
        case addressID = "address_id"
        case studioID = "studio_id"
        case trainerID = "trainer_id"
        case bestPlanID = "best_plan_id"
        case isBestPlan = "is_best_plan"
        case price
        case pricePerSession = "price_per_session"
        case validity
        case validityDays = "validity_days"
        case taxRate = "tax_rate"
        case taxAmount = "tax_amount"
        case mainPrice = "main_price"
        case appliedOfferID = "applied_offer_id"
        case textMsg = "text_msg"
        case early_renewal_text, is_early_renew, original_price, early_renewal_discount
        case start_date, end_date
    }
}


// MARK: - TrainerDetail
struct ReviewTrainerDetail: Codable {
    let primaryTrainer: ReviewPrimaryTrainer?
    let secondaryTrainers: [ReviewPrimaryTrainer]?
    let isGroup: Bool?

    enum CodingKeys: String, CodingKey {
        case primaryTrainer = "primary_trainer"
        case secondaryTrainers = "secondary_trainers"
        case isGroup = "is_group"
    }
}

// MARK: - PrimaryTrainer
struct ReviewPrimaryTrainer: Codable {
    let id, name: String?
    let profile: String?
    let phone, rating: String?
    let badge: String?
}

// MARK: - UpgradePlan
struct UpgradePlan: Codable {
    let id, title: String?
    let sessions, price: Int?
    let currency: String?
    let pricePerSession: FlexibleValue?
    let validity, badgeText: String?
    let backgroundImage: String?
    let specialMsg: String?

    enum CodingKeys: String, CodingKey {
        case id, title, sessions, price, currency
        case pricePerSession = "price_per_session"
        case validity
        case badgeText = "badge_text"
        case backgroundImage = "background_image"
        case specialMsg = "special_msg"
    }
}

// MARK: - TermsConditionRsponse
struct TermsConditionRsponse: Codable {
    let status: Bool?
    let data: TermsConditionData?
    let msg: String?
}

// MARK: - DataClass
struct TermsConditionData: Codable {
    let id: Int?
    let type, name, titleEn, titleAr: String?
    let contentEn, contentAr: String?

    enum CodingKeys: String, CodingKey {
        case id, type, name
        case titleEn = "title_en"
        case titleAr = "title_ar"
        case contentEn = "content_en"
        case contentAr = "content_ar"
    }
}
