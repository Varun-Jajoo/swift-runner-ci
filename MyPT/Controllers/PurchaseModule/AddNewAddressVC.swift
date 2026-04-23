//
//  AddNewAddressVC.swift
//  MyPT
//
//  Created on 31/01/26.
//

import UIKit
import GooglePlaces
import IQKeyboardManagerSwift

class AddNewAddressVC: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var lblAddressLabel: UILabel!
    @IBOutlet weak var tfAddressLabel: UITextField!
    @IBOutlet weak var lblBuildingName: UILabel!
    @IBOutlet weak var lblAppartmentNumber: UILabel!
    @IBOutlet weak var tfAppratmentNumber: UITextField!
    @IBOutlet weak var tfBuildingName: UITextField!
    @IBOutlet weak var lblStreetName: UILabel!
    @IBOutlet weak var tfStreetName: UITextField!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfEmirate: UITextField!
    @IBOutlet weak var popupScrollV: UIScrollView!
    @IBOutlet weak var constPopUpHeight: NSLayoutConstraint!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var viewAddressLabel: UIView!
    @IBOutlet weak var viewBuildingName: UIView!
    @IBOutlet weak var viewAppartmentNumber: UIView!
    @IBOutlet weak var viewStreetName: UIView!
    @IBOutlet weak var viewCity: UIView!
    @IBOutlet weak var viewEmirate: UIView!
    
    var getAlltCityData: CityDataModel?
    var suggestedPlace: GMSPlace?
    var currentStreetName: String?
    var currentApartmentNumber: String?
    var newAddressAddedCallBack : ( () -> ())?
    var city_idStr: String?
    var country_idStr: String?
    var emirates_idStr: String?
    var getAlltCountryData: [CountryDataModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTxtField()
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        btnProceed.layer.cornerRadius = 10
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
//        self.getCityListApi()
        getEmiratesApi()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.isEnabled = false
        IQKeyboardManager.shared.resignOnTouchOutside = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let place = suggestedPlace {
            if let components = place.addressComponents {
                for component in components {
                    if component.types.contains("route") {
                        self.lblStreetName.isHidden = false
                        self.lblStreetName.text = hintTxtGet(inputLabel: self.lblStreetName)
                        self.tfStreetName.text = component.name
                    }
                    
                    if component.types.contains("subpremise") {
                        self.lblAppartmentNumber.isHidden = false
                        self.lblAppartmentNumber.text = hintTxtGet(inputLabel: self.lblAppartmentNumber)
                        self.tfAppratmentNumber.text = component.name
                    }
                    
                    //                        if component.types.contains("premise") {
                    //                            self.lblBuildingName.isHidden = false
                    //                            self.tfBuildingName.text = component.name
                    //                        }
                    
                    //                            if component.types.contains("locality") {
                    //                                self.lblCity.isHidden = false
                    //                                self.tfCity.text = component.name
                    //                            }
                }
            }
            if let name = place.name {
                self.lblBuildingName.isHidden = false
                self.lblBuildingName.text = hintTxtGet(inputLabel: self.lblBuildingName)
                self.tfBuildingName.text = name
            }
        }
        if let appartment = self.currentApartmentNumber {
            self.lblAppartmentNumber.isHidden = false
            self.lblAppartmentNumber.text = hintTxtGet(inputLabel: self.lblAppartmentNumber)
            self.tfAppratmentNumber.text = appartment
        }
        if let street = self.currentStreetName {
            self.lblStreetName.isHidden = false
            self.lblStreetName.text = hintTxtGet(inputLabel: self.lblStreetName)
            self.tfStreetName.text = street
        }
    }
    
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
    
    @IBAction func dropDownAction(_ sender: UIButton) {
        openDropDown(inputView: sender)
    }
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func proceedButtonAction(_ sender: UIButton) {
        
        if tfAppratmentNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || tfBuildingName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || tfAddressLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || tfStreetName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || tfCity.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            AlertHelper.shared.alertMesssage(view: self, title: "", message: "All Fields are compulsory")
            return
        }
        
        print("save and update btn..")
        
        let phoneNumber = ""
        let params:[String:Any] = [
            "building_name" : (self.tfAddressLabel.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "villa_name": (self.tfBuildingName.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "building_name": (self.tfBuildingName.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "street": (self.tfStreetName.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "city_id": (self.city_idStr ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "country_id": "231",
            "emirate_id": self.emirates_idStr,
            "area_name": (self.tfBuildingName.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
//            "landmark": (self.tfBuildingName.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            "type": "home",
            "mobile_no": "9876543210",
            "lat": self.suggestedPlace?.coordinate.latitude ?? "28.584125",
            "long": self.suggestedPlace?.coordinate.longitude ?? "77.2753162",
            "name": ""
        ]
   
        if TrainerVM.isValideAddres(inputParams: params) {
            print("api is called..")
           
            TrainerVM.addAddressApi(viewController: self, inputParams: params, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                
                print("Add Adrress successfully: ",getResultData)
                
                NotificationCenter.default.post(name: NSNotification.Name("UpdateAddress"), object: nil, userInfo: ["newValue": "True"])
                self.dismiss(animated: true, completion: {
                    self.newAddressAddedCallBack?()
                })
            })
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
          if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
              let keyboardHeight = keyboardFrame.height
            
//              switch bookingAddressFlow {
//              case .addAddress, .editAddress:
//                  print("add/Edit adress..")
//              case .addMember:
                  // Adjust the scroll view's content inset
//                  popupScrollV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
//                  popupScrollV.scrollIndicatorInsets = popupScrollV.contentInset
//                                    
//              constPopUpHeight.constant = keyboardHeight + view.frame.size.height * 0.2
//                  view.layoutIfNeeded()
                  
//              case .defaultBooing:
//                  break
//              }
              
          }
      }
      
      @objc func keyboardWillHide(notification: Notification) {
          // Reset the scroll view's content inset
          popupScrollV.contentInset = .zero
          popupScrollV.scrollIndicatorInsets = .zero
      }
    
    private func setupTxtField(){
        //----------------------Text fields
        
        [
            self.lblAddressLabel,
            self.lblAppartmentNumber,
            self.lblBuildingName,
            self.lblStreetName,
            self.lblCity,
        ].forEach({
            $0?.isHidden = true
        })
        
        [
            tfAppratmentNumber: "Apartment Unit / Number",
            tfBuildingName: "Building / Tower Name",
            tfStreetName: "Street Name",
            tfCity: "Emirates",
            tfEmirate: "Emirates",
            tfAddressLabel: "Address Label"
        ].forEach({[weak self] (key, value) in
            guard let self = self, let key = key else {
                return
            }
            
            key.placeholderSet(placeHolder: value, color: UIColor.txtDarkGray)
            key.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            key.delegate = self
            key.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        })
        
        [
            self.viewAppartmentNumber,
            self.viewBuildingName,
            self.viewStreetName,
            self.viewCity,
            self.viewEmirate,
            self.viewStreetName,
            self.viewAddressLabel
        ].forEach({
            $0?.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#2C2C2C"), cornerRadious: 12.0)
            $0?.backgroundColor = UIColor(hex: "#141514")
        })

    }
    
    private func setViewBorder() {
        
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
            self.tfAppratmentNumber: lblAppartmentNumber,
            self.tfBuildingName: lblBuildingName,
            self.tfStreetName: lblStreetName,
            self.tfAddressLabel: lblAddressLabel,
            self.tfCity: lblCity,
           ]
        
        return textFieldsWithLabels[inputTxtField]
    }
    
    func hintTxtGet(inputLabel: UILabel) -> String {
        let hintTxtAddAddress: [UILabel: String] = [
            self.lblAddressLabel: "Address Label",
            self.lblBuildingName: "Building / Tower Name",
            self.lblStreetName: "Street Name",
//            self.lblCity: "City",
            self.lblCity: "",
            self.lblAppartmentNumber: "Apartment Unit / Number"
        ]
        return hintTxtAddAddress[inputLabel] ?? ""
        }
    
    private func openDropDown(inputView: UIView){
        let popupVC:CityDropDownViewController = CityDropDownViewController.instantiate(appStoryboard: .booking)
        popupVC.modalPresentationStyle = .popover
        popupVC.getAlltCityData = nil
        popupVC.getAlltCityData = self.getAlltCityData
        popupVC.cityData?.removeAll()
        popupVC.cityData?.append(contentsOf: self.getAlltCityData?.cities ?? [])
        
        popupVC.sentBackData = { [weak self] getCityName , getId, getCountryName, getCountryId, emiratesName, emiratesId in
            guard let self = self else { return  }
            print("name", getCityName as Any, "id", getId as Any)
            self.tfCity.text = emiratesName
//            self.countrySideTxt.text = getCountryName
//            self.tfEmirate.text = getCountryName
//            self.countryTxt.text = getCountryName
//            self.city_idStr = "\(getId ?? 0)"
            self.emirates_idStr = "\(emiratesId ?? 0)"
            self.country_idStr = "231"
//            self.country_idStr = "\(getCountryId ?? 0)"
            
            if let city = self.tfCity.text, !city.isEmpty{
                self.lblCity.isHidden = false
//                self.lblCity.text = "City"
                self.lblCity.text = ""
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
}
