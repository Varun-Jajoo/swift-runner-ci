//
//  TopUpgradeSessionViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/07/25.
//

import UIKit

enum ChoosePlanFlow: CaseIterable {
    case topUp
    case upgrade
    case gymWorkoutPlan
    case homeWorkoutPlan
    case renew
    case choosePlanDefault
    
    var stringValue: String {
        switch self {
        case .topUp:
            return "Top-Up"
        case .upgrade:
            return "Upgrade"
        case .gymWorkoutPlan:
            return "Home Workout"
        case .homeWorkoutPlan:
            return "Gym Workout"
        case .renew:
            return "renew"
        case .choosePlanDefault:
            return "Choose Plan Default"
        }
    }
    
    init(from string: String) {
        if let match = ChoosePlanFlow.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(string) == .orderedSame }) {
            self = match
        } else {
            self = .choosePlanDefault
        }
    }
}

class TopUpgradeSessionViewController: CommonViewController {
    
    //MARK: -------------- VARIABLE
    var planFlow: ChoosePlanFlow = .choosePlanDefault
    var isShowTotalCost:Bool = false{
        didSet{
            self.setTotalCost(isTotalCost: isShowTotalCost)
        }
    }
    private var lastNoteStrScroll: Int? = nil
    var noteStrScroll: Int? = 0 {
        didSet {
            // Check if new value is different and valid
            guard let newValue = noteStrScroll,
                  newValue != lastNoteStrScroll,
                  newValue >= 0,
                  newValue < noteStrings.count else {
                return
            }
            // Update tracker and call scrollText
            lastNoteStrScroll = newValue
            scrollText(indx: newValue)
        }
    }
    var isCurrentSession: Bool?
    var isNotScroll: Bool?
    private var lastValidValue: Float = 0.0
    private var minAllowedValue: Float = 0.0
    private var localExistDays: String?
    private var increaseSession: Int = 0 {
        didSet{
            upgradeParams?.sessions = "\(increaseSession)"
            if increaseSession == 0 {
                self.enableContinueBtn(isSelected: false)
            }else{
                self.enableContinueBtn(isSelected: true)
            }
        }
    }
    var tagsData: [TrainerTagModel]? = []
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    var sessionCost:[String] = ["0.0"]
    var noteStrings = ["Increase session count for lower per session cost", "The validity of the package also determines the access period for the trainer"]
    var noteStringsCount:Int = -1
    var upgradeDetails: UpgradePlanDetailsModel?
    var upgradeParams: UpgradePlanParamModel? {
        didSet{
            self.upgradeParams?.days = "0"
            self.upgradeApi(inputParams: upgradeParams)
        }
    }
    
    private let tooltipView: UIView = {
        let vv = UIView()
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1)
        label.textAlignment = .center
        label.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        label.text = "Save 0%"
        label.tag = 100
        label.layer.masksToBounds = true
        label.frame.size = CGSize(width: 90, height: 35)
        label.setCornerRadius(borderWidth: 2.0, borderColor: UIColor(red: 158/255, green: 188/255, blue: 255/255, alpha: 1), cornerRadious: 17.5)
        vv.frame = CGRect(x: 5, y: 5, width: label.frame.width, height: label.frame.height - 10)
        
