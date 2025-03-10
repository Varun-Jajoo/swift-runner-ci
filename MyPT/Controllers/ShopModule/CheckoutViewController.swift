//
//  ReviewInformationViewController.swift
//  MyPT
//
//  Created by techsaga corp on 04/03/25.
//

import UIKit

class CheckoutViewController: CommonViewController {

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var deliveryAddrMBV: UIView!
    @IBOutlet weak var expectedDeliveryMBV: UIView!
    @IBOutlet weak var amountPayableMBV: UIView!
    @IBOutlet weak var paymentOptionsMBV: UIView!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var extrachargedMBV: UIView!
    @IBOutlet weak var placeOrderMBV: UIView!
    @IBOutlet weak var extraChargedTitleLbl: UILabel!
    @IBOutlet weak var homeDeliveryTitleLbl: UILabel!
    @IBOutlet weak var deliveryAddrLbl: UILabel!
    @IBOutlet weak var expectedDeliveryTitleLbl: UILabel!
    @IBOutlet weak var amtPayableTitleLbl: UILabel!
    @IBOutlet weak var totalTitleLbl: UILabel!
    @IBOutlet weak var totalAmtLbl: UILabel!
    @IBOutlet weak var totalSavingTitleLbl: UILabel!
    @IBOutlet weak var totalSavingAmtLbl: UILabel!
    @IBOutlet weak var deliveryFeesTitleLbl: UILabel!
    @IBOutlet weak var deliveryFeesAmtLbl: UILabel!
    @IBOutlet weak var totalAmtPayableTitleLbl: UILabel!
    @IBOutlet weak var totalAmtPayableAmtLbl: UILabel!
    @IBOutlet weak var paymentOptionsTitleLbl: UILabel!
    @IBOutlet weak var cardTitleLbl: UILabel!
    @IBOutlet weak var cardLineLbl: UILabel!
    @IBOutlet weak var walletTitleLbl: UILabel!
    @IBOutlet weak var walletLineLbl: UILabel!
    @IBOutlet weak var cashOnDeliveryLbl: UILabel!
    @IBOutlet weak var editAddrBtn: UIButton!
    @IBOutlet weak var expectedDateBtn: UIButton!
    @IBOutlet weak var amtPayableBtn: UIButton!
    @IBOutlet weak var addCardBtn: UIButton!
    @IBOutlet weak var walletBtn: UIButton!
    @IBOutlet weak var cashOnDeliveryBtn: UIButton!
    @IBOutlet weak var placeOrderBtn: UIButton!
    @IBOutlet weak var whatsThisBtn: UIButton!
    @IBOutlet weak var expectedDeliveryTblView: UITableView!
    @IBOutlet weak var expectedDeliveryTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.expectedDateBtn.isSelected = true
        self.amtPayableBtn.isSelected = true
        self.extrachargedMBV.isHidden = true
        self.placeOrderMBV.isHidden = true
        
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.checkout_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: UIColor.black, setTitleColor: UIColor.black)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if self.expectedDeliveryTblView.contentSize.height != 0 {
            self.expectedDeliveryTblViewHeightConstrnt.constant = self.expectedDeliveryTblView.contentSize.height
        }
        view.layoutIfNeeded()
    }
    
    enum BtnTag: Int {
    case placeOrder = 401, cashOnDelivery, whatsThis, wallet, addCard
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case BtnTag.placeOrder.rawValue:
            let vc: OrderConfirmedViewController = OrderConfirmedViewController.instantiate(appStoryboard: .shop)
            vc.flowOrder = .placeOrder
            self.navigationController?.pushViewController(vc, animated: true)
        case BtnTag.cashOnDelivery.rawValue:
            self.cashOnDeliveryBtn.isSelected = !self.cashOnDeliveryBtn.isSelected
            
            if self.cashOnDeliveryBtn.isSelected {
                self.cashOnDeliveryBtn.isSelected = true
                self.extrachargedMBV.isHidden = false
                self.placeOrderMBV.isHidden = false
                
                //---------------*************
                if let scrollView = self.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                    print("Found scroll view: \(scrollView)")
                    scrollView.setContentOffset(CGPoint(x: 0, y: max(0, scrollView.contentSize.height - scrollView.bounds.height + 150)), animated: true)
                }
            }else{
                self.cashOnDeliveryBtn.isSelected = false
                self.extrachargedMBV.isHidden = true
                self.placeOrderMBV.isHidden = true
            }
            
        default:
            print("none....")
        }
        
  
    }
    
    
    private func setupUI(){
        self.expectedDeliveryTblView.register(UINib(nibName: "CartTableViewCell", bundle: nil), forCellReuseIdentifier: "CartTableViewCell")
        
        DispatchQueue.main.async {
            self.editAddrBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.editAddrBtn.frame.height/2.0)
            //--------------------View
            [
                self.deliveryAddrMBV,
                self.expectedDeliveryMBV,
                self.amountPayableMBV,
                self.paymentOptionsMBV,
                self.placeOrderBtn
            ].forEach({
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
            
          
            //-------------------line
            [
                self.cardLineLbl,
                self.walletLineLbl
            ].forEach({
                $0?.backgroundColor = .clear
                $0?.addGradient(colors: UIColor.appMultiColor(.lineVGradient2), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            })
        
            
            self.lineMBV.addDashedLine(strokeColor: UIColor.txtDarkGray, lineWidth: 1.0, dashPattern: [6,3])
            
        }
    }
    
    private func setupFont(){
        //---------------------
        [
            self.homeDeliveryTitleLbl,
            self.expectedDeliveryTitleLbl,
            self.amtPayableTitleLbl,
            self.paymentOptionsTitleLbl
        ].forEach({
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
        
        //-------------
        [
         self.totalTitleLbl,
         self.totalAmtLbl,
         self.totalSavingTitleLbl,
         self.totalSavingAmtLbl,
         self.deliveryFeesTitleLbl,
         self.deliveryFeesAmtLbl,
         self.totalAmtPayableTitleLbl,
         self.totalAmtPayableAmtLbl,
         self.cardTitleLbl,
         self.walletTitleLbl,
         self.cashOnDeliveryLbl
        ].forEach({
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
         
        //-------------------------
        self.deliveryAddrLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        
        self.expectedDateBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.amtPayableBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.addCardBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.placeOrderBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
}

//MARK: ----------------------UITABLEVIEW DELEGATE/DATASOURCE
extension CheckoutViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CartTableViewCell = expectedDeliveryTblView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        cell.addBtn.isHidden = true
        cell.minusBtn.isHidden = true
        cell.itemsCount.isHidden = true
        
        cell.productPriceLbl.text = "Quantity: 1"
        cell.productPriceLbl.textColor = UIColor.txtDarkGray
        cell.productPriceLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}
