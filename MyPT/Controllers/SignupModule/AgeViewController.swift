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
    private let yearCurveIV  = UIImageView(image: UIImage(named: "YearBg"))
    private let monthCurveIV = UIImageView(image: UIImage(named: "MonthBg"))
    private let dayCurveIV   = UIImageView(image: UIImage(named: "DateBg"))
    
    //MARK: ----------IBOUTLET
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
        setupYearBackground()   // 👈 IMPORTANT
        setupMonthBackground()
        wheelDobSetup()
//        setupBackgroundGradient()
        updateContinueButton(isEnabled: true)
        setupContinueButtonIcon(isEnabled: true)
        yearsMBV.clipsToBounds = false
        monthsMBV.clipsToBounds = false
//        addSideFade()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let date18 = self.dobPicker.default18YearsAgoDate()
                let parts = self.components(from: date18)

                self.dobPicker.selectInitialDate(
                    year: parts.year,
                    month: parts.month,
                    day: parts.day
                )
            }
        }


        func components(from date: Date) -> (year: String, month: String, day: String) {
            let calendar = Calendar.current
            
            let year  = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day   = calendar.component(.day, from: date)
            
            let monthName = calendar.shortMonthSymbols[month - 1] // Jan, Feb...
            
            return ("\(year)", monthName, "\(day)")
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
    
    private func setupYearBackground() {

            yearCurveIV.translatesAutoresizingMaskIntoConstraints = false
            yearCurveIV.image = UIImage(named: "YearBg")
            yearCurveIV.contentMode = .scaleToFill   // 👈 IMPORTANT
            yearCurveIV.clipsToBounds = false
    //        yearCurveIV.backgroundColor = .red.withAlphaComponent(0.3)

            yearsMBV.insertSubview(yearCurveIV, at: 0)

            NSLayoutConstraint.activate([
                yearCurveIV.leadingAnchor.constraint(equalTo: yearsMBV.leadingAnchor),
                yearCurveIV.trailingAnchor.constraint(equalTo: yearsMBV.trailingAnchor),

                // 👇 Half circle ko TOP se hang karna hai
                yearCurveIV.topAnchor.constraint(equalTo: yearsMBV.topAnchor, constant: -35),

                // 👇 image actual height
                yearCurveIV.heightAnchor.constraint(equalToConstant: 220)
            ])
        }
        
        private func setupMonthBackground() {

            monthCurveIV.translatesAutoresizingMaskIntoConstraints = false
            monthCurveIV.contentMode = .scaleToFill
            monthCurveIV.clipsToBounds = false
            monthCurveIV.backgroundColor = .red

            // 👇 background me add karo
            monthsMBV.insertSubview(monthCurveIV, at: 0)

            NSLayoutConstraint.activate([
                monthCurveIV.leadingAnchor.constraint(equalTo: monthsMBV.leadingAnchor),
                monthCurveIV.trailingAnchor.constraint(equalTo: monthsMBV.trailingAnchor),

                // 👇 month arc thoda upar se hang hota hai
                monthCurveIV.topAnchor.constraint(equalTo: monthsMBV.topAnchor, constant: -30),

                // 👇 SVG ke radius ke according
                monthCurveIV.heightAnchor.constraint(equalToConstant: 200)
            ])
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
        self.noteLbl.textColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.55)
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
//                self.continueBtn.tintColor = .mainBg   // arrow color
//                self.continueBtn.backgroundColor = .appWhite
//                self.continueBtn.setTitleColor(.mainBg, for: .normal)
            } else {
                self.continueBtn.tintColor = .appWhite
                self.continueBtn.backgroundColor = .appDarkGray
                self.continueBtn.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {

            if isEnabled {
                // 🟢 ENABLED → IMAGE ONLY
                let image = UIImage(named: "ButtonContinue")?
                    .withRenderingMode(.alwaysOriginal)

                continueBtn.setImage(image, for: .normal)
                continueBtn.setTitle("", for: .normal)

                continueBtn.backgroundColor = .clear
                continueBtn.tintColor = .clear

                continueBtn.imageEdgeInsets = .zero
                continueBtn.titleEdgeInsets = .zero
                continueBtn.contentEdgeInsets = .zero

                continueBtn.semanticContentAttribute = .forceLeftToRight
                continueBtn.adjustsImageWhenHighlighted = false
                continueBtn.adjustsImageWhenDisabled = false

            } else {
                // 🔴 DISABLED → TEXT + ARROW
                continueBtn.setTitle("CONTINUE", for: .normal)
                continueBtn.setTitleColor(.appWhite, for: .normal)

                let arrowImage = UIImage(named: "whiteRightArrow")?
                    .withRenderingMode(.alwaysOriginal)
                continueBtn.setImage(arrowImage, for: .normal)

                continueBtn.semanticContentAttribute = .forceRightToLeft

                // spacing between text & arrow
                continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
                continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)

                continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
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
                    
                    let vc: WeightViewController = WeightViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        } else {
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.select_dob)
        }
    }
    
    func wheelDobSetup(){
        dobPicker.delegate = self
        dobPicker.backgroundColor = UIColor.clear
        self.yearsMBV.addSubview(dobPicker)
        yearsMBV.bringSubviewToFront(dobPicker)
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
