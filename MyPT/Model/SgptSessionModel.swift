//
//  SgptSessionModel.swift
//  MyPT
//
//  Small Group PT (SGPT) upcoming-session model — `GET api/sgpt-upcoming`.
//  Field shape/decoding style mirrors `UpcomingClassModel` in
//  Model/UpcomingClassModel.swift: plain `Int?`/`String?` for fields the
//  backend always sends as their natural JSON type, `FlexibleValue` for
//  fields observed (on the Group Classes endpoints) to sometimes arrive as a
//  JSON string instead of a number.
//

import Foundation

// MARK: - SgptUpcomingBaseModel

struct SgptUpcomingBaseModel: Codable {
    var status: Bool?
    var data: [SgptSessionModel]?
}

// MARK: - SgptSessionModel

struct SgptSessionModel: Codable {
    var id: Int?
    var sessionName: String?
    var trainerName: String?
    var studioName: String?
    /// `yyyy-MM-dd`.
    var date: String?
    /// `HH:mm:ss`.
    var time: String?
    /// Full URL string, or `nil`.
    var image: String?
    // FlexibleValue: same rationale as UpcomingClassModel's bookedCount/
    // totalCapacity/remainingSeats/studioLat/studioLng - these are read via
    // the coercing GroupClassCardFormatter.intValue/doubleValue helpers
    // rather than trusted to always decode as a native JSON number.
    var duration: FlexibleValue?
    var maxSize: FlexibleValue?
    var bookedCount: FlexibleValue?
    var remainingSeats: FlexibleValue?
    var studioLat: FlexibleValue?
    var studioLng: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case id
        case sessionName = "session_name"
        case trainerName = "trainer_name"
        case studioName = "studio_name"
        case date, time, image, duration
        case maxSize = "max_size"
        case bookedCount = "booked_count"
        case remainingSeats = "remaining_seats"
        case studioLat = "studio_lat"
        case studioLng = "studio_lng"
    }
}
