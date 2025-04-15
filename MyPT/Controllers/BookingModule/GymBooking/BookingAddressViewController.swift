//
//  BookingAddressViewController.swift
//  MyPT
//
//  Created by techsaga corp on 15/03/25.
//

import UIKit

enum BookingAddressFlow: CaseIterable {
    case addAddress
    case editAddress
    case addMember
    case defaultBooing
}

protocol BookingAddressProtocol {
    func onDismiss(isDismiss: Bool?)
}

protocol AddMemberProtocol {
    func memberAdd(isDismiss: Bool?)
}

class BookingAddressViewController: UIViewController {

    //MARK: ------------VARIABLE
    var hintTxt:[String] = []
    var bookingAddressFlow: BookingAddressFlow = .defaultBooing
    var delegate:BookingAddressProtocol?
    var addMemberDelegate: AddMemberProtocol?
    
    var idStr: String?
    var city_idStr: String?
    var country_idStr: String?
    var typeStr: String?
    var inputLat: String?
    var inputLong: String?
    var addressData:AddressDataModel?
    var navCtrnl:UINavigationController?
    var addMemberData:MemberModel?
    

    //MARK: --------------IBOUTLET
    @IBOutlet weak var popupScrollV: UIScrollView!
    @IBOutlet weak var popupMBV: UIView!
    @IBOutlet weak var buildingNumMBV: UIView!
    @IBOutlet weak var streetNameMBV: UIView!
    @IBOutlet weak var landmarkMBV: UIView!
    @IBOutlet weak var mobilMBV: UIView!
    @IBOutlet weak var cityMBV: UIView!
    @IBOutlet weak var countryMBV: UIView!
    @IBOutlet weak var typeAddressMBV: UIView!
    @IBOutlet weak var saveAddMemberMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var buildingNumHintLbl: UILabel!
    @IBOutlet weak var streetNameHintLbl: UILabel!
    @IBOutlet weak var landmarkHintLbl: UILabel!
    @IBOutlet weak var mobileHintLbl: UILabel!
    @IBOutlet weak var cityHintLbl: UILabel!
    @IBOutlet weak var countryHintLbl: UILabel!
    @IBOutlet weak var typeAddrTitleLbl: UILabel!
    @IBOutlet weak var buildingNumTxt: UITextField!
    @IBOutlet weak var streetNameTxt: UITextField!
    @IBOutlet weak var landmarkTxt: UITextField!
    @IBOutlet weak var mobileTxt: UITextField!
    @IBOutlet weak var cityTxt: UITextField!
    @IBOutlet weak var countryTxt: UITextField!
    @IBOutlet weak var selectCityBtn: UIButton!
    @IBOutlet weak var selectCountryBtn: UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var officeBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var saveUpdateBtn: UIButton!
    @IBOutlet weak var addMemeberSaveNextBtn: UIButton!
    @IBOutlet weak var addMemeberSaveBtn: UIButton!
    @IBOutlet weak var saveUpdateBtnHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var saveUpdateBtnTopConstrnt: NSLayoutConstraint!
    @IBOutlet weak var saveUpdateBtnBottomConstrnt: NSLayoutConstraint!
    @IBOutlet weak var scrollVBottomConstrnt: NSLayoutConstraint!
    @IBOutlet weak var popupMBVHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        //        self.setupHint()
        self.setFlowAddress()
        
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
          if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
              let keyboardHeight = keyboardFrame.height
            
