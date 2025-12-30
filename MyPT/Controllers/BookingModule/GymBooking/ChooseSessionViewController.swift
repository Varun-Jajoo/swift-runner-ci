//
//  ChooseSessionViewController.swift
//  MyPT
//
//  Created by techsaga corp on 02/12/24.
//

import UIKit

enum SesionFlow {
    case session
    case validity
    case validityMembership
    case defaultSession
}

class ChooseSessionViewController: CommonViewController {
        
    //MARK: -------------VARIABLE
    var flowSession:SesionFlow = .defaultSession
    
    var availParams:AvailParmsModel?
    var inputParams:CreatePackageParamsModel?
    var packageDetails: CreatePackageDataModel?
    var validityMembershipParam: (studioStr: String?,days: String?)?
    var membershipDetailsData: MembershipValityDataModel?
    
    
    var tagsData: [TrainerTagModel]? = []
    var sessionCost:[String] = ["0.0"]
    
    var isShowTotalCost:Bool = false{
        didSet{
            self.setTotalCost(isTotalCost: isShowTotalCost)
        }
    }
    
    var isValidityData:Bool? = true
    
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

    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
    var noteStrings = ["Increase session count for lower per session cost", "The validity of the package also determines the access period for the trainer"]
    var noteStringsCount:Int = -1
   
    //MARK: -----------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var sliderTopMBV: UIView!
    @IBOutlet weak var trainerProfileImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var categoryCollView: UICollectionView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var sessionSliderMBV: UIView!
    @IBOutlet weak var perSessionCostLbl: UILabel!
    @IBOutlet weak var totalCostLbl: UILabel!
    @IBOutlet weak var totalCostAmtPicker: CustomPickerView!
    @IBOutlet weak var totalCostAmtPickerWidthConstrnt: NSLayoutConstraint!
    @IBOutlet weak var costSlider: UISlider!
    @IBOutlet weak var startMonthLbl: UILabel!
    @IBOutlet weak var sessionCostLbl: UILabel!
    @IBOutlet weak var startPointLbl: UILabel!
    @IBOutlet weak var endPointLbl: UILabel!
    @IBOutlet weak var sessionNoteMBV: UIView!
    @IBOutlet weak var sessionNote: UILabel!
    @IBOutlet weak var consultExpertMBV: UIView!
    @IBOutlet weak var consultExpertBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var customSwitch: CustomSwipeSwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.consultExpertBtn.isHidden = true
        setupUI()
        setUpFont()
        self.setupFlowLoad()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.sessionNoteMBV.animTopBottom(duration: 0.4, delay: 0.1) {
            print("animted done..")
        }
        scrollText(indx: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.sessionSliderMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.sessionSliderMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            self.sessionSliderMBV.setGradientMultiBorder(cornerRadius: 12, width: 2.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
        }
        
        //resized(to: CGSize(width: 80, height: 80))
        if let thumbImage = UIImage(named: "ic_Slider") {
            self.costSlider.setThumbImage(thumbImage, for: .normal)
        }
                        
        view.layoutIfNeeded()
    }
    
    //MARK: -------------------MAKE SCROLLABLE TEXT
    func scrollText(indx:Int){
        
        guard indx != self.noteStringsCount else { return }
        
        self.noteStringsCount = indx > 0 ? indx : 0
        
        self.sessionNote.animateTextScroll(strings: self.noteStrings, selectedIndex:  self.noteStringsCount, animationDuration: 0.4) {
            print("Text scrolling completed!")
        }
    }
   
