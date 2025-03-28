//
//  AvailabilityCalendarModel.swift
//  MyPT
//
//  Created by techsaga corp on 24/03/25.
//

import Foundation

//MARK: ----------------------- CalendarAvailabilityModel
struct CalendarAvailabilityBaseModel: Codable {
    var status: Bool?
    var data: [AvailabilityStatusModel]?
    var msg: String?
    let errors: [String: [String]]?
}

//MARK: --------------- AvailabilityBaseModel
struct SlotsBaseModel: Codable {
    var status: Bool?
    var data: AvailabilityDataModel?
    var msg: String?
    let errors: [String: [String]]?
}

//MARK: --------- AvailabilityDataModel
struct AvailabilityDataModel: Codable {
    var availabilityStatus: [AvailabilityStatusModel]?
    var date: String?
    var slots: [SlotModel]?
    var price: String?
    var infomation: InfomationModel?
}

//MARK: -------- AvailabilityStatusModel
struct AvailabilityStatusModel: Codable {
    var date: String?
    var status: String?
}

//MARK: ---- InfomationModel
struct InfomationModel: Codable {
    var type, trainerID: String?

    enum CodingKeys: String, CodingKey {
        case type
        case trainerID = "trainer_id"
    }
}

//MARK: ----------- SlotModel
struct SlotModel: Codable {
    var id: Int?
    var isBooked: Bool?
    var time: String?
}

