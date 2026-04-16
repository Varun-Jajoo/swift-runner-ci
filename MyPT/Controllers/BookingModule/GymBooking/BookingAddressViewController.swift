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
    func editReloadData(isReload: Bool?)
}

class BookingAddressViewController: UIViewController {

    //MARK: ------------VARIABLE
    var addMaxMember:Int?
    var addedMember:Int?
    private var currentAddMember:Int = 0
    
    var hintTxt:[String] = []
    var bookingAddressFlow: BookingAddressFlow = .defaultBooing
    var delegate:BookingAddressProtocol?
    var addMemberDelegate: AddMemberProtocol?
    var getAlltCityData: CityDataModel?
    var getAlltCountryData: [CountryDataModel]?
    
    var idStr: String?
    var city_idStr: String?
    var country_idStr: String?
    var emirates_idStr: String?
    var typeStr: String? = "home"
    var inputLat: String?
    var inputLong: String?
    var addressData:AddressDataModel?
    var navCtrnl:UINavigationController?
    var addMemberData:MemberModel?
    var isFromHome:Bool?
    var isFreeAssessmentSelected: Bool?
//    var inputParam: DetailsParam?
    

    //MARK: --------------IBOUTLET
    @IBOutlet weak var popupScrollV: UIScrollView!
    @IBOutlet weak var popupMBV: UIView!
    @IBOutlet weak var buildingNumMBV: UIView!
    @IBOutlet weak var streetNameMBV: UIView!
    @IBOutlet weak var landmarkMBV: UIView!
    @IBOutlet weak var apartmentMBV: UIView!
    @IBOutlet weak var cityMBV: UIView!
    @IBOutlet weak var countryMBV: UIView!
    @IBOutlet weak var typeAddressMBV: UIView!
    @IBOutlet weak var saveAddMemberMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var buildingNumHintLbl: UILabel!
    @IBOutlet weak var streetNameHintLbl: UILabel!
    @IBOutlet weak var landmarkHintLbl: UILabel!
    @IBOutlet weak var apartmentNumLbl: UILabel!
    @IBOutlet weak var cityHintLbl: UILabel!
    @IBOutlet weak var countryHintLbl: UILabel!
    @IBOutlet weak var typeAddrTitleLbl: UILabel!
    @IBOutlet weak var buildingNumTxt: UITextField!
    @IBOutlet weak var streetNameTxt: UITextField!
    @IBOutlet weak var landmarkTxt: UITextField!
    @IBOutlet weak var apartmentTxt: UITextField!
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
    @IBOutlet weak var countrySideMBV: UIView!
    @IBOutlet weak var countrySideTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentAddMember = self.addedMember ?? 0
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.getCityListApi()
        self.getEmiratesApi()
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
           
            print("First time currentAddMember", currentAddMember)
            
            if let addMaxMember = addMaxMember,  currentAddMember < addMaxMember {
                
                let memberParams = AddMemberParams(name: self.buildingNumTxt.text, age: self.streetNameTxt.text, gender: self.typeStr ?? "", id: "\(addMemberData?.id ?? -1)")
                
                //id is getting then meber will be edit ohterwise new member added
                if CreatePackageVM.isValidMember(inputParams: memberParams) {
                    currentAddMember += 1
                    print("currentAddMember", currentAddMember)
                    CreatePackageVM.addMemberApi(viewController: self, inputParams: memberParams.getParams(), completion: { [weak self] getResultData in
                        
                        self?.view.endEditing(true)
                        self?.addMemberDelegate?.editReloadData(isReload: true)
                        self?.addMemberData?.id = nil
                        self?.typeStr = nil
                        self?.setAddrType(sender: UIButton())
                        self?.buildingNumTxt.text = nil
                        self?.streetNameTxt.text = nil
                        
                        guard let self = self, let getResultData = getResultData else { return  }
                        
                        if getResultData.status == true{
                            if currentAddMember == addMaxMember {
                                self.dismiss(animated: true, completion: {
                                    self.addMemberDelegate?.memberAdd(isDismiss: true)
                                })
                            }
                        }
                    })
                }
            }else{
                print("max number member added.")
            }
            
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
        
