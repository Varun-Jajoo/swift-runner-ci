//
//  NewBookingModel.swift
//  MyPT
//
//  Created by Manik Goel on 28/06/26.
//

import Foundation

struct NewBookingParmsModel {
    var type, group_id, date: String?
    var dates: [String]?
    var trainer_id: String?
    var studio_id: String?
    var address_id, preferred_time: String?
    var lat, long: String?
    var slot_ids: [String]?
    
    func getParams() -> [String: Any] {
          var dict: [String: Any] = [:]

          if let type = type { dict["type"] = type }
          if let group_id = group_id { dict["group_id"] = group_id }
          if let date = date { dict["date"] = date }
          if let dates = dates { dict["dates"] = dates }
          if let trainer_id = trainer_id { dict["trainer_id"] = trainer_id }
          if let preferred_time = preferred_time { dict["preferred_time"] = preferred_time }
          if let studio_id = studio_id { dict["studio_id"] = studio_id }
          if let address_id = address_id { dict["address_id"] = address_id }
          if let lat = lat { dict["lat"] = lat }
          if let long = long { dict["long"] = long }
          if let slot_ids = slot_ids { dict["slot_ids"] = slot_ids }
          return dict
      }
}

// MARK: - NewBookingSlots
struct NewBookingSlots: Codable {
    let status: Bool?
    let data: NewBookingSlotsData?
    let msg: String?
}

struct NewBookingSlotsData: Codable {
    let determined_type: String?
    let trainers: [TrainersData]?
    let has_group: Bool?
    let trainers_count, total_session, total_available: Int?
    let group: GroupData?
}

struct TrainersData: Codable {
    var id: FlexibleValue?
    var name: String?
    var image, badge: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name, image, badge
    }
}

struct GroupData: Codable {
    var id: FlexibleValue?
    var name, type: String?
    var image, description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name, image, description, type
    }
}

// MARK: - GetSlotesModel
struct GetSlotesModel: Codable {
    let status: Bool?
    var data: GetSlotesModelData?
    let msg: String?
}

// MARK: - GetSlotesModelData
struct GetSlotesModelData: Codable {
    var secondaryTrainers: [PrimaryTrainer]?
    let preferredTimeFormatted, preferredTime, date, date_formatted: String?
    var primaryTrainer: PrimaryTrainer?
    let isGroup: Bool?
//    let group: JSONNull?
    let dates: [DateElement]?
    let totalAvailableSlots: Int?
    let total_session: Int?

    enum CodingKeys: String, CodingKey {
        case secondaryTrainers = "secondary_trainers"
        case preferredTimeFormatted = "preferred_time_formatted"
        case preferredTime = "preferred_time"
        case primaryTrainer = "primary_trainer"
        case isGroup = "is_group"
//        case group
        case dates, total_session, date, date_formatted
        case totalAvailableSlots = "total_available_slots"
    }
}

// MARK: - DateElement
struct DateElement: Codable {
    let hasAlternatives, isPrimaryAvailable: Bool?
//    let alternativeTrainers, alternativeSlots: [JSONAny]?
    let date, dateFormatted, trainerName: String?
    let slots: [Slot]?
    let trainerID, slotsCount: Int?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case hasAlternatives = "has_alternatives"
        case isPrimaryAvailable = "is_primary_available"
//        case alternativeTrainers = "alternative_trainers"
//        case alternativeSlots = "alternative_slots"
        case date
        case dateFormatted = "date_formatted"
        case trainerName = "trainer_name"
        case slots
        case trainerID = "trainer_id"
        case slotsCount = "slots_count"
        case message
    }
}

// MARK: - PrimaryTrainer
struct PrimaryTrainer: Codable {
    var id, slots_count: Int?
    var name: String?
    var image: String?
    var badge: String?
    var slots: [Slot]?
}

// MARK: - ReviewNewBookingModel
struct ReviewNewBookingModel: Codable {
    let status: Bool?
    let data: ReviewNewBookingData?
    let msg: String?
}

struct ReviewNewBookingData: Codable {
    let sessions_used, sessions_remaining, booking_timeout_minutes: Int?
    let training_location: TrainingLocation?
    let trainers: [TrainersSlotData]?
    let is_group: Bool?
    let trainers_count: Int?
    let sessions_display: String?
}

struct TrainingLocation: Codable {
    var type, address, area, lat, long: String?
    var address_id, id: Int?

    enum CodingKeys: String, CodingKey {
        case type, address, area, lat, long
        case address_id, id
    }
}

struct TrainersSlotData: Codable {
    var badge, image, trainer_name: String?
    var grouped_slots: [GroupedSlots]?
    var slots_count, trainer_id: Int?
    var slots: [TrainerSlots]?

    enum CodingKeys: String, CodingKey {
        case badge, image, trainer_name
        case grouped_slots
        case slots_count, trainer_id
    }
}

struct GroupedSlots: Codable {
    var slot_ids: [Int]?
    var count: Int?
    var date_display, time, time_display: String?

    enum CodingKeys: String, CodingKey {
        case slot_ids, count, date_display, time, time_display
    }
}

struct TrainerSlots: Codable {
    var slot_id: Int?
    var date, date_raw, time_display: String?
    var date_full, time: String?

    enum CodingKeys: String, CodingKey {
        case slot_id, date, date_raw, time_display
        case date_full, time
    }
}
