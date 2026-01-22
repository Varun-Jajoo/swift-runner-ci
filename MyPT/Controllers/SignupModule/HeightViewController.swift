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
    private let haptic = UISelectionFeedbackGenerator()
    private var lastHapticValue: Int?
    
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
        haptic.prepare()
        
        
//        setUpSegmet()
//        setupSegmentedControlStyle()
//        enableContinueBtn(isSelected: true)
//        self.setupFeetRuler()
        
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
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
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
    }
    
    private func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.5)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
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
                let image = UIImage(named: "ButtonNext")?
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
                continueBtn.setTitle("NEXT", for: .normal)
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
    
//    func setupContinueButtonIcon(isEnabled: Bool) {
//        let arrowImage = UIImage(named: isEnabled ? "blackRightArrow" : "whiteRightArrow")?
//            .withRenderingMode(.alwaysTemplate)
//        
//        continueBtn.setImage(arrowImage, for: .normal)
//        
//        // Force image on right side
//        continueBtn.semanticContentAttribute = .forceRightToLeft
//        
//        // Space between text and image
//        continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -12)
//        continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 12)
//        
//        continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//    }
    
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
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
//            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
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
//            imgSlider.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: 20),
            imgSlider.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: 15),
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
        valueLabel.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
//        valueLabel.textColor = #colorLiteral(red: 0.8466725945, green: 0.9522742629, blue: 0.276040554, alpha: 1)
        valueLabel.textColor = UIColor(red: 214/255, green: 244/255, blue: 7/255, alpha: 1)
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
        
        // ✅ HAPTIC ONLY WHEN VALUE CHANGES
            if lastHapticValue != value {
                haptic.selectionChanged()
                haptic.prepare()
                lastHapticValue = value
            }
        
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
        let switchingToFeet = sender.tag == 0
                // UI
                isFeetSelected = switchingToFeet
                btnFeet.backgroundColor = switchingToFeet ? .white : .clear
                btnFeet.setTitleColor(switchingToFeet ? .black : .white, for: .normal)
                btnCms.backgroundColor = switchingToFeet ? .clear : .white
                btnCms.setTitleColor(switchingToFeet ? .white : .black, for: .normal)
                
                if switchingToFeet {
                    // 🔁 CM → FEET
                    let cmValue = Int(extractDigits(from: valueLabel.text ?? "")) ?? 0
                    let converted = cmToFeetInch(cmValue)
                    
                    rulerView.heightUnit = .feet
                    let totalInches = converted.feet * 12 + converted.inches
                    currentIndex = totalInches
                    
                    rulerView.scrollToValue(
                        rulerView: rulerView,
                        scrollView: scrollView,
                        totalInches - 1
                    )
                    valueLabel.text = "\(converted.feet) ft \(converted.inches) in"
                } else {
                    // 🔁 FEET → CM
                    let digits = extractDigits(from: valueLabel.text ?? "")
                    let chars = Array(digits)
                    let feet = Int(String(chars.first ?? "0")) ?? 0
                    let inches = chars.count > 1 ? Int(String(chars.dropFirst())) ?? 0 : 0
                    
                    let cmValue = heightInCm(feet: feet, inches: inches)
                    
                    rulerView.heightUnit = .centimeters
                    currentIndex = cmValue
                    
                    rulerView.scrollToCentimeter(cmValue - 1, scrollView: scrollView)
                    valueLabel.text = "\(cmValue) cm"
                }
    }
    
    private func setupValueTextField() {
        valueTextField.text = ""
        valueTextField.textColor = .white
        valueTextField.font = AppFont.semibold.size(40.0, familyName: familyClashDisplay)
        valueTextField.textAlignment = .center
        valueTextField.keyboardType = .numberPad
        valueTextField.backgroundColor = .clear
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        valueTextField.tintColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.55)
        view.addSubview(valueTextField)
        
        valueTextField.delegate = self
        valueTextField.isUserInteractionEnabled = false
        
        // Underline
        underlineView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(underlineView)
        
        // Button
        moveButton.setImage(UIImage(named: "editIcon"), for: .normal)
        moveButton.tintColor = .white
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
    
    func cmToFeetInch(_ cm: Int) -> (feet: Int, inches: Int) {
            let totalInches = Double(cm) / 2.54
            let rounded = Int(round(totalInches))
            let feet = rounded / 12
            let inches = rounded % 12
            return (feet, inches)
        }
    
    @objc override func keyboardWillShow(_ notification: Notification) {
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            
            let keyboardHeight = frame.height - view.safeAreaInsets.bottom
            lblNote.isHidden = true
            
            // Adaptive keyboard padding (SE vs big phones)
            let padding: CGFloat = view.bounds.height < 700 ? 35 : 80
            nextButtonBottomConstraint.constant = keyboardHeight + padding
            
            valueTextFieldCenterYConstraint.isActive = false
            textFieldAboveButtonConstraint.isActive = true
            
            let screenHeight = view.bounds.height
            let spacing: CGFloat = view.bounds.height < 700 ? -70 : -100
            textFieldAboveButtonConstraint.constant = spacing
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
        @objc override func keyboardWillHide(_ notification: Notification) {
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            
            nextButtonBottomConstraint.constant = 16
            textFieldAboveButtonConstraint.isActive = false
            valueTextFieldCenterYConstraint.isActive = true
            valueTextFieldCenterYConstraint.constant = 12
            lblNote.isHidden = false
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    
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
                    let digits = extractDigits(from: valueLabel.text ?? "")
                    valueTextField.keyboardType = .numberPad
                    previousText = formatFeetInch(from: digits)
                    valueTextField.text = formatFeetInch(from: digits)
                    
                } else {
                    previousText = ""
                    let digits = extractDigits(from: valueLabel.text ?? "")
                    valueTextField.keyboardType = .numberPad
                    valueTextField.text = formatCentimeter(from: digits)
                    valueTextField.isUserInteractionEnabled = true
                }
            }
        }
        
        func formatFeetInchText(from text: String) -> String {
            let cleaned = text
                .lowercased()
                .replacingOccurrences(of: "ft", with: "")
                .replacingOccurrences(of: "in", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            let parts = cleaned.split(separator: " ")
            
            guard let feet = parts.first else { return text }
            
            if parts.count > 1, let inch = parts.last, inch != "0" {
                return "\(feet) ft \(inch) in"
            } else {
                return "\(feet) ft"
            }
        }
        
        // Convert digits → "XXX cm"
        func formatCentimeter(from digits: String) -> String {
            guard !digits.isEmpty else { return "" }
            return "\(digits) cm"
        }
        
        // Extract only digits from text
        func extractDigits(from text: String) -> String {
            return text.filter { $0.isNumber }
        }
        
        // Convert digits → "X ft Y in"
        func formatFeetInch(from digits: String) -> String {
            guard !digits.isEmpty else { return "" }
            
            if digits.count == 1 {
                return "\(digits) ft"
            }
            
            let chars = Array(digits)
            let feet = chars[0]
            let inchDigits = chars.dropFirst()
            let inches = min(Int(String(inchDigits)) ?? 0, 11)
            
            return "\(feet) ft \(inches) in"
        }
        
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if isFeetSelected {
                let currentText = textField.text ?? ""
                let rawDigits = extractDigits(from: currentText)
                if string.isEmpty {
                    let newDigits = String(rawDigits.dropLast())
                    textField.text = formatFeetInch(from: newDigits)
                    return false
                }
                
                // Allow only numbers
                guard string.allSatisfy({ $0.isNumber }) else { return false }
                
                let newDigits = rawDigits + string
                
                // Max 3 digits: (5 11)
                if newDigits.count > 3 { return false }
                
                textField.text = formatFeetInch(from: newDigits)
                return false
            } else {
                let currentText = textField.text ?? ""
                let rawDigits = extractDigits(from: currentText)
                
                // BACKSPACE
                if string.isEmpty {
                    let newDigits = String(rawDigits.dropLast())
                    textField.text = formatCentimeter(from: newDigits)
                    return false
                }
                
                // Allow only digits
                guard string.allSatisfy({ $0.isNumber }) else { return false }
                
                let newDigits = rawDigits + string
                
                // Optional max: 3 digits (300 cm)
                if newDigits.count > 3 { return false }
                
                let value = Int(newDigits) ?? 0
                if value > 300 { return false }
                
                textField.text = formatCentimeter(from: newDigits)
                return false
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            textFieldLeadingConstraint.isActive = true
            textFieldCenterConstraint.isActive = false
            if isFeetSelected {
                let digits = extractDigits(from: valueTextField.text ?? "")
                guard !digits.isEmpty else {
                    setScreenUI(showSlider: true)
                    return
                }
                
                let chars = Array(digits)
                let feet = Int(String(chars[0])) ?? 0
                let inches = chars.count > 1 ? Int(String(chars.dropFirst())) ?? 0 : 0
                
                let rulerValue = feet * 12 + min(inches, 11)
                rulerView.scrollToValue(rulerView: rulerView,
                                        scrollView: scrollView,
                                        rulerValue - 1)
            } else {
                let digits = extractDigits(from: valueTextField.text ?? "")
                guard let value = Int(digits) else {
                    setScreenUI(showSlider: true)
                    return
                }
                
                rulerView.scrollToCentimeter(value - 1, scrollView: scrollView)
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
