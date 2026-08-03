//
//  UpcomingClassModel.swift
//  MyPT
//
//  Created by techsaga corp on 14/05/25.
//

import Foundation

struct UpcomingClassesBaseModel: Codable {
    var status: Bool?
    var data: UpcomingDataModel?
    var msg: String?
}

struct ResourcesBaseModel: Codable {
    var status: Bool?
    var data: [ResourceModel]?
}

// MARK: - UpcomingDataModel
struct UpcomingDataModel: Codable {
    var classesWithCategory: [ClassesWithCategoryModel]?
    var allClasses: [UpcomingClassModel]?
    var allClassVideos: [String]?
    var resources: [ResourceModel]?
}

// MARK: ---------- UpcomingClassModel
struct UpcomingClassModel: Codable {
    var classID: Int?
    var className, allClassClass: String?
    /// Secondary title key. Android reads `json.optString("name")` and falls back
    /// `class` -> `name` -> "Group Training" when painting a class card, so the key
    /// has to be decoded here for the two platforms to render the same title.
    var name: String?
    var scheduleID, categoryID: Int?
    var image: String?
    var status, location, type, studioName: String?
    var time, start_end: String?
    var price: FlexibleValue?
    var trainedBy: String?
    var trainerImage: String?
    var access: String?
    var isMember: Bool?
    // FlexibleValue: backend types are inconsistent (Android reads these with the coercing
    // optInt/optDouble accessors). Read via `.intValue` / `.doubleValue` / `.value`.
    var bookedCount, totalCapacity, remainingSeats: FlexibleValue?
    var distance: String?
    var studioLat, studioLng: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case classID = "class_id"
        case className = "class"
        case name
        case scheduleID = "schedule_id"
        case categoryID = "category_id"
        case image, status, location, type
        case studioName = "studio_name"
        case time, price, start_end
        case trainedBy = "trained_by"
        case trainerImage = "trainer_image"
        case access, distance
        case isMember = "is_member"
        case bookedCount = "booked_count"
        case totalCapacity = "total_capacity"
        case remainingSeats = "remaining_seats"
        case studioLat = "studio_lat"
        case studioLng = "studio_lng"
    }
}


// MARK: - ClassesWithCategory
struct ClassesWithCategoryModel: Codable {
    var categoryID: Int?
    var categoryName: String?
    var categoryImage: String?
    var classCount: String?

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case categoryImage = "category_image"
        case classCount
    }
}

// MARK: - ResourceModel
struct ResourceModel: Codable {
    var id: String? //extra adde
    var image: String?
    var title: String?
    var description:String?
    var date: String?
    var rating: Int?
    var isSaved: Bool?
    var totalSaved: Int?
    var totalView, readingTime: String?

    enum CodingKeys: String, CodingKey {
        case id, image, title, rating, description, date
        case isSaved = "is_saved"
        case totalSaved = "total_saved"
        case totalView = "total_view"
        case readingTime = "reading_time"
    }
}

 // MARK: ----------- ViewAllClassBaseModel
 struct ViewAllClassBaseModel: Codable {
     let status: Bool?
     let data: DataClassModel?
     let msg: String?
 }

 // MARK: ---------- DataClassModel
 struct DataClassModel: Codable {
     let classesWithCategory: [ClassesWithCategoryModel]?
     let allClasses: [UpcomingClassModel]?
     let allcategories: [AllcategoryModel]?
 }

 // MARK: ---------- AllcategoryModel
 struct AllcategoryModel: Codable {
     let id: Int?
     let name: String?
     let icon, image: String?
 }

struct CategoryWiseClassesBaseModel: Codable {
    var status: Bool?
    var data: [UpcomingClassModel]?
    var msg: String?
}


// MARK: ------------ UserMealsBaseModel
struct UserMealsBaseModel: Codable {
    var status: Bool?
    var data: [UserMealsDataModel]?
    var msg: String?
}

// MARK: - UserMealsDataModel
struct UserMealsDataModel: Codable {
    var id: FlexibleValue?
    var mealName, mealType: String?
    var calories, proteins: FlexibleValue?
    var isSaved: Bool?
    var carbs, fats: FlexibleValue?
    var mealTime, fitnessGoal: String?

    enum CodingKeys: String, CodingKey {
        case id
        case mealName = "meal_name"
        case mealType = "meal_type"
        case calories, proteins
        case isSaved = "is_saved"
        case carbs, fats
        case mealTime = "meal_time"
        case fitnessGoal = "fitness_goal"
    }
}
