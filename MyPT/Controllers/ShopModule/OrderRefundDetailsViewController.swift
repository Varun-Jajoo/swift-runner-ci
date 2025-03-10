//
//  OrderRefundDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 10/03/25.
//

import UIKit

class OrderRefundDetailsViewController: CommonViewController {

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var productsMBV: UIView!
    @IBOutlet weak var deliveryAddrMBV: UIView!
    @IBOutlet weak var refundDetailsMBV: UIView!
    @IBOutlet weak var termsConditionsMBV: UIView!
    @IBOutlet weak var productsTblView: UITableView!
    @IBOutlet weak var pickupLocTitleLbl: UILabel!
    @IBOutlet weak var homeTitleLbl: UILabel!
    @IBOutlet weak var homeAddrLbl: UILabel!
    @IBOutlet weak var refundMethodTitleLbl: UILabel!
    @IBOutlet weak var paymentModeLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var refundAmtLbl: UILabel!
    @IBOutlet weak var termsConditionTitleLbl: UILabel!
    @IBOutlet weak var refundTimeBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var productsTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupFont()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.order_Refund], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    
    @IBAction func nextBtnActn(_ sender: Any) {
        print("next btn clicked.")
        let vc: ReturnRequestViewController = ReturnRequestViewController.instantiate(appStoryboard: .shop)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupUI(){
        
        self.productsTblView.register(UINib(nibName: "MyOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "MyOrderTableViewCell")
        
        DispatchQueue.main.async {
            self.productsMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.deliveryAddrMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.refundDetailsMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.txtDarkGray, cornerRadious: 7.0)
            self.nextBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        self.pickupLocTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.homeTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.homeAddrLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.refundMethodTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.paymentModeLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.refundAmtLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.termsConditionTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.refundTimeBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.nextBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if self.productsTblView.contentSize.height != 0 {
            self.productsTblViewHeightConstrnt.constant = self.productsTblView.contentSize.height
        }
        view.layoutIfNeeded()
    }
}


extension OrderRefundDetailsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyOrderTableViewCell = self.productsTblView.dequeueReusableCell(withIdentifier: "MyOrderTableViewCell", for: indexPath) as! MyOrderTableViewCell
        
//        cell.orderIdLbl.isHidden = true
        
//        cell.stutusTitleLbl.text = "30th Aug"
//        cell.estimatedDelDateLbl.text = "HandGripper - Green - 5kg to 60kg"
//        cell.paymentModeLbl.text = "Quantity: 1"
//        cell.orderIdLbl.text = "AED 750 AED 1150"
        
        cell.stutusTitleLbl.isHidden = true
        cell.stutusTitleLbl.text = nil
        cell.estimatedDelDateLbl.text = "HandGripper - Green - 5kg to 60kg"
        cell.paymentModeLbl.text = "Quantity: 1"
        cell.orderIdLbl.text = "AED 750 AED 1150"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}
