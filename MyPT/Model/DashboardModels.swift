//
//  DashboardModels.swift
//  MyPT
//
//  Created by techsaga corp on 28/07/25.
//

import Foundation

struct UserPlanBaseModel: Codable {
    var status: Bool?
    var data: [PlanDetailsModel]?
    var msg:String?
}

struct PlanDetailsModel: Codable {
    var id: FlexibleValue?
    var name: FlexibleValue?
    var remaining_sessions: FlexibleValue?
    var validity_days: FlexibleValue?
    var remaining_days: FlexibleValue?
    var type: FlexibleValue?
    var sessions: FlexibleValue?
    var amount: FlexibleValue?
    var isUpgrade, is_sessions_out, show_expired_card: Bool?
    var isShow, is_expired, is_date_expired, is_membership: Bool?
    var renew_new: Bool?
    var msg: FlexibleValue?
    var end_date: FlexibleValue?
    var image, studio_name: String?
}


struct UpgradePlanBaseModel: Codable {
    var status: Bool?
    var data:UpgradePlanDetailsModel?
    var msg:String?
    let errors: TopupErrorModel?
}

struct UpgradePlanDetailsModel: Codable {
    var current_sessions: FlexibleValue?
    var max_sessions: FlexibleValue?
    var per_session_cost: FlexibleValue?
    var price: FlexibleValue?
    var previous_paid: FlexibleValue?
    var additional_payable: FlexibleValue?
    var tax_price: FlexibleValue?
    var main_price: FlexibleValue?
    var final_price: FlexibleValue?
    var totalDays: FlexibleValue?
}

struct TopupErrorModel: Codable{
    var days: FlexibleValue?
    var msg: FlexibleValue?
}


struct ReviewUpgradePackageBaseModel: Codable {
    var status: Bool?
    var data:ReviewUpgradePackageDetailModel?
    var msg:String?
}

struct ReviewUpgradePackageDetailModel: Codable {
    var currentPackage: FlexibleValue?
    var currentEndDate: FlexibleValue?
    var newPackageStart: FlexibleValue?
    var tax_price: FlexibleValue?
    var main_price: FlexibleValue?
    var newPackageEnd: FlexibleValue?
    var trainingPreference: FlexibleValue?
    var totalSessions: FlexibleValue?
    var validity: FlexibleValue?
    var price: FlexibleValue?
}


struct UpgradePlanPaymentBaseModel: Codable {
    var status: Bool?
    var data:UpgradePaymentDetailModel?
    var msg:String?
}


struct UpgradePaymentDetailModel: Codable {
    var package: FlexibleValue?
    var subscription_id: FlexibleValue?
    var start_date: FlexibleValue?
    var new_session: FlexibleValue?
    var new_end_date: FlexibleValue?
    var payment_status: FlexibleValue?
}
