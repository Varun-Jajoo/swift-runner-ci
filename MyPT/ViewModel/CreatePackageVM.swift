//
//  CreatePackageVM.swift
//  MyPT
//
//  Created by techsaga corp on 29/03/25.
//

import UIKit


//MARK: ------------------PACKAGEREVIEW WithoutTrainerParams PARAMS MODEL
struct WithoutTrainerParams {
    var price: String?
    var start_date: String?
    var end_date: String?
    var days: String?
    var studio_id: String?
    var transaction_id: String?
    
    func getParamsReviewPackage() -> [String:String] {
        var dictVar: [String:String] =  [:]
        
        if let price = price { dictVar["price"] = price }
        if let start_date = start_date { dictVar["start_date"] = start_date }
        if let end_date = end_date { dictVar["end_date"] = end_date }
        if let days = days { dictVar["days"] = days }
        if let studio_id = studio_id { dictVar["studio_id"] = studio_id }
        if let transaction_id = transaction_id { dictVar["transaction_id"] = transaction_id }
        
        return dictVar
    }
    
    func getParamsBookMembership() -> [String:Any] {
        var dictVar: [String:Any] =  [:]
        
        if let price = price { dictVar["price"] = price }
        if let start_date = start_date { dictVar["start_date"] = start_date }
        if let end_date = end_date { dictVar["end_date"] = end_date }
        if let days = days { dictVar["days"] = days }
        if let studio_id = studio_id { dictVar["studio_id"] = studio_id }
        
        return dictVar
    }
}


class CreatePackageVM{
    
