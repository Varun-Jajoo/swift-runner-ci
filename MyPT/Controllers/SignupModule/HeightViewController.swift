//
//  HeightViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/11/24.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

class HeightViewController: CommonViewController, UIScrollViewDelegate, UITextFieldDelegate {

    //MARK: -------------VARIABLE
    var selectedHeight:String?
    var heightPicker = HeightPickerControl()
    var titleFeetLbl = UILabel()
    private var backgroundGradient: CAGradientLayer?
    private let imgSlider = UIImageView()
    private let scrollView = UIScrollView()
    private let rulerView = VerticalRulerView()
    private let valueLabel = ObservableLabel()
//    private let valueLabel = UILabel()
    private let valueTextField = UITextField()
    let indicator = UIView()
    private let curvedIndicator = UIView()
    private let underlineView = UIView()
    private let moveButton = UIButton(type: .system)
    var currentIndex = 55
    var previousText = ""
    private var textFieldLeadingConstraint: NSLayoutConstraint!
    private var textFieldCenterConstraint: NSLayoutConstraint!
    private var valueTextFieldCenterYConstraint: NSLayoutConstraint!
    private var textFieldAboveButtonConstraint: NSLayoutConstraint!
    
    var isFeetSelected = true
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet var viewBackground: UIView!
    @IBOutlet weak var viewHeightType: UIView!
    @IBOutlet weak var btnFeet: UIButton!
    @IBOutlet weak var btnCms: UIButton!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var nextButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setUpFont()
        setupBackgroundGradient()
        updateContinueButton(isEnabled: true)
        setupContinueButtonIcon(isEnabled: true)
        setupScrollView()
        setupIndicator()
        rulerView.heightUnit = .feet
        viewHeightType.layer.cornerRadius = 25
        btnFeet.layer.cornerRadius = 20
        btnCms.layer.cornerRadius = 20
        btnFeet.layer.masksToBounds = true
        btnCms.layer.masksToBounds = true
        btnFeet.backgroundColor = .white
        btnFeet.setTitleColor(.black, for: .normal)
        //        setupUI()
        setupValueTextField()
        
        
//        setUpSegmet()
//        setupSegmentedControlStyle()
//        enableContinueBtn(isSelected: true)
//        self.setupFeetRuler()
        
        if let userData = appUserDefaults.getUserFromUserDefaults(as: UserModel.self), let userName = userData.name {
            print("userData", userData)
            print("userData name: ", userName, "Id: ",userData.id ?? "",  userData.phone ?? "")
        }
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow),
//            name: UIResponder.keyboardWillShowNotification,
//            object: nil
//        )
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillHide),
//            name: UIResponder.keyboardWillHideNotification,
//            object: nil
//        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.rulerView.scrollToValue(rulerView: rulerView, scrollView: scrollView, currentIndex)
        self.valueLabel.text = rulerView.displayText(for: rulerView.selectedValue ?? currentIndex)
        IQKeyboardManager.shared.isEnabled = false
        IQKeyboardToolbarManager.shared.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
    }
    
    private func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.5)
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(setTitle: [AppStrings.skipStr], setTintColor: .black, setTitleColor: UIColor.txtSkip)
    }
    
    //------------------************Font
    private func setUpFont() {
        self.lblNote.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.btnFeet.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.btnCms.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
    override func rightBtnActn(sender: UIButton) {
        appUserDefaults.setRegistrationSkip(value: true)
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
    }
    
    //MARK: ---------- SET UI
    private func setupUI() {
        //-----------*************
        DispatchQueue.main.async {
//            self.heightMeasureType.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 6.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
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
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        
        imgSlider.image = UIImage(named: "verticalSlider")
        imgSlider.contentMode = .scaleAspectFit
        
        view.addSubview(scrollView)
        scrollView.addSubview(rulerView)
        view.addSubview(imgSlider)
        imgSlider.translatesAutoresizingMaskIntoConstraints = false
        rulerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70),
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 68),
            scrollView.widthAnchor.constraint(equalToConstant: 80),
            scrollView.heightAnchor.constraint(equalToConstant: 300),
            
            rulerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            rulerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            rulerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            rulerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            rulerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imgSlider.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 60),
            imgSlider.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: 20),
            imgSlider.widthAnchor.constraint(equalToConstant: 270),
            imgSlider.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    private func setupIndicator() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = .clear
        
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: 19.5),
            indicator.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 80),
            indicator.widthAnchor.constraint(equalToConstant: 40),
            indicator.heightAnchor.constraint(equalToConstant: 2)
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
        valueLabel.font = .boldSystemFont(ofSize: 22)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textColor = #colorLiteral(red: 0.8466725945, green: 0.9522742629, blue: 0.276040554, alpha: 1)
        valueLabel.onTextChange = {
            text in
            if let value = text {
                self.valueTextField.text = "\(String(describing: value))"
            }
        }
        view.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.centerYAnchor.constraint(equalTo: indicator.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: indicator.leadingAnchor, constant: -10)
        ])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerOffset = scrollView.contentOffset.y + scrollView.bounds.height / 2
        let value = Int(round(centerOffset / rulerView.lineSpacing))
        valueLabel.text = "\(rulerView.displayText(for: value))"
        self.selectedHeight = valueLabel.text
        print(valueLabel.text)
