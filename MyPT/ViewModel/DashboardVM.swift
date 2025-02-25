//
//  DashboardVM.swift
//  MyPT
//
//  Created by techsaga corp on 11/02/25.
//

import UIKit

class DashboardVM {
    
    //MARK: --------------------- workouts
   //api/workouts
    class func workoutsApi(viewController: UIViewController,params: [String:Any]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:DashboardBaseModel?) -> Void){
        NetworkManager.shared.genericAPICall(serviceEndPoint: .workouts, method: .get , parameters: params, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(DashboardBaseModel.self, from: responceData)
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
    
    //MARK: --------------------- get-trainer
    /*
     "type":"gym"
     type=>home, gym
     */
    //http://mypt.test/api/get-trainer?type=gym
    
    class func gerTrainerApi(viewController: UIViewController,inputType: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData:DashboardBaseModel?) -> Void){
        guard let inputType = inputType else { return  }
        
        let params:[String:String] = [
            "type": inputType
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_trainer, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    
                    if let jsonResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String: Any] {
                        print(jsonResult)
                    }
                    
//                    let getResult = try JSONDecoder().decode(DashboardBaseModel.self, from: responceData)
//                    if (getResult.status == true)  {
//                        completion(getResult)
//                    }
//                    else{
//                        let errorMsg = getResult.msg
//                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
//                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
}
