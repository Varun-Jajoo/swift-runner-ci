//
//  BookingReviewPurchaseVC.swift
//  MyPT
//
//  Created by Manik Goel on 25/07/26.
//

import UIKit

class BookingReviewPurchaseVC: CommonViewController {
    
    private var checkoutData: ReviewPackageCheckoutData?
    private var inputBookSlotParams: BookSlotParamsModel?
    private var selectedOfferId: Int? {
        didSet {
            updateApplyCouponUI()
        }
    }
    var isGymMembership: Bool = false
    private var isUpgradeSelected: Bool = false
    private var selectedBestPlanId: String?
    private var appliedCoupon: CoupenData?
    
    var previousSubscriptionID: String?
    var type: String?
    var sessions: String?
    var packageType: String?
    var trainerId: Int?
    var addressId: Int?
    var studioId: String?
    var bestPlanId: String?
    var inputParam: DetailsParam?
    var paymetMethod: String? = "ccavenue"
    var flowGymwork: calendarFlow = .defaultFlow
    var startDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
    var isChecked = false
    
    @IBOutlet weak var btnAddress: UIButton!
    @IBOutlet weak var imgAddressArrow: UIImageView!
    @IBOutlet weak var lblUpgradeToVIP: UILabel!
    @IBOutlet weak var lblAED: UILabel!
    @IBOutlet weak var lblSession: UILabel!
    @IBOutlet weak var btnUpgradePlan: UIButton!
    @IBOutlet weak var lblSavingCorner: UILabel!
    @IBOutlet weak var lblSavedAED: UILabel!
    @IBOutlet weak var viewSavingCorner: UIView!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var btnViewAllCoupon: UIButton!
    @IBOutlet weak var viewPackageDetail: UIView!
    @IBOutlet weak var lblPackageDetail: UILabel!
    @IBOutlet weak var lblMode: UILabel!
    @IBOutlet weak var lblTypeWorkout: UILabel!
    @IBOutlet weak var lblTrainingPlace: UILabel!
    @IBOutlet weak var lblSolo: UILabel!
    @IBOutlet weak var lblTotalSession: UILabel!
    @IBOutlet weak var lblValidity: UILabel!
    @IBOutlet weak var lblNumSession: UILabel!
    @IBOutlet weak var lblMOnth: UILabel!
    @IBOutlet weak var lblNumOfAED: UILabel!
    @IBOutlet weak var lblRemainingSession: UILabel!
    @IBOutlet weak var lblSavedSession: UILabel!
    @IBOutlet weak var lblAllTrainer: UILabel!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblSelectedGym: UILabel!
    @IBOutlet weak var lblGymName: UILabel!
    @IBOutlet weak var lblYouwillBookSession: UILabel!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var lblLocationTYpe: UILabel!
    @IBOutlet weak var lblAdress: UILabel!
    @IBOutlet weak var viewPayment: UIView!
    @IBOutlet weak var lblChoosePayment: UILabel!
    @IBOutlet weak var viewTabby: UIView!
    @IBOutlet weak var lblTabby: UILabel!
    @IBOutlet weak var lblTabbyDetail: UILabel!
    @IBOutlet weak var btnTabby: UIButton!
    @IBOutlet weak var viewTamara: UIView!
    @IBOutlet weak var lblTamara: UILabel!
    @IBOutlet weak var lblTamarayDetail: UILabel!
    @IBOutlet weak var btnTamara: UIButton!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var lblCard: UILabel!
    @IBOutlet weak var lblCardDetail: UILabel!
    @IBOutlet weak var btnCard: UIButton!
    @IBOutlet weak var lblCancel6h: UILabel!
    @IBOutlet weak var lblTrainingLoc: UILabel!
    @IBOutlet weak var imgUpgradeCard: UIImageView!
    @IBOutlet weak var imgSavingCorner: UIImageView!
    @IBOutlet weak var imgPackageDetail: UIImageView!
    @IBOutlet weak var imgTrainingLoc: UIImageView!
    @IBOutlet weak var imgChoosepayment: UIImageView!
    @IBOutlet weak var viewUpgrade: UIView!
    @IBOutlet weak var viewSpecialMsg: UIView!
    @IBOutlet weak var viewPaymenytDownword: UIView!
    @IBOutlet weak var viewGymMembershipDetails: UIView!
    @IBOutlet weak var lblGymMembershipPackageDetails: UILabel!
    @IBOutlet weak var lblGymMembershipSelectedGym: UILabel!
    @IBOutlet weak var lblGymMemberSelectedGymData: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblStartDateData: UILabel!
    @IBOutlet weak var lblGymMembershipSelectedPlan: UILabel!
    @IBOutlet weak var lblGymMembershipSelectedPlanType: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var lblEndDateData: UILabel!
    @IBOutlet weak var lblGymMembershipPrice: UILabel!
    @IBOutlet weak var viewTrainerLocation: UIView!
    @IBOutlet weak var lblRefundable: UILabel!
    @IBOutlet weak var viewOtherPlans: UIView!
    @IBOutlet weak var lblBrowseOtherPlan: UILabel!
    @IBOutlet weak var lblChangeSessionCount: UILabel!
    @IBOutlet weak var lblPlanExpired: UILabel!
    @IBOutlet weak var viewPlanExpired: UIView!
    @IBOutlet weak var imgEarlyClock: UIImageView!
    @IBOutlet weak var lblEarlyMsg: UILabel!
    @IBOutlet weak var viewNewGymMembershipDetails: UIView!
    @IBOutlet weak var lblNewGymPackageDetail: UILabel!
    @IBOutlet weak var lblNewGymPlanType: UILabel!
    @IBOutlet weak var lblNewGymPlanTypeData: UILabel!
    @IBOutlet weak var lblNewGymValidity: UILabel!
    @IBOutlet weak var lblNewGymValidityData: UILabel!
    @IBOutlet weak var lblNewGymPrice: UILabel!
    @IBOutlet weak var lblNewGymMsg: UILabel!
    @IBOutlet weak var lblNewSelectedGym: UILabel!
    @IBOutlet weak var lblNewSelectedGymData: UILabel!
    @IBOutlet weak var lblNewGymEarlyMsg: UILabel!
    @IBOutlet weak var imgNewGymEarlyClock: UIImageView!
    @IBOutlet weak var viewNewGymMSg: UIView!
    @IBOutlet weak var heightOfNewGymMembership: NSLayoutConstraint!
    @IBOutlet weak var viewTermAndCond: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTermCondition: UILabel!
    @IBOutlet weak var lblGymRefundable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let param = inputParam {
            print("inputParam value:", param)
            btnAddress.isUserInteractionEnabled = param.type == "home"
            imgAddressArrow.isHidden = param.type == "gym"
        } else {
            print("inputParam is nil")
        }
        
