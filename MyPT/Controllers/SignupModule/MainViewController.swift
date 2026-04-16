//
//  ViewController.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import UIKit
import AVKit
import AVFoundation
import FacebookLogin
import CountryPickerView
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

class MainViewController: CommonViewController,UITextFieldDelegate {
    
    //MARK: ----------VARIABLE
    var player: LoopingPlayer?
    var countryCodeStr:String?
    var inputType:String?
    
    let countryPickerView = CountryPickerView()
    var selectedCountry: Country?
    
    private let mobileMaxLengthByCountryCode: [String: Int] = [
        "IN": 10,  // India
        "US": 10,  // United States
        "AE": 9,   // United Arab Emirates
        "GB": 10,  // United Kingdom
        "PK": 10,  // Pakistan
        "BD": 11,  // Bangladesh
        "NG": 11,  // Nigeria
        "DE": 11,  // Germany
        "FR": 9,   // France
        "AU": 9    // Australia
    ]
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var subTitileLbl: UILabel!
    @IBOutlet weak var mobileNumTxt: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var gloginBtn: UIButton!
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var appleLoginBtn: UIButton!
    @IBOutlet weak var countryCodeBtn: UIButton!
    @IBOutlet weak var orBtn: UIButton!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var constBottomSocialButtons: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        
        self.mobileNumTxt.isHidden = false
        self.emailTxtField.isHidden = true
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
        
        //        self.continueBtn.isUserInteractionEnabled = false
        mobileNumTxt.delegate = self
        setUpFont()
        setupUI()
        setUpVideo()
        
