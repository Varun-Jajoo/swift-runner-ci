//
//  ReviewInformationViewController.swift
//  MyPT
//
//  Created by techsaga corp on 04/03/25.
//

import UIKit

class ReviewInformationViewController: CommonViewController {

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var deliveryAddrMBV: UIView!
    @IBOutlet weak var expectedDeliveryMBV: UIView!
    @IBOutlet weak var amountPayableMBV: UIView!
    @IBOutlet weak var paymentOptionsMBV: UIView!
    @IBOutlet weak var lineMBV: UIView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.expectedDateBtn.isSelected = true
        self.amtPayableBtn.isSelected = true
        
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
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: UIColor.black, setTitleColor: UIColor.black)
    }
    
    private func setupUI(){
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
