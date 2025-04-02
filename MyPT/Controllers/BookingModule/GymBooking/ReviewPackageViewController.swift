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
    var tagsData: [String]? = []
    
    var packageDetailsData:[[String:Any]]?
    
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
    //MARK: ------------IBOUTLET
    @IBOutlet weak var profileMBV: UIView!
    @IBOutlet weak var trainerProfileImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var categoryCollView: UICollectionView!
    @IBOutlet weak var ratingBtn: UIButton!
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
    @IBOutlet weak var paymentMBV: UIView!
    @IBOutlet weak var paymentBtn: UIButton!
    @IBOutlet weak var paymentAmountLbl: UILabel!
    @IBOutlet weak var viewBreakdownLbl: UILabel!
    @IBOutlet weak var addressMBV: UIView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var mobileNumnLbl: UILabel!
    @IBOutlet weak var addressTypeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
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
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.review_Package], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func setInputData(){
        
        self.trainerProfileImgView.loadImage(urlString: packagecheckoutData?.trainer?.profile, placeholder: AppImages.navLeft)
        self.trainerNameLbl.text = packagecheckoutData?.trainer?.name
        self.preferenceLbl.text = packagecheckoutData?.trainingPreference
        self.bookingTimeLbl.text = packagecheckoutData?.slotTime

        self.addressTypeBtn.setTitle(packagecheckoutData?.address?.type?.localizedCapitalized, for: .normal)
        
        let fullAddrStr = [packagecheckoutData?.address?.building_name?.value, packagecheckoutData?.address?.street?.value, packagecheckoutData?.address?.landmark, packagecheckoutData?.address?.city_name, packagecheckoutData?.address?.country_name]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        
        self.addressLbl.text = fullAddrStr
        

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
        
        
        //------------------rating atttibuted btn text
        let numRating = packagecheckoutData?.trainer?.noOfRating ?? ""
        let avgRating = "• " + (packagecheckoutData?.trainer?.averageRating ?? "")
        
        let ratingDefaultAttr = [
            .font: AppFont.semibold.size(12.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let avgRatingAttr = [
            .font: AppFont.semibold.size(12.0, familyName: familyManrope),
            .foregroundColor: UIColor.appDarkGray
        ] as [NSAttributedString.Key : Any]
        
        let makeAttr = [
            numRating ,
            NSAttributedString(string: avgRating ,
                               attributes: avgRatingAttr)
        ] as [AttributedStringComponent]
        
        
        self.ratingBtn.setAttributedTitle(NSAttributedString(from: makeAttr, defaultAttributes: ratingDefaultAttr), for: .normal)
        
        
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
        categoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        packageDetails.register(UINib(nibName: "PackageDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "PackageDetailsTableViewCell")
        
        DispatchQueue.main.async {
            self.trainingPreferenceMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.couponMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
            self.couponMBV.addDashedBorder(UIColor.appGreen, filledColor: UIColor.appGreen.withAlphaComponent(0.2), withWidth: 1.5, cornerRadius: 3.0, dashPattern: [6,2])
            self.trainingPreferenceMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.bookingSlotMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            
            self.offerDetailsSubMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
           
            self.trainerProfileImgView.setCornerRadius(borderWidth: 0.3, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.trainerProfileImgView.contentMode = .scaleToFill
            
            self.addressTypeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.addressTypeBtn.frame.height/2.5)
            
            //-------------------
            [
              self.profileMBV,
              self.viewCouponStckView,
              self.packageDetailsMBV,
              self.trainingPreferenceMBV,
              self.bookingSlotMBV,
              self.paymentBtn,
              self.addressMBV
            ].forEach({
                $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
        }
    }
    
    //------------------************Font
    private func setUpFont(){
        self.ratingBtn.titleLabel?.font = AppFont.semibold.size(12, familyName: familyManrope)
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
            self.trainerNameLbl,
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
        case profileEdit = 501, trainingPreference,bookingSlot, editOffers, viewCoupon, deleteOffer, editAddress
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
        
        if packageDetails.contentSize.height != 0 {
            packageDetailsHeightConstrnt.constant = packageDetails.contentSize.height
        }
        view.layoutIfNeeded()
    }
    
}


//MARK: ----------------UITableViewDelegate
extension ReviewPackageViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        if let totalCount = tagsData?.count, totalCount > 2 {
            return 3
        }else{
            return tagsData?.count ?? 0
        }
        
//        return categoryData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        
        DispatchQueue.main.async {
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 9.0)
            cell.layoutIfNeeded()
        }
        
        cell.titleLblLeading.constant = 8.0
        cell.titleLblTopConstrnt.constant = 5.0
        cell.layoutIfNeeded()
        
        if let lastCell = collectionView.isLastCell(), let totalCount = tagsData?.count,( lastCell == indexPath.row && totalCount > 2) {
            cell.titleLbl.text = "+3"
           
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 2.0)
            cell.layoutIfNeeded()
        }
        else{
            cell.titleLbl.text = tagsData?[indexPath.row] as? String
        }
        
        //        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
                
        //        cell.titleLbl.text = tagsData?[indexPath.row] as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Check if any range contains the index
        return !restrictedRange.contains { $0.contains(indexPath.item) }
    }
    
    
}

//MARK: ----------------UITableViewDelegate
extension ReviewPackageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packageDetailsData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PackageDetailsTableViewCell = packageDetails.dequeueReusableCell(withIdentifier: "PackageDetailsTableViewCell", for: indexPath) as! PackageDetailsTableViewCell
        
        cell.titleLbl.text = packageDetailsData?[indexPath.row]["title"] as? String
        cell.descLbl.text = packageDetailsData?[indexPath.row]["desc"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
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
                self.tagsData?.removeAll()
                self.tagsData?.append(contentsOf: getResultData?.data?.trainer?.tags ?? [])
                self.categoryCollView.reloadData()
                self.setInputData()
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


