//
//  SgptVM.swift
//  MyPT
//
//  Small Group PT (SGPT) home-carousel + See All screen.
//  Split out from UpcomingClassVM.swift rather than added there: SGPT is a
//  distinct feature/domain (own model, own endpoint) - every existing method
//  in UpcomingClassVM is specifically about the Group Classes domain
//  (UpcomingClassModel / ViewAllClassBaseModel / etc.), same one-VM-per-domain
//  split already used for HomepageViewModel/DashboardVM/TrainerVM/BookingVM.
//

import Foundation

class SgptVM {
    //MARK: ----------------------- api/sgpt-upcoming
    class func sgptUpcomingApi(inputParams: [String: String]?, isShowLoader: Bool = false, completion: @escaping (_ resultData: [SgptSessionModel]?) -> Void) {
        /*
         let params:[String:String] = [
            "lat": "", // lat: 13.887989
            "long": "" // long: 12.67788
         ]
        */

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_upcoming, method: .get, queries: inputParams, parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                print(getResponce as Any)
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptUpcomingBaseModel.self, from: responceData)
                // A present, non-empty `data` array is real sessions to show
                // regardless of `status` - don't let an unreliable/ambiguous
                // status flag hide sessions that actually came back.
                if let data = getResult.data, !data.isEmpty {
                    completion(data)
                } else {
                    completion(getResult.status == true ? [] : nil)
                }
            } catch {
                print(error)
                completion(nil)
            }
        })
    }
}
