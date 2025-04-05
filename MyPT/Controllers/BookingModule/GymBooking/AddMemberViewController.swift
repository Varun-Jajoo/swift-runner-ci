//
//  AddMemberViewController.swift
//  MyPT
//
//  Created by techsaga corp on 02/04/25.
//

import UIKit


class AddMemberViewController: CommonViewController {
    
    //MARK: -------------VARIABLE
    var getMemberParams: MemberParamsModel?
    var memberData: MemberDataModel?
    var memberList:[MemberModel]? = []
    var createPackageParamsAddMember: CreatePackageParamsModel?
    var avialCalanderparamsAddMember:AvailParmsModel?
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var addMemberMBV: UIView!
    @IBOutlet weak var addMemberBtn: UIButton!
    @IBOutlet weak var noteMemberBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var membersTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupFont()
        
        //------------------------******************
        self.setupInputData()
        self.enableContinueBtn(isSelected: false)
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        
        //-----------------------*************
        self.getMemberApi(params: getMemberParams?.getParams() ?? [:])
    }
    
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("Continue btn clicked...")
        
        if let minMember = memberData?.minMember, let maxMember = memberData?.maxMember, let totalAddMember =  self.memberList?.count,(Int(minMember) ?? 0) <= totalAddMember, (Int(maxMember) ?? 0) >= totalAddMember {
            let vc:ChooseSessionViewController = ChooseSessionViewController.instantiate(appStoryboard: .booking)
            vc.inputParams = self.createPackageParamsAddMember
            vc.availParams = self.avialCalanderparamsAddMember
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: memberData?.limit ?? "")
        }
        
        /*
        if let memberList = self.memberList, memberList.contains(where: { $0.id != 17  || $0.id == 0}) {
            let vc:ChooseSessionViewController = ChooseSessionViewController.instantiate(appStoryboard: .booking)
            vc.inputParams = self.createPackageParamsAddMember
            vc.availParams = self.avialCalanderparamsAddMember
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.memebr_Added)
        }
        */
    }
    
    
    @IBAction func addMemberBtnActn(_ sender: Any) {
        print("Add member btn clicked......")
        let vc: BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
        vc.bookingAddressFlow = .addMember
        vc.modalPresentationStyle = .automatic
        vc.navCtrnl = self.navigationController
        vc.addMemberDelegate  = self
        self.present(vc, animated: true)
        
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
    }
    
    private func setupInputData(){
        
        if let memberList = self.memberList, memberList.count == 0 {
            self.addMemberMBV.isHidden = true
            self.noteMemberBtn.isHidden = true
            self.enableContinueBtn(isSelected: false)
        }else{
            self.addMemberMBV.isHidden = false
            self.noteMemberBtn.isHidden = false
            self.enableContinueBtn(isSelected: true)
        }
        
        //---------------****************
        self.noteMemberBtn.setTitle(self.memberData?.limit, for: .normal)
    }
    
    private func setupUI(){
        
        self.membersTblView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        self.membersTblView.register(UINib(nibName: "AddMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "AddMemberTableViewCell")
        
        //-------------------UI
        DispatchQueue.main.async {
            self.addMemberBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.noteMemberBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), cornerRadious: 12.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
        
    }
    
    private func setupFont(){
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.addMemberBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.noteMemberBtn.titleLabel?.font = AppFont.regular.size(12.0, familyName: familyOverpass)
        self.noteMemberBtn.titleLabel?.numberOfLines = 2
        
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    //MARK: -------------- ENABLE CONTINUE
    private func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
}

//MARK: -------------- TABLEVIEW DELEGATE/DATASOURCE
extension AddMemberViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setupRow(inputTable: tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: AddMemberTableViewCell = membersTblView.dequeueReusableCell(withIdentifier: "AddMemberTableViewCell", for: indexPath) as! AddMemberTableViewCell
        
        cell.setupCell(data: memberList?[indexPath.row])
        
        cell.editBtn.accessibilityHint = "\(memberList?[indexPath.row].id ?? -1)"
        cell.editBtn.addTarget(self, action: #selector(editMemberBtnActn(sender: )), for: .touchUpInside)
        
        cell.delBtn.accessibilityHint = "\(memberList?[indexPath.row].id ?? -1)"
        cell.delBtn.addTarget(self, action: #selector(deleteMemberBtnActn(sender: )), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return addMemberMBV
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
     
        return UITableView.automaticDimension
    }
            
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    //MARK: ------------EDIT MEMBER
    @objc func editMemberBtnActn(sender: UIButton){
        let indx = memberList?.firstIndex(where: {$0.id == Int(sender.accessibilityHint ?? " ")})
        print(indx as Any)
        
        if let indx = indx {
            let memberData = memberList?[indx]
            print("memberData: ",memberData as Any)
            
            let vc: BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
            vc.bookingAddressFlow = .addMember
            vc.modalPresentationStyle = .automatic
            vc.navCtrnl = self.navigationController
            vc.addMemberData = memberData
            vc.addMemberDelegate = self
            self.present(vc, animated: true)
        }
    }
    
    //MARK: ------------DELETE MEMBER
    @objc func deleteMemberBtnActn(sender: UIButton){
        print(sender.accessibilityHint as Any)
        AlertHelper.shared.showCustomeAlert(title: AppAlertStrings.delete_Str.localizedCapitalized + "!", message: AppAlertStrings.delete_AlertMsg, actions: ["cancel","ok"], withCancel: true, completion: {[weak self] getTag in
            guard let self = self else { return  }
            
            if let getTag = getTag, getTag == 1 {
                self.deleteMemberApi(inputIdStr: sender.accessibilityHint)
            }
        })
    }
    
    //MARK: ------------ SETUP NO DATA FOUND
    private func setupRow(inputTable:UITableView) -> Int {
        return inputTable.numberOfRows(count: memberList?.count ?? 0, title: AppAlertStrings.no_Memebr_Added, message: " ", messageImage: AppImages.noAddress, messageImageHeight: 150.0, reloadBtnBgColor: UIColor.appWhite, reloadBtnTitleColor: UIColor.mainBg, reloadSetTitle: "ADD MEMBER NOW", reloadBtnImg: UIImage(named: "ic_add"), target: self, action: #selector(addMemebrBtnActn(sender: )), fromCenter: -110, fromTop: nil)
    }
    
    @objc func addMemebrBtnActn(sender: UIButton){
        let vc: BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
        vc.bookingAddressFlow = .addMember
        vc.modalPresentationStyle = .automatic
        vc.navCtrnl = self.navigationController
        vc.addMemberDelegate = self
        self.present(vc, animated: true)
    }
    
}

//MARK: --------------------EXTENSION FOR RELOAD ADDED MEMBER DATA
extension AddMemberViewController: AddMemberProtocol{
    func memberAdd(isDismiss: Bool?) {
        if isDismiss == true {
            self.getMemberApi(params: getMemberParams?.getParams() ?? [:])
        }
    }
}

extension AddMemberViewController{

    private func getMemberApi(params: [String:String]){
        CreatePackageVM.getMemberPackagegroupApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print(getResultData)
            
            if getResultData.status == true {
                self.memberData = getResultData.data
                self.memberList?.removeAll()
                self.memberList?.append(contentsOf: getResultData.data?.members ?? [])
                self.membersTblView.reloadData()
                self.setupInputData()
            }
           
        })
    }
    
    private func deleteMemberApi(inputIdStr: String?){
        CreatePackageVM.deleteMemberApi(viewController: self, inputId: inputIdStr, completion: { [weak self] getResultData in
            guard let self = self else { return }
            
            print("Result Data: ", getResultData as Any)
            
            if getResultData?["status"] as? Bool == true  {
                self.getMemberApi(params: getMemberParams?.getParams() ?? [:])
               
                AlertHelper.shared.alertMesssage(view: self, title: "", message: getResultData?["msg"] as? String ?? "")
            }
        })
    }
}


//MARK: ----------- GET MEMBER PARAM MODEL
struct MemberParamsModel {
    var package_type: String?
    var type: String?
    var trainer_id: String?
    var studio_id: String?
    
    func getParams() -> [String: String] {
        var dict: [String: String] = [:]
        
        if let package_type = package_type { dict["package_type"] = package_type }
        if let type = type { dict["type"] = type }
        if let trainer_id = trainer_id { dict["trainer_id"] = trainer_id }
        if let studio_id = studio_id { dict["studio_id"] = studio_id }
        
        return dict
    }
}
