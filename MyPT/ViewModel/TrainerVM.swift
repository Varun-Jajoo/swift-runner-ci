//
//  TrainerVM.swift
//  MyPT
//
//  Created by techsaga corp on 12/03/25.
//


import UIKit

struct DetailsParam {
    var trainer_id: String?
    var studio_id: String?
    var type: String?
    var long:String?
    var lat: String?
}

class TrainerVM {
    
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
        print("token: ", appUserDefaults.getAccessToken() ?? "")
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_trainer, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GetTrainerBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        
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
                    
                    //                    if let jsonResult = try JSONSerialization.jsonObject(with: responceData, options: .mutableContainers) as? [String: Any] {
                    //                        print(jsonResult)
                    //                    }
                }
            }catch {
                print(error)
            }
        })
    }
    
    //MARK: ------------------------- api/trainer-details
    class func getTrainerDetailsApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:TrainerDetailsBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
       
        /*
        let params:[String:String] = [
            "trainer_id": "",
            "studio_id": "",
            "type": "",
            "long": "",
            "lat": ""
        ]
        */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .trainer_details, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(TrainerDetailsBaseModel.self, from: responceData)
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
    
    //MARK: ------------------------- api/select/gym
    /*
     id = 5 , this is studio id , for get studio trainers
     long = 77.391029, this is always required for current location
     lat = 28.535517, this is always required for current location
     is_filter = 1, if select tag based trainer
     tag_id = 4, required if is_filter is 1
     */

    class func selectGymApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:GymTrainerBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
     
        /*
        let params:[String:String] = [
            "id": "",
            "long": "",
            "lat": "",
            "is_filter": "",
            "tag_id": ""
        ]
       */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .select_gym, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GymTrainerBaseModel.self, from: responceData)
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
    
    //MARK: ------------------------- api/studio-details
    class func studioDetailsApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:StudioDetailsBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
        /*
        let params:[String:String] = [
            "id": "",
            "long": "",
            "lat": "",
        ]
       */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .studio_details, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(StudioDetailsBaseModel.self, from: responceData)
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
    
    /*
     type = gym, gym=>trainer from gym, home=>trainer for home
     trainer_id = 1, trainer id is required
     studio_id = 1, studio id required if selecting from gym
     month = 03
     */
    
    //MARK: ------------------------- api/get-availability
    class func calendarAvailabilityApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:AvailabilityBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
       
        /*
         let params:[String:String] = [
         "type": "",
         "trainer_id": "",
         "studio_id": "",
         "month": ""
         ]
       */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_availability, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(AvailabilityBaseModel.self, from: responceData)
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
    
    //MARK: ------------------------- api/get-cities
    class func getCityApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:CityBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
       
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_cities, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(CityBaseModel.self, from: responceData)
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
    

    //MARK: ------------------------- api/get-address
    class func getAddressApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:AddressBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
       
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_address, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(AddressBaseModel.self, from: responceData)
                    
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
        
    //MARK: ------------ADDRESS VALIDATION
    class func isValideAddres(inputParams: [String:Any]?) -> Bool {
        guard let inputParams = inputParams else { return  false}
        
        if let building_Name =  inputParams["building_name"] as? String, building_Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.enter_Building_Name,actions: ["Ok"])
            return false
        } else if let street_Name =  inputParams["street"] as? String, street_Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.enter_Street_Name,actions: ["Ok"])
            return false
        } else if let mobile_no =  (inputParams["mobile_no"] as? String), !mobile_no.isValidPhone(phone: mobile_no) || mobile_no.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.enter_phone,actions: ["Ok"])
            return false
        } else if let city_Id =  (inputParams["city_id"] as? String), city_Id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.select_City,actions: ["Ok"])
            return false
        } else if let country_Id =  inputParams["country_id"] as? String, country_Id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.select_Country,actions: ["Ok"])
            return false
        } else if let type =  inputParams["type"] as? String, type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.select_type,actions: ["Ok"])
            return false
        }
        
        return true
    }
    
    //MARK: --------------------- Add Address/ Edit Address
    //AddressBaseModel
    class  func addAddressApi(viewController: UIViewController, inputParams: [String:Any], completion: @escaping(_ resultData:AddressBaseModel?) -> Void){
       
        //"id" : "" , when add addres id is empty otherwise id which is getting list of address
       
        /*
        let params:[String:Any] = [
            "id": "",
            "building_name": "" ,
            "street": "",
            "city_id": "",
            "country_id": "",
            "landmark": "",
            "type": "",
            "mobile_no": "",
            "lat": "",
            "long": ""
        ]
        */
        
        print("inputParams = ", inputParams)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_address, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(AddressBaseModel.self, from: responceData)
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
}
