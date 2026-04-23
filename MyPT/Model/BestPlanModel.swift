//
//  BestPlanModel.swift
//  MyPT
//
//  Created by Radha on 29/01/26.
//

import Foundation

struct BestPlanModel: Codable {
    let status: Bool?
    let data: [BestPlanData]?
    let msg: String?
}

// MARK: - Datum
struct BestPlanData: Codable {
    let id, title, sessions, price: String?
    let currency, pricePerSession, validityDays, validityMonths: String?
    let periodType, validityText: String?
    let backgroundImage: String?
    let badgeText: String?
    let features: [String]?

    enum CodingKeys: String, CodingKey {
        case id, title, sessions, price, currency
        case pricePerSession = "price_per_session"
        case validityDays = "validity_days"
        case validityMonths = "validity_months"
        case periodType = "period_type"
        case validityText = "validity_text"
        case backgroundImage = "background_image"
        case badgeText = "badge_text"
        case features
    }
}


struct CustomisePlanModel: Codable {
    let status: Bool?
    let data: CustoomiseData?
    let msg: String?
}

// MARK: - CustoomiseData
struct CustoomiseData: Codable {
    let totalPrice: Int?
    let pricePerSession: FlexibleValue?
    let save_price: String?
    let validity: String?
    let totalDays: Int?
    let details: Details?
}

// MARK: - Details
struct Details: Codable {
    let packageType: Int?
    let sessions: String?

    enum CodingKeys: String, CodingKey {
        case packageType = "package_type"
        case sessions
    }
}
