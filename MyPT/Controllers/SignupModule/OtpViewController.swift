//
//  OtpViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/10/24.
//

import UIKit
import AVFoundation

enum vcSteps: Int {
    case one = 1, two, three, four, five, six,seven, eight
    
    static func getCurrentVC(vcRawValue: Int) -> UIViewController.Type? {
        guard let vcEnum = vcSteps(rawValue: vcRawValue) else {
            return nil // Return nil if invalid raw value is passed
        }
        
        switch vcEnum {
        case .one:
            return PersoniledViewController.self
        case .two:
            return GenderViewController.self
        case .three:
            return AgeViewController.self
        case .four:
            return WeightViewController.self
        case .five:
            return HeightViewController.self
        case .six:
            return GoalsViewController.self
        case .seven:
            return PreferenceViewController.self
        case .eight:
            return LocationsViewController.self

        }
    }
}

enum OtpBoxState {
    case empty
    case filled
    case wrongOtp
}

class OtpViewController: CommonViewController, UITextFieldDelegate {
    
    //MARK: ---------VARIABLE
    private var backgroundGradient: CAGradientLayer?
    private var isWrongOtp = false
    var player: LoopingPlayer?
    var mobilNumStr:String?
    var countryCodeStr:String?
    var inputType:String?

    lazy var timer: Timer? = nil
    
    lazy var timeCouter : Int? = nil {
        didSet{
            if let timeCouter = timeCouter {
                receiveOtpLbl.text = nil
                if timeCouter > 0 {
                    resentOtpLbl.text = "\(timeCouter) seconds"
                } else {
                    self.stopTimer()
                    receiveOtpLbl.text = "Didn’t receive OTP?"
                    self.setupResnd(timeStr: "\(timeCouter)")
                }
            }
        }
    }
    
    //MARK: ---------- IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var topDescLbl: UILabel!
    @IBOutlet weak var mobilNumeLbl: UILabel!
    @IBOutlet weak var oneTxtField: UITextField!
    @IBOutlet weak var twoTxTField: UITextField!
    @IBOutlet weak var threeTxTField: UITextField!
    @IBOutlet weak var fourTxTField: UITextField!
    @IBOutlet weak var receiveOtpLbl: UILabel!
    @IBOutlet weak var resentOtpLbl: UILabel!
    @IBOutlet weak var invalidOtpLbl: UILabel!
    @IBOutlet weak var oneImgView: UIImageView!
    @IBOutlet weak var twoImgView: UIImageView!
    @IBOutlet weak var threeImgView: UIImageView!
    @IBOutlet weak var fourImgView: UIImageView!
    @IBOutlet weak var oneContainer: UIView!
    @IBOutlet weak var twoContainer: UIView!
    @IBOutlet weak var threeContainer: UIView!
    @IBOutlet weak var fourContainer: UIView!
    @IBOutlet weak var viewBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mobileNumFormat()
//        if let countryCodeStr = countryCodeStr, let mobilNumStr = mobilNumStr {
//            mobilNumeLbl.text = countryCodeStr + mobilNumStr
//        }
        receiveOtpLbl.text = nil
        resentOtpLbl.text  = nil
        self.startTimer()
        setupBackgroundGradient()
        oneTxtField.delegate = self
        twoTxTField.delegate = self
        threeTxTField.delegate = self
        fourTxTField.delegate = self
        setupOtpBoxes()
        setupUI()
        setUpFont()
//        setUpVideo()
        self.customBlurViewShow(viewShow: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.endEditing(true)   // ⬅️ IMPORTANT
        updateOtpUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
    }

    func updateOtpUI() {
        let mapping: [(UITextField, UIView)] = [
            (oneTxtField, oneContainer),
            (twoTxTField, twoContainer),
            (threeTxTField, threeContainer),
            (fourTxTField, fourContainer)
        ]

        mapping.forEach { field, container in
            if isWrongOtp {
                container.applyOtpStyle(.wrongOtp)
            } else {
                let isFilled = !(field.text?.isEmpty ?? true)
                container.applyOtpStyle(isFilled ? .filled : .empty)
            }
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        super.keyboardWillHide(notification)
        self.customBlurViewShow(viewShow: self.view)
    }
    
    deinit {
        player?.progressDelegate = nil
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        self.startTimer()
        setNavUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
        self.player?.pause()
        self.player?.pausePlayback()
    }
    
    func setNavUI() {
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [AppImages.help], setTitle: [AppStrings.helpStr], setTintColor: .black, setTitleColor: UIColor.appWhite,isRightImg: [false])
    }
    