        // Set country to UAE using its country code "AE"
        if let _ = countryPickerView.getCountryByCode("AE") {
            countryPickerView.setCountryByCode("AE")
        }
        continueBtn.adjustsImageWhenDisabled = false
        continueBtn.adjustsImageWhenHighlighted = false
    }
    
    deinit {
        player?.progressDelegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        self.mobileNumTxt.isHidden = false
        self.emailTxtField.isHidden = true
        
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
        super.viewDidAppear(animated)
        self.checkStep()
        UIVisualEffectView.disableAllBlur(in: view)
        IQKeyboardManager.shared.isEnabled = false
        IQKeyboardToolbarManager.shared.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
    }
    
    @objc override func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = frame.height - view.safeAreaInsets.bottom
        
        // Adaptive keyboard padding (SE vs big phones)
        let padding: CGFloat = view.bounds.height < 700 ? -50 : 20
        constBottomSocialButtons.constant = keyboardHeight + padding
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc override func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        constBottomSocialButtons.constant = 35
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.appLogo], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
//        self.setRighMenu(rightImgs: [AppImages.arrow_right], setTitle: [AppStrings.skip_to_home.uppercased()], setTintColor: .black, setTitleColor: UIColor.appWhite,isRightImg: [true])
    }
    
    override func rightBtnActn(sender: UIButton) {
        print(appUserDefaults.getIsPackageCreated())
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
    }
    
    //------------------************Font
    func setUpFont() {
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.subTitileLbl.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        self.mobileNumTxt.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        self.emailTxtField.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.countryCodeBtn.titleLabel?.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
        self.orBtn.titleLabel?.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
    }
    
    //MARK: ---------- SET UI
    func setupUI() {
        //        self.countryCodeStr = isTesting ? "+91" : "+971" //for country code
        
        DispatchQueue.main.async {
            //            self.mobileNumTxt.setLeftPaddingWithImage(95.0, self.mobileNumTxt.font?.lineHeight.magnitude ?? 1.0, UIImage(named: "ic_countyCode"), self.countryCodeStr ?? "+971")
            self.viewBackground.addGradient(colors: UIColor.appMultiColor(.blackBgGradient), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0)
            //            self..backgroundColor
            self.mobileNumTxt.placeholderSet(placeHolder: "XXX-XXX-XXXX", color: UIColor.txtDarkGray)
            
            self.emailTxtField.setLeftPaddingWithImage(35, 0, UIImage(named: "ic_email"), "")
            self.emailTxtField.placeholderSet(placeHolder: "Enter you email id", color: UIColor.txtDarkGray)
            
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            //            [
            //                self.gloginBtn,
            //                self.fbLoginBtn,
            //                self.appleLoginBtn
            //            ].forEach({[weak self] in
            //                guard self != nil else {
            //                    return
            //                }
            //                $0?.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.white, cornerRadious: ($0?.frame.size.height ?? 15)/2.0)
            //            })
        }
    }
    
    func setUpVideo(){
        //MyPTGems.mp4
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
            
            // from url
            //                if let videoURL = URL(string: "path") {
            //                    player = LoopingPlayer(url: videoURL)
            //                    player?.progressDelegate = self
            //                    player?.play()
            //                }
            print("Video file not found")
        }
        
    }
    
    //MARK: ----------CONTINUE BTN ACTN
    @IBAction func continueBtnActn(_ sender: Any) {
        
        if let mobileStr = mobileNumTxt.text , !mobileStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let phoneNumber = mobileStr.replacingOccurrences(of: "-", with: "")
            
            if RegistrationVM.isValidePhone(phoneNumStr: phoneNumber) {
                
                self.view.endEditing(true)
                self.inputType = "1"
                
                RegistrationVM.loginApi(inputEmail: "", inputPhoneNum: phoneNumber, inputCountryCode: self.countryCodeStr, loginType: self.inputType, completion: { [weak self] getResult in
                    guard let self = self, let getResult = getResult else { return  }
                    
                    if getResult.status == true {
                        let vc:OtpViewController = OtpViewController.instantiate(appStoryboard: .main)
                        vc.mobilNumStr = phoneNumber
                        vc.countryCodeStr = self.countryCodeStr
                        vc.inputType = self.inputType
                        self.navigationController?.pushViewController(vc, animated: false)
                    }else{
                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        AlertHelper.shared.alertMesssage(view: self, title: "", message: errorMsg ?? "")
                    }
                })
            }
        }else if let email = emailTxtField.text{
            
            self.view.endEditing(true)
            self.inputType = "3"
            self.countryCodeStr = ""
            
            RegistrationVM.loginApi(inputEmail: email,inputPhoneNum: "", inputCountryCode: self.countryCodeStr, loginType: self.inputType, completion: { [weak self] getResult in
                guard let self = self, let getResult = getResult else { return  }
                
                if getResult.status == true {
                    let vc:OtpViewController = OtpViewController.instantiate(appStoryboard: .main)
                    vc.mobilNumStr = email
                    vc.countryCodeStr = self.countryCodeStr
                    vc.inputType = self.inputType
                    self.navigationController?.pushViewController(vc, animated: false)
                }else{
                    let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                    AlertHelper.shared.alertMesssage(view: self, title: "", message: errorMsg ?? "")
                }
            })
        }
    }
    
    //MARK: ----------- SOCIAL MEDIA
    enum socialBtnTag:Int {
        case googleLogin = 101 ,fbLogin,appleLoggin, selectCountryCode
    }
    
    @IBAction func socialLoginBtnActn(_ sender: UIButton){
        
        switch sender.tag {
        case socialBtnTag.googleLogin.rawValue:
            print("Google clicked at btn")
            
            GLoginManager.shared.gLogin(viewController: self,completion: { [weak self] userInfo, userProfile in
                guard self != nil else { return }
                print("userInfo= ",userInfo as Any,"userProfile= ",userProfile as Any)
                //                appUserDefaults.setUserID(value: userInfo?["uid"] as? String)
                //                appUserDefaults.setUserName(value: (userInfo?["email"] as? String))
                
                appUserDefaults.setSocialId(value: userInfo?["uid"] as? String)
                appUserDefaults.setUserName(value: (userInfo?["fullName"] as? String))
                
                //1 for phone , 2 for social media, if type is 3 then email is require
                let params:[String:Any] = [
                    "unique_id": userInfo?["uid"] as? String ?? "",
                    "phone": (userInfo?["phoneNumber"] as? String) ?? "" ,
                    "email": (userInfo?["email"] as? String) ?? "",
                    "type": "2",
                    "name": (userProfile?["fullName"] as? String) ?? "",
                    "device_type": "ios",
                    "device_token": "48r748fjdfbdjdcn"
                ]
                
                RegistrationVM.socialLoginApi(inputParams: params, completion: {[weak self] getResult in
                    
                    guard let self = self, let getResult = getResult else { return  }
                    
                    if getResult.status == true {
                        if let userData = getResult.data {
                            appUserDefaults.saveUserToUserDefaults(userData)
                            appUserDefaults.setUserName(value: userData.user?.name)
                            appUserDefaults.setAccessToken(accessToken: userData.token?.value)
                        }
                        
                        if let isCompleted = getResult.data?.user?.isCompleted, isCompleted == 1 {
                            appUserDefaults.setIsPackageCreated(value: true)
                            appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: appUserDefaults.getIsPackageCreated())
                            
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
                    }
                })
            })
            
        case socialBtnTag.fbLogin.rawValue:
            print("fbLogin clicked at btn")
            self.fbLogin()
            
        case socialBtnTag.appleLoggin.rawValue:
            print("appleLoggin clicked at btn")
            AppleAuthManager.shared.handleAppleIdRequest()
            AppleAuthManager.shared.sendData = { [weak self] dataGet in
                guard self != nil else {
                    return
                }
                print(dataGet)
                appUserDefaults.setSocialId(value: dataGet.userIdentifier)
                appUserDefaults.setUserName(value: dataGet.fullName)
                
                //1 for phone , 2 for social media, if type is 3 then email is require
                let params:[String:Any] = [
                    "unique_id": dataGet.userIdentifier ?? "",
                    "phone": "" ,
                    "email": dataGet.email ?? "",
                    "type": "2",
                    "name": dataGet.fullName ?? "",
                    "device_type": "ios",
                    "device_token": "48r748fjdfbdjdcn"
                ]
                
                RegistrationVM.socialLoginApi(inputParams: params, completion: {[weak self] getResult in
                    
                    guard let self = self, let getResult = getResult else { return  }
                    
                    if getResult.status == true {
                        if let userData = getResult.data {
                            appUserDefaults.saveUserToUserDefaults(userData)
                            appUserDefaults.setUserName(value: userData.user?.name)
                            appUserDefaults.setAccessToken(accessToken: userData.token?.value)
                        }
                        
                        if let isCompleted = getResult.data?.user?.isCompleted, isCompleted == 1 {
                            appUserDefaults.setIsPackageCreated(value: true)
                            appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: appUserDefaults.getIsPackageCreated())
                            
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
                    }
                })
            }
            
        case socialBtnTag.selectCountryCode.rawValue:
            print("Select country code....")
            // Present the picker
            countryPickerView.showCountriesList(from: self)
            
        default:
            print("Default...")
        }
    }
    
    
    // UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == mobileNumTxt {
            // Allow only numeric input
            let allowedCharacterSet = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            if !allowedCharacterSet.isSuperset(of: characterSet) {
                return false // Disallow non-numeric input
            }
            //restrict the input to 10 digits
            //        let countNum:Int = self.countryCodeStr == "+971" ? 11 : 12
            
            let countNum:Int = (mobileMaxLengthByCountryCode[selectedCountry?.code ?? "AE"] ?? 10) + 2
            
            // Check the total length after the proposed change
            if let currentText = textField.text, let stringRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
                if updatedText.count >= countNum {
                    self.updateContinueButton(isEnabled: true)
                    //                    self.enableContinueBtn(isSelected: true)
                }else{
                    self.updateContinueButton(isEnabled: false)
                    //                    self.enableContinueBtn(isSelected: false)
                }
                
                if let textFieldMobile = self.mobileNumTxt.text, string != "" {
                    if textFieldMobile.count == 3 || textFieldMobile.count == 7 {
                        self.mobileNumTxt.text = textFieldMobile.text + "-"
                    }
                }
                
                return updatedText.count <= countNum // 11= for 9 digits, 12 for 10 digits Allow input only if it results in 10 or fewer digits
            }
        }
        else if textField == emailTxtField{
            print(textField.text ?? "")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let validSmail = textField.text?.isValidEmail(), validSmail {
                    self.updateContinueButton(isEnabled: true)
                    //                    self.enableContinueBtn(isSelected: true)
                }else{
                    self.updateContinueButton(isEnabled: false)
                    //                    self.enableContinueBtn(isSelected: false)
                }
            }
        }
        
        return true
    }
    
    //MARK: -------------- ENABLE CONTINUE
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
    
