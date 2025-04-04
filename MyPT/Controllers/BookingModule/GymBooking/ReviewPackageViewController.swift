//
//  ReviewPackageViewController.swift
//  MyPT
//
//  Created by techsaga corp on 04/12/24.
//

import UIKit

class ReviewPackageViewController: CommonViewController {
    
    //MARK: -----------VARIBALE
    var inputCheckoutParams: SetDateParams?
    var inputBookSlotParams:BookSlotParamsModel? = nil
    var packagecheckoutData: PackageCheckoutDataModel?
    var trainersList: [PackageCheckoutTrainerModel]? = []
    var studioData:PackageCheckoutStudioModel?
    var memberList:[MemberModel]? = []
    var packageDetailsData:[[String:Any]]?
    
    
    //MARK: ------------IBOUTLET
    @IBOutlet weak var profileMBV: UIView!
    @IBOutlet weak var trainingPreferenceMBV: UIView!
    @IBOutlet weak var bookingSlotMBV: UIView!
    @IBOutlet weak var trainingPrefernceTitleLbl: UILabel!
    @IBOutlet weak var preferenceLbl: UILabel!
    @IBOutlet weak var bookingSlotTitleLbl: UILabel!
    @IBOutlet weak var bookingTimeLbl: UILabel!
    @IBOutlet weak var preferenceEditBtn: UIButton!
    @IBOutlet weak var bookingSlotEditBtn: UIButton!
    @IBOutlet weak var viewCouponStckView: UIStackView!
    @IBOutlet weak var offersMBV: UIView!
    @IBOutlet weak var offerDetailsMBV: UIView!
    @IBOutlet weak var couponOffersTitleBtn: UIButton!
    @IBOutlet weak var offerDetailsSubMBV: UIView!
    @IBOutlet weak var couponMBV: UIView!
    @IBOutlet weak var couponLbl: UILabel!
    @IBOutlet weak var saveedLbl: UILabel!
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

//        setupUI()
        setNavUI()
        setUpFont()
                        
        self.offerDetailsMBV.isHidden = true
        
        //-------------------Api
        self.packageCheckoutApi(inputParams: inputCheckoutParams?.getPackageCheckoutParams())
        
