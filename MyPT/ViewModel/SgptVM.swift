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

    /// TEMPORARY diagnostic capture - there's no Mac/Xcode/Console.app
    /// available to read this app's console output directly, so the only
    /// way to see why the SGPT carousel renders empty on iOS (while Android,
    /// hitting the same staging endpoint, shows real sessions) is to surface
    /// it on-screen instead. `HomepageVC`/`ActiveHomepageVCViewController`
    /// show this in an alert when `sgptSessions` ends up empty. Remove once
    /// the empty-carousel issue is actually root-caused.
    static var lastDiagnostic: String = "(sgpt-upcoming not called yet)"

    //MARK: ----------------------- api/sgpt-upcoming
    class func sgptUpcomingApi(inputParams: [String: String]?, isShowLoader: Bool = false, completion: @escaping (_ resultData: [SgptSessionModel]?) -> Void) {
        /*
         let params:[String:String] = [
            "lat": "", // lat: 13.887989
            "long": "" // long: 12.67788
         ]
        */

        let requestURL = ApiEndPoint.sgpt_upcoming.getURL(queries: inputParams)?.absoluteString ?? "(nil URL)"

        NetworkManager.shared.genericAPICall(serviceEndPoint: .sgpt_upcoming, method: .get, queries: inputParams, parameters: nil, isShowLoading: isShowLoader, completion: { (getResponce, error) in
            do {
                print(getResponce as Any)
                guard let responceData = getResponce else {
                    lastDiagnostic = "URL: \(requestURL)\n\nNo response data - network error or request-level failure.\nnetworkError param: \(String(describing: error))"
                    completion(nil)
                    return
                }
                let rawBody = String(data: responceData, encoding: .utf8) ?? "(non-UTF8 body, \(responceData.count) bytes)"
                let getResult = try JSONDecoder().decode(SgptUpcomingBaseModel.self, from: responceData)
                // A present, non-empty `data` array is real sessions to show
                // regardless of `status` - don't let an unreliable/ambiguous
                // status flag hide sessions that actually came back.
                if let data = getResult.data, !data.isEmpty {
                    lastDiagnostic = "URL: \(requestURL)\n\nDecoded \(data.count) session(s) OK."
                    completion(data)
                } else {
                    lastDiagnostic = "URL: \(requestURL)\n\nDecoded OK but data is empty/nil. status=\(String(describing: getResult.status))\n\nRaw body:\n\(rawBody)"
                    completion(getResult.status == true ? [] : nil)
                }
            } catch {
                let rawBody = getResponce.flatMap { String(data: $0, encoding: .utf8) } ?? "(no body / non-UTF8)"
                lastDiagnostic = "URL: \(requestURL)\n\nDECODE FAILED: \(error)\n\nRaw body:\n\(rawBody)"
                print(error)
                completion(nil)
            }
        })
    }
}
