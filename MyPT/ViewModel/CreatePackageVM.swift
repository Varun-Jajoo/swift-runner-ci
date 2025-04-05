//
//  CreatePackageVM.swift
//  MyPT
//
//  Created by techsaga corp on 29/03/25.
//

import UIKit

class CreatePackageVM{
    
    //MARK: -----------------------Create package for One buddy / With buddy
    
    /*
     package_type: 1, 1=>one-on-one,2=>buddy,3=>group
     sessions: 13, no of sessions,initally remains 1
     type: gym, home=>if selected from home, gym=>selected from gym
     trainer_id: 1, trainer id is required
     studio_id: 5, studio id is required if type is gym
     month: 3, month
     address_id: 1, Address id is required if type is home
     */
    
    class func createPackageApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:CreatePackageBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        
        /*
         let params:[String:String] = [
         "package_type": "",
         "sessions": "",
         "type": "",
         "trainer_id": "",
         "studio_id": "",
         "month": "",
         "address_id": ""
         ]
         */
        
        let params:[String:String] = inputParms
        print("token: ", appUserDefaults.getAccessToken() ?? "")
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .package_create_one_buddy, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(CreatePackageBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                    
                    //                    if let jsonResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String: Any] {
                    //                        print(jsonResult)
                    //                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    
    //MARK: ------------------ api/package-setdate
    /*
     package_type: 1
     sessions: 13
     type: gym
     trainer_id: 1
     studio_id: 5
     date: 2025-03-15 , start Date
     end_date: 2025-04-02, End date
     timing: morning
     address_id: 1, address id is required if type is home
     */
    
    class  func packageSetDateApi(viewController: UIViewController, inputParams: [String:Any]?, completion: @escaping(_ resultData:SetDateBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "package_type": "",
         "sessions": "" ,
         "type": "",
         "trainer_id": "",
         "studio_id": "",
         "date": "",
         "end_date": "",
         "timing": "",
         "address_id": "",
         ]
         */
        
        print("inputParams = ", inputParams as Any)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .package_setdate, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(SetDateBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
                
            }catch {
                print(error)
            }
            
        })
    }
    
    
    //MARK: ------------------ api/package-checkout
    //http://mypt.test/api/package-checkout
    /*
     package_type: 1, package type is required 1,2,3
     sessions: 13, no of session , at least one is required
     type: gym,  home or gym
     trainer_id: 1, trainer id is required
     studio_id: 5, studio id is required if type is gym
     date: 2025-03-29, start date
     end_date: 2025-04-02, end date
     address_id: 1, address id is required if type is home
     slot_id: 18, slot id is required
     */
    
    class  func packageCheckoutApi(viewController: UIViewController, inputParams: [String:Any]?, completion: @escaping(_ resultData:PackageCheckoutBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "package_type": "",
         "sessions": "" ,
         "type": "",
         "trainer_id": "",
         "studio_id": "",
         "date": "",
         "end_date": "",
         "address_id": "",
         "slot_id": ""
         ]
         */
        
        print("inputParams = ", inputParams as Any)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .package_checkout, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(PackageCheckoutBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
                
            }catch {
                print(error)
            }
            
        })
    }
    
    
    //MARK: --------------------------- VALIDATION FOR ADD MEMBER
    
    class func isValidMember(inputParams: AddMemberParams?) -> Bool {
        guard let inputParams = inputParams else { return  false}
        if let name_member =  inputParams.name, name_member.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.valid_user_name,actions: ["Ok"])
            return false
        } else if let age_member =  inputParams.age, age_member.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.valid_age,actions: ["Ok"])
            return false
        } else if let gender_member =  inputParams.gender, gender_member.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.select_gender,actions: ["Ok"])
            return false
        }
        return true
    }
    
    //MARK:------------------- "api/package-group"
    /*
     package_type: 3, this will always remains
     type: gym, gym=>select from studio, home=>direct home
     trainer_id: 1, trainer id is required
     studio_id: 1, studio id required if type is gym
     */
    
    class func getMemberPackagegroupApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:MemberBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        
        /*
         let params:[String:String] = [
         "package_type": "",
         "type": "",
         "trainer_id": "",
         "studio_id": ""
         ]
         */
        
        let params:[String:String] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_maember_package_group, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(MemberBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg //(getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    
    //MARK: ------------------ api/add-member
    //http://mypt.test/api/add-member
    /*
     name: jojos, name field is required
     age: 22, age is required
     gender: male, gender field is required=>male,female,others
     id: 1, if edit then id is required else not required meanwhile when want to add new member then id wiil be nil
     */
    
    class  func addMemberApi(viewController: UIViewController, inputParams: [String:Any]?, completion: @escaping(_ resultData: AddMemberBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "name": "",
         "age": "" ,
         "gender": "",
         "id": ""
         ]
         */
        
        print("inputParams = ", inputParams as Any)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_member, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(AddMemberBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
                
            }catch {
                print(error)
            }
            
        })
    }
    
    //MARK: --------------------- api/delete-member
    
    class func deleteMemberApi(viewController: UIViewController, inputId: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData:[String:Any]?) -> Void){
        
        let params:[String:String] = [
            "id": inputId ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .delete_member, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["msg"] as? String ?? ""))"
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg)
                    }
                }
                
            }catch {
                print(error)
            }
        })
    }
    
    
    
    //MARK: --------------------api/trainer-follow
    /*
     id:2, trainer id is required
     */
    
    class  func trainerFollowApi(viewController: UIViewController, inputId: String?, completion: @escaping(_ resultData:[String:Any]?) -> Void){
        
         let params:[String:Any] = [
            "id": inputId ?? ""
         ]
         
        print("params = ", params as Any)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .trainer_follow, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
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
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg)
                    }
                }
                
            }catch {
                print(error)
            }
            
        })
    }
    
}
