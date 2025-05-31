//
//  BookingModel.swift
//  MyPT
//
//  Created by techsaga corp on 15/04/25.
//

import Foundation

//MARK: ---------------------- BookingBaseModel
struct BookingBaseModel: Codable {
    var status: Bool?
    var data: [BookingDataModel]?
    var msg: String?
    let errors: String? 
}

//MARK: ------------ BookingDataModel
struct BookingDataModel: Codable {
    var id: Int?
    var type, timing, trainer_image, selected_slot: String?
    var workoutFocus: [String]?
    var sessionType, duration, trainer, location, distance: String?
    var isReschedule, isTrainer: Bool?
    var msg: String?

    enum CodingKeys: String, CodingKey {
        case id, type, timing, trainer_image, selected_slot
        case workoutFocus = "workout_focus"
        case sessionType = "session_type"
        case duration, trainer, location, distance
        case isReschedule = "is_reschedule"
        case isTrainer
        case msg
    }
}

//MARK: --------------------------- BOOKING DETAILS FLOW

//MARK: - BookingDetailsBaseModel
struct BookingDetailsBaseModel: Codable {
    var status: Bool?
    var data: BookingDetailsDataModel?
    var msg: String?
}

//MARK: ------------- BookingDetailsDataModel
struct BookingDetailsDataModel: Codable {
    var rescheduledStatus, cancelRequest, is_declined, isAction: Bool?
    var msg, cancellationPolicyMsg, bookingType, bookedAt, cancelledAtBooking: String?
    var bookingDetail: BookingDetailModel?
    var trainerDetail: TrainerDetailModel?
    var cancellationDetail: CancellationDetailModel?
    

    enum CodingKeys: String, CodingKey {
        case rescheduledStatus = "rescheduled_status"
        case cancelRequest = "can_cancel_request"
        case is_declined, isAction
        case cancellationPolicyMsg
        case bookingType = "booking_type"
        case cancelledAtBooking = "cancelled_at"
        case bookedAt = "booked_at"
        case bookingDetail, trainerDetail, msg, cancellationDetail
    }
}


//MARK: ------------- BookingDetailModel
struct BookingDetailModel: Codable {
    var contact, price, location, trainingDate: String?
    var type: String?

    enum CodingKeys: String, CodingKey {
        case contact, price, location
        case trainingDate = "training_date"
        case type
    }
}

//MARK: --------------- TrainerDetailModel
struct TrainerDetailModel: Codable {
    var name, distance, location: String?
    var profile: String?
    var averageRating, noOfRating: String?
}

//MARK: --------------- Aancellation Detail MODEL
struct CancellationDetailModel: Codable {
    var cancelledOn: String?
    var reason: String?
    var refundAmount: String?
    
    enum CodingKeys: String, CodingKey {
        case cancelledOn = "cancelled_on"
        case reason
        case refundAmount = "refund_amount"
    }
}

//MARK: ------------------ TRAINER SLOTS
struct TrainerSlotsBaseModel: Codable {
    var status: Bool?
    var data: [AvailabilityStatusModel]?
    var msg: String?
}

