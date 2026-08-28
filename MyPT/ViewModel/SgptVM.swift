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

struct SgptCreditsBaseModel: Codable {
    var status: Bool?
    var message: String?
    var data: SgptCreditsModel?
}

struct SgptCreditsModel: Codable {
    var hasCredits: Bool?
    var remainingCredits: Int?
    var totalCredits: Int?
    var usedCredits: Int?
    var expiresAt: String?
    var expiresInDays: Int?

    enum CodingKeys: String, CodingKey {
        case hasCredits = "has_credits"
        case remainingCredits = "remaining_credits"
        case totalCredits = "total_credits"
        case usedCredits = "used_credits"
        case expiresAt = "expires_at"
        case expiresInDays = "expires_in_days"
    }
}

class SgptVM {
    //MARK: ----------------------- api/sgpt-credits

    /// Credit balance for the signed-in member. `nil` means the balance could
    /// not be read (offline, signed out, server error) - callers treat that
    /// the same as "no credits" and fall through to the pricing screen.
    class func sgptCreditsApi(isShowLoader: Bool = false, completion: @escaping (_ resultData: SgptCreditsModel?) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_credits, method: .get, queries: nil, parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                guard let responceData = getResponce else {
                    completion(nil)
                    return
                }
                let getResult = try JSONDecoder().decode(SgptCreditsBaseModel.self, from: responceData)
                completion(getResult.data)
            } catch {
                print(error)
                completion(nil)
            }
        })
    }

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
