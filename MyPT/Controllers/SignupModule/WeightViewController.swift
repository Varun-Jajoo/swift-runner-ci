//
//  WeightViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/11/24.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

class WeightViewController: CommonViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    // MARK: -------------VARIABLE
    var selectedWeight: String?
    var rangeStart = Measurement(value: 1.0, unit: UnitMass.kilograms)
    var rangeLength = Measurement(value: Double(100), unit: UnitMass.kilograms)
    var colorOverridesEnabled = false
    private var backgroundGradient: CAGradientLayer?
    private let scrollView = UIScrollView()
    private let indicatorImageView = UIImageView()
    private let rulerView = HorizontalRulerView()
    private let valueLabel = ObservableLabel()
    private let valueTextField = UITextField()
    let indicator = UIView()
    private let curvedIndicator = UIView()
    private let underlineView = UIView()
    private let moveButton = UIButton(type: .system)
    var currentIndex = 66
    var previousText = ""
    private var isSwitchingUnit = false
    var isKgSelected = true
    private var rulerBottomConstraint: NSLayoutConstraint!
    private var valueTextFieldCenterYConstraint: NSLayoutConstraint!
    private var textFieldAboveButtonConstraint: NSLayoutConstraint!
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet var viewBackground: UIView!
    @IBOutlet weak var viewWeightType: UIView!
    @IBOutlet weak var btnKG: UIButton!
    @IBOutlet weak var btnLBS: UIButton!
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
        viewWeightType.layer.cornerRadius = 25
        btnKG.layer.cornerRadius = 20
        btnLBS.layer.cornerRadius = 20
        btnKG.layer.masksToBounds = true
        btnLBS.layer.masksToBounds = true
        btnKG.backgroundColor = .white
        btnKG.setTitleColor(.black, for: .normal)
        //        setupUI()
        setupValueTextField()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
        let contentWidth = rulerView.intrinsicContentSize.width
        scrollView.contentSize = CGSize(
            width: contentWidth,
            height: scrollView.bounds.height
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        rulerView.scrollToValue(rulerView: rulerView, scrollView: scrollView, currentIndex)
        self.valueLabel.text = "\(rulerView.selectedValue ?? 0)"
        IQKeyboardManager.shared.isEnabled = false
         IQKeyboardToolbarManager.shared.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            IQKeyboardManager.shared.isEnabled = true
            IQKeyboardToolbarManager.shared.isEnabled = true
            NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
            NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        }
    
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

        view.addSubview(scrollView)
        scrollView.addSubview(rulerView)
        view.addSubview(indicatorImageView)

        rulerView.translatesAutoresizingMaskIntoConstraints = false
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // ScrollView frame
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 68),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 80),

            // RulerView expands horizontally
            rulerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            rulerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            rulerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            rulerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            rulerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            // Indicator
            indicatorImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            indicatorImageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: 50),
            indicatorImageView.widthAnchor.constraint(equalToConstant: 270),
            indicatorImageView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    private func setupIndicator() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = .clear
        
        view.addSubview(indicator)
        
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
//        valueLabel.textColor = #colorLiteral(red: 0.8466725945, green: 0.9522742629, blue: 0.276040554, alpha: 1)
        valueLabel.textColor = UIColor(red: 214/255, green: 244/255, blue: 7/255, alpha: 1)
        valueLabel.onTextChange = {
            text in
            if let value = text {
                self.valueTextField.text = value + (self.isKgSelected ? " kg" : " lbs")
                self.selectedWeight = self.valueTextField.text
                print(self.valueTextField.text)
            }
        }
        view.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.centerYAnchor.constraint(equalTo: indicator.centerYAnchor, constant: -40),
            valueLabel.centerXAnchor.constraint(equalTo: indicator.centerXAnchor)
        ])
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
    func setupUI() {
        //-----------*************
        DispatchQueue.main.async {
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //------------------************Font
    func setUpFont() {
        self.lblNote.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.topTitleLbl.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }

    private func setupBackgroundGradient() {
        // Remove old gradient if any
        backgroundGradient?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.colors = UIColor.appMultiColor(.greenBgGradient).map { $0.cgColor }
        
        // VERY IMPORTANT – match first UI direction
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint   = CGPoint(x: 1.0, y: 1.0)
        
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.cornerRadius = 0
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSwitchingUnit { return }

        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2

        let rawValue =
            (centerX - rulerView.edgePaddingUnits.cgFloat * rulerView.lineSpacing)
            / rulerView.lineSpacing

        let value = Int(round(rawValue))

        let clampedValue = max(
            rulerView.minValue,
            min(value, rulerView.maxValue)
        )

        rulerView.indicatorX = centerX
        rulerView.selectedValue = clampedValue
        valueLabel.text = "\(clampedValue)"
        currentIndex = clampedValue
    }

    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let spacing = rulerView.lineSpacing

        let targetX = round(targetContentOffset.pointee.x / spacing) * spacing
        targetContentOffset.pointee.x = targetX

        let centerX =
            targetX
            + scrollView.bounds.width / 2

        rulerView.indicatorX = centerX
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedValueFromScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectedValueFromScroll(scrollView)
        }
    }
    
    private func updateSelectedValueFromScroll(_ scrollView: UIScrollView) {
        let centerX =
            scrollView.contentOffset.x
            + scrollView.bounds.width / 2

        let rawValue =
            (centerX - rulerView.edgePaddingUnits.cgFloat * rulerView.lineSpacing)
            / rulerView.lineSpacing

        let value = Int(round(rawValue))

        let clampedValue = max(
            rulerView.minValue,
            min(value, rulerView.maxValue)
        )

        rulerView.selectedValue = clampedValue
        rulerView.indicatorX = centerX
    }
    
    @IBAction func heightType(_ sender: UIButton) {
        let switchingToKg = sender.tag == 0

            let currentDigits = extractDigits(from: valueLabel.text ?? "")
            let currentValue = Int(currentDigits) ?? 0

            isKgSelected = switchingToKg

            btnKG.backgroundColor = switchingToKg ? .white : .clear
            btnKG.setTitleColor(switchingToKg ? .black : .white, for: .normal)
            btnLBS.backgroundColor = switchingToKg ? .clear : .white
            btnLBS.setTitleColor(switchingToKg ? .white : .black, for: .normal)

            let convertedValue: Int

            if switchingToKg {
                convertedValue = lbsToKg(currentValue)
            } else {
                convertedValue = kgToLbs(currentValue)
            }

            rulerView.isKgSelected = switchingToKg
            currentIndex = convertedValue

            rulerView.scrollToValue(
                rulerView: rulerView,
                scrollView: scrollView,
                convertedValue
            )

            valueLabel.text = "\(convertedValue)"
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        if let selectedWeight = selectedWeight, !selectedWeight.isEmpty {
            RegistrationVM.addWeightApi(viewController: self, inputWeight: selectedWeight, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                if getResultData.status == true {
                    
                    appUserDefaults.setRegistrationSkip(value: false)
                    if let detailsData = getResultData.data?.first {
                        appUserDefaults.saveUserToUserDefaults(detailsData)
                    }
                    let vc:HeightViewController = HeightViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        } else {
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.select_Weight)
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
        
        view.addSubview(valueTextField)
        
        valueTextField.delegate = self
        valueTextField.isUserInteractionEnabled = false

        underlineView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(underlineView)

        // Button
        moveButton.setImage(UIImage(named: "editIcon"), for: .normal)
        moveButton.tintColor = .white
        moveButton.addTarget(self, action: #selector(moveLabelToCenter), for: .touchUpInside)
        moveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(moveButton)
        
        textFieldAboveButtonConstraint =
                valueTextField.bottomAnchor.constraint(equalTo: continueBtn.topAnchor, constant: -12)
                textFieldAboveButtonConstraint.isActive = false
                
                valueTextFieldCenterYConstraint =
                valueTextField.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -100)
        
        NSLayoutConstraint.activate([
            valueTextFieldCenterYConstraint,
            valueTextField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            valueTextField.heightAnchor.constraint(equalToConstant: 40),
            underlineView.topAnchor.constraint(equalTo: valueTextField.bottomAnchor, constant: 6),
            underlineView.leadingAnchor.constraint(equalTo: valueTextField.leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: valueTextField.trailingAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 2),
            
            moveButton.leadingAnchor.constraint(equalTo: valueTextField.trailingAnchor, constant: 8),
            moveButton.centerYAnchor.constraint(equalTo: valueTextField.centerYAnchor)
        ])
        
    }
    // MARK: Button Tap Function
    @objc private func moveLabelToCenter() {
        valueTextField.isUserInteractionEnabled = true
        setScreenUI(showSlider: false)
        valueTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setScreenUI(showSlider : Bool) {
        scrollView.isHidden = !showSlider
        valueLabel.isHidden = !showSlider
        indicatorImageView.isHidden = !showSlider
        indicator.isHidden = !showSlider
        moveButton.isHidden = !showSlider
        underlineView.isHidden = !showSlider
        btnKG.isUserInteractionEnabled = showSlider
        btnLBS.isUserInteractionEnabled = showSlider
        if showSlider == false {
            let digits = extractDigits(from: valueLabel.text ?? "")
            valueTextField.keyboardType = .numberPad

            if isKgSelected {
                previousText = formatKg(from: digits)
                valueTextField.text = formatKg(from: digits)
            } else {
                previousText = formatLbs(from: digits)
                valueTextField.text = formatLbs(from: digits)
            }
        }
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
            let spacing: CGFloat = screenHeight < 700 ? -50 : -90
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
            valueTextFieldCenterYConstraint.constant = -100
            lblNote.isHidden = false
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        let rawDigits = extractDigits(from: currentText)

        // BACKSPACE
        if string.isEmpty {
            let newDigits = String(rawDigits.dropLast())
            textField.text = isKgSelected
                ? formatKg(from: newDigits)
                : formatLbs(from: newDigits)
            return false
        }

        // Allow only digits
        guard string.allSatisfy({ $0.isNumber }) else { return false }

        let newDigits = rawDigits + string

        // Limits
        let value = Int(newDigits) ?? 0
        if isKgSelected {
            if value > 600 { return false }
            textField.text = formatKg(from: newDigits)
        } else {
            if value > 1500 { return false }
            textField.text = formatLbs(from: newDigits)
        }

        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        let digits = extractDigits(from: textField.text ?? "")
        guard let value = Int(digits) else {
            setScreenUI(showSlider: true)
            return
        }

        let finalValue: Int

        if isKgSelected {
            finalValue = value
        } else {
            finalValue = value
        }

        rulerView.scrollToValue(
            rulerView: rulerView,
            scrollView: scrollView,
            finalValue
        )

        valueTextField.isUserInteractionEnabled = false
        setScreenUI(showSlider: true)
    }
    
    func trimCharacters(from text: String) -> String {
        guard text.count > 2 else { return "" }
        return String(text.dropLast(isKgSelected ? 2 : 3))
    }
    
    // Digits only
    func extractDigits(from text: String) -> String {
        return text.filter { $0.isNumber }
    }

    // kg formatter
    func formatKg(from digits: String) -> String {
        guard !digits.isEmpty else { return "" }
        return "\(digits) kg"
    }

    // lbs formatter
    func formatLbs(from digits: String) -> String {
        guard !digits.isEmpty else { return "" }
        return "\(digits) lbs"
    }

    // Conversions
    func kgToLbs(_ kg: Int) -> Int {
        return Int(round(Double(kg) * 2.20462))
    }

    func lbsToKg(_ lbs: Int) -> Int {
        return Int(round(Double(lbs) / 2.20462))
    }
}

final class ObservableLabel: UILabel {
    var onTextChange: ((String?) -> Void)?
    
    override var text: String? {
        didSet {
            onTextChange?(text)
        }
    }
}

extension Int {
    var cgFloat: CGFloat { CGFloat(self) }
}