    //MARK: ---------------EDIT MOBILE NUMBER ACTN
    @IBAction func editMobileBtnActn(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    private func mobileNumFormat(){
        if let countryCodeStr = countryCodeStr, let mobilNumStr = mobilNumStr {
            var formattedNum = ""
            for (index, char) in mobilNumStr.enumerated() {
                if index == 3 || index == 6 {
                    formattedNum += "-"
                }
                formattedNum += String(char)
            }
            mobilNumeLbl.text = "\(countryCodeStr) \(formattedNum)"
        }
    }
    
    //MARK: ---------------------VIDEO SETUP
    func setUpVideo(){
        if let filePath = Bundle.main.path(forResource: "landdingVideo", ofType: "mp4") {
            let fileURL = URL(fileURLWithPath: filePath)
            
            // Initialize LoopingPlayer
            player = LoopingPlayer(url: fileURL)
            player?.progressDelegate = self
            
            // Add video layer
            if let player = player {
                let playerLayer = AVPlayerLayer(player: player)
                DispatchQueue.main.async {
                    playerLayer.frame = self.view.bounds
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    playerLayer.zPosition = -1
                    self.view.layer.addSublayer(playerLayer)
                }
                
                // Start playback
                player.play()
            }
        } else {
            print("Video file not found")
        }
        
    }
    
    //MARK: --------------------Timer
    func startTimer() {
        self.stopTimer()
        self.timeCouter = 30 //1
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getTime), userInfo: nil, repeats: true)
    }
    
    @objc func getTime() {
        if let _ = self.timeCouter {
            self.timeCouter! -= 1
        }else{
            print("Timer",timer?.timeInterval as Any)
            self.timeCouter = 1
        }
        
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    //------------------************Font
    func setupResnd(timeStr: String){
        //-------------------- Attributed Text
        let defaultAttributes = [
            .font: AppFont.regular.size(12.0, familyName: familyManrope),
            .foregroundColor: UIColor.txtDarkGray
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.bold.size(12.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "Resend OTP in ",
            NSAttributedString(string: timeStr + " " + "seconds",
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        self.resentOtpLbl.attributedText       =  NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
        
        // Add a tap gesture recognizer
        self.resentOtpLbl.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
        self.resentOtpLbl.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Handle Tap Gesture
    @objc func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        let text = self.resentOtpLbl.attributedText?.string ?? ""
        let clickableText = "Resend OTP in"
        
        let tapLocation = gesture.location(in: self.resentOtpLbl)
        
        // Find the range of the clickable text
        let textStorage = NSTextStorage(attributedString: self.resentOtpLbl.attributedText ?? NSAttributedString())
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: self.resentOtpLbl.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = self.resentOtpLbl.lineBreakMode
        textContainer.maximumNumberOfLines = self.resentOtpLbl.numberOfLines
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let characterIndex = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // Check if the tapped character is within the range of the clickable text
        let clickableRange = (text as NSString).range(of: clickableText)
        if NSLocationInRange(characterIndex, clickableRange) {
            // Perform the action for the clickable text
            print("Resend tapped!")
            self.resendOtp()
        }
    }
    
    func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.topDescLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.mobilNumeLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.oneTxtField.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.twoTxTField.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.threeTxTField.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.fourTxTField.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        
        self.receiveOtpLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        self.resentOtpLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        self.resentOtpLbl.textColor = UIColor.appWhite
        self.invalidOtpLbl.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
     
        //------------
        if inputType != "3" {
            self.topTitleLbl.text = "Verify your mobile number"
        }else{
            self.topTitleLbl.text = "Verify your email"
        }
        //        //-------------------- Attributed Text
        //
        //        let defaultAttributes = [
        //            .font: AppFont.regular.size(12.0, familyName: familyManrope),
        //            .foregroundColor: UIColor.txtDarkGray
        //        ] as [NSAttributedString.Key : Any]
        //
        //        let makeAttributes = [
        //            .font: AppFont.regular.size(12.0, familyName: familyManrope),
        //            .foregroundColor: UIColor.appWhite
        //        ] as [NSAttributedString.Key : Any]
        //
        //        let attributedNickName = [
        //            "Resend OTP in",
        //            NSAttributedString(string: "30 second",
        //                               attributes: makeAttributes)
        //        ] as [AttributedStringComponent]
        //        self.resentOtpLbl.attributedText       =  NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
    
    func setupUI() {
        invalidOtpLbl.isHidden = true
        oneTxtField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        twoTxTField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        threeTxTField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        fourTxTField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
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

    @objc func textFieldDidChange(textField: UITextField) {
        
        if isWrongOtp {
            isWrongOtp = false
            invalidOtpLbl.isHidden = true
        }

        let text = textField.text

        if (text?.utf16.count ?? 0) >= 1 {
            switch textField {
            case oneTxtField: twoTxTField.becomeFirstResponder()
            case twoTxTField: threeTxTField.becomeFirstResponder()
            case threeTxTField: fourTxTField.becomeFirstResponder()
            case fourTxTField:
                fourTxTField.resignFirstResponder()
                if isValiadteOtp() {
                    let otp = [
                        oneTxtField.text,
                        twoTxTField.text,
                        threeTxTField.text,
                        fourTxTField.text
                    ].compactMap { $0 }.joined()
                    submitOtp(inputOtp: otp)
                }
            default: break
            }
        } else {
            switch textField {
            case twoTxTField: oneTxtField.becomeFirstResponder()
            case threeTxTField: twoTxTField.becomeFirstResponder()
            case fourTxTField: threeTxTField.becomeFirstResponder()
            default: break
            }
        }
        // ✅ THIS IS THE KEY LINE
        updateOtpUI()
    }
    
    // UITextFieldDelegate method to restrict the input to 1 digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numeric input
        let allowedCharacterSet = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        if !allowedCharacterSet.isSuperset(of: characterSet) {
            return false // Disallow non-numeric input
        }
        
        // Check the total length after the proposed change
        if let currentText = textField.text, let stringRange = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            return updatedText.count <= 1 // Allow input only if it results in 1 or fewer digits
        }
        
        return true
    }
    
    //MARK: --> VALIDATION
    func isValiadteOtp() -> Bool{
        if (oneTxtField.text == "") || (twoTxTField.text == "") || (threeTxTField.text == "") || (fourTxTField.text == "") {
            print("Please Enter Otp")
            AlertHelper.shared.showCustomeAlert(message: "Please Enter Otp", actions: ["Ok"])
            return false
        }
        return true
    }
    
    private func showIncorrectOtpUI() {
        invalidOtpLbl.isHidden = false
        isWrongOtp = true
        updateOtpUI()
    }
}


extension OtpViewController {
    
    func resendOtp(){
        if inputType != "3" {
            if RegistrationVM.isValidePhone(phoneNumStr: self.mobilNumStr) {
                RegistrationVM.resendOtpApi(inputEmail: "", inputPhoneNum: self.mobilNumStr, inputCountryCode: self.countryCodeStr, loginType: self.inputType, completion: { [weak self] getResult in
                    guard let self = self, let getResult = getResult else { return  }
                    
                    if getResult.status == true {
                        AlertHelper.shared.alertMesssage(view: self, title: "", message: (getResult.msg ?? ""))
                        self.startTimer()
                    }else{
                        AlertHelper.shared.alertMesssage(view: self, title: "", message: (getResult.errors?.values.first?.first as? String ?? ""))
                    }
                })
            }
        }else{
            RegistrationVM.resendOtpApi(inputEmail: self.mobilNumStr, inputPhoneNum: "", inputCountryCode: self.countryCodeStr, loginType: self.inputType, completion: { [weak self] getResult in
                guard let self = self, let getResult = getResult else { return  }
                
                if getResult.status == true {
                    AlertHelper.shared.alertMesssage(view: self, title: "", message: (getResult.msg ?? ""))
                    self.startTimer()
                }else{
                    AlertHelper.shared.alertMesssage(view: self, title: "", message: (getResult.errors?.values.first?.first as? String ?? ""))
                }
            })
        }
    }
    
    func submitOtp(inputOtp: String){
        if inputType != "3" {
            if RegistrationVM.isValidePhone(phoneNumStr: self.mobilNumStr) {
                RegistrationVM.submitOtpApi(inputEmail: "", inputPhoneNum: self.mobilNumStr, inputCountryCode: self.countryCodeStr, loginType: self.inputType, otpStr: inputOtp, completion: { [weak self] getResult in
                    guard let self = self, let getResult = getResult else { return  }
                    
                    if getResult.status == true {
                        if let userData = getResult.data {
                            
//                            if userData.name == nil {
//                                if let userModelData = getResult.data?.user {
//                                    appUserDefaults.saveUserToUserDefaults(userModelData)
//                                }
//                            }else{
//                                appUserDefaults.saveUserToUserDefaults(userData)
//
//                            }
                            appUserDefaults.saveUserToUserDefaults(userData)
                            appUserDefaults.setUserName(value: userData.user?.name)
                            appUserDefaults.setAccessToken(accessToken: userData.token?.value)
                        }
                        
                        if let isCompleted = getResult.data?.user?.isCompleted, isCompleted == 1 {
                            appUserDefaults.setIsPackageCreated(value: true)
                            
                            appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: appUserDefaults.getIsPackageCreated())
                            
                            //                        let vc:PersoniledViewController = PersoniledViewController.instantiate(appStoryboard: .main)
                            //                        self.navigationController?.pushViewController(vc, animated: true)
                            
                        } else{
                            if let getStep = getResult.data?.step?.intValue ,  let currentVC = vcSteps.getCurrentVC(vcRawValue: getStep) {
                                // Use the currentVC, which will be the type of the corresponding view controller
                                let getVC = currentVC.instantiate(appStoryboard: .main)
                                self.navigationController?.pushViewController(getVC, animated: true)
                            } else {
                                let vc:NameViewController = NameViewController.instantiate(appStoryboard: .main)
                                self.navigationController?.pushViewController(vc, animated: false)
                            }
                        }
                        
                    } else {
                        //(getResult.errors?.values.first?.first as? String ?? "")
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: self, title: "", message: errorMsg ?? "")
                        // Show red message
                        DispatchQueue.main.async {
                            self.showIncorrectOtpUI()
                        }
                    }
                })
            }
        }else{
//            if RegistrationVM.isValidePhone(phoneNumStr: self.mobilNumStr) {
                RegistrationVM.submitOtpApi(inputEmail: self.mobilNumStr, inputPhoneNum: "", inputCountryCode: self.countryCodeStr, loginType: self.inputType, otpStr: inputOtp, completion: { [weak self] getResult in
                    guard let self = self, let getResult = getResult else { return  }
                    
                    if getResult.status == true {
                        if let userData = getResult.data {
//                            if userData.name == nil {
//                                if let userModelData = getResult.data?.user {
//                                    appUserDefaults.saveUserToUserDefaults(userModelData)
//                                }
//                            }else{
//                                appUserDefaults.saveUserToUserDefaults(userData)
//
//                            }
                            
                            appUserDefaults.saveUserToUserDefaults(userData)
                            appUserDefaults.setUserName(value: userData.user?.name)
                            appUserDefaults.setAccessToken(accessToken: userData.token?.value)
                        }
                        
                        if let isCompleted = getResult.data?.user?.isCompleted, isCompleted == 1 {
                            appUserDefaults.setIsPackageCreated(value: true)
                            
                            appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: appUserDefaults.getIsPackageCreated())
                            
                            //                        let vc:PersoniledViewController = PersoniledViewController.instantiate(appStoryboard: .main)
                            //                        self.navigationController?.pushViewController(vc, animated: true)
                            
                        } else{
                            if let getStep = getResult.data?.step?.intValue ,  let currentVC = vcSteps.getCurrentVC(vcRawValue: getStep) {
                                // Use the currentVC, which will be the type of the corresponding view controller
                                let getVC = currentVC.instantiate(appStoryboard: .main)
                                self.navigationController?.pushViewController(getVC, animated: true)
                            }
                            else{
                                let vc:NameViewController = NameViewController.instantiate(appStoryboard: .main)
                                self.navigationController?.pushViewController(vc, animated: false)
                            }
                        }
                        
                    }else{
                        //(getResult.errors?.values.first?.first as? String ?? "")
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: self, title: "", message: errorMsg ?? "")
                    }
                })
//            }
        }

    }
    
    func setupOtpBoxes() {

        let containers = [oneContainer, twoContainer, threeContainer, fourContainer]
        let fields = [oneTxtField, twoTxTField, threeTxTField, fourTxTField]

        containers.forEach {
            $0?.layer.cornerRadius = 18
//            $0?.applyOtpGradient()
        }
//        self.oneContainer.backgroundColor =  UIColor(red: 53.0/255.0, green: 62.0/255.0, blue:  56.0/255.0, alpha: 1.0)
        fields.forEach {
            $0?.backgroundColor = .clear
            $0?.textAlignment = .center
            $0?.keyboardType = .numberPad
            $0?.textColor = .white
            $0?.tintColor = .white
        }
    }

}

