//
//  AddNewAddressViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/08/25.
//

import UIKit

class AddNewAddressViewController: CommonViewController {

    //MARK: ---------------- VARIABLE
    var getAlltCityData: CityDataModel?
    var addressData:AddressDataModel?
    var idStr: String?
    var city_idStr: String?
    var country_idStr: String?
    var typeStr: String?
    var inputLat: String?
    var inputLong: String?
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var contactInfoMBV: UIView!
    @IBOutlet weak var fullNameMBV: UIView!
    @IBOutlet weak var contactNumMBV: UIView!
    @IBOutlet weak var addressInfoMBV: UIView!
    @IBOutlet weak var buildingNameMBV: UIView!
    @IBOutlet weak var streetNameMBV: UIView!
    @IBOutlet weak var landMarkMBV: UIView!
    @IBOutlet weak var mobileNumMBV: UIView!
    @IBOutlet weak var cityMBV: UIView!
    @IBOutlet weak var counrtyMBV: UIView!
    @IBOutlet weak var typeAddressMBV: UIView!
    @IBOutlet weak var saveAddrMBV: UIView!
    @IBOutlet weak var contactInfoLbl: UILabel!
    @IBOutlet weak var addrInfoLbl: UILabel!
    @IBOutlet weak var fullNameHintLbl: UILabel!
    @IBOutlet weak var contactNumHintLbl: UILabel!
    @IBOutlet weak var buildingNumHintLbl: UILabel!
    @IBOutlet weak var streetNameHintLbl: UILabel!
    @IBOutlet weak var landmarkHintLbl: UILabel!
    @IBOutlet weak var mobileHintLbl: UILabel!
    @IBOutlet weak var cityHintLbl: UILabel!
    @IBOutlet weak var countryHintLbl: UILabel!
    @IBOutlet weak var typeAddrTitleLbl: UILabel!
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var contactNumTxt: UITextField!
    @IBOutlet weak var buildingNumTxt: UITextField!
    @IBOutlet weak var streetNameTxt: UITextField!
    @IBOutlet weak var landmarkTxt: UITextField!
    @IBOutlet weak var mobileTxt: UITextField!
    @IBOutlet weak var cityTxt: UITextField!
    @IBOutlet weak var countryTxt: UITextField!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var officeBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var defaultAddrBtn: UIButton!
    @IBOutlet weak var saveAddrBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.countryTxt.isUserInteractionEnabled = false
        self.setupUI()
        self.setupFont()
        self.setupTxtField()
        self.mobileNumMBV.isHidden = true
        self.setInputData()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCityListApi()
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Add Address"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        print("notification", notification)
        self.customBlurViewRemove(viewShow: self.view)
    }
    
    private func setInputData(){
        //----------------------Text fields
        self.setupTxtField()
        
        //-----------------setup input data
        if let addressData = addressData {
            self.setInputData(data: addressData)
            self.inputLat = "\(addressData.lat?.value ?? "0.0")"
            self.inputLong = "\(addressData.long?.value ?? "0.0")"
            
        }
    }
    
    //--------------------SETUP INPUT DATA
    private func setInputData(data: AddressDataModel){
        var fullNameStr:String = ""
        var contactNumStr: String = ""
        
        if let userData = appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self), let userName = userData.user?.name {
            fullNameStr = userName
            contactNumStr = userData.user?.phone ?? ""
        }
        
        //-------------------
        let textFields: [(UITextField, String)] = [
            (fullNameTxt, fullNameStr),
            (contactNumTxt, contactNumStr),
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
    
    enum AddAddrBtnTag: Int {
        case selectCity = 1401, selectCountry, home, office, other, markDefault,saveAddr
    }
    
    @IBAction func commonAddAddrBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case AddAddrBtnTag.selectCity.rawValue:
            print("Select city.")
            break
        case AddAddrBtnTag.selectCountry.rawValue:
            print("Select country...")
            break
        case AddAddrBtnTag.home.rawValue:
            print("Home address.")
            self.setAddrType(sender: self.homeBtn)
            break
        case AddAddrBtnTag.office.rawValue:
            print("Office address.")
            self.setAddrType(sender: self.officeBtn)
            break
        case AddAddrBtnTag.other.rawValue:
            print("other address.")
            self.setAddrType(sender: self.otherBtn)
            break
        case AddAddrBtnTag.markDefault.rawValue:
            print("Mark Default Address....")
            sender.isSelected = !sender.isSelected
            break
            
        case AddAddrBtnTag.saveAddr.rawValue:
            let contactNumber = (self.contactNumTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "-", with: "")
            
            let params:[String:Any] = [
                "id" : (self.idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                "building_name": (self.buildingNumTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                "street": (self.streetNameTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                "city_id": (self.city_idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                "country_id": (self.country_idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                "landmark": (self.landmarkTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                "type": (self.typeStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
                "mobile_no": contactNumber,
                "lat": self.inputLat ?? "28.584125",
                "long": self.inputLong ?? "77.2753162",
                "name": (self.fullNameTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            ]
            
            print("params: ", params)
            
            //------------------******* Validations
            if let building_Name =  params["name"] as? String, building_Name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.enter_full_name,actions: ["Ok"])
            }
            else if let mobile_no =  (params["mobile_no"] as? String), !mobile_no.isValidPhone(phone: mobile_no) || mobile_no.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                AlertHelper.shared.showCustomeAlert(message: AppAlertStrings.enter_phone,actions: ["Ok"])
            }else if TrainerVM.isValideAddres(inputParams: params) {
                TrainerVM.addAddressApi(viewController: self, inputParams: params, completion: { [weak self] getResultData in
                    guard let self = self, let getResultData = getResultData else { return  }
                    print("Add Adrress successfully: ",getResultData)
                    NotificationCenter.default.post(name: NSNotification.Name("presenteDeliveryAddress"), object: "new address")
                    self.navigationController?.popToViewController(ofClass: BookingDetailsViewController.self, animated: true)
                })
            }
            
        default:
            print("None......")
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
    
    private func setupUI(){
        DispatchQueue.main.async {
          
            self.saveAddrBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.typeAddressMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.txtDarkGray, cornerRadious: 8.0)
          
            [
                self.fullNameMBV,
                self.contactNumMBV,
                self.buildingNameMBV,
                self.streetNameMBV,
                self.landMarkMBV,
                self.mobileNumMBV,
                self.cityMBV,
                self.counrtyMBV
            ].forEach({
                $0.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0)
                $0.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.txtDarkGray, cornerRadious: 8.0)
            })
        }
        view.layoutIfNeeded()
    }
    
    private func setupFont(){
//        self.contactInfoLbl.font  = AppFont.semibold.size(16.0, familyName: familyManrope)
//        self.addrInfoLbl.font  = AppFont.semibold.size(16.0, familyName: familyManrope)
//        self.typeAddrTitleLbl.font  = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.saveAddrBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        
        [
            self.homeBtn.titleLabel,
            self.officeBtn.titleLabel,
            self.otherBtn.titleLabel,
            self.defaultAddrBtn.titleLabel
        ].forEach({
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
        //-----------------Hint Label
        [
            fullNameHintLbl,
            contactNumHintLbl,
            buildingNumHintLbl,
            streetNameHintLbl,
            landmarkHintLbl,
            mobileHintLbl,
            cityHintLbl,
            countryHintLbl,
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0.font = AppFont.medium.size(10.0, familyName: familyManrope)
            $0.text = nil
        })
        
        //----------------------Text fields
        fullNameTxt.tag = 101
        addRightPaddingImageWithTap(to: fullNameTxt, image: UIImage(named: "ic_curve_edit"), paddingWidth: 25.0)
        cityTxt.tag = 102
        addRightPaddingImageWithTap(to: cityTxt, image: UIImage(named: "ic_arrow_down"), paddingWidth: 25.0)
        [
            fullNameTxt,
            contactNumTxt,
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
        
        [
            contactInfoLbl,
            addrInfoLbl,
            typeAddrTitleLbl,
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
    }
    
    private func setupTxtField(){
        
        //----------------------Text fields
        [
            fullNameTxt: "Full name",
            contactNumTxt: "Contact Number",
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
        popupVC.getAlltCityData = nil
        popupVC.getAlltCityData = self.getAlltCityData
        popupVC.cityData?.removeAll()
        popupVC.cityData?.append(contentsOf: self.getAlltCityData?.cities ?? [])
        
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
    
        popupVC.view.backgroundColor = UIColor.mainBg
  
         if let popoverController = popupVC.popoverPresentationController {
             popoverController.sourceView = inputView
             popoverController.sourceRect = inputView.bounds
             popoverController.permittedArrowDirections = .any
             popoverController.delegate = self
             popoverController.backgroundColor = UIColor.mainBg
         }
        popupVC.preferredContentSize = CGSize(width: self.view.frame.size.width - 40, height: 350)

        present(popupVC, animated: true)
    }
    
    func addRightPaddingImageWithTap(to textField: UITextField, image: UIImage?, paddingWidth: CGFloat? = 25.0) {
        guard let paddingWidth = paddingWidth else { return }
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: textField.frame.height))

        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .center
        imageView.frame = CGRect(x: (paddingWidth - 24) / 2, y: (textField.frame.height - 24) / 2, width: 24, height: 24)

        // Add tap gesture and assign the textField's tag to the imageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightImageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
        imageView.tag = textField.tag  // Pass tag via imageView

        paddingView.addSubview(imageView)
        textField.rightView = paddingView
        textField.rightViewMode = .always
    }
    
    @objc func rightImageTapped(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view else { return }

        switch imageView.tag {
        case 101:
            print("Name TextField......")
            self.fullNameTxt.becomeFirstResponder()
            break
        case 102:
            self.cityTxt.becomeFirstResponder()
            break
        default:
            break
        }
        
    }

}

extension AddNewAddressViewController: UITextFieldDelegate{

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
        }else if textField == self.contactNumTxt {
            // Allow only numeric input
            let allowedCharacterSet = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            if !allowedCharacterSet.isSuperset(of: characterSet) {
                return false // Disallow non-numeric input
            }
            
            // Check the total length after the proposed change
            if let currentText = textField.text, let stringRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
               
                if let textFieldMobile = self.contactNumTxt.text, string != "" {
                    if textFieldMobile.count == 3 || textFieldMobile.count == 7 {
                        self.contactNumTxt.text = textFieldMobile.text + "-"
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
            self.fullNameTxt: fullNameHintLbl,
            self.contactNumTxt: contactNumHintLbl,
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
            self.fullNameHintLbl: "Full name",
            self.contactNumHintLbl: "Contact Number",
            self.buildingNumHintLbl: "Building/Villa Name or Number",
            self.streetNameHintLbl: "Street Name & Number",
            self.landmarkHintLbl: "Landmark (Optional)",
            self.mobileHintLbl: "Mobile",
            self.cityHintLbl: "City",
            self.countryHintLbl: "Country",
        ]
        return hintTxtAddAddress[inputLabel] ?? ""
    }
    
    /*
    //"Flat no / Building Name"
     "Locality / Street / Area"
     */
}

// MARK: ------------ UIPopoverPresentationControllerDelegate
extension AddNewAddressViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none  // Keeps it as a popover on iPhone instead of full-screen
    }
}


extension AddNewAddressViewController{
    private func getCityListApi(){
        TrainerVM.getCityApi(viewController: self, inputParms: [:], isShowLoader: false, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("getResultData", getResultData)
            self.getAlltCityData = nil
            self.getAlltCityData = getResultData.data
        })
    }
}
