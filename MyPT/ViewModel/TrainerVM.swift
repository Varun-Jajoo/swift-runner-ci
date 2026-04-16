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
    var addressId: String?
    var addressData: AddressDataModel?
    var package_type: String?
    var daysForGymMembership: Int?
    var priceForGymMembership: Int?
    var isFreeAssessmentSelected: Bool?
    var isGroup: Bool? // true -> show TrainerListViewController
    var isFromHomeTrainers: Bool? // true -> when comes from home and gym trainers
}

class TrainerVM {
    
    //MARK: --------------------- get-trainer
    class func gerTrainerApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:GetTrainerBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        
        /*
         let params:[String:String] = [
         "type": inputType, // type: gym, home, gym based on selection
         "is_filter": "",   //is_filter: 1, if filter 1 then tag id required, trainers or studio
         "tag_id": "",      //tag_id: 1, tag id is required when is filter 1
         "long": "",        //long: 77.391029, this is current location always required
         "lat": ""          //lat: 28.535517, this is current location always required
         ]
         */
        
        let params:[String:String] = inputParms
        print("token: ", appUserDefaults.getAccessToken() ?? "")
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_trainer, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(GetTrainerBaseModel.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    }
                    else{
                        let errorMsg = getResult.msg
                        AlertHelper.shared.alertMesssage(view: viewController, title: "", message: errorMsg ?? "")
                        
                        /*
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
                         */
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
    
    
    //MARK: --------------------- api/get-trainers
    class  func gerFilterTrainerApi(viewController: UIViewController, inputParams: [String:Any], completion: @escaping(_ resultData:GetTrainerBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "gender": 1,2,
         "language": 1,2
         "is_filter":1
         "lat": 1.344444
         "long":4.8999
         "time_slot":
         "type": home , type: gym, home, gym based on selection
         "tag_id":49 , //tag_id: 1, tag id is required when is filter 1
         "nationality": 1,2
         ]
         */
        
        print("inputParams = ", inputParams)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .filter_trainer, method: .post , parameters: inputParams, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(GetTrainerBaseModel.self, from: responceData)
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
    
    
    //MARK: --------------------- api/gym-trainers //(selectGymApi)
    class  func selectGymFilterTrainerApi(viewController: UIViewController, inputParams: [String:Any], completion: @escaping(_ resultData:GymTrainerBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "id":"", studio id is required
         "gender": 1,2,
         "language": 1,2
         "is_filter":1
         "lat": 1.344444
         "long":4.8999
         "time_slot":
         "type": home , type: gym, home, gym based on selection
         "tag_id":49 , //tag_id: 1, tag id is required when is filter 1
         "nationality": 1,2
         ]
         */
        
        print("inputParams = ", inputParams)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .filter_gym_trainers, method: .post , parameters: inputParams, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
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
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .trainer_details, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
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
    class func selectGymApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:GymTrainerBaseModel?) -> Void) {
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
        
        /*
         let params:[String:String] = [
         "id": "",        //id = 5 , this is studio id , for get studio trainers
         "long": "",      //long = 77.391029, this is always required for current location
         "lat": "",       //lat = 28.535517, this is always required for current location
         "is_filter": "", // is_filter = 1, if select tag based trainer
         "tag_id": ""     //tag_id = 4, required if is_filter is 1
         ]
         */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .select_gym, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
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
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .studio_details, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
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
    
    
    //MARK: ------------------------- api/get-availability
    class func calendarAvailabilityApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:CalendarAvailabilityBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
        
        /*
         let params:[String:String] = [
         "type": "",        //type = gym, gym=>trainer from gym, home=>trainer for home
         "trainer_id": "",  //trainer_id = 1, trainer id is required
         "studio_id": "",   //studio_id = 1, studio id required if selecting from gym
         "month": ""        //month = 03
         "address_id: ""    //address_id = 1
         ]
         */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_availability, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(CalendarAvailabilityBaseModel.self, from: responceData)
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
    
    //MARK: ------------------------- api/get-Slotes-by-time
    class func getSlotsByTimeApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: SlotsByTimeModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .getSlotsByTime, method: .post , queries: nil, parameters: params, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
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
    
    class func reviewAssessmentApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader: Bool = true, completion: @escaping(_ resultData: ReviewAssessmentBaseModel?) -> Void) {
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .reviewAssessment, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(ReviewAssessmentBaseModel.self, from: responceData)
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
    
    class func bookAssessmentApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData: SlotsByTimeModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .bookAssessment, method: .post , queries: nil, parameters: params, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
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
    
    // MARK: ------------------------- api/get-cities
    class func getCityApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:CityBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_cities, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(CityBaseModel.self, from: responceData)
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
    
    //MARK: ------------------------- api/get-emirates
    class func getEmiratesApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:CountryBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params: [String:String] = inputParms
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_emirates, method: .get , queries: nil, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(CountryBaseModel.self, from: responceData)
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
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_address, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
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
    class  func addAddressApi(viewController: UIViewController, inputParams: [String:Any], completion: @escaping(_ resultData:AddressBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "id": "", //"id" : "" , when add addres id is empty otherwise id which is getting list of address
         "building_name": "" ,
         "street": "",
         "city_id": "",
         "country_id": "",
         "landmark": "",
         "type": "",
         "mobile_no": "",
         "lat": "",
         "long": "",
         "name": "", hareram field is required
         ]
         */
        
        print("inputParams = ", inputParams)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .add_address, method: .post , parameters: inputParams, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
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
    
    
    //MARK: ------------------------- api/get-slots
    class func getSlotsApi(viewController: UIViewController, inputParms: [String:String]?, isShowLoader:Bool = true, completion: @escaping(_ resultData:SlotsBaseModel?) -> Void){
        guard let inputParms = inputParms else { return  }
        let params:[String:String] = inputParms
        
        /*
         let params:[String:String] = [
         "trainer_id": "", //trainer_id: 2, trainer id required if selecting from gym
         "type": "",      //type: home, gym=>trainer from gym, home=>home trainer
         "date": "",      //date: 2025-03-25, date is required
         "timing": "",    //timing: night, morning or evening(required)
         "studio_id": "", //studio_id: 5, studio id is required if selecting from gym
         "address_id: ""  //address_id: 1, address id is required if type is gym
         ]
         */
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .get_slots, method: .get , queries: params, parameters:  nil, isShowLoading: isShowLoader, completion: {  (getResponce, error) in
            do{
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(SlotsBaseModel.self, from: responceData)
                    
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
    
    //MARK: ---------------------https://mobileapp.mypt-me.com/api/pay?amount=2
    
    class func ccavenuePaymentApi(viewController: UIViewController, inputPrice: String?, isShowLoader:Bool = true, completion: @escaping(_ resultData:[String:Any]?) -> Void){
        let params:[String:String] =
        [
            "amount": inputPrice ?? ""
        ]
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .ccaavenue_payment, method: .get , queries: params, parameters:  nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: {  (getResponce, error) in
            
            do {
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
                
            } catch {
                print(error)
            }
        })
    }
    
    //MARK: --------------------- api/book-slot
    class  func bookSlotApi(viewController: UIViewController, inputParams: [String:Any], completion: @escaping(_ resultData:BookedSlotBaseModel?) -> Void){
        
        /*
         let params:[String:Any] = [
         "studio_id": "",    //studio_id: 5, Studio id field is required if selecting from gym
         "type": "" ,        //type: gym, type will be home , gym
         "trainer_id": "",   //trainer_id: 1, trainer id filed is required
         "slot_id": "",      //slot_id: 23, slot id field is required
         "address_id": "",   //address_id: 1, address id is required if type is gym
         "is_package": "",   //is_package: 1, if hit through using package then 1 else blank
         "package_type": "", //package_type: 3, package type is required
         "date": "",         //date: 2025-03-28, start date is required
         "end_date": "",     //end_date: 2025-04-25, end date is required
         "sessions": "",     //sessions: 12, no of sessions
         "price": "",        //price: 320, price field is required
         "days": ""  ,        //days: 30, no of days
         "transaction_id":"",
         
         "payment_type": ccavenue, tabby/tamara/ccavenue
         "booking_id": 345, booking id for accept booking
         ]
         */
        
        
        
        print("inputParams = ", inputParams)
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .book_slot, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(BookedSlotBaseModel.self, from: responceData)
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
    
    // MARK: ----------------------- api/get-resources
    class func trainerFilterApi(inputParams:[String:String]? , isShowLoader:Bool = true, completion: @escaping(_ resultData:FilterTrainerBaseModel?) -> Void){
        
        NetworkManager.shared.genericAPICall(serviceEndPoint: .trainer_filter_data, method: .get , queries: inputParams, parameters:  nil, isShowLoading: isShowLoader, completion: {  ( getResponce, error) in
            do{
                print(getResponce as Any)
                if let responceData = getResponce {
                    let getResult = try JSONDecoder().decode(FilterTrainerBaseModel.self, from: responceData)
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
    
    // MARK: ---------------------- api/trainer-review
    class  func trainerReviewApi(inputParams: [String:Any]?, completion: @escaping(_ resultData: [String:Any]?) -> Void){
        /*
         let params:[String:Any] = [
         "trainer_id":  "",
         "booking_id": "",
         "message": "",
         "rating": ""
         ]
         */
        print("inputParams = ", inputParams as Any)
        NetworkManager.shared.genericAPICall(serviceEndPoint: .trainer_review, method: .post , parameters: inputParams, isShowLoading: true, completion: {  (getResponce, error) in
            do {
                print(getResponce as Any)
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
            } catch {
                print(error)
            }
        })
    }
    
}