//        valueTextField.text = "\(rulerView.displayText(for: value))"
        currentIndex = value
        let centerY = scrollView.contentOffset.y + scrollView.bounds.height / 2
        rulerView.indicatorY = centerY
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let spacing = rulerView.lineSpacing
        let targetY = round(targetContentOffset.pointee.y / spacing) * spacing
        targetContentOffset.pointee.y = targetY
        let centerY = scrollView.contentOffset.y + scrollView.bounds.height / 2
        rulerView.indicatorY = centerY
        rulerView.indicatorY = centerY
    }
    
    private func heightInCm(feet: Int, inches: Int) -> Int {
        let totalInches = feet * 12 + inches
        let cm = Double(totalInches) * 2.54
        return Int(round(cm))
    }
    
    private func heightInFeetAndInches(cm: Int) -> (feet: Int, inches: Int) {
        let totalInches = Double(cm) / 2.54
        let roundedInches = Int(round(totalInches))
        let feet = roundedInches / 12
        let inches = roundedInches % 12
        return (feet, inches)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedValue(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectedValue(scrollView)
        }
    }
    
    private func updateSelectedValue(_ scrollView: UIScrollView) {
        let centerY = scrollView.contentOffset.y + scrollView.bounds.height / 2
        let value = Int(round(centerY / rulerView.lineSpacing)) + rulerView.minValue
        rulerView.selectedValue = value
    }
    
    @IBAction func heightType(_ sender: UIButton) {
        isFeetSelected = sender.tag == 0
        btnFeet.backgroundColor = sender.tag == 0 ? .white : .clear
        btnFeet.setTitleColor(sender.tag == 0 ? .black : .white, for: .normal)
        btnCms.backgroundColor = sender.tag == 0 ? .clear : .white
        btnCms.setTitleColor(sender.tag == 0 ? .white : .black, for: .normal)
        rulerView.heightUnit = sender.tag == 0 ? .feet : .centimeters
        valueTextField.keyboardType = sender.tag == 0 ? .decimalPad : .numberPad
        if valueTextField.isUserInteractionEnabled == true {
            if sender.tag == 0 {
                previousText = "\(String(describing: feetInchToDecimal(valueLabel.text ?? "")))"
                valueTextField.text = "\(String(describing: feetInchToDecimal(valueLabel.text ?? "")))"
            } else {
                previousText = ""
                valueLabel.text = "\(trimLastTwoCharacters(from: rulerView.displayText(for: currentIndex)))"
                valueTextField.becomeFirstResponder()
            }
        } else {
            valueLabel.text = "\(rulerView.displayText(for: currentIndex))"
        }
//        btnFeet.backgroundColor = sender.tag == 0 ? .white : .clear
//        btnFeet.setTitleColor(sender.tag == 0 ? .black : .white, for: .normal)
//        btnCms.backgroundColor = sender.tag == 0 ? .clear : .white
//        btnCms.setTitleColor(sender.tag == 0 ? .white : .black, for: .normal)
//        rulerView.heightUnit = sender.tag == 0 ? .feet : .centimeters
//        valueLabel.text = "\(rulerView.displayText(for: currentIndex))"
//        valueTextField.text = "\(rulerView.displayText(for: currentIndex))"
    }
    
    private func setupValueTextField() {
        valueTextField.text = ""
        valueTextField.textColor = .white
        valueTextField.font = AppFont.semibold.size(40.0, familyName: familyClashDisplay)
        valueTextField.textAlignment = .center
        valueTextField.keyboardType = .decimalPad
        valueTextField.backgroundColor = .clear
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(valueTextField)
        
        valueTextField.delegate = self
        valueTextField.isUserInteractionEnabled = false
        
        // Underline
        underlineView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(underlineView)
        
        // Button
        moveButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        moveButton.tintColor = .white.withAlphaComponent(0.5)
        moveButton.addTarget(self, action: #selector(moveLabelToCenter), for: .touchUpInside)
        moveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(moveButton)
        
        // Constraints
        textFieldLeadingConstraint = valueTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        textFieldCenterConstraint = valueTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        textFieldCenterConstraint.isActive = false
        
        textFieldAboveButtonConstraint =
        valueTextField.bottomAnchor.constraint(equalTo: continueBtn.topAnchor, constant: -12)
        
        textFieldAboveButtonConstraint.isActive = false   // only used when editing
        
        // Create the constraint and store it
        valueTextFieldCenterYConstraint =
        valueTextField.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor,
                                                constant: 12)
        
        // Activate all constraints together
        NSLayoutConstraint.activate([
            textFieldLeadingConstraint,
            valueTextFieldCenterYConstraint,
            valueTextField.heightAnchor.constraint(equalToConstant: 32),
            
            underlineView.topAnchor.constraint(equalTo: valueTextField.bottomAnchor, constant: 6),
            underlineView.leadingAnchor.constraint(equalTo: valueTextField.leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: valueTextField.trailingAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 2),
            
            moveButton.leadingAnchor.constraint(equalTo: valueTextField.trailingAnchor, constant: 8),
            moveButton.centerYAnchor.constraint(equalTo: valueTextField.centerYAnchor)
        ])
        
    }
    
    
