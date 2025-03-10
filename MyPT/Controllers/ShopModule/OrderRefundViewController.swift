//
//  OrderRefundViewController.swift
//  MyPT
//
//  Created by techsaga corp on 07/03/25.
//

import UIKit
import IQTextView

class OrderRefundViewController: CommonViewController {

    //MARK: -------------VARIABLE
    var  returnReasonData:[String]?
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var productLstTblView: UITableView!
    @IBOutlet weak var reaseonReturnTblView: UITableView!
    @IBOutlet weak var eligibleReturnMBV: UIView!
    @IBOutlet weak var reaseonReturnTitleLbl: UILabel!
    @IBOutlet weak var tellusTitleLbl: UILabel!
    @IBOutlet weak var tellusTxtView: IQTextView!
    @IBOutlet weak var eligibleReturnBtn: UIButton!
    @IBOutlet weak var eligibleReturnOuterBtn: UIButton!
    @IBOutlet weak var viewPolicyBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var productLstTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var reaseonReturnTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableContinueBtn(isSelected: false, btn: self.nextBtn)
        self.setupUI()
        self.setupFont()
        
        self.returnReasonData = [
            "Frame size doesn’t fit properly",
            "Product received is damaged or defective.",
            "Wrong item shipped",
            "Changed My Mind"
        ]
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
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: UIColor.black, setTitleColor: UIColor.black)
    }
    
    @IBAction func viewPolicyBtnActn(_ sender: Any) {
        print("view policy btn clicked.....")
    }
    
    
    @IBAction func nextBtnActn(_ sender: Any) {
        print("next btn clicked..")
        let vc: OrderRefundDetailsViewController = OrderRefundDetailsViewController.instantiate(appStoryboard: .shop)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupUI(){
        
        self.productLstTblView.register(UINib(nibName: "MyOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "MyOrderTableViewCell")
        self.reaseonReturnTblView.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
        
        DispatchQueue.main.async {
            self.nextBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.tellusTxtView.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.txtDarkGray, cornerRadious: 8.0)
            self.tellusTxtView.contentInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
            self.eligibleReturnBtn.titleLabel?.textColor = UIColor.appOuterProgress.withAlphaComponent(0.7)
           
            self.eligibleReturnMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appOuterProgress.withAlphaComponent(0.8), cornerRadious: 12.0)
            self.eligibleReturnOuterBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.eligibleReturnOuterBtn.backgroundColor = UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 0.3)
            
//            self.eligibleReturnBtn.titleLabel?.applyGradientWith(startColor: UIColor.appWhite, endColor: UIColor.appOuterProgress)
            
        }
        
//        self.tellusTxtView.attributedPlaceholder = NSAttributedString(
//            string: "Type here",
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor.txtDarkGray]
//        )
        
//        self.tellusTxtView.placeholder = "Type here"
                
        // ✅ Change the placeholder color
//        self.tellusTxtView.placeholderTextColor = UIColor.red
        
    }
    
    private func setupFont(){
        
        self.tellusTxtView.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.viewPolicyBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.eligibleReturnBtn.titleLabel?.font = AppFont.semibold.size(13.0, familyName: familyManrope)
        self.nextBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        [
            self.reaseonReturnTitleLbl,
            self.tellusTitleLbl
        ].forEach({
            $0?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        })
        
        self.eligibleReturnBtn.titleLabel?.numberOfLines = 2
        self.viewPolicyBtn.titleLabel?.numberOfLines = 2
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.productLstTblView.contentSize.height != 0 {
            self.productLstTblViewHeightConstrnt.constant = self.productLstTblView.contentSize.height
        }
        
        if self.reaseonReturnTblView.contentSize.height != 0 {
            self.reaseonReturnTblViewHeightConstrnt.constant = self.reaseonReturnTblView.contentSize.height
        }
        
        view.layoutIfNeeded()
    }
}

//MARK: ------------------------UITABLEVIEW DELEGATE/DATASOURCE
extension OrderRefundViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == productLstTblView {
            return 1
        }else{
            return returnReasonData?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == productLstTblView {
            let cell: MyOrderTableViewCell = productLstTblView.dequeueReusableCell(withIdentifier: "MyOrderTableViewCell", for: indexPath) as! MyOrderTableViewCell
            
            cell.stutusTitleLbl.isHidden = true
            cell.stutusTitleLbl.text = nil
            cell.estimatedDelDateLbl.text = "HandGripper - Green - 5kg to 60kg"
            cell.paymentModeLbl.text = "Quantity: 1"
            cell.orderIdLbl.text = "AED 750 AED 1150"
            
            return cell
        }else{
            let cell: PointsTableViewCell = reaseonReturnTblView.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
            
            cell.titleLbl.text = self.returnReasonData?[indexPath.row] as? String
            cell.leftImgView.image = UIImage(named: "ic_filterUncheck")
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == reaseonReturnTblView {
            let selectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
            selectedCell.leftImgView.image = UIImage(named: "ic_filterChecked")
            
            self.enableContinueBtn(isSelected: true, btn: self.nextBtn)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if tableView == reaseonReturnTblView {
            let deselectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
            deselectedCell.leftImgView.image = UIImage(named: "ic_filterUncheck")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false, btn:UIButton){
        if isSelected {
            btn.isUserInteractionEnabled = true
            btn.backgroundColor = UIColor.appWhite
            btn.setTitleColor(UIColor.mainBg, for: .normal)
            btn.setImage(AppImages.arrow_right_black, for: .normal)
        } else {
            btn.isUserInteractionEnabled = false
            btn.backgroundColor = UIColor.appDarkGray
            btn.setTitleColor(UIColor.appWhite, for: .normal)
            btn.setImage(AppImages.arrow_rightWhite, for: .normal)
            
        }
    }
}