        vv.addSubview(label)
        return vv
    }()
    
    //MARK: ---------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userTagsCollView: UICollectionView!
    @IBOutlet weak var userEditBtn: UIButton!
    @IBOutlet weak var userDetailsMBV: UIView!
    @IBOutlet weak var planChooseMBV: UIView!
    @IBOutlet weak var outerPlanNoteMBV: UIView!
    @IBOutlet weak var planNoteMBV: UIView!
    @IBOutlet weak var planDescMBV: UIView!
    @IBOutlet weak var costSessionMBV: UIView!
    @IBOutlet weak var saveMBV: UIView!
    @IBOutlet weak var perSessionCostLbl: UILabel!
    @IBOutlet weak var totalCostLbl: UILabel!
    @IBOutlet weak var showMinValueLbl: UILabel!
    @IBOutlet weak var showMaxValueLbl: UILabel!
    @IBOutlet weak var sessionCountLbl: UILabel!
    @IBOutlet weak var sessionCostLbl: UILabel!
    @IBOutlet weak var sessionAmt: CustomPickerView!
    @IBOutlet weak var sessionAmtWidthConstrnt: NSLayoutConstraint!
    @IBOutlet weak var costChooseSwtch: CustomSwipeSwitch!
    @IBOutlet weak var planNoteLbl: UILabel!
    @IBOutlet weak var planDescBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var costSlider: UISlider!
    @IBOutlet weak var planNoteMBVTopConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.localExistDays = self.upgradeParams?.days
        self.isCurrentSession = true
        self.increaseSession = 0
        self.setupUI()
        self.setUpFont()
        self.flowPlanSetup()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.planChooseMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.planChooseMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            self.planChooseMBV.setGradientMultiBorder(cornerRadius: 12, width: 2.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
        }
        if let thumbImage = UIImage(named: "ic_Slider") {
            self.costSlider.setThumbImage(thumbImage, for: .normal)
        }
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        //        if let localExistDays = self.localExistDays {
        //            self.upgradeParams?.days = localExistDays
        //        }
    }
    
    private func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func leftBtnActn(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func flowPlanSetup(){
        self.planDescMBV.isHidden = true
        self.userDetailsMBV.isHidden = true
        self.planNoteMBV.isHidden = true
        self.topTitleLbl.text = "Choose total sessions"
        self.setTotalCost(isTotalCost: isShowTotalCost)
        self.planDescBtn.titleLabel?.textAlignment = .center
        self.planDescBtn.setTitle("Not sure what you want?  Consult an expert", for: .normal)
        self.self.planDescBtn.setImage(UIImage(named: "ic_rightArrow_yellow"), for: .normal)
        //-----------------------###############
        switch planFlow {
        case .topUp:
            self.planNoteMBV.isHidden = false
            self.planDescMBV.isHidden = false
            self.topTitleLbl.text = "Enter number of sessions to top up"
            self.planDescBtn.setTitle("Available top-ups are based on your active package validity.", for: .normal)
            self.self.planDescBtn.setImage(nil, for: .normal)
            self.noteStrings.removeAll()
            self.noteStrings.append("Remaining sessions expire when the package ends.")
            scrollText(indx: 1)
            self.planNoteMBVTopConstrnt.constant = 32
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%"
            }
            //--------------------Data Setup
            costSlider.minimumValue = 0 //Float(upgradeDetails?.current_sessions?.value ?? "0.0") ?? 1.0
            costSlider.maximumValue = Float(upgradeDetails?.max_sessions?.value ?? "0.0") ?? 20.0
            //--------------- only first time slider load
            if let currentSession = upgradeDetails?.current_sessions?.value, let _ = isCurrentSession {
                self.isCurrentSession = nil
                self.lastValidValue = Float(currentSession) ?? 1.0
                self.minAllowedValue = self.lastValidValue
                self.costSlider.setValue(Float(upgradeDetails?.current_sessions?.value ?? "0.0") ?? 1.0, animated: true)
                self.costSlider.sendActions(for: .valueChanged)
            }
            self.showMinValueLbl.text = "0" //upgradeDetails?.current_sessions?.value
            self.showMaxValueLbl.text = upgradeDetails?.max_sessions?.value
            self.costSlider.isUserInteractionEnabled = true
            break
        case .upgrade:
            sessionAmt.items = sessionCost
            // Initially center the picker at the first item
            sessionAmt.scrollToRow(0)
            self.planNoteMBVTopConstrnt.constant = 32
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%"
            }
            //            self.planDescBtn.setTitle("Available top-ups are based on your active package validity.", for: .normal)
            //            self.self.planDescBtn.setImage(nil, for: .normal)
            //--------------------Data Setup
            self.topTitleLbl.text = "Choose total sessions"
            costSlider.minimumValue = 0 //Float(upgradeDetails?.current_sessions?.value ?? "0.0") ?? 1.0
            costSlider.maximumValue = Float(upgradeDetails?.max_sessions?.value ?? "0.0") ?? 20.0
            //--------------- only first time slider load
            if let currentSession = upgradeDetails?.current_sessions?.value, let _ = isCurrentSession {
                self.isCurrentSession = nil
                self.lastValidValue = Float(currentSession) ?? 1.0
                self.minAllowedValue = self.lastValidValue
                self.costSlider.setValue(Float(upgradeDetails?.current_sessions?.value ?? "0.0") ?? 1.0, animated: true)
                self.costSlider.sendActions(for: .valueChanged)
            }
            self.showMinValueLbl.text = "0" //upgradeDetails?.current_sessions?.value
            self.showMaxValueLbl.text = upgradeDetails?.max_sessions?.value
            self.costSlider.isUserInteractionEnabled = true
            self.planNoteMBV.isHidden = false
            self.noteStrings.removeAll()
            self.noteStrings.append("Increase session count for lower per session cost")
            scrollText(indx: 1)
            self.setTotalCost(isTotalCost: isShowTotalCost)
            //-------------------- Continue btn
            if let _ = upgradeDetails?.price?.value , let currentSession = upgradeDetails?.current_sessions?.value, let maxSession = upgradeDetails?.max_sessions?.value, (Float(currentSession) ?? 0.0) > (Float(maxSession) ?? 0.0) {
                self.enableContinueBtn(isSelected: false)
            }else{
                if increaseSession > 0 {
                    self.enableContinueBtn(isSelected: true)
                }else{
                    self.enableContinueBtn(isSelected: false)
                }
            }
            break
            
        case .gymWorkoutPlan:
            self.userDetailsMBV.isHidden = false
            self.planNoteMBVTopConstrnt.constant = 12
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%"
            }
            self.sessionCountLbl.text = "1 sessions"
            break
        case .homeWorkoutPlan:
            print("homeWorkoutPlan....")
            self.userDetailsMBV.isHidden = false
            self.planNoteMBVTopConstrnt.constant = 12
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%"
            }
            self.sessionCountLbl.text = "1 sessions"
            break
            
        case .renew:
            self.planNoteMBV.isHidden = true
            sessionAmt.items = sessionCost
            // Initially center the picker at the first item
            sessionAmt.scrollToRow(0)
            self.planNoteMBVTopConstrnt.constant = 32
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%"
            }
            //--------------------Data Setup
            self.topTitleLbl.text = "Choose total sessions"
            costSlider.minimumValue = 0 //Float(upgradeDetails?.current_sessions?.value ?? "0.0") ?? 1.0
            costSlider.maximumValue = Float(upgradeDetails?.max_sessions?.value ?? "0.0") ?? 20.0
            //--------------- only first time slider load
            if let currentSession = upgradeDetails?.current_sessions?.value, let _ = isCurrentSession {
                self.isCurrentSession = nil
                self.lastValidValue = Float(currentSession) ?? 1.0
                self.minAllowedValue = self.lastValidValue
                self.costSlider.setValue(Float(upgradeDetails?.current_sessions?.value ?? "0.0") ?? 1.0, animated: true)
                self.costSlider.sendActions(for: .valueChanged)
            }
            self.showMinValueLbl.text = "0"
            self.showMaxValueLbl.text = upgradeDetails?.max_sessions?.value
            self.costSlider.isUserInteractionEnabled = true
            //            self.noteStrings.removeAll()
            //            self.noteStrings.append("Increase session count for lower per session cost")
            //            scrollText(indx: 1)
            self.setTotalCost(isTotalCost: isShowTotalCost)
            //-------------------- Continue btn
            /*
             if let _ = upgradeDetails?.price?.value , let currentSession = upgradeDetails?.current_sessions?.value, let maxSession = upgradeDetails?.max_sessions?.value, (Float(currentSession) ?? 0.0) > (Float(maxSession) ?? 0.0) {
             self.enableContinueBtn(isSelected: false)
             }else{
             self.enableContinueBtn(isSelected: true)
             }
             */
        case .choosePlanDefault:
            print("None....")
            self.planNoteMBVTopConstrnt.constant = 32
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%"
            }
            self.sessionCountLbl.text = "1 sessions"
            break
        }
    }
    
    @IBAction func userDetailsEditBtnActn(_ sender: Any) {
        print("User details btn actn.......")
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        switch planFlow {
        case .topUp:
            if let priceStr = upgradeDetails?.price?.value {
                let vc: TopReviewPackageViewController = TopReviewPackageViewController.instantiate(appStoryboard: .dashboard)
                vc.planFlow = self.planFlow
                vc.inputType = upgradeParams?.type
                vc.inputId = upgradeParams?.id
                vc.inputPrice = priceStr
                vc.inputSessions = upgradeParams?.sessions
                vc.inputDays = upgradeParams?.days
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .upgrade:
            print("Upgrade....")
            if let _ = upgradeDetails?.price?.value , let currentSession = upgradeDetails?.current_sessions?.value, let maxSession = upgradeDetails?.max_sessions?.value, (Float(currentSession) ?? 0.0) < (Float(maxSession) ?? 0.0) {
                let vc: UserPlansValidityViewController = UserPlansValidityViewController.instantiate(appStoryboard: .dashboard)
                vc.upgradeParams = self.upgradeParams
                vc.planFlow = self.planFlow
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .renew, .gymWorkoutPlan, .homeWorkoutPlan:
            //            if let _ = upgradeDetails?.price?.value , let currentSession = upgradeDetails?.current_sessions?.value, let maxSession = upgradeDetails?.max_sessions?.value, (Float(currentSession) ?? 0.0) < (Float(maxSession) ?? 0.0) {
            if let _ = upgradeDetails?.price?.value , let currentSession = upgradeDetails?.current_sessions?.value {
                let vc: UserPlansValidityViewController = UserPlansValidityViewController.instantiate(appStoryboard: .dashboard)
                vc.upgradeParams = self.upgradeParams
                vc.planFlow = self.planFlow
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .choosePlanDefault:
            print("None....")
        }
        
        //        let vc: UserPlansValidityViewController = UserPlansValidityViewController.instantiate(appStoryboard: .dashboard)
        //        vc.upgradeParams = self.upgradeParams
        //        vc.planFlow = self.planFlow
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func costSliderActn(_ sender: UISlider) {
        let row = Int(sender.value)
        guard sender.maximumValue > 1 else { return }
        //        self.sessionCountLbl.text = (upgradeDetails?.current_sessions?.value ?? "") + " sessions"
        //---------------------*************
        // Update tooltip text
        let percentage = Int(sender.value / sender.maximumValue * 100)
        if let label = tooltipView.viewWithTag(100) as? UILabel {
            label.text = "Save 20%" //"Save \(percentage)%"
        }
        
        if percentage > 60 {
            self.sessionCountLbl.text = "\(row) sessions"
            self.sessionCountLbl.textAlignment = .right
            self.startScrolling()
            noteStrScroll = 1
        }else{
            self.sessionCountLbl.text = "\(row) sessions"
            self.sessionCountLbl.textAlignment = .left
            self.startScrolling()
            noteStrScroll = 0
        }
        updateTooltipPosition()
    }
    
    //MARK: -----------COST SLIDER ACTN
    @objc func sliderTouchEnded(_ sender: UISlider) {
        //-----------------------
        let upgradeSessions = sender.value - (Float(upgradeDetails?.current_sessions?.value ?? "0.0") ?? 0.0)
        if sender.value <= sender.maximumValue, Int(sender.value) > 0 && Int(upgradeSessions) > 0 {
            // Prevent sliding below
            self.increaseSession = Int(upgradeSessions)
        }else{
            self.increaseSession = Int(upgradeSessions)
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        if currentValue < minAllowedValue {
            // Prevent sliding below
            sender.setValue(lastValidValue, animated: false)
            return
        }
        // Allow updating if value is >=
        sessionCountLbl.text = "\(Int(currentValue)) sessions"
    }
    
    //MARK: -------------------MAKE SCROLLABLE TEXT
    func scrollText(indx:Int){
        guard indx != self.noteStringsCount else { return }
        self.noteStringsCount = indx > 0 ? indx : 0
        self.planNoteLbl.animateTextScroll(strings: self.noteStrings, selectedIndex:  self.noteStringsCount, animationDuration: 0.4) {
            print("Text scrolling completed!")
        }
    }
    
    //MARK: --------------ANIMATED MONTH LABEL
    func startScrolling() {
        let totalHeight = sessionCountLbl.frame.height
        let visibleHeight = 10.0
        self.sessionCountLbl.alpha = 0
        // Calculate the time it takes to scroll through the entire text
        let duration = Double(totalHeight + visibleHeight) / 30.0 // Adjust speed (30 points per second)
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            self.sessionCountLbl.alpha = 1.0
        }, completion: nil)
    }
    
    private func setTotalCost(isTotalCost:Bool){
        //-------------------- Cost
        let costAmt:String = isShowTotalCost ? "\(self.upgradeDetails?.price?.value ?? "")" : "\(self.upgradeDetails?.per_session_cost?.value ?? "")"
        self.sessionCost.removeAll()
        self.sessionCost.append(costAmt)
        sessionAmt.items = sessionCost
        sessionAmt.layoutIfNeeded()
        sessionAmt.scrollToRow(0)
        //-------------------- Attributed Text for Discount Price
        let totalPrice = "" //"\(packageDetails?.totalPrice ?? 0.0)"
        let defaultAttributes = [
            .font: AppFont.semibold.size(25.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.semibold.size(20.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attrStrCost:String = isShowTotalCost ? "AED" : "AED / Session"
        
        let attributedNickName = [
            "",
            totalPrice.strikeThrough(with: AppFont.medium.size(20.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray),
            NSAttributedString(string: attrStrCost,
                               attributes: makeAttributes),
        ] as [AttributedStringComponent]
        
        self.sessionCostLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
        self.sessionCostLbl.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
        //---------------------***********
        self.updateContainerWidth()
    }
    
    func updateContainerWidth() {
        let widestLabelWidth = sessionAmt.labelWidth
        print("Widest label width: \(widestLabelWidth)")
        sessionAmtWidthConstrnt?.constant = widestLabelWidth  // Adding padding (8 + 8)
        view.layoutIfNeeded() // Apply the constraint changes
    }
    
    //MARK: -----------SESSION SELECTION BTN ACTN
    private func updateTooltipPosition() {
        self.costSlider.maximumTrackTintColor = UIColor.appWhite
        //        let thumbRect = self.costSlider.thumbRect(forBounds: self.costSlider.bounds, trackRect: self.costSlider.trackRect(forBounds: self.costSlider.bounds), value: self.costSlider.value) //for show 100%
        
        let value80 = self.costSlider.minimumValue + 0.8 * (self.costSlider.maximumValue - self.costSlider.minimumValue) //for only show 80%
        let thumbRect = self.costSlider.thumbRect(forBounds: self.costSlider.bounds, trackRect: self.costSlider.trackRect(forBounds: self.costSlider.bounds), value: value80)
        let thumbX = thumbRect.origin.x + thumbRect.width / 2
        // Update tooltip position
        tooltipView.center = CGPoint(x: thumbX , y: self.costSlider.frame.origin.y - (self.costSlider.frame.height + 62))
        drawTringle()
        //        tooltipView.center = CGPoint(x: thumbX + self.costSlider.frame.origin.x, y: self.costSlider.frame.origin.y - (self.costSlider.frame.height + 70))
        //sliderTopMBV
    }
    
    func drawTringle(){
        let tooltipHeight = tooltipView.frame.size.height + 13
        let triangleHeight: CGFloat = 7
        let heightWidth = tooltipView.frame.size.width
        let path = CGMutablePath()
        path.move(to: CGPoint(x: heightWidth/2 - 7, y: tooltipHeight))
        path.addLine(to: CGPoint(x:heightWidth/2, y: tooltipHeight + triangleHeight))
        path.addLine(to: CGPoint(x:heightWidth-(heightWidth/2 - 7), y:tooltipHeight))
        path.closeSubpath()
        let shape = CAShapeLayer()
        shape.path = path
        shape.fillColor = UIColor(red: 158/255, green: 188/255, blue: 255/255, alpha: 1).cgColor
        tooltipView.layer.insertSublayer(shape, at: 0)
    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    //MARK: -----------SETUI
    private func setupUI(){
        userTagsCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        self.planDescBtn.titleLabel?.numberOfLines = 0
        self.costSlider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        self.costSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        DispatchQueue.main.async {
            self.saveMBV.addSubview(self.tooltipView)
            self.updateTooltipPosition()
            //--------Apply Gradient color
            self.costSlider.setSlider(gradientColors: [
                UIColor(red: 61.0/255.0, green: 215.0/255.0, blue: 114.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 66/255.0, green: 171/255.0, blue: 152/255.0, alpha: 1.0).cgColor,
                UIColor(red: 66/255.0, green: 114/255.0, blue: 211/255.0, alpha: 1.0).cgColor,
                UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1.0).cgColor
            ]
            )
            self.userImgView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.planNoteMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            //            self.planDescBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 10.0)
            self.planDescBtn.roundSideCorners(radius: 24.0, cornerSide: [.topLeft, .topRight])
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
        //-----------------***************** Custom switch
        costChooseSwtch.onToggle = { [weak self] isSelected in
            guard let self = self else { return  }
            print("isSelected", isSelected)
            self.isShowTotalCost = isSelected
            self.perSessionCostLbl.textColor = (!isSelected ? UIColor.appYellow : UIColor.txtDarkGray)
            self.totalCostLbl.textColor = (isSelected ? UIColor.appYellow : UIColor.txtDarkGray)
        }
    }
    //MARK: ------------FONT SETUP
    //------------------************Font
    private func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.userNameLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.perSessionCostLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.totalCostLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.sessionCountLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.planNoteLbl.font = AppFont.regular.size(12.0, familyName: familyOverpassMono)
        self.planDescBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.showMinValueLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.showMaxValueLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
    }
}

extension TopUpgradeSessionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
        //        if let totalCount = tagsData?.count, totalCount > 2 {
        //            return 3
        //        }else{
        //            return tagsData?.count ?? 0
        //        }
        //        return tagsData?.count ?? 0 //categoryData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = userTagsCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        DispatchQueue.main.async {
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 9.0)
            cell.layoutIfNeeded()
        }
        //        cell.titleLbl.text = tagsData?[indexPath.row].name
        cell.titleLblLeading.constant = 8.0
        cell.titleLblTopConstrnt.constant = 5.0
        cell.layoutIfNeeded()
        /*
         if let lastCell = collectionView.isLastCell(), let totalCount = tagsData?.count,( lastCell == indexPath.row && totalCount > 2) {
         cell.titleLbl.text = "+3"
         
         cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 2.0)
         cell.layoutIfNeeded()
         }
         else{
         cell.titleLbl.text = tagsData?[indexPath.row].name
         }
         */
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

//MARK: --------------------------------EXTENSION FOR API
extension TopUpgradeSessionViewController {
    private func upgradeApi(inputParams: UpgradePlanParamModel?){
        let params:[String:String]? = [
            "type": inputParams?.type ?? "",
            "sessions": inputParams?.sessions ?? "",
            "id": inputParams?.id ?? "",
            "days": inputParams?.days ?? ""
        ]
        
        DashboardVM.upgradePlansApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self else { return }
            if let getStatus = getResultData?.status, getStatus {
                self.upgradeDetails = nil
                self.upgradeDetails = getResultData?.data
                self.flowPlanSetup()
            }
            //-----------------************
            switch planFlow {
            case .topUp:
                if let getErrors = getResultData?.errors {
                    Toast.show(message: getErrors.msg?.value ?? "")
                    
                    let maxLimit = self.lastValidValue + (Float(getErrors.days?.value ?? "0.0") ?? 0.0)
                    self.costSlider.setValue(maxLimit, animated: true)
                    self.costSlider.sendActions(for: .valueChanged)
                    break
                }
                break
            case .upgrade, .gymWorkoutPlan, .homeWorkoutPlan, .renew, .choosePlanDefault:
                print("none of these....")
                break
            }
        })
    }
}
