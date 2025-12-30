//
//  ProfileVM.swift
//  MyPT
//
//  Created by techsaga corp on 12/06/25.
//

import Foundation

class ProfileVM {
        
    //MARK: ---------------------- api/user-profile
    class func getUserProfileApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:ProfileBaseModel?) -> Void){
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .user_profile, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(ProfileBaseModel.self, from: responceData)
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
    
    //MARK: ----------------------api/user-information
    class func getUserInformationApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:UserProfileBaseModel?) -> Void){
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .user_information, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(UserProfileBaseModel.self, from: responceData)
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
    
    //MARK: ------------------ api/update-information
    class  func updateInformationApi(inputparams: [String:Any]?, completion: @escaping(_ resultData: UpdateUserProfileBaseModel?) -> Void){
      
        /*
         let params:[String:Any] = [
             "name": "", //name is required
             "email": "", //email is required
             "gender": "", //male/female/others
             "location": "", //location is required
             "address": "",  //address is required
             "country_id": "", //static 231
             "city_id": "",  //city id is required
             "address_id": "", //optional
             "long": "", //location based
             "lat": "" ,//location based
             "profile": "", // for image
             "cover_image": "" //for cover image
         ]
        */
        
        print("inputParams = ", inputparams as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .update_information, method: .post , parameters: inputparams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(UpdateUserProfileBaseModel.self, from: responceData)
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
    
    //MARK: ------------------ api/update-information
    class  func updateProfileInfApi(inputparams: [String:String]?, imageParams: [String:Any], completion: @escaping(_ resultData: UpdateUserProfileBaseModel?) -> Void){
      
        /*
         let params:[String:Any] = [
         "name": "", //name is required
         "email": "", //email is required
         "gender": "", //male/female/others
         "location": "", //location is required
         "address": "",  //address is required
         "country_id": "", //static 231
         "city_id": "",  //city id is required
         "address_id": "", //optional
         "long": "", //location based
         "lat": "" ,//location based
     ]
         let imageParam:[String:Any] = [
         "profile": UIImage, // for image
         "cover_image": UIImage //for cover image
         ]
        */
        
        print("inputParams = ", inputparams as Any)
        NetworkManager.shared.uploadMedia(serviceEndPoint: .update_information, method: .post, queries: inputparams, isShowLoading: true, mediaPaths: [imageParams], completion: { (getResponce, error) in
            
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(UpdateUserProfileBaseModel.self, from: responceData)
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
    
    //MARK:  -------------------api/delete-user-profile-image?type
    class func deleteUserProfileImageApi(inputparams: [String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:[String:Any]?) -> Void){
        
//        let params:[String:Any] = [
//            "type","profile", profile/cover_image
//       ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .delete_user_profileImage, method: .get , queries: inputparams, parameters:  nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            
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
    
    //-------- api/user-health-stats
    class func healthStatsApi(inputType:String? , isShowLoader:Bool = true, completion: @escaping(_ resultData:HealthStatsBaseModel?) -> Void){
        /*
         type: 2, 1=>health ,2=>stats
         */
        
        let inputParams = [
            "type": inputType ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .user_health_stats, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(HealthStatsBaseModel.self, from: responceData)
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
    
    
    //MARK: ---------------------- api/user-trainer
    class func getUserTrainersApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:GetTrainerBaseModel?) -> Void){
        
        /*
      var params: [String:String]? = [
            "lat": "",
            "long":"",
            "type":"", // 1=>trainer al ,2=>following
            "is_filter":"", // if filter wise then 1
            "tag_id":"" // tag id is required if is_filter 1
        ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .user_trainer, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GetTrainerBaseModel.self, from: responceData)
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
}


