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
            self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [self.totalPayableStr ?? ""], setTintColor: .appWhite, setTitleColor: .appWhite)
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
               
        self.cardMBV.isHidden = false
        self.tamaraMBV.isHidden = true
        self.paymentBtn.setTitle(self.totalPayableStr, for: .normal)
        
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [self.totalPayableStr ?? ""], setTintColor: .appWhite, setTitleColor: .appWhite)
        
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
    
    enum cardBtnTag: Int {
        case masterCard = 1101, tabby, tamara, payment
    }
    
    @IBAction func cardSelectionCommonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case cardBtnTag.masterCard.rawValue:
            print("master card")
            self.selectPaymentMethod(sender: masterCardSelctionBtn)
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.paymentSuccess?(true,"","ccavenue")
            }
            
            break
        case cardBtnTag.tabby.rawValue:
            print("tabby")
            self.selectPaymentMethod(sender: tabbySelctionBtn)
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.makeTabbyPaymnet()
            }
            
            break
        case cardBtnTag.tamara.rawValue:
            print("Tamara")
            self.selectPaymentMethod(sender: tamaraSelctionBtn)
            break
        case cardBtnTag.payment.rawValue:
            print("payment..")
        default:
            break
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
                btn.setImage(AppImages.filterChecked, for: .normal)
            }else{
                btn.setImage(AppImages.filterUncheck, for: .normal)
            }
        })
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
        
        /*
         email: "successful.payment@tabby.ai",
         phone: "500000001",
         name: "Yazan Khalid",
         */
            // Your payment payload
            let customerPayment = Payment(
                amount: "1",
                currency: .AED,
                description: "tabby Store Order #3",
                buyer: Buyer(
                    email: "otp.success@tabby.ai", //"successful.payment@tabby.ai",
                    phone: "+971500000001", //"500000001",
                    name: "Yazan Khalid",
                    dob: nil
                ),
                buyer_history: BuyerHistory(
                    registered_since: "2019-08-24T14:15:22Z",
                    loyalty_level: 0
                ),
                order: Order(
                    reference_id: "#xxxx-xxxxxx-xxxx",
                    items: [
                        OrderItem(
                            description: "Jersey",
                            product_url: "https://tabby.store/p/SKU123",
                            quantity: 1,
                            reference_id: "SKU123",
                            title: "Pink jersey",
                            unit_price: "300",
                            category: "Clothes"
                        )
                    ],
                    shipping_amount: "50",
                    tax_amount: "100"
                ),
                order_history: [
                    OrderHistory(
                        purchased_at: "2019-08-24T14:15:22Z",
                        amount: "10",
                        status: .new,
                        shipping_address: ShippingAddress(
                            address: "Sample Address #2",
                            city: "Dubai",
                            zip: "01234"
                        )
                    )
                ],
                shipping_address: ShippingAddress(
                    address: "Sample Address #2",
                    city: "Dubai",
                    zip: "01234"
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
