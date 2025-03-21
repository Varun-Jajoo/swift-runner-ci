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
    
    
}
