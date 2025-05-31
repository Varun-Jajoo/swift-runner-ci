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
}
