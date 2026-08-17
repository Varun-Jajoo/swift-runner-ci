//
//  AddBuddylViewController.swift
//  DemoCards
//
//  Created by techsaga on 15/01/26.
//

import UIKit

class AddBuddylViewController: CommonViewController, AddMemberProtocol {
    
    var packageType: String?
    var inputType:String?
    var inputLat:Double?
    var inputLong:Double?
    var getMemberParams: MemberParamsModel?
    var memberData: MemberDataModel?
    var memberList: [MemberModel]? = []
    var createPackageParamsAddMember: CreatePackageParamsModel?
    var avialCalanderparamsAddMember:AvailParmsModel?
    var isGroup = false
    var inputParam: DetailsParam?
    
    @IBOutlet weak var imgBckgrnd: UIImageView!
    @IBOutlet weak var imgBuddy: UIImageView!
    @IBOutlet weak var lblAddBuddy: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var btnAddDetail: UIButton!
    @IBOutlet weak var viewPlaceholder: UIView!
    @IBOutlet weak var viewWithData: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableViewData: UITableView!
    @IBOutlet weak var btnAddMember: UIButton!
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var addMemberMBV: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFont()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        if isGroup {
            var param: MemberParamsModel?
            param?.package_type = "3"
            param?.type = inputType
            getMemberParams = MemberParamsModel(package_type: "3", type: inputParam?.type, trainer_id: self.inputParam?.trainer_id, studio_id: self.inputParam?.studio_id)
            self.getMemberApi(params: getMemberParams?.getParams() ?? [:])
        } else {
            self.getBuddyMemberApi(params: getMemberParams?.getParams() ?? [:])
        }
    }
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.3)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
    }
    
    private func setupFont() {
        self.lblTitle.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        self.lblAddBuddy.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        self.lblDetail.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        self.lblBottom.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.btnAddDetail.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnAddMember.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
    }

    private func setupUI() {
        self.tableViewData.register(UINib(nibName: "AddMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "AddMemberTableViewCell")
        self.tableViewData.delegate = self
        self.tableViewData.dataSource = self
        self.btnAddDetail.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        self.btnAddDetail.setTitle("+  ADD DETAILS", for: .normal)
        self.btnAddDetail.tintColor = .mainBg   // arrow color
        self.btnAddDetail.backgroundColor = .appWhite
        self.btnAddDetail.setTitleColor(.mainBg, for: .normal)
        btnAddMember.isHidden = !isGroup
        lblBottom.isHidden = !isGroup
        lblTitle.text = isGroup ? "Group information" : "Buddy information"
        lblAddBuddy.text = "Add your " + (isGroup ? "group" : "buddy")
        self.btnAddMember.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        self.btnContinue.layer.cornerRadius = 8
//        btnAddMember.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1, cornerRadius: 12.0, dashPattern: [6,4])
    }
    
    private func setupInputData() {
        DispatchQueue.main.async {
            if let memberList = self.memberList, memberList.count <= 1 {
                self.viewPlaceholder.isHidden = false
                self.viewWithData.isHidden = true
            } else {
                self.viewPlaceholder.isHidden = true
                self.viewWithData.isHidden = false
            }
            self.lblBottom.text = self.memberData?.limit
        }
    }
    
    func memberAdd(isDismiss: Bool?) {
        if isDismiss == true {
            if isGroup {
                self.getMemberApi(params: getMemberParams?.getParams() ?? [:])
            } else {
                self.getBuddyMemberApi(params: getMemberParams?.getParams() ?? [:])
            }
        }
//        else {
//            if isGroup {
//                self.getMemberApi(params: getMemberParams?.getParams() ?? [:])
//                let currentMembers = (self.memberList?.count ?? 0) + 1
//                let maxMember = Int(memberData?.maxMember ?? "0") ?? 7
//                if currentMembers <= maxMember {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
//                        let vc: AddMembersVC = AddMembersVC.instantiate(appStoryboard: .booking)
//                        vc.modalPresentationStyle = .automatic
//                        vc.delegate = self
//                        vc.isGroup = self.isGroup
//                        self.present(vc, animated: true)
//                    })
//                }
//            }
//        }
    }
    
    func editReloadData(isReload: Bool?) {
        if isReload == true {
            if isGroup {
                self.getMemberApi(params: self.getMemberParams?.getParams() ?? [:])
            } else {
                self.getBuddyMemberApi(params: getMemberParams?.getParams() ?? [:])
            }
        }
    }
    
    @IBAction func onTapAddDetail(_ sender: UIButton) {
        if let maxMember = memberData?.maxMember?.value, let totalAddMember =  self.memberList?.count, (Int(maxMember) ?? 0) > totalAddMember {
            let vc: AddMembersVC = AddMembersVC.instantiate(appStoryboard: .booking)
            vc.isGroup = isGroup
            vc.modalPresentationStyle = .automatic
//            vc.navCtrnl = self.navigationController
            vc.delegate  = self
            vc.addMaxMember = Int(maxMember)
            vc.addedMember = totalAddMember
            var data = inputParam
            data?.package_type = packageType
            vc.inputParam = data
            self.present(vc, animated: true)
        } else {
            AlertHelper.shared.alertMesssage(view: self, title: "", message: memberData?.limit ?? "")
        }
    }
    
    @IBAction func onTapContinue(_ sender: UIButton) {
        let minMember = Int(memberData?.minMember?.value ?? "0") ?? 3
        if self.memberList?.count ?? 0 < minMember {
            AlertHelper.shared.alertMesssage(view: self, title: "", message: memberData?.limit ?? "")
            return
        }
        let vc: ChoosePrimaryTrainerVC = ChoosePrimaryTrainerVC.instantiate(appStoryboard: .purchase)
        vc.packageType = packageType
        vc.inputType = inputType
        vc.inputLat = inputLat
        vc.inputLong = inputLong
        vc.inputParam = inputParam
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onTapAddBuddy(_ sender: UIButton) {
        if isGroup {
            if let maxMember = memberData?.maxMember?.value, let totalAddMember = self.memberList?.count, (Int(maxMember) ?? 0) > totalAddMember {
                let vc: AddMembersVC = AddMembersVC.instantiate(appStoryboard: .booking)
                vc.modalPresentationStyle = .automatic
                vc.delegate = self
                vc.isGroup = isGroup
                vc.addMaxMember = Int(memberData?.maxMember?.value ?? "0")
                vc.addedMember = self.memberList?.count
                var data = inputParam
                data?.package_type = packageType
                vc.inputParam = data
                self.present(vc, animated: true)
            } else {
                AlertHelper.shared.alertMesssage(view: self, title: "", message: memberData?.limit ?? "")
            }
        } else {
            let vc: AddMembersVC = AddMembersVC.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            vc.delegate = self
            vc.isGroup = isGroup
            vc.addMaxMember = Int(memberData?.maxMember?.value ?? "0")
            vc.addedMember = self.memberList?.count
            var data = inputParam
            data?.package_type = packageType
            vc.inputParam = data
            self.present(vc, animated: true)
        }
    }
}

extension AddBuddylViewController {

    private func getBuddyMemberApi(params: [String: String]) {
        CreatePackageVM.getBuddyMemberApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print(getResultData)
            
            if getResultData.status == true {
                self.memberData = getResultData.data
                self.memberList?.removeAll()
                self.memberList?.append(contentsOf: getResultData.data?.members ?? [])
                self.lblTitle.isHidden = self.memberList?.count == 0
                self.tableViewData.reloadData()
                self.setupInputData()
            }
        })
    }
    
    private func deleteMemberApi(inputIdStr: String?){
        CreatePackageVM.deleteMemberApi(viewController: self, inputId: inputIdStr, completion: { [weak self] getResultData in
            guard let self = self else { return }
            
            print("Result Data: ", getResultData as Any)
            
            if getResultData?["status"] as? Bool == true  {
                if isGroup {
                    self.getMemberApi(params: getMemberParams?.getParams() ?? [:])
                } else {
                    self.getBuddyMemberApi(params: getMemberParams?.getParams() ?? [:])
                }
                AlertHelper.shared.alertMesssage(view: self, title: "", message: getResultData?["msg"] as? String ?? "")
            }
        })
    }
    
    private func getMemberApi(params: [String:String]){
        CreatePackageVM.getMemberPackagegroupApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print(getResultData)
            
            if getResultData.status == true {
                self.memberData = getResultData.data
                self.memberList?.removeAll()
                self.memberList?.append(contentsOf: getResultData.data?.members ?? [])
                self.lblTitle.isHidden = self.memberList?.count == 0
                self.tableViewData.reloadData()
                self.setupInputData()
            }
           
        })
    }
    
}

