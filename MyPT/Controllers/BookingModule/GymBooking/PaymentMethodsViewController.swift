//
//  PaymentMethodsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 27/05/25.
//

import UIKit
import SwiftUI
import Tabby

class PaymentMethodsViewController: CommonViewController {
    
    //MARK: -------------- VARIABLE
    var paymentSuccess:((_ transactionStatus: Bool?,_ transactionId: String?, _ paymentMethod: String?) -> Void)?
//    var paymetSlotsData: AvailabilityDataModel?
    var sessionCost: String?
    var taxesStr: String?
    var totalPayableStr: String? = nil {
        didSet{
            let totalAmt = self.totalPayableStr?.components(separatedBy: " ")
//            let payBal: String = (totalAmt?.last ?? "") + " " + (totalAmt?.first ?? "")
            
//            let payBal: String = (totalAmt?.count > 1) ? (totalAmt?.last ?? "") + " " + (totalAmt?.first ?? "") : "AED" + " " + (totalAmt?.first ?? "")
          
            var payBal: String = ""
            if let totalAmt = totalAmt {
                payBal = (totalAmt.count > 1) ? (totalAmt.last ?? "") + " " + (totalAmt.first ?? " ") : ("AED" + " ") + (totalAmt.first ?? "")
            }
            totalPayableStr = payBal
            self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Total: ", payBal], setTintColor: .appWhite, setTitleColor: .appWhite)
        }
    }
    
    // State
       private var isTabbyInstallmentsAvailable = false {
           didSet {
               DispatchQueue.main.async {
//                   self.tabbyInstallmentsButton.isEnabled = self.isTabbyInstallmentsAvailable
//                   self.tabbyInstallmentsButton.backgroundColor = self.isTabbyInstallmentsAvailable ? .systemYellow : .systemGray5
               }
           }
       }
         
    private var sessionId: String?
    private var paymentId: String?
    private var availableProducts: [TabbyProductType] = []
    private var selectedPaymentMethod: Int?
    
    //MARK: ------------- IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var cardMBV: UIView!
    @IBOutlet weak var tabbyMBV: UIView!
    @IBOutlet weak var tamaraMBV: UIView!
    @IBOutlet weak var masterCardSelctionBtn: UIButton!
    @IBOutlet weak var tabbySelctionBtn: UIButton!
    @IBOutlet weak var tamaraSelctionBtn: UIButton!
    @IBOutlet weak var paymentBtn: UIButton!
    @IBOutlet weak var cardTitleLbl: UILabel!
    @IBOutlet weak var cardImgView: UIImageView!
    @IBOutlet weak var tabbyLbl: UILabel!
    @IBOutlet weak var tabbyImgView: UIImageView!
    @IBOutlet weak var tamaraLbl: UILabel!
    @IBOutlet weak var tamaraImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        self.enableContinueBtn(isSelected: false)
        self.cardMBV.isHidden = false
        self.tabbyMBV.isHidden = !isTesting
        self.tamaraMBV.isHidden = true
        self.selectPaymentMethod(sender: masterCardSelctionBtn) //Make to select default card
        
        self.paymentBtn.setTitle("PAY " + (totalPayableStr ?? ""), for: .normal)
        