//    @objc override func keyboardWillShow(_ notification: Notification) {
//        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
//              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
//        
//        let keyboardHeight = frame.height - view.safeAreaInsets.bottom
//        
//        // Adaptive keyboard padding (SE vs big phones)
//        let padding: CGFloat = view.bounds.height < 700 ? 12 : 38
//        nextButtonBottomConstraint.constant = keyboardHeight + padding
//        
//        valueTextFieldCenterYConstraint.isActive = false
//        textFieldAboveButtonConstraint.isActive = true
//        
//        let screenHeight = view.bounds.height
//        let spacing: CGFloat = screenHeight < 700 ? -12 : -34
//        textFieldAboveButtonConstraint.constant = spacing
//        
//        UIView.animate(withDuration: duration) {
//            self.view.layoutIfNeeded()
//        }
//    }
    
//    @objc override func keyboardWillHide(_ notification: Notification) {
//        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
//        
//        nextButtonBottomConstraint.constant = 16
//        textFieldAboveButtonConstraint.isActive = false
//        valueTextFieldCenterYConstraint.isActive = true
//        valueTextFieldCenterYConstraint.constant = 12
//        
//        UIView.animate(withDuration: duration) {
//            self.view.layoutIfNeeded()
//        }
//    }
    
    // MARK: Button Tap Function
    @objc private func moveLabelToCenter() {
        valueTextField.isUserInteractionEnabled = true
        textFieldLeadingConstraint.isActive = false
        textFieldCenterConstraint.isActive = true
        setScreenUI(showSlider: false)
        valueTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setScreenUI(showSlider : Bool) {
        scrollView.isHidden = !showSlider
        valueLabel.isHidden = !showSlider
        imgSlider.isHidden = !showSlider
        indicator.isHidden = !showSlider
        moveButton.isHidden = !showSlider
        underlineView.isHidden = !showSlider
        btnFeet.isUserInteractionEnabled = showSlider
        btnCms.isUserInteractionEnabled = showSlider
        if showSlider == false {
            if isFeetSelected {
                previousText = "\(String(describing: feetInchToDecimal(valueLabel.text ?? "")))"
                valueTextField.text = "\(String(describing: feetInchToDecimal(valueLabel.text ?? "")))"
            } else {
                previousText = ""
                valueTextField.text = trimLastTwoCharacters(from: valueTextField.text ?? "")
                valueTextField.isUserInteractionEnabled = true
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if isFeetSelected {
            let currentText = textField.text ?? ""
            let nsText = currentText as NSString
            let updatedText = nsText.replacingCharacters(in: range, with: string)
            if updatedText.isEmpty {
                return true
            }
            if updatedText.filter({ $0 == "." }).count > 1 {
                return false
            }
            let parts = updatedText.split(separator: ".")
            if let beforeDecimal = parts.first, beforeDecimal.count > 1 {
                return false
            }
            if parts.count == 2 {
                let afterDecimal = parts[1]
                if afterDecimal.count > 2 {
                    return false
                }
                if let value = Int(afterDecimal), value > 11 {
                    return false
                }
            }
            return true
        } else {
//            return true
            let currentText = textField.text ?? ""
                   let nsText = currentText as NSString
                   let updatedText = nsText.replacingCharacters(in: range, with: string)

                   // Allow delete
                   if updatedText.isEmpty {
                       return true
                   }

                   // Allow only digits
                   if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: updatedText)) {
                       return false
                   }

                   // Convert to number
                   guard let value = Int(updatedText) else {
                       return false
                   }

                   // Range check: 0–300
                   return value >= 0 && value <= 300
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldLeadingConstraint.isActive = true
        textFieldCenterConstraint.isActive = false
        if isFeetSelected {
            let value = Double(valueTextField.text ?? "") ?? 0.0
            let rulerInt = rulerValue(from: value)
            if previousText != "\(String(describing: value))" {
                rulerView.scrollToValue(rulerView: rulerView, scrollView: scrollView, rulerInt)
            } else {
                valueTextField.text = valueLabel.text
            }
        } else {
            var finalValue = Int(valueTextField.text ?? "0") ?? 0
            finalValue -= 1
            rulerView.scrollToCentimeter(finalValue , scrollView: scrollView)
        }
        valueTextField.isUserInteractionEnabled = false
        setScreenUI(showSlider: true)
    }
    
    func feetInchToDecimal(_ text: String) -> Double {
        let cleaned = text
            .lowercased()
            .replacingOccurrences(of: "ft", with: "")
            .replacingOccurrences(of: "in", with: "")
        
        let parts = cleaned.split(separator: " ")
        guard parts.count >= 1,
              let feet = Double(parts[0]) else { return 0.0 }
        
        let inches = parts.count > 1 ? Double(parts[1]) ?? 0 : 0
        let fraction = convertToFractionalDouble(inches)
        let decimal = feet + fraction
        return decimal
    }
    
    func convertToFractionalDouble(_ value: Double) -> Double {
        let intPart = Int(value)
        let digits = String(intPart).count
        let divisor = pow(10.0, Double(digits))
        return Double(intPart) / divisor
    }
    
    func rulerValue(from height: Double) -> Int {
        let feet = Int(height)
        let inchPart = height - Double(feet)
        
        // Convert decimal to inches (0–11)
        let inches = min(Int(round(inchPart * 10)), 11)
        var value = feet * 12 + inches
        value = value - 1
        return value
    }
    
    func trimLastTwoCharacters(from text: String) -> String {
        guard text.count > 2 else { return "" }
        return String(text.dropLast(2))
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
                    
                    let vc: GoalsViewController = GoalsViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        } else {
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.select_Height)
        }
    }
}



