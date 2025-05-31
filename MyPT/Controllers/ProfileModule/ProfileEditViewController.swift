//
//  ProfileEditViewController.swift
//  MyPT
//
//  Created by techsaga corp on 19/05/25.
//

import UIKit

//MARK: ------------ SECTION MODEL
struct EditSectionModel {
    let title: String?
    var items: [[String:Any]]?
}

class ProfileEditViewController: CommonViewController {

//    var editData: [[String:Any]]? = []
    
    var editData:[EditSectionModel]?

    
    @IBOutlet weak var profileHeaderImgView: UIImageView!
    @IBOutlet weak var userNameTopConstrnt: NSLayoutConstraint!
    @IBOutlet weak var userNameMBV: UIView!
    @IBOutlet weak var userProfileImgView: UIImageView!
    @IBOutlet weak var profileEditImgView: UIImageView!
    @IBOutlet weak var headerEditBtn: UIButton!
    @IBOutlet weak var personalInfoMBV: UIView!
    @IBOutlet weak var addrInfoMBV: UIView!
    @IBOutlet weak var personalTitleLbl: UILabel!
    @IBOutlet weak var fullNameMBV: UIView!
    @IBOutlet weak var emailAddressMBV: UIView!
    @IBOutlet weak var mobileMBV: UIView!
    @IBOutlet weak var dobMBV: UIView!
    @IBOutlet weak var genderMBV: UIView!
    @IBOutlet weak var addrInfoTitleLbl: UILabel!
    @IBOutlet weak var LocationMBV: UIView!
    @IBOutlet weak var addressMBV: UIView!
    @IBOutlet weak var postalCodeMBV: UIView!
    @IBOutlet weak var countryMBV: UIView!
    @IBOutlet weak var stateMBV: UIView!
    @IBOutlet weak var cityMBV: UIView!
    @IBOutlet weak var fullNameHintLbl: UILabel!
    @IBOutlet weak var fullNameTxtField: UITextField!
    @IBOutlet weak var emailHintLbl: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var mobilHintLbl: UILabel!
    @IBOutlet weak var mobileNumTxtField: UITextField!
    @IBOutlet weak var dobHintLbl: UILabel!
    @IBOutlet weak var dobTxtField: UITextField!
    @IBOutlet weak var genderHintLbl: UILabel!
    @IBOutlet weak var genderTxtField: UITextField!
    @IBOutlet weak var locHintLbl: UILabel!
    @IBOutlet weak var locTxtField: UITextField!
    @IBOutlet weak var addressHintLbl: UILabel!
    @IBOutlet weak var addressTxtField: UITextField!
    @IBOutlet weak var postalCodeHintLbl: UILabel!
    @IBOutlet weak var postalCodeTxtField: UITextField!
    @IBOutlet weak var countryHintLbl: UILabel!
    @IBOutlet weak var countryTxtField: UITextField!
    @IBOutlet weak var stateHintLbl: UILabel!
    @IBOutlet weak var stateTxtField: UITextField!
    @IBOutlet weak var cityHintLbl: UILabel!
    @IBOutlet weak var cityTxtField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.profileData()
        self.setupTxtField()
        self.setupUI()
        self.setupFont()
        
//        profileDataTblView.register(UINib(nibName: "TxtFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TxtFieldTableViewCell")
//        self.customBlurViewRemove(viewShow: self.profileDataTblView)
        
//        // Register for keyboard notifications
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        self.topUserNameMBV()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.topUserNameMBV()
    }
    
   
    private func topUserNameMBV(){
        //---------------------- Navigationview
        if let navigationController = self.navigationController {
            let navBarHeight = navigationController.navigationBar.frame.height
            let topSafeArea = (self.view.safeAreaInsets.top + 20.0)
            let totalTopHeight = navBarHeight + topSafeArea
            self.userNameTopConstrnt.constant = totalTopHeight
            self.userNameMBV.setNeedsLayout()
            self.userNameMBV.layoutIfNeeded()
        }
    }
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Personal Information"], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.notificationCount,AppImages.notification], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
  
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        print("notification", notification)
        self.customBlurViewRemove(viewShow: self.view)
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.profileHeaderImgView.addGradientLayer(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 0, green: 5/255.0, blue: 2.0/255.0, alpha: 0.8)], locations: [0.96,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 0)
            self.userProfileImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
            self.userProfileImgView.setGradientMultiBorder(cornerRadius: 16.0, width: 3, colors: [
                UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),
                UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),
                UIColor(red: 173.0/255.0, green: 130.0/255.0, blue: 54.0/255.0, alpha: 1.0)
               ], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 1, y: 1))
            
            [
                self.fullNameMBV,
                self.emailAddressMBV,
                self.mobileMBV,
                self.dobMBV,
                self.genderMBV,
                self.LocationMBV,
                self.addressMBV,
                self.postalCodeMBV,
                self.countryMBV,
                self.stateMBV,
                self.cityMBV
            ].forEach({[weak self] in
                guard self != nil else {
                    return
                }
                $0?.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appDarkGray, cornerRadious: 8.0)
                $0?.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1)
            })
            
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        self.personalTitleLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
        self.addrInfoTitleLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
        self.saveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        [
            self.fullNameHintLbl,
            self.emailHintLbl,
            self.mobilHintLbl,
            self.dobHintLbl,
            self.genderHintLbl,
            self.locHintLbl,
            self.addressHintLbl,
            self.postalCodeHintLbl,
            self.countryHintLbl,
            self.stateHintLbl,
            self.cityHintLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.medium.size(10.0, familyName: familyManrope)
        })
        
        [
            self.fullNameTxtField,
            self.emailTxtField,
            self.mobileNumTxtField,
            self.dobTxtField,
            self.genderTxtField,
            self.locTxtField,
            self.addressTxtField,
            self.postalCodeTxtField,
            self.countryTxtField,
            self.stateTxtField,
            self.cityTxtField
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
        
        [
            self.fullNameTxtField,
            self.emailTxtField,
//            self.mobileNumTxtField,
//            self.dobTxtField,
//            self.genderTxtField,
            self.locTxtField,
            self.addressTxtField,
            self.postalCodeTxtField,
//            self.countryTxtField,
//            self.stateTxtField,
//            self.cityTxtField
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.setRightPaddingWithImage(25.0, UIImage(named: "ic_curve_edit"))
        })
    }
    
    private func setupTxtField(){
        //----------------------Text fields
        [
            fullNameTxtField: "Full name",
            emailTxtField: "Email Address",
            mobileNumTxtField: "Contact Number",
            dobTxtField: "Date of Birth",
            genderTxtField: "Gender",
            locTxtField: "Location",
            addressTxtField: "Address",
            postalCodeTxtField: "Postal Code/Zip",
            countryTxtField: "Country",
            stateTxtField: "State",
            cityTxtField: "City"
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
    
    
//    private func profileData(){
//        //var editData: [ String : [String:Any]]? = [:]
//        
//        /*
//        self.editData = [
//            "Personal Information":
//                [
//                    [
//                        "title":"", "placeHTxt":"Full name"
//                    ],
//                    [
//                        "title":"", "placeHTxt":"Email Address"
//                    ],
//                    [
//                        "title":"", "placeHTxt":"Contact Number"
//                    ],
//                    [
//                        "title":"", "placeHTxt":"Date of Birth"
//                    ],
//                    [
//                        "title":"", "placeHTxt":"Gender"
//                    ]
//                ],
//            "Address Information":
//                [
//                    [
//                        "title":"", "placeHTxt":"Location"
//                    ],
//                    [
//                        "title":"", "placeHTxt":"Address"
//                    ],
//                    [
//                        "title":"", "placeHTxt":"Postal Code/Zip"
//                    ],
//                    [
//                        "title":"", "placeHTxt":"Country"
//                    ],
//                    [
//                        "title":"", "placeHTxt":"State"
//                    ],
//                    [
//                        "title":"", "placeHTxt":"City"
//                    ]
//                ]
//        ]
//        */
//        
////        let personalInfo = [
////            [
////                "title":"", "placeHTxt":"Full name"
////            ],
////            [
////                "title":"", "placeHTxt":"Email Address"
////            ],
////            [
////                "title":"", "placeHTxt":"Contact Number"
////            ],
////            [
////                "title":"", "placeHTxt":"Date of Birth"
////            ],
////            [
////                "title":"", "placeHTxt":"Gender"
////            ]
////        ]
//        
//        
////        let addrInfo =
////        [
////            [
////                "title":"", "placeHTxt":"Location"
////            ],
////            [
////                "title":"", "placeHTxt":"Address"
////            ],
////            [
////                "title":"", "placeHTxt":"Postal Code/Zip"
////            ],
////            [
////                "title":"", "placeHTxt":"Country"
////            ],
////            [
////                "title":"", "placeHTxt":"State"
////            ],
////            [
////                "title":"", "placeHTxt":"City"
////            ]
////        ]
//        
//        
////        self.editData = [
////            EditSectionModel(title: "Personal Information", items: personalInfo),
////            EditSectionModel(title: "Address Information", items: addrInfo)
////        ]
//        
////        self.profileDataTblView.reloadData()
//        
//        /*
//        self.editData = [
//            [
//                "title":"", "placeHTxt":"Full name"
//            ],
//            [
//                "title":"", "placeHTxt":"Email Address"
//            ],
//            [
//                "title":"", "placeHTxt":"Contact Number"
//            ],
//            [
//                "title":"", "placeHTxt":"Date of Birth"
//            ],
//            [
//                "title":"", "placeHTxt":"Gender"
//            ]
//        ]
//        */
//    }
}

extension ProfileEditViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    // UITextFieldDelegate method to restrict the input to 10 digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.mobileNumTxtField {
            // Allow only numeric input
            let allowedCharacterSet = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            if !allowedCharacterSet.isSuperset(of: characterSet) {
                return false // Disallow non-numeric input
            }
            
            // Check the total length after the proposed change
            if let currentText = textField.text, let stringRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
               
                if let textFieldMobile = self.mobileNumTxtField.text, string != "" {
                    if textFieldMobile.count == 3 || textFieldMobile.count == 7 {
                        self.mobileNumTxtField.text = textFieldMobile.text + "-"
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
            self.fullNameTxtField: self.fullNameHintLbl,
            self.emailTxtField: self.emailHintLbl,
            self.mobileNumTxtField: self.mobilHintLbl,
            self.dobTxtField: self.dobHintLbl,
            self.genderTxtField: self.genderHintLbl,
            self.locTxtField: self.locHintLbl,
            self.addressTxtField: self.addressHintLbl,
            self.postalCodeTxtField: self.postalCodeHintLbl,
            self.countryTxtField: self.countryHintLbl,
            self.stateTxtField: self.stateHintLbl,
            self.cityTxtField: self.cityHintLbl
        ]
        
        return textFieldsWithLabels[inputTxtField]
    }
    
    func hintTxtGet(inputLabel: UILabel) -> String {
        let hintTxtAddAddress: [UILabel: String] = [
            self.fullNameHintLbl: "Full name",
            self.emailHintLbl: "Email Address",
            self.mobilHintLbl: "Contact Number",
            self.dobHintLbl: "Date of Birth",
            self.genderHintLbl: "Gender",
            self.locHintLbl: "Location",
            self.addressHintLbl: "Address",
            self.postalCodeHintLbl: "Postal Code/Zip",
            self.countryHintLbl: "Country",
            self.stateHintLbl: "State",
            self.cityHintLbl: "City"
        ]
        return hintTxtAddAddress[inputLabel] ?? ""
    }
    
}

