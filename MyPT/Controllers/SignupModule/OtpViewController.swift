//
//  OtpViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/10/24.
//

import UIKit

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
//            return DemmyAgeViewController.self
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

class OtpViewController: CommonViewController, UITextFieldDelegate {
    
    //MARK: ---------VARIABLE
    var mobilNumStr:String?
    var countryCodeStr:String?
    var inputType:String?

    lazy var timer: Timer? = nil
    
    lazy var timeCouter : Int? = nil {
        didSet{
            if let timeCouter = timeCouter {
                receiveOtpLbl.text = nil
                if timeCouter < 30 {
                    resentOtpLbl.text = "\(timeCouter) seconds"
                }else{
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let countryCodeStr = countryCodeStr, let mobilNumStr = mobilNumStr {
            mobilNumeLbl.text = countryCodeStr + mobilNumStr
        }
        
        receiveOtpLbl.text = nil
        resentOtpLbl.text  = nil
        self.startTimer()
        
        oneTxtField.delegate = self
        twoTxTField.delegate = self
        threeTxTField.delegate = self
        fourTxTField.delegate = self
        
        setupUI()
        setUpFont()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [AppImages.help], setTitle: [AppStrings.helpStr], setTintColor: .black, setTitleColor: UIColor.appWhite,isRightImg: [false])
    }
    
    //MARK: ---------------EDIT MOBILE NUMBER ACTN
    @IBAction func editMobileBtnActn(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK: --------------------Timer
    func startTimer() {
        self.stopTimer()
        self.timeCouter = 1
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getTime), userInfo: nil, repeats: true)
    }
    
    @objc func getTime() {
        if let timeCouter = self.timeCouter {
            self.timeCouter! += 1
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
        self.topTitleLbl.font = AppFont.bold.size(24.0, familyName: familyManrope)
        self.topDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.mobilNumeLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.oneTxtField.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.twoTxTField.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.threeTxTField.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.fourTxTField.font = AppFont.bold.size(14.0, familyName: familyManrope)
        
        self.receiveOtpLbl.font = AppFont.regular.size(12.0, familyName: familyManrope)
        self.resentOtpLbl.font = AppFont.bold.size(12.0, familyName: familyManrope)
        self.resentOtpLbl.textColor = UIColor.appWhite
        
        
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
    
    func setupUI(){
        
        oneTxtField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        twoTxTField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        threeTxTField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        fourTxTField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        
        let text = textField.text
        
        if (text?.utf16.count)! >= 1{
            switch textField{
            case oneTxtField:
                twoTxTField.becomeFirstResponder()
            case twoTxTField:
                threeTxTField.becomeFirstResponder()
            case threeTxTField:
                fourTxTField.becomeFirstResponder()
            case fourTxTField:
                fourTxTField.resignFirstResponder()
                
                if let  txt =  fourTxTField.text , !txt.isEmpty {
                    self.view.endEditing(true)
                    if  self.isValiadteOtp() {
                        if let otp1 = self.oneTxtField.text, let otp2 = self.twoTxTField.text, let otp3 = self.threeTxTField.text, let otp4 = self.fourTxTField.text {
                            let otpStr = otp1 + otp2 + otp3 + otp4
                            self.submitOtp(inputOtp: otpStr)
                        }
                        
                        
                        //                        let vc:NameViewController = NameViewController.instantiate(appStoryboard: .main)
                        //                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }
                
            default:
                break
            }
        }else{
            switch textField{
            case oneTxtField:
                oneTxtField.becomeFirstResponder()
            case twoTxTField:
                oneTxtField.becomeFirstResponder()
            case threeTxTField:
                twoTxTField.becomeFirstResponder()
            case fourTxTField:
                threeTxTField.becomeFirstResponder()
            default:
                break
            }
        }
        
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
    
}


extension OtpViewController {
    
    func resendOtp(){
        if RegistrationVM.isValidePhone(phoneNumStr: self.mobilNumStr) {
            RegistrationVM.resendOtpApi(inputPhoneNum: self.mobilNumStr, inputCountryCode: self.countryCodeStr, completion: { [weak self] getResult in
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
        if RegistrationVM.isValidePhone(phoneNumStr: self.mobilNumStr) {
            RegistrationVM.submitOtpApi(inputPhoneNum: self.mobilNumStr, inputCountryCode: self.countryCodeStr, loginType: self.inputType, otpStr: inputOtp, completion: { [weak self] getResult in
                guard let self = self, let getResult = getResult else { return  }
                
                if getResult.status == true {
                    if let userData = getResult.data {
                        appUserDefaults.saveUserToUserDefaults(userData)
                        appUserDefaults.setAccessToken(accessToken: userData.token?.value)
                    }
                    
                    if let isCompleted = getResult.data?.user?.isCompleted, isCompleted == 1 {
                        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: true)
                        
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
        }
    }
    
    
    
}
