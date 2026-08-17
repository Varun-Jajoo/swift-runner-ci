//
//  NewBookingVM.swift
//  MyPT
//
//  Created by Manik Goel on 28/06/26.
//

import Foundation
import UIKit

class NewBookingVM {
    
    class func getNewBookingCheckClientApi(viewController: UIViewController, inputParms: [String: Any]?, isShowLoader: Bool = true, completion: @escaping(_ resultData: NewBookingSlots?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .newBookingCheckClientGroup, method: .get, queries: nil, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do {
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(NewBookingSlots.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
                        let errorMsg = getResult.msg
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    class func getNewBookingSlotsApi(viewController: UIViewController, inputParms: [String: Any]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: GetSlotesModel?) -> Void) {
        guard let inputParms = inputParms else { return  }
        let params: [String: Any] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .newBookingTrainerSlots, method: .post , queries: nil, parameters: params, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do {
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GetSlotesModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
                        let errorMsg = getResult.msg
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    class func getNewBookingGroupSlotsApi(viewController: UIViewController, inputParms: [String: Any]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: GetSlotesModel?) -> Void) {
        guard let inputParms = inputParms else { return  }
        let params: [String: Any] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .newBookingGroupDateSlots, method: .post , queries: nil, parameters: params, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do {
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GetSlotesModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
                        let errorMsg = getResult.msg
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            } catch {
                print(error)
                completion(nil)
            }
        })
    }
    
    class func reviewBookingApi(viewController: UIViewController, inputParms: [String: Any]?, isShowLoader: Bool = true, completion: @escaping(_ resultData: ReviewNewBookingModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String: Any] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .newBookingReviewGroupBooking, method: .post , queries: nil, parameters: params, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do {
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(ReviewNewBookingModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
                        let errorMsg = getResult.msg
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
            } catch {
                print(error)
            }
        })
    }
    
    class func confirmBookingApi(viewController: UIViewController, inputParms: [String: Any]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: SlotsByTimeModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params: [String: Any] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .newBookingConfirmGroupBooking, method: .post , queries: nil, parameters: params, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do {
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SlotsByTimeModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
                        let errorMsg = getResult.msg
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                    }
                }
            } catch {
                print(error)
            }
        })
    }
}
