//
//  TopReviewPackageViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/07/25.
//

import UIKit

class TopReviewPackageViewController: CommonViewController {
    
    //MARK: --------------- VARIABLE
    var planFlow: ChoosePlanFlow = .choosePlanDefault
    var memberList:[MemberModel]? = []
    var reviewUpgradeDetails: ReviewUpgradePackageDetailModel?
    var paymentDetails: UpgradePaymentDetailModel?
    var packageDetailsData:[[String:Any]]?
    var inputType: String?
    var inputId: String?
    var inputPrice: String?
    var inputSessions: String?
    var inputDays: String?
    
    //MARK: --------------- IBOUTLET
    @IBOutlet weak var profileMBV: UIView!
    @IBOutlet weak var trainingPreferenceMBV: UIView!
    @IBOutlet weak var bookingSlotMBV: UIView!
    @IBOutlet weak var trainingPrefernceTitleLbl: UILabel!
    @IBOutlet weak var preferenceLbl: UILabel!
    @IBOutlet weak var bookingSlotTitleLbl: UILabel!
    @IBOutlet weak var bookingTimeBckView: UIView!
    @IBOutlet weak var bookingTimeLbl: UILabel!
    @IBOutlet weak var preferenceEditBtn: UIButton!
    @IBOutlet weak var bookingSlotEditBtn: UIButton!
    @IBOutlet weak var viewCouponStckView: UIStackView!
    @IBOutlet weak var renewCouponStckView: UIStackView!
    @IBOutlet weak var renewOffersMBV: UIView!
    @IBOutlet weak var renewOfferDetailsMBV: UIView!
    @IBOutlet weak var renewcouponOffersTitleBtn: UIButton!
    @IBOutlet weak var renewCouponEditBtn: UIButton!
    @IBOutlet weak var renewOfferDetailsSubMBV: UIView!
    @IBOutlet weak var renewOfferDeleteBtn: UIButton!
    @IBOutlet weak var renewCouponMBV: UIView!
    @IBOutlet weak var renewSavedLbl: UILabel!
    @IBOutlet weak var offersMBV: UIView!
    @IBOutlet weak var offerDetailsMBV: UIView!
    @IBOutlet weak var couponOffersTitleBtn: UIButton!
    @IBOutlet weak var offerDetailsSubMBV: UIView!
    @IBOutlet weak var couponMBV: UIView!
    @IBOutlet weak var renewCouponLbl: UILabel!
    @IBOutlet weak var couponLbl: UILabel!
    @IBOutlet weak var savedLbl: UILabel!
    @IBOutlet weak var couponEditBtn: UIButton!
    @IBOutlet weak var offerDeleteBtn: UIButton!
    @IBOutlet weak var packageDetailsMBV: UIView!
    @IBOutlet weak var packageDetailsTitleLbl: UILabel!
    @IBOutlet weak var packageDetails: UITableView!
    @IBOutlet weak var packageDetailsHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var traninerTblView: UITableView!
    @IBOutlet weak var memberMBV: UIView!
    @IBOutlet weak var membersTblView: UITableView!
    @IBOutlet weak var traninerTblViewHeightConstrt: NSLayoutConstraint!
    @IBOutlet weak var membersTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var paymentMBV: UIView!
    @IBOutlet weak var paymentBtn: UIButton!
    @IBOutlet weak var paymentAmountLbl: UILabel!
    @IBOutlet weak var viewBreakdownLbl: UILabel!
    @IBOutlet weak var addressMBV: UIView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var mobileNumnLbl: UILabel!
    @IBOutlet weak var membersTitleLbl: UILabel!
    @IBOutlet weak var addressTypeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.setupUI()
        self.setUpFont()
        self.offerDetailsMBV.isHidden = true
        self.offersMBV.isHidden = true
        self.setupFlow()
        self.topupUpgradeReviewApi()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.review_Package], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func viewBreakDownBtnActn(_ sender: Any) {
        print("View breakdown btn actn...")
    }
    
    @IBAction func paymentBtnActn(_ sender: Any) {
        if let pricePackage = self.reviewUpgradeDetails?.price?.value, let mainPrice = self.reviewUpgradeDetails?.main_price?.value, let taxesRate = self.reviewUpgradeDetails?.tax_price?.value {
            let vc: PaymentMethodsViewController = PaymentMethodsViewController.instantiate(appStoryboard: .booking)
            vc.totalPayableStr = pricePackage
            vc.taxesStr = "\(taxesRate)"
            vc.sessionCost = "\(mainPrice)"
            
            vc.paymentSuccess = {[weak self] (getStatus, getTransactionId, paymetMethod) in
                guard let self = self else { return  }
                
                if paymetMethod == "ccavenue" {
                    let vc: CCAvenuePaymentViewController = CCAvenuePaymentViewController.instantiate(appStoryboard: .booking)
                    vc.modalPresentationStyle = .overFullScreen
                    vc.costAmt =  Double(pricePackage)
                    
//                    vc.paymentSuccess = {[weak self] (getStatus, getTransactionId) in
//                        guard let self = self, let getTransactionId = getTransactionId  else { return  }
//                        
//                        self.paymentApi(transactionId: getTransactionId, paymentType: "ccavenue")
//                    }
                    self.navigationController?.present(vc, animated: true)
                }
                else if paymetMethod == "tabby" {
                    self.paymentApi(transactionId: getTransactionId, paymentType: "tabby")
                }
            }
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    private func registerCell(){
        self.packageDetails.register(UINib(nibName: "PackageDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "PackageDetailsTableViewCell")
        self.packageDetails.isUserInteractionEnabled = false
        self.traninerTblView.register(UINib(nibName: "ReviewProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewProfileTableViewCell")
        self.membersTblView.register(UINib(nibName: "AddMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "AddMemberTableViewCell")
    }
    
    private func setupFlow(){
        self.profileMBV.isHidden = true
        self.trainingPreferenceMBV.isHidden = true
        self.bookingSlotMBV.isHidden = true
        self.addressMBV.isHidden = true
        self.memberMBV.isHidden = true
        self.memberList?.removeAll()
        self.memberMBV.isHidden = true
        self.renewCouponStckView.isHidden = true
        self.renewOffersMBV.isHidden = true
        self.renewOfferDetailsMBV.isHidden = true
        self.packageDetailsMBV.isHidden = true
        self.offersMBV.isHidden = true
        self.offerDetailsMBV.isHidden = true
       
        switch planFlow {
        case .topUp:
            self.packageDetailsMBV.isHidden = false
            self.offersMBV.isHidden = false
            self.setpayableAmtAttr(priceStr: reviewUpgradeDetails?.price?.value)
            self.packageDetailsData = [
                ["title":"Current Package","desc": reviewUpgradeDetails?.currentPackage?.value ?? ""],
                ["title":"Current End Date","desc": reviewUpgradeDetails?.currentEndDate?.value ?? ""],
                ["title":"Training Preference","desc": reviewUpgradeDetails?.trainingPreference?.value ?? ""],
                ["title":"Topup Sessions","desc": reviewUpgradeDetails?.totalSessions?.value ?? ""],
                ["title":"Validity","desc": reviewUpgradeDetails?.validity?.value ?? ""]
            ]
            self.packageDetails.reloadData()
            
        case .upgrade:
            self.packageDetailsMBV.isHidden = false
            self.offersMBV.isHidden = false
            self.setpayableAmtAttr(priceStr: reviewUpgradeDetails?.price?.value)
            self.packageDetailsData = [
                ["title":"Current Package","desc": reviewUpgradeDetails?.currentPackage?.value ?? ""],
                ["title":"Current End Date","desc": reviewUpgradeDetails?.currentEndDate?.value ?? ""],
                ["title":"New Package Start","desc": reviewUpgradeDetails?.newPackageStart?.value ?? ""],
                ["title":"New Package End","desc": reviewUpgradeDetails?.newPackageEnd?.value ?? ""],
                ["title":"Training Preference","desc": reviewUpgradeDetails?.trainingPreference?.value ?? ""],
                ["title":"Total Sessions","desc": reviewUpgradeDetails?.totalSessions?.value ?? ""],
                ["title":"Validity","desc": reviewUpgradeDetails?.validity?.value ?? ""]
            ]
            self.packageDetails.reloadData()
            
        case .renew:
            self.renewCouponStckView.isHidden = false
            self.renewOffersMBV.isHidden = false
            self.renewOfferDetailsMBV.isHidden = true
            self.offersMBV.isHidden = true
            self.packageDetailsMBV.isHidden = false
            self.setpayableAmtAttr(priceStr: reviewUpgradeDetails?.price?.value)
            
            self.packageDetailsData = [
                ["title":"Current Package","desc": reviewUpgradeDetails?.currentPackage?.value ?? ""],
                ["title":"Current End Date","desc": reviewUpgradeDetails?.currentEndDate?.value ?? ""],
                ["title":"New Package Start","desc": reviewUpgradeDetails?.newPackageStart?.value ?? ""],
                ["title":"New Package End","desc": reviewUpgradeDetails?.newPackageEnd?.value ?? ""],
                ["title":"Training Preference","desc": reviewUpgradeDetails?.trainingPreference?.value ?? ""],
                ["title":"Total Sessions","desc": reviewUpgradeDetails?.totalSessions?.value ?? ""],
                ["title":"Validity","desc": reviewUpgradeDetails?.validity?.value ?? ""]
            ]
            self.packageDetails.reloadData()
            
        case .choosePlanDefault, .gymWorkoutPlan, .homeWorkoutPlan:
            print("choosePlanDefault")
            self.packageDetailsMBV.isHidden = false
            self.offersMBV.isHidden = false
        }
    }
    
    private func setpayableAmtAttr(priceStr: String?){
        //-------------------- Attributed Text for Price
        let getAmount:String = priceStr ?? ""
        let currencyStr:String = "AED"
//        if let pricePackage = packagecheckoutData?.packageDetail?.price {
//            let components = pricePackage.split(separator: " ")
//            getAmount = "\(components.first ?? "")"
//            currencyStr = "\(components.last ?? "")"
//        }
        
        let defaultAttributes = [
            .font: AppFont.bold.size(32.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.regular.size(14.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let priceAttributed = [
            getAmount,
            NSAttributedString(string: currencyStr,
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.paymentAmountLbl.attributedText = NSAttributedString(from: priceAttributed, defaultAttributes: defaultAttributes)
    }
    
    private func mobileAttr(mobileStr: String?){
        //-------------------- Attributed Text for MOBILE NUMBER
        let mobileDefault = [
            .font: AppFont.semibold.size(12.0, familyName: familyManrope),
            .foregroundColor: UIColor.appDarkGray
        ] as [NSAttributedString.Key : Any]
        
        let moblieAttr = [
            .font: AppFont.semibold.size(12.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let mobileMakeAttr = [
            "Mobile: ",
            NSAttributedString(string: mobileStr ?? "",
                               attributes: moblieAttr)
        ] as [AttributedStringComponent]
        
        self.mobileNumnLbl.attributedText = NSAttributedString(from: mobileMakeAttr, defaultAttributes: mobileDefault)
    }
    
    //MARK: ---------- SET UI
    private func setupUI(){
        DispatchQueue.main.async {
            self.trainingPreferenceMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.couponMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
            self.couponMBV.addDashedBorder(UIColor.appGreen, filledColor: UIColor.appGreen.withAlphaComponent(0.2), withWidth: 1.5, cornerRadius: 3.0, dashPattern: [6,2])
            self.offerDetailsSubMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.renewCouponMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
            self.renewCouponMBV.addDashedBorder(UIColor.appGreen, filledColor: UIColor.appGreen.withAlphaComponent(0.2), withWidth: 1.5, cornerRadius: 3.0, dashPattern: [6,2])
            self.renewOfferDetailsSubMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.trainingPreferenceMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.bookingSlotMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.addressTypeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.addressTypeBtn.frame.height/2.5)
            self.bookingTimeBckView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            
            //-------------------
            self.profileMBV.backgroundColor = UIColor.clear
            
            [
              self.profileMBV,
              self.viewCouponStckView,
              self.renewCouponStckView,
              self.packageDetailsMBV,
              self.trainingPreferenceMBV,
              self.bookingSlotMBV,
              self.paymentBtn,
              self.addressMBV,
              self.memberMBV
            ].forEach({
                $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
        }
        view.layoutIfNeeded()
    }
    
    //------------------************Font
    private func setUpFont(){
        //----------------------***********
        self.preferenceLbl.font = AppFont.bold.size(16, familyName: familyManrope)
        self.bookingSlotTitleLbl.font = AppFont.regular.size(14, familyName: familyManrope)
        self.bookingTimeLbl.font = AppFont.bold.size(16, familyName: familyManrope)
        self.couponOffersTitleBtn.titleLabel?.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.couponLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.renewcouponOffersTitleBtn.titleLabel?.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.renewCouponLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.packageDetailsTitleLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.paymentBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
        self.mobileNumnLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        //-------------------***************
        [
            self.trainingPrefernceTitleLbl,
            self.savedLbl,
            self.renewSavedLbl,
            self.viewBreakdownLbl,
            self.addressLbl,
            self.mobileNumnLbl,
            self.addressTypeBtn.titleLabel
        ].forEach({
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if self.traninerTblView.contentSize.height != 0 {
            self.traninerTblViewHeightConstrt.constant = self.traninerTblView.contentSize.height
        }
        if self.membersTblView.contentSize.height != 0 {
            self.membersTblViewHeightConstrnt.constant = self.membersTblView.contentSize.height
        }
        if self.packageDetails.contentSize.height != 0 {
            self.packageDetailsHeightConstrnt.constant = self.packageDetails.contentSize.height
        }
        view.layoutIfNeeded()
    }
}

//MARK: ----------------UITableViewDelegate
extension TopReviewPackageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == traninerTblView {
            return 1 //trainersList?.count ?? 0
        }else if tableView == packageDetails{
            return packageDetailsData?.count ?? 0
        }else{
            return memberList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == traninerTblView {
            let trainerCell: ReviewProfileTableViewCell = traninerTblView.dequeueReusableCell(withIdentifier: "ReviewProfileTableViewCell", for: indexPath) as! ReviewProfileTableViewCell
            DispatchQueue.main.async {
                trainerCell.cellMBV.backgroundColor = UIColor.appCard2
                trainerCell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
            trainerCell.profileImgView.image = nil
            trainerCell.ratingBtn.setTitle(nil, for: .normal)
            trainerCell.trainerNameLbl.text = nil
//            trainerCell.trainerTagsData = trainersList?[indexPath.row].tags
//            trainerCell.setCellData(inputData: trainersList?[indexPath.row])
            trainerCell.editBtn.accessibilityHint = "" //"\(trainersList?[indexPath.row].id ?? 0)"
            trainerCell.editBtn.addTarget(self, action: #selector(editTrainerBtnActn(sender: )), for: .touchUpInside)
            
            return trainerCell
        }
        else if tableView == packageDetails{
            let cell:PackageDetailsTableViewCell = packageDetails.dequeueReusableCell(withIdentifier: "PackageDetailsTableViewCell", for: indexPath) as! PackageDetailsTableViewCell
            cell.titleLbl.text = packageDetailsData?[indexPath.row]["title"] as? String
            cell.descLbl.text = packageDetailsData?[indexPath.row]["desc"] as? String
            return cell
        }
        else{
            let memberCell: AddMemberTableViewCell = membersTblView.dequeueReusableCell(withIdentifier: "AddMemberTableViewCell", for: indexPath) as! AddMemberTableViewCell
            DispatchQueue.main.async {
                memberCell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1.0), cornerRadious: 12.0)
                memberCell.ageMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
                memberCell.genderMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            }
//            memberCell.setupCell(data: memberList?[indexPath.row])
            memberCell.editBtn.isHidden = true
            memberCell.delBtn.isHidden = true
            
            return memberCell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    @objc func editTrainerBtnActn(sender: UIButton){
        print(sender.accessibilityHint as Any)
        self.navigationController?.popToViewController(ofClass: TrainerListViewController.self, animated: true)
    }
}

//MARK: --------------------API
extension TopReviewPackageViewController {
    private func topupUpgradeReviewApi(){
        let params:[String:Any] = [
            "type": (self.inputType ?? "").lowercased(),
            "id": self.inputId ?? "",
            "price": self.inputPrice ?? "",
            "sessions": self.inputSessions ?? "",
            "days": self.inputDays ?? "",
        ]
        print("Review upgrade input Params: ", params)
        DashboardVM.reviewUpgradePackageApi(inputparams: params, completion: {[weak self] getResultData in
            guard let self = self else { return }
            
            self.reviewUpgradeDetails = nil
            self.reviewUpgradeDetails = getResultData?.data
            self.setupFlow()
        })
    }
    
    //MARK: ---------------MAKE PAYMENT
    private func paymentApi(transactionId: String?, paymentType: String?){
        let params:[String:Any] = [
            "id":  self.inputId ?? "",
            "transaction_id": transactionId ?? "",
            "payment_type": paymentType ?? "",
            "type": (self.inputType ?? "").lowercased(),
            "sessions": self.inputSessions ?? "",
            "days": self.inputDays ?? "",
            "price": self.inputPrice ?? ""
        ]
        print("Payment params: ", params)
        DashboardVM.makePaymentUpgradePackageApi(inputparams: params, completion: {[weak self] getResultData in
            guard let self = self else { return }
            print("getResultData: ", getResultData as Any)
            self.paymentDetails = nil
            self.paymentDetails = getResultData?.data
            let vc:TopupUpgradeBillingViewController = TopupUpgradeBillingViewController.instantiate(appStoryboard: .dashboard)
            vc.paymentDetails = getResultData?.data
            vc.planFlow = self.planFlow
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
}