    private func setNavUI(){
        
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func leftBtnActn(sender: UIButton) {
        switch flowSession {
        case .session:
            //------------ session is set default
            break
        case .validity:
            flowSession = .defaultSession
            isValidityData = true
            self.setInputData()
        case .validityMembership, .defaultSession:
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupFlowLoad(){
        switch flowSession {
        case .session, .validity, .defaultSession:
            
            setUpTotalCost()
            self.startMonthLbl.text = "1 sessions"
            //---------------
            inputParams?.sessions = "1"
            self.createPackageApi(parms: inputParams?.getParams())
            self.setInputData()
            break
            
        case .validityMembership:
           
            print("validityMembership..")
            self.perSessionCostLbl.text = "Per Package Cost"
            self.perSessionCostLbl.textColor = UIColor.txtDarkGray
            self.totalCostLbl.text = "Total Cost"
            self.totalCostLbl.textColor = UIColor.appYellow
//            self.sessionToggleBtn.isSelected = true
//            self.sessionToggleBtn.isUserInteractionEnabled = false
            self.customSwitch.isUserInteractionEnabled = false
            self.customSwitch.isSelected = true
            
            //-------------need to hide when come from without a trainer
            self.perSessionCostLbl.isHidden = true
            self.totalCostLbl.isHidden = true
            self.customSwitch.isHidden = true
           
            let costAmt:String = "0"
            
            self.sessionCost.removeAll()
            self.sessionCost.append(costAmt)
            totalCostAmtPicker.items = sessionCost //items
            totalCostAmtPicker.layoutIfNeeded()
            
            self.setUpTotalCost()
            self.costSlider.isUserInteractionEnabled = true
            self.topTitleLbl.text = "Validity of the package?"
            self.noteStrings.removeAll()
            self.noteStrings.append("The validity of the package determines the access period for MyPT gym")
            scrollText(indx: 1)
            
            self.startMonthLbl.text = packageDetails?.validity
            self.startMonthLbl.text = "1 day"
            self.endPointLbl.text = "365 days"
            
            self.getMembershipValityApi(studioIdStr: validityMembershipParam?.studioStr, dayStr: validityMembershipParam?.days)
            
            self.setInputData()
        
            break
        }
    }
    
    //MARK: ---------------SETUP DATA
    private func setInputData(){
        
        switch flowSession {
        case .session:
            //--------session is default set
            break
        case .validity:
            
            if let _ = isValidityData {
                self.trainerProfileImgView.loadImage(urlString: packageDetails?.trainer?.image, placeholder: UIImage())
                self.trainerNameLbl.text = packageDetails?.trainer?.name
        //        self.noteStrings.removeAll()
        //        self.noteStrings.append("Increase session count for lower per session cost")
                
                self.costSlider.isUserInteractionEnabled = false
                self.topTitleLbl.text = "Validity of the package?"
                self.noteStrings.removeAll()
                self.noteStrings.append("The validity of the package also determines the access period for the trainer")
                scrollText(indx: 1)
            }
   
            self.setTotalCost(isTotalCost: isShowTotalCost)
            self.startMonthLbl.text = packageDetails?.validity
            self.endPointLbl.text = "365"
            
            print("packageDetails validity = ", packageDetails?.validity as Any)
            if let validityCount = packageDetails?.validity {
                let validityParts = validityCount.components(separatedBy: " ")

                if let unit = validityParts.first(where: { $0.lowercased() == "month" || $0.lowercased() == "months" }) {
                    print("Found unit: \(unit)")
                    self.endPointLbl.text = "12"
                }else{
                    self.endPointLbl.text = "365"
                }
            }
            
//            self.costSlider.isUserInteractionEnabled = false
//            self.topTitleLbl.text = "Validity of the package?"
//            self.noteStrings.removeAll()
//            self.noteStrings.append("The validity of the package also determines the access period for the trainer")
//            scrollText(indx: 1)
            
//            self.startMonthLbl.text = packageDetails?.validity
//            
//            self.endPointLbl.text = "12"
                        
        case .validityMembership:
            print("validity membership..")
            
            if let _ = isValidityData {
                self.costSlider.isUserInteractionEnabled = true
                self.topTitleLbl.text = "Validity of the package?"
                self.noteStrings.removeAll()
                self.noteStrings.append("The validity of the package determines the access period for MyPT gym")
                scrollText(indx: 1)
                
    //            self.startMonthLbl.text = (membershipDetailsData?.packageDetail?.validity?.value ?? "") + " days" //"1 day"
    //            self.endPointLbl.text = "365 days"
                
                //-----------------------***********
                self.trainerProfileImgView.loadImage(urlString: membershipDetailsData?.studio?.profile, placeholder: UIImage())
                self.trainerNameLbl.text = membershipDetailsData?.studio?.name
                
            }
            
            self.setValidityWithoutTrainer()
            
//            //-------------------- Cost
//            let costAmt:String = membershipDetailsData?.packageDetail?.price?.value ?? "0"
//            
//            self.sessionCost.removeAll()
//            self.sessionCost.append(costAmt)
//            totalCostAmtPicker.items = sessionCost //items
//            totalCostAmtPicker.layoutIfNeeded()
//            
//            //-------------------- Attributed Text for Discount Price
//            let totalPrice = "" //"\(packageDetails?.totalPrice ?? 0.0)"
//            
//            let defaultAttributes = [
//                .font: AppFont.semibold.size(25.0, familyName: familyClashDisplay),
//                .foregroundColor: UIColor.appWhite
//            ] as [NSAttributedString.Key : Any]
//            
//            let makeAttributes = [
//                .font: AppFont.semibold.size(20.0, familyName: familyClashDisplay),
//                .foregroundColor: UIColor.appWhite
//            ] as [NSAttributedString.Key : Any]
//                    
//            let attributedNickName = [
//                "",
//                totalPrice.strikeThrough(with: AppFont.medium.size(20.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray),
//                NSAttributedString(string: "AED",
//                                   attributes: makeAttributes),
//            ] as [AttributedStringComponent]
//            
//            self.sessionCostLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
//            
//            self.sessionCostLbl.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
//            
//            //---------------------***********
//            self.updateContainerWidth()
            
            
        case .defaultSession:
            
            if let _ = isValidityData {
                self.costSlider.isUserInteractionEnabled = true
                self.topTitleLbl.text = "Choose total sessions"
                self.noteStrings.removeAll()
                self.noteStrings.append("Increase session count for lower per session cost")
                scrollText(indx: 1)
                self.trainerProfileImgView.loadImage(urlString: packageDetails?.trainer?.image, placeholder: UIImage())
                self.trainerNameLbl.text = packageDetails?.trainer?.name
            }
            
            self.costSlider.sendActions(for: .valueChanged)
            self.endPointLbl.text = "\(Int(costSlider.maximumValue))"
            self.setTotalCost(isTotalCost: isShowTotalCost)
            
//            self.costSlider.isUserInteractionEnabled = true
//            self.topTitleLbl.text = "Choose total sessions"
//            self.noteStrings.removeAll()
//            self.noteStrings.append("Increase session count for lower per session cost")
//            scrollText(indx: 1)
            
//            self.costSlider.sendActions(for: .valueChanged)
//            self.endPointLbl.text = "\(Int(costSlider.maximumValue))"
            
//            self.trainerProfileImgView.loadImage(urlString: packageDetails?.trainer?.image, placeholder: AppImages.navLeft)
//            self.trainerNameLbl.text = packageDetails?.trainer?.name
    //        self.noteStrings.removeAll()
    //        self.noteStrings.append("Increase session count for lower per session cost")
            
//            self.setTotalCost(isTotalCost: isShowTotalCost)
        }
    }
    
    private func setValidityWithoutTrainer(){
        
        self.startMonthLbl.text = (membershipDetailsData?.packageDetail?.validity?.value ?? "") + " days" //"1 day"
        self.endPointLbl.text = "365 days"
        //-------------------- Cost
        let costAmt:String = membershipDetailsData?.packageDetail?.price?.value ?? "0"
        
        self.sessionCost.removeAll()
        self.sessionCost.append(costAmt)
        totalCostAmtPicker.items = sessionCost //items
        totalCostAmtPicker.layoutIfNeeded()
        
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
                
        let attributedNickName = [
            "",
            totalPrice.strikeThrough(with: AppFont.medium.size(20.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray),
            NSAttributedString(string: "AED",
                               attributes: makeAttributes),
        ] as [AttributedStringComponent]
        
        self.sessionCostLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
        
        self.sessionCostLbl.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
        
        //---------------------***********
        self.updateContainerWidth()
    }
    
    private func setTotalCost(isTotalCost:Bool){
        
        //-------------------- Cost
        let costAmt:String = isShowTotalCost ? "\(self.packageDetails?.totalPrice ?? 0.0)" : "\(self.packageDetails?.pricePerSession ?? 0.0)"
        
        self.sessionCost.removeAll()
        self.sessionCost.append(costAmt)
        totalCostAmtPicker.items = sessionCost //items
        totalCostAmtPicker.layoutIfNeeded()
        
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
    
    private func setUpTotalCost(){
        // Define items for the picker
//        let items = ["50", "80", "100", "150", "200", "250", "300"]
        // Set the items for the picker
        
        switch flowSession {
        case .session, .validity, .defaultSession:
            totalCostAmtPicker.items = sessionCost //items
            costSlider.minimumValue = 1
            costSlider.maximumValue = 100 //Float(sessionCost.count - 1) //Float(items.count - 1)
            // Initially center the picker at the first item
            totalCostAmtPicker.scrollToRow(0)
            
            //--------------
            self.startPointLbl.text = "0"
            self.endPointLbl.text = "\(Int(costSlider.maximumValue))"
            
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%" //"Save \(1)%"
            }
            
            //------------------********
            totalCostAmtPicker.scrollToRow(80, animated: true)
            self.updateContainerWidth()
            
        case .validityMembership:
                        
            //------
            
            totalCostAmtPicker.items = sessionCost //items
            costSlider.minimumValue = 1
            costSlider.maximumValue = 365
            // Initially center the picker at the first item
            totalCostAmtPicker.scrollToRow(0)
            
            //--------------
            self.startPointLbl.text = "0"
            self.endPointLbl.text = "\(Int(costSlider.maximumValue))"
            
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%" //"Save \(1)%"
            }
            
            //------------------********
            totalCostAmtPicker.scrollToRow(80, animated: true)
            self.updateContainerWidth()
        }
        
    }
    
    func updateContainerWidth() {
        let widestLabelWidth = totalCostAmtPicker.labelWidth
        print("Widest label width: \(widestLabelWidth)")
          totalCostAmtPickerWidthConstrnt?.constant = widestLabelWidth  // Adding padding (8 + 8)
          view.layoutIfNeeded() // Apply the constraint changes
      }
    
    //MARK: -----------SETUI
    private func setupUI(){
         
        categoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        self.consultExpertBtn.titleLabel?.numberOfLines = 2
        
        costSlider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        
        DispatchQueue.main.async {
            
            self.sliderTopMBV.addSubview(self.tooltipView)
            self.updateTooltipPosition()
            
            //--------Apply Gradient color
            self.costSlider.setSlider(gradientColors: [
                UIColor(red: 61.0/255.0, green: 215.0/255.0, blue: 114.0/255.0, alpha: 1.0).cgColor,
                UIColor(red: 66/255.0, green: 171/255.0, blue: 152/255.0, alpha: 1.0).cgColor,
                UIColor(red: 66/255.0, green: 114/255.0, blue: 211/255.0, alpha: 1.0).cgColor,
                UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1.0).cgColor
            ]
            )
            
            //----------------Gradient view
            
            self.trainerProfileImgView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.sessionNoteMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.consultExpertMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.consultExpertBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
        
        //-----------------***************** Custom switch
        customSwitch.onToggle = { [weak self] isSelected in
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
        self.perSessionCostLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.trainerNameLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.perSessionCostLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.totalCostLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.startMonthLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
//        self.startMonthLbl.font = AppFont.regular.size(14.0, familyName: familyOverpass)
        self.consultExpertBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.startPointLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.endPointLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
    }
    
    
    //MARK: -----------COST SLIDER ACTN
    
    @objc func sliderTouchEnded(_ sender: UISlider) {
          print("Final Value on Scroll End: \(Int(sender.value))") // Value when user lifts finger
        //-----------------------
        switch flowSession {
        case .session, .validity, .defaultSession:
            let row = Int(sender.value)
    //        inputParams?.sessions = "\(row+1)"
            inputParams?.sessions = "\(row)"
            self.createPackageApi(parms: inputParams?.getParams())
       
        case .validityMembership:
            let row = Int(sender.value)
       
            self.validityMembershipParam?.days = "\(row)"
           
            self.getMembershipValityApi(studioIdStr: validityMembershipParam?.studioStr, dayStr: self.validityMembershipParam?.days)
        }
        
      }
    
    @IBAction func costSliderActn(_ sender: UISlider) {
        let row = Int(sender.value)
        guard sender.maximumValue > 1 else { return }
        print("Scroll slider Row value : ", row)
        switch flowSession {
        case .session, .validity, .defaultSession:
           
            /*
            if sessionCost.count > 1 && row < sessionCost.count {
                totalCostAmtPicker.scrollToRow(row, animated: true)
            }
             self.updateContainerWidth()
            */
           
            
            //---------------------*************
            // Update tooltip text
            let percentage = Int(sender.value / sender.maximumValue * 100)
            //        tooltipLabel.text = "Save \(percentage)%"
            
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%" //"Save \(percentage)%"
            }
            
            
            if percentage > 60 {
    //            self.startMonthLbl.text = "12 month"
                self.startMonthLbl.text = "\(row) sessions" //"100 sessions"
                self.startMonthLbl.textAlignment = .right
                self.startScrolling()
                
                if 1 <= noteStrings.count {
                    scrollText(indx: 1)
                }
                
            }else{
    //            self.startMonthLbl.text = "3 month"
                self.startMonthLbl.text = "\(row) sessions" //"3 sessions"
                self.startMonthLbl.textAlignment = .left
                self.startScrolling()
                
                if 1 <= noteStrings.count {
                    scrollText(indx: 0)
                }
            }
            
            updateTooltipPosition()
            
        case .validityMembership:
            
            /*
            if sessionCost.count > 1 && row < sessionCost.count {
                totalCostAmtPicker.scrollToRow(row, animated: true)
            }
            self.updateContainerWidth()
            */
            
            //---------------------*************
            // Update tooltip text
            let percentage = Int(sender.value / sender.maximumValue * 100)
            //        tooltipLabel.text = "Save \(percentage)%"
            
            if let label = tooltipView.viewWithTag(100) as? UILabel {
                label.text = "Save 20%" //"Save \(percentage)%"
            }
            
            if percentage > 60 {
                self.startMonthLbl.text = "\(row) days"
                self.startMonthLbl.textAlignment = .right
                self.startScrolling()
                if 1 <= noteStrings.count {
                    scrollText(indx: 1)
                }
            }else{
                self.startMonthLbl.text = "\(row) days"
                self.startMonthLbl.textAlignment = .left
                self.startScrolling()
                
                if 1 <= noteStrings.count {
                    scrollText(indx: 0)
                }
            }
            updateTooltipPosition()
        }
    }
    
    //MARK: --------------ANIMATED MONTH LABEL
    func startScrolling() {
         let totalHeight = startMonthLbl.frame.height
        let visibleHeight = 10.0
        self.startMonthLbl.alpha = 0
        
         // Calculate the time it takes to scroll through the entire text
         let duration = Double(totalHeight + visibleHeight) / 30.0 // Adjust speed (30 points per second)

         UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
             self.startMonthLbl.alpha = 1.0
         }, completion: nil)
     }
    
    //MARK: -----------ENUM  BTN TAG
    enum btnTag:Int {
        case edit = 301, consultExpert, continueBtn
    }
    
    //MARK: -----------EDIT BTN ACTN
    @IBAction func commonBtnActn(_ sender: UIButton) {
        print("common btn clicked....")
        
        switch sender.tag {
        case btnTag.edit.rawValue:
            print("edit btn clicked.")
            self.navigationController?.popToViewController(ofClass: TrainerListViewController.self, animated: true)
               
        case btnTag.consultExpert.rawValue:
            print("consultExpert btn clicked.")
        case btnTag.continueBtn.rawValue:
            print("continueBtn btn clicked.")
            
            switch flowSession {
            case .session:
                //------------ session is set default
                break
            case .validity:
                let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
                vc.slotBookFlow = .createPackage
                vc.params = availParams
                vc.totalDays = packageDetails?.totalDays
                vc.packageTypeStr = "\(packageDetails?.details?.packageType ?? 1)"
                vc.sessionsStr = packageDetails?.details?.sessions
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .validityMembership:
                print("validity membership..")
                
                let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
                vc.slotBookFlow = .withoutTrainerMembership
                vc.totalDays = Int(membershipDetailsData?.packageDetail?.validity?.value ?? "0")
                vc.priceStr = membershipDetailsData?.packageDetail?.price?.value
                vc.studioIdStr = "\(membershipDetailsData?.studio?.id ?? 0)"
                self.navigationController?.pushViewController(vc, animated: true)

            case .defaultSession:
                flowSession = .validity
                self.isValidityData = true
                self.setInputData()
            }
 
        default:
            print("non...........")
        }
        
        /*
         case btnTag.sessionToggle.rawValue:
             print("sessionToggle btn clicked.")
 //            sender.isSelected.toggle()
 //            self.isShowTotalCost = sender.isSelected
          
         */
        
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
    
}


extension ChooseSessionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if let totalCount = tagsData?.count, totalCount > 2 {
            return 3
        }else{
            return tagsData?.count ?? 0
        }
        
//        return tagsData?.count ?? 0 //categoryData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        
        DispatchQueue.main.async {
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 9.0)
            cell.layoutIfNeeded()
        }
        
