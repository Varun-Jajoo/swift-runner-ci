//
//  MyOrderStatusViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/03/25.
//

import UIKit

class MyOrderStatusViewController: CommonViewController {

    //MARK: ---------------VARIABLE
    private let orderStatuses = [
          "Confirmed",
          "Packed",
          "Shipped",
          "Out for Delivery",
          "Delivery by 31 Aug, 2024"
      ]
    
    private let currentStep = 0
    
//MARK: --------------------IBOULET
    @IBOutlet weak var productsMBV: UIView!
    @IBOutlet weak var deliveryStatusMBV: UIView!
    @IBOutlet weak var deliveryAddrMBVMBV: UIView!
    @IBOutlet weak var amountPayableMBV: UIView!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var orderStatusTblView: UITableView!
    @IBOutlet weak var orderStatusTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var productsTblView: UITableView!
    @IBOutlet weak var productsTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var homeDeliveryTitleLbl: UILabel!
    @IBOutlet weak var addrLbl: UILabel!
    @IBOutlet weak var payableAmtTitleLbl: UILabel!
    @IBOutlet weak var totalTitleLbl: UILabel!
    @IBOutlet weak var totalAmtLbl: UILabel!
    @IBOutlet weak var totalSavingTitleLbl: UILabel!
    @IBOutlet weak var totalSavingAmtLbl: UILabel!
    @IBOutlet weak var deliveryFeesTitleLbl: UILabel!
    @IBOutlet weak var deliveryFeesAmtLbl: UILabel!
    @IBOutlet weak var aggriegateAmtTitleLbl: UILabel!
    @IBOutlet weak var aggriegateAmtLbl: UILabel!
    @IBOutlet weak var editAddrBtn: UIButton!
    @IBOutlet weak var payableAmtBtn: UIButton!
    @IBOutlet weak var cancelProductBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.payableAmtBtn.isSelected = true
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.my_orders], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: UIColor.black, setTitleColor: UIColor.black)
    }
    
    override func leftBtnActn(sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: ProductsViewController.self, animated: true)
    }
    
    
    @IBAction func editAddrBtnActn(_ sender: Any) {
        print("Edit address clicked...")
    }
    
    @IBAction func cancelProductBtnActn(_ sender: Any) {
        let vc: ProductCancelPopupViewController = ProductCancelPopupViewController.instantiate(appStoryboard: .shop)
        vc.navCntrl = self.navigationController
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(vc, animated: true)
    }
    
    
    private func setupUI(){
        self.orderStatusTblView.register(OrderStatusCell.self, forCellReuseIdentifier: "OrderStatusCell")
        
        self.productsTblView.register(UINib(nibName: "MyOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "MyOrderTableViewCell")
        
        DispatchQueue.main.async {
           [
            self.productsMBV,
            self.deliveryStatusMBV,
            self.deliveryAddrMBVMBV,
            self.amountPayableMBV
           ].forEach({
               $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
           })

            self.lineMBV.addDashedLine(strokeColor: UIColor.txtDarkGray, lineWidth: 1.0, dashPattern: [6,3])
            self.cancelProductBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.editAddrBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.editAddrBtn.frame.height/2.0)
        }
    }
    
    private func setupFont(){
        self.homeDeliveryTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.addrLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.payableAmtTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.payableAmtBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        [
            self.totalTitleLbl,
            self.totalAmtLbl,
            self.totalSavingTitleLbl,
            self.totalSavingAmtLbl,
            self.deliveryFeesTitleLbl,
            self.deliveryFeesAmtLbl,
            self.aggriegateAmtTitleLbl,
            self.aggriegateAmtLbl
        ].forEach({
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.productsTblView.contentSize.height != 0 {
            self.productsTblViewHeightConstrnt.constant = self.productsTblView.contentSize.height
        }
        
        if self.orderStatusTblView.contentSize.height != 0 {
            self.orderStatusTblViewHeightConstrnt.constant = self.orderStatusTblView.contentSize.height
        }
        
        view.layoutIfNeeded()
    }
}

extension MyOrderStatusViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == productsTblView {
            return 1
        }else{
            return orderStatuses.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if tableView == productsTblView {
            let cell: MyOrderTableViewCell = productsTblView.dequeueReusableCell(withIdentifier: "MyOrderTableViewCell", for: indexPath) as! MyOrderTableViewCell
            
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusCell", for: indexPath) as? OrderStatusCell else {
                   return UITableViewCell()
               }
            cell.selectionStyle = .none
               let isActive = indexPath.row <= currentStep
               let isLast = indexPath.row == orderStatuses.count - 1
               cell.configure(with: orderStatuses[indexPath.row], isActive: isActive, isLast: isLast)
            cell.backgroundColor = .clear
            
               return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
        
    }
    
}

