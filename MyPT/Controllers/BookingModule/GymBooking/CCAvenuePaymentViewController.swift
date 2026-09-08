//
//  CCAvenuePaymentViewController.swift
//  MyPT
//
//  Created by techsaga corp on 28/05/25.
//

import UIKit
import Alamofire
@preconcurrency import WebKit

class CCAvenuePaymentViewController: CommonViewController, WKNavigationDelegate{

    var costAmt: Double?
    var packageDetails: PackageDetails?
    var paymentSuccess:((_ transactionStatus: Bool?,_ paymentId: Int?, _ orderRef: String?) -> Void)?
    var type: String?
    var sessions: Int?
    var packageType: String?
    var trainerId: Int?
    var addressId: Int?
    var studioId: String?
    var bestPlanId: String?
    var inputParam: DetailsParam?
    /// Bundle purchase (SGPT non-member flow). Set these INSTEAD of
    /// packageDetails/inputParam: a bundle is several products in one payment,
    /// so it carries its own id rather than a package tier. Nil for every other
    /// caller, which leaves the normal request untouched.
    var bundleId: String?
    /// Renewal offer: assembled per member from existing packages, so it is
    /// bought by its tier ids and has no bundle row to point at.
    var renewalTierIds: String?
    var bundleAmount: Double?
    var bundleStudioId: String?
    /// Session to auto-book once payment grants the access booking needs.
    var bundleSessionId: String?
    var paymetMethod: String? = "ccavenue"
    var requestData = PaymentModel()
    var paymentId = Int()
    var orderRef = String()
    
