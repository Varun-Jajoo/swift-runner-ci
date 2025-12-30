//
//  WorkoutLibraryModel.swift
//  MyPT
//
//  Created by techsaga corp on 11/07/25.
//

import Foundation

// MARK: ---------------- TrackTrainerBaseModel
struct TrackTrainerBaseModel: Codable {
    var status: Bool?
    var data: TrackTrainerDataModel?
    var msg: String?
}

// MARK: --------------- TrackTrainerDataModel
struct TrackTrainerDataModel: Codable {
    var trainer: TrackTrainerModel?
    var booking: TrackBookingModel?
}

// MARK: -------------- TrackBookingModel
struct TrackBookingModel: Codable {
    var address: String?
    var otp: Int?
    var arrivingTime: String?
}

// MARK: ----------------- TrackTrainerModel
struct TrackTrainerModel: Codable {
    var name, location: String?
    var profile: String?
    var tags: [String]?
}


// MARK: ---------------- TrackTrainerBaseModel
struct RemindWorkoutTimeBaseModel: Codable {
    var status: Bool?
    var data: [RemindWorkoutDataModel]?
    var msg: FlexibleValue?
}

struct RemindWorkoutDataModel: Codable {
    var id: FlexibleValue?
    var remind_time: FlexibleValue?
    var time: FlexibleValue?
}

//MARK: -------------CREATE WORKOUT MODEL FOR REGULAR/CIRCUIT
struct RegularWorkoutModel: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var type: String?
    var category_id: Int?
    var repeat_duration: Int?
    var repeat_days: String?
    var start_date: String?     // e.g. "2025-07-28"
    var end_date: String?     // e.g. "2025-07-28"
    var time: String?           // e.g. "06:00 PM"
    var remind_me: String?   // time id for remind
    var client_id: String?
    var rest_status: Bool? // if status true rest
    var sets_round: String?
    // var image: String?       // Uncomment if you need to send image URL
    var exercises: [ExerciseModel]?
}

struct ExerciseModel: Codable {
    var id: Int?
    var type: String?           // "exercise" or "rest"
    var sets: Int?
    var reps: Int?
    var rest_duration: Int?
    // var note: String?        // Uncomment if needed
    var time_type: Int?
}

// MARK: ---------------------FOR API SupersetWorkoutModel
struct SupersetBaseModel: Codable {
    let status: Bool?
    let data: SupersetWorkoutModelAPI?
    let msg: FlexibleValue?
}

// MARK: --------------------- FOR API SupersetWorkoutModel
struct SupersetWorkoutModelAPI: Codable {
    let workoutId: FlexibleValue?
    let name, description, type: FlexibleValue?
    let isSetNew: Bool?
    let categoryID, repeatDuration: FlexibleValue?
    let repeatDays, startDate, endDate, time: FlexibleValue?
    let remindMe, calories, totalExercise, time_in_seconds, time_in_minutes: FlexibleValue?
    var client_id, rest_status, sets_round: FlexibleValue?
    let supersets: [SupersetModelAPI]?
    var exercises: [ExercisesDatailsModel]?
    
    enum CodingKeys: String, CodingKey {
        case workoutId = "workout_id"
        case name, description, type
        case categoryID = "category_id"
        case repeatDuration = "repeat_duration"
        case repeatDays = "repeat_days"
        case startDate = "start_date"
        case endDate = "end_date"
        case time
        case remindMe = "remind_me"
        case isSetNew = "is_set_new"
        case supersets, exercises
        case calories
        case totalExercise = "total_exercise"
        case time_in_seconds, time_in_minutes
        case client_id, rest_status, sets_round
    }
}



// MARK: --------------- SupersetModelAPI
struct SupersetModelAPI: Codable {
    var type: FlexibleValue?
    var sets_position: FlexibleValue?
    var exercises: [ExercisesDatailsModel]?
    var duration: FlexibleValue?
}



// MARK: --------------------- FOR CREATE SupersetWorkoutModel
struct SupersetWorkoutModel: Codable {
    let id: FlexibleValue?
    let name, description, type: FlexibleValue?
    let isSetNew: Bool?
    let categoryID, repeatDuration: FlexibleValue?
    let repeatDays, startDate, endDate, time: FlexibleValue?
    let remindMe: FlexibleValue?
    let supersets: [SupersetModel]?
    
