//
//  DailyGoalsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/02/25.
//

import UIKit

protocol SendDailGoals {
    func sendBackDailyGoalsData(inputData:String?)
}

class DailyGoalsPopupViewController: UIViewController, UITextFieldDelegate {

    //MARK: ------------VARIABLE
    var sendDailyGoals:((String?) -> Void)?
    var delegate:SendDailGoals?
    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var popupMBV: UIView!
    @IBOutlet weak var recommendedMBV: UIView!
    @IBOutlet weak var customMBV: UIView!
    @IBOutlet weak var recommendQntyTxtFMBV: UIView!
    @IBOutlet weak var customQntyTxtFMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var recommendTitleLbl: UILabel!
    @IBOutlet weak var customTitleLbl: UILabel!
    @IBOutlet weak var recommendTxtField: UITextField!
    @IBOutlet weak var customQntyTxtField: UITextField!
    @IBOutlet weak var topBarBtn: UIButton!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var check1Btn: UIButton!
    @IBOutlet weak var check2Btn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.check1Btn.isSelected = true
        self.setupFont()
        
        self.customQntyTxtField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    
    //MARK: -------------BTNTAG
    enum Btntag: Int{
        case topBar = 501, dismiss, recommendCheck, customCheck, cancel, save
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        print(sender.tag)
        
        switch sender.tag {
        case Btntag.topBar.rawValue:
            print("top btn clciked")
        case Btntag.dismiss.rawValue:
            self.dismiss(animated: true)
        case Btntag.recommendCheck.rawValue:
            
            self.check1Btn.isSelected = true
            self.check2Btn.isSelected = false
            recommendTxtField.resignFirstResponder()
            customQntyTxtField.resignFirstResponder()
         
            let originalString = recommendTxtField.text ?? ""
            let cleanedString = originalString.replacingOccurrences(of: "ml", with: "").trimmingCharacters(in: .whitespaces)
            
            self.sendDailyGoals?(cleanedString)
            
        case Btntag.customCheck.rawValue:
            
            self.check1Btn.isSelected = false
            self.check2Btn.isSelected = true
            customQntyTxtField.becomeFirstResponder()
                        
        case Btntag.cancel.rawValue:
            print("Cancel btn clicked.")
            self.dismiss(animated: true)
        case Btntag.save.rawValue:
            print("save btn clicked")
            self.dismiss(animated: true)
        default:
            print("None......")
        }
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.popupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.popupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
//            self.popupMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cancelBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
//            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.customQntyTxtFMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 6.0)
            
            [self.recommendedMBV,self.customMBV,self.saveBtn].forEach({
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
            
            //-------------********Gredient
            self.recommendedMBV.addGradient(colors: UIColor.appMultiColor(.lightGreen), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1.0, y: 1.0), cornerRadius: 12.0)
        }
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.bold.size(44.0, familyName: familyManrope)
        self.recommendTitleLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
        self.customTitleLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
        self.recommendTxtField.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.customQntyTxtField.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.cancelBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.saveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.customQntyTxtField == textField {
            self.check1Btn.isSelected = false
            self.check2Btn.isSelected = true
            return true
        }
        else if self.recommendTxtField == textField{
            self.check1Btn.isSelected = true
            self.check2Btn.isSelected = false
            let originalString = recommendTxtField.text ?? ""
            let cleanedString = originalString.replacingOccurrences(of: "ml", with: "").trimmingCharacters(in: .whitespaces)
            
            self.sendDailyGoals?(cleanedString)
            return false
        }
        return false
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        if  self.customQntyTxtField == textField {
            print("Entered data",customQntyTxtField.text ?? "")
            self.sendDailyGoals?(customQntyTxtField.text)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.popupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }

}