    //MARK: -----------------------Check package is created or not
    class func checkPackageCreatedApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:[String:Any]?) -> Void){
        guard let inputParms = inputParms else { return  }
        /*
         let params:[String:String] = [
         :
         ]
         */
        let params:[String:String] = inputParms
        NetworkManager.shared.genericAPICall(serviceEndPoint: .check_type_Package, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                    guard let getResult = getResult else { return }
                    if (getResult["status"] as? Bool) == true  {
                        completion(getResult)
                    }
                    else{
                        
                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["msg"] as? String ?? ""))"
//                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg)
                        debugPrint(errorMsg)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: -----------------------Create package for One buddy / With buddy
    class func createPackageApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:CreatePackageBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        
        /*
         let params:[String:String] = [
         "package_type": "",  //package_type: 1, 1=>one-on-one,2=>buddy,3=>group
         "sessions": "",     //sessions: 13, no of sessions,initally remains 1
         "type": "",         //type: gym, home=>if selected from home, gym=>selected from gym
         "trainer_id": "",   //trainer_id: 1, trainer id is required
         "studio_id": "",   //studio_id: 5, studio id is required if type is gym
         "month": "",       //month: 3, month
         "address_id": ""   //address_id: 1, Address id is required if type is home
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
    class  func packageSetDateApi(viewController: UIViewController, inputParams: [String:Any]?, completion: @escaping(_ resultData:SetDateBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "package_type": "", //package_type: 1
         "sessions": "" ,    //sessions: 13
         "type": "",         //type: gym
         "trainer_id": "",   //trainer_id: 1
         "studio_id": "",    //studio_id: 5
         "date": "",         //date: 2025-03-15 , start Date
         "end_date": "",    //end_date: 2025-04-02, End date
         "timing": "",      //timing: morning
         "address_id": "",  //address_id: 1, address id is required if type is home
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
    class  func packageCheckoutApi(viewController: UIViewController, inputParams: [String:Any]?, completion: @escaping(_ resultData:PackageCheckoutBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "package_type": "",   //package_type: 1, package type is required 1,2,3
         "sessions": "" ,      //sessions: 13, no of session , at least one is required
         "type": "",           //type: gym,  home or gym
         "trainer_id": "",     //trainer_id: 1, trainer id is required
         "studio_id": "",      //studio_id: 5, studio id is required if type is gym
         "date": "",           //date: 2025-03-29, start date
         "end_date": "",       //end_date: 2025-04-02, end date
         "address_id": "",     //address_id: 1, address id is required if type is home
         "slot_id": ""         //slot_id: 18, slot id is required
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
    class func getMemberPackagegroupApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:MemberBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        
        /*
         let params:[String:String] = [
         "package_type": "", //package_type: 3, this will always remains
         "type": "",         //type: gym, gym=>select from studio, home=>direct home
         "trainer_id": "",   //trainer_id: 1, trainer id is required
         "studio_id": ""     //studio_id: 1, studio id required if type is gym
         ]
         */
        
        let params:[String:String] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_maember_package_group, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
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
    
    class func getBuddyMemberApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:MemberBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        
        /*
         let params:[String:String] = [
         "package_type": "", //package_type: 3, this will always remains
         "type": "",         //type: gym, gym=>select from studio, home=>direct home
         "trainer_id": "",   //trainer_id: 1, trainer id is required
         "studio_id": ""     //studio_id: 1, studio id required if type is gym
         ]
         */
        
        let params: [String: String] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_buddy_member, method: .get , queries: nil, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(MemberBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
                        let errorMsg = getResult.msg //(getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    //MARK: ------------------ api/add-member
    class  func addMemberApi(viewController: UIViewController, inputParams: [String:Any]?, completion: @escaping(_ resultData: AddMemberBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "name": "",     //name: jojos, name field is required
         "age": "" ,     //age: 22, age is required
         "gender": "",   //gender: male, gender field is required=>male,female,others
         "id": ""       //id: 1, if edit then id is required else not required meanwhile when want to add new                   member then id wiil be nil
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
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .delete_member, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
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
            "id": inputId ?? "" //id:2, trainer id is required
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
    
    
    //MARK: --------------------- api/membership-validity
    /*
     studio_id: 5, studio id field is required
     days: 12, no of days , atleast 1 one day is required
     */
    
    class func membershipValidityApi(viewController: UIViewController, inputStudioId: String?, inputDays: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData:MembershipValidityBaseModel?) -> Void){
        
        let params:[String:String] = [
            "studio_id": inputStudioId ?? "",
            "days": inputDays ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .membership_validity, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(MembershipValidityBaseModel.self, from: responceData)
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
    
    //MARK: --------------------- api/review-package
    class func reviewPackageMembershipApi(viewController: UIViewController, inputParams: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: ReviewPackageWithoutTrainerBaseModel?) -> Void){
        
        guard let inputParams = inputParams else { return  }
        
        /*
         let params:[String:String] = [
         "price": "",        //price: 123, price
         "start_date": "",   //start_date: 2025-03-04, start date
         "end_date": "",     //end_date: 2025-03-08, end date is required
         "days": "",         //days: 12, no of days , atleast 1 one day is required
         "studio_id": ""     //studio_id: 4, studio id field is required
         ]
         */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .review_package_membership, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(ReviewPackageWithoutTrainerBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
                
                //                if let responceData = getResponce {
                //                    let getResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String:Any]
                //                    guard let getResult = getResult else { return }
                //
                //                    if (getResult["status"] as? Bool) == true  {
                //                        completion(getResult)
                //                    }
                //                    else{
                //
                //                        let errorMsg = "\(((getResult["errors"] as? [String : Any])?.values.first as? [Any])?.first as? String ?? (getResult["msg"] as? String ?? ""))"
                //                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg)
                //                    }
                //                }
                
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: -------------------- api/book-membership
    class  func bookMembershipApi(viewController: UIViewController, inputParams:[String:Any]?, completion: @escaping(_ resultData: BookMembershipBaseModel?) -> Void){
        print("params = ", inputParams as Any)
        
        /*
         let params:[String:String] = [
         "price": "123",    //price: 123, price
         "start_date": "",  //start_date: 2025-04-02, start date is required
         "end_date": "",    //end_date: 2025-04-06, end date is required
         "days": "",        //days: 4, no of days required for validity
         "studio_id": ""    //studio_id: 1, required
         "transaction_id": "" //
         ]
         */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .book_membership, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(BookMembershipBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        //                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                        
                        //----------Token expire
                        if let unauthorizedStr = errorMsg, unauthorizedStr.uppercased() == "Unauthorized".uppercased() {
                            AlertHelper.shared.showCustomeAlert(message: "Session expired, please login again", actions: ["Ok"], completion: { getTag in
                                
                                if  appUserDefaults.clearUserDefault() {
                                    appSceneDelegate?.goToMainView()
                                }
                            })
                            
                            return
                        }else{
                            AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                        }
                    }
                }
            }catch {
                print(error)
            }
        })
    }
}