    @IBOutlet weak var paymentWeb: WKWebView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.loadpaymentWeb()
        apiCallForPaymentStatus(completion: {resultData in
            if (resultData != nil) {
//                self.paymentSuccess?(true, "")
            }
        })
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        self.customBlurViewRemove(viewShow: self.view)
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavUI()
    }
    
    func setNavUI() {
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: nil, setTitleColor: nil)
    }
    
    
    //MARK: --------------MAKE PAYMENT URL
    func buildPaymentURL(amount: Double) -> URL? {
        let paymentCCAvenueUrl = ApiEndPoint.ccaavenue_payment.getURL(queries: ["amount":"\(amount)"])
        print("paymentUrl", paymentCCAvenueUrl as Any)
        return paymentCCAvenueUrl
        
        /*
        var components = URLComponents(string: "https://mobileapp.mypt-me.com/api/pay")
        components?.queryItems = [URLQueryItem(name: "amount", value: "\(amount)")]
        return components?.url
        */
    }
        
    override func leftBtnActn(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismisBtnActn(_ sender: Any) {
        print("dismiss....")
        self.dismiss(animated: true, completion: nil)
    }
    
    
//    private func loadpaymentWeb() {
//        
//        guard let costAmt = costAmt, let paymentGatewayURL = buildPaymentURL(amount: costAmt) else { return }
//        paymentWeb.navigationDelegate = self
//        
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(appUserDefaults.getAccessToken() ?? "")",
//            "Accept": "application/json"
//        ]
//
//        AF.request(paymentGatewayURL, headers: headers)
//            .validate(contentType: ["text/html", "application/json"])
//            .responseString { [self] response in
//                // same as above
//                print("response", response)
//                
//                switch response.result {
//                case .success(let responseString):
//                    print("✅ Response String: \(responseString)")
//                    paymentWeb.loadHTMLString(responseString, baseURL: nil)
//                case .failure(let error):
//                    print("❌ Error: \(error.localizedDescription)")
//                }
//            }
//    }
    
    private func apiCallForPaymentStatus(completion: @escaping(_ resultData: PackageCheckoutBaseModel?) -> Void) {
//        let inputParams: [String: Any] = [
//            "gateway": "ccavenue",
//            "amount": 500,
//            "payment_for": "subscription",
//            "sessions": sessions ?? 1,
//            "type": inputParam?.type ?? "",
//            "plan_id": 1,
//            "package_type": inputParam?.package_type ?? "",
//            "best_plan_id": Int(bestPlanId ?? "0") ?? 0,
//            "offer_id": 6,
//            "bonus_sessions": 2,
//            "validity_days": 30,
//            "price": costAmt ?? 0.0
//        ]
        
        requestData.gateway = "ccavenue"
        requestData.amount = packageDetails?.price
        requestData.payment_for = "subscription"
        requestData.sessions = packageDetails?.sessions
        requestData.type = inputParam?.type
        requestData.trainer_id = inputParam?.trainer_id
//        requestData.plan_id = 1
        requestData.package_type = packageDetails?.packageType
        requestData.best_plan_id = packageDetails?.bestPlanID
        requestData.offer_id = packageDetails?.appliedOfferID
        requestData.bonus_sessions = packageDetails?.bonusSessions
        requestData.validity_days = packageDetails?.validityDays
        requestData.price = packageDetails?.price
        requestData.studio_id = inputParam?.studio_id

        // A bundle overrides the package-tier shaped request above: package_type
        // 5 tells the server to snapshot the bundle's components and grant them
        // all on the gateway callback.
        if bundleId != nil || renewalTierIds != nil {
            requestData.package_type = 5
            requestData.bundle_id = bundleId
            requestData.renewal_tier_ids = renewalTierIds
            requestData.session_id = bundleSessionId
            requestData.studio_id = bundleStudioId
            requestData.type = "gym"
            requestData.payment_for = "subscription"
            requestData.amount = bundleAmount
            requestData.price = bundleAmount
            requestData.best_plan_id = nil
            requestData.sessions = nil
        }
       
        print("inputParams: ",requestData.getParams())
        
//        print("inputParams = ", inputParams as Any)
        
        guard let costAmt = costAmt, let paymentGatewayURL = ApiEndPoint.ccaavenue_payment.getURL(queries: [:]) else { return }
                paymentWeb.navigationDelegate = self
        
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(appUserDefaults.getAccessToken() ?? "")",
                    "Accept": "application/json"
                ]
        print("paymentGatewayURL", paymentGatewayURL)
        AF.request(paymentGatewayURL, method: .post, parameters: requestData.getParams(), headers: headers)
                    .validate(contentType: ["text/html", "application/json"])
                    .responseString { [self] response in
                        // same as above
                        print("response", response)
        
                        switch response.result {
                        case .success(let responseString):
                            print("✅ Response String: \(responseString)")
                            if let data = responseString.data(using: .utf8) {
                                
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                       let dataDict = json["data"] as? [String: Any] {
                                        
                                        let gateway = dataDict["gateway"] as? String
                                        let paymentId = dataDict["payment_id"] as? Int
                                        let orderRef = dataDict["order_ref"] as? String
                                        let html = dataDict["html"] as? String
                                        
                                        print("gateway:", gateway ?? "")
                                        print("payment_id:", paymentId ?? 0)
                                        print("order_ref:", orderRef ?? "")
                                        print("html:", html ?? "")
                                        self.paymentId = paymentId ?? 0
                                        self.orderRef = orderRef ?? ""
                                        paymentWeb.loadHTMLString(html ?? "", baseURL: nil)
                                    }
                                } catch {
                                    print("JSON Error:", error)
                                }
                            }

//                            paymentWeb.loadHTMLString(responseString, baseURL: nil)
                        case .failure(let error):
                            print("❌ Error: \(error.localizedDescription)")
                        }
                    }
        