//    func setupFeetRuler(){
//        heightPicker.removeFromSuperview()
//        titleFeetLbl.removeFromSuperview()
//        titleFeetLbl  = UILabel()
//        titleFeetLbl.text = nil
//        heightPicker = HeightPickerControl()
//        heightPicker.translatesAutoresizingMaskIntoConstraints = false
//        heightPicker.unit = .feetInches
//        heightPicker.maxFeet = 300
//        heightPicker.addTarget(self, action: #selector(heightChanged(_:)), for: .valueChanged)
//        heightPicker.backgroundColor = UIColor.clear
//        heightPicker.rulerViewBgColor = UIColor.clear
//        scaleMBV.addSubview(heightPicker)
//        titleFeetLbl.backgroundColor = UIColor.clear
//        titleFeetLbl.textColor = UIColor.appWhite
//        titleFeetLbl.textAlignment = .right
//        scaleMBV.addSubview(titleFeetLbl)
//        titleFeetLbl.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            heightPicker.trailingAnchor.constraint(equalTo: scaleMBV.trailingAnchor, constant: 10),
//            heightPicker.centerYAnchor.constraint(equalTo: scaleMBV.centerYAnchor),
//            heightPicker.widthAnchor.constraint(equalToConstant: 250),
//            heightPicker.heightAnchor.constraint(equalTo: scaleMBV.heightAnchor, multiplier: 0.96),
//            titleFeetLbl.leadingAnchor.constraint(equalTo: heightPicker.leadingAnchor, constant: -170),
//            titleFeetLbl.centerYAnchor.constraint(equalTo: scaleMBV.centerYAnchor),
//            titleFeetLbl.widthAnchor.constraint(equalTo: heightPicker.widthAnchor, multiplier: 1.0),
//            titleFeetLbl.heightAnchor.constraint(equalTo: heightPicker.heightAnchor, multiplier: 0.8)
//        ])
//
//        self.scrollScale(inputView: heightPicker)
//    }
    
    //MARK: -----------------MAKE RULER FOR WEIGHT
