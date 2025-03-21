//
//  SelectYourLocationViewController.swift
//  MyPT
//
//  Created by techsaga corp on 17/03/25.
//

import UIKit

class SelectYourLocationViewController: CommonViewController {

    //MARK: -------------- VARIABLE
    var addressData:[AddressDataModel]? = []
    var selectedIdStr:String?
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var headerMBV: UIView!
    @IBOutlet weak var footerMBV: UIView!
    @IBOutlet weak var headerTitleLbl: UILabel!
    @IBOutlet weak var selectAddrTblView: UITableView!
    @IBOutlet weak var addNewAddrBtn: UIButton!
    @IBOutlet weak var dateNtimeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        self.selectAddrTblView.contentInset = UIEdgeInsets(top: -50, left: 0, bottom: 0, right: 0)
        self.dateNtimeBtn.isHidden = true
        self.selectAddrTblView.reloadData()
//        self.getAddressListApi()
    }
    
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        self.getAddressListApi()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [ AppStrings.book_a_Slot], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    
    @IBAction func dateNtimeBtnActn(_ sender: Any) {
        print("select Date & Time..")
        if let selectedIdStr = self.selectedIdStr , !selectedIdStr.isEmpty {
            let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
            vc.slotBookFlow = .bookTrainer
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.select_Address)
        }

        
//        let vc:BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
//        vc.modalPresentationStyle = .automatic
//        vc.bookingAddressFlow = .addMember
//        self.present(vc, animated: true)
    }
    
    @IBAction func addNewAddrBtnAtcn(_ sender: Any) {
        print("addNewAddrBtnAtcn clicked...")
        
        let vc:LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
        vc.flowLocation = .addAdress
        self.navigationController?.pushViewController(vc, animated: true)
        
        /* only for testing
        let vc:BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
        vc.modalPresentationStyle = .automatic
        vc.bookingAddressFlow = .addAddress
        vc.delegate = self
        self.present(vc, animated: true)
        
        */
    }
    
    
    private func setupUI(){
        self.headerMBV.isHidden = true
        self.footerMBV.isHidden = true
        
        selectAddrTblView.register(UINib(nibName: "SelectLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectLocationTableViewCell")
        
        headerTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        addNewAddrBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        dateNtimeBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        //-----------------Set UI
        DispatchQueue.main.async {
            self.addNewAddrBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.dateNtimeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
}

//MARK: --------------------TABLEVIEW DELEGATE/ DATASOURCE
extension SelectYourLocationViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setupRow(inputTable: tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SelectLocationTableViewCell = selectAddrTblView.dequeueReusableCell(withIdentifier: "SelectLocationTableViewCell", for: indexPath) as! SelectLocationTableViewCell

        cell.setCellData(cellData: addressData?[indexPath.row])
     
        cell.selectBtn.accessibilityHint = addressData?[indexPath.row].id?.value
        cell.editBtn.accessibilityHint = addressData?[indexPath.row].id?.value
        cell.editBtn.addTarget(self, action: #selector(editAddrBtnActn(sender: )), for: .touchUpInside)
        cell.selectBtn.addTarget(self, action: #selector(selectAddrBtnActn(sender: )), for: .touchUpInside)
        
        if let selectedIdStr = selectedIdStr, let cellId = addressData?[indexPath.row].id?.value, selectedIdStr == cellId{
            cell.selectBtn.isSelected = true
        }else{
            cell.selectBtn.isSelected = false
        }
                
        return cell
    }
    
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if self.addressData?.count == 0 {
//            return 1
//        }else{
//            return UITableView.automaticDimension
//        }
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        if self.addressData?.count == 0 {
//            return nil
//        }else{
//            return headerMBV
//        }
//        
//        //        return headerMBV
//    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if self.addressData?.count == 0 {
            return nil
        }else{
            return footerMBV
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.addressData?.count == 0 {
            return 1
        }else{
            return UITableView.automaticDimension
        }
    }
            
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    //MARK: ------------ SETUP NO DATA FOUND
    private func setupRow(inputTable:UITableView) -> Int {
        return inputTable.numberOfRows(count: self.addressData?.count, title: AppAlertStrings.no_Address_Added, message: AppAlertStrings.no_Address_Added_desc, messageImage: AppImages.noAddress, messageImageHeight: 150.0, reloadBtnBgColor: UIColor.appWhite, reloadBtnTitleColor: UIColor.mainBg, reloadSetTitle: "ADD ADDRESS NOW", reloadBtnImg: UIImage(named: "ic_add"), target: self, action: #selector(addAddressBtnActn(sender: )), fromCenter: -110, fromTop: nil)
    }
    
    @objc func selectAddrBtnActn(sender: UIButton){
        sender.isSelected = true
        self.selectedIdStr = sender.accessibilityHint
        self.selectAddrTblView.reloadData()
        
//        sender.isSelected = !sender.isSelected
//        
//        if sender.isSelected {
//            sender.isSelected = true
//        }else {
//            sender.isSelected = false
//        }
    }
    
    @objc func editAddrBtnActn(sender: UIButton){
        print(sender.accessibilityHint ?? "")
        
        let indx = addressData?.firstIndex(where: {$0.id?.value == sender.accessibilityHint ?? ""})
        print(indx as Any)
        
        if let indx = indx {
            let addData = addressData?[indx]
            print("addData: ",addData as Any)
            
            let vc:BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            vc.bookingAddressFlow = .editAddress
            vc.addressData = addData
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
    @objc func addAddressBtnActn(sender: UIButton){
        print("No add ADD ADDRESS NOW clicked...")
        /*   only test
        let vc:BookingAddressViewController = BookingAddressViewController.instantiate(appStoryboard: .booking)
        vc.modalPresentationStyle = .automatic
        vc.bookingAddressFlow = .addAddress
        vc.delegate = self
        self.present(vc, animated: true)
        */
        
        let vc:LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
        vc.flowLocation = .addAdress
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: -----------------EXTENSION FOR API
extension SelectYourLocationViewController {
    
    private func getAddressListApi(){
        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print("getResultData", getResultData.data as Any)
            self.addressData?.removeAll()
            self.addressData?.append(contentsOf: getResultData.data ?? [])
            self.selectAddrTblView.reloadData()
            
            //--------------************-------
            if let dataCount = self.addressData?.count, dataCount > 0 {
                self.dateNtimeBtn.isHidden = false
                self.headerMBV.isHidden = false
                self.footerMBV.isHidden = false
            }else{
                self.dateNtimeBtn.isHidden = true
                self.headerMBV.isHidden = true
                self.footerMBV.isHidden = true
            }
        })
    }
}


extension SelectYourLocationViewController: BookingAddressProtocol{

    func onDismiss(isDismiss: Bool?) {
        if isDismiss == true {
            self.getAddressListApi()
        }
    }
    
}
