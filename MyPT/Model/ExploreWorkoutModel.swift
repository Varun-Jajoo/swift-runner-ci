//
//  ExploreWorkoutModel.swift
//  MyPT
//
//  Created by techsaga corp on 11/02/25.
//

import Foundation

// MARK: - Base Model
struct WorkoutBaseModel: Codable {
    var status: Bool?
    var data: DataModel?
    var msg: String?
}

// MARK: --------- DataModel
struct DataModel: Codable {
    var categories: [CategoryModel]?
    var featured: [FeaturedModel]?
    var myworkouts, challanges: [FlexibleValue]? //it's not clear model
    
    //    init(from decoder: Decoder) throws {
    //        let container = try decoder.container(keyedBy: CodingKeys.self)
    //        myworkouts = try container.decodeIfPresent(FlexibleValue.self, forKey: .myworkouts)
    //        challanges = try container.decodeIfPresent(FlexibleValue.self, forKey: .challanges)
    //
    //        // Handle `data` as both an array and a dictionary
    //        if let dataDictionary = try? container.decode(CategoryModel.self, forKey: .categories) {
    //            categories = dataDictionary
    //        }else if let dataArray = try container.decodeIfPresent([CategoryModel].self, forKey: .categories), let firstElement = dataArray.first {
    //            categories = firstElement
    //        }else{
    //            categories = nil
    //        }
    //        if let dataDictionary = try? container.decode(FeaturedModel.self, forKey: .featured) {
    //            featured = dataDictionary
    //        }else if let dataArray = try container.decodeIfPresent([FeaturedModel].self, forKey: .categories), let firstElement = dataArray.first {
    //            featured = firstElement
    //        }else{
    //            featured = nil
    //        }
    //    }
}

// MARK: -------- CategoryModel
struct CategoryModel: Codable {
    var name: FlexibleValue?
    var image: FlexibleValue?
    var id: FlexibleValue?
}


// MARK: --------- FeaturedModel
struct FeaturedModel: Codable {
    var id: FlexibleValue?
    var title: FlexibleValue?
    var category: FlexibleValue?
    var image: FlexibleValue?
    var status: FlexibleValue?
    var level: String?
    var duration: String?
    var isFavourite: Bool?
    var description, createdAt, updatedAt: FlexibleValue?
    var calories: FlexibleValue?
    var seriesName: FlexibleValue?
    
    enum CodingKeys: String, CodingKey {
        case id, title, image, status, description, level, duration, category
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case calories
        case seriesName = "series_name"
        case isFavourite
    }
}


// MARK: ------------ GetWorkoutsBaseModel
struct GetWorkoutsBaseModel: Codable {
    var status: Bool?
    var data: GetWorkoutsDataModel?
    var msg: String?
}

// MARK: - GetWorkoutsDataModel
struct GetWorkoutsDataModel: Codable {
    var workouts: [GetWorkoutsModel]?
    var meta: MetaModel?
}

// MARK: -------- GetWorkoutsModel
struct GetWorkoutsModel: Codable {
    var id: FlexibleValue?
    var name: String?
    var image: String?
    var type: String?
    var category_name: String?
    var exercises: FlexibleValue?
    var time: String?
    var isFeatured: Bool?
}


// MARK: ------------ MetaModel
struct MetaModel: Codable {
    var currentPage, lastPage, total, perPage: FlexibleValue?
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case total
        case perPage = "per_page"
    }
}


// MARK: ------------ WorkoutTypeBaseModel
struct WorkoutTypeBaseModel: Codable {
    var status: Bool?
    var data: WorkoutTypeDataModel?  //[WorkoutAllcategoryModel]?
    var msg: String?
}

// MARK: --------- WorkoutTypeDataModel
struct WorkoutTypeDataModel: Codable {
    var allcategory: [WorkoutAllcategoryModel]?
    var workoutLevels: [WorkoutLevelModel]?
    var filters: [WorkoutLevelModel]?
    
}

// MARK: -------- WorkoutAllcategoryModel
struct WorkoutAllcategoryModel: Codable {
    var id: FlexibleValue?
    var name: FlexibleValue?
    var icon, image: FlexibleValue?
}