//        NetworkManager.shared.genericAPICall(serviceEndPoint: .ccaavenue_payment, method: .post , parameters: inputParams, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: { (getResponce, error) in
//            do {
//                print(getResponce as Any)
//                if let responceData = getResponce {
//                    
//                    let getResult = try JSONDecoder().decode(PackageCheckoutBaseModel.self, from: responceData)
//                    if (getResult.status == true)  {
//                        completion(getResult)
//                    } else {
//                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
//                        AlertHelper.shared.alertMesssage(view: self, title: "", message: errorMsg ?? "")
//                    }
//                }
//            } catch {
//                print(error)
//            }
//        })
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Optional:  Additional actions after the page loads
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        print("Navigating to URL: \(url.absoluteString)")
    
        if url.path.contains("payment/success") {
            let pathComponents = url.pathComponents
            if let lastComponent = pathComponents.last {
                print("Last path component: \(lastComponent)")
                self.paymentSuccess?(true, self.paymentId, self.orderRef)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else if url.path.contains("api/payment/failure") {
            self.dismiss(animated: true, completion: {
                //"Transaction Failed!"
//                AlertHelper.shared.showCustomeAlert(title: "", message: "Transaction cancelled!", actions: ["ok"], withCancel: false, completion: {[weak self] getIndx in
                    self.paymentSuccess?(false, self.paymentId, self.orderRef)
                    self.dismiss(animated: true)
//                })
            })
        }
    
        
      
        /*
        if navigationAction.navigationType == .linkActivated {
            //api/payment/success
          
           
            
            // Check query parameters for "status"
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
//               let status = queryItems.first(where: { $0.name == "status" })?.value {
               
                let status = queryItems.first(where: { $0.name == "payment" })?.value {
                
                print("Detected status: \(status)")
                
                switch status.lowercased() {
                case "success":
//                    self.dismiss(animated: true)
                    decisionHandler(.cancel)
                    return
                case "cancelled":
                    // Optionally show an alert
                    self.dismiss(animated: true, completion: {
                        AlertHelper.shared.alertMesssage(view: self, title: "", message: "Transaction Failed!")
                    })
                    
                    decisionHandler(.cancel)
                    return
                default:
                    break
                }
            }
        }
        */

        decisionHandler(.allow)
    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
//        
//        guard let url = navigationAction.request.url else {
//                decisionHandler(.allow)
//                return
//            }
//            
//            // Only act on link-activated navigation type
//            if navigationAction.navigationType == .linkActivated {
//                // Check if the URL path contains "orange-return"
//                if url.path.contains("") {
//                    // If matched, pop the current view controller
//                    decisionHandler(.cancel) // Prevent the link from being loaded
//                    return
//                }
//                else if url.path.contains(""){
//                    
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }
//
//            // Allow the navigation to continue
//            decisionHandler(.allow)
//        }

    // MARK: - WKScriptMessageHandler
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        // Handle payment status messages from the webview
//        if let message = message.body as? String, message == "paymentSuccess" {
//            // Payment successful, redirect to success page
////            webView.load(URLRequest(url: successURL))
//        } else if let message = message.body as? String, message == "paymentFailure" {
//            // Payment failed, redirect to failure page
////            webView.load(URLRequest(url: failureURL))
//        }
//    }
}


struct PaymentModel {
    
    var gateway: String?
    var amount: Double?
    var payment_for: String?
    var sessions: Int?
    var type: String?
    var plan_id: Int?
    var package_type: Int?
    var best_plan_id: Int?
    var offer_id: Int?
    var bonus_sessions: Int?
    var validity_days: Int?
    var price: Double?
    var transaction_id: String?
    var payment_type: String?
    var booking_id: String?
    var payment_id: String?
    var order_ref, studio_id, trainer_id: String?
    /// Bundle purchase (package_type 5): the bundle being bought, and the
    /// session to book once payment grants the access booking requires.
    var bundle_id: String?
    var renewal_tier_ids: String?
    var session_id: String?
    
    func getParams() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let gateway = gateway { dict["gateway"] = gateway }
        if let amount = amount { dict["amount"] = amount }
        if let payment_for = payment_for { dict["payment_for"] = payment_for }
        if let sessions = sessions { dict["sessions"] = sessions }
        if let type = type { dict["type"] = type }
        if let plan_id = plan_id { dict["plan_id"] = plan_id }
        if let package_type = package_type { dict["package_type"] = package_type }
        if let best_plan_id = best_plan_id { dict["best_plan_id"] = best_plan_id }
        if let offer_id = offer_id { dict["offer_id"] = offer_id }
        if let bonus_sessions = bonus_sessions { dict["bonus_sessions"] = bonus_sessions }
        if let validity_days = validity_days { dict["validity_days"] = validity_days }
        if let price = price { dict["price"] = price }
        if let studio_id = studio_id { dict["studio_id"] = studio_id }
        if let trainer_id = trainer_id { dict["trainer_id"] = trainer_id }
        if let bundle_id = bundle_id { dict["bundle_id"] = bundle_id }
        if let renewal_tier_ids = renewal_tier_ids { dict["renewal_tier_ids"] = renewal_tier_ids }
        if let session_id = session_id { dict["session_id"] = session_id }
        
        return dict
    }
}