extension OtpViewController: LoopingPlayerProgressDelegate{
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float) {
        print("Loading progress: \(percentage * 100)%")
    }
    
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool) {
        print(succeeded ? "Video loaded successfully!" : "Failed to load video.")
    }
}

extension UIView {

    private static let bgLayerName = "otp.bg"
    private static let glowLayerName = "otp.glow"
    private static let topBorderLayerName = "otp.top.border"

    func applyOtpStyle(_ state: OtpBoxState) {

        guard bounds.width > 0 else { return }

        // Remove only glow layer safely
        layer.sublayers?
            .filter { $0.name == Self.glowLayerName }
            .forEach { $0.removeFromSuperlayer() }

        // Background layer (reuse)
        let bgLayer: CALayer
        if let existing = layer.sublayers?.first(where: { $0.name == Self.bgLayerName }) {
            bgLayer = existing
        } else {
            let layer = CALayer()
            layer.name = Self.bgLayerName
            layer.cornerRadius = 18
            self.layer.insertSublayer(layer, at: 0)
            bgLayer = layer
        }

        bgLayer.frame = bounds

        switch state {
        //  EMPTY
        case .empty:
            bgLayer.backgroundColor = UIColor.clear.cgColor
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
            layer.shadowOpacity = 0
            layer.sublayers?
                .filter { $0.name == Self.topBorderLayerName }
                .forEach { $0.removeFromSuperlayer() }

            
        // FILLED
        case .filled:
            bgLayer.backgroundColor = UIColor.otpBg.cgColor

            layer.borderWidth = 1
            layer.borderColor = UIColor.otpGlow.withAlphaComponent(0.45).cgColor

            // ───── Smooth curved top highlight (Image-2 style) ─────
            let highlight = CAGradientLayer()
            highlight.name = Self.glowLayerName

            highlight.frame = CGRect(
                x: 0,
                y: -2,
                width: bounds.width,
                height: 4
            )

            highlight.cornerRadius = 2

            // ⭐ Center strong → sides thin
            highlight.colors = [
                UIColor.clear.cgColor,
                UIColor.otpGlow.withAlphaComponent(0.65).cgColor,
                UIColor.clear.cgColor
            ]

            highlight.locations = [0.0, 0.5, 1.0]

            // 🔥 Horizontal fade (THIS is the key)
            highlight.startPoint = CGPoint(x: 0.0, y: 0.5)
            highlight.endPoint   = CGPoint(x: 1.0, y: 0.5)

            // Mask so it stays INSIDE rounded corners
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(
                roundedRect: bounds.insetBy(dx: 2, dy: 2),
                cornerRadius: 16
            ).cgPath

            highlight.mask = mask
            layer.addSublayer(highlight)
            
        case .wrongOtp:
            bgLayer.backgroundColor = UIColor.wrongOtpBg.cgColor

            layer.borderWidth = 1
            layer.borderColor = UIColor.wrongOtpGlow.withAlphaComponent(0.45).cgColor

            let highlight = CAGradientLayer()
            highlight.name = Self.glowLayerName

            highlight.frame = CGRect(
                x: 0,
                y: -1,
                width: bounds.width,
                height: 4
            )

            highlight.cornerRadius = 2

            highlight.colors = [
                UIColor.clear.cgColor,
                UIColor.wrongOtpGlow.withAlphaComponent(0.65).cgColor,
                UIColor.clear.cgColor
            ]

            highlight.locations = [0.0, 0.5, 1.0]
            highlight.startPoint = CGPoint(x: 0.0, y: 0.5)
            highlight.endPoint   = CGPoint(x: 1.0, y: 0.5)

            let mask = CAShapeLayer()
            mask.path = UIBezierPath(
                roundedRect: bounds.insetBy(dx: 2, dy: 2),
                cornerRadius: 16
            ).cgPath

            highlight.mask = mask
            layer.addSublayer(highlight)


//        case .wrongOtp:
//            bgLayer.backgroundColor = UIColor.wrongOtpBg.cgColor
//
//            layer.borderWidth = 1
//            layer.borderColor = UIColor.wrongOtpGlow.withAlphaComponent(0.45).cgColor
//
//            // ───── Smooth curved top highlight (Image-2 style) ─────
//            let highlight = CAGradientLayer()
//            highlight.name = Self.glowLayerName
//
//            highlight.frame = CGRect(
//                x: 0,
//                y: -2,
//                width: bounds.width,
//                height: 4
//            )
//
//            highlight.cornerRadius = 2
//
//            // ⭐ Center strong → sides thin
//            highlight.colors = [
//                UIColor.clear.cgColor,
//                UIColor.wrongOtpGlow.withAlphaComponent(0.65).cgColor,
//                UIColor.clear.cgColor
//            ]
//
//            highlight.locations = [0.0, 0.5, 1.0]
//
//            // 🔥 Horizontal fade (THIS is the key)
//            highlight.startPoint = CGPoint(x: 0.0, y: 0.5)
//            highlight.endPoint   = CGPoint(x: 1.0, y: 0.5)
//
//            // Mask so it stays INSIDE rounded corners
//            let mask = CAShapeLayer()
//            mask.path = UIBezierPath(
//                roundedRect: bounds.insetBy(dx: 2, dy: 2),
//                cornerRadius: 16
//            ).cgPath
//
//            highlight.mask = mask
//            layer.addSublayer(highlight)
        }
    }
}