//extension ProfileEditViewController: UITableViewDelegate, UITableViewDataSource, CustomCellDelegate{
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return editData?.count ?? 0
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        return editData?[section].items?.count ?? 0  //editData?.count ?? 0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: TxtFieldTableViewCell = profileDataTblView.dequeueReusableCell(withIdentifier: "TxtFieldTableViewCell", for: indexPath) as! TxtFieldTableViewCell
//                
//        cell.hintTitleLbl.isHidden = true
//        
//        cell.configure(withPlaceHolder: editData?[indexPath.section].items?[indexPath.row]["placeHTxt"] as? String ?? "", with: editData?[indexPath.section].items?[indexPath.row]["title"] as? String ?? "", section: indexPath.section, at: indexPath)
//        
////        cell.configure(withPlaceHolder: editData?[indexPath.row]["placeHTxt"] as? String ?? "", with: editData?[indexPath.row]["title"] as? String ?? "", at: indexPath)
//       
//        cell.delegate = self
//        cell.removeAddedBlurView(viewShow: cell.txtField)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let headerV = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
//        let headerSubVMBV = UIView()
//        let headerLbltLbl = UILabel()
//        
//        headerV.backgroundColor = UIColor.clear
//        headerSubVMBV.backgroundColor = UIColor.clear
//        headerV.addSubview(headerSubVMBV)
//        headerSubVMBV.addSubview(headerLbltLbl)
//        
//        headerSubVMBV.translatesAutoresizingMaskIntoConstraints = false
//        headerLbltLbl.translatesAutoresizingMaskIntoConstraints = false
//        //----------make constraint
//        NSLayoutConstraint.activate([
//            headerSubVMBV.leadingAnchor.constraint(equalTo: headerV.leadingAnchor, constant: 20),
//            headerSubVMBV.trailingAnchor.constraint(equalTo: headerV.trailingAnchor, constant: -20),
//            headerSubVMBV.topAnchor.constraint(equalTo: headerV.topAnchor, constant: 2),
//            headerSubVMBV.bottomAnchor.constraint(equalTo: headerV.bottomAnchor, constant: -2),
//            headerLbltLbl.leadingAnchor.constraint(equalTo: headerSubVMBV.leadingAnchor, constant: 1),
//            headerLbltLbl.trailingAnchor.constraint(equalTo: headerSubVMBV.trailingAnchor, constant: -1),
//            headerLbltLbl.topAnchor.constraint(equalTo: headerSubVMBV.topAnchor, constant: 2),
//            headerLbltLbl.bottomAnchor.constraint(equalTo: headerSubVMBV.bottomAnchor, constant: -2)
//            ])
//        
//        //------------------Input Data
//        headerLbltLbl.text = self.editData?[section].title as? String
//        headerLbltLbl.textColor = UIColor.txtDarkGray
//        headerLbltLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
//        
//        return headerV
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
//    
//    // MARK: - CustomCellDelegate
//    /*
//    func textFieldDidUpdate(_ placeHoldere: String?, _ text: String, at indexPath: IndexPath) {
//        print("placeHTxt", placeHoldere as Any, text, indexPath)
////        self.editData?[indexPath.row]["placeHTxt"] = placeHoldere
////        self.editData?[indexPath.row]["title"] = text
//        
//        
//        if text.count == 1 {
//            self.profileDataTblView.reloadRows(at: [indexPath], with: .none)
//            let cell = self.profileDataTblView.cellForRow(at: indexPath) as? TxtFieldTableViewCell
//            cell?.txtField.becomeFirstResponder()
//        }else if text.count == 0{
//            self.profileDataTblView.reloadRows(at: [indexPath], with: .none)
//            let cell = self.profileDataTblView.cellForRow(at: indexPath) as? TxtFieldTableViewCell
//            cell?.txtField.becomeFirstResponder()
//        }
//        
//    }
//    */
//    
//    func textFieldDidUpdate(_ placeHoldere: String?, _ text: String, atSectiion Section: Int, at indexPath: IndexPath) {
//        print("placeHTxt", placeHoldere as Any, text, indexPath)
////        self.editData?[indexPath.row]["placeHTxt"] = placeHoldere
////        self.editData?[indexPath.row]["title"] = text
//        
//        self.editData?[indexPath.section].items?[indexPath.row]["placeHTxt"] = placeHoldere
//        self.editData?[indexPath.section].items?[indexPath.row]["title"] = text
//        
//        
//        if text.count == 1 {
//            let sectionIndex = indexPath.section
//            // Reload the entire section
//            self.profileDataTblView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
//            let cell = self.profileDataTblView.cellForRow(at: indexPath) as? TxtFieldTableViewCell
//            cell?.txtField.becomeFirstResponder()
//        }else if text.count == 0{
//            let sectionIndex = indexPath.section
//            // Reload the entire section
//            self.profileDataTblView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
//            let cell = self.profileDataTblView.cellForRow(at: indexPath) as? TxtFieldTableViewCell
//            cell?.txtField.becomeFirstResponder()
//        }
//        
//        
//        /*
//        if text.count == 1 {
//            self.profileDataTblView.reloadRows(at: [indexPath], with: .none)
//            let cell = self.profileDataTblView.cellForRow(at: indexPath) as? TxtFieldTableViewCell
//            cell?.txtField.becomeFirstResponder()
//        }else if text.count == 0{
//            self.profileDataTblView.reloadRows(at: [indexPath], with: .none)
//            let cell = self.profileDataTblView.cellForRow(at: indexPath) as? TxtFieldTableViewCell
//            cell?.txtField.becomeFirstResponder()
//        }
//        */
//    }
//    
//
//    */
//    
//}
