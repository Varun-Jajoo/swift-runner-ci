//
//  AddAddressViewController.swift
//  MyPT
//
//  Created by techsaga corp on 27/02/25.
//

import UIKit

class AddAddressViewController: CommonViewController {

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var fullNameMBV: UIView!
    @IBOutlet weak var contactNumMBV: UIView!
    @IBOutlet weak var stateMBV: UIView!
    @IBOutlet weak var localityMBV: UIView!
    @IBOutlet weak var flatNumMBV: UIView!
    @IBOutlet weak var landMarkMBV: UIView!
    @IBOutlet weak var typesOfAddrMBV: UIView!
    @IBOutlet weak var pincodeMBV: UIView!
    @IBOutlet weak var cityMBV: UIView!
    @IBOutlet weak var contactInfoTitleLbl: UILabel!
    @IBOutlet weak var fullNameHintLbl: UILabel!
    @IBOutlet weak var pincodeHintLbl: UILabel!
    @IBOutlet weak var cityHintLbl: UILabel!
    @IBOutlet weak var stateHintLbl: UILabel!
    @IBOutlet weak var localityHintLbl: UILabel!
    @IBOutlet weak var flatNumHintLbl: UILabel!
    @IBOutlet weak var landMarkHintLbl: UILabel!
    @IBOutlet weak var fullNameTxtField: UITextField!
    @IBOutlet weak var contactNumLbl: UILabel!
    @IBOutlet weak var contactNumTxtField: UITextField!
    @IBOutlet weak var addressInfoLbl: UILabel!
    @IBOutlet weak var pincodeTxtField: UITextField!
    @IBOutlet weak var cityTxtField: UITextField!
    @IBOutlet weak var stateTxtField: UITextField!
    @IBOutlet weak var localityTxtField: UITextField!
    @IBOutlet weak var flatNumTxtField: UITextField!
    @IBOutlet weak var landmarkTxtField: UITextField!
    @IBOutlet weak var typesOfAddrTitleLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var officeBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var markAsDefaultBtn: UIButton!
    @IBOutlet weak var saveAddrsBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupFont()
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
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.add_Address], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: UIColor.black, setTitleColor: UIColor.black)
    }
    
    enum BtnTag: Int {
        case editBtn = 1001, home, office, other,
        markDefault, saveAddr
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        if sender.tag == BtnTag.saveAddr.rawValue {
            print("save addrs btn clicked")
            let vc: CheckoutViewController = CheckoutViewController.instantiate(appStoryboard: .shop)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            self.setSelectionAddr(sender: sender)
        }
    }
    
    private func setSelectionAddr(sender: UIButton){
        [
            self.homeBtn,
            self.officeBtn,
            self.otherBtn,
            self.markAsDefaultBtn
        ].forEach({ [weak self] btn in
            guard self != nil, let btn = btn else {
                return
            }
            if btn.tag == sender.tag {
                btn.isSelected = true
            }else{
                btn.isSelected = false
            }
        })
    }
    
    private func setupUI(){
        
        DispatchQueue.main.async {
            [
                self.fullNameMBV,
                self.contactNumMBV,
                self.stateMBV,
                self.localityMBV,
                self.flatNumMBV,
                self.landMarkMBV,
                self.typesOfAddrMBV,
                self.pincodeMBV,
                self.cityMBV,
                
            ].forEach({
                $0?.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appDarkGray, cornerRadious: 8.0)
            })
            
            self.saveAddrsBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
//        self.fullNameHintLbl.font = AppFont.medium.size(10.0, familyName: familyManrope)
//        self.contactNumLbl.font = AppFont.medium.size(10.0, familyName: familyManrope)
        self.saveAddrsBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
       
        [
            self.fullNameHintLbl,
            self.contactNumLbl,
            self.stateHintLbl,
            self.localityHintLbl,
            self.flatNumHintLbl,
            self.landMarkHintLbl,
            self.pincodeHintLbl,
            self.cityHintLbl
        ].forEach({
            $0?.isHidden = true
            $0?.text = nil
            $0?.font = AppFont.medium.size(10.0, familyName: familyManrope)
        })
        
        [
         self.fullNameTxtField: "Full name",
         self.contactNumTxtField: "Contact number",
         self.stateTxtField: "State",
         self.localityTxtField: "Locality",
         self.flatNumTxtField: "Flat number",
         self.landmarkTxtField: "Landmark (optional)",
         self.pincodeTxtField: "Pincode",
         self.cityTxtField: "City",
        ].forEach({[weak self] (key, value) in
            guard let self = self else {
                return
            }
            key?.delegate = self
            key?.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            key?.placeholderSet(placeHolder: value, color: UIColor.appWhite.withAlphaComponent(0.7))
            key?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
            if key == self.contactNumTxtField {
                key?.keyboardType = .phonePad
            }else{
                key?.keyboardType = .default
            }
        })
        
        [
            self.contactInfoTitleLbl,
            self.addressInfoLbl,
            self.typesOfAddrTitleLbl
        ].forEach({ [weak self]
            lbl in
            guard self != nil else {
                return
            }
            lbl?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
                
        [
            self.homeBtn.titleLabel,
            self.officeBtn.titleLabel,
            self.otherBtn.titleLabel,
            self.markAsDefaultBtn.titleLabel,
            self.saveAddrsBtn.titleLabel
        ].forEach({ [weak self] btn in
            guard self != nil else {
                return
            }
            btn?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
    }
}

extension AddAddressViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    
    @objc func textFieldDidChange(textField: UITextField){
        if let hintLabel = self.getHintLbl(inputTxtField: textField) {
            if let isEmptyTxt = textField.text?.isEmpty, !isEmptyTxt {
                hintLabel.isHidden = false
                hintLabel.text = self.hintTxtGet(inputLabel: hintLabel)
            } else {
                hintLabel.isHidden = true
                hintLabel.text = nil
            }
        }
    }
    
    func getHintLbl(inputTxtField: UITextField) -> UILabel? {
        let textFieldsWithLabels: [UITextField: UILabel] = [
               self.fullNameTxtField: fullNameHintLbl,
               self.contactNumTxtField: contactNumLbl,
               self.stateTxtField: stateHintLbl,
               self.localityTxtField: localityHintLbl,
               self.flatNumTxtField: flatNumHintLbl,
               self.landmarkTxtField: landMarkHintLbl,
               self.pincodeTxtField: pincodeHintLbl,
               self.cityTxtField: cityHintLbl
           ]
        
        return textFieldsWithLabels[inputTxtField]
    }
    
    func hintTxtGet(inputLabel: UILabel) -> String {
        let hintTxt: [UILabel: String] = [
            self.fullNameHintLbl: "Full name",
            self.contactNumLbl: "Contact number",
            self.stateHintLbl: "State",
            self.localityHintLbl: "Locality",
            self.flatNumHintLbl: "Flat number",
            self.landMarkHintLbl: "Landmark (optional)",
            self.pincodeHintLbl: "Pincode",
            self.cityHintLbl: "City",
        ]
        
        return hintTxt[inputLabel] ?? ""
    }
}
