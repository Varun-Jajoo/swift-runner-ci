//
//  HomepageViewModel.swift
//  MyPT
//
//  Created by Pratham Gupta on 11/02/26.
//

import Foundation

// MARK: - HomePageModel
struct HomePageModel: Codable {
    let status: Bool?
    let data: [HomePageData]?
    let msg: String?
}

// MARK: - Datum
struct HomePageData: Codable {
    let id: Int?
    let key, name, description: String?
    let image: String?
    let order: Int?
}




// MARK: - GetStoriesModel
struct GetStoriesModel: Codable {
    let status: Bool?
    let data: GetStoriesData?
    let msg: String?
}

// MARK: - DataClass
struct GetStoriesData: Codable {
    let data: [Datum]?
    let pagination: Pagination?
}

// MARK: - Datum
struct Datum: Codable {
    let categoryID: Int?
    let categoryName: String?
    let categoryIcon, categoryImage: String?
    let categoryDescription: String?
    let categoryOrder: Int?
    let stories: [Story]?
    let storiesCount: Int?

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case categoryIcon = "category_icon"
        case categoryImage = "category_image"
        case categoryDescription = "category_description"
        case categoryOrder = "category_order"
        case stories
        case storiesCount = "stories_count"
    }
}

// MARK: - Story
struct Story: Codable {
    let id: Int?
    let title, type: String?
    let mediaPath: String?
    let thumbPath: String?
    let caption, ctaText: String?
    let ctaURL: String?
    let publishedAt, expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, type
        case mediaPath = "media_path"
        case thumbPath = "thumb_path"
        case caption
        case ctaText = "cta_text"
        case ctaURL = "cta_url"
        case publishedAt = "published_at"
        case expiresAt = "expires_at"
    }
}

// MARK: - Pagination
struct Pagination: Codable {
    let currentPage, lastPage, perPage, total: Int?
    let from, to: Int?
    let hasMorePages: Bool?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total, from, to
        case hasMorePages = "has_more_pages"
    }
}



// MARK: - SubscriptionSlotModel
struct SubscriptionSlotModel: Codable {
    let status: Bool?
    let data: SubscriptionSlotsData?
    let msg: String?
}

// MARK: - DataClass
struct SubscriptionSlotsData: Codable {
    let isGroup, is_remaining_session: Bool?
    let type: String?
    let availableTypes: [String]?
    let remainingSessions: Int?
    let group: SubscriptionSlotsGroup?
    let date, dateFormatted: String?
    let trainers: [SubscriptionSlotTrainer]?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case isGroup = "is_group"
        case type
        case availableTypes = "available_types"
        case remainingSessions = "remaining_sessions"
        case group, date
        case dateFormatted = "date_formatted"
        case trainers, message, is_remaining_session
    }
}

// MARK: - Group
struct SubscriptionSlotsGroup: Codable {
    let id: Int?
    let name, type: String?
    let image: String?
    let msg: String?
}

// MARK: - Trainer
struct SubscriptionSlotTrainer: Codable {
    let id: FlexibleValue?
    let name: String?
    let profile: String?
    let badge: String?
    let slots: [Slot]?
    let slotsCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, profile, badge, slots
        case slotsCount = "slots_count"
    }
}

// MARK: - Slot
struct Slot: Codable {
    var id: FlexibleValue?
    var isSelected: Bool?
    var time, startTime, endTime, time_display: String?

    enum CodingKeys: String, CodingKey {
        case id, time, isSelected
        case startTime = "start_time"
        case endTime = "end_time"
        case time_display = "time_display"
    }
}

// MARK: - AssesmentStatusModel
struct AssesmentStatusModel: Codable {
    let status: Bool?
    let data: AssesmentStatusData?
    let msg: String?
}

// MARK: - DataClass
struct AssesmentStatusData: Codable {
    let status, start_time, end_time, trainer_name, date: String?
    let is_upcoming, is_completed, can_book: Bool?
    let booking_id, assessment_id: FlexibleValue?
    let profile, type, address: String?
}
