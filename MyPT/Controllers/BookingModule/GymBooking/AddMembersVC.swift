//
//  AddMembersVC.swift
//  MyPT
//
//  Created by Manik Goel on 02/02/26.
//

import UIKit

//protocol AddMemberProtocol {
//    func memberAdd(isDismiss: Bool?)
//    func editReloadData(isReload: Bool?)
//}

class AddMembersVC: UIViewController {
    
    // MARK: - VARIABLES
    var addMaxMember: Int?
    var addedMember: Int?
    private var currentAddMember: Int = 0
    var addMemberData: MemberModel?
    var delegate: AddMemberProtocol?
    private var genderStr: String?
    var isGroup = false
    var inputParam: DetailsParam?
    
    // MARK: - IBOUTLETS
    @IBOutlet weak var popupMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var ageTxt: UITextField!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var saveAddMemberMBV: UIView!
    @IBOutlet weak var saveNextBtn: UIButton!
    @IBOutlet weak var saveDetailBtn: UIButton!
    @IBOutlet weak var proceedBtn: UIButton!
//    @IBOutlet weak var popupHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectGenderLbl: UILabel!
    @IBOutlet weak var popupScrollV: UIScrollView!
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        currentAddMember = addedMember ?? 0
        setupUI()
        setupFont()
        setupDataIfEdit()
        [maleBtn, femaleBtn, otherBtn].forEach {
            $0?.semanticContentAttribute = .forceLeftToRight
            $0?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        }
        saveAddMemberMBV.isHidden = !isGroup
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        proceedBtn.isHidden = isGroup
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
          if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
              let keyboardHeight = keyboardFrame.height
            
//              popupHeightConstraint.constant = keyboardHeight + view.frame.size.height * 0.2
                  view.layoutIfNeeded()
          }
      }
      
      @objc func keyboardWillHide(notification: Notification) {
          // Reset the scroll view's content inset
          popupScrollV.contentInset = .zero
          popupScrollV.scrollIndicatorInsets = .zero
      }
    
    private func setupUI() {
//        popupHeightConstraint.constant = view.frame.height * 0.6
        ageTxt.keyboardType = .numberPad // default
        
        DispatchQueue.main.async {
            self.popupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.popupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.saveNextBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.saveDetailBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 40/255, green: 41/255, blue: 43/255, alpha: 1), cornerRadious: 8.0)
            self.proceedBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.maleBtn.setImage(UIImage(named: "Radio"), for: .normal)
            self.femaleBtn.setImage(UIImage(named: "Unradio"), for: .normal)
            self.otherBtn.setImage(UIImage(named: "Unradio"), for: .normal)
            [
                self.fullNameView,
                self.emailView,
                self.ageView,
            ].forEach({
                $0?.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#2C2C2C"), cornerRadious: 12.0)
                $0?.backgroundColor = UIColor(hex: "#141514")
            })
        }
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectGender(sender: maleBtn)
    }
    
    private func setupFont() {
        self.topTitleLbl.font  = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.selectGenderLbl.font  = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        self.saveDetailBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.saveNextBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.proceedBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        [
            self.maleBtn.titleLabel,
            self.femaleBtn.titleLabel,
            self.otherBtn.titleLabel
        ].forEach({
            $0?.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        })
        
        //-----------------Hint Label
        [
            fullNameLbl,
            emailLbl,
            ageLbl,
        ].forEach({
            $0.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
            $0.text = nil
        })
        
        //----------------------Text fields
        [
            fullNameTxt,
            emailTxt,
            ageTxt,
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
    private func setupDataIfEdit() {
        guard let data = addMemberData, let id = data.id, id != 0 else { return }
        
        fullNameTxt.text = data.name
        ageTxt.text = data.age?.value
        
        if let gender = data.gender?.lowercased() {
            if gender == "male" { selectGender(sender: maleBtn) }
            else if gender == "female" { selectGender(sender: femaleBtn) }
            else { selectGender(sender: otherBtn) }
        }
    }
    
    // MARK: - ACTIONS
    @IBAction func genderBtnAction(_ sender: UIButton) {
        selectGender(sender: sender)
    }
    
    @IBAction func saveNextAction(_ sender: UIButton) {
//        handleSave(isSaveNext: true)
        addMemberForGroup(isSaveAndNext: true)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
//        handleSave(isSaveNext: false)
        addMemberForGroup(isSaveAndNext: false)
    }
    
    @IBAction func proceedAction(_ sender: UIButton) {
        handleSave(isSaveNext: false)
    }
    
    @IBAction func dismissAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - CORE LOGIC
    private func handleSave(isSaveNext: Bool) {
        
        let params = AddMemberParams(
            name: fullNameTxt.text,
            age: ageTxt.text,
            gender: genderStr,
            id: "\(addMemberData?.id ?? -1)",
//            isGroup: false,
            isBuddy: true
        )
        
        guard CreatePackageVM.isValidMember(inputParams: params) else { return }
        
        CreatePackageVM.addMemberApi(viewController: self, inputParams: params.getParams()) { [weak self] response in
            
            guard let self = self, response?.status == true else { return }
            
            self.delegate?.editReloadData(isReload: true)
            
            if isGroup {
                self.dismiss(animated: true) {
                    self.delegate?.memberAdd(isDismiss: !isSaveNext)
                }
                
            } else {
                
                if isSaveNext, let max = self.addMaxMember {
                    
                    self.currentAddMember += 1
                    self.clearForm()
                    
                    if self.currentAddMember == max {
                        self.dismiss(animated: true) {
                            self.delegate?.memberAdd(isDismiss: true)
                        }
                    } else {
                        self.dismiss(animated: true) {
                            self.delegate?.memberAdd(isDismiss: false)
                        }
                    }
                } else {
                    self.dismiss(animated: true) {
                        self.delegate?.memberAdd(isDismiss: true)
                    }
                }
            }
        }
    }
    
    private func addMemberForGroup(isSaveAndNext : Bool) {
        if isSaveAndNext {
            print("save & next btn clicked")
           
            print("First time currentAddMember", currentAddMember)
            
            if let addMaxMember = addMaxMember,  currentAddMember < addMaxMember {
                
                let memberParams = AddMemberParams(name: self.fullNameTxt.text, age: self.ageTxt.text, gender: self.genderStr ?? "", id: "\(addMemberData?.id ?? -1)", isGroup: true, isBuddy: false)
                
                //id is getting then meber will be edit ohterwise new member added
                if CreatePackageVM.isValidMember(inputParams: memberParams) {
                    currentAddMember += 1
                    print("currentAddMember", currentAddMember)
                    CreatePackageVM.addMemberApi(viewController: self, inputParams: memberParams.getParams(), completion: { [weak self] getResultData in
                        
                        self?.view.endEditing(true)
                        self?.delegate?.editReloadData(isReload: true)
                        self?.addMemberData?.id = nil
                        self?.genderStr = nil
//                        self?.setAddrType(sender: UIButton())
                        self?.fullNameTxt.text = nil
                        self?.emailTxt.text = nil
                        self?.ageTxt.text = nil
                        
                        guard let self = self, let getResultData = getResultData else { return  }
                        
                        if getResultData.status == true{
                            if currentAddMember == addMaxMember {
                                self.dismiss(animated: true, completion: {
                                    self.delegate?.memberAdd(isDismiss: true)
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
            let memberParams = AddMemberParams(name: self.fullNameTxt.text, age: self.ageTxt.text, gender: self.genderStr ?? "", id: "\(addMemberData?.id ?? -1)", isGroup: true, isBuddy: false)
            
            //id is getting then meber will be edit ohterwise new member added
            if CreatePackageVM.isValidMember(inputParams: memberParams) {
                
                CreatePackageVM.addMemberApi(viewController: self, inputParams: memberParams.getParams(), completion: { [weak self] getResultData in
                    guard let self = self, let getResultData = getResultData else { return  }
                    
                    if getResultData.status == true{
                        self.dismiss(animated: true, completion: {
                            self.delegate?.memberAdd(isDismiss: true)
                        })
                    }
                })
            }
            
        }
    }
    
    private func clearForm() {
        fullNameTxt.text = nil
        ageTxt.text = nil
        genderStr = nil
        selectGender(sender: maleBtn)
    }
    
    // MARK: - GENDER UI
    private func selectGender(sender: UIButton) {
        let selectedImg = UIImage(named: "Radio")
        let unSelectedImg = UIImage(named: "Unradio")
        let oldBtn = genderStr == "male" ? maleBtn : genderStr == "female" ? femaleBtn : otherBtn
        oldBtn?.setImage(unSelectedImg, for: .normal)
        genderStr = sender.tag == 0 ? "male" : sender.tag == 1 ? "female" : "others"
        sender.setImage(selectedImg, for: .normal)
    }

}

extension AddMembersVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
            self.fullNameTxt: fullNameLbl,
            self.emailTxt: emailLbl,
            self.ageTxt: ageLbl
        ]
        
        return textFieldsWithLabels[inputTxtField]
    }
    
    func hintTxtGet(inputLabel: UILabel) -> String {
        let hintTxtAddMember: [UILabel: String] = [
            self.fullNameLbl: "Full name",
            self.emailLbl: "Email ID",
            self.ageLbl: "Enter Age"
        ]
        return hintTxtAddMember[inputLabel] ?? ""
    }
}
