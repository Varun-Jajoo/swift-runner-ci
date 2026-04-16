//
//  WorkoutLibraryVM.swift
//  MyPT
//
//  Created by techsaga corp on 11/07/25.
//

import Foundation

class WorkoutLibraryVM {
    
    //MARK: --------------------- workouts
    class func workoutsApi(params: [String:Any]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:WorkoutBaseModel?) -> Void){
        NetworkManager.shared.genericAPICall(serviceEndPoint: .workouts, method: .get , parameters: params,  isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(WorkoutBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //------------------- api/get-trainer-time
    class func trackTrainerTimeApi(inputBookingId:String? , isShowLoader:Bool = true, completion: @escaping(_ resultData:TrackTrainerBaseModel?) -> Void){
        
        let inputParams = [
            "booking_id": inputBookingId ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_trainer_time, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(TrackTrainerBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
//                        AlertHelper.shared.showCustomeAlert(title: "", message: getResult.errors ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: ------------------ api/make-favourite
    class  func makeFavouriteWorkoutApi(inputFeatureId: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData: [String:Any]?) -> Void){
      
         let params:[String:Any]? = [
            "featured_id" : inputFeatureId ?? ""
         ]
        
        print("inputParams = ", params as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .make_favourite, method: .post , parameters: params,  isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    print("getResult", getResult as Any)
                    guard let getResult = getResult else { return }
                    
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["message"] as? String ?? ""))"
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg, completion: nil)
                    }
                }
                
            }catch {
                print(error)
            }
        })
    }
    
    //------------------- api/workout-types
    class func workoutTypeApi(isShowLoader:Bool = true, completion: @escaping(_ resultData:WorkoutTypeBaseModel?) -> Void){
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .workout_types, method: .get , queries: nil, parameters:  nil,  isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(WorkoutTypeBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
//                        AlertHelper.shared.showCustomeAlert(title: "", message: getResult.errors ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
   
    //MARK: ------------------ api/get-workouts
    class  func getWorkoutApi(inputParams: [String:Any]?,  isShowLoader:Bool = true, completion: @escaping(_ resultData: GetWorkoutsBaseModel?) -> Void){
      
        /*
         let params:[String:Any]? = [
            "filter_by": "", //
            "type": "",//type:  1,2,3 workout type is required(comma seperated)
            "page": "", //for pagination
            "muscle_id": "", //body part
            "level": "",
            "calories": "",
            "duration": "", // 10=>min duration, 12=>max duration
            "per_page": "", // need of data count if 10/20/30
            "name": "" , //strenght (workout name filter)
         ]
        */
        
        print("inputParams = ", inputParams as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_workouts, method: .post , parameters: inputParams, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GetWorkoutsBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
//                        AlertHelper.shared.showCustomeAlert(title: "", message: getResult.errors ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: ------------------ api/get-exercises
    class  func getExercisesApi(params:[String:Any]?, completion: @escaping(_ resultData: GetExerciseBaseModel?) -> Void){
      
        /*
         let params:[String:Any]? = [
            "page" : inputPageNum ?? 1,
            "category_id": "", // 1,2,3
            "level": "" , //name
            "group_ids": "" //1,2,3 , group ids comma sepearted
         ]
        */
  
        print("inputParams = ", params as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_exercises, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GetExerciseBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //------------------- api/body-parts
    class func getBodyPartsApi(isShowLoader:Bool = true, completion: @escaping(_ resultData:BodyPartsBaseModel?) -> Void){
        NetworkManager.shared.genericAPICall(serviceEndPoint: .body_parts, method: .get , queries: nil, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(BodyPartsBaseModel.self, from: responceData)
                    if (getResult.success == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //------------------- api/wokout-detail
    class func workoutDetailsApi(inputId: String?, inputType: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData:WorkoutDetailBaseModel?) -> Void){
        
        let params: [String:String] = [
            "id": inputId ?? "",
            "type": inputType ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .wokout_detail, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(WorkoutDetailBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
        
    //MARK: ------------------ api/workout-start
    class  func workoutStartApi(inputId: Int?, assignmentId: String?, completion: @escaping(_ resultData: [String:Any]?) -> Void){
         let params:[String:Any]? = [
            "workout_id" : inputId ?? 0,
            "assignment_id" : assignmentId ?? " "
         ]
        print("start workout params: ", params as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .workout_start, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["message"] as? String ?? ""))"
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg, completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: ------------------ api/exercise-complete
    class  func exerciseCompleteApi(inputSessionId: String?, workoutExerciseId: String?, inputsetRound: String?, completion: @escaping(_ resultData: [String:Any]?) -> Void){
         let params:[String:Any]? = [
            "session_id" : inputSessionId ?? "",
            "workout_exercise_id": workoutExerciseId ?? "",
            "set_round": inputsetRound ?? ""
         ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .exercise_complete, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["message"] as? String ?? ""))"
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg, completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: ------------------ api/workout-complete
    class  func workoutCompleteApi(inputSessionId: String?, completion: @escaping(_ resultData: CompleteWorkoutBaseModel?) -> Void){
         let params:[String:Any]? = [
            "session_id" : inputSessionId ?? ""
         ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .workout_complete, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(CompleteWorkoutBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
                    }
                }
                
                /*
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["message"] as? String ?? ""))"
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg, completion: nil)
                    }
                }
                */
            }catch {
                print(error)
            }
        })
    }
    
    //------------------- api/get-workout-summary
    class func getWorkoutSummaryApi(inputSessionId: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData: WorkoutSummarBaseModel?) -> Void){
        
        let params: [String:String] = [
            "session_id": inputSessionId ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_workout_summary, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(WorkoutSummarBaseModel.self, from: responceData)
                    if (getResult.success == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //------------------- api/my-workouts
    class func myWorkoutsApi(inputDateStr: String?, inputStatus: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData: MyworkoutsBaseModel?) -> Void){
        let params: [String:String] = [
            "date": inputDateStr ?? "", //date=2025-08-21
            "status": inputStatus ?? ""
        ]
        NetworkManager.shared.genericAPICall(serviceEndPoint: .my_workouts, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(MyworkoutsBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //------------------- api/get-user-streak
    class func getUserStreakApi(isShowLoader:Bool = true, completion: @escaping(_ resultData: UserDayStreakBaseModel?) -> Void){
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_user_streak, method: .get , queries: nil, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(UserDayStreakBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //------------------- api/trainer/remindworkouttime
    class func remindWorkoutTimeApi(isShowLoader:Bool = true, completion: @escaping(_ resultData:RemindWorkoutTimeBaseModel?) -> Void){
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .trainer_remindworkouttime, method: .get , queries: nil, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(RemindWorkoutTimeBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
//                        AlertHelper.shared.showCustomeAlert(title: "", message: getResult.errors ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //---------
    //MARK: ------------------ api/createworkout
    class  func createWorkoutApi(inputWorkout: RegularWorkoutModel?, completion: @escaping(_ resultData: [String:Any]?) -> Void){
 
        var params = [String: Any]()
        params["id"] = inputWorkout?.id
        params["name"] = inputWorkout?.name
        params["description"] = inputWorkout?.description
        params["type"] = inputWorkout?.type
        params["category_id"] = inputWorkout?.category_id
        params["repeat_duration"] = inputWorkout?.repeat_duration
        params["repeat_days"] = inputWorkout?.repeat_days
        params["start_date"] = inputWorkout?.start_date
        params["end_date"] = inputWorkout?.end_date
        params["time"] = inputWorkout?.time
        params["remind_me"] = inputWorkout?.remind_me
        params["client_id"] = inputWorkout?.client_id
        params["rest_status"] = inputWorkout?.rest_status
        params["sets_round"] = inputWorkout?.sets_round
        
        // Convert exercises array to dictionary array
        if let exercises = inputWorkout?.exercises {
            let exerciseDicts = exercises.map { exercise -> [String: Any] in
                var dict = [String: Any]()
                dict["id"] = exercise.id
                dict["type"] = exercise.type
                dict["sets"] = exercise.sets
                dict["reps"] = exercise.reps
                dict["rest_duration"] = exercise.rest_duration
                dict["time_type"] = exercise.time_type
                return dict
            }
            params["exercises"] = exerciseDicts
        }
        
        print("params: ", params)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .createworkout, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["message"] as? String ?? ""))"
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg, completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    
    //MARK: ------------------ api/createworkout(Superset workout)
    class  func createSupersetWorkoutApi(inputWorkout: SupersetWorkoutModel?, isShowLoading: Bool? = true, completion: @escaping(_ resultData: CreateSupersetGourpBaseModel?) -> Void){
        
        //MARK: ------------Make params
            var params = [String: Any]()
        params["id"] = inputWorkout?.id?.value
        params["name"] = inputWorkout?.name?.value
        params["description"] = inputWorkout?.description?.value
        params["type"] = inputWorkout?.type?.value
        params["category_id"] = inputWorkout?.categoryID?.value
        params["repeat_duration"] = inputWorkout?.repeatDuration?.value
        params["repeat_days"] = inputWorkout?.repeatDays?.value
        params["start_date"] = inputWorkout?.startDate?.value
        params["end_date"] = inputWorkout?.endDate?.value
        params["time"] = inputWorkout?.time?.value
        params["remind_me"] = inputWorkout?.remindMe?.value
        params["is_set_new"] = inputWorkout?.isSetNew
        
        if let supersets = inputWorkout?.supersets {
            let supersetDicts = supersets.map { superset -> [String: Any] in
                var dict = [String: Any]()
                dict["type"] = superset.type?.value ?? ""
                dict["duration"] = superset.duration?.value ?? ""
                
                if let exercises = superset.exercises {
                    dict["exercises"] = exercises.map { exercise -> [String: Any] in
                        return [
                            "id": exercise.id?.value ?? "",
                            "type": exercise.type?.value ?? "",
                            "sets": exercise.sets?.value ?? "",
                            "reps": exercise.reps?.value ?? "",
                            "time_type": exercise.timeType?.value ?? ""
                        ]
                    }
                }
                
                return dict
            }
            params["supersets"] = supersetDicts
        }
        print("params: ", params)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .createworkout, method: .post , parameters: params, isShowLoading: isShowLoading ?? true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(CreateSupersetGourpBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
//                        completion(getResult)                        
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: --------------------- set-edit-workout
    class func setEditWorkoutsApi(inputWorkoutId: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData:SupersetBaseModel?) -> Void){
        let params: [String:String] = [
            "workout_id": inputWorkoutId ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .set_edit_workout, method: .get , queries: params, parameters: nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SupersetBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg?.value
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
   
    //MARK: --------------------- api/workout-delete
    class func workoutDeleteApi(inputId: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData: [String:Any]?) -> Void){
        let params: [String:String] = [
            "id": inputId ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .workout_delete, method: .get , queries: params, parameters: nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["message"] as? String ?? ""))"
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg, completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    
    //MARK: ------------------ edit-workout-exercise
    class  func editWorkoutExerciseApi(inputParams: [String:Any]?, completion: @escaping(_ resultData: CreateSupersetGourpBaseModel?) -> Void){
        
        /*
         //MARK: ------------Make params
         var params = [String: Any]()
         params["id"] = "", //workout id
         params["exercise_id"] = "", //exercise_id
         params["reps"] = "", //reps
         params["sets"] = "", //sets
         params["rest"] = "", //rest in seconds
         params["note"] = "", //note
         params["sets_position"] = "", //0, if editing superset exercise
         
         print("params: ", params)
         */
        
        print("params: ", inputParams as Any)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .edit_workout_exercise, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(CreateSupersetGourpBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
//                        AlertHelper.shared.showCustomeAlert(title: "", message: getResult.errors ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    
    //MARK: --------------------- api/delete-workout-exercise
    class func deleteWorkoutExerciseApi(inputWorkoutExerciseId: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData: [String:Any]?) -> Void){
        let params: [String:String] = [
            "workout_exercise_id": inputWorkoutExerciseId ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .delete_workout_exercise, method: .get , queries: params, parameters: nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
//                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["msg"] as? String ?? ""))"
                        
                        let errorMsg = (getResult["errors"] as? [String: Any])?["msg"] as? String ?? ""
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg, completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
}
