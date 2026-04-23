//
//  PurchaseViewModel.swift
//  MyPT
//
//  Created by Pratham Gupta on 26/01/26.
//

import Foundation


//MARK: --------------------- workouts

class PurchaseViewModel {
   class func groupTrainersApi(params: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: GroupTrainerModel?) -> Void) {
       NetworkManager.shared.genericAPICall(serviceEndPoint: .getTrainerGroup, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GroupTrainerModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    class func getGroupDetailApi(params: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: GroupTrainerModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .getGroupDetail, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
             do{
                 if let responceData = getResponce {
                     let getResult = try JSONDecoder().decode(GroupTrainerModel.self, from: responceData)
                     if (getResult.status == true)  {
                         completion(getResult)
                     }
                     else{
                         let errorMsg = getResult.msg
                         AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                     }
                 }
             } catch {
                 print(error)
             }
         })
     }
    
    class func bestPlanApi(params: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: BestPlanModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .bestPlans, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
             do{
                 if let responceData = getResponce {
                     let getResult = try JSONDecoder().decode(BestPlanModel.self, from: responceData)
                     if (getResult.status == true)  {
                         completion(getResult)
                     }
                     else{
                         let errorMsg = getResult.msg
                         AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                     }
                 }
             } catch {
                 print(error)
             }
         })
     }
    
    
    class func customisePlanApi(params: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: CustomisePlanModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .package_create_one_buddy, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
             do{
                 if let responceData = getResponce {
                     let getResult = try JSONDecoder().decode(CustomisePlanModel.self, from: responceData)
                     if (getResult.status == true)  {
                         completion(getResult)
                     }
                     else{
                         let errorMsg = getResult.msg
                         AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                     }
                 }
             } catch {
                 print(error)
             }
         })
     }
    
    class func customisePlansForGymMembership(params: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: MembershipValidityBaseModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .membership_validity, method: .get, queries: params, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
             do{
                 if let responceData = getResponce {
                     let getResult = try JSONDecoder().decode(MembershipValidityBaseModel.self, from: responceData)
                     if (getResult.status == true)  {
                         completion(getResult)
                     } else {
                         let errorMsg = getResult.msg
                         AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                     }
                 }
             } catch {
                 print(error)
             }
         })
     }
    
    
    class func reviewPackageCheckoutApi(params: [String: Any]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: ReviewPackageCheckoutModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .reviewPackageCheckout, method: .post, parameters: params, isShowLoading: false,  isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
             do{
                 print(getResponce as Any)
                 if let responceData = getResponce {
                     let getResult = try JSONDecoder().decode(ReviewPackageCheckoutModel.self, from: responceData)
                     if (getResult.status == true)  {
                         completion(getResult)
                     }else{
                         let errorMsg = getResult.msg
                         AlertHelper.shared.showCustomeAlert(title: "", message: errorMsg ?? "", completion: nil)
                     }
                 }
             } catch {
                 print(error)
             }
         })
     }
}
