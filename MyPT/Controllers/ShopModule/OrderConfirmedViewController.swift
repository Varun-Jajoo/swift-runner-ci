//
//  OrderConfirmedViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/03/25.
//

import UIKit

enum ProductOrderStatusFlow {
    case placeOrder
    case cancelOrder
    case defaultOrder
}

class OrderConfirmedViewController: UIViewController {
    
    //MARK: ----------------VARIABLE
    var flowOrder:ProductOrderStatusFlow = .defaultOrder
    
    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var confirmationMBV: UIView!
    @IBOutlet weak var expectedDeliveryMBV: UIView!
    @IBOutlet weak var deliveryAddrMBV: UIView!
    @IBOutlet weak var refundDetailsMBV: UIView!
//    @IBOutlet weak var termsConditionsMBV: UIView!
    @IBOutlet weak var checkImgView: UIImageView!
    @IBOutlet weak var orderConfirmLbl: UILabel!
    @IBOutlet weak var orderIdLbl: UILabel!
    @IBOutlet weak var expectedDelivertyLbl: UILabel!
    @IBOutlet weak var homeDeliveryLbl: UILabel!
    @IBOutlet weak var deliveryAddrLbl: UILabel!
    @IBOutlet weak var refundDetailsTitleLbl: UILabel!
    @IBOutlet weak var originalPaymentModeLbl: UILabel!
    @IBOutlet weak var lineVLbl: UILabel!
    @IBOutlet weak var refundAmtLbl: UILabel!
//    @IBOutlet weak var termsNconditionLbl: UILabel!
    @IBOutlet weak var refundDurationBtn: UIButton!
    @IBOutlet weak var trackOrderBtn: UIButton!
    @IBOutlet weak var productsTblview: UITableView!
    @IBOutlet weak var productsTblviewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var orderConfirmLblTopConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.trackOrderBtn.isUserInteractionEnabled = false
        self.setupUI()
        self.setupFont()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func trackOrderBtnActn(_ sender: UIButton) {
        print("Track btn clicked.")
        
        if sender.accessibilityHint?.uppercased() == "Track Order".uppercased() {
            let vc: OrderHistoryViewController = OrderHistoryViewController.instantiate(appStoryboard: .shop)
            vc.orderList = [1]
            self.navigationController?.pushViewController(vc, animated: true)
        }else if sender.accessibilityHint?.uppercased() == "refund order".uppercased() {
            let vc: ReturnRequestViewController = ReturnRequestViewController.instantiate(appStoryboard: .shop)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        else{
            self.navigationController?.popToViewController(ofClass: ProductsViewController.self, animated: true)
        }
    }
    
    private func flowSetupOrder(){
        switch flowOrder {
        case .placeOrder:
            //--------------*********  Animation view
            self.confirmationMBV.backgroundColor = UIColor.clear
            self.confirmationMBV.isHidden = false
            self.expectedDeliveryMBV.isHidden = true
            self.deliveryAddrMBV.isHidden = true
            self.refundDetailsMBV.isHidden = true
            self.orderConfirmLbl.isHidden = true
            self.orderIdLbl.isHidden = true
            
            self.animateConfirmation()
            self.trackOrderBtn.isUserInteractionEnabled = false
            self.trackOrderBtn.accessibilityHint = "Track Order"
            self.trackOrderBtn.setTitle("TRACK ORDER", for: .normal)
            
            
        case .cancelOrder:
            //--------------*********
            self.confirmationMBV.backgroundColor = UIColor.appCard2
            self.confirmationMBV.isHidden = false
            self.expectedDeliveryMBV.isHidden = false
            self.deliveryAddrMBV.isHidden = true
            self.refundDetailsMBV.isHidden = false
            self.orderConfirmLbl.isHidden = false
            self.orderIdLbl.isHidden = false
            
            self.checkImgView.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)
            self.orderConfirmLblTopConstrnt.constant = -20
            
            self.orderConfirmLbl.text = "Order Cancelled"
            self.trackOrderBtn.isUserInteractionEnabled = true
            self.trackOrderBtn.accessibilityHint = "order cancel"
            self.trackOrderBtn.setTitle("BACK TO HOME", for: .normal)
            
        case .defaultOrder:
            print("none......")
        }
    }
    
    private func setupUI(){
        self.productsTblview.register(UINib(nibName: "MyOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "MyOrderTableViewCell")
        
        DispatchQueue.main.async {
            [
                self.confirmationMBV,
                self.expectedDeliveryMBV,
                self.deliveryAddrMBV,
                self.refundDetailsMBV,
                self.trackOrderBtn
            ].forEach({
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
        }
        
        self.flowSetupOrder()
        
        /*
        //--------------*********  Animation view
        self.confirmationMBV.backgroundColor = UIColor.clear
        self.confirmationMBV.isHidden = false
        self.expectedDeliveryMBV.isHidden = true
        self.deliveryAddrMBV.isHidden = true
        self.refundDetailsMBV.isHidden = true
        self.orderConfirmLbl.isHidden = true
        self.orderIdLbl.isHidden = true
        
        self.animateConfirmation()
        */
        
    }
    
    private func animateConfirmation() {
        //---------------------Image size reduce animated.
        UIView.animate(withDuration: 1) {
            self.checkImgView.transform = CGAffineTransform(scaleX: 0.50, y: 0.50)
            self.orderConfirmLblTopConstrnt.constant = -20
        }
        
        self.confirmationMBV.applyTransition(duration: 1.2) { [weak self] in
            guard let self = self else { return }
            
            self.animateView(self.orderConfirmLbl, duration: 0.2, delay: 0.0) {
                self.animateView(self.orderIdLbl, duration: 0.2, delay: 0.0) {
                    self.confirmationMBV.backgroundColor = UIColor.appCard2
                }
            }
            
            self.animateView(self.expectedDeliveryMBV, duration: 0.8, delay: 0.1) {
                self.animateView(self.deliveryAddrMBV, duration: 0.4, delay: 0.0){
                    self.trackOrderBtn.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    private func animateView(_ view: UIView, duration: CFTimeInterval, delay: CFTimeInterval = 0, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak view] in
            guard let view = view else { return }
            view.isHidden = false
            view.applyTransition(duration: duration, completion: completion)
        }
    }
    
    
    private func setupFont(){
        self.orderConfirmLbl.font = AppFont.semibold.size(32.0, familyName: familyClashDisplay)
        self.orderIdLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.expectedDelivertyLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.homeDeliveryLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.deliveryAddrLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.trackOrderBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.refundDetailsTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.originalPaymentModeLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.refundAmtLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.refundDurationBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.productsTblview.contentSize.height != 0 {
            self.productsTblviewHeightConstrnt.constant = self.productsTblview.contentSize.height
        }
        view.layoutIfNeeded()
    }
}

//MARK: -------------UITABLEVIEW DELEGATE/ DATASOURCE
extension OrderConfirmedViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyOrderTableViewCell = self.productsTblview.dequeueReusableCell(withIdentifier: "MyOrderTableViewCell", for: indexPath) as! MyOrderTableViewCell
        
        cell.orderIdLbl.isHidden = true
        
        cell.stutusTitleLbl.text = "30th Aug"
        cell.estimatedDelDateLbl.text = "HandGripper - Green - 5kg to 60kg"
        cell.paymentModeLbl.text = "Quantity: 1"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}