        //        cell.titleLbl.text = tagsData?[indexPath.row].name
        cell.titleLblLeading.constant = 8.0
        cell.titleLblTopConstrnt.constant = 5.0
        cell.layoutIfNeeded()
        
        if let lastCell = collectionView.isLastCell(), let totalCount = tagsData?.count,( lastCell == indexPath.row && totalCount > 2) {
            cell.titleLbl.text = "+3"
           
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 2.0)
            cell.layoutIfNeeded()
        }
        else{
            cell.titleLbl.text = tagsData?[indexPath.row].name
        }
        
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

//MARK: --------------------EXTENSION FOR API
extension ChooseSessionViewController{
    
    func createPackageApi(parms:[String:String]?){
        CreatePackageVM.createPackageApi(viewController: self, inputParms: parms, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print("getResultData", getResultData)
            if getResultData.status == true {
                self.packageDetails = getResultData.data
                self.setInputData()
                self.isValidityData = nil
                self.tagsData?.removeAll()
                self.tagsData?.append(contentsOf: self.packageDetails?.trainer?.tags ?? [])
                print(self.tagsData?.count ?? 0)
                self.categoryCollView.reloadData()
                self.updateContainerWidth()
                
            }
        })
    }
    
    //MARK: ---------------MEMBERSHIP VALIDITY
    func getMembershipValityApi(studioIdStr: String?, dayStr: String?){
        CreatePackageVM.membershipValidityApi(viewController: self, inputStudioId: studioIdStr, inputDays: dayStr, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            self.membershipDetailsData = getResultData.data
            self.setInputData()
            self.isValidityData = nil
            self.tagsData?.removeAll()
            if let getTags = self.membershipDetailsData?.studio?.tags {
                self.tagsData = getTags.enumerated().map { index, name in
                     TrainerTagModel(id: index + 1, name: name)
                }
            }
            self.categoryCollView.reloadData()       
            self.updateContainerWidth()
        })
    }
}

