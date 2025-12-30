//
//  AgeViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/11/24.
//

import UIKit

class AgeViewController: CommonViewController {
    
    //MARK: -------------VARIABLE
    var selectedDate: String?
    private let dobPicker = WheelDob()
    private var backgroundGradient: CAGradientLayer?
    
    //MARK: ----------IBOUTLET
    @IBOutlet weak var bottomNoteMBV: UIView!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var yearsMBV: UIView!
    @IBOutlet weak var monthsMBV: UIView!
    @IBOutlet weak var daysMBV: UIView!
    @IBOutlet var viewBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpFont()
        self.enableContinueBtn(isSelected: true)
        self.wheelDobSetup()
        setupBackgroundGradient()
//        addCenterGlow()
        addSideFade()
        updateContinueButton(isEnabled: true)
        setupContinueButtonIcon(isEnabled: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
        dobPicker.frame = CGRect(x: 0, y: 20, width: self.yearsMBV.frame.width, height: 300)
    }
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.4)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(setTitle: [AppStrings.skipStr], setTintColor: .black, setTitleColor: UIColor.txtSkip)
    }
    
    override func rightBtnActn(sender: UIButton) {
        
        appUserDefaults.setRegistrationSkip(value: true)
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        //-----------*************
        DispatchQueue.main.async {
            //            self.bottomNoteMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //------------------************Font
    func setUpFont() {
        self.noteLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.titleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
//    private func setupBackgroundGradient() {
//        // Remove old gradient if any
//        backgroundGradient?.removeFromSuperlayer()
//        
//        let gradient = CAGradientLayer()
//        gradient.colors = UIColor.appMultiColor(.greenBgGradient).map { $0.cgColor }
//        
//        // VERY IMPORTANT – match first UI direction
//        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
//        gradient.endPoint   = CGPoint(x: 1.0, y: 1.0)
//        
//        gradient.locations = [0.0, 0.5, 1.0]
//        gradient.cornerRadius = 0
//        
//        viewBackground.layer.insertSublayer(gradient, at: 0)
//        backgroundGradient = gradient
//    }
    
    private func setupBackgroundGradient() {
        backgroundGradient?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.frame = viewBackground.bounds

        gradient.colors = [
            UIColor.black.cgColor,
            UIColor(hex: "#0A1A10").cgColor,
            UIColor.black.cgColor
        ]

        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1.0)

        viewBackground.layer.insertSublayer(gradient, at: 0)
        backgroundGradient = gradient
    }

    private func addCenterGlow() {
        let glowLayer = CAGradientLayer()
        glowLayer.frame = viewBackground.bounds

        glowLayer.colors = [
            UIColor.clear.cgColor,
            UIColor(hex: "#9CFF2E").withAlphaComponent(0.25).cgColor,
            UIColor.clear.cgColor
        ]

        glowLayer.locations = [0.4, 0.5, 0.6]
        glowLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        glowLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)

        viewBackground.layer.addSublayer(glowLayer)
    }

    private func addSideFade() {
        let sideFade = CAGradientLayer()
        sideFade.frame = viewBackground.bounds

        sideFade.colors = [
            UIColor.black.cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.black.cgColor
        ]

        sideFade.locations = [0.0, 0.15, 0.85, 1.0]
        sideFade.startPoint = CGPoint(x: 0.0, y: 0.5)
        sideFade.endPoint   = CGPoint(x: 1.0, y: 0.5)

        monthsMBV.layer.addSublayer(sideFade)
    }

    
    func updateContinueButton(isEnabled: Bool) {
        continueBtn.isEnabled = isEnabled
        continueBtn.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0.2) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.continueBtn.tintColor = .mainBg   // arrow color
                self.continueBtn.backgroundColor = .appWhite
                self.continueBtn.setTitleColor(.mainBg, for: .normal)
            } else {
                self.continueBtn.tintColor = .appWhite
                self.continueBtn.backgroundColor = .appDarkGray
                self.continueBtn.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        let arrowImage = UIImage(named: isEnabled ? "blackRightArrow" : "whiteRightArrow")?
            .withRenderingMode(.alwaysTemplate)
        
        continueBtn.setImage(arrowImage, for: .normal)
        
        // Force image on right side
        continueBtn.semanticContentAttribute = .forceRightToLeft
        
        // Space between text and image
        continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -12)
        continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 12)
        
        continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("Continue btn actn.....")
        //"dob"="2022-12-28"
        if let selectedDate = selectedDate, !selectedDate.isEmpty {
            print("selectedDate = ", selectedDate)
            
            RegistrationVM.addDobApi(viewController: self, inputDob: selectedDate, completion: { [weak self] getResultData in
                guard let self = self else { return  }
                
                if getResultData?.status == true {
                    appUserDefaults.setRegistrationSkip(value: false)
                    if let detailsData = getResultData?.data {
                        appUserDefaults.saveUserToUserDefaults(detailsData)
                    }
                    
                    let vc:LoadingViewController = LoadingViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.select_dob)
        }
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
    
    func wheelDobSetup(){
        
        dobPicker.delegate = self
        dobPicker.backgroundColor = UIColor.clear
        self.yearsMBV.addSubview(dobPicker)
    }
}

extension AgeViewController: SelectedDateDelegate{
    func selectDate(date: (year: String?, month: String?, day: String?)?) {
        selectedDate = nil
        guard let date = date else { return }
        print("selected date is = ", date)
        selectedDate = "\(date.year ?? "")-\(date.month ?? "")-\(date.day ?? "")"
    }
    
    func selectAge(age: String?) {
        print("age is = ", age ?? "")
    }
}