//    func setupCMSRuler(){
//        heightPicker.removeFromSuperview()
//        titleFeetLbl.removeFromSuperview()
//        titleFeetLbl  = UILabel()
//        titleFeetLbl.text = nil
//        heightPicker = HeightPickerControl()
//        heightPicker.translatesAutoresizingMaskIntoConstraints = false
//        heightPicker.unit = .centimeters
//        heightPicker.maxCM = 650.0
//        heightPicker.addTarget(self, action: #selector(heightChanged(_:)), for: .valueChanged)
//        heightPicker.backgroundColor = UIColor.clear
//        heightPicker.rulerViewBgColor = UIColor.clear
//        scaleMBV.addSubview(heightPicker)
//        titleFeetLbl.backgroundColor = UIColor.clear
//        titleFeetLbl.textColor = UIColor.appWhite
//        titleFeetLbl.textAlignment = .right
//        scaleMBV.addSubview(titleFeetLbl)
//        titleFeetLbl.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            heightPicker.trailingAnchor.constraint(equalTo: scaleMBV.trailingAnchor, constant: 10),
//            heightPicker.centerYAnchor.constraint(equalTo: scaleMBV.centerYAnchor),
//            heightPicker.widthAnchor.constraint(equalToConstant: 250),
//            heightPicker.heightAnchor.constraint(equalTo: scaleMBV.heightAnchor, multiplier: 0.96),
//            titleFeetLbl.leadingAnchor.constraint(equalTo: heightPicker.leadingAnchor, constant: -170),
//            titleFeetLbl.centerYAnchor.constraint(equalTo: scaleMBV.centerYAnchor),
//            titleFeetLbl.widthAnchor.constraint(equalTo: heightPicker.widthAnchor, multiplier: 1.0),
//            titleFeetLbl.heightAnchor.constraint(equalTo: heightPicker.heightAnchor, multiplier: 0.8)
//        ])
//
//        self.scrollScale(inputView: heightPicker)
//    }
    
//    func scrollScale(inputView: UIView){
//
//        if let scrollView = inputView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
//            print("Found scroll view: \(scrollView)")
//            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//        }
//
////        if let scrollView = inputView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
////            print("Found scroll view: \(scrollView)")
////            scrollView.setContentOffset(CGPoint(x: 0, y: 10), animated: true)
////        }
//    }
    
    //MARK: ----------------GETTING VALUE FROM SCALE
