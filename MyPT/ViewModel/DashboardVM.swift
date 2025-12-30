//
//  DashboardVM.swift
//  MyPT
//
//  Created by techsaga corp on 11/02/25.
//

import UIKit

struct UpgradePlanParamModel {
    var type: String?
    var sessions: String?
    var id: String?
    var days: String?
}

class DashboardVM {
    
    //MARK: -----------------------api/get-plans
    class func getPlansApi(isShowLoader:Bool = true, completion: @escaping(_ resultData:UserPlanBaseModel?) -> Void){
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_plans, method: .get , queries: nil, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(UserPlanBaseModel.self, from: responceData)
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
    
    //MARK: -----------------------api/upgrade-plan
    class func upgradePlansApi(inputParams:[String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:UpgradePlanBaseModel?) -> Void){
        
        /*
        let params:[String:String]? = [
            "type": "upgrade",  //upgrade/topup
            "sessions": "", // no of sessions that are added or updated(if 10 sessions already if user add scroll bar from to 40 then 30 sessions goes).
            "id": "", //plan id is required
            "days": "" //no of days validity increasing
        ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .upgrade_plan, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(UpgradePlanBaseModel.self, from: responceData)
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
    
    //MARK: ------------------ api/review-upgrade-package
    class  func reviewUpgradePackageApi(inputparams: [String:Any]?, completion: @escaping(_ resultData: ReviewUpgradePackageBaseModel?) -> Void){
        /*
         let params:[String:Any] = [
             "type": "", //topup
             "id": "", //id is required
             "price": "",
             "sessions": "",
             "days": "",
         ]
        */
        print("inputParams = ", inputparams as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .review_upgrade_package, method: .post , parameters: inputparams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(ReviewUpgradePackageBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        print(getResult.msg as Any)
//                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    
    //http://mypt.test/api/make-payment
    
    //MARK: ------------------ api/make-payment
    class  func makePaymentUpgradePackageApi(inputparams: [String:Any]?, completion: @escaping(_ resultData: UpgradePlanPaymentBaseModel?) -> Void){
        /*
         let params:[String:Any] = [
                                     "id": "",
                                     "transaction_id": "",
                                     "payment_type": "",
                                     "type": "",
                                     "sessions": "",
                                     "days": "",
                                     "price": ""
                                    ]
        */
        print("inputParams = ", inputparams as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .make_payment, method: .post , parameters: inputparams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(UpgradePlanPaymentBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        print(getResult.msg as Any)
//                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
//    //MARK: --------------------- workouts
//    class func workoutsApi(viewController: UIViewController,params: [String:Any]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:DashboardBaseModel?) -> Void){
//        NetworkManager.shared.genericAPICall(serviceEndPoint: .workouts, method: .get , parameters: params, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
//            do{
//                if let responceData = getResponce {
//                    let getResult = try JSONDecoder().decode(DashboardBaseModel.self, from: responceData)
//                    if (getResult.status == true)  {
//                        completion(getResult)
//                    }
//                    else{
//                        let errorMsg = getResult.msg
//                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
//                    }
//                }
//            }catch {
//                print(error)
//            }
//        })
//    }
    
}
