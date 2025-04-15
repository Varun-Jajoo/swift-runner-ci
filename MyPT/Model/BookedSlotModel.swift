//
//  BookedSlotModel.swift
//  MyPT
//
//  Created by techsaga corp on 26/03/25.
//

import Foundation

//MARK: ----------- BookedSlotBaseModel
struct BookedSlotBaseModel: Codable {
    var status: Bool?
    var data: BookedSlotData?
    var msg: String?
    let errors: [String: [String]]?
    
}

//MARK: --------- DataClass
struct BookedSlotData: Codable {
    var trainer: BookedTrainerModel?
    var date: SlotDateModel?
    var package: String?
    var qr: String?
    var timing, location: String?
}

//MARK: ---------- DateClass
struct SlotDateModel: Codable {
    var startDate, validTill: String?

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case validTill = "valid_till"
    }
}

//MARK: ----------- BookedTrainerModel
struct BookedTrainerModel: Codable {
    var id: Int?
    var name: String?
    var isVerified: Bool?
    var image: String?
    var tags: [String]?
}


//MARK: ----------- Booke MEMBERSHIP BaseModel
struct BookMembershipBaseModel: Codable {
    var status: Bool?
    var data: BookMembershipDataModel?
    var msg: String?
    let errors: [String: [String]]?
    
}


//MARK: --------- BookMembershipDataModel
struct BookMembershipDataModel: Codable {
    var studio: ValityStudioDetailModel?
    var startDate: String?
    var endDate: String?
    var package: String?
    var qr: String?
    var location: String?
    
    enum CodingKeys: String, CodingKey {
        case package, qr, location
        case startDate = "start_date"
        case endDate = "end_date"
        case studio
    }
}