// MARK: --------- WorkoutLevel
struct WorkoutLevelModel: Codable {
    var id: FlexibleValue?
    var name: String?
}

/*
 {"status": true,
     "data": {
         
         "data": [
             {
                 "id": 508,
                 "name": "SpeedStep",
                 "raps": 12,
                 "category": "bicycle",
                 "image": "https://img.youtube.com/vi/uNN62f55EV0/0.jpg",
                 "calories": 150,
                 "video_type": "youtube",
                 "video_path": "https://www.youtube.com/watch?v=uNN62f55EV0"
             },
             {
                 "id": 507,
                 "name": "CardioBurner",
                 "raps": 12,
                 "category": "bicycle",
                 "image": "https://mobileappuat.mypt-me.com/storage",
                 "calories": 200,
                 "video_type": "custom",
                 "video_path": "https://mobileappuat.mypt-me.com/storage/exercise/video/1754556278_SampleVideo_1280x720_5mb.mp4"
             },
             {
                 "id": 504,
                 "name": "12345",
                 "raps": 12,
                 "category": "bicycle",
                 "image": "https://img.youtube.com/vi/D0UnqGm_miA/0.jpg",
                 "calories": 123,
                 "video_type": "youtube",
                 "video_path": "https://www.youtube.com/watch?v=D0UnqGm_miA"
             },
             {
                 "id": 503,
                 "name": "Autem perspiciatis aut veritatis.",
                 "raps": 12,
                 "category": "sed",
                 "image": "https://img.youtube.com/vi/QtNyYLPDEJX/0.jpg",
                 "calories": 0,
                 "video_type": "youtube",
                 "video_path": "https://www.youtube.com/watch?v=QtNyYLPDEJX"
             },
             {
                 "id": 502,
                 "name": "Aut non fugit doloribus.",
                 "raps": 12,
                 "category": "dolorum",
                 "image": "https://img.youtube.com/vi/8H3Pqh4drgx/0.jpg",
                 "calories": 0,
                 "video_type": "youtube",
                 "video_path": "https://www.youtube.com/watch?v=8H3Pqh4drgx"
             },
             {
                 "id": 501,
                 "name": "Cupiditate quo qui.",
                 "raps": 12,
                 "category": "Yoga",
                 "image": "https://mobileappuat.mypt-me.com/assets/images/icon.webp",
                 "calories": 0,
                 "video_type": "mp4",
                 "video_path": "https://mobileappuat.mypt-me.com/storage/https://www.youtube.com/watch?v=iK3ILVFsLih"
             },
             {
                 "id": 500,
                 "name": "Quam sapiente consequuntur.",
                 "raps": 12,
                 "category": "sed",
                 "image": "https://mobileappuat.mypt-me.com/assets/images/icon.webp",
                 "calories": 0,
                 "video_type": "mp4",
                 "video_path": "https://mobileappuat.mypt-me.com/storage/https://www.youtube.com/watch?v=qakMI0NvpMA"
             },
             {
                 "id": 499,
                 "name": "Ea eligendi odio.",
                 "raps": 12,
                 "category": "dolorum",
                 "image": "https://mobileappuat.mypt-me.com/assets/images/icon.webp",
                 "calories": 0,
                 "video_type": "mp4",
                 "video_path": "https://mobileappuat.mypt-me.com/storage/https://www.youtube.com/watch?v=ERWGKMpm5up"
             },
             {
                 "id": 498,
                 "name": "Repellendus dolore ea harum.",
                 "raps": 12,
                 "category": "bicycle",
                 "image": "https://img.youtube.com/vi/SY8cpcuNLVk/0.jpg",
                 "calories": 0,
                 "video_type": "youtube",
                 "video_path": "https://www.youtube.com/watch?v=SY8cpcuNLVk"
             },
             {
                 "id": 497,
                 "name": "Et voluptatem iusto eos.",
                 "raps": 12,
                 "category": "sed",
                 "image": "https://img.youtube.com/vi/zALUYJ5GaN3/0.jpg",
                 "calories": 0,
                 "video_type": "youtube",
                 "video_path": "https://www.youtube.com/watch?v=zALUYJ5GaN3"
             }
         ],
         
 }
 */

