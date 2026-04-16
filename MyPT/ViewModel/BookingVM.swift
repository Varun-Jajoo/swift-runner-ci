//
//  BookingVM.swift
//  MyPT
//
//  Created by techsaga corp on 15/04/25.
//

import Foundation

class  BookingVM {
    
    //MARK: -----------------------api/get-booking
    class func getBookingApi(inputType: String?, inputDate: String?, inputSessionType: String?, inputLocation: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData:BookingBaseModel?) -> Void){
        
         let params:[String:String] = [
            "type": inputType ?? ""               //type: 0, 1 => completed, 2 => upcoming, 0 => cancel
//            "session_type": inputSessionType ?? ""  //session_type : home , gym
//            "location": inputLocation ?? "",         //location: home ,gym
//            "date": inputDate ?? ""                  //date: 2025-05
         ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_booking, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(BookingBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        completion(getResult)
//                        AlertHelper.shared.showCustomeAlert(title: "", message: getResult.errors ?? "", completion: nil)
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
                        
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["msg"] as? String ?? ""))"
                        
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg, completion: nil)
                    }
                }
                */
            }catch {
                print(error)
            }
        })
    }
    
    
    //MARK: ----------------------- api/booking-detail
    class func bookingDetailsApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:BookingDetailsBaseModel?) -> Void){
        
        /*
         let params:[String:String] = [
            "id": "", //id: 4
            "long": "", // long:12.67788, required if type is gym
            "lat": "" //lat: 13.887989, required if type is gym
         ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .booking_detail, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(BookingDetailsBaseModel.self, from: responceData)
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
    
    
    //MARK: ------------------ api/accept-reject
    class  func acceptRejectBookingApi(inputParams: [String:Any]?, completion: @escaping(_ resultData: [String:Any]?) -> Void){
        
        /*
         let params:[String:Any] = [
         "id": "", //id:1 , session id is required
         "type": "" // type:2 , 1=>accept , 2=>cancel
         ]
         */
        
        print("inputParams = ", inputParams as Any)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .accept_reject_Booking, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["msg"] as? String ?? ""))"
                        
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg, completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: ------------------ api/get-trainerslot (for calendar date availabily)
   
    class func trainerSlotApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:TrainerSlotsBaseModel?) -> Void){
        
        /*
         let params:[String:String] = [
            "id": "", //id:1 , booking id
            "month": "", // month:04 , month
         ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_trainerSlot, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(TrainerSlotsBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
//                        completion(getResult)
                        AlertHelper.shared.showCustomeAlert(title: "", message: getResult.msg ?? "" ,completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: ------------------ api/get-allslots (for  date availabily)
    
    class func allSlotsRescheduleApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:SlotsBaseModel?) -> Void){
        
        /*
         let params:[String:String] = [
            "id": "", //id: 1, booking id
            "timing": "", //timing: morning, morning/night
            "date": "" //date: 2025-04-12, date is required
         ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_allslots_Reschedule, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SlotsBaseModel.self, from: responceData)
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
    
    //MARK: ---------------------- api/reschedule-session
    class  func rescheduleSessionConsumerApi(inputParams: [String:Any]?, completion: @escaping(_ resultData: [String:Any]?) -> Void){
        
        /*
         let params:[String:Any] = [
         "id": "", //id:1 ,  booking id main id
         "new_slot_id": "" , //new_slot_id:2 , new slot id
         "reason": "" // reason field is required
         ]
         */
        
        print("inputParams = ", inputParams as Any)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .reschedule_session_Consumer, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    
                    if (getResult["success"] as? Bool) == true  {
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
    

    //MARK: ---------------------- api/cancel-request
    class  func cancelRequstConsumerRescheduleApi(inputId: String?, completion: @escaping(_ resultData: [String:Any]?) -> Void){
        
         let params:[String:Any] = [
            "id": inputId ?? "", //id:1 ,  booking id
         ]
        
        print("inputParams = ", params as Any)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .cancel_request, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
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
    
    //MARK: ---------------------- api/cancel-session
    class  func cancelSessionUpcomingApi(inputParams: [String:Any]?, completion: @escaping(_ resultData: BookingDetailsBaseModel?) -> Void){
        /*
         let params:[String:Any] = [
            "id": inputId ?? "", //id:1 ,  booking id
            "reason": ""         //reason field is required
         ]
        */
        
        print("inputParams = ", inputParams as Any)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .cancel_session, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(BookingDetailsBaseModel.self, from: responceData)
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
    
    /*
     {
       "status": true,
       "data": [],
       "msg": "Session already accepted or no reschedule found."
     }
     */
    
    /*
       class func getBookingApii(inputType: String?,
                                isShowLoader: Bool = true,
                                onError: ((String) -> Void)? = nil,
                                completion: @escaping (_ resultData: [String: Any]?) -> Void) {
           
           let params: [String: String] = [
               "type": inputType ?? ""
           ]
           
           NetworkManager.shared.genericAPICall(
               serviceEndPoint: .get_booking,
               method: .get,
               queries: params,
               parameters: nil,
               isShowLoading: isShowLoader
           ) { (responseData, error) in
               do {
                   if let data = responseData {
                       let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                       guard let result = json else {
                           onError?("Invalid server response.")
                           return
                       }

                       if (result["status"] as? Bool) == true {
                           completion(result)
                       } else {
                           let errorMsg = "\(((result["errors"] as? [String: Any])?.values.first as? [Any])?.first as? String ?? (result["msg"] as? String ?? "Something went wrong."))"
                           onError?(errorMsg)
                       }
                   } else if let error = error {
                       onError?(error.localizedDescription)
                   }
               } catch {
                   onError?("Parsing error: \(error.localizedDescription)")
               }
           }
       }
    */
    
}
