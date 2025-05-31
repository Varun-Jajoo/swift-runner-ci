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
    var paymentSuccess:((_ transactionStatus: Bool?,_ transactionId: String?) -> Void)?
    
    @IBOutlet weak var paymentWeb: WKWebView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadpaymentWeb()
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
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func payAmt(){
        ////https://mobileapp.mypt-me.com/api/pay?amount=2
    }
    
    //MARK: --------------MAKE PAYMENT URL
    func buildPaymentURL(amount: Double) -> URL? {
        var components = URLComponents(string: "https://mobileapp.mypt-me.com/api/pay")
        components?.queryItems = [URLQueryItem(name: "amount", value: "\(amount)")]
        return components?.url
    }
    
    override func leftBtnActn(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismisBtnActn(_ sender: Any) {
        print("dismiss....")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func loadpaymentWeb(){
        
        guard let costAmt = costAmt, let paymentGatewayURL = buildPaymentURL(amount: costAmt) else { return }
        paymentWeb.navigationDelegate = self
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(appUserDefaults.getAccessToken() ?? "")",
            "Accept": "application/json"
        ]

        AF.request(paymentGatewayURL, headers: headers)
            .validate(contentType: ["text/html", "application/json"])
            .responseString { [self] response in
                // same as above
                print("response", response)
                
                switch response.result {
                case .success(let responseString):
                    print("✅ Response String: \(responseString)")
                    paymentWeb.loadHTMLString(responseString, baseURL: nil)
                case .failure(let error):
                    print("❌ Error: \(error.localizedDescription)")
                }
            }
        
//        guard let costAmt = costAmt, let paymentGatewayURL = buildPaymentURL(amount: costAmt) else { return }
//        paymentWeb.navigationDelegate = self
//        let request = URLRequest(url: paymentGatewayURL)
//        paymentWeb.load(request)
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
                self.paymentSuccess?(true,lastComponent)
                self.dismiss(animated: true, completion: nil)
            }
        }
        else if url.path.contains("payment/cancelled") {
            self.dismiss(animated: true, completion: {
                //"Transaction Failed!"
                AlertHelper.shared.showCustomeAlert(title: "", message: "Transaction cancelled!", actions: ["ok"], withCancel: false, completion: {[weak self] getIndx in
                    
                    self?.dismiss(animated: true)
                })
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