//    func setupContinueButtonIcon(isEnabled: Bool) {
//        let arrowImage = UIImage(named: isEnabled ? "blackRightArrow" : "whiteRightArrow")?
//            .withRenderingMode(.alwaysOriginal)
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
    
    func setupContinueButtonIcon(isEnabled: Bool) {

        if isEnabled {
            // 🟢 ENABLED → IMAGE ONLY
            let image = UIImage(named: "btnLetsGetStart")?
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
            continueBtn.setTitle("LET’S GET STARTED", for: .normal)
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
  



    
    
    //    func enableContinueBtn(isSelected:Bool = false){
    //        if isSelected {
    //            self.continueBtn.isUserInteractionEnabled = true
    //            self.continueBtn.backgroundColor = UIColor.appWhite
    //            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
    //        } else {
    //            self.continueBtn.isUserInteractionEnabled = false
    //            self.continueBtn.backgroundColor = UIColor.appDarkGray
    //            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
    //        }
    //    }
    
    //MARK: -------------------FACEBOOK LOGIN
    private func fbLogin(){
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if let error = error {
                print("Login failed:", error.localizedDescription)
                return
            }
            
            guard let result = result, !result.isCancelled else {
                print(" Login cancelled.")
                return
            }
            // Successfully logged in
            self.fetchFacebookUserData()
        }
    }
    
    func fetchFacebookUserData() {
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { _, result, error in
            if let error = error {
                print("Failed to fetch user data:", error.localizedDescription)
            } else if let userData = result as? [String: Any] {
                print("User Data:", userData)
                
                // Extract and save to UserDefaults
                let userID = userData["id"] as? String
                let name = userData["name"] as? String
                let email = userData["email"] as? String
                print("name",name ?? "")
                print("email",email ?? "")
                print("Saved name: \(name ?? ""), email: \(email ?? "") to UserDefaults")
                
                appUserDefaults.setSocialId(value: userID)
                appUserDefaults.setUserName(value: name)
                
                //1 for phone , 2 for social media, if type is 3 then email is require
                let params:[String:Any] = [
                    "unique_id": userID ?? "",
                    "phone": "" ,
                    "email": email ?? "",
                    "type": "2",
                    "name": name ?? "",
                    "device_type": "ios",
                    "device_token": "48r748fjdfbdjdcn"
                ]
                
                RegistrationVM.socialLoginApi(inputParams: params, completion: {[weak self] getResult in
                    
                    guard let self = self, let getResult = getResult else { return  }
                    
                    if getResult.status == true {
                        if let userData = getResult.data {
                            appUserDefaults.saveUserToUserDefaults(userData)
                            appUserDefaults.setUserName(value: userData.user?.name)
                            appUserDefaults.setAccessToken(accessToken: userData.token?.value)
                        }
                        
                        if let isCompleted = getResult.data?.user?.isCompleted, isCompleted == 1 {
                            appUserDefaults.setIsPackageCreated(value: true)
                            appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: appUserDefaults.getIsPackageCreated())
                            
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
                    }
                })
            }
        }
    }
    
}

