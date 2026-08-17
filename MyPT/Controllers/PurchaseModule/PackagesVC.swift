//
//  PackagesVC.swift
//  DemoCards
//
//  Created by techsaga on 17/01/26.
//

import UIKit
import Mixpanel

class PackagesVC: CommonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var bestPlans: [BestPlanData] = []
    var customisePlans: CustoomiseData?
    var gymMembershipData: ValityPackageDetailModel?
    private var isBestPlanSelected: Bool = true
    private let scrollView = UIScrollView()
    private let indicatorImageView = UIImageView()
    private let rulerView = SessionsRulerView()
    private let valueLabel = ObservableLabel()
    private let indicator = UIView()
    var initialScrollCompleted = false
    var trainerIdStr: String?
    var studioIdStr: String?
    var inputType: String?
    var package_type: String?
    var inputParam: DetailsParam?
    var scrollAt : Int = 10
    var flowGymwork:calendarFlow = .defaultFlow
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var viewbEstPlan: UIView!
    @IBOutlet weak var collectionBestPlan:
    UICollectionView!
    @IBOutlet weak var viewCustomised: UIView!
    @IBOutlet weak var collectionCustomised: UICollectionView!
    @IBOutlet weak var viewBottom: UIView!
//    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAED: UILabel!
    @IBOutlet weak var viewCircle: UIView!
    @IBOutlet weak var lblSession: UILabel!
    @IBOutlet weak var btnContinueSummary: UIButton!
    @IBOutlet weak var viewBestPlan: UIView!
    @IBOutlet weak var btnBestPlan: UIButton!
    @IBOutlet weak var btnCustomization: UIButton!
    @IBOutlet weak var viewBottomBar: UIView!
    @IBOutlet weak var constButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var constMainViewTop: NSLayoutConstraint!
    //    @IBOutlet weak var constBottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lblselectedPlan: UILabel!
    @IBOutlet weak var lblValidFor: UILabel!
    @IBOutlet weak var imgExpandedIcon: UIImageView!
