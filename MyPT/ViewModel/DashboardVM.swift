//
//  DashboardVM.swift
//  MyPT
//
//  Created by techsaga corp on 11/02/25.
//

import UIKit

class DashboardVM {
    
    //MARK: --------------------- workouts
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
      http://mypt.test/api/get-trainer?is_filter=1&tag_id=1&type=gym&long=77.391029&lat=28.535517
      is_filter
      1

      if filter then 1 define request basic of filter

      tag_id
      1

      tag id is required when is filter 1

      type
      gym

      if filter 1 then tag id required, trainers or studio

      long
      77.391029

      this is current location always required

      lat
      28.535517

      this is current location always required
      
     */
    
    class func gerTrainerApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:GetTrainerBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        
        /*
        let params:[String:String] = [
            "type": inputType,
            "is_filter": "",
            "tag_id": "",
            "long": "",
            "lat": ""
        ]
        */
        
        let params:[String:String] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_trainer, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GetTrainerBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
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
    
}