        uiSetup()
        fetchCheckoutData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI() {
        //        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        //        self.setProgress(0.3)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [AppStrings.reviewYourTrainingPlan], setTintColor: UIColor.appWhite, setTitleColor: UIColor.appWhite)
        self.setRighMenu(setTitle: [], setTintColor: .black, setTitleColor:.clear)
        viewGymMembershipDetails.isHidden = flowGymwork == .withoutTrainerMembership ? false : true
        viewPackageDetail.isHidden = flowGymwork == .withoutTrainerMembership ? true : false
        viewTrainerLocation.isHidden = flowGymwork == .withoutTrainerMembership ? true : false
        viewTrainerLocation.isHidden = flowGymwork == .withoutTrainerMembership ? true : false
    }
    
    private func uiSetup() {
        DispatchQueue.main.async {
            self.btnCheck.setImage(UIImage(named: "unselectedRadioBtn"), for: .normal)
            self.lblTermCondition.isUserInteractionEnabled = true
            self.lblRefundable.isUserInteractionEnabled = true
            self.lblGymRefundable.isUserInteractionEnabled = true
            self.viewPaymenytDownword.roundBottomCorners(radius: 16)
            
            //        .roundSideCorners(radius: 16, cornerSide: .bottomLeft)
            
            self.btnUpgradePlan.cornersWithBorder(radius: 8, corners: .allCorners, borderColor: .clear, borderWidth: 0)
            self.viewSpecialMsg.cornersWithBorder(
                radius: 8,
                corners: .allCorners,
                borderColor: UIColor(red: 56/255, green: 118/255, blue: 45/255, alpha: 1),
                borderWidth: 1
            )
            self.viewNewGymMSg.cornersWithBorder(
                radius: 8,
                corners: .allCorners,
                borderColor: UIColor(red: 56/255, green: 118/255, blue: 45/255, alpha: 1),
                borderWidth: 1
            )
            self.viewPlanExpired.cornersWithBorder(
                radius: 12,
                corners: .allCorners,
                borderColor: UIColor(red: 238/255, green: 77/255, blue: 55/255, alpha: 0.13),
                borderWidth: 3
            )
            self.viewTabby.cornersWithBorder(
                radius: 8,
                corners: .allCorners,
                borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5),
                borderWidth: 1
            )
            self.viewTamara.cornersWithBorder(
                radius: 8,
                corners: .allCorners,
                borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5),
                borderWidth: 1
            )
            self.viewCard.cornersWithBorder(
                radius: 8,
                corners: .allCorners,
                borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5),
                borderWidth: 1
            )
            
            self.imgUpgradeCard.cornersWithBorder(radius: 16, corners: .allCorners, borderColor: .clear, borderWidth: 0)
            self.imgSavingCorner.cornersWithBorder(radius: 12, corners: .allCorners, borderColor: .clear, borderWidth: 0)
            self.imgPackageDetail.cornersWithBorder(radius: 12, corners: .allCorners, borderColor: .clear, borderWidth: 0)
            self.imgTrainingLoc.cornersWithBorder(radius: 12, corners: .allCorners, borderColor: .clear, borderWidth: 0)
            self.imgChoosepayment.cornersWithBorder(radius: 12, corners: .allCorners, borderColor: .clear, borderWidth: 0)
            
            self.lblUpgradeToVIP.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
            self.lblPlanExpired.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblAED.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            self.lblSession.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            [self.lblSavingCorner, self.lblPackageDetail, self.lblNewGymPackageDetail, self.lblGymMembershipPackageDetails, self.lblTrainingLoc, self.lblChoosePayment, self.lblRemainingSession, self.lblTrainerName, self.lblGymName, self.lblNewSelectedGymData].forEach {
                $0?.font = AppFont.semibold.size(16.0, familyName: familyFunnelSans)
            }
            [self.lblSavedAED, self.lblLocationTYpe, self.lblTabby, self.lblTamara, self.lblCard, self.lblBrowseOtherPlan] .forEach {
                $0?.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            }
            [self.lblMode, self.lblTypeWorkout, self.lblTotalSession, self.lblValidity, self.lblAllTrainer, self.lblSelectedGym, self.lblYouwillBookSession, self.lblCancel6h, self.lblGymMembershipSelectedGym, self.lblGymMembershipSelectedPlan, self.lblStartDate, self.lblEndDate, self.lblNewGymPlanType, self.lblNewGymValidity, self.lblNewSelectedGym].forEach {
                $0?.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            }
            self.lblTermCondition.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            self.lblSavedSession.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            self.lblNewGymMsg.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            self.lblNumOfAED.font = AppFont.bold.size(30.0, familyName: familyFunnelSans)
            self.lblNewGymPrice.font = AppFont.bold.size(30.0, familyName: familyFunnelSans)
            self.lblGymMembershipPrice.font = AppFont.bold.size(30.0, familyName: familyFunnelSans)
            self.lblRemainingSession.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            [self.lblAdress, self.lblTabbyDetail, self.lblTabbyDetail, self.lblCardDetail, self.lblChangeSessionCount].forEach {
                $0?.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            }
            [self.lblGymMemberSelectedGymData, self.lblGymMembershipSelectedPlanType, self.lblStartDateData, self.lblEndDateData].forEach {
                $0?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            }
            self.lblTrainerName.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblGymName.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblTrainingPlace.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblSolo.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblNumSession.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblMOnth.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblNewGymPlanTypeData.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblNewGymValidityData.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblNewGymEarlyMsg.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            self.lblEarlyMsg.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            self.btnViewAllCoupon.setTitle("View all coupons ", for: .normal)
            self.btnViewAllCoupon.setImage(UIImage(named: "viewAllCoupon"), for: .normal)
            self.btnViewAllCoupon.semanticContentAttribute = .forceRightToLeft
            self.btnViewAllCoupon.titleLabel?.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            //            self.btnProceed.tintColor = .mainBg   // arrow color
            self.btnViewAllCoupon.backgroundColor = .clear
            //            self.btnProceed.setTitleColor(.mainBg, for: .normal)
            
            
            let fullText = "I have read and agree to the MyPT Personal Training Terms & Conditions"
            let clickableText = "MyPT Personal Training Terms & Conditions"
            
            let attributedString = NSMutableAttributedString(string: fullText)
            
            // Normal text color
            attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: fullText.count))
            
            // Find range of clickable text
            let range = (fullText as NSString).range(of: clickableText)
            
            // Apply green color + underline (optional)
            attributedString.addAttributes([
                .foregroundColor: UIColor(red: 224/255, green: 254/255, blue: 8/255, alpha: 1),
                //                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: range)
            
            self.lblTermCondition.attributedText = attributedString
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
            self.lblTermCondition.addGestureRecognizer(tapGesture)
            
            
            let refundFullText = "This package is non-refundable. Know More"
            let refundFclickableText = "Know More"
            
            let refundFattributedString = NSMutableAttributedString(string: refundFullText)
            
            // ✅ correct length
            refundFattributedString.addAttribute(
                .foregroundColor,
                value: UIColor.white,
                range: NSRange(location: 0, length: refundFullText.count)
            )
            
            // find range
            let refundFrange = (refundFullText as NSString).range(of: refundFclickableText)
            
            // ✅ correct object
            refundFattributedString.addAttributes([
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: refundFrange)
            
            self.lblRefundable.attributedText = refundFattributedString
            self.lblGymRefundable.attributedText = refundFattributedString
            
            let refundFtapGesture = UITapGestureRecognizer(target: self, action: #selector(self.refundhandleTap))
            let refundGymFtapGesture = UITapGestureRecognizer(target: self, action: #selector(self.refundhandleTap))
            self.lblRefundable.addGestureRecognizer(refundFtapGesture)
            self.lblGymRefundable.addGestureRecognizer(refundGymFtapGesture)
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let text = lblTermCondition.attributedText?.string else { return }
        
        let clickableText = "MyPT Personal Training Terms & Conditions"
        let range = (text as NSString).range(of: clickableText)
        
        if gesture.didTapAttributedText(in: lblTermCondition, inRange: range) {
            
            let vc: TermsConditionVC = TermsConditionVC.instantiate(appStoryboard: .purchase)
            vc.onAgreeTap = { [weak self] in
                guard let self = self else { return }
                
                self.isChecked = true
                self.btnCheck.setImage(UIImage(named: "ic_checkMark"), for: .normal)
            }
            vc.type = flowGymwork == .withoutTrainerMembership ? "memebership" : "pt"
            vc.modalPresentationStyle = .pageSheet
            
            //                   if #available(iOS 15.0, *) {
            //                       if let sheet = vc.sheetPresentationController {
            //                           sheet.detents = [.medium(), .large()]   // half + full
            //                           sheet.prefersGrabberVisible = true      // top drag indicator
            //                           sheet.preferredCornerRadius = 20        // rounded top
            //                       }
            //                   }
            
            self.present(vc, animated: true)
        }
    }
    
    @objc func refundhandleTap(_ gesture: UITapGestureRecognizer) {
        let vc: RefundVC = RefundVC.instantiate(appStoryboard: .purchase)
        vc.modalPresentationStyle = .pageSheet
        self.present(vc, animated: true)
    }
    
    private func fetchCheckoutData() {
        var baseParams: [String: Any] {
            [
                "id": previousSubscriptionID ?? "",
//                "type": inputParam?.type ?? "",
                //                "sessions": sessions ?? 0,
//                "package_type": Int(inputParam?.package_type ?? "1") ?? 1,
                //                "trainer_id": Int(inputParam?.trainer_id ?? "1") ?? 1,
//                "best_plan_id": bestPlanId ?? ""
            ]
        }
        
        var params = baseParams
        if let address = inputParam?.addressData?.id?.value {
            if inputParam?.type == "home" {
                params["address_id"] = inputParam?.addressData?.id?.value ?? 0
            }
        }
        if let studio_id = inputParam?.studio_id {
            params["studio_id"] = studio_id
        }
//        
//        if let sessions = sessions {
//            params["sessions"] = sessions
//        }
//        
//        if let trainer_id = inputParam?.trainer_id {
//            params["trainer_id"] = Int(trainer_id)
//        }
//        
//        // Scenario 2: Upgrade selected
        if let bestPlanId = selectedBestPlanId {
            params["best_plan_id"] = bestPlanId
        }
//        
//        // Scenario 3: Promo applied
//        if let offerId = selectedOfferId {
//            params["offer_id"] = "\(offerId)"
//        }
//        
//        // Scenario 4: priceForGymMembership
//        if let priceForGymMembership = inputParam?.priceForGymMembership {
//            params["price"] = priceForGymMembership
//        }
//        
//        // Scenario 5: priceForGymMembership
//        if let daysForGymMembership = inputParam?.daysForGymMembership {
//            params["days"] = daysForGymMembership
//            params["end_date"] = getEndDate(after: daysForGymMembership)
//        }
        
        PurchaseViewModel.reviewPackageCheckoutApi(
            params: params,
            isShowLoader: true
        ) { [weak self] result in
            guard
                let self = self,
                let data = result?.data
            else { return }
            self.checkoutData = data
            DispatchQueue.main.async {
                self.bindUI(with: data)
            }
        }
    }
    
    private func bindUI(with data: ReviewPackageCheckoutData) {
        if flowGymwork == .withoutTrainerMembership {
            lblGymMemberSelectedGymData.text = "\(data.studio?.name ?? "")"
            lblGymMembershipSelectedPlanType.text = "\(data.packageDetails?.packageName ?? "")"
            lblStartDateData.text = startDate
            lblEndDateData.text = convertDateFormat(getEndDate(after: data.packageDetails?.validityDays ?? 1))
            lblGymMembershipPrice.text = "AED \(data.packageDetails?.price ?? 0.0)"
        }
        
        if packageType == "1" {
            lblSolo.text = "Solo"
        } else if packageType == "2" {
            lblSolo.text = "Buddy"
        } else if packageType == "3" {
            lblSolo.text = "Group"
        }
        
        // Upgrade View visibility
        viewUpgrade.isHidden = (data.upgradePlan == nil)
        lblPlanExpired.text = data.renewal_info?.message
        // Re-apply border after text changes viewPlanExpired's height via Auto Layout
        viewPlanExpired.layoutIfNeeded()
        viewPlanExpired.cornersWithBorder(
            radius: 12,
            corners: .allCorners,
            borderColor: UIColor(red: 238/255, green: 77/255, blue: 55/255, alpha: 0.13),
            borderWidth: 3
        )

        // Upgrade section
        if let upgrade = data.upgradePlan {
            imgUpgradeCard.loadImage(urlString: upgrade.backgroundImage, placeholder: nil)
            lblUpgradeToVIP.text = upgrade.title
            lblAED.text = "Avail at " +  "\(upgrade.currency ?? "") \(upgrade.price ?? 0)" + " for"
            lblSession.text = "\(upgrade.sessions ?? 0) sessions"
            btnUpgradePlan.isHidden = false
        } else {
            btnUpgradePlan.isHidden = true
        }
        viewSavingCorner.isHidden = true
        
        // Saving Corner (Promo)
//        if let promo = data.availablePromos?.first(where: { $0.isApplied == true }) {
//            viewSavingCorner.isHidden = false
//            //            lblSavedAED.text = "AED \(promo.description ?? "0") saved with \(promo.offerCode ?? "")"
//            lblSavedAED.text = promo.offerDetails
//        } else if let promo = data.availablePromos?.first {
//            viewSavingCorner.isHidden = false
//            lblSavedAED.text = promo.offerDetails
//        } else {
//            viewSavingCorner.isHidden = true
//        }
        
        // Package Details
        if let pkg = data.packageDetails {
            imgEarlyClock.isHidden = !(pkg.is_early_renew ?? false)
            lblEarlyMsg.isHidden = !(pkg.is_early_renew ?? false)
            imgNewGymEarlyClock.isHidden = !(pkg.is_early_renew ?? false)
            lblNewGymEarlyMsg.isHidden = !(pkg.is_early_renew ?? false)
            lblNewGymEarlyMsg.text = pkg.early_renewal_text
            lblEarlyMsg.text = pkg.early_renewal_text
            lblTrainingPlace.text = "\(pkg.type ?? "") Training"
            //            lblSolo.text = "wertyui"
            lblNumSession.text = "\(pkg.totalSessions ?? 0)"
            lblMOnth.text = pkg.validity
            lblNumOfAED.text = "AED \(pkg.price ?? 0)"
            lblNewGymPrice.text = "AED \(pkg.price ?? 0)"
            //            lblRemainingSession.text = "AED \(pkg.pricePerSession?.value) / session"
            lblRemainingSession.text = "AED \(pkg.pricePerSession?.value ?? "") / session"
            lblSavedSession.text = pkg.textMsg
            lblNewGymMsg.text = pkg.textMsg
            lblNewGymValidityData.text = "\(pkg.validityDays ?? 0) days"
        }
        
        if isUpgradeSelected != false {
            if let upgradePlan = data.upgradePlan {
                lblNumSession.text = "\(upgradePlan.sessions ?? 0)"
                lblMOnth.text = upgradePlan.validity
                lblNumOfAED.text = "AED \(upgradePlan.price ?? 0)"
                lblNewGymPrice.text = "AED \(upgradePlan.price ?? 0)"
                lblRemainingSession.text = "AED \(upgradePlan.pricePerSession?.value) / session"
                lblSavedSession.text = upgradePlan.badgeText
                lblNewGymMsg.text = upgradePlan.badgeText
            }
        }
        
        // Trainer
        if let trainer = data.trainerDetail?.primaryTrainer {
            lblTrainerName.text = trainer.name
            lblSelectedGym.text = inputParam?.type == "home" ? "" : "SELECTED GYM"
            lblGymName.text = inputParam?.type == "home" ? "" : data.studio?.name
        }
        
        // Address
        if let address = data.address {
            lblLocationTYpe.text = address.type?.capitalized
            lblAdress.text = "\(address.buildingName ?? ""), \(address.villa_name ?? "") \(address.street ?? ""), \(address.emirate_name ?? "")"
        }
        
        // Footer message
        lblCancel6h.text = data.paymentMsg
        
        // ✅ Sync applied coupon state from API
        if let appliedPromo = data.availablePromos?.first(where: { $0.isApplied == true }) {
            selectedOfferId = appliedPromo.id
        } else {
            selectedOfferId = nil
        }
        
        viewTrainerLocation.isHidden = inputParam?.type != "home"
        viewNewGymMembershipDetails.isHidden = !isGymMembership
        viewPackageDetail.isHidden = isGymMembership
        lblNewGymPlanTypeData.text = "Gym Membership"
        lblNewSelectedGymData.text = data.studio?.name
        if isGymMembership {
            lblAdress.text = data.studio?.address
        }
    }
    
    func resetSelection() {
        let buttons = [btnTabby, btnTamara, btnCard]
        buttons.forEach {
            $0?.setImage(UIImage(named: "unselectedRadioBtn"), for: .normal)
        }
    }
    
    private func updateApplyCouponUI() {
        let isApplied = selectedOfferId != nil
        btnApply.setImage(
            UIImage(named: isApplied ? "appliedImg" : "btnApply"),
            for: .normal
        )
        btnApply.isUserInteractionEnabled = !isApplied
    }
    
    private func applyCouponPopUp() {
        let vc: PurchasePopupVC = PurchasePopupVC.instantiate(appStoryboard: .purchase)
        vc.modalPresentationStyle = .overCurrentContext
        vc.couponData = appliedCoupon
        vc.callBack = { [self] in
            if let coupon = appliedCoupon {
                selectedOfferId = coupon.id
            }
            // Priority 2: auto apply first promo
            else if let firstPromo = checkoutData?.availablePromos?.first {
                selectedOfferId = firstPromo.id
            }
            // No coupon available
            else {
                return
            }
            
            fetchCheckoutData()
        }
        self.present(vc, animated: true)
    }
    
    private func paymentPopUp() {
        //        vc.paymentSuccess = {[weak self] (getStatus, getTransactionId, paymetMethod) in
        //            guard let self = self else { return  }
        //
        if paymetMethod == "ccavenue" {
            //                if let pricePackage = self.slotsData?.price {
            //                    let components = pricePackage.split(separator: " ")
            let vc: CCAvenuePaymentViewController = CCAvenuePaymentViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .overFullScreen
            vc.costAmt = checkoutData?.packageDetails?.price ?? 0.0
            vc.packageDetails = checkoutData?.packageDetails
            vc.inputParam = inputParam
            vc.paymentSuccess = {[weak self] (getStatus, paymentId, orderRefId) in
                guard let self = self else { return }
                //                inputBookSlotParams?.status = getStatus ?? false ? "success" : "failed"
                //                inputBookSlotParams?.order_ref = orderRefId
                //                inputBookSlotParams?.payment_id = paymentId ?? 0
                //
                var baseParams: [String: Any] {
                    [
                        "payment_id": paymentId
                        //                "sessions": sessions ?? 0,
                        //                        "package_type": Int(inputParam?.package_type ?? "1") ?? 1,
                        //                "trainer_id": Int(inputParam?.trainer_id ?? "1") ?? 1,
                        //                        "best_plan_id": bestPlanId ?? ""
                    ]
                }
                print("Slot booking params: ",inputBookSlotParams?.getParams() ?? [:])
                
                verifyPaymentStatus(inputParams: baseParams, completion: { result in
                    if result.data?.isSuccess ?? false {
//                        if self.inputParam?.package_type == "4" {
//                            Mixpanel.mainInstance().track(
//                                event: self.inputParam?.type ?? "" == "home" ? "HomePT_Purchase_Confirmed" : "GymPT_Purchase_Confirmed ",
//                                properties: [
////                                    "plan_type": self.inputParam?.package_type == "1" ? "Solo" : self.inputParam?.package_type == "2" ? "Buddy" : "Group",
//                                    "amount": self.inputParam?.priceForGymMembership
//                                ]
//                            )
//                        } else {
//                            Mixpanel.mainInstance().track(
//                                event: self.inputParam?.type ?? "" == "home" ? "HomePT_Purchase_Confirmed" : "GymPT_Purchase_Confirmed ",
//                                properties: [
//                                    "training_type": self.inputParam?.package_type == "1" ? "Solo" : self.inputParam?.package_type == "2" ? "Buddy" : "Group",
//                                    "sessions": String(self.checkoutData?.packageDetails?.sessions ?? 0),
//                                    "amount": String(self.checkoutData?.packageDetails?.price ?? 0.0)
//                                ]
//                            )
//                        }
                        let vc:PurchaseSucessfulPaymentVC = PurchaseSucessfulPaymentVC.instantiate(appStoryboard: .purchase)
                        vc.successData = result.data
                        vc.flowGymwork = self.flowGymwork
                        self.navigationController?.pushViewController(vc, animated: false)
                    } else {
                        let vc:PurchaseFailureViewController = PurchaseFailureViewController.instantiate(appStoryboard: .purchase)
                        vc.failureData = result.data
                        vc.flowGymwork = self.flowGymwork
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                })
                //                        }else{
                //                            AlertHelper.shared.alertMesssage(view: self, title: "", message: "Please select slot")
                //                        }
            }
            self.navigationController?.present(vc, animated: true)
            //                }
        }
        else if paymetMethod == "tabby" {
            AlertHelper.shared.alertMesssage(view: self, title: "Not supported", message: "Please make the payment by card")
            //                inputBookSlotParams?.transaction_id = getTransactionId
            //                inputBookSlotParams?.price = pricePackage
            //                inputBookSlotParams?.payment_type = paymetMethod
            //
            //                print("Slot booking params: ",inputBookSlotParams?.getParams() ?? [:])
            //                if let slotId = inputBookSlotParams?.slot_id, !slotId.isEmpty {
            //                    self.bookSlot(inputParam: inputBookSlotParams?.getParams() ?? [:])
            //                }else{
            //                    AlertHelper.shared.alertMesssage(view: self, title: "", message: "Please select slot")
            //                }
            //            }
        } else { // For Tamara
            AlertHelper.shared.alertMesssage(view: self, title: "Not supported", message: "Please make the payment by card")
        }
    }
    
    @IBAction func onTapCheck(_ sender: UIButton) {
        isChecked.toggle()
        if isChecked {
            btnCheck.setImage(UIImage(named: "ic_checkMark"), for: .normal)
        } else {
            btnCheck.setImage(UIImage(named: "unselectedRadioBtn"), for: .normal)
        }
    }
    
    @IBAction func onTapConformPay(_ sender: UIButton) {
        paymentPopUp()
    }
    
    @IBAction func onTapHome(_ sender: UIButton) {
        let vc: ChooseAddressPopUpVC = ChooseAddressPopUpVC.instantiate(appStoryboard: .purchase)
        vc.isModalInPresentation = true
        vc.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        } else {
            // Fallback on earlier versions
        }
        vc.selectedAddressCallBack = { [weak self] currectAddress in
            guard let self = self else { return }
            var data = self.inputParam
            data?.addressId = currectAddress.id?.value
            data?.addressData = currectAddress
            self.inputParam = data
            self.fetchCheckoutData()
        }
        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("getResultData", getResultData.data as Any)
            let addresses = getResultData.data ?? []
            vc.addressData?.append(contentsOf: addresses)
            // Pre-select the address that was previously chosen (match by id)
            if let selectedId = self.inputParam?.addressData?.id?.value,
               let matchedIndex = addresses.firstIndex(where: { $0.id?.value == selectedId }) {
                vc.currentSelectedAddress = matchedIndex
            }
            present(vc, animated: true)
        })
    }
    
    @IBAction func onTapUpgradePlan(_ sender: UIButton) {
        guard let upgradePlanId = checkoutData?.upgradePlan?.id else {
            return
        }
        selectedBestPlanId = upgradePlanId
        btnUpgradePlan.isUserInteractionEnabled = false
        fetchCheckoutData()
    }
    
    @IBAction func onTapApplyCoupon(_ sender: UIButton) {
        // Priority 1: coupon selected from View All
        if let coupon = appliedCoupon {
            selectedOfferId = coupon.id
        }
        // Priority 2: auto apply first promo
        else if let firstPromo = checkoutData?.availablePromos?.first {
            selectedOfferId = firstPromo.id
        }
        // No coupon available
        else {
            return
        }
        
        fetchCheckoutData()
    }
    
    @IBAction func onTapViewAllCoupon(_ sender: UIButton) {
        let vc: CouponsOffersViewController =
            .instantiate(appStoryboard: .booking)
        // convert API promos → CoupenData
        if let promos = checkoutData?.availablePromos {
            
            vc.promoList = promos.map {
                CoupenData(
                    id: $0.id ?? 0,
                    offerCode: $0.offerCode ?? "",
                    expiryDate: "Expires on: \($0.expiryDate ?? "")",
                    description: $0.description ?? "",
                    isOfferForYou: true   // only this section
                )
            }
        }
        // Receive selected coupon back
        vc.sentBackCoupon = { [weak self] coupon, navVC in
            guard let self = self else { return }
            navVC.navigationController?.popViewController(animated: true)
            //            self.appliedCoupon = coupon
            //            self.selectedOfferId = coupon.id
            //            self.fetchCheckoutData()
            
            self.appliedCoupon = coupon
            
            // user selected coupon but NOT applied yet
            self.selectedOfferId = nil   // reset applied state
            
            // show Apply button again
            self.updateApplyCouponUI()
            self.fetchCheckoutData()
            
            applyCouponPopUp()
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onTapTabby(_ sender: UIButton) {
        
        // Unselect all first
        resetSelection()
        
        // Select tapped one
        sender.setImage(UIImage(named: "selectedRadio"), for: .normal)
        
        switch sender.tag {
        case 0:
            print("Tabby selected")
            paymetMethod = "tabby"
        case 1:
            print("Tamara selected")
            paymetMethod = "tamara"
        case 2:
            print("Card selected")
            paymetMethod = "ccavenue"
        default:
            break
        }
    }
    
    @IBAction func onTapBrowsePlan(_ sender: UIButton) {
        let vc: ChooseBestPlanVC = ChooseBestPlanVC.instantiate(appStoryboard: .newBookingModule)
        vc.modalPresentationStyle = .automatic
        vc.bestPlansData = checkoutData?.best_plans
        vc.selectedPlanId = selectedBestPlanId
        vc.isGymMembership = isGymMembership
        vc.onPlanSelected = { [weak self] selectedPlan in
            guard let self = self else { return }
            self.selectedBestPlanId = selectedPlan.id
            self.fetchCheckoutData()
        }
        present(vc, animated: true)
    }
    
    func getEndDate(after days: Int) -> String {
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Add days
        guard let futureDate = calendar.date(byAdding: .day, value: days, to: currentDate) else {
            return ""
        }
        
        // Format date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX") // important for server format
        
        return formatter.string(from: futureDate)
    }
    
    func convertDateFormat(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yy"
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            return outputFormatter.string(from: date)
        }
        
        return nil
    }
    
    private func verifyPaymentStatus(inputParams: [String: Any], completion: @escaping (PaymentResponse) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .paymentStatus, method: .post, queries: nil, parameters: inputParams, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: { (getResponce, error) in
            do {
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(PaymentResponse.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
                        //                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        //                        AlertHelper.shared.alertMesssage(view: self, title: "", message: errorMsg ?? "")
                    }
                }
            } catch {
                print(error)
            }
        })
    }
}