//    @IBOutlet weak var lblFaltu: UILabel!
    @IBOutlet weak var viewAED: UIView!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var viewSaveAEDBottom: UIView!
    @IBOutlet weak var lblSaveAEDBottom: UILabel!
    @IBOutlet weak var viewCustomBottom: UIView!
    @IBOutlet weak var lblCustomBottom: UILabel!
    @IBOutlet weak var viewBottomSelectionPlan: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if package_type == "4" {
            Mixpanel.mainInstance().track(
                event: "Membership_Plan_Viewed",
                properties: [:]
            )
        } else {
            Mixpanel.mainInstance().track(
                event: inputType == "home" ? "Home_Pricing_Viewed" : "GymPT_Pricing_Viewed",
                properties: [
                    "training_type": package_type == "1" ? "Solo" : package_type == "2" ? "Buddy" : "Group"
                ]
            )
        }
        if let param = inputParam {
            print("inputParam value:", param)
        } else {
            print("inputParam is nil")
        }
        
        btnDropDown.isHidden = false
        viewCircle.isHidden = false
        lblSession.isHidden = false
        lblAED.isHidden = false
        imgExpandedIcon.isHidden = false
        viewSaveAEDBottom.isHidden = true
        
        uiSetup()
        setupUI()
        viewCustomised.isHidden = true
        viewbEstPlan.isHidden = false
        viewCustomBottom.isHidden = true
        setupScrollView()
        view.layoutIfNeeded()
        scrollView.contentSize = CGSize(
            width: rulerView.intrinsicContentSize.width,
            height: scrollView.bounds.height
        )
        setupIndicator()
        viewBottomBar.isHidden = true
        constButtonBottom.constant = self.view.bounds.height > 700 ? 52 : 20
        constMainViewTop.constant = self.view.bounds.height > 700 ? 125 : 40
        //        constBottomViewHeight.constant = self.view.bounds.height > 700 ? 173 : 125
        rulerView.scrollToValue(rulerView: rulerView, scrollView: scrollView, 1)
        //        scrollToInitialValue(1)
        setBottomBarUI(isExpanded: false)
        updateContinueButton(isEnabled: true)
        setupContinueButtonIcon(isEnabled: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        viewBestPlan.layer.cornerRadius = 24
        btnBestPlan.layer.cornerRadius = 18
        btnCustomization.layer.cornerRadius = 18
        btnBestPlan.layer.masksToBounds = true
        btnCustomization.layer.masksToBounds = true
        //        btnBestPlan.backgroundColor = .white
        //        btnBestPlan.setTitleColor(.black, for: .normal)
        // Default selection
        updatePlanSelection(isBestPlanSelected: true)
        getBestPlans()
    }
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.8)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        //        self.setRighMenu(setTitle: [AppStrings.skipStr], setTintColor: .black, setTitleColor: UIColor.txtSkip)
    }
    
    private func uiSetup() {
        collectionBestPlan.delegate = self
        collectionBestPlan.dataSource = self
        collectionCustomised.delegate = self
        collectionCustomised.dataSource = self
        collectionBestPlan.register(
            UINib(nibName: "BestPlansCardCollVCell", bundle: nil),
            forCellWithReuseIdentifier: "BestPlansCardCollVCell"
        )
        collectionBestPlan.register(
            UINib(nibName: "WithoutGymBestPlanCVCell", bundle: nil),
            forCellWithReuseIdentifier: "WithoutGymBestPlanCVCell"
        )
        
        collectionCustomised.register(
            UINib(nibName: "CustomisedCollVCell", bundle: nil),
            forCellWithReuseIdentifier: "CustomisedCollVCell"
        )
        
        collectionBestPlan.clipsToBounds = false
        collectionBestPlan.layer.masksToBounds = false
        collectionBestPlan.contentInsetAdjustmentBehavior = .never
        
        collectionBestPlan.collectionViewLayout = createCarouselLayout()
        collectionBestPlan.decelerationRate = .fast
        collectionBestPlan.showsHorizontalScrollIndicator = false
        self.lblHeading.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.lblAED.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        self.lblSession.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        self.viewCircle.makeCircular()
        self.btnBestPlan.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.btnCustomization.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
//        self.btnContinueSummary.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
//        self.btnContinueSummary.setTitle("CONTINUE TO SUMMARY  ", for: .normal)
//        self.btnContinueSummary.setImage(UIImage(named: "ButtonContinueToSummary"), for: .normal)
//        self.btnContinueSummary.semanticContentAttribute = .forceRightToLeft
//        self.lblFaltu.font = AppFont.regular.size(14.0, familyName: familyClashDisplay)
//        self.btnContinueSummary.tintColor = .mainBg   // arrow color
//        self.btnContinueSummary.backgroundColor = .appWhite
//        self.btnContinueSummary.setTitleColor(.mainBg, for: .normal)
        lblSaveAEDBottom.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        lblValidFor.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        //        self.sessionSuccessfullyMBV.backgroundColor = .divideLineColor
    }
    
    private func setupUI() {
        self.btnContinueSummary.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnContinueSummary.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
    }
    
    @IBAction func onTapExandAction(_ sender: UIButton) {
        setBottomBarUI(isExpanded: self.lblselectedPlan.isHidden)
    }
    
    func setBottomBarUI(isExpanded : Bool) {
        self.lblselectedPlan.isHidden = !isExpanded
        lblValidFor.isHidden = !isExpanded
        imgExpandedIcon.image = UIImage(named: isExpanded ? "ic_downArrow" : "ic_arrow_up_White")
        viewSaveAEDBottom.isHidden = !isExpanded
    }
    
    private func createCarouselLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(258),
            //            widthDimension: .absolute(294),
            heightDimension: .absolute(338)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        //  KEY FIXES
        section.interGroupSpacing = 18   //  was 20 (too much)
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 10,   //  reduced (cell already has 18)
            bottom: 16,
            trailing: 10
        )
        
        section.visibleItemsInvalidationHandler = { [weak self] items, offset, env in
            guard let self = self else { return }
            
            let centerX = offset.x + env.container.contentSize.width / 2
            
            var closestItem: NSCollectionLayoutVisibleItem?
            var minDistance: CGFloat = .greatestFiniteMagnitude
            
            for item in items {
                let distance = abs(item.frame.midX - centerX)
                
                if distance < minDistance {
                    minDistance = distance
                    closestItem = item
                }
                
                // 🔹 Card lift effect
                let maxDistance = item.frame.width + 18
                let ratio = min(distance / maxDistance, 1)
                let yOffset = ratio * 26
                
                item.transform = CGAffineTransform(translationX: 0, y: yOffset)
                item.zIndex = Int((1 - ratio) * 10)
            }
            
            // ✅ DATA UPDATE FOR CENTER CARD
            if let indexPath = closestItem?.indexPath {
                DispatchQueue.main.async {
                    self.updateBottomData(for: indexPath.item)
                }
            }
        }
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func updateBottomData(for index: Int) {
        guard bestPlans.indices.contains(index) else { return }
        
        let plan = bestPlans[index]
        
        lblAED.text = "\(plan.currency ?? "") \(plan.price ?? "")"
        lblSession.text = flowGymwork == .withoutTrainerMembership
        ? "\(plan.validityDays ?? "") Days"
        : "\(plan.sessions ?? "") Sessions"
//        lblSession.text = "\(plan.sessions ?? "") Sessions"
        lblValidFor.text = plan.validityText

        if let amount = extractAEDAmount(from: plan.badgeText ?? "") {
            print(amount) // 300.50
//            lblSaveAEDBottom.text = "You save AED " + (amount) + " — that's 6 free sessions ✨"
            lblSaveAEDBottom.text = "You save AED " + (amount) + " ✨"
        }

//        lblSaveAEDBottom.text = "You save AED" + (plan.badgeText ?? "") + " — that's 6 free sessions ✨"
    }
    
    func extractAEDAmount(from text: String) -> String? {

        let pattern = #"AED\s*([0-9]+(?:\.[0-9]+)?)"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }

        return String(text[range])
    }
    
    
    private func updatePlanSelection(isBestPlanSelected: Bool) {
        self.isBestPlanSelected = isBestPlanSelected
        let darkColor = UIColor(
            red: 24/255,
            green: 29/255,
            blue: 32/255,
            alpha: 1
        )
        
        if isBestPlanSelected {
            // Best Plan Selected
            btnBestPlan.backgroundColor = .white
            btnBestPlan.setTitleColor(.black, for: .normal)
            
            btnCustomization.backgroundColor = darkColor
            btnCustomization.setTitleColor(.white, for: .normal)
            
            viewCustomised.isHidden = true
            viewbEstPlan.isHidden = false
            //            lblFaltu.text = "label"
            //            lblFaltu.textColor = UIColor(red: 224/255, green: 254/255, blue: 8/255, alpha: 1)
            btnDropDown.isHidden = false
            viewCircle.isHidden = false
            lblSession.isHidden = false
            lblAED.isHidden = false
            imgExpandedIcon.isHidden = false
            viewCustomBottom.isHidden = true
            viewBottomSelectionPlan.isHidden = false
            self.lblAED.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
            getBestPlans()
//            lblFaltu.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        } else {
            // Customization Selected
            btnCustomization.backgroundColor = .white
            btnCustomization.setTitleColor(.black, for: .normal)
            
            btnBestPlan.backgroundColor = darkColor
            btnBestPlan.setTitleColor(.white, for: .normal)
            
            viewCustomised.isHidden = false
            viewbEstPlan.isHidden = true
            initialScrollCompleted = false
            DispatchQueue.main.async {
                self.rulerView.scrollToValue(rulerView: self.rulerView, scrollView: self.scrollView, self.scrollAt)
            }
            if flowGymwork == .withoutTrainerMembership {
                customisePlansForGymMembership(days: "\(self.scrollAt)")
            } else {
                customisePlansType(session: "\(self.scrollAt)")
            }
            //            lblFaltu.text = "Validity and savings increase with more sessions"
            //            lblFaltu.textColor = UIColor(red: 179/255, green: 179/255, blue: 179/255, alpha: 1)
            btnDropDown.isHidden = true
            viewCircle.isHidden = true
            lblSession.isHidden = true
            imgExpandedIcon.isHidden = true
            viewSaveAEDBottom.isHidden = true
            viewCustomBottom.isHidden = false
            viewBottomSelectionPlan.isHidden = true
            lblCustomBottom.text = flowGymwork == .withoutTrainerMembership ? "Savings increase with more days" : "Validity and savings increase with more sessions"
            lblCustomBottom.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        }
        
        
        
        viewBottomBar.isHidden = isBestPlanSelected
        updateScrollBarUI()
    }
    
    
    func updateContinueButton(isEnabled: Bool) {
        btnContinueSummary.isEnabled = isEnabled
        btnContinueSummary.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.btnContinueSummary.tintColor = .mainBg   // arrow color
                self.btnContinueSummary.backgroundColor = .appWhite
                self.btnContinueSummary.setTitleColor(.mainBg, for: .normal)
            } else {
                self.btnContinueSummary.tintColor = .appWhite
                self.btnContinueSummary.backgroundColor = .appDarkGray
                self.btnContinueSummary.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        if isEnabled {
            // 🟢 ENABLED → IMAGE ONLY
            btnContinueSummary.setTitle("CONTINUE TO SUMMARY", for: .normal)
            btnContinueSummary.setTitleColor(.black, for: .normal)

            let arrowImage = UIImage(named: "blackRightArrow")?
                .withRenderingMode(.alwaysOriginal)
            btnContinueSummary.setImage(arrowImage, for: .normal)

            btnContinueSummary.semanticContentAttribute = .forceRightToLeft

            // spacing between text & arrow
            btnContinueSummary.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            btnContinueSummary.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            btnContinueSummary.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        } else {
            // 🔴 DISABLED → TEXT + ARROW
            btnContinueSummary.setTitle("CONTINUE TO SUMMARY", for: .normal)
            btnContinueSummary.setTitleColor(.appWhite, for: .normal)

            let arrowImage = UIImage(named: "whiteRightArrow")?
                .withRenderingMode(.alwaysOriginal)
            btnContinueSummary.setImage(arrowImage, for: .normal)

            btnContinueSummary.semanticContentAttribute = .forceRightToLeft

            // spacing between text & arrow
            btnContinueSummary.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            btnContinueSummary.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            btnContinueSummary.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    // MARK: - API's
    private func getBestPlans() {
        let params: [String: String] = [
            "package_type": package_type ?? "1", // 4 -> Gym membership
            "type": inputType ?? "home"
        ]
        
        PurchaseViewModel.bestPlanApi(params: params) { [weak self] result in
            guard let self = self else { return }
            
            if let plans = result?.data {
                self.bestPlans = plans
                self.collectionBestPlan.reloadData()
                DispatchQueue.main.async {
                    self.updateContinueButton(isEnabled: self.bestPlans.isEmpty ? false : true)
                    self.setupContinueButtonIcon(isEnabled: self.bestPlans.isEmpty ? false : true)
                    self.updateBottomLabelsForBestPlan()
                }
            } else {
                DispatchQueue.main.async {
                    self.updateContinueButton(isEnabled: false)
                    self.setupContinueButtonIcon(isEnabled: false)
                }
            }
        }
    }
    
    private func customisePlansForGymMembership(days: String) {
        let params: [String: String] = [
            "studio_id": inputParam?.studio_id ?? "1",
            "days": days
        ]
        
        PurchaseViewModel.customisePlansForGymMembership(params: params) { [weak self] result in
            guard let self = self else { return }
            if let customisePlan = result?.data {
                self.gymMembershipData = customisePlan.packageDetail
                DispatchQueue.main.async {
                    self.updateContinueButton(isEnabled: self.gymMembershipData == nil ? false : true)
                    self.setupContinueButtonIcon(isEnabled: self.gymMembershipData == nil ? false : true)
                }
                self.collectionCustomised.reloadData()
            } else {
                DispatchQueue.main.async {
                    self.updateContinueButton(isEnabled: false)
                    self.setupContinueButtonIcon(isEnabled: false)
                }
            }
        }
    }
    
    private func customisePlansType(session: String) {
        let params: [String: String] = [
            "package_type": package_type ?? "1",
            "type": inputType ?? "home",
            "sessions": session
        ]
        
        PurchaseViewModel.customisePlanApi(params: params) { [weak self] result in
            guard let self = self else { return }
            
            if let customisePlan = result?.data {
                self.customisePlans = customisePlan
                //                if customisePlan.details?.sessions == "1" && !initialScrollCompleted {
                //                }
                DispatchQueue.main.async {
                    self.updateContinueButton(isEnabled: self.customisePlans == nil ? false : true)
                    self.setupContinueButtonIcon(isEnabled: self.customisePlans == nil ? false : true)
                }
                self.collectionCustomised.reloadData()
            } else {
                DispatchQueue.main.async {
                    self.updateContinueButton(isEnabled: false)
                    self.setupContinueButtonIcon(isEnabled: false)
                }
            }
        }
    }
    
    private func getCenterBestPlanIndex() -> Int {
        let centerPoint = CGPoint(
            x: collectionBestPlan.bounds.midX + collectionBestPlan.contentOffset.x,
            y: collectionBestPlan.bounds.midY
        )
        
        return collectionBestPlan.indexPathForItem(at: centerPoint)?.row ?? 0
    }
    
    private func updateBottomLabelsForBestPlan() {
        guard isBestPlanSelected else { return }
        
        let index = getCenterBestPlanIndex()
        guard bestPlans.indices.contains(index) else { return }
        
        let plan = bestPlans[index]
        
        // AED price
        lblAED.text = "\(plan.currency ?? "") \(plan.price ?? "")"
        
        // Sessions
        lblSession.text = flowGymwork == .withoutTrainerMembership
        ? "\(plan.validityDays ?? "") Days"
        : "\(plan.sessions ?? "") Sessions"
        
        // Validity
        lblValidFor.text = plan.validityText
    }
    
    // MARK: - @IBAction
    @IBAction func onTapBestPlan(_ sender: UIButton) {
        updatePlanSelection(isBestPlanSelected: sender.tag == 0)
    }
    
    @IBAction func onTapContinueSummary(_ sender: UIButton) {
        let vc: PurchaseReviewPackageVC = PurchaseReviewPackageVC.instantiate(appStoryboard: .purchase)
        //        vc.addressId = inputParam?.addressId
        //        vc.studioId = inputParam?.studio_id
        vc.type = inputParam?.type ?? "home"
        vc.packageType = inputParam?.package_type ?? "1"
        vc.trainerId = Int(trainerIdStr ?? "0")
        
        vc.studioId = studioIdStr
        
        vc.inputParam = inputParam
        vc.flowGymwork = flowGymwork
        
        if isBestPlanSelected {
            //  BEST PLAN CASE
            let index = getCenterBestPlanIndex()
            let selectedPlan = bestPlans[index]
            if flowGymwork == .withoutTrainerMembership {
                var params = inputParam
                params?.daysForGymMembership = Int(selectedPlan.validityDays ?? "")
                params?.priceForGymMembership = Int(selectedPlan.price ?? "")
                vc.inputParam = params
            } else {
                vc.sessions = Int(selectedPlan.sessions ?? "0") ?? 0
            }
            //                vc.sessions = selectedPlan.sessions ?? 0
            vc.bestPlanId = selectedPlan.id
            
        } else {
            //  CUSTOMISE PLAN CASE
            if flowGymwork == .withoutTrainerMembership {
                var params = inputParam
                params?.daysForGymMembership = Int(gymMembershipData?.validity?.value ?? "")
                params?.priceForGymMembership = Int(gymMembershipData?.price?.value ?? "")
                vc.inputParam = params
                vc.bestPlanId = nil
            } else {
                let sessions = Int(customisePlans?.details?.sessions ?? "1") ?? 1
                vc.sessions = sessions
                vc.bestPlanId = nil
            }
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionBestPlan {
            let count = bestPlans.count
            if count == 0 {
                collectionView.showEmptyView(
                    title: "No Best plans Found",
                    image: AppImages.search_NoResult,
                    centerOffset: -100   // adjust if needed
                )
            } else {
                collectionView.restoreEmptyView()
            }
            return count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == collectionBestPlan {
            if flowGymwork == .withoutTrainerMembership {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "WithoutGymBestPlanCVCell",
                    for: indexPath
                ) as! WithoutGymBestPlanCVCell
                
                cell.configure(with: bestPlans[indexPath.row])
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "BestPlansCardCollVCell",
                    for: indexPath
                ) as! BestPlansCardCollVCell
                
                cell.configure(with: bestPlans[indexPath.row])
                
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CustomisedCollVCell",
                for: indexPath
            ) as! CustomisedCollVCell
            if flowGymwork == .withoutTrainerMembership {
                cell.cellGymMembershipConfigure(customData: self.gymMembershipData)
            } else {
                cell.cellConfigure(customData: self.customisePlans)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 400, height: 154)
    }
    
}

extension PackagesVC {
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.decelerationRate = .fast
        
        indicatorImageView.image = UIImage(named: "verticalSlider")
        indicatorImageView.contentMode = .scaleAspectFit
        indicatorImageView.transform = CGAffineTransform(rotationAngle: .pi / 2)
        
        viewBottomBar.addSubview(scrollView)
        scrollView.addSubview(rulerView)
        viewBottomBar.addSubview(indicatorImageView)
        rulerView.sessionType = flowGymwork == .withoutTrainerMembership ? .days : .session
        rulerView.translatesAutoresizingMaskIntoConstraints = false
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // ScrollView frame (viewport)
            scrollView.leadingAnchor.constraint(equalTo: viewBottomBar.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: viewBottomBar.trailingAnchor),
            scrollView.centerYAnchor.constraint(equalTo: viewBottomBar.centerYAnchor, constant: -65),
            scrollView.heightAnchor.constraint(equalToConstant: 80),
            
            // RulerView content
            rulerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            rulerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            rulerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            rulerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            rulerView.widthAnchor.constraint(equalToConstant: rulerView.intrinsicContentSize.width),
            
            // Indicator image
            indicatorImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            indicatorImageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: 50),
            indicatorImageView.widthAnchor.constraint(equalToConstant: 270),
            indicatorImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    
    private func setupIndicator() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = .clear
        
        viewBottomBar.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: 20),
            indicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0),
            indicator.widthAnchor.constraint(equalToConstant: 2),
            indicator.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Gradient fade layer
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.white.withAlphaComponent(0.6).cgColor,
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        
        // Horizontal fade
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        
        // Important: frame set after layout
        DispatchQueue.main.async {
            gradient.frame = self.indicator.bounds
        }
        indicator.layer.addSublayer(gradient)
        setupValueLabel(indicator: indicator)
    }
    
    
    private func setupValueLabel(indicator : UIView) {
        valueLabel.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textColor = UIColor(red: 214/255, green: 244/255, blue: 7/255, alpha: 1)
        valueLabel.text = "\(rulerView.selectedValue ?? 0)"
        viewBottomBar.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.centerYAnchor.constraint(equalTo: indicator.centerYAnchor, constant: -40),
            valueLabel.centerXAnchor.constraint(equalTo: indicator.centerXAnchor)
        ])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        TapticEngine.selection.feedback()
        let centerX =
        scrollView.contentOffset.x
        + scrollView.bounds.width / 2
        - scrollView.contentInset.left
        - rulerView.edgePaddingUnits.cgFloat   // IMPORTANT
        
        let index = Int(
            round(centerX / rulerView.lineSpacing)
        )
        
        let rawValue = index + rulerView.minValue
        
        // Clamp to VISIBLE range only
