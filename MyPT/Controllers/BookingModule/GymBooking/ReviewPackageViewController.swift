//
//  ReviewPackageViewController.swift
//  MyPT
//
//  Created by techsaga corp on 04/12/24.
//

import UIKit

class ReviewPackageViewController: CommonViewController {
    
    //MARK: -----------VARIBALE
    var packageDetailsData:[[String:Any]]?
    
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    var categoryData:[String]?
    
    //MARK: ------------IBOUTLET
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setNavUI()
        setUpFont()
        
        categoryData = ["Cardio","Pilates","+3"]
        
        self.packageDetailsData = [["title":"Package","desc":"My PT Trainer Package"],
                                   ["title":"Start Date","desc":"13 th Jun 2024"],
                                   ["title":"Package","desc":"13 th Jun 2024"],
                                   ["title":"Total Sessions","desc":"12"]
        ]
        
        self.offerDetailsMBV.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.review_Package], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        categoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        packageDetails.register(UINib(nibName: "PackageDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "PackageDetailsTableViewCell")
        
        DispatchQueue.main.async {
            self.trainingPreferenceMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.couponMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
            self.couponMBV.addDashedBorder(UIColor.appGreen, filledColor: UIColor.appGreen.withAlphaComponent(0.2), withWidth: 1.5, cornerRadius: 3.0, dashPattern: [6,2])
            self.trainingPreferenceMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.bookingSlotMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            self.packageDetailsMBV.backgroundColor = UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1)
            
            self.viewCouponStckView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.offerDetailsSubMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.packageDetailsMBV.backgroundColor = UIColor.mainBg.withAlphaComponent(0.3)
            self.packageDetailsMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.trainerProfileImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.trainingPreferenceMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.bookingSlotMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.paymentBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            //            self.viewCouponStckView.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor,UIColor.mainBg.cgColor], type: .conic)
            //            self.trainingPreferenceMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor,UIColor.mainBg.cgColor], type: .conic)
            //            self.bookingSlotMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor,UIColor.mainBg.cgColor], type: .conic)
                
            //            self.packageDetailsMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor,UIColor.mainBg.cgColor], type: .conic)
        }
    }
    
    //------------------************Font
    func setUpFont(){
        self.trainerNameLbl.font = AppFont.bold.size(14, familyName: familyManrope)
        self.ratingBtn.titleLabel?.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.trainingPrefernceTitleLbl.font = AppFont.regular.size(14, familyName: familyManrope)
        self.preferenceLbl.font = AppFont.bold.size(16, familyName: familyManrope)
        self.bookingSlotTitleLbl.font = AppFont.regular.size(14, familyName: familyManrope)
        self.bookingTimeLbl.font = AppFont.bold.size(16, familyName: familyManrope)
        self.couponOffersTitleBtn.titleLabel?.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.couponLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.saveedLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.packageDetailsTitleLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        self.paymentBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
//        self.paymentAmountLbl.font = AppFont.regular.size(12, familyName: familyManrope)
        self.viewBreakdownLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
        
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
        
        self.paymentAmountLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
    
    enum btnTag:Int {
        case profileEdit = 501, trainingPreference,bookingSlot, editOffers, viewCoupon, deleteOffer
    }

    @IBAction func commonBtnActn(_ sender:UIButton){
        print(sender.tag)
        
        switch sender.tag {
        case btnTag.profileEdit.rawValue:
            print("profileEdit btn clicked")
        case btnTag.trainingPreference.rawValue:
            print("training preference btn clicked")
        case btnTag.bookingSlot.rawValue:
            print("booking slot btn clicked")
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
        let vc:PaymentSuccessViewController = PaymentSuccessViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: true)
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
        return categoryData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
        cell.titleLbl.text = categoryData?[indexPath.row] as? String
        
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
