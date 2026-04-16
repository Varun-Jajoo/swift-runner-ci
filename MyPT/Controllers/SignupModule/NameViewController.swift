//
//  NameViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

class NameViewController: CommonViewController, UITextFieldDelegate {
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var mgImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var nameTxtMBV: UIView!
    @IBOutlet weak var fullNameTitleLbl: UILabel!
    @IBOutlet weak var fullNameTxtField: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLblTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLblTopConstraint.constant = view.bounds.height < 700 ? 300 : view.bounds.height < 900 ? 400 : 500
        setupUI()
        fullNameTitleLbl.text = nil
        fullNameTxtField.delegate = self
        self.continueBtn.isUserInteractionEnabled = false
        setUpFont()
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
        continueBtn.adjustsImageWhenDisabled = false
        continueBtn.adjustsImageWhenHighlighted = false
        
        //        self.setupNavigationBarProgress(
        //            progressBarWidth: 20,
        //            settrackTintColor: UIColor(
        //                red: 178/255,
        //                green: 202/255,
        //                blue: 1/255,
        //                alpha: 1
        //            )
        //        )
        //        self.setProgress(0.2)
        
        if let retrievedUser = appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self){
            print("User ID: \(retrievedUser.step?.value ?? ""), Phone: \(retrievedUser.user?.phone ?? "")")
        } else {
            print("No user found in UserDefaults")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.setNavigationColor(setColor: .clear)
            self.statusBarColor(setColor: .clear)
            setNavUI()
            IQKeyboardManager.shared.isEnabled = false
            IQKeyboardToolbarManager.shared.isEnabled = false
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            IQKeyboardManager.shared.isEnabled = true
            IQKeyboardToolbarManager.shared.isEnabled = true
            
        }
    
    func setNavUI(){
        self.setupNavigationBarProgress(
            progressBarWidth: self.view.frame.size.width*0.37,
            settrackTintColor: UIColor(
                red: 178/255,
                green: 202/255,
                blue: 1/255,
                alpha: 1
            )
        )
        //        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37, settrackTintColor: UIColor(red: 178, green: 202, blue: 1, alpha: 1))
        self.setProgress(0.2)
        
        self.setLeftMenu(setTitle: [""], setTintColor: .clear, setTitleColor: .clear)
        //        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite) skipe remove need of client
    }
    
    override func keyboardWillShow(_ notification: Notification) {
            super.keyboardWillShow(notification)
            print("keyboardWillShow")
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            
            let keyboardHeight = frame.height - view.safeAreaInsets.bottom
            let padding : CGFloat = view.bounds.height < 700 ? 180 : 220
            titleLblTopConstraint.constant = 30
            continueButtonBottomConstraint.constant = keyboardHeight + 30
            
            self.addBlurWithVibrancyEffect(viewShow: self.mgImgView, alphBlur: 1.0, vibrancyAlphBlur: 0.4)
        }
    
    override func keyboardWillHide(_ notification: Notification) {
            super.keyboardWillHide(notification)
            continueButtonBottomConstraint.constant = 14
            titleLblTopConstraint.constant = view.bounds.height < 700 ? 300 : view.bounds.height < 900 ? 400 : 500
            self.customBlurViewRemove(viewShow: self.mgImgView)
        }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    //------------------************Font
    func setUpFont() {
        self.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        self.descLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.fullNameTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.fullNameTxtField.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.fullNameTxtField.setPlaceholder(text: "Full name", font: AppFont.semibold.size(14.0, familyName: familyManrope), color: UIColor.txtDarkGray)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
    //MARK: ---------- SET UI
    func setupUI() {
        
        self.fullNameTxtField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        DispatchQueue.main.async {
            
            //            self.fullNameTxtField.setLeftRightPadding(16)
            self.nameTxtMBV.setCornerRadius(borderWidth: 0.5,
                                            borderColor: UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.1),
                                            cornerRadious: 12.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
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
        print("Continiue btn clicked..")
        self.view.endEditing(true)
        self.updateContinueButton(isEnabled: false)
        
        
        //"\(appUserDefaults.getUserFromUserDefaults()?.user?.id ?? 0)"
        RegistrationVM.addNameApi(viewController: self, inputName: self.fullNameTxtField.text, inputId: "\(appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self)?.user?.id ?? 0)", completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            if getResultData.status == true {
                if let detailsData = getResultData.data {
                    appUserDefaults.saveUserToUserDefaults(detailsData)
                }
                
                let vc: GenderViewController = GenderViewController.instantiate(appStoryboard: .main)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            self.updateContinueButton(isEnabled: true)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        if  fullNameTxtField == textField {
            if let isEmptyTxt = textField.text?.isEmpty, !isEmptyTxt {
                self.fullNameTitleLbl.isHidden = false
                self.fullNameTitleLbl.text = "Full name"
                self.updateContinueButton(isEnabled: true)
            } else {
                self.updateContinueButton(isEnabled: false)
                self.fullNameTitleLbl.isHidden = true
                self.fullNameTitleLbl.text = nil
            }
        }
    }
}