        self.setInputData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupUI()
        view.layoutIfNeeded()
        
//        DispatchQueue.main.async {
//            self.addressTypeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.addressTypeBtn.frame.height/2.5)
//        }
      
    }
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.review_Package], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func setInputData(){
        
        self.preferenceLbl.text = packagecheckoutData?.trainingPreference
        self.bookingTimeLbl.text = packagecheckoutData?.slotTime

        if let getAddress = packagecheckoutData?.address {
            self.addressMBV.isHidden = false
            
            self.addressTypeBtn.setTitle(getAddress.type?.localizedCapitalized, for: .normal)
            
            let fullAddrStr = [getAddress.building_name?.value, getAddress.street?.value, getAddress.landmark, getAddress.city_name, getAddress.country_name]
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
            
            self.addressLbl.text = fullAddrStr
            
        }else{
            self.addressMBV.isHidden = true
        }
        
        //----------------------***************
        let startDateStr = DateFormatterHelper.shared.dateInsuffix(from: packagecheckoutData?.packageDetail?.startDate ?? "", fromFormat: "yyyy-MM-dd", toFormat: "d MMM yyyy") ?? ""
        let endDateStr = DateFormatterHelper.shared.dateInsuffix(from: packagecheckoutData?.packageDetail?.endDate ?? "", fromFormat: "yyyy-MM-dd", toFormat: "d MMM yyyy") ?? ""
        
        self.packageDetailsData = [
            ["title":"Package","desc":packagecheckoutData?.packageDetail?.package ?? ""],
            ["title":"Start Date","desc": startDateStr],
            ["title":"End date","desc": endDateStr],
            ["title":"Total Sessions","desc":packagecheckoutData?.packageDetail?.totalSessions ?? ""]
        ]
        
        self.packageDetails.reloadData()
        
        
        //-------------------- Attributed Text for Price
        var getAmount:String = ""
        var currencyStr:String = ""
        
        if let pricePackage = packagecheckoutData?.packageDetail?.price {
            let components = pricePackage.split(separator: " ")
            getAmount = "\(components.first ?? "")"
            currencyStr = "\(components.last ?? "")"
        }
        
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
            NSAttributedString(string: packagecheckoutData?.address?.mobile_no?.value ?? "",
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
            self.trainingPreferenceMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.bookingSlotMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.offerDetailsSubMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            
            self.addressTypeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.addressTypeBtn.frame.height/2.5)
            
            //-------------------
            self.profileMBV.backgroundColor = UIColor.clear
            
            [
              self.profileMBV,
              self.viewCouponStckView,
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
        
        packageDetails.register(UINib(nibName: "PackageDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "PackageDetailsTableViewCell")
        
        self.traninerTblView.register(UINib(nibName: "ReviewProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewProfileTableViewCell")
        self.membersTblView.register(UINib(nibName: "AddMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "AddMemberTableViewCell")
        
        //----------------------***********
        self.preferenceLbl.font = AppFont.bold.size(16, familyName: familyManrope)
        self.bookingSlotTitleLbl.font = AppFont.regular.size(14, familyName: familyManrope)
        self.bookingTimeLbl.font = AppFont.bold.size(16, familyName: familyManrope)
        self.couponOffersTitleBtn.titleLabel?.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.couponLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.packageDetailsTitleLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.paymentBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
        self.mobileNumnLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)

        //-------------------***************
        [
            self.trainingPrefernceTitleLbl,
            self.saveedLbl,
            self.viewBreakdownLbl,
            self.addressLbl,
            self.mobileNumnLbl,
            self.addressTypeBtn.titleLabel
        ].forEach({
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
    }
    
    //------------------******************
    enum btnTag:Int {
        case profileEdit = 501, trainingPreference,bookingSlot, editOffers, viewCoupon, deleteOffer, editAddress, editMembers
    }

    @IBAction func commonBtnActn(_ sender:UIButton){
        print(sender.tag)
        
        switch sender.tag {
        case btnTag.profileEdit.rawValue:
            print("profileEdit btn clicked")
           
            self.navigationController?.popToViewController(ofClass: TrainerListViewController.self, animated: true)
            
        case btnTag.trainingPreference.rawValue:
            print("training preference btn clicked")
            
            self.navigationController?.popToViewController(ofClass: CreatePackageViewViewController.self, animated: true)
            
        case btnTag.bookingSlot.rawValue:
            print("booking slot btn clicked")
            self.navigationController?.popViewController(animated: true)
            
        case btnTag.editOffers.rawValue:
            print("edit offers btn clicked")
            let vc:CouponsOffersViewController = CouponsOffersViewController.instantiate(appStoryboard: .booking)
            vc.sentBackCoupon = { [weak self] getData in
                guard let self = self else { return }
                self.offerDetailsMBV.isHidden = false
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    self.viewCouponStckView.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor,UIColor.mainBg.cgColor], type: .conic)
                   
              
                    self.viewCouponStckView.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
                    self.couponMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
                    self.couponMBV.addDashedBorder(UIColor.appGreen, filledColor: UIColor.appGreen.withAlphaComponent(0.2), withWidth: 1.5, cornerRadius: 3.0, dashPattern: [6,2])
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
            
        case btnTag.viewCoupon.rawValue:
            print("view coupon btn clicked")
            let vc:CouponsOffersViewController = CouponsOffersViewController.instantiate(appStoryboard: .booking)
            vc.sentBackCoupon = { [weak self] getData in
                guard let self = self else { return }
                self.offerDetailsMBV.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    self.viewCouponStckView.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor,UIColor.mainBg.cgColor], type: .conic)
                    
                    self.viewCouponStckView.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
                    
                    self.couponMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
                    self.couponMBV.addDashedBorder(UIColor.appGreen, filledColor: UIColor.appGreen.withAlphaComponent(0.2), withWidth: 1.5, cornerRadius: 3.0, dashPattern: [6,2])
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
            
        case btnTag.deleteOffer.rawValue:
            print("delete offers btn clicked")
            
        case btnTag.editAddress.rawValue:
            print("Edit address cliocked")
            
            let vc: SelectYourLocationViewController =  SelectYourLocationViewController.instantiate(appStoryboard: .booking)
            vc.selectAddFlow = .reviewPackage
            vc.sentAddressDetails = { [weak self] getData in
                guard let self = self, let getData = getData else { return  }
                
                self.packagecheckoutData?.address = getData
                
                let fullAddrStr = [packagecheckoutData?.address?.building_name?.value, packagecheckoutData?.address?.street?.value, packagecheckoutData?.address?.landmark, packagecheckoutData?.address?.city_name, packagecheckoutData?.address?.country_name]
                    .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
                
                self.addressLbl.text = fullAddrStr
                
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
           
        case btnTag.editMembers.rawValue:
            print("edit members is clicked......")
        default:
            print("Default btn.....")
        }
    }
    
//    //MARK: ------------VIEW OFFER ACT
//    @objc func viewOffersCoupon(sender:UITapGestureRecognizer){
//        print("tap to view offers")
//        let vc:CouponsOffersViewController = CouponsOffersViewController.instantiate(appStoryboard: .booking)
//        vc.sentBackCoupon = { [weak self] getData in
//            guard let self = self else { return }
//            self.couponMBV.isHidden = false
//        }
//        self.navigationController?.pushViewController(vc, animated: true)
        
//    }
    
    //MARK: ------------- MAKE PAYMENT BTN ACTN
    @IBAction func paymentBtnActn(_ sender: Any) {
        print("make payment clicked")
        
        self.inputBookSlotParams = BookSlotParamsModel(studio_id: inputCheckoutParams?.studio_id, type: inputCheckoutParams?.type, trainer_id: inputCheckoutParams?.trainer_id, slot_id: inputCheckoutParams?.slot_id, address_id: packagecheckoutData?.address?.id?.value, is_package: "1", package_type: inputCheckoutParams?.package_type, date: inputCheckoutParams?.date, end_date: inputCheckoutParams?.end_date, sessions: inputCheckoutParams?.sessions, price: packagecheckoutData?.packageDetail?.price, days: "\(packagecheckoutData?.packageDetail?.days ?? 0)")
        
        print("inputBookSlotParams", inputBookSlotParams as Any)
        //-----------------Called booking Api
        self.bookSlot(inputParam: self.inputBookSlotParams?.getParams() ?? [:])
        
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
extension ReviewPackageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if tableView == traninerTblView {
            return trainersList?.count ?? 0
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
            
            trainerCell.trainerTagsData = trainersList?[indexPath.row].tags
            trainerCell.setCellData(inputData: trainersList?[indexPath.row])
            
            trainerCell.editBtn.accessibilityHint = "\(trainersList?[indexPath.row].id ?? 0)"
            trainerCell.editBtn.addTarget(self, action: #selector(editTrainerBtnActn(sender: )), for: .touchUpInside)
            
            return trainerCell
        }else if tableView == packageDetails{
            let cell:PackageDetailsTableViewCell = packageDetails.dequeueReusableCell(withIdentifier: "PackageDetailsTableViewCell", for: indexPath) as! PackageDetailsTableViewCell
            
            cell.titleLbl.text = packageDetailsData?[indexPath.row]["title"] as? String
            cell.descLbl.text = packageDetailsData?[indexPath.row]["desc"] as? String
            
            return cell
        }else{
            let memberCell: AddMemberTableViewCell = membersTblView.dequeueReusableCell(withIdentifier: "AddMemberTableViewCell", for: indexPath) as! AddMemberTableViewCell
           
            DispatchQueue.main.async {
                memberCell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 43.0/255.0, green: 43.0/255.0, blue: 43.0/255.0, alpha: 1.0), cornerRadious: 12.0)
                memberCell.ageMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
                memberCell.genderMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            }
            
            memberCell.setupCell(data: memberList?[indexPath.row])
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


//MARK: ---------------------EXTENSION FOR API

extension ReviewPackageViewController{
    
    private func packageCheckoutApi(inputParams: [String:Any]?){
        print("Package checkout params: ", inputParams as Any)
        CreatePackageVM.packageCheckoutApi(viewController: self, inputParams: inputParams, completion: { [weak self] getResultData in
            guard let self = self else { return  }
            
            print("PackageCheckout getResultData", getResultData as Any)
            
            if getResultData?.status == true {
                self.packageDetailsData = nil
                self.packagecheckoutData = getResultData?.data
                self.trainersList?.removeAll()
                if let trainerData = getResultData?.data?.trainer {
                    self.trainersList?.append(trainerData)
                    self.traninerTblView.reloadData()
                }
                
//                self.setInputData()
                
//                ---------------For  Gymworkout flow
                if let getStudioData = getResultData?.data?.studio {
                    self.studioData = getStudioData
                    let convertTrainerModel = PackageCheckoutTrainerModel(id: self.studioData?.id, name: self.studioData?.name, profile: self.studioData?.image, noOfRating: self.studioData?.noOfRating, averageRating: self.studioData?.averageRating, tags: self.studioData?.tags)
                    
                    self.trainersList?.append(convertTrainerModel)
                    self.traninerTblView.reloadData()
                }
                
                self.setInputData()
                
                //---------------------For 
                self.memberList?.removeAll()
                self.memberList?.append(contentsOf: getResultData?.data?.userMembers ?? [])
                if self.memberList?.count == 0 {
                    self.memberMBV.isHidden = true
                }else{
                    self.memberMBV.isHidden = false
//                    self.addressMBV.isHidden = true
                }
                
                self.membersTblView.reloadData()
            }
        })
    }
    
    //MARK: -----------------SLOT BOOKED API
    private func bookSlot(inputParam: [String:Any]){
        print("Book Slot inputParam: ", inputParam)
        
        TrainerVM.bookSlotApi(viewController: self, inputParams: inputParam, completion: {[weak self]  getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print("Booked getResultData: ",getResultData)
            if getResultData.status == true {
                let vc:PaymentSuccessViewController = PaymentSuccessViewController.instantiate(appStoryboard: .booking)
                vc.bookedDataModel = getResultData.data
                self.navigationController?.pushViewController(vc, animated: true)
            }
          
        })
    }
}