              switch bookingAddressFlow {
              case .addAddress, .editAddress:
                  print("add/Edit adress..")
              case .addMember:
                  // Adjust the scroll view's content inset
//                  popupScrollV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
//                  popupScrollV.scrollIndicatorInsets = popupScrollV.contentInset
                                    
                  popupMBVHeightConstrnt.constant = keyboardHeight + view.frame.size.height * 0.2
                  view.layoutIfNeeded()
                  
              case .defaultBooing:
                  break
              }
              
          }
      }
      
      @objc func keyboardWillHide(notification: Notification) {
          // Reset the scroll view's content inset
          popupScrollV.contentInset = .zero
          popupScrollV.scrollIndicatorInsets = .zero
      }
    
    private func setupHint(){
        hintTxt = [
                    "Building/Villa Name or Number",
                    "Street Name & Number",
                    "Landmark (Optional)",
                    "Mobile",
                    "City",
                    "Country"
                  ]
    }
    
    @IBAction func addMemebersBtnActn(_ sender: UIButton) {
        if sender.tag == 801 {
            print("save & next btn clicked")
            
        }else{
            print("save members btn clicked.")
            let memberParams = AddMemberParams(name: self.buildingNumTxt.text, age: self.streetNameTxt.text, gender: self.typeStr ?? "", id: "\(addMemberData?.id ?? -1)")
            
            //id is getting then meber will be edit ohterwise new member added
            if CreatePackageVM.isValidMember(inputParams: memberParams) {
                
                CreatePackageVM.addMemberApi(viewController: self, inputParams: memberParams.getParams(), completion: { [weak self] getResultData in
                    guard let self = self, let getResultData = getResultData else { return  }
                    
                    if getResultData.status == true{
                        self.dismiss(animated: true, completion: {
                            self.addMemberDelegate?.memberAdd(isDismiss: true)
                        })
                    }
                })
            }
            
        }
    }
    
    
    @IBAction func saveUpdateBtnActn(_ sender: Any) {
        print("save and update btn..")
        
        let phoneNumber = (self.mobileTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "-", with: "")
        
        let params:[String:Any] = [
            "id" : (self.idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "building_name": (self.buildingNumTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "street": (self.streetNameTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "city_id": (self.city_idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "country_id": (self.country_idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "landmark": (self.landmarkTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "type": (self.typeStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "mobile_no": phoneNumber,
            "lat": self.inputLat ?? "28.584125",
            "long": self.inputLong ?? "77.2753162"
        ]
        
   
        if TrainerVM.isValideAddres(inputParams: params) {
            print("api is called..")
           
            TrainerVM.addAddressApi(viewController: self, inputParams: params, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                
                print("Add Adrress successfully: ",getResultData)
                
                NotificationCenter.default.post(name: NSNotification.Name("UpdateAddress"), object: nil, userInfo: ["newValue": "True"])
                
                self.delegate?.onDismiss(isDismiss: true)
                self.dismiss(animated: true, completion: {
                    self.navCtrnl?.popToViewController(ofClass: SelectYourLocationViewController.self, animated: true)
                })
            })
        }
        
    }
    
    enum btnTag: Int {
    case dismiss = 401, home, office, other, selectCity, selectCounrty
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        switch sender.tag {
        case btnTag.dismiss.rawValue:
            self.dismiss(animated: true, completion: nil)
        case btnTag.home.rawValue, btnTag.office.rawValue, btnTag.other.rawValue:
            self.setAddrType(sender: sender)
        case btnTag.selectCity.rawValue:
            self.cityTxt.becomeFirstResponder()
        case btnTag.selectCounrty.rawValue:
            self.countryTxt.becomeFirstResponder()
        default:
            print("none...")
            break
        }
    }
    
    //--------------------SETUP INPUT DATA
    private func setInputData(data: AddressDataModel){
        
        
        let textFields: [(UITextField, String)] = [
            (buildingNumTxt, data.building_name?.value ?? ""),
            (streetNameTxt, data.street?.value ?? ""),
            (landmarkTxt, data.landmark ?? ""),
            (mobileTxt, data.mobile_no?.value ?? ""),
            (cityTxt, data.city_name ?? ""),
            (countryTxt, data.country_name ?? "")
        ]

        textFields.forEach { (textField, txtStr) in
            if let hintLabel = self.getHintLbl(inputTxtField: textField) {
                if !txtStr.isEmpty {
                    hintLabel.isHidden = false
                    hintLabel.text = self.hintTxtGet(inputLabel: hintLabel)
                    textField.text = txtStr
                } else {
                    hintLabel.isHidden = true
                    hintLabel.text = nil
                }
            }
        }
        
        self.city_idStr = data.city_id?.value
        self.country_idStr = data.country_id?.value
        
        //----------------*************Button selection
        if let type = data.type {
            self.typeStr = data.type
            
            if type.uppercased() == "Home".uppercased() {
                self.homeBtn.isSelected = true
            }else  if type.uppercased() == "Office".uppercased() {
                self.officeBtn.isSelected = true
            }else  if type.uppercased() == "Others".uppercased() {
                self.otherBtn.isSelected = true
            }
        }
    }
    
    //------------------SETUP FLOW ADDRESS
    private func setFlowAddress(){
        
        switch bookingAddressFlow {
        case .addAddress:
            
            popupMBVHeightConstrnt.constant = view.frame.size.height * 0.8
            
            [
                landmarkMBV,
                cityMBV,
                countryMBV,
                typeAddressMBV,
                saveUpdateBtn
            ].forEach({
                $0?.isHidden = false
            })
            
            self.countryTxt.isUserInteractionEnabled = false
            self.selectCountryBtn.isHidden = true
            saveAddMemberMBV.isHidden = true
            saveUpdateBtnHeightConstrnt.constant = 56.0
            saveUpdateBtnTopConstrnt.constant = 20.0
            saveUpdateBtnBottomConstrnt.constant = 20.0
            
            self.topTitleLbl.text = "Add New Address"
            self.homeBtn.setTitle("Home", for: .normal)
            self.officeBtn.setTitle("Office", for: .normal)
            self.otherBtn.setTitle("Others", for: .normal)
            
            //----------------------Text fields
            self.setupTxtField()
            
            //-----------------setup input data
            if let addressData = addressData {
                self.setInputData(data: addressData)
                self.inputLat = "\(addressData.lat?.value ?? "0.0")"
                self.inputLat = "\(addressData.lat?.value ?? "0.0")"
                
            }
            
            self.setupTxtField()
            
        case .editAddress:
            self.topTitleLbl.text = "Edit Address"
            if let addressData = addressData {
                self.idStr = addressData.id?.value
                self.setInputData(data: addressData)
                
                //-----------------setup input data
                self.inputLat = "\(addressData.lat?.value ?? "0.0")"
                self.inputLat = "\(addressData.lat?.value ?? "0.0")"
            }
            
            self.setupTxtField()
            
            popupMBVHeightConstrnt.constant = view.frame.size.height * 0.8
            
            [
                landmarkMBV,
                cityMBV,
                countryMBV,
                typeAddressMBV,
                saveUpdateBtn
            ].forEach({
                $0?.isHidden = false
            })
            
            self.countryTxt.isUserInteractionEnabled = false
            self.selectCountryBtn.isHidden = true
            saveAddMemberMBV.isHidden = true
            saveUpdateBtnHeightConstrnt.constant = 56.0
            saveUpdateBtnTopConstrnt.constant = 20.0
            saveUpdateBtnBottomConstrnt.constant = 20.0
            
            self.homeBtn.setTitle("Home", for: .normal)
            self.officeBtn.setTitle("Office", for: .normal)
            self.otherBtn.setTitle("Others", for: .normal)
                        
        case .addMember:
            
            popupMBVHeightConstrnt.constant = view.frame.size.height * 0.6
            
            DispatchQueue.main.async {
                self.typeAddressMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
            
            [
                landmarkMBV,
                cityMBV,
                countryMBV,
                mobilMBV,
                saveUpdateBtn
            ].forEach({
                $0?.isHidden = true
            })
            
            typeAddressMBV.isHidden = false
            saveAddMemberMBV.isHidden = false
            saveUpdateBtnHeightConstrnt.constant = 0.0
            saveUpdateBtnBottomConstrnt.constant = 1.0
            
            self.topTitleLbl.text = "Add Members"
            self.typeAddrTitleLbl.text = "Select Gender"
            self.homeBtn.setTitle("Male", for: .normal)
            self.officeBtn.setTitle("Female", for: .normal)
            self.otherBtn.setTitle("Others", for: .normal)
            
            //----------------------Text fields
            self.streetNameTxt.keyboardType = .decimalPad
            
            [
                buildingNumTxt: "Enter Full Name",
                streetNameTxt: "Enter Age",
            ].forEach({[weak self] (key, value) in
                guard let self = self, let key = key else {
                    return
                }
                
                key.placeholderSet(placeHolder: value, color: UIColor.txtDarkGray)
                key.font = AppFont.semibold.size(16.0, familyName: familyManrope)
                key.delegate = self
                key.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
            })
            
            //---------------------- SETUP INPUT DATA
            if let addMemberData = addMemberData, let memberId = addMemberData.id, memberId != 0  {
                self.buildingNumTxt.text = addMemberData.name
                self.streetNameTxt.text = addMemberData.age?.value
                self.buildingNumTxt.sendActions(for: .editingChanged)
                self.streetNameTxt.sendActions(for: .editingChanged)
                
                
                //----------------*************Button selection
                if let type = addMemberData.gender {
                    self.typeStr = type
                    
                    if type.uppercased() == "Male".uppercased() {
                        self.homeBtn.isSelected = true
                    }else  if type.uppercased() == "Female".uppercased() {
                        self.officeBtn.isSelected = true
                    }else  if type.uppercased() == "Others".uppercased() {
                        self.otherBtn.isSelected = true
                    }
                }
                
            }
            
        case .defaultBooing:
            break
        }
    }
    
    //------------------
    private func setAddrType(sender: UIButton){
        [
            self.homeBtn,
            self.officeBtn,
            self.otherBtn,
        ].forEach({ [weak self] btn in
       
            guard let self = self, let btn = btn else { return }
            
            if btn.tag == sender.tag {
                btn.isSelected = true
                self.typeStr = (btn.titleLabel?.text)?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            }else{
                btn.isSelected = false
            }
        })
    }
    
    private func setupTxtField(){
        //----------------------Text fields
        [
            buildingNumTxt: "Building/Villa Name or Number",
            streetNameTxt: "Street Name & Number",
            landmarkTxt: "Landmark (Optional)",
            mobileTxt: "Mobile",
            cityTxt: "City",
            countryTxt: "Country"
        ].forEach({[weak self] (key, value) in
            guard let self = self, let key = key else {
                return
            }
            
            key.placeholderSet(placeHolder: value, color: UIColor.txtDarkGray)
            key.font = AppFont.semibold.size(16.0, familyName: familyManrope)
            key.delegate = self
            key.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        })
    }
    
    //MARK: -------------FOR DROP DOWN
    private func openDropDown(inputView: UIView){
        let popupVC:CityDropDownViewController = CityDropDownViewController.instantiate(appStoryboard: .booking)
         popupVC.modalPresentationStyle = .popover
        popupVC.sentBackData = { [weak self] getCityName , getId, getCountryName, getCountryId in
            guard let self = self else { return  }
            print("name", getCityName as Any, "id", getId as Any)
            self.cityTxt.text = getCityName
            self.countryTxt.text = getCountryName
            self.city_idStr = "\(getId ?? 0)"
            self.country_idStr = "\(getCountryId ?? 0)"
            
            if let city = self.cityTxt.text, !city.isEmpty{
                self.cityHintLbl.isHidden = false
                self.cityHintLbl.text = "City"
            }
            if let country = self.countryTxt.text, !country.isEmpty {
                self.countryHintLbl.isHidden = false
                self.countryHintLbl.text = "Country"
            }
        }
    //        popupVC.preferredContentSize = CGSize(width: 200, height: 100)
        popupVC.view.backgroundColor = UIColor.mainBg
         if let popoverController = popupVC.popoverPresentationController {
             popoverController.sourceView = inputView
             popoverController.sourceRect = inputView.bounds
             popoverController.permittedArrowDirections = .any
             popoverController.delegate = self
         }
         present(popupVC, animated: false)
    }
        
    private func setupUI(){
        DispatchQueue.main.async {
            self.popupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.popupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.saveUpdateBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.addMemeberSaveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            [
                self.buildingNumMBV,
                self.streetNameMBV,
                self.landmarkMBV,
                self.mobilMBV,
                self.cityMBV,
                self.countryMBV,
                self.typeAddressMBV,
                self.addMemeberSaveNextBtn
            ].forEach({
                $0.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            })
            
            //---------------------------**************
            if self.getEnumCaseName(self.bookingAddressFlow).uppercased() == "addMember".uppercased() {
                self.typeAddressMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
        }
        view.layoutIfNeeded()
        
//        let hh = bookingAddressFlow.hashValue
        
    }
    
    private func getEnumCaseName(_ flow: BookingAddressFlow) -> String {
        return String(describing: flow)
    }
    
    private func setupFont(){
        self.topTitleLbl.font  = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.typeAddrTitleLbl.font  = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.saveUpdateBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.addMemeberSaveNextBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.addMemeberSaveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        [
            self.homeBtn.titleLabel,
            self.officeBtn.titleLabel,
            self.otherBtn.titleLabel
        ].forEach({
            $0?.font = AppFont.medium.size(12.0, familyName: familyManrope)
        })
        
        //-----------------Hint Label
        [
            buildingNumHintLbl,
            streetNameHintLbl,
            landmarkHintLbl,
            mobileHintLbl,
            cityHintLbl,
            countryHintLbl,
        ].forEach({
            $0.font = AppFont.medium.size(10.0, familyName: familyManrope)
            $0.text = nil
        })
        
        //----------------------Text fields
        [
            buildingNumTxt,
            streetNameTxt,
            landmarkTxt,
            mobileTxt,
            cityTxt,
            countryTxt
        ].forEach({[weak self] key in
            guard let self = self, let key = key else {
                return
            }
            key.font = AppFont.semibold.size(16.0, familyName: familyManrope)
            key.delegate = self
            key.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        })
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


extension BookingAddressViewController: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.cityTxt {
            view.endEditing(true)
            self.openDropDown(inputView: textField)
            return false
        }
        else if textField == self.countryTxt {
            view.endEditing(true)
            self.openDropDown(inputView: textField)
            return false
        }
        return true
    }
    
    // UITextFieldDelegate method to restrict the input to 10 digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.mobileTxt {
            // Allow only numeric input
            let allowedCharacterSet = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            if !allowedCharacterSet.isSuperset(of: characterSet) {
                return false // Disallow non-numeric input
            }
            
            // Check the total length after the proposed change
            if let currentText = textField.text, let stringRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
               
                if let textFieldMobile = self.mobileTxt.text, string != "" {
                    if textFieldMobile.count == 3 || textFieldMobile.count == 7 {
                        self.mobileTxt.text = textFieldMobile.text + "-"
                    }
                }
                
                return updatedText.count <= 12 // Allow input only if it results in 10 or fewer digits
            }
        }
        
        return true
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
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
            self.buildingNumTxt: buildingNumHintLbl,
            self.streetNameTxt: streetNameHintLbl,
            self.landmarkTxt: landmarkHintLbl,
            self.mobileTxt: mobileHintLbl,
            self.cityTxt: cityHintLbl,
            self.countryTxt: countryHintLbl
           ]
        
        return textFieldsWithLabels[inputTxtField]
    }
    
    func hintTxtGet(inputLabel: UILabel) -> String {
        let hintTxtAddAddress: [UILabel: String] = [
            self.buildingNumHintLbl: "Building/Villa Name or Number",
            self.streetNameHintLbl: "Street Name & Number",
            self.landmarkHintLbl: "Landmark (Optional)",
            self.mobileHintLbl: "Mobile",
            self.cityHintLbl: "City",
            self.countryHintLbl: "Country",
        ]
        
        let hintTxtAddMember: [UILabel: String] = [
            self.buildingNumHintLbl: "Enter Full Name",
            self.streetNameHintLbl: "Enter Age"
        ]
        
        switch bookingAddressFlow {
        case .addAddress, .editAddress:
            return hintTxtAddAddress[inputLabel] ?? ""
            
        case .addMember:
            return hintTxtAddMember[inputLabel] ?? ""
        case .defaultBooing:
            break
        }
        
        return ""
//        return hintTxt[inputLabel] ?? ""
    }
}


//MARK: --------------EXTENSION FOR API
//extension BookingAddressViewController{
//    
//    private func getAddressListApi(){
//        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
//            guard let self = self, let getResultData = getResultData else { return  }
//            
//            print("getResultData", getResultData)
//          
//        })
//    }
//    
//}

// MARK: ------------ UIPopoverPresentationControllerDelegate
extension BookingAddressViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none  // Keeps it as a popover on iPhone instead of full-screen
    }
}


//MARK: ------------------ADD MEMBER PARAMS
struct AddMemberParams {
    var name: String?
    var age: String?
    var gender: String?
    var id: String?
    
    func getParams() -> [String:Any] {
        var dictVar: [String:Any] =  [:]
        
        if let name = name { dictVar["name"] = name }
        if let age = age { dictVar["age"] = age }
        if let gender = gender { dictVar["gender"] = gender }
        if let id = id { dictVar["id"] = id }
        
        return dictVar
    }
}
