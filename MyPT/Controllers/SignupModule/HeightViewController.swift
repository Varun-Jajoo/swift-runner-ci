//
//  HeightViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/11/24.
//

import UIKit

class HeightViewController: CommonViewController {

    //MARK: -------------VARIABLE
    var selectedHeight:String?
    var heightPicker = HeightPickerControl()
    var titleFeetLbl = UILabel()
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var measureScaleMBV: UIView!
    @IBOutlet weak var scaleMBV: RulerMultiUnitRuler!
    @IBOutlet weak var heightMeasureType: UISegmentedControl!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setUpFont()
        setUpSegmet()
        setupSegmentedControlStyle()
        enableContinueBtn(isSelected: true)
        self.setupFeetRuler()
        
        if let userData = appUserDefaults.getUserFromUserDefaults(as: UserModel.self), let userName = userData.name {
            print("userData", userData)
            print("userData name: ", userName, "Id: ",userData.id ?? "",  userData.phone ?? "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    private func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.5)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite) skipe remove need of client
        
        //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
    }
    
    //------------------************Font
    private func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    override func rightBtnActn(sender: UIButton) {
        appUserDefaults.setRegistrationSkip(value: true)
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
    }
    
    //MARK: ---------- SET UI
    private func setupUI(){
        //-----------*************
        DispatchQueue.main.async {
            self.heightMeasureType.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 6.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    
    //MARK: -----------------MAKE RULER FOR WEIGHT
    
    func setupFeetRuler(){
        heightPicker.removeFromSuperview()
        titleFeetLbl.removeFromSuperview()
        titleFeetLbl  = UILabel()
        titleFeetLbl.text = nil
        heightPicker = HeightPickerControl()
        heightPicker.translatesAutoresizingMaskIntoConstraints = false
        heightPicker.unit = .feetInches
        heightPicker.maxFeet = 300
        heightPicker.addTarget(self, action: #selector(heightChanged(_:)), for: .valueChanged)
        heightPicker.backgroundColor = UIColor.clear
        heightPicker.rulerViewBgColor = UIColor.clear
        scaleMBV.addSubview(heightPicker)
        titleFeetLbl.backgroundColor = UIColor.clear
        titleFeetLbl.textColor = UIColor.appWhite
        titleFeetLbl.textAlignment = .right
        scaleMBV.addSubview(titleFeetLbl)
        titleFeetLbl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightPicker.trailingAnchor.constraint(equalTo: scaleMBV.trailingAnchor, constant: 10),
            heightPicker.centerYAnchor.constraint(equalTo: scaleMBV.centerYAnchor),
            heightPicker.widthAnchor.constraint(equalToConstant: 250),
            heightPicker.heightAnchor.constraint(equalTo: scaleMBV.heightAnchor, multiplier: 0.96),
            titleFeetLbl.leadingAnchor.constraint(equalTo: heightPicker.leadingAnchor, constant: -170),
            titleFeetLbl.centerYAnchor.constraint(equalTo: scaleMBV.centerYAnchor),
            titleFeetLbl.widthAnchor.constraint(equalTo: heightPicker.widthAnchor, multiplier: 1.0),
            titleFeetLbl.heightAnchor.constraint(equalTo: heightPicker.heightAnchor, multiplier: 0.8)
        ])
        
        self.scrollScale(inputView: heightPicker)
    }
    
    //MARK: -----------------MAKE RULER FOR WEIGHT
    func setupCMSRuler(){
        heightPicker.removeFromSuperview()
        titleFeetLbl.removeFromSuperview()
        titleFeetLbl  = UILabel()
        titleFeetLbl.text = nil
        heightPicker = HeightPickerControl()
        heightPicker.translatesAutoresizingMaskIntoConstraints = false
        heightPicker.unit = .centimeters
        heightPicker.maxCM = 650.0
        heightPicker.addTarget(self, action: #selector(heightChanged(_:)), for: .valueChanged)
        heightPicker.backgroundColor = UIColor.clear
        heightPicker.rulerViewBgColor = UIColor.clear
        scaleMBV.addSubview(heightPicker)
        titleFeetLbl.backgroundColor = UIColor.clear
        titleFeetLbl.textColor = UIColor.appWhite
        titleFeetLbl.textAlignment = .right
        scaleMBV.addSubview(titleFeetLbl)
        titleFeetLbl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightPicker.trailingAnchor.constraint(equalTo: scaleMBV.trailingAnchor, constant: 10),
            heightPicker.centerYAnchor.constraint(equalTo: scaleMBV.centerYAnchor),
            heightPicker.widthAnchor.constraint(equalToConstant: 250),
            heightPicker.heightAnchor.constraint(equalTo: scaleMBV.heightAnchor, multiplier: 0.96),
            titleFeetLbl.leadingAnchor.constraint(equalTo: heightPicker.leadingAnchor, constant: -170),
            titleFeetLbl.centerYAnchor.constraint(equalTo: scaleMBV.centerYAnchor),
            titleFeetLbl.widthAnchor.constraint(equalTo: heightPicker.widthAnchor, multiplier: 1.0),
            titleFeetLbl.heightAnchor.constraint(equalTo: heightPicker.heightAnchor, multiplier: 0.8)
        ])
        
        self.scrollScale(inputView: heightPicker)
    }
    
    func scrollScale(inputView: UIView){
        
        if let scrollView = inputView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            print("Found scroll view: \(scrollView)")
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
        
//        if let scrollView = inputView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
//            print("Found scroll view: \(scrollView)")
//            scrollView.setContentOffset(CGPoint(x: 0, y: 10), animated: true)
//        }
    }
    
    //MARK: ----------------GETTING VALUE FROM SCALE
    @objc func heightChanged(_ sender: HeightPickerControl) {
        print("Selected: \(sender.selectedFeet)ft \(sender.selectedInches)in")
        
        let feetAttributes = [
            .font: AppFont.bold.size(50.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let ftAttributes = [
            .font: AppFont.medium.size(25.0, familyName: familyManrope),
            .foregroundColor: UIColor.txtDarkGray
        ] as [NSAttributedString.Key : Any]
        
        //----------------Getting unit
        switch sender.unit {
         case .feetInches:
             print("Selected: \(sender.selectedFeet) ft \(sender.selectedInches) in")
            
            self.selectedHeight = nil
            self.selectedHeight = "\(sender.selectedFeet)ft\(sender.selectedInches)"
                        
            var attributedParts: [AttributedStringComponent] = [
                NSAttributedString(string: "\(sender.selectedFeet)", attributes: feetAttributes),
                NSAttributedString(string: "ft", attributes: ftAttributes)
            ]
        
            if sender.selectedInches > 0 {
                attributedParts.append(NSAttributedString(string: "\(sender.selectedInches)", attributes: feetAttributes))
                attributedParts.append(NSAttributedString(string: "in", attributes: ftAttributes))
            }

            self.titleFeetLbl.attributedText = NSAttributedString(from: attributedParts, defaultAttributes: feetAttributes)
            
         case .centimeters:
             print("Selected: \(sender.selectedCM) cm")
            
            self.selectedHeight = nil
            self.selectedHeight = "\(sender.selectedCM)cm"
            
            let attributedParts: [AttributedStringComponent] = [
                NSAttributedString(string: formatNumber(sender.selectedCM), attributes: feetAttributes),
                NSAttributedString(string: "cm", attributes: ftAttributes)
            ]
                        
            self.titleFeetLbl.attributedText = NSAttributedString(from: attributedParts, defaultAttributes: feetAttributes)
         }
    }
    
    private func formatNumber(_ number: Double) -> String {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(number)) // Remove decimal
        } else {
            return String(number) // Keep decimal
        }
    }
    
    func setUpSegmet(){
        heightMeasureType.setTitle("feet", forSegmentAt: 0)
        heightMeasureType.setTitle("cms", forSegmentAt: 1)
        setUISegmentControlAppearance()
    }
    
    func setUISegmentControlAppearance() {
//        UISegmentedControl.appearance().selectedSegmentTintColor = .white
//        UISegmentedControl.appearance().backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.txtDarkGray, .font:AppFont.semibold.size(14.0, familyName: familyManrope)], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.appWhite, .font:AppFont.semibold.size(14.0, familyName: familyManrope)], for: .selected)
    }
    
    //MARK: ------------setup segmantstyle
    func setupSegmentedControlStyle(){
        let unselectedBackgroundImage = UIImage(color: UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1))
        let selectedBacgroundImage = UIImage(color:UIColor.appYellow)

        heightMeasureType.setBackgroundImage(unselectedBackgroundImage, for: .normal, barMetrics: .default)
        heightMeasureType.setBackgroundImage(unselectedBackgroundImage, for: .highlighted, barMetrics: .default)
        heightMeasureType.setBackgroundImage(selectedBacgroundImage, for: .selected, barMetrics: .default)

        heightMeasureType.setDividerImage(selectedBacgroundImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        heightMeasureType.layer.borderWidth = 0
        heightMeasureType.layer.borderColor = UIColor.clear.cgColor
    }
    
    @IBAction func heightMeasureTypeActn(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex )
        
        if sender.selectedSegmentIndex == 0 {
            self.setupFeetRuler()
        }else{
            self.setupCMSRuler()
        }
    }
    
    
    @IBAction func continueBtnActn(_ sender: Any) {
        
        //--------discussion on responce model as like weight, height data type
        if let selectedHeight = self.selectedHeight, !selectedHeight.isEmpty {
            RegistrationVM.addheightApi(viewController: self, inputHeight: selectedHeight, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                
                if getResultData.status == true {
                    appUserDefaults.setRegistrationSkip(value: false)
                    
                    if let detailsData = getResultData.data {
                        appUserDefaults.saveUserToUserDefaults(detailsData)
                    }
                    
                    let vc:GoalsViewController = GoalsViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.select_Height)
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
}

