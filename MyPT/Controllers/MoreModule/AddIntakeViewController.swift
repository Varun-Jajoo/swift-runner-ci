//
//  AddIntakeViewController.swift
//  MyPT
//
//  Created by techsaga corp on 12/02/25.
//

import UIKit

class AddIntakeViewController: UIViewController {

    //MARK: ---------------IBOUTLET
    @IBOutlet weak var popuoMBV: UIView!
    @IBOutlet weak var inteakeTxtFieldMBV: UIView!
    @IBOutlet weak var titlLbl: UILabel!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var enterIntakeTxtField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var infBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupFont()
    }
    
    
    @IBAction func saveBtnActn(_ sender: UIButton) {
        print("save btn clicked.")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setupUI(){
        self.enterIntakeTxtField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    
        DispatchQueue.main.async {
            self.popuoMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.popuoMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.inteakeTxtFieldMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite, cornerRadious: 8.0)
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12)
            self.enterIntakeTxtField.placeholderSet(placeHolder: "Enter calories", color: UIColor.txtDarkGray)
        }
        
        let image = UIImage(named: "ic_information_circle")?.withRenderingMode(.alwaysTemplate)
        self.infBtn.titleLabel?.numberOfLines = 2
        self.infBtn.setImage(image, for: .normal)
        self.infBtn.tintColor = UIColor(red: 109.0/255.0, green: 109.0/255.0, blue: 109.0/255.0, alpha: 1)
    }
    
    func setupFont(){
        self.titlLbl.font = AppFont.bold.size(24.0, familyName: familyManrope)
        self.headingLbl.font = AppFont.medium.size(10.0, familyName: familyManrope)
        self.enterIntakeTxtField.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.infBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.saveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.popuoMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    
    @objc func textFieldDidChange(textField: UITextField){
        if  enterIntakeTxtField == textField {
            if let isEmptyTxt = textField.text?.isEmpty, !isEmptyTxt{
                self.headingLbl.isHidden = false
                self.headingLbl.text = "Calories"
            }else{
                self.headingLbl.isHidden = true
                self.headingLbl.text = nil
            }
        }
    }
}