        let phoneNumber = (self.apartmentTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "-", with: "")
        let params:[String:Any] = [
            "id" : (self.idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "building_name": phoneNumber,
            "villa_name": (self.buildingNumTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "street": (self.streetNameTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "city_id": (self.city_idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "country_id": "231",
            "emirate_id": self.emirates_idStr,
//            "landmark": (self.landmarkTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "area_name": (self.landmarkTxt.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "type": (self.typeStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "mobile_no": "9876543210",
            "lat": self.inputLat ?? "28.584125",
            "long": self.inputLong ?? "77.2753162",
//            "name": ""
        ]
   
        if TrainerVM.isValideAddres(inputParams: params) {
            print("api is called..")
           
            TrainerVM.addAddressApi(viewController: self, inputParams: params, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                
                print("Add Adrress successfully: ",getResultData)
                self.addressData = getResultData.data?.first
                self.inputLat = getResultData.data?.first?.lat?.value
                self.inputLong = getResultData.data?.first?.long?.value
                NotificationCenter.default.post(name: NSNotification.Name("UpdateAddress"), object: nil, userInfo: ["newValue": "True"])
                
                self.delegate?.onDismiss(isDismiss: true)
                self.dismiss(animated: true, completion: {
//                    self.navCtrnl?.popToViewController(ofClass: SelectYourLocationViewController.self, animated: true)
                    self.goToNextVC()
                })
            })
        }
        
    }
    
    enum btnTag: Int {
    case dismiss = 401, home, work, other, selectCity, selectCounrty
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        switch sender.tag {
        case btnTag.dismiss.rawValue:
            self.dismiss(animated: true, completion: nil)
        case btnTag.home.rawValue, btnTag.work.rawValue, btnTag.other.rawValue:
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
    private func setInputData(data: AddressDataModel) {
        let textFields: [(UITextField, String)] = [
            (buildingNumTxt, data.building_name?.value ?? ""),
            (streetNameTxt, data.street?.value ?? ""),
            (landmarkTxt, data.landmark ?? ""),
            (apartmentTxt, data.mobile_no?.value ?? ""),
//            (cityTxt, data.city_name ?? ""),
//            (countrySideTxt, data.country_name ?? "")
//            (countryTxt, data.country_name ?? "")
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
            } else if type.uppercased() == "Work".uppercased() {
                self.officeBtn.isSelected = true
            } else if type.uppercased() == "Others".uppercased() {
                self.otherBtn.isSelected = true
            }
        }
    }
    
    //------------------SETUP FLOW ADDRESS
    private func setFlowAddress() {
        
        switch bookingAddressFlow {
        case .addAddress:
            popupMBVHeightConstrnt.constant = view.frame.size.height * 0.8
            [
                landmarkMBV,
                cityMBV,
//                countrySideMBV,
//                countryMBV,
                typeAddressMBV,
                saveUpdateBtn
            ].forEach({
                $0?.isHidden = false
            })
            
            self.countryTxt.isUserInteractionEnabled = false
            self.selectCountryBtn.isHidden = true
            saveAddMemberMBV.isHidden = true
            saveUpdateBtnHeightConstrnt.constant = 48.0
            saveUpdateBtnTopConstrnt.constant = 20.0
            saveUpdateBtnBottomConstrnt.constant = 20.0
            
            self.topTitleLbl.text = "Enter your full address details"
            self.homeBtn.setTitle("HOME", for: .normal)
            self.officeBtn.setTitle("WORK", for: .normal)
            self.otherBtn.setTitle("OTHER", for: .normal)
            
            //----------------------Text fields
            self.setupTxtField()
            
            //-----------------setup input data
            if let addressData = addressData {
                self.setInputData(data: addressData)
                self.inputLat = "\(addressData.lat?.value ?? "0.0")"
                self.inputLong = "\(addressData.long?.value ?? "0.0")"
                
            }
            
            self.setupTxtField()
            
        case .editAddress:
            self.topTitleLbl.text = "Edit Address"
            if let addressData = addressData {
                self.idStr = addressData.id?.value
                self.setInputData(data: addressData)
                //-----------------setup input data
                self.inputLat = "\(addressData.lat?.value ?? "0.0")"
                self.inputLong = "\(addressData.long?.value ?? "0.0")"
            }
            
            self.setupTxtField()
            
            popupMBVHeightConstrnt.constant = view.frame.size.height * 0.8
            
            [
                landmarkMBV,
                cityMBV,
                countrySideMBV,
//                countryMBV,
                typeAddressMBV,
                saveUpdateBtn
            ].forEach({
                $0?.isHidden = false
            })
            
            self.countryTxt.isUserInteractionEnabled = false
            self.selectCountryBtn.isHidden = true
            saveAddMemberMBV.isHidden = true
            saveUpdateBtnHeightConstrnt.constant = 48.0
            saveUpdateBtnTopConstrnt.constant = 20.0
            saveUpdateBtnBottomConstrnt.constant = 20.0
            
            self.homeBtn.setTitle("HOME", for: .normal)
            self.officeBtn.setTitle("WORK", for: .normal)
            self.otherBtn.setTitle("OTHER", for: .normal)
                        
        case .addMember:
            
            popupMBVHeightConstrnt.constant = view.frame.size.height * 0.6
            
//            DispatchQueue.main.async {
//                self.typeAddressMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
//            }
            
            [
                apartmentMBV,
                landmarkMBV,
                cityMBV,
                countrySideMBV,
//                countryMBV,
//                mobilMBV,
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
//            self.streetNameTxt.keyboardType = .decimalPad
            
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
    
    private func goToNextVC() {
        if isFreeAssessmentSelected ?? false {
//            if inputType == "home" { // For Home
                let vc: TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
                vc.flowSlot = .bookTrainerHomeWorkout
                vc.isFromHome = true
                vc.inputType = "home"
                vc.inputLat = Double(self.inputLat ?? "0.0")
                vc.inputLong = Double(self.inputLong ?? "0.0")
                vc.inputParam = DetailsParam(
                    type: "home",
                    long: self.inputLong ?? "0.0",
                    lat: self.inputLat ?? "0.0",
                    addressId: self.addressData?.id?.value,
                    addressData: self.addressData,
                    isFreeAssessmentSelected: isFreeAssessmentSelected
                )
            self.navCtrnl?.pushViewController(vc, animated: true)
//            } else { // For Gym
//                let vc: GymWorkoutViewController =
//                GymWorkoutViewController.instantiate(appStoryboard: .booking)
//                vc.flowGymwork = .bookTrainerGymWorkout
//                vc.inputParam = DetailsParam(
//                    type: "gym",
//                    long: self.getAddressData?.long?.value ?? "0.0",
//                    lat: self.getAddressData?.lat?.value ?? "0.0",
//                    addressId: self.getAddressData?.id?.value,
//                    addressData: self.getAddressData,
//                    isFreeAssessmentSelected: isFreeAssessmentSelected
//                )
//                vc.inputType = "gym"
//                vc.inputLat = Double(self.inputLat ?? "0.0")
//                vc.inputLong = Double(self.inputLong ?? "0.0")
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
        } else {
            let vc:CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
            let param = DetailsParam(type: "home", long: self.inputLong, lat: self.inputLat, addressData: self.addressData)
            vc.inputParam = param
            vc.inputType = "home"
            vc.inputLat = Double(self.inputLat ?? "0.0")
            vc.inputLong = Double(self.inputLong ?? "0.0")
            self.navCtrnl?.pushViewController(vc, animated: true)
        }
    }
    
    //------------------
    private func setAddrType(sender: UIButton) {
        [
            self.homeBtn,
            self.officeBtn,
            self.otherBtn,
        ].forEach({ [weak self] btn in
       
            guard let self = self, let btn = btn else { return }
            
            if btn.tag == sender.tag {
//                btn.isSelected = true
                btn.backgroundColor = UIColor(hex: "#1B1D13")
                btn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#6C7627"), cornerRadious: 8.0)
                self.typeStr = (btn.titleLabel?.text)?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
//                btn.isSelected = false
                btn.backgroundColor = UIColor(hex: "#101113")
                btn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#28292B"), cornerRadious: 8.0)
            }
        })
    }
    
    private func setupTxtField(){
        //----------------------Text fields
        [
            apartmentTxt: "Apartment / Villa Number",
            buildingNumTxt: "Building Name / Villa Name",
            streetNameTxt: "Street Name (Optional)",
            landmarkTxt: "Area / Community Name",
            cityTxt: "Emirate",
            countryTxt: "Emirates"
        ].forEach({[weak self] (key, value) in
            guard let self = self, let key = key else {
                return
            }
            
            key.placeholderSet(placeHolder: value, color: UIColor.txtDarkGray)
            key.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            key.delegate = self
            key.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        })
    }
    
    //MARK: -------------FOR DROP DOWN
    private func openDropDown(inputView: UIView){
        let popupVC: CityDropDownViewController = CityDropDownViewController.instantiate(appStoryboard: .booking)
        popupVC.modalPresentationStyle = .popover
//        popupVC.getAlltCityData = nil
//        popupVC.getAlltCityData = self.getAlltCityData
        popupVC.getAlltCountryData = self.getAlltCountryData
//        popupVC.cityData?.removeAll()
//        popupVC.cityData?.append(contentsOf: self.getAlltCityData?.cities ?? [])

        popupVC.sentBackData = { [weak self] getCityName , getId, getCountryName, getCountryId, emiratesName, emiratesId in
            guard let self = self else { return  }
            print("name", getCityName as Any, "id", getId as Any)
            self.cityTxt.text = emiratesName
//            self.countrySideTxt.text = getCountryName
//            self.countryTxt.text = getCountryName
//            self.city_idStr = "\(emiratesId ?? 0)"
            self.emirates_idStr = "\(emiratesId ?? 0)"
            self.country_idStr = "231"
//            self.country_idStr = "\(getCountryId ?? 0)"
            
            if let city = self.cityTxt.text, !city.isEmpty {
                self.cityHintLbl.isHidden = false
                self.cityHintLbl.text = "City"
            }
//            if let country = self.countryTxt.text, !country.isEmpty {
//                self.countryHintLbl.isHidden = false
//                self.countryHintLbl.text = "Country"
//            }
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

    private func setupUI() {
        DispatchQueue.main.async {
            self.popupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.popupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.saveUpdateBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.addMemeberSaveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.homeBtn.backgroundColor = UIColor(hex: "#1B1D13")
            self.homeBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#6C7627"), cornerRadious: 8.0)
            self.officeBtn.backgroundColor = UIColor(hex: "#101113")
            self.officeBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#28292B"), cornerRadious: 8.0)
            self.otherBtn.backgroundColor = UIColor(hex: "#101113")
            self.otherBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#28292B"), cornerRadious: 8.0)
            [
                self.apartmentMBV,
                self.buildingNumMBV,
                self.streetNameMBV,
                self.landmarkMBV,
//                self.mobilMBV,
                self.cityMBV,
                self.countrySideMBV,
//                self.countryMBV,
                self.addMemeberSaveNextBtn
            ].forEach({
                $0?.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#2C2C2C"), cornerRadious: 12.0)
                $0?.backgroundColor = UIColor(hex: "#141514")
            })
            
            //---------------------------**************
            if self.getEnumCaseName(self.bookingAddressFlow).uppercased() == "addMember".uppercased() {
//                self.typeAddressMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
        }
        view.layoutIfNeeded()
//        let hh = bookingAddressFlow.hashValue
    }
    
    private func getEnumCaseName(_ flow: BookingAddressFlow) -> String {
        return String(describing: flow)
    }
    
    private func setupFont() {
        self.topTitleLbl.font  = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.typeAddrTitleLbl.font  = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        self.saveUpdateBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.addMemeberSaveNextBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.addMemeberSaveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        [
            self.homeBtn.titleLabel,
            self.officeBtn.titleLabel,
            self.otherBtn.titleLabel
        ].forEach({
            $0?.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        })
        
        //-----------------Hint Label
        [
            buildingNumHintLbl,
            streetNameHintLbl,
            landmarkHintLbl,
            apartmentNumLbl,
            cityHintLbl,
            countryHintLbl,
        ].forEach({
            $0.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
            $0.text = nil
        })
        
        //----------------------Text fields
        [
            buildingNumTxt,
            streetNameTxt,
            landmarkTxt,
            apartmentTxt,
            cityTxt,
            countryTxt
        ].forEach({[weak self] key in
            guard let self = self, let key = key else {
                return
            }
            key.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
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
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        if textField == self.apartmentTxt {
//            // Allow only numeric input
//            let allowedCharacterSet = CharacterSet.decimalDigits
//            let characterSet = CharacterSet(charactersIn: string)
//
//            if !allowedCharacterSet.isSuperset(of: characterSet) {
//                return false // Disallow non-numeric input
//            }
//
//            // Check the total length after the proposed change
//            if let currentText = textField.text, let stringRange = Range(range, in: currentText) {
//                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
//
//                if let textFieldMobile = self.mobileTxt.text, string != "" {
//                    if textFieldMobile.count == 3 || textFieldMobile.count == 7 {
//                        self.mobileTxt.text = textFieldMobile.text + "-"
//                    }
//                }
//
//                return updatedText.count <= 12 // Allow input only if it results in 10 or fewer digits
//            }
//        }
//
//        return true
//    }
    
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
            self.apartmentTxt: apartmentNumLbl,
            self.buildingNumTxt: buildingNumHintLbl,
            self.streetNameTxt: streetNameHintLbl,
            self.landmarkTxt: landmarkHintLbl,
            self.cityTxt: cityHintLbl,
            self.countryTxt: countryHintLbl
           ]
        
        return textFieldsWithLabels[inputTxtField]
    }
    
    func hintTxtGet(inputLabel: UILabel) -> String {
        let hintTxtAddAddress: [UILabel: String] = [
            self.apartmentNumLbl: "Apartment / Villa Number",
            self.buildingNumHintLbl: "Building Name / Villa Name",
            self.streetNameHintLbl: "Street Name (Optional)",
            self.landmarkHintLbl: "Area / Community Name",
            self.cityHintLbl: "Emirate",
            self.countryHintLbl: "Emirate",
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
extension BookingAddressViewController {
    
//    private func getAddressListApi(){
//        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
//            guard let self = self, let getResultData = getResultData else { return  }
//
//            print("getResultData", getResultData)
//
//        })
//    }
    
    private func getCityListApi() {
        TrainerVM.getCityApi(viewController: self, inputParms: [:], isShowLoader: false, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("getResultData", getResultData)
            self.getAlltCityData = nil
            self.getAlltCityData = getResultData.data
        })
    }
    
    private func getEmiratesApi() {
        TrainerVM.getEmiratesApi(viewController: self, inputParms: [:], isShowLoader: false, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("getResultData", getResultData)
            self.getAlltCountryData = nil
            self.getAlltCountryData = getResultData.data
        })
    }
}

// MARK: ------------ UIPopoverPresentationControllerDelegate
extension BookingAddressViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none  // Keeps it as a popover on iPhone instead of full-screen
    }
}


// MARK: ------------------ADD MEMBER PARAMS
struct AddMemberParams {
    var name: String?
    var age: String?
    var gender: String?
    var id: String?
    var isGroup : Bool?
    var isBuddy : Bool?
    
    func getParams() -> [String:Any] {
        var dictVar: [String:Any] =  [:]
        
        if let name = name { dictVar["name"] = name }
        if let age = age { dictVar["age"] = age }
        if let gender = gender { dictVar["gender"] = gender }
        if let id = id { dictVar["id"] = id }
        if let isGroup = isGroup { dictVar["is_group"] = isGroup }
        if let isBuddy = isBuddy { dictVar["is_buddy"] = isBuddy }
        
        return dictVar
    }
}