//MARK: ----------------- CreatePackageParamsModel
struct CreatePackageParamsModel {
    
    var package_type: String?
    var sessions: String?
    var type: String?
    var timing: String?
    var trainer_id: String?
    var studio_id: String?
    var month: String?
    var address_id: String?
    
    func getParams() -> [String: String] {
        var dict: [String: String] = [:]
        
        if let package_type = package_type { dict["package_type"] = package_type }
        if let sessions = sessions { dict["sessions"] = sessions }
        if let type = type { dict["type"] = type }
        if let timing = timing { dict["timing"] = timing }
        if let trainer_id = trainer_id { dict["trainer_id"] = trainer_id }
        if let studio_id = studio_id { dict["studio_id"] = studio_id }
        if let month = month { dict["month"] = month }
        if let address_id = address_id { dict["address_id"] = address_id }
        
        return dict
    }
}



/*    for making slide label text
 class MySliderView: UIView {
     
     private var discreteSlider = UISlider()

     override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         commonInit()
     }
     func commonInit() -> Void {
         
         let minVal: Int = 1
         let maxVal: Int = 5
         
         // slider properties
         discreteSlider.minimumValue = Float(minVal)
         discreteSlider.maximumValue = Float(maxVal)
         discreteSlider.isContinuous = true
         discreteSlider.tintColor = UIColor.purple

         let stepStack = UIStackView()
         stepStack.distribution = .equalSpacing
         
         for i in minVal...maxVal {
             let v = UILabel()
             v.text = "\(i)"
             v.textAlignment = .center
             v.textColor = .systemRed
             stepStack.addArrangedSubview(v)
         }
         
         // references to first and last step label
         guard let firstLabel = stepStack.arrangedSubviews.first,
               let lastLabel = stepStack.arrangedSubviews.last
         else {
             // this will never happen, but we want to
             //  properly unwrap the labels
             return
         }
         
         // make all step labels the same width
         stepStack.arrangedSubviews.dropFirst().forEach { v in
             v.widthAnchor.constraint(equalTo: firstLabel.widthAnchor).isActive = true
         }
         
         let minLabel = UILabel()
         minLabel.text = "Min"
         minLabel.textAlignment = .center
         minLabel.textColor = .systemRed

         let maxLabel = UILabel()
         maxLabel.text = "Max"
         maxLabel.textAlignment = .center
         maxLabel.textColor = .systemRed
         
         // add the labels and the slider to self
         [minLabel, maxLabel, discreteSlider, stepStack].forEach { v in
             v.translatesAutoresizingMaskIntoConstraints = false
             addSubview(v)
         }

         // now we setup the layout

         NSLayoutConstraint.activate([
             
             // start with the step labels stackView
             
             // we'll give it 40-pts leading and trailing "padding"
             stepStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40.0),
             stepStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40.0),
             
             // and 20-pts from the bottom
             stepStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.0),

             // now constrain the slider leading and trailing to the
             //  horizontal center of first and last step labels
             //  accounting for width of thumb (assuming a default UISlider)
             discreteSlider.leadingAnchor.constraint(equalTo: firstLabel.centerXAnchor, constant: -14.0),
             discreteSlider.trailingAnchor.constraint(equalTo: lastLabel.centerXAnchor, constant: 14.0),
             
             // and 20-pts above the steps stackView
             discreteSlider.bottomAnchor.constraint(equalTo: stepStack.topAnchor, constant: -20.0),
             
             // constrain Min and Max labels centered to first and last step labels
             minLabel.centerXAnchor.constraint(equalTo: firstLabel.centerXAnchor, constant: 0.0),
             maxLabel.centerXAnchor.constraint(equalTo: lastLabel.centerXAnchor, constant: 0.0),
             
             // and 20-pts above the steps slider
             minLabel.bottomAnchor.constraint(equalTo: discreteSlider.topAnchor, constant: -20.0),
             maxLabel.bottomAnchor.constraint(equalTo: discreteSlider.topAnchor, constant: -20.0),

             // and 20-pts top "padding"
             minLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20.0),
         ])

         // add behavior
         discreteSlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
         discreteSlider.addTarget(self, action: #selector(self.sliderThumbReleased(_:)), for: .touchUpInside)

     }
     
     // so we can set the slider value from the controller
     public func setSliderValue(_ val: Float) -> Void {
         discreteSlider.setValue(val, animated: true)
     }
     
     @objc func sliderValueDidChange(_ sender: UISlider) -> Void {
         print("Slider dragging value:", sender.value)
     }
     @objc func sliderThumbReleased(_ sender: UISlider) -> Void {
         // "snap" to discreet step position
         sender.setValue(Float(lroundf(sender.value)), animated: true)
         print("Slider dragging end value:", sender.value)
     }
     
 }
 */


//class CustomSlider: UISlider {
//    
//    // Adjust thumb position
//    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
//        let thumbSize = CGSize(width: 40, height: 40) // Adjust based on your image
//        let newThumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
//        
//        let adjustedX = newThumbRect.origin.x - (thumbSize.width - newThumbRect.width) / 2
//        let adjustedY = newThumbRect.origin.y - (thumbSize.height - newThumbRect.height) / 2
//        
//        return CGRect(x: adjustedX, y: adjustedY, width: thumbSize.width, height: thumbSize.height)
//    }
//}
