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

/// Custom decode instead of plain `Codable` synthesis: `status` is typed
/// `Bool?`, but if this endpoint ever sends it as `1`/`0` (as some of this
/// backend's other endpoints are known to for numeric-ish fields - see
/// `FlexibleValue`'s own rationale below) a strict `Bool` decode throws,
/// which - since `status`/`data` are decoded together in one synthesized
/// init - would silently discard an otherwise-valid `data` array too
/// (`sgptUpcomingApi` catches the throw and calls `completion(nil)`). Decode
/// `data` independently of `status`'s exact representation so a type quirk
/// on one field can't hide real sessions that did come back.
struct SgptUpcomingBaseModel: Codable {
    var status: Bool?
    var data: [SgptSessionModel]?

    enum CodingKeys: String, CodingKey {
        case status, data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let boolStatus = try? container.decodeIfPresent(Bool.self, forKey: .status) {
            status = boolStatus
        } else if let intStatus = try? container.decodeIfPresent(Int.self, forKey: .status) {
            status = intStatus != 0
        } else if let stringStatus = try? container.decodeIfPresent(String.self, forKey: .status) {
            status = ["true", "1"].contains(stringStatus.lowercased())
        } else {
            status = nil
        }
        data = try container.decodeIfPresent([SgptSessionModel].self, forKey: .data)
    }
}

// MARK: - SgptSessionModel

struct SgptSessionModel: Codable {
    // FlexibleValue, not Int: confirmed via on-device diagnostic that this
    // endpoint sends id as a formatted session code string ("SG3011"), not
    // a number - a plain Int decode throws on the very first real session,
    // which (since every field in this struct decodes together) discarded
    // the entire array and was why the SGPT carousel rendered empty on iOS
    // while Android's more lenient parsing showed the same sessions fine.
    var id: FlexibleValue?
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
    /// Whether the signed-in member already holds a seat on this session.
    var isBooked: Bool?

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
        case isBooked = "is_booked"
    }
}