//MARK: -------------------EXTENSION FOR API
extension MainViewController {
    //MARK: -------------------CHECK COMPLETED STEPS API
    func checkStep(){
        RegistrationVM.checkStep(viewController: self, params: nil, isShowLoader: false, completion: { [weak self] getResult in
            guard let self = self, let getResult = getResult else { return  }
            let  getData = getResult["data"] as? [String:Any]
            
            if let userData = getData?["user"] as? [String:Any] {
                do {
                    // Convert dictionary to JSON data
                    let jsonData = try JSONSerialization.data(withJSONObject: userData, options: [])
                    // Decode JSON data into model
                    let user = try JSONDecoder().decode(SubmitDataModel.self, from: jsonData)
                    appUserDefaults.saveUserToUserDefaults(user)
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                }
                
            }
            
            if let getIncompleteStep = getData?["incompletestep"] as? Int, let currentVC = vcSteps.getCurrentVC(vcRawValue: getIncompleteStep) {
                // Use the currentVC, which will be the type of the corresponding view controller
                let getVC = currentVC.instantiate(appStoryboard: .main)
                self.navigationController?.pushViewController(getVC, animated: true)
            }
            
        })
    }
}

extension MainViewController: CountryPickerViewDelegate, CountryPickerViewDataSource{
    
    //    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country] {
    //        let india = countryPickerView.getCountryByCode("IN")!
    //        let uae = countryPickerView.getCountryByCode("AE")!
    //        return [india, uae]
    //    }
    //
    //    func showOnlyPreferredCountries(in countryPickerView: CountryPickerView) -> Bool {
    //        return true
    //    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        //"\(country.flag) \(country.name) \(country.phoneCode)"
        self.mobileNumTxt.text = nil
        countryCodeStr = "\(country.phoneCode)"
        self.selectedCountry = country
        self.countryCodeBtn.setImage(country.flag.resized(to: CGSize(width: 33, height: 22)), for: .normal)
        self.countryCodeBtn.setTitle("  \(country.phoneCode)", for: .normal)
    }
}

extension MainViewController:LoopingPlayerProgressDelegate {
    //MARK: -------------- VIDEO PLAYER DELEAGTE
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float) {
        print("Loading progress: \(percentage * 100)%")
    }
    
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool) {
        print(succeeded ? "Video loaded successfully!" : "Failed to load video.")
    }
}
