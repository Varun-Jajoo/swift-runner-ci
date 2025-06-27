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

class MainViewController: CommonViewController,UITextFieldDelegate {
    
    //MARK: ----------VARIABLE
    var player: LoopingPlayer?
    var countryCodeStr:String?
    var inputType:String?
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var subTitileLbl: UILabel!
    @IBOutlet weak var mobileNumTxt: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var gloginBtn: UIButton!
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var appleLoginBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mobileNumTxt.isHidden = false
        self.emailTxtField.isHidden = true
        
        self.continueBtn.isUserInteractionEnabled = false
        mobileNumTxt.delegate = self
        setUpFont()
                
        //        for family in UIFont.familyNames {
        //            print("Font family: \(family)")
        //            for name in UIFont.fontNames(forFamilyName: family) {
        //                print("Font name: \(name)")
        //            }
        //        }
        setupUI()
        setUpVideo()
//        loadVideo()
        
//        //------------------only for testin for age ui
//        let currentVC = vcSteps.getCurrentVC(vcRawValue: 3)
//        if let getVC = currentVC?.instantiate(appStoryboard: .main){
//            self.navigationController?.pushViewController(getVC, animated: true)
//        }
       
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkStep()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.navLeft], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [AppImages.arrow_right], setTitle: [AppStrings.skip_to_home.uppercased()], setTintColor: .black, setTitleColor: UIColor.appWhite,isRightImg: [true])
    }
    
    override func rightBtnActn(sender: UIButton) {
        print(appUserDefaults.getIsPackageCreated())
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
    }
    
    //------------------************Font
    func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.subTitileLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.mobileNumTxt.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.emailTxtField.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        self.countryCodeStr = isTesting ? "+91" : "+971" //for country code
        
        DispatchQueue.main.async {
            self.mobileNumTxt.setLeftPaddingWithImage(95.0, self.mobileNumTxt.font?.lineHeight.magnitude ?? 1.0, UIImage(named: "ic_countyCode"), self.countryCodeStr ?? "+971")
            self.mobileNumTxt.placeholderSet(placeHolder: "XXX-XXX-XXX", color: UIColor.txtDarkGray)
            
            self.emailTxtField.setLeftPaddingWithImage(35, 0, UIImage(named: "ic_email"), "")
            self.emailTxtField.placeholderSet(placeHolder: "Enter you email id", color: UIColor.txtDarkGray)
            
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            [
                self.gloginBtn,
                self.fbLoginBtn,
                self.appleLoginBtn
            ].forEach({[weak self] in
                guard self != nil else {
                    return
                }
                $0?.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: ($0?.frame.size.height ?? 15)/2.0)
            })
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
    
//    private func loadVideo() {
//        
//        //this line is important to prevent background music stop
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
//        } catch { }
//        
//        let path = Bundle.main.path(forResource: "landdingVideo", ofType:"mp4")
//        
//        player = AVPlayer(url: NSURL(fileURLWithPath: path!) as URL)
//        let playerLayer = AVPlayerLayer(player: player)
//        
//        playerLayer.frame = self.view.frame
//        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        playerLayer.zPosition = -1
//        
//        self.view.layer.addSublayer(playerLayer)
//        
//        player?.seek(to: CMTime.zero)
//        player?.play()
//        
//        //-----------------*********
//        
//        //        let player = AVPlayer(url: URL(fileURLWithPath: path!) as URL)
//        //        let playerController = AVPlayerViewController()
//        //        playerController.modalPresentationStyle = .overFullScreen
//        //        playerController.player = player
//        //        playerController.videoGravity = .resizeAspectFill
//        ////        playerController.showsPlaybackControls = false
//        //
//        //        present(playerController, animated: false) {
//        //            player.play()
//        //        }
//        //        self.view.addSubview(playerController.view)
//        
//    }
    
    
    
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
        
        
        /*
        let vc:OtpViewController = OtpViewController.instantiate(appStoryboard: .main)
        vc.mobilNumStr = "+971" + " " + (mobileNumTxt.text ?? "XXXXXXXXXX")
        self.navigationController?.pushViewController(vc, animated: false)
        */
    }
    
    //MARK: ----------- SOCIAL MEDIA
    enum socialBtnTag:Int {
        case googleLogin = 101 ,fbLogin,appleLoggin
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
        let countNum:Int = self.countryCodeStr == "+971" ? 11 : 12
        
            // Check the total length after the proposed change
            if let currentText = textField.text, let stringRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
                if updatedText.count >= countNum {
                    self.enableContinueBtn(isSelected: true)
                }else{
                    self.enableContinueBtn(isSelected: false)
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
                    self.enableContinueBtn(isSelected: true)
                }else{
                    self.enableContinueBtn(isSelected: false)
                }
            }
        }
        
        return true
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

extension MainViewController:LoopingPlayerProgressDelegate {
    //MARK: -------------- VIDEO PLAYER DELEAGTE
    func loopingPlayer(loopingPlayer: LoopingPlayer, didLoad percentage: Float) {
        print("Loading progress: \(percentage * 100)%")
    }
    
    func loopingPlayer(loopingPlayer: LoopingPlayer, didFinishLoading succeeded: Bool) {
        print(succeeded ? "Video loaded successfully!" : "Failed to load video.")
    }
}
