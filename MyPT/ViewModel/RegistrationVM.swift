//
//  RegistrationVM.swift
//  MyPT
//
//  Created by techsaga corp on 27/01/25.
//

import UIKit

class RegistrationVM {
    
    //MARK: ------------VALIDATION
    class func isValidePhone(phoneNumStr:String?) -> Bool {
        
        if let userPhoneStr =  phoneNumStr, userPhoneStr.isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.enter_phone,actions: ["Ok"])
         return false
        }
        
        return true
//        if let userPhoneStr =  phoneNumStr, !userPhoneStr.isValidPhone(phone: userPhoneStr) || userPhoneStr.isEmpty{
//            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.enter_phone,actions: ["Ok"])
//         return false
//        }
//        return true
    }
    
    //MARK: --------------------- Login
    class  func loginApi(inputEmail: String?, inputPhoneNum:String?,inputCountryCode:String?, loginType: String?, completion: @escaping(_ resultData:LoginBaseModel?) -> Void){
//        guard let inputPhoneNum = inputPhoneNum, let inputCountryCode = inputCountryCode, let inputType = loginType else { return }
        
        let params:[String:Any] = [
            "country_code":inputCountryCode ?? "",
            "phone":inputPhoneNum ?? "",
            "type": loginType ?? "",
            "email": inputEmail ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .login, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(LoginBaseModel.self, from: responceData)
                    completion(getResult)
                }
            }catch {
                print(error)
            }
            
        })
    }
    
    //MARK: --------------------- Resend Otp
    class  func resendOtpApi(inputEmail: String?, inputPhoneNum:String?, inputCountryCode:String?, loginType: String?, completion: @escaping(_ resultData:LoginBaseModel?) -> Void){
//        guard let inputPhoneNum = inputPhoneNum, let inputCountryCode = inputCountryCode else { return }
        
        let params:[String:Any] = [
            "country_code":inputCountryCode ?? "",
            "phone":inputPhoneNum ?? "",
            "email": inputEmail ?? "",
            "type": loginType ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .resend_Otp, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(LoginBaseModel.self, from: responceData)
                    completion(getResult)
                }
            }catch {
                print(error)
            }
            
        })
    }
 
    //MARK: --------------------- Resend Otp
    class  func submitOtpApi(inputEmail: String?, inputPhoneNum:String?,inputCountryCode:String?, loginType: String?, otpStr: String?, completion: @escaping(_ resultData:SubmitOtpBaseModel?) -> Void){
//        guard let inputPhoneNum = inputPhoneNum, let inputCountryCode = inputCountryCode, let otpStr = otpStr, let loginType = loginType else { return }
        
        let params:[String:Any] = [
            "phone":inputPhoneNum ?? "",
            "country_code":inputCountryCode ?? "",
            "otp": otpStr ?? "",
            "type": loginType ?? "",
            "email": inputEmail ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .submit_Otp, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            print(getResponce as Any)
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SubmitOtpBaseModel.self, from: responceData)
                    completion(getResult)
                }
            }catch {
                print(error)
            }
            
        })
    }
    
    //MARK: --------------------- Check steps
    class func checkStep(viewController: UIViewController,params: [String:Any]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:[String:Any]?) -> Void){
        NetworkManager.shared.genericAPICall(serviceEndPoint: .check_Step, method: .get , parameters: params, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        print(getResult["msg"] as? String ?? "")
                        
//                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: getResult["msg"] as? String ?? "")
                    }
                }
            }catch {
                print(error)
            }
            
        })
    }
    
    //MARK: --------------------- Login
    class  func addNameApi(viewController: UIViewController, inputName:String?, inputId:String?, completion: @escaping(_ resultData:SubmitOtpBaseModel?) -> Void){
        guard let inputName = inputName, let inputId = inputId else { return }
        
        let params:[String:Any] = [
            "id": inputId,
            "name":inputName
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_name, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SubmitOtpBaseModel.self, from: responceData)
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
    
    //MARK: --------------------- get-prefrences
    class  func getPrefrencesApi(viewController: UIViewController, completion: @escaping(_ resultData:PersonalizedBaseModel?) -> Void){
       
        let params:[String:Any]? = nil
       
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_prefrences, method: .get , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            print(getResponce as Any)
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(PersonalizedBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
            }catch {
                print(error)
            }
            
        })
    }
    
    //MARK: ---------------------add/prefrence?
    class  func addPersonalizedApi(viewController: UIViewController, inputIds:String?, completion: @escaping(_ resultData:SubmitOtpBaseModel?) -> Void){
        guard let inputIds = inputIds else { return }
        /*
         ids: 1,2
         */
        let params:[String:Any] = [
            "ids": inputIds
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_prefrence, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SubmitOtpBaseModel.self, from: responceData)
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
    
    //MARK: ---------------------add/gender
    class  func addGenderApi(viewController: UIViewController, inputGender:String?, completion: @escaping(_ resultData:SubmitOtpBaseModel?) -> Void){
        guard let getInputGender = inputGender else { return }
        /*
         "gender": "male"
         */
        let params:[String:Any] = [
            "gender": getInputGender
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_gender, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SubmitOtpBaseModel.self, from: responceData)
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
    
    //MARK: ---------------------add/dob
    class  func addDobApi(viewController: UIViewController, inputDob:String?, completion: @escaping(_ resultData:SubmitOtpBaseModel?) -> Void){
        guard let getInputDob = inputDob else { return }
        /*
         "dob": "2025-12-28"
         "yyyy-mm-dd"
         */
        
        let params:[String:Any] = [
            "dob": getInputDob
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_dob, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SubmitOtpBaseModel.self, from: responceData)
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
    
    //MARK: ---------------------add/weight
    class  func addWeightApi(viewController: UIViewController, inputWeight:String?, completion: @escaping(_ resultData: WeightBaseModel?) -> Void){
        guard let inputWeight = inputWeight else { return }
        /*
         "weight": "22", 12lbs, 12lbs or 23kg (lbs automatic convert into kg)
         */
        
        let params:[String:Any] = [
            "weight": inputWeight
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_weight, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(WeightBaseModel.self, from: responceData)
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
    
    //MARK: ------------------ add/height
    class  func addheightApi(viewController: UIViewController, inputHeight:String?, completion: @escaping(_ resultData: WeightBaseModel?) -> Void){
        guard let inputHeight = inputHeight else { return }
        /*
         "height": "5"
         */
        
        /*
         
         5ft12

         5ft12=>ft is feet and after feet it is inch(convert to cm), 120cm
         */
        
        let params:[String:Any] = [
            "height": inputHeight
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_height, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(WeightBaseModel.self, from: responceData)
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
    
    //MARK: --------------------- get-goals?
    class  func getGoalsApi(viewController: UIViewController, completion: @escaping(_ resultData:PersonalizedBaseModel?) -> Void){
       
        let params:[String:Any]? = nil
       
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_goals, method: .get , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            print(getResponce as Any)
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(PersonalizedBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
            }catch {
                print(error)
            }
            
        })
    }
    
    //MARK: --------------------- add/goal
    class  func addGoalApi(viewController: UIViewController, inputIds:String?, completion: @escaping(_ resultData:SubmitOtpBaseModel?) -> Void){
        guard let inputIds = inputIds else { return }
        /*
         ids: 1,2
         */
        let params:[String:Any] = [
            "ids": inputIds
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_goal, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SubmitOtpBaseModel.self, from: responceData)
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
    
    //MARK: --------------------- api/preferwork
    class  func addPreferworkApi(viewController: UIViewController, inputName:String?, completion: @escaping(_ resultData:WeightBaseModel?) -> Void){
        guard let inputName = inputName else { return }
        /*
         "name": "myselfs"
         */
        let params:[String:Any] = [
            "name": inputName
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_preferwork, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(WeightBaseModel.self, from: responceData)
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
    
 
    //MARK: --------------------- add/location
    class  func addLocationApi(viewController: UIViewController, inputLat:String?, inputLong:String?, inputAddress:String?, completion: @escaping(_ resultData:SubmitOtpBaseModel?) -> Void){
        guard let inputLat = inputLat, let inputLong = inputLong, let inputAddress = inputAddress else { return }
        /*
         "lat": "5.7889988",
         "long":"6.87979",
         "address": "gt road"
         */
        let params:[String:Any] = [
            "lat": inputLat,
            "long":inputLong,
            "address": inputAddress
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_location, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SubmitOtpBaseModel.self, from: responceData)
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
    
    //MARK: ---------------------https://mobileapp.mypt-me.com/api/account-delete
    class func deleteUserAccApi(viewController: UIViewController, isShowLoader:Bool = true, completion: @escaping(_ resultData:[String:Any]?) -> Void){
//        let params:[String:String] =
//        [
//            "" : ""
//        ]
        
        //        NetworkManager.shared.genericAPICall(serviceEndPoint: .account_delete, method: .get , queries: nil, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .account_delete, method: .get , parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
        
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
        })
    }
    
    
    /*
     NetworkManager.shared.genericAPICall(serviceEndPoint: .login, method: .post , parameters: params, isShowLoading: true, completion: {  (getResponce, error) in
         do{
             if let responceData = getResponce {
                 let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                 completion(getResult)
             }
             
//                if let responceData = getResponce {
//                    let getResult = try JSONDecoder().decode(SentOptModel.self, from: responceData)
//                    completion(getResult)
//                }
         }catch {
             print(error)
         }
         
     })
     */
}
