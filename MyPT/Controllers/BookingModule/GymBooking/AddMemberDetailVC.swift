//
//  AddMemberDetailVC.swift
//  MyPT
//
//  Created by Manik Goel on 02/02/26.
//

import UIKit

class AddMemberDetailVC: UIViewController {
    
    //MARK: ------------VARIABLE
    var addMaxMember:Int?
    var addedMember:Int?
    private var currentAddMember:Int = 0
    
    var delegate:BookingAddressProtocol?
    var addMemberDelegate: AddMemberProtocol?
    
    var typeStr: String?
    var inputLat: String?
    var inputLong: String?
    var navCtrnl:UINavigationController?
    var addMemberData:MemberModel?

    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectGenderLabel: UILabel!   // "Select Gender"
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var fullNameTextField: UITextField!   // "Enter Full Name"
    @IBOutlet weak var ageTextField: UITextField!        // "Enter Age"
    @IBOutlet weak var saveAndAddNextButton: UIButton!   // "SAVE & ADD NEXT"
    @IBOutlet weak var saveButton: UIButton!             // "SAVE"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentAddMember = self.addedMember ?? 0
        
//        self.setupFont()
//        //        self.setupHint()
//        self.setFlowAddress()
//        
//        
//        // Register for keyboard notifications
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.setupUI()
//    }
//    
//    
//    @objc func keyboardWillShow(notification: Notification) {
//          if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//              let keyboardHeight = keyboardFrame.height
//                  popupMBVHeightConstrnt.constant = keyboardHeight + view.frame.size.height * 0.2
//                  view.layoutIfNeeded()
//          }
//      }
//      
////      @objc func keyboardWillHide(notification: Notification) {
////          // Reset the scroll view's content inset
////          popupScrollV.contentInset = .zero
////          popupScrollV.scrollIndicatorInsets = .zero
////      }
//    
//    @IBAction func addMemebersBtnActn(_ sender: UIButton) {
//        if sender.tag == 801 {
//            print("save & next btn clicked")
//           
//            print("First time currentAddMember", currentAddMember)
//            
//            if let addMaxMember = addMaxMember,  currentAddMember < addMaxMember {
//                
//                let memberParams = AddMemberParams(name: self.buildingNumTxt.text, age: self.streetNameTxt.text, gender: self.typeStr ?? "", id: "\(addMemberData?.id ?? -1)")
//                
//                //id is getting then meber will be edit ohterwise new member added
//                if CreatePackageVM.isValidMember(inputParams: memberParams) {
//                    currentAddMember += 1
//                    print("currentAddMember", currentAddMember)
//                    CreatePackageVM.addMemberApi(viewController: self, inputParams: memberParams.getParams(), completion: { [weak self] getResultData in
//                        
//                        self?.view.endEditing(true)
//                        self?.addMemberDelegate?.editReloadData(isReload: true)
//                        self?.addMemberData?.id = nil
//                        self?.typeStr = nil
//                        self?.setAddrType(sender: UIButton())
//                        self?.buildingNumTxt.text = nil
//                        self?.streetNameTxt.text = nil
//                        
//                        guard let self = self, let getResultData = getResultData else { return  }
//                        
//                        if getResultData.status == true{
//                            if currentAddMember == addMaxMember {
//                                self.dismiss(animated: true, completion: {
//                                    self.addMemberDelegate?.memberAdd(isDismiss: true)
//                                })
//                            }
//                        }
//                    })
//                }
//            }else{
//                print("max number member added.")
//            }
//            
//        }else{
//            print("save members btn clicked.")
//            let memberParams = AddMemberParams(name: self.buildingNumTxt.text, age: self.streetNameTxt.text, gender: self.typeStr ?? "", id: "\(addMemberData?.id ?? -1)")
//            
//            //id is getting then meber will be edit ohterwise new member added
//            if CreatePackageVM.isValidMember(inputParams: memberParams) {
//                
//                CreatePackageVM.addMemberApi(viewController: self, inputParams: memberParams.getParams(), completion: { [weak self] getResultData in
//                    guard let self = self, let getResultData = getResultData else { return  }
//                    
//                    if getResultData.status == true{
//                        self.dismiss(animated: true, completion: {
//                            self.addMemberDelegate?.memberAdd(isDismiss: true)
//                        })
//                    }
//                })
//            }
//            
//        }
//    }
//    
//    
//    @IBAction func saveUpdateBtnActn(_ sender: Any) {
//        print("save and update btn..")
//        
//        let phoneNumber = (self.apartmentTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "-", with: "")
//        let params:[String:Any] = [
//            "id" : (self.idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "building_name": (self.buildingNumTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "street": (self.streetNameTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "city_id": (self.city_idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "country_id": (self.country_idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "landmark": (self.landmarkTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "type": (self.typeStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "mobile_no": "9876543210",
//            "lat": self.inputLat ?? "28.584125",
//            "long": self.inputLong ?? "77.2753162",
//            "name": ""
//        ]
//   
//        if TrainerVM.isValideAddres(inputParams: params) {
//            print("api is called..")
//           
//            TrainerVM.addAddressApi(viewController: self, inputParams: params, completion: { [weak self] getResultData in
//                guard let self = self, let getResultData = getResultData else { return  }
//                
//                print("Add Adrress successfully: ",getResultData)
//                
//                NotificationCenter.default.post(name: NSNotification.Name("UpdateAddress"), object: nil, userInfo: ["newValue": "True"])
//                
//                self.delegate?.onDismiss(isDismiss: true)
//                self.dismiss(animated: true, completion: {
////                    self.navCtrnl?.popToViewController(ofClass: SelectYourLocationViewController.self, animated: true)
//                    let vc:CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
////                    vc.createParams = CreatePackageParamsModel(
////                        package_type: "",
////                        sessions: "",
////                        type: inputGetSlotParams?.type,
////                        timing: inputGetSlotParams?.timing,
////                        trainer_id: inputGetSlotParams?.trainer_id,
////                        studio_id: inputGetSlotParams?.studio_id,
////                        month: "\(Int(self.getMonth(inputDateStr: selectedDate ?? "").0) ?? 0)",
////                        address_id: inputGetSlotParams?.address_id
////                    )
////                    vc.avialCalanderparams = self.avialCalanderparams
////                    vc.isFirst = false
//                    self.navCtrnl?.pushViewController(vc, animated: true)
//                })
//            })
//        }
//        
//    }
//    
//    enum btnTag: Int {
//    case dismiss = 401, home, work, other, selectCity, selectCounrty
//    }
//    
//    @IBAction func commonBtnActn(_ sender: UIButton) {
//        switch sender.tag {
//        case btnTag.dismiss.rawValue:
//            self.dismiss(animated: true, completion: nil)
//        case btnTag.home.rawValue, btnTag.work.rawValue, btnTag.other.rawValue:
//            self.setAddrType(sender: sender)
//        case btnTag.selectCity.rawValue:
//            self.cityTxt.becomeFirstResponder()
//        case btnTag.selectCounrty.rawValue:
//            self.countryTxt.becomeFirstResponder()
//        default:
//            print("none...")
//            break
//        }
//    }
//    
//    //--------------------SETUP INPUT DATA
//    private func setInputData(data: AddressDataModel) {
//        let textFields: [(UITextField, String)] = [
//            (buildingNumTxt, data.building_name?.value ?? ""),
//            (streetNameTxt, data.street?.value ?? ""),
//            (landmarkTxt, data.landmark ?? ""),
//            (apartmentTxt, data.mobile_no?.value ?? ""),
//            (cityTxt, data.city_name ?? ""),
////            (countrySideTxt, data.country_name ?? "")
////            (countryTxt, data.country_name ?? "")
//        ]
//
//        textFields.forEach { (textField, txtStr) in
//            if let hintLabel = self.getHintLbl(inputTxtField: textField) {
//                if !txtStr.isEmpty {
//                    hintLabel.isHidden = false
//                    hintLabel.text = self.hintTxtGet(inputLabel: hintLabel)
//                    textField.text = txtStr
//                } else {
//                    hintLabel.isHidden = true
//                    hintLabel.text = nil
//                }
//            }
//        }
//        
//        self.city_idStr = data.city_id?.value
//        self.country_idStr = data.country_id?.value
//        
//        //----------------*************Button selection
//        if let type = data.type {
//            self.typeStr = data.type
//            
//            if type.uppercased() == "Home".uppercased() {
//                self.homeBtn.isSelected = true
//            } else if type.uppercased() == "Work".uppercased() {
//                self.officeBtn.isSelected = true
//            } else if type.uppercased() == "Others".uppercased() {
//                self.otherBtn.isSelected = true
//            }
//        }
//    }
//    
//    //------------------SETUP FLOW ADDRESS
//    private func setFlowAddress() {
//                        
//        case .addMember:
//            
//            popupMBVHeightConstrnt.constant = view.frame.size.height * 0.6
//            
////            DispatchQueue.main.async {
////                self.typeAddressMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
////            }
//            
//            [
//                apartmentMBV,
//                landmarkMBV,
//                cityMBV,
//                countrySideMBV,
////                countryMBV,
////                mobilMBV,
//                saveUpdateBtn
//            ].forEach({
//                $0?.isHidden = true
//            })
//            
//            typeAddressMBV.isHidden = false
//            saveAddMemberMBV.isHidden = false
//            saveUpdateBtnHeightConstrnt.constant = 0.0
//            saveUpdateBtnBottomConstrnt.constant = 1.0
//            
//            self.topTitleLbl.text = "Add Members"
//            self.typeAddrTitleLbl.text = "Select Gender"
//            self.homeBtn.setTitle("Male", for: .normal)
//            self.officeBtn.setTitle("Female", for: .normal)
//            self.otherBtn.setTitle("Others", for: .normal)
//            
//            //----------------------Text fields
//            self.streetNameTxt.keyboardType = .decimalPad
//            
//            [
//                buildingNumTxt: "Enter Full Name",
//                streetNameTxt: "Enter Age",
//            ].forEach({[weak self] (key, value) in
//                guard let self = self, let key = key else {
//                    return
//                }
//                
//                key.placeholderSet(placeHolder: value, color: UIColor.txtDarkGray)
//                key.font = AppFont.semibold.size(16.0, familyName: familyManrope)
//                key.delegate = self
//                key.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
//            })
//            
//            //---------------------- SETUP INPUT DATA
//            if let addMemberData = addMemberData, let memberId = addMemberData.id, memberId != 0  {
//                self.buildingNumTxt.text = addMemberData.name
//                self.streetNameTxt.text = addMemberData.age?.value
//                self.buildingNumTxt.sendActions(for: .editingChanged)
//                self.streetNameTxt.sendActions(for: .editingChanged)
//                
//                
//                //----------------*************Button selection
//                if let type = addMemberData.gender {
//                    self.typeStr = type
//                    
//                    if type.uppercased() == "Male".uppercased() {
//                        self.homeBtn.isSelected = true
//                    }else  if type.uppercased() == "Female".uppercased() {
//                        self.officeBtn.isSelected = true
//                    }else  if type.uppercased() == "Others".uppercased() {
//                        self.otherBtn.isSelected = true
//                    }
//                }
//                
//            }
//            
//        case .defaultBooing:
//            break
//        }
//    }
//    
//    //------------------
//    private func setAddrType(sender: UIButton) {
//        [
//            self.homeBtn,
//            self.officeBtn,
//            self.otherBtn,
//        ].forEach({ [weak self] btn in
//       
//            guard let self = self, let btn = btn else { return }
//            
//            if btn.tag == sender.tag {
////                btn.isSelected = true
//                btn.backgroundColor = UIColor(hex: "#1B1D13")
//                btn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#6C7627"), cornerRadious: 8.0)
//                self.typeStr = (btn.titleLabel?.text)?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//            } else {
////                btn.isSelected = false
//                btn.backgroundColor = UIColor(hex: "#101113")
//                btn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#28292B"), cornerRadious: 8.0)
//            }
//        })
//    }
//    
//    private func setupTxtField(){
//        //----------------------Text fields
//        [
//            apartmentTxt: "Apartment Unit / Number",
//            buildingNumTxt: "Building / Tower Name",
//            streetNameTxt: "Street Name",
//            landmarkTxt: "Directions to reach (Optional)",
//            cityTxt: "City",
//            countryTxt: "Emirates"
//        ].forEach({[weak self] (key, value) in
//            guard let self = self, let key = key else {
//                return
//            }
//            
//            key.placeholderSet(placeHolder: value, color: UIColor.txtDarkGray)
//            key.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
//            key.delegate = self
//            key.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
//        })
//    }
//
//
//    private func setupUI() {
//        DispatchQueue.main.async {
//            self.popupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
//            self.popupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
//            self.saveUpdateBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
//            self.addMemeberSaveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
//            self.homeBtn.backgroundColor = UIColor(hex: "#1B1D13")
//            self.homeBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#6C7627"), cornerRadious: 8.0)
//            self.officeBtn.backgroundColor = UIColor(hex: "#101113")
//            self.officeBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#28292B"), cornerRadious: 8.0)
//            self.otherBtn.backgroundColor = UIColor(hex: "#101113")
//            self.otherBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#28292B"), cornerRadious: 8.0)
//            [
//                self.apartmentMBV,
//                self.buildingNumMBV,
//                self.streetNameMBV,
//                self.landmarkMBV,
////                self.mobilMBV,
//                self.cityMBV,
//                self.countrySideMBV,
////                self.countryMBV,
//                self.addMemeberSaveNextBtn
//            ].forEach({
//                $0?.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#2C2C2C"), cornerRadious: 12.0)
//                $0?.backgroundColor = UIColor(hex: "#141514")
//            })
//            
//            //---------------------------**************
//            if self.getEnumCaseName(self.bookingAddressFlow).uppercased() == "addMember".uppercased() {
////                self.typeAddressMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
//            }
//        }
//        view.layoutIfNeeded()
////        let hh = bookingAddressFlow.hashValue
//    }
//    
//    private func getEnumCaseName(_ flow: BookingAddressFlow) -> String {
//        return String(describing: flow)
//    }
//    
//    private func setupFont() {
//        self.topTitleLbl.font  = AppFont.medium.size(20.0, familyName: familyClashDisplay)
//        self.typeAddrTitleLbl.font  = AppFont.regular.size(14.0, familyName: familyFunnelSans)
//        self.saveUpdateBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
//        self.addMemeberSaveNextBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
//        self.addMemeberSaveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
//        [
//            self.homeBtn.titleLabel,
//            self.officeBtn.titleLabel,
//            self.otherBtn.titleLabel
//        ].forEach({
//            $0?.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
//        })
//        
//        //-----------------Hint Label
//        [
//            buildingNumHintLbl,
//            streetNameHintLbl,
//            landmarkHintLbl,
//            apartmentNumLbl,
//            cityHintLbl,
//            countryHintLbl,
//        ].forEach({
//            $0.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
//            $0.text = nil
//        })
//        
//        //----------------------Text fields
//        [
//            buildingNumTxt,
//            streetNameTxt,
//            landmarkTxt,
//            apartmentTxt,
//            cityTxt,
//            countryTxt
//        ].forEach({[weak self] key in
//            guard let self = self, let key = key else {
//                return
//            }
//            key.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
//            key.delegate = self
//            key.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
//        })
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let location = touch.location(in: view)
//            if !self.popupMBV.frame.contains(location) {
//                      self.dismiss(animated: true, completion: nil)
//                  }else{
//                      print("tap at popup view.")
//                  }
//        }
//    }
//}
//
//
//extension BookingAddressViewController: UITextFieldDelegate{
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//    }
//    
//    @objc func textFieldDidChange(textField: UITextField) {
//        
//        if let hintLabel = self.getHintLbl(inputTxtField: textField) {
//            if let isEmptyTxt = textField.text?.isEmpty, !isEmptyTxt {
//                hintLabel.isHidden = false
//                hintLabel.text = self.hintTxtGet(inputLabel: hintLabel)
//            } else {
//                hintLabel.isHidden = true
//                hintLabel.text = nil
//            }
//        }
//    }
//    
//    func getHintLbl(inputTxtField: UITextField) -> UILabel? {
//        let textFieldsWithLabels: [UITextField: UILabel] = [
//            self.apartmentTxt: apartmentNumLbl,
//            self.buildingNumTxt: buildingNumHintLbl,
//            self.streetNameTxt: streetNameHintLbl,
//            self.landmarkTxt: landmarkHintLbl,
//            self.cityTxt: cityHintLbl,
//            self.countryTxt: countryHintLbl
//           ]
//        
//        return textFieldsWithLabels[inputTxtField]
//    }
//    
//    func hintTxtGet(inputLabel: UILabel) -> String {
//        let hintTxtAddAddress: [UILabel: String] = [
//            self.apartmentNumLbl: "Apartment Unit / Number",
//            self.buildingNumHintLbl: "Building / Tower Name",
//            self.streetNameHintLbl: "Street Name",
//            self.landmarkHintLbl: "Directions to reach (Optional)",
//            self.cityHintLbl: "City",
//            self.countryHintLbl: "Country",
//        ]
//        
//        let hintTxtAddMember: [UILabel: String] = [
//            self.buildingNumHintLbl: "Enter Full Name",
//            self.streetNameHintLbl: "Enter Age"
//        ]
//        
//        switch bookingAddressFlow {
//        case .addAddress, .editAddress:
//            return hintTxtAddAddress[inputLabel] ?? ""
//            
//        case .addMember:
//            return hintTxtAddMember[inputLabel] ?? ""
//        case .defaultBooing:
//            break
//        }
//        
//        return ""
////        return hintTxt[inputLabel] ?? ""
//    }
//}
//
//
////MARK: --------------EXTENSION FOR API
//extension BookingAddressViewController {
//    
////    private func getAddressListApi(){
////        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
////            guard let self = self, let getResultData = getResultData else { return  }
////
////            print("getResultData", getResultData)
////
////        })
////    }
//    
//    private func getCityListApi() {
//        TrainerVM.getCityApi(viewController: self, inputParms: [:], isShowLoader: false, completion: { [weak self] getResultData in
//            guard let self = self, let getResultData = getResultData else { return  }
//            print("getResultData", getResultData)
//            self.getAlltCityData = nil
//            self.getAlltCityData = getResultData.data
//        })
//    }
//    
//}
//
//// MARK: ------------ UIPopoverPresentationControllerDelegate
//extension BookingAddressViewController: UIPopoverPresentationControllerDelegate {
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .none  // Keeps it as a popover on iPhone instead of full-screen
//    }
//}
//
//
//// MARK: ------------------ADD MEMBER PARAMS
//struct AddMemberParams {
//    var name: String?
//    var age: String?
//    var gender: String?
//    var id: String?
//    
//    func getParams() -> [String:Any] {
//        var dictVar: [String:Any] =  [:]
//        
//        if let name = name { dictVar["name"] = name }
//        if let age = age { dictVar["age"] = age }
//        if let gender = gender { dictVar["gender"] = gender }
//        if let id = id { dictVar["id"] = id }
//        
//        return dictVar
//    }
}
