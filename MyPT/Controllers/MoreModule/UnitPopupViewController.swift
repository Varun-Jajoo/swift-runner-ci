//
//  UnitPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/02/25.
//

import UIKit

class UnitPopupViewController: UIViewController {

    //MARK: ------------VARIABLE
    var sendUnit:((String?) -> Void)?
    let unitData = ["USOz", "ml","L"]
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var unitPopupMBV: UIView!
    @IBOutlet weak var unitTitleLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var showUnitPicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupFont()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    enum Btntag: Int{
        case dismiss = 601, cancel, save
    }
    
    @IBAction func unitCommonBtnActn(_ sender: UIButton) {
        print(sender.tag)
        switch sender.tag {
        case Btntag.dismiss.rawValue:
            self.dismiss(animated: true)
        case Btntag.cancel.rawValue:
            self.dismiss(animated: true)
        case Btntag.save.rawValue:
            print("save btn clikced...")
            self.dismiss(animated: true)
        default:
            print("None......")
        }
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.unitPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.unitPopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
            self.cancelBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.unitTitleLbl.font = AppFont.bold.size(44.0, familyName: familyManrope)
        self.cancelBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.saveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.unitPopupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
    
}

extension UnitPopupViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    // MARK: - UIPickerView DataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single column picker
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return unitData.count
    }
    
    // MARK: - UIPickerView Delegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return unitData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
         let title = unitData[row]
         let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appWhite, // Change text color
            .font: AppFont.semibold.size(14.0, familyName: familyManrope) // Set font style
         ]
         return NSAttributedString(string: title, attributes: attributes)
     }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(unitData[row])
        self.sendUnit?(unitData[row])
    }
    
}


