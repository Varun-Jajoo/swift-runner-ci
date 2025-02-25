//
//  CouponsOffersViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/12/24.
//

import UIKit

class CouponsOffersViewController: CommonViewController {

    //MARK: --------------VARIABLE
    var selectedIndx:IndexPath = IndexPath(row: -1, section: 0)
    var sentBackCoupon:((String) -> Void)?
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var checkCouponMBV: UIView!
    @IBOutlet weak var chechCouponTxtField: UITextField!
    @IBOutlet weak var checkCouponBtn: UIButton!
    @IBOutlet weak var couponListTbl: UITableView!
    @IBOutlet weak var bottomPriceMBV: UIView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var maxSavingsLbl: UILabel!
    @IBOutlet weak var applyBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setUpFont()
        
        couponListTbl.register(UINib(nibName: "CouponsOffersTableViewCell", bundle: nil), forCellReuseIdentifier: "CouponsOffersTableViewCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.coupons_Offers], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
     
    //------------------************Font
    func setUpFont(){

        self.chechCouponTxtField.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.checkCouponBtn.titleLabel?.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.applyBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
        self.maxSavingsLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
        
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
        
        self.amountLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            
            self.chechCouponTxtField.placeholderSet(placeHolder: "Enter coupon code", color: UIColor.txtDarkGray)
            
            self.checkCouponMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.bottomPriceMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.applyBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    

    @IBAction func checkCouponBtnActn(_ sender: UIButton){
        print("check coupon btn clicked")
    }

    @IBAction func applyBtnActn(_ sender: UIButton){
        print("apply btn clicked")
        self.sentBackCoupon?("coupon")
        self.navigationController?.popViewController(animated: false)
    }

}


extension CouponsOffersViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CouponsOffersTableViewCell = couponListTbl.dequeueReusableCell(withIdentifier: "CouponsOffersTableViewCell", for: indexPath) as! CouponsOffersTableViewCell
        cell.checkBtn.tag = indexPath.row
        cell.checkBtn.addTarget(self, action: #selector(checkMarkActn(sender: )), for: .touchUpInside)
        
        if selectedIndx.row == indexPath.row {
            cell.checkBtn.isSelected = true
        }else{
            cell.checkBtn.isSelected = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected cell index", indexPath.row)
        selectedIndx = indexPath
        tableView.reloadData()
//        let cell:CouponsOffersTableViewCell = tableView.cellForRow(at: indexPath) as! CouponsOffersTableViewCell

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        print("Deselected cell index", indexPath.row)
//        let cell:CouponsOffersTableViewCell = tableView.cellForRow(at: indexPath) as! CouponsOffersTableViewCell

    }
    
    @objc func checkMarkActn(sender:UIButton){
        let row = sender.tag
        selectedIndx.row = row
        couponListTbl.reloadData()
        
    
        //        guard let indexPathGet = couponListTbl.indexPathForRow(at: sender.convert(sender.frame.origin, to: couponListTbl)) else {
        //            print("Error: indexPath)")
        //            return
        //        }
        //
        //        let point : CGPoint = (sender as AnyObject).convert(CGPoint.zero, to:couponListTbl)
        //        var indexPath =  self.couponListTbl!.indexPathForRow(at: point)
        //        if let btnlike = sender as? UIButton{
        //            if btnlike.isSelected{
        //                btnlike.isSelected = false
        //            }else{
        //                btnlike.isSelected = true
        //            }
    }
    
}
