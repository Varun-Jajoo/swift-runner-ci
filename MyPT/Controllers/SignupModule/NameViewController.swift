//
//  NameViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit

class NameViewController: CommonViewController, UITextFieldDelegate {
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var mgImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var nameTxtMBV: UIView!
    @IBOutlet weak var fullNameTitleLbl: UILabel!
    @IBOutlet weak var fullNameTxtField: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.hideNavigationBar()
        fullNameTitleLbl.text = nil
        fullNameTxtField.delegate = self
        self.continueBtn.isUserInteractionEnabled = false
        setUpFont()
        
        //-----------------
//        if let retrievedUser = appUserDefaults.getUserFromUserDefaults(){
//            print("User ID: \(retrievedUser.step ?? 0), Phone: \(retrievedUser.user?.phone ?? "")")
//        } else {
//            print("No user found in UserDefaults")
//        }
        
        if let retrievedUser = appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self){
            print("User ID: \(retrievedUser.step?.value ?? ""), Phone: \(retrievedUser.user?.phone ?? "")")
        } else {
            print("No user found in UserDefaults")
        }
        
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        print("keyboardWillShow")
        self.addBlurWithVibrancyEffect(viewShow: self.mgImgView, alphBlur: 1.0, vibrancyAlphBlur: 0.4)
    }
        
    override func keyboardWillHide(_ notification: Notification) {
        super.keyboardWillHide(notification)
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
    func setUpFont(){
        self.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.descLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.fullNameTitleLbl.font = AppFont.medium.size(10.0, familyName: familyManrope)
        self.fullNameTxtField.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.fullNameTxtField.setPlaceholder(text: "Full name", font: AppFont.semibold.size(14.0, familyName: familyManrope), color: UIColor.txtDarkGray)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        
        self.fullNameTxtField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        DispatchQueue.main.async {
            
            //            self.fullNameTxtField.setLeftRightPadding(16)
            self.nameTxtMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("Continiue btn clicked..")
        self.view.endEditing(true)
        self.enableContinueBtn(isSelected: false)
    
        
        //"\(appUserDefaults.getUserFromUserDefaults()?.user?.id ?? 0)"
        RegistrationVM.addNameApi(viewController: self, inputName: self.fullNameTxtField.text, inputId: "\(appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self)?.user?.id ?? 0)", completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            if getResultData.status == true {
                if let detailsData = getResultData.data {
                    appUserDefaults.saveUserToUserDefaults(detailsData)
                }
               
                let vc:PersoniledViewController = PersoniledViewController.instantiate(appStoryboard: .main)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            self.enableContinueBtn(isSelected: true)
        })
        
        
        //        let vc:PersoniledViewController = PersoniledViewController.instantiate(appStoryboard: .main)
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    
    @objc func textFieldDidChange(textField: UITextField){
        if  fullNameTxtField == textField {
            if let isEmptyTxt = textField.text?.isEmpty, !isEmptyTxt{
                self.fullNameTitleLbl.isHidden = false
                self.fullNameTitleLbl.text = "Full name"
                self.enableContinueBtn(isSelected: true)
            }else{
                self.enableContinueBtn(isSelected: false)
                self.fullNameTitleLbl.isHidden = true
                self.fullNameTitleLbl.text = nil
            }
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
