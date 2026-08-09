//
//  UpcomingClassVM.swift
//  MyPT
//
//  Created by techsaga corp on 14/05/25.
//

import Foundation


class UpcomingClassVM {
    //MARK: ----------------------- api/upcoming-classes
    class func upcomingClassesApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:UpcomingClassesBaseModel?) -> Void){
        /*
         let params:[String:String] = [
            "long": "", // long:12.67788, required if type is gym
            "lat": "" //lat: 13.887989, required if type is gym
         ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .upcoming_classes, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(UpcomingClassesBaseModel.self, from: responceData)
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
    
    //MARK: ----------------------- api/get-resources
    class func getResourcesApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:ResourcesBaseModel?) -> Void){
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_resources, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(ResourcesBaseModel.self, from: responceData)
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
    
    //MARK: ----------------------- api/class-detail
    class func classDetailsApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:ClassDetailsBaseModel?) -> Void){
        /*
         let params:[String:String] = [
            "long": "", // long:12.67788, required if type is gym
            "lat": "" //lat: 13.887989, required if type is gym
            "schdule_id": "" //
         ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .class_detail, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(ClassDetailsBaseModel.self, from: responceData)
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
    
    //MARK: ----------------------- api/viewall-classes
    class func viewAllClassesApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:ViewAllClassBaseModel?) -> Void){
        /*
         let params:[String:String] = [
            "long": "", // long:12.67788, required if type is gym
            "lat": "", //lat: 13.887989, required if type is gym
            "is_filter": " ", // is_filter = 0 , when all workout otherwise  is_filter = 1
            "category_id": "" // category_id  is needed when want data categorywise when all workout no need category
         ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .viewall_classes, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(ViewAllClassBaseModel.self, from: responceData)
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
 
    //MARK: ----------------------- api/class-category
    class func categoryWiseClassesApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:CategoryWiseClassesBaseModel?) -> Void){
        /*
         let params:[String:String] = [
            "long": "", // long:12.67788, required if type is gym
            "lat": "", //lat: 13.887989, required if type is gym
            "category_id": "" //category_id  is needed when want data categorywise when all workout no need category
         ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .class_category, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(CategoryWiseClassesBaseModel.self, from: responceData)
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
    
    //MARK: ------------------ api/book-class
    class  func bookingClassApi(inputScheduleId: String?, completion: @escaping(_ resultData: BookClassBaseModel?) -> Void){
      
         let params:[String:Any] = [
            "schedule_id": inputScheduleId ?? "", //schedule_id id is required
         ]
         
        print("inputParams = ", params as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .book_class, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(BookClassBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }

    //MARK: ------------------ api/book-class  (Group Classes booking flow)
    /*
     Android reference: GroupTrainingDetailActivity.kt lines 545-603 (free path) —
     PostMethod(ApiURL.bookclass, {schedule_id, transaction_id, payment_type}).

     Deliberately NOT the same as `bookingClassApi` above:
     - it sends the full `schedule_id` / `transaction_id` / `payment_type` trio, and
     - it forwards EVERY decoded response to the caller (including `status == false`)
       instead of swallowing failures into an alert, because the group-class flow has
       to inspect a failed response for the blacklist/pause payload before deciding
       where to navigate. See `BookClassBaseModel` in Model/BookedSlotModel.swift.

     Caveat inherited from `NetworkManager.genericAPICall`: its completion only fires
     on a 2xx (or with `nil` when there is no internet). A non-2xx never calls back,
     so callers must not rely on this closure for teardown that has to happen on any
     outcome.
     */
    class func bookGroupClassApi(scheduleId: String?,
                                 transactionId: String = "",
                                 paymentType: String = "free",
                                 isShowLoader: Bool = true,
                                 completion: @escaping(_ resultData: BookClassBaseModel?) -> Void){

        let params:[String:Any] = [
            "schedule_id": scheduleId ?? "",
            "transaction_id": transactionId,
            "payment_type": paymentType
        ]

        print("inputParams = ", params as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .book_class, method: .post , parameters: params, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(BookClassBaseModel.self, from: responceData)
                completion(getResult)
            }catch {
                print(error)
                completion(nil)
            }
        })
    }

    //MARK: ----------------------- api/join-waitlist
    /// Port of `GroupTrainingDetailActivity.joinWaitlistDirectly`'s param trio —
    /// note `price`, not `payment_type` (joining a waitlist isn't a payment).
    /// Reuses `BookClassBaseModel`: the response shape (status/msg/code/
    /// is_blacklisted/data) is identical to `book-class`.
    class func joinWaitlistApi(scheduleId: String?,
                               transactionId: String = "",
                               price: String = "",
                               isShowLoader: Bool = true,
                               completion: @escaping(_ resultData: BookClassBaseModel?) -> Void){

        let params:[String:Any] = [
            "schedule_id": scheduleId ?? "",
            "transaction_id": transactionId,
            "price": price
        ]

        print("inputParams = ", params as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .join_waitlist, method: .post , parameters: params, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(BookClassBaseModel.self, from: responceData)
                completion(getResult)
            }catch {
                print(error)
                completion(nil)
            }
        })
    }


    //MARK: ----------------------- api/claim-open-spot
    /// Called by both a waitlisted member (tapped the "spot opened up" push)
    /// and a brand-new user browsing a class with an open spot - everyone
    /// gets an equal shot, the backend serializes the race with a row lock
    /// (`GroupClassService::claimOpenSpot`). Same response envelope as
    /// join-waitlist/book-class: `status:false, code:"SPOT_TAKEN"` means
    /// someone else won and this user is now on the waitlist instead.
    class func claimOpenSpotApi(scheduleId: String?,
                                isShowLoader: Bool = true,
                                completion: @escaping(_ resultData: BookClassBaseModel?) -> Void){

        let params: [String: Any] = [
            "schedule_id": scheduleId ?? ""
        ]

        print("inputParams = ", params as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .claim_open_spot, method: .post, parameters: params, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                print(getResponce as Any)
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(BookClassBaseModel.self, from: responceData)
                completion(getResult)
            } catch {
                print(error)
                completion(nil)
            }
        })
    }

    //MARK: ----------------------- api/waitlist-open-slots-count
    /// Count of this member's active waitlist entries whose class currently
    /// has an open spot - used to decide whether to fire a local "N spots
    /// opened up" notification the next time the app backgrounds right
    /// after a booking/waitlist-join. Android: `ApiURL.waitlistOpenSlotsCount`.
    class func waitlistOpenSlotsCountApi(isShowLoader: Bool = false,
                                         completion: @escaping(_ emptySlots: Int) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .waitlist_open_slots_count, method: .get, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            guard let responceData = getResponce,
                  let json = try? JSONSerialization.jsonObject(with: responceData) as? [String: Any],
                  json["status"] as? Bool == true,
                  let data = json["data"] as? [String: Any] else {
                completion(0)
                return
            }
            completion(data["empty_slots"] as? Int ?? 0)
        })
    }

    //MARK: ----------------------- api/user-meals
    class func getuserMealsApi(inputDate:String? , isShowLoader:Bool = true, completion: @escaping(_ resultData:UserMealsBaseModel?) -> Void){
        /*
         date: 2025-05-22
         */
        
        let params:[String:String] = [
           "date": inputDate ?? "",
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .user_meals, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(UserMealsBaseModel.self, from: responceData)
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
    
    //MARK: ------------------ api/meal-favourite
    class  func mealFavoriteApi(inputMealId: String?, completion: @escaping(_ resultData:[String:Any]?) -> Void){
        
         let params:[String:Any] = [
            "meal_id": inputMealId ?? "", //meal_id id is required
         ]
         
        print("inputParams = ", params as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .meal_favourite, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            
            do{

                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["msg"] as? String ?? ""))"
                        debugPrint(errorMsg)
                    }
                }
                
            }catch {
                print(error)
            }

            
//            do{
//                print(getResponce as Any)
//                if let responceData = getResponce {
//                    let getResult = try JSONDecoder().decode(BookClassBaseModel.self, from: responceData)
//                    if (getResult.status == true)  {
//                        completion(getResult)
//                    }
//                    else{
//                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
//                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
//                    }
//                }
//            }catch {
//                print(error)
//            }
        })
    }
}
