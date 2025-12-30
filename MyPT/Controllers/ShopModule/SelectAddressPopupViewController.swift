//
//  SelectAddressPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 06/03/25.
//

import UIKit

enum MakeAddressFlow {
    case editLocation
    case defaultAddress
}

class SelectAddressPopupViewController: UIViewController {
    
    //MARK: ------------- VARIABLE
    var makeAddrFlow: MakeAddressFlow = .defaultAddress
    var navCtrl: UINavigationController?
    var addressData:[AddressDataModel]? = []
    var selectedIdStr:String?
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var addressPopupMBV: UIView!
    @IBOutlet weak var titleMBV: UIView!
    @IBOutlet weak var checkPinMBV: UIView!
    @IBOutlet weak var checkMBV: UIView!
    @IBOutlet weak var savedAddrMBV: UIView!
    @IBOutlet weak var cancelOrderMBV: UIView!
    @IBOutlet weak var addAddrMBV: UIView!
    @IBOutlet weak var deliveryAddrMBV: UIView!
    @IBOutlet weak var deliveryAddressTitleLbl: UILabel!
    @IBOutlet weak var savedAddressTitleLbl: UILabel!
    @IBOutlet weak var homeDeliveryTitleLbl: UILabel!
    @IBOutlet weak var homeAddressLbl: UILabel!
    @IBOutlet weak var checkPincodeBtn: UIButton!
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var cancelOrderBtn: UIButton!
    @IBOutlet weak var pincodeTxtField: UITextField!
    @IBOutlet weak var addAddrBtn: UIButton!
    @IBOutlet weak var addressMBV: UIView!
    @IBOutlet weak var addrTitleLbl: UILabel!
    @IBOutlet weak var addrTblView: UITableView!
    @IBOutlet weak var addrTblViewHeightConstrnt: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFont()
        self.setFlow()
        addrTblView.showsVerticalScrollIndicator = false
        addrTblView.showsHorizontalScrollIndicator = false
        addrTblView.register(UINib(nibName: "ShowAddressTableViewCell", bundle: nil), forCellReuseIdentifier: "ShowAddressTableViewCell")
        
        self.getAddressListApi()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    @IBAction func checkPincodeBtnActn(_ sender: Any) {
        print("check pincode...")
    }
    
    @IBAction func cancelOrderBtnActn(_ sender: Any) {
        print("order cancel...")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAddrBtnActn(_ sender: Any) {
        print("Add new address btn....")
        self.dismiss(animated: true, completion: {[weak self] in
            guard self != nil else {
                return
            }
            
            let vc:LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
            vc.flowLocation = .confirmAddAddress
            vc.isFromEditAddress = false
            self?.navCtrl?.pushViewController(vc, animated: true)
        })
      
    }
    
    private func setFlow(){
        self.checkMBV.isHidden = true
        self.addAddrMBV.isHidden = true
       
        switch makeAddrFlow {
        case .editLocation:
            print("Edit Location...")
            self.addAddrMBV.isHidden = false
            self.cancelOrderBtn.setTitle("CHANGE ADDRESS", for: .normal)
        case .defaultAddress:
            print("default address....")
            self.checkMBV.isHidden = false
            self.cancelOrderBtn.setTitle("CANCEL ORDER", for: .normal)
        }
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.addressPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.checkPinMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appDarkGray, cornerRadious: 8.0)
            self.addAddrBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.deliveryAddrMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cancelOrderBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        self.deliveryAddressTitleLbl.font = AppFont.bold.size(24.0, familyName: familyManrope)
        self.savedAddressTitleLbl.font = AppFont.bold.size(24.0, familyName: familyManrope)
        self.homeDeliveryTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.homeAddressLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.checkPincodeBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.cancelOrderBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.addAddrBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.pincodeTxtField.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        self.pincodeTxtField.placeholderSet(placeHolder: "Enter Postcode", color: UIColor.appWhite.withAlphaComponent(0.7))
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        let vcHeight = (self.view.frame.size.height*0.3)
        
        if addrTblView.contentSize.height != 0.0 {
            addrTblViewHeightConstrnt.constant = addrTblView.contentSize.height < vcHeight ? addrTblView.contentSize.height : vcHeight
        }
      
        self.view.layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.addressPopupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
    
}

extension SelectAddressPopupViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ShowAddressTableViewCell = addrTblView.dequeueReusableCell(withIdentifier: "ShowAddressTableViewCell", for: indexPath) as! ShowAddressTableViewCell
        cell.addrTypeLbl.text = addressData?[indexPath.row].type?.localizedCapitalized
        
        let nameStr: String = addressData?[indexPath.row].name?.value ?? ""
        let fullAddrStr = [addressData?[indexPath.row].building_name?.value, addressData?[indexPath.row].street?.value, addressData?[indexPath.row].landmark, addressData?[indexPath.row].city_name, addressData?[indexPath.row].country_name]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        let mobileStr: String = addressData?[indexPath.row].mobile_no?.value ?? ""
        
        cell.addressLbl.text = nameStr + " \n" + fullAddrStr + " \n" + mobileStr
        cell.selectAddrBtn.accessibilityHint = addressData?[indexPath.row].id?.value
        cell.selectAddrBtn.addTarget(self, action: #selector(selectAddrBtnActn(sender: )), for: .touchUpInside)
        
        if let selectedIdStr = selectedIdStr, let cellId = addressData?[indexPath.row].id?.value, selectedIdStr == cellId{
            cell.selectAddrBtn.isSelected = true
        }else{
            cell.selectAddrBtn.isSelected = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    @objc func selectAddrBtnActn(sender: UIButton){
        print("sender accessibilityHint: ", sender.accessibilityHint as Any)
        sender.isSelected = true
        self.selectedIdStr = sender.accessibilityHint
        self.addrTblView.reloadData()
        
        if let adddrIdStr = sender.accessibilityHint, let getIndx = addressData?.firstIndex(where: {$0.id?.value == adddrIdStr}) {
            let addrDetails = addressData?[getIndx]
            print("addrDetails: ", addrDetails as Any)
        }
    }
    
}

extension SelectAddressPopupViewController{
    private func getAddressListApi(){
        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            self.addressData?.removeAll()
            self.addressData?.append(contentsOf: getResultData.data ?? [])
            if let addrsId = self.selectedIdStr {
                self.selectedIdStr = addrsId
            }else{
                self.selectedIdStr = self.addressData?.first?.id?.value
            }
            self.addrTblView.reloadData()
        })
    }
}