//        let displayValue = max(0, min(rawValue, 100))
        let displayValue = max(0, min(rawValue, rulerView.sessionType == .session ? 100 : 365))
        
        rulerView.selectedValue = displayValue
        valueLabel.text = "\(displayValue)"
//        customisePlansType(session: "\(displayValue)")
    }
    
    
    func updateScrollBarUI() {
        let currentStatus = self.viewBottomBar.isHidden
        self.scrollView.isHidden = currentStatus
        self.valueLabel.isHidden = currentStatus
        self.rulerView.isHidden = currentStatus
        self.indicator.isHidden = currentStatus
        self.indicatorImageView.isHidden = currentStatus
    }
}

//extension PackagesVC: UIScrollViewDelegate {
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let sessionValue = "\(rulerView.selectedValue ?? 0)"
//        customisePlansType(session: sessionValue)
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
//                                  willDecelerate decelerate: Bool) {
//        if !decelerate {
//            let sessionValue = "\(rulerView.selectedValue ?? 0)"
//            customisePlansType(session: sessionValue)
//        }
//    }
//}
extension PackagesVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView === collectionBestPlan {
            // ✅ Best plan carousel stopped
            updateBottomLabelsForBestPlan()
            
        } else if scrollView === self.scrollView {
            // ✅ Custom slider stopped
            let sessionValue = "\(rulerView.selectedValue ?? 0)"
            if flowGymwork == .withoutTrainerMembership {
                customisePlansForGymMembership(days: sessionValue)
            } else {
                customisePlansType(session: sessionValue)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        
        guard !decelerate else { return }
        
        if scrollView === collectionBestPlan {
            // ✅ Best plan carousel stopped (no deceleration)
            updateBottomLabelsForBestPlan()
            
        } else if scrollView === self.scrollView {
            // ✅ Custom slider stopped (no deceleration)
            let sessionValue = "\(rulerView.selectedValue ?? 0)"
            if flowGymwork == .withoutTrainerMembership {
                customisePlansForGymMembership(days: sessionValue)
            } else {
                customisePlansType(session: sessionValue)
            }
        }
    }
}
