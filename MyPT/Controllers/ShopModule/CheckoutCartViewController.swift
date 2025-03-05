//
//  CheckoutCartViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/02/25.
//

import UIKit

class CheckoutCartViewController: CommonViewController {

    //MARK: ---------------------IBOUTLET
    @IBOutlet weak var itemsListTblView: UITableView!
    @IBOutlet weak var itemsListTblViewHeighConstrnt: NSLayoutConstraint!
    @IBOutlet weak var viewCouponsMBV: UIView!
    @IBOutlet weak var orderDetailsMStackV: UIStackView!
    @IBOutlet weak var orderDetailsMBV: UIView!
    @IBOutlet weak var totalOrderMBV: UIView!
    @IBOutlet weak var totalSavingOrderMBV: UIView!
    @IBOutlet weak var deliveryFeesMBV: UIView!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var amountPayableMBV: UIView!
    @IBOutlet weak var bottomPriceMBV: UIView!
    @IBOutlet weak var viewCouponBtn: UIButton!
    @IBOutlet weak var addAddressBtn: UIButton!
    @IBOutlet weak var itemsCartLbl: UILabel!
    @IBOutlet weak var orderDetailsLbl: UILabel!
    @IBOutlet weak var totalOrderTitleLbl: UILabel!
    @IBOutlet weak var totalOrderAmtLbl: UILabel!
    @IBOutlet weak var totalSavingsTitleLbl: UILabel!
    @IBOutlet weak var totalSavingsAmtLbl: UILabel!
    @IBOutlet weak var deliveryFeesTitleLbl: UILabel!
    @IBOutlet weak var deliveryFeesAmtLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var amountPayableTitleLbl: UILabel!
    @IBOutlet weak var payableamountLbl: UILabel!
    @IBOutlet weak var totalCartAmountLbl: UILabel!
    @IBOutlet weak var viewBreakdownLbl: UILabel!
    
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
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.cart], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: UIColor.black, setTitleColor: UIColor.black)
    }
    
    @IBAction func viewCouponBtnActn(_ sender: Any) {
        print("view coupon btn clicked.")
    }
    
    @IBAction func addAdressBtnActn(_ sender: Any) {
        print("Add addrs btn clicked.")
        let vc: AddAddressViewController = AddAddressViewController.instantiate(appStoryboard: .shop)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func setupUI(){
        
        self.itemsListTblView.register(UINib(nibName: "CartTableViewCell", bundle: nil), forCellReuseIdentifier: "CartTableViewCell")
        
        DispatchQueue.main.async {
            self.viewCouponsMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.mainBg, shadowRadius: 4.0, opacity: 1.0, offset: .zero, cornerRadius: 12.0)
            self.orderDetailsMStackV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.mainBg, shadowRadius: 4.0, opacity: 1.0, offset: .zero, cornerRadius: 12.0)
            self.bottomPriceMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.mainBg, shadowRadius: 4.0, opacity: 1.0, offset: .zero, cornerRadius: 0)
            
            self.addAddressBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
          
            self.lineLbl.addDashedLine(strokeColor: UIColor.txtDarkGray, lineWidth: 1.0, dashPattern: [6,3])
        }
    }
    
    func setupFont(){
        self.viewCouponBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope) 
        self.orderDetailsLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        
        [
            self.addAddressBtn.titleLabel,
            self.itemsCartLbl,
            self.totalOrderTitleLbl,
            self.totalOrderAmtLbl,
            self.totalSavingsTitleLbl,
            self.totalSavingsAmtLbl,
            self.deliveryFeesTitleLbl,
            self.deliveryFeesAmtLbl,
            self.amountPayableTitleLbl,
            self.payableamountLbl,
            self.viewBreakdownLbl
        ].forEach({
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.bold.size(32.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.regular.size(14.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "360",
            NSAttributedString(string: "AED",
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.totalCartAmountLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if itemsListTblView.contentSize.height != 0 {
            self.itemsListTblViewHeighConstrnt.constant = itemsListTblView.contentSize.height
        }
        view.layoutIfNeeded()
    }

}

//MARK: -----------------------UITABLEVIEW DELEGATE/DATASOURCE
extension CheckoutCartViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CartTableViewCell = itemsListTblView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}