extension AddBuddylViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isGroup {
        let minMember = Int(memberData?.minMember?.value ?? "0") ?? 3
//            if memberData?.members?.count ?? 0 < minMember {
//                btnContinue.isUserInteractionEnabled = false
//                btnContinue.backgroundColor = .gray
//            } else {
//                btnContinue.isUserInteractionEnabled = false
//                btnContinue.backgroundColor = UIColor(hex: "#F0F0F0")
//            }
//            self.tableViewData.isHidden = self.memberData?.members?.count ?? 0 == 0
        self.viewWithData.isHidden = self.memberData?.members?.count ?? 0 == 0
            return self.memberData?.members?.count ?? 0
//        }
//        return setupRow(inputTable: tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: AddMemberTableViewCell = tableViewData.dequeueReusableCell(withIdentifier: "AddMemberTableViewCell", for: indexPath) as! AddMemberTableViewCell
        
        cell.setupCell(data: memberList?[indexPath.row])
        cell.editBtn.accessibilityHint = "\(memberList?[indexPath.row].id ?? -1)"
        cell.editBtn.addTarget(self, action: #selector(editMemberBtnActn(sender: )), for: .touchUpInside)
        
        cell.delBtn.accessibilityHint = "\(memberList?[indexPath.row].id ?? -1)"
        cell.delBtn.addTarget(self, action: #selector(deleteMemberBtnActn(sender: )), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isGroup {
            let maxMember = Int(memberData?.maxMember?.value ?? "0") ?? 7
            return (self.memberData?.members?.count ?? 0) >= maxMember ? nil : addMemberMBV
        } else {
            return  nil
            
//            return  addMemberMBV
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
     
        return UITableView.automaticDimension
    }
            
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0.1
//    }
    
    // MARK: ------------EDIT MEMBER
    @objc func editMemberBtnActn(sender: UIButton) {
        TapticEngine.selection.feedback()
        let indx = memberList?.firstIndex(where: {$0.id == Int(sender.accessibilityHint ?? " ")})
        print(indx as Any)
        
        if let indx = indx {
            let memberDetailsData = memberList?[indx]
            print("memberData: ",memberData as Any)
            
            if let maxMember = memberData?.maxMember?.value, let totalAddMember =  self.memberList?.count{
                
                let vc: AddMembersVC = AddMembersVC.instantiate(appStoryboard: .booking)
                vc.modalPresentationStyle = .automatic
//                vc.navCtrnl = self.navigationController
                vc.isGroup = isGroup
                vc.addMemberData = memberDetailsData
                vc.addedMember = (totalAddMember == Int(maxMember) ? totalAddMember - 1: totalAddMember)
                vc.addMaxMember = Int(maxMember)
                vc.delegate = self
                self.present(vc, animated: true)
            }
        }
    }
    
    //MARK: ------------DELETE MEMBER
    @objc func deleteMemberBtnActn(sender: UIButton) {
        TapticEngine.selection.feedback()
        print(sender.accessibilityHint as Any)
        AlertHelper.shared.showCustomeAlert(title: AppAlertStrings.delete_Str.localizedCapitalized + "!", message: AppAlertStrings.delete_AlertMsg, actions: ["cancel","ok"], withCancel: true, completion: {[weak self] getTag in
            guard let self = self else { return  }
            
            if let getTag = getTag, getTag == 1 {
                self.deleteMemberApi(inputIdStr: sender.accessibilityHint)
            }
        })
    }
    
    //MARK: ------------ SETUP NO DATA FOUND
//    private func setupRow(inputTable:UITableView) -> Int {
////        return inputTable.numberOfRows(count: memberList?.count ?? 0, target: self, action: #selector(addMemebrBtnActn(sender: )), fromCenter: -110, fromTop: nil)
//        
//        return inputTable.numberOfRows(count: memberList?.count ?? 0, title: AppAlertStrings.no_Memebr_Added, message: " ", messageImage: AppImages.noAddress, messageImageHeight: 150.0, reloadBtnBgColor: UIColor.appWhite, reloadBtnTitleColor: UIColor.mainBg, reloadSetTitle: "ADD MEMBER NOW", reloadBtnImg: UIImage(named: "ic_add"), target: self, action: #selector(addMemebrBtnActn(sender: )), fromCenter: -110, fromTop: nil)
//    }
//    
//    @objc func addMemebrBtnActn(sender: UIButton){
//        let vc: AddMembersVC = AddMembersVC.instantiate(appStoryboard: .booking)
//        vc.modalPresentationStyle = .automatic
////        vc.navCtrnl = self.navigationController
//        vc.delegate = self
//        vc.isGroup = isGroup
//        vc.addMaxMember = Int(memberData?.maxMember ?? "0")
//        vc.addedMember = self.memberList?.count
//        var data = inputParam
//        data?.package_type = packageType
//        vc.inputParam = data
//        self.present(vc, animated: true)
//    }
}