    //clientID
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, type
        case categoryID = "category_id"
        case repeatDuration = "repeat_duration"
        case repeatDays = "repeat_days"
        case startDate = "start_date"
        case endDate = "end_date"
        case time
        case remindMe = "remind_me"
        case isSetNew = "is_set_new"
        case supersets
    }
}

// MARK: --------------- SupersetModel
struct SupersetModel: Codable {
    let type: FlexibleValue?
    let exercises: [SupersetExerciseModel]?
    let duration: FlexibleValue?
}

// MARK: --------------- SupersetExerciseModel
struct SupersetExerciseModel: Codable {
    let id: FlexibleValue?
    let type: FlexibleValue?
    let sets, reps, timeType: FlexibleValue?
    
    enum CodingKeys: String, CodingKey {
        case id, type, sets, reps
        case timeType = "time_type"
    }
}

//MARK: ----------------- WHEN CREATE SUPERSET GROUP
struct CreateSupersetGourpBaseModel: Codable {
    let status: Bool?
    let msg: String?
    let data: SupersetGourpDataModel?
    var errors: [String: [String]]?
}

struct SupersetGourpDataModel: Codable {
    var client_id: FlexibleValue?
    var workout_id: FlexibleValue?
}

/*
 {
     "status": true,
     "data": {
         "workout_id": 754,
         "name": "test super",
         "type": "superset",
         "time_in_seconds": "240",
         "time_in_minutes": "4",
         "calories": 350,
         "total_exercise": 2,
         "start_date": "2025/09/11",
         "end_date": "2025/09/11",
         "time": "04:07 PM",
         "repeat_days": "2,5",
         "repeat_duration": 2,
         "remind_me": "1",
         "supersets": [
             {
                 "type": "superset",
                 "sets_position": 0,
                 "exercises": [
                     {
                         "id": 508,
                         "category": "bicycle",
                         "name": "Speed Step",
                         "image": "https://mobileappuat.mypt-me.com/storage//tmp/phpyrtsrj",
                         "calories": 150,
                         "type": "exercise",
                         "sets": 4,
                         "reps": 12,
                         "duration": 30,
                         "rest_duration": 0,
                         "time_type": 2,
                         "note": "",
                         "position": 0,
                         "sets_position": 0,
                         "workout_exercise_id": 5437
                     },
                     {
                         "id": 507,
                         "category": "bicycle",
                         "name": "CardioBurner",
                         "image": "",
                         "calories": 200,
                         "type": "exercise",
                         "sets": 4,
                         "reps": 12,
                         "duration": 30,
                         "rest_duration": 0,
                         "time_type": 2,
                         "note": "",
                         "position": 1,
                         "sets_position": 0,
                         "workout_exercise_id": 5438
                     }
                 ]
             }
         ]
     },
     "msg": "Data fetched successfully"
 }
 */

/*
 curl --location 'http://mypt.test/api/createworkout' \
 --data '{
   "id": "",
   "name": "Back Strength Workout",
   "description": "A powerful workout focusing on back muscles and posture.",
   "type": "superset",
   "category_id": 1,
   "repeat_duration": 2,
   "repeat_days": "1,2",
   "start_date": "2025-07-30",
   "end_date": "2025-08-15",
   "time": "06:00 PM",
   "remind_me": "1",
   "supersets": [
     {
       "type": "superset",
       "exercises": [
         {
           "id": 1,
           "type": "exercise",
           "sets": 3,
           "reps": 12,
           "time_type": 2
         },
         {
           "id": 2,
           "type": "exercise",
           "sets": 2,
           "reps": 15,
           "time_type": 2
         }
       ]
     },
     {
       "type": "rest",
       "duration": 60
     },
     {
       "type": "superset",
       "exercises": [
         {
           "id": 3,
           "type": "exercise",
           "sets": 4,
           "reps": 10,
           "time_type": 2
         }
       ]
     },
     {
       "type": "rest",
       "duration": 90
     }
   ]
 }'
 */