extension UIColor {
    static let otpBg = UIColor(hex: "#1B270C")
    static let otpGlow = UIColor(red: 224/255, green: 254/255, blue: 8/255, alpha: 1)
    static let wrongOtpBg = UIColor(hex: "#221910")
    static let wrongOtpGlow = UIColor(red: 73/255, green: 39/255, blue: 26/255, alpha: 1)
}


//extension UIView {
//
//    func applyOtpGradient(isActive: Bool = false, isError: Bool = false) {
//        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
//
//        let gradient = CAGradientLayer()
//        gradient.frame = bounds
//        gradient.cornerRadius = 18
//
//        if isError {
////            gradient.colors = [
////                UIColor(red: 0.25, green: 0, blue: 0, alpha: 1).cgColor,
////                UIColor.black.cgColor
////            ]
//            gradient.colors = [
//                UIColor.errorRed
////                UIColor(red: 0.25, green: 0, blue: 0, alpha: 1).cgColor,
////                UIColor.black.cgColor
//            ]
//        } else {
//            gradient.colors = [
//                UIColor(red: 53.0/255.0, green: 62.0/255.0, blue:  56.0/255.0, alpha: 1.0).cgColor
////                UIColor(red: 53.25, green: 0.35, blue: 0.05, alpha: 1).cgColor,
////                UIColor(red: 0.05, green: 0.08, blue: 0.02, alpha: 1).cgColor
//            ]
//        }
//
//        gradient.startPoint = CGPoint(x: 0, y: 0)
//        gradient.endPoint = CGPoint(x: 1, y: 1)
//
//        layer.insertSublayer(gradient, at: 0)
//
//        layer.borderWidth = isActive ? 1.5 : 0.5
//        layer.borderColor = isError
//            ? UIColor.red.cgColor
//            : UIColor(red: 0.6, green: 0.9, blue: 0.2, alpha: 0.5).cgColor
//
//        layer.shadowColor = isError
//            ? UIColor.red.cgColor
//            : UIColor(red: 0.6, green: 0.9, blue: 0.2, alpha: 1).cgColor
//
//        layer.shadowRadius = isActive ? 10 : 6
//        layer.shadowOpacity = isActive ? 0.6 : 0.3
//        layer.shadowOffset = .zero
//        layer.masksToBounds = false
//    }
//}