        self.setupUI()
        self.setupFont()
        self.configureTabbySession()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavUI()
    }
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Total: " + (self.totalPayableStr ?? "")], setTintColor: .appWhite, setTitleColor: .appWhite)
        
        let helpIcon = UIImage(named: "ic_help_payment")?.resized(to: CGSize(width: 15.0, height: 15.0))?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.appWhite)
        
        let viewBillIcon = UIImage(named: "ic_viewAll_payment")?.resized(to: CGSize(width: 15.0, height: 15.0))?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor.appWhite)
        
        self.setRighMenu(rightImgs: [helpIcon,viewBillIcon], setTitle: ["Help ","View Bill"], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite, spacing: 2)
    }
    
    override func rightBtnActn(sender: UIButton) {
        if sender.tag == 1 {
            let vc: BillDetailsViewController = BillDetailsViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            vc.sessionCost = self.sessionCost
            vc.taxesStr = self.taxesStr
            vc.totalPayableStr = self.totalPayableStr
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    enum CardBtnTag: Int {
        case masterCard = 1101, tabby, tamara, payment
        
        var caseValueStr: String {
             switch self {
             case .masterCard: return "MasterCard"
             case .tabby:      return "Tabby"
             case .tamara:     return "Tamara"
             case .payment:    return "Payment"
             }
         }
    }
    
    @IBAction func cardSelectionCommonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case CardBtnTag.masterCard.rawValue:
            print("master card")
            self.selectPaymentMethod(sender: masterCardSelctionBtn)
           
            break
        case CardBtnTag.tabby.rawValue:
            print("tabby")
            self.selectPaymentMethod(sender: tabbySelctionBtn)
            
            break
        case CardBtnTag.tamara.rawValue:
            print("Tamara")
            self.selectPaymentMethod(sender: tamaraSelctionBtn)
            break
        case CardBtnTag.payment.rawValue:
            print("payment..")
            if let paymentTag = self.selectedPaymentMethod {
                self.selectPaymentMethod(tag: paymentTag)
            }
            
        default:
            break
        }
    }
    
    private func selectPaymentMethod(tag: Int){
        if let buttonTag = CardBtnTag(rawValue:tag) {
            switch buttonTag {
            case .masterCard:
                print("MasterCard tapped")
                self.paymentSuccess?(true,"","ccavenue")
                //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //                self.paymentSuccess?(true,"","ccavenue")
                //            }
            case .tabby:
                print("Tabby tapped")
                self.makeTabbyPaymnet()
            case .tamara:
                print("Tamara tapped")
            case .payment:
                print("Payment tapped")
            }
        }
    }
    
    private func selectPaymentMethod(sender: UIButton){
    
        [
            masterCardSelctionBtn,
            tabbySelctionBtn,
            tamaraSelctionBtn
        ].forEach({ [weak self] btn in
            
            guard let _ = self, let btn = btn else { return }
            
            if btn.tag == sender.tag {
                self?.selectedPaymentMethod = sender.tag
                btn.setImage(AppImages.filterChecked, for: .normal)
                self?.enableContinueBtn(isSelected: true)
            }else{
                btn.setImage(AppImages.filterUncheck, for: .normal)
            }
        })
    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.paymentBtn.isUserInteractionEnabled = true
            self.paymentBtn.backgroundColor = UIColor.appWhite
            self.paymentBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.paymentBtn.setImage(AppImages.arrow_right_black, for: .normal)
        } else {
            self.paymentBtn.isUserInteractionEnabled = false
            self.paymentBtn.backgroundColor = UIColor.appDarkGray
            self.paymentBtn.setTitleColor(UIColor.appWhite, for: .normal)
            self.paymentBtn.setImage(AppImages.arrow_rightWhite, for: .normal)
        }
    }
    
    private func setupUI(){
        self.cardImgView.loadGif(name: "Cards")
        
        DispatchQueue.main.async {
            [
                self.cardMBV,
                self.tabbyMBV,
                self.tamaraMBV,
                self.paymentBtn
            ].forEach({[weak self] in
                
                guard self != nil else {
                    return
                }
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
        }
    }
    
    private func setupFont(){
        
        [
            topTitleLbl,
            tabbyLbl,
            tamaraLbl,
            cardTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
        
        paymentBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
}


//MARK: ----------------CCAVENUE PAYMENT
extension PaymentMethodsViewController{
    //https://mobileapp.mypt-me.com/api/pay?amount=2
//    if let pricePackage = self.slotsData?.price {
//        let components = pricePackage.split(separator: " ")
//        let vc: CCAvenuePaymentViewController = CCAvenuePaymentViewController.instantiate(appStoryboard: .booking)
//        vc.modalPresentationStyle = .overFullScreen
//        vc.costAmt =  Double(components.first ?? "0.0")
//        
//        vc.paymentSuccess = {[weak self] (getStatus, getTransactionId) in
//            guard let self = self, let getTransactionId = getTransactionId  else { return  }
//            inputBookSlotParams?.transaction_id = getTransactionId
//            
//            print("Slot booking params: ",inputBookSlotParams?.getParams() ?? [:])
//            if let slotId = inputBookSlotParams?.slot_id, !slotId.isEmpty {
//                self.bookSlot(inputParam: inputBookSlotParams?.getParams() ?? [:])
//            }else{
//                AlertHelper.shared.alertMesssage(view: self, title: "", message: "Please select slot")
//            }
//        }
//        self.navigationController?.present(vc, animated: true)
//    }
}

//MARK: --------------- TABBY PAYMENT
extension PaymentMethodsViewController{
    
    private func configureTabbySession() {
        let min: UInt64 = 1_000_000_000
        let max: UInt64 = 9_999_999_999
        let randomNumber = UInt64.random(in: min...max)
        
        /*
         email: "successful.payment@tabby.ai",
         phone: "500000001",
         name: "Yazan Khalid",
         */
               
        let makePayAmtStr = (totalPayableStr ?? "0.0").filter { $0.isNumber || $0 == "." }
        let payAmt = Float(makePayAmtStr) ?? 0.0
        
        let todayDateStr = DateFormatterHelper.shared.getTodayDate(fromFormat: "yyyy-MM-dd HH:mm:ss zzz")
        
            // Your payment payload
            let customerPayment = Payment(
                amount: "\(payAmt)",
                currency: .AED,
                description: "",
                buyer: Buyer(
                    email: "otp.success@tabby.ai", //"successful.payment@tabby.ai",
                    phone: "+971500000001", //"500000001",
                    name: "", //"Yazan Khalid"
                    dob: nil
                ),
                buyer_history: BuyerHistory(
                    registered_since: todayDateStr,//"2019-08-24T14:15:22Z"
                    loyalty_level: 0
                ),
                order: Order(
                    reference_id: "#\(randomNumber)",
                    items: [
                        OrderItem(
                            description: "",
                            product_url: "https://tabby.store/p/SKU123",
                            quantity: 1,
                            reference_id: "SKU123",
                            title: "",
                            unit_price: "\(payAmt)",
                            category: ""
                        )
                    ],
                    shipping_amount: "",
                    tax_amount: self.taxesStr
                ),
                order_history: [
                    OrderHistory(
                        purchased_at: todayDateStr, //"2019-08-24T14:15:22Z"
                        amount: "",
                        status: .new,
                        shipping_address: ShippingAddress(
                            address: "",
                            city: "",
                            zip: ""
                        )
                    )
                ],
                shipping_address: ShippingAddress(
                    address: "",
                    city: "",
                    zip: ""
                )
            )

            let myTestPayment = TabbyCheckoutPayload(
                merchant_code: "ae",
                lang: .en,
                payment: customerPayment
            )

        TabbySDK.shared.setup(withApiKey: AppConstant.tabby_key) //Use with your public API Key

            TabbySDK.shared.configure(forPayment: myTestPayment) { [weak self] result in
                switch result {
                case .success(let sessionInfo):
                    print("SessionId: \(sessionInfo.sessionId)")
                    print("PaymentId: \(sessionInfo.paymentId)")
                    print("Available products: \(sessionInfo.tabbyProductTypes)")

                    self?.sessionId = sessionInfo.sessionId
                    self?.paymentId = sessionInfo.paymentId
                    self?.availableProducts = sessionInfo.tabbyProductTypes

                    self?.isTabbyInstallmentsAvailable = sessionInfo.tabbyProductTypes.contains(.installments)
                   
                case .failure(let error):
                    print("Tabby configure failed: \(error.localizedDescription)")
                    self?.isTabbyInstallmentsAvailable = false
                }
            }
        }
    
    private func makeTabbyPaymnet() {
        guard isTabbyInstallmentsAvailable, let _ = sessionId else {
            // You might want to show an alert here to the user instead of just printing
            print("Installments not available or sessionId missing")
            return
        }
        
        if #available(iOS 14.0, *) {
            let tabbyCheckoutView = TabbyCheckout(productType: .installments) { [weak self] result in
                guard let self = self else { return }
                
                print("Tabby checkout result: \(result)")
                self.dismiss(animated: true) {
                    switch result {
                    case .authorized:
                        print("✅ Payment authorized")
                    self.paymentSuccess?(true, self.paymentId, "tabby")
                        // TODO: maybe notify user or update UI here
                    case .rejected:
                        print("❌ Payment rejected")
                    case .close:
                        print("❌ Checkout closed")
                    case .expired:
                        print("⚠️ Session expired - reconfiguring")
                        self.configureTabbySession()
                    @unknown default:
                        print("❓ Unknown status")
                    }
                }
            }
            let hostingController = UIHostingController(rootView: tabbyCheckoutView)
            present(hostingController, animated: true)
            
        } else {
            // Fallback for iOS versions < 14
            let alert = UIAlertController(title: "Unsupported iOS Version",
                                          message: "Tabby checkout requires iOS 14 or later.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