//    @objc func heightChanged(_ sender: HeightPickerControl) {
//        print("Selected: \(sender.selectedFeet)ft \(sender.selectedInches)in")
//
//        let feetAttributes = [
//            .font: AppFont.bold.size(50.0, familyName: familyManrope),
//            .foregroundColor: UIColor.appWhite
//        ] as [NSAttributedString.Key : Any]
//
//        let ftAttributes = [
//            .font: AppFont.medium.size(25.0, familyName: familyManrope),
//            .foregroundColor: UIColor.txtDarkGray
//        ] as [NSAttributedString.Key : Any]
//
//        //----------------Getting unit
//        switch sender.unit {
//         case .feetInches:
//             print("Selected: \(sender.selectedFeet) ft \(sender.selectedInches) in")
//
//            self.selectedHeight = nil
//            self.selectedHeight = "\(sender.selectedFeet)ft\(sender.selectedInches)"
//
//            var attributedParts: [AttributedStringComponent] = [
//                NSAttributedString(string: "\(sender.selectedFeet)", attributes: feetAttributes),
//                NSAttributedString(string: "ft", attributes: ftAttributes)
//            ]
//
//            if sender.selectedInches > 0 {
//                attributedParts.append(NSAttributedString(string: "\(sender.selectedInches)", attributes: feetAttributes))
//                attributedParts.append(NSAttributedString(string: "in", attributes: ftAttributes))
//            }
//
//            self.titleFeetLbl.attributedText = NSAttributedString(from: attributedParts, defaultAttributes: feetAttributes)
//
//         case .centimeters:
//             print("Selected: \(sender.selectedCM) cm")
//
//            self.selectedHeight = nil
//            self.selectedHeight = "\(sender.selectedCM)cm"
//
//            let attributedParts: [AttributedStringComponent] = [
//                NSAttributedString(string: formatNumber(sender.selectedCM), attributes: feetAttributes),
//                NSAttributedString(string: "cm", attributes: ftAttributes)
//            ]
//
//            self.titleFeetLbl.attributedText = NSAttributedString(from: attributedParts, defaultAttributes: feetAttributes)
//         }
//    }
    
//    private func formatNumber(_ number: Double) -> String {
//        if number.truncatingRemainder(dividingBy: 1) == 0 {
//            return String(Int(number)) // Remove decimal
//        } else {
//            return String(number) // Keep decimal
//        }
//    }
//
//    func setUpSegmet(){
//        heightMeasureType.setTitle("feet", forSegmentAt: 0)
//        heightMeasureType.setTitle("cms", forSegmentAt: 1)
//        setUISegmentControlAppearance()
//    }
    
//    func setUISegmentControlAppearance() {
////        UISegmentedControl.appearance().selectedSegmentTintColor = .white
////        UISegmentedControl.appearance().backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
//        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.txtDarkGray, .font:AppFont.semibold.size(14.0, familyName: familyManrope)], for: .normal)
//        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.appWhite, .font:AppFont.semibold.size(14.0, familyName: familyManrope)], for: .selected)
//    }
    
    //MARK: ------------setup segmantstyle
//    func setupSegmentedControlStyle(){
//        let unselectedBackgroundImage = UIImage(color: UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1))
//        let selectedBacgroundImage = UIImage(color:UIColor.appYellow)
//
//        heightMeasureType.setBackgroundImage(unselectedBackgroundImage, for: .normal, barMetrics: .default)
//        heightMeasureType.setBackgroundImage(unselectedBackgroundImage, for: .highlighted, barMetrics: .default)
//        heightMeasureType.setBackgroundImage(selectedBacgroundImage, for: .selected, barMetrics: .default)
//
//        heightMeasureType.setDividerImage(selectedBacgroundImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
//
//        heightMeasureType.layer.borderWidth = 0
//        heightMeasureType.layer.borderColor = UIColor.clear.cgColor
//    }
    
//    @IBAction func heightMeasureTypeActn(_ sender: UISegmentedControl) {
//        print(sender.selectedSegmentIndex )
//
//        if sender.selectedSegmentIndex == 0 {
//            self.setupFeetRuler()
//        }else{
//            self.setupCMSRuler()
//        }
//    }
    
