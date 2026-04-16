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
    var isPackage: Bool?
    var main_price: FlexibleValue?
    var tax_rate: FlexibleValue?
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

// MARK: - SlotsByTimeModel
struct SlotsByTimeModel: Codable {
    let status: Bool?
    let data: SlotsByTimeModelData?
    let msg: String?
}

// MARK: - SlotsByTimeModelData
struct SlotsByTimeModelData: Codable {
    let selectedSlot: SelectedSlot?
    let slots: [SelectedSlot]?
    let otherTrainers: [OtherTrainer]?

    enum CodingKeys: String, CodingKey {
        case selectedSlot = "selected_slot"
        case slots
        case otherTrainers = "other_trainers"
    }
}

// MARK: - OtherTrainer
struct OtherTrainer: Codable {
    var id: FlexibleValue?
    var name: String?
    var profile, distance, averageRating: String?
    var tags: [String]?
    var isSelected: Bool?

    enum CodingKeys: String, CodingKey {
        case id, isSelected
//        case trainerID = "trainer_id"
        case name, profile, tags, distance, averageRating
    }
}

// MARK: - SelectedSlot
struct SelectedSlot: Codable {
    var startTime, endTime: String?
    var status, name: String?
    var id: FlexibleValue?
    var isSelected: Bool?

    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case status, id, name, isSelected
    }
}

struct ReviewAssessmentBaseModel: Codable {
    var status: Bool?
    var data: ReviewAssessmentModel?
    var msg: String?
    let errors: [String: [String]]?
}

struct ReviewAssessmentModel: Codable {
    var date: String?
    var location_name: String?
    var timing: String?
    var trainer_name: String?
    var type: String?
}
