//
//  WorkoutDetailsModel.swift
//  MyPT
//
//  Created by techsaga corp on 13/08/25.
//

import Foundation

// MARK: ------- Workout details
struct WorkoutDetailBaseModel: Codable {
    var status: Bool?
    var data: WorkoutDetailDataModel?
    var msg: String?
}

// MARK: ----------- WorkoutDetailDataModel
struct WorkoutDetailDataModel: Codable {
    var id: FlexibleValue?
    var image, level, name: FlexibleValue?
    var percentage: FlexibleValue?
    var duration, timeInSeconds: FlexibleValue?
    var calories, exercisesCount: FlexibleValue?
    var isStarted, isExercisesCompleted: Bool?
    var sessionID: FlexibleValue?
    var exercises: [WorkoutExerciseModel]?
    var workoutVideo: String?
    var type: FlexibleValue?
    var rounds: FlexibleValue?
    
    enum CodingKeys: String, CodingKey {
        case id, image, level, name, percentage, duration
        case timeInSeconds = "time_in_seconds"
        case calories
        case exercisesCount = "exercises_count"
        case isStarted, isExercisesCompleted
        case sessionID = "session_id"
        case exercises, type, rounds
        case workoutVideo = "workout_video"
    }
}


// MARK: ----------------- WorkoutExerciseModel
struct WorkoutExerciseModel: Codable {
    var id: FlexibleValue?
    var image: FlexibleValue?
    var calories, workoutExerciseID: FlexibleValue?
    var name: FlexibleValue?
    var sets, reps: FlexibleValue?
    var isComplete: Bool?
    var type: FlexibleValue?
    var totalREST: FlexibleValue?
    var video: String?
    var setRound: FlexibleValue?
    var restDuration: FlexibleValue?
    
    

    enum CodingKeys: String, CodingKey {
        case id, image, calories
        case workoutExerciseID = "workout_exercise_id"
        case name, sets, reps, isComplete, type
        case totalREST = "totalRest"
        case video
        case setRound = "set_round"
        case restDuration = "rest_duration"
    }
}


// MARK: -------------------- CompleteWorkoutBaseModel
struct CompleteWorkoutBaseModel: Codable {
    var status: Bool?
    var data: CompleteWorkoutDataModel?
    var msg: String?
}

// MARK: ---------------- CompleteWorkoutDataModel
struct CompleteWorkoutDataModel: Codable {
    var sessionID: FlexibleValue?
    var status: FlexibleValue?
    var workoutData: WorkoutDataModel?
    var durationScore: FlexibleValue?
    var ptScore: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case status, workoutData
        case durationScore = "duration_score"
        case ptScore
    }
}

// MARK: - WorkoutData
struct WorkoutDataModel: Codable {
    var calories, heartZone, steps, minuteDuration: FlexibleValue?
    var secDuration, routine: FlexibleValue?
    var durationScore: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case calories
        case heartZone = "heart_zone"
        case steps
        case minuteDuration = "minute_duration"
        case secDuration = "sec_duration"
        case routine
        case durationScore = "duration_score"
    }
}

//MARK: -------------- WORKOUT SUMMARY
struct WorkoutSummarBaseModel: Codable {
    var success: Bool?
    var message: FlexibleValue?
    var data: WorkoutSummaryDataModel?
}

// MARK: - WorkoutSummaDataModel
struct WorkoutSummaryDataModel: Codable {
    var percentageCompleted, totalKcal: FlexibleValue?
    var scoreBlocks: [ScoreBlocksModel]?
    var summary: [SummaryModel]?

    enum CodingKeys: String, CodingKey {
        case percentageCompleted = "percentage_completed"
        case totalKcal = "total_kcal"
        case scoreBlocks = "score_blocks"
        case summary
    }
}

// MARK: ----------- SummaryModel
struct SummaryModel: Codable {
    var exerciseName, image: FlexibleValue?
    var reps, expectedReps, calories: FlexibleValue?
    var status: FlexibleValue?

    enum CodingKeys: String, CodingKey {
        case exerciseName = "exercise_name"
        case reps, image
        case expectedReps = "expected_reps"
        case calories, status
    }
}

struct ScoreBlocksModel: Codable {
    var date: FlexibleValue?
    var calories: FlexibleValue?
}