// MARK: ------------ GetExerciseBaseModel
struct GetExerciseBaseModel: Codable {
    var status: Bool?
    var data: GetExerciseDataModel?
    var msg: FlexibleValue?
}

// MARK: --------------- GetExerciseDataModel
struct GetExerciseDataModel: Codable {
    var currentPage: FlexibleValue?
    var exercisesData: [ExercisesDatailsModel]?
    var firstPageURL: FlexibleValue?
    var from, lastPage: FlexibleValue?
    var lastPageURL: FlexibleValue?
    var links: [ExercisesLinkModel]?
    var nextPageURL, path: FlexibleValue?
    var perPage: FlexibleValue?
    var prevPageURL: FlexibleValue?
    var to, total: FlexibleValue?
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case exercisesData = "data"
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case links
        case nextPageURL = "next_page_url"
        case path
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
        case to, total
    }
}

// MARK: --------------- ExerciseDatailsModel
struct ExercisesDatailsModel: Codable {
    var id: FlexibleValue?
    var name, category, image: FlexibleValue?
    var calories: FlexibleValue?
    var type, localRest: FlexibleValue?
    var sets, reps, raps: FlexibleValue?
    var videoType: FlexibleValue?
    var videoPath: FlexibleValue?
    var timeType, restDuration, workout_exercise_id, duration, note, position, sets_position: FlexibleValue?
    var isSupersetDeleted: Bool?
    

    enum CodingKeys: String, CodingKey {
        case id, name, category, image, calories, type, localRest, sets
//        case reps = "raps"
        case reps , raps
        case videoType = "video_type"
        case videoPath = "video_path"
        case timeType = "time_type"
        case restDuration = "rest_duration"
        case workout_exercise_id, duration, note, position, sets_position
        case isSupersetDeleted
    }
}



/*
struct GetCircuitExcercise: Codable {
    let id: Int?
    var category, name, image: String?
    let calories: Int?
    let type: String?
    let sets, reps: Int?
    var timeType, restDuration, workout_exercise_id, duration: Int?
 
    enum CodingKeys: String, CodingKey {
        case id, category, name, calories, type, sets, reps, image
        case timeType = "time_type"
        case restDuration = "rest_duration"
        case workout_exercise_id, duration
    }
}
*/
 


// MARK: --------------- ExercisesLinkModel
struct ExercisesLinkModel: Codable {
    var url: FlexibleValue?
    var label: FlexibleValue?
    var active: Bool?
}


// MARK: ------------ BodyPartsBaseModel
struct BodyPartsBaseModel: Codable {
    var success: Bool?
    var data: [WorkoutAllcategoryModel]?
    var msg: String?
}

// MARK: ------------ MyworkoutsBaseModel
struct MyworkoutsBaseModel: Codable {
    var status: Bool?
    var data: [MyWorkoutsDataModel]?
    var msg: String?
}

struct MyWorkoutsDataModel: Codable {
    var id: FlexibleValue?
    var category: FlexibleValue?
    var pt_score: FlexibleValue?
    var assigned_id: FlexibleValue?
    var title: FlexibleValue?
    var exercise_count: FlexibleValue?
    var totalDuration: FlexibleValue?
    var time: FlexibleValue?
    var type: FlexibleValue?
    var isStarted: Bool?
    var isCompleted: Bool?
    var percentage: FlexibleValue?
    var session_id: FlexibleValue?
    var date: FlexibleValue?
    var previewImage: FlexibleValue?
    var displayDate: String? //extra for check selected date
    
}


// MARK: ----------- user day streak model
struct UserDayStreakBaseModel: Codable {
    var status: Bool?
    var data: UserDayStreakDataModel?
    var msg: String?
}

// MARK: -------------- userDayStreakDataBaseModel
struct UserDayStreakDataModel: Codable {
    var currentStreak, longestStreak, weekNumber: FlexibleValue?
    var weekDays: [WeekDayModel]?
    var message: FlexibleValue?
    
    enum CodingKeys: String, CodingKey {
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
        case weekDays = "week_days"
        case message
        case weekNumber = "week_number"
    }
}

// MARK: ---------------- WeekDayModel
struct WeekDayModel: Codable {
    var day, date, status: FlexibleValue?
    var completed, is_started, is_upcoming, is_missed: Bool?
}
