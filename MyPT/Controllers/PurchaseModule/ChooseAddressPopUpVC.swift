//
//  ChooseAddressPopUpVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 31/01/26.
//

import UIKit

class ChooseAddressPopUpVC: UIViewController {

    @IBOutlet weak var tableViewAddress: UITableView!
    @IBOutlet weak var viewProceedButton: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var viewAddNewAddress: UIView!
    @IBOutlet weak var imgDotedBorder: UIImageView!
    
    var addressData: [AddressDataModel]? = []
    var currentSelectedAddress = 0
    var selectedAddressCallBack : ((AddressDataModel) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
    }
    
    private func uiSetup() {
        tableViewAddress.delegate = self
        tableViewAddress.dataSource = self
        tableViewAddress.register(UINib(nibName: "AddressTVC", bundle: nil), forCellReuseIdentifier: "AddressTVC")
        viewProceedButton.layer.cornerRadius = 10
        viewAddNewAddress.layer.cornerRadius = 10
        imgDotedBorder.layer.cornerRadius = 10
        self.tableViewAddress.reloadData()
    }

    @IBAction func onTapCloseSheetAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onTapProceedAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if let dataModel = self.addressData?[self.currentSelectedAddress] {
                self.selectedAddressCallBack?(dataModel)
            }
        })
    }
    
    @IBAction func onTapAddNewAddressAction(_ sender: UIButton) {

//        let vc: AddNewAddressVC = AddNewAddressVC.instantiate(appStoryboard: .purchase)
//            vc.tfAddressLabel.text = currentAddress
//            vc.tfCity.text = addressDataReceived?.city_name
//            vc.tfStreetName.text = addressDataReceived?.street?.value
//            vc.tfBuildingName.text = addressDataReceived?.building_name?.value
//        vc.isModalInPresentation = true
//        vc.modalPresentationStyle = .pageSheet
//        self.present(vc, animated: true)
        
        let vc: LocationDetailsVC = LocationDetailsVC.instantiate(appStoryboard: .main)
        vc.flowLocation = .fromReviewPackage
        vc.isModalInPresentation = true
        vc.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        } else {
            // Fallback on earlier versions
        }
        
        vc.callBackNewAddressAdded = {
                    TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
                        guard let self = self, let getResultData = getResultData else { return  }
                        print("getResultData", getResultData.data as Any)
                        self.currentSelectedAddress = 0
                        self.addressData = []
                        self.addressData?.append(contentsOf: getResultData.data ?? [])
                        self.tableViewAddress.reloadData()
                    })
                }
        vc.callBackSetLocation = { (location, title , subtitle) in
//            self.addMarkers(marker: MarkerModel(latitude: location.latitude, longitude: location.longitude, title: title, snippet: subtitle, iconImageName: AppImages.Radius))
//            self.mainAddrLbl.text = title
//            self.subAddrLbl.text = subtitle
        }
        
//        vc.callBackEditAddress = { (currentAddress, mainAddress, subAddress , addressDataReceived) in
//            
//            let vc: AddNewAddressVC = AddNewAddressVC.instantiate(appStoryboard: .purchase)
//            vc.currentAddress = currentAddress
//            vc.getAddressData = addressDataReceived
////            vc.tfAddressLabel.text = currentAddress
////            vc.tfCity.text = addressDataReceived?.city_name
////            vc.tfStreetName.text = addressDataReceived?.street?.value
////            vc.tfBuildingName.text = addressDataReceived?.building_name?.value
//            vc.isModalInPresentation = true
//            vc.modalPresentationStyle = .pageSheet
//            self.present(vc, animated: true)
//        }
//        
//        vc.callBackSetLocation = { (location, title , subtitle) in
////            self.addMarkers(marker: MarkerModel(latitude: location.latitude, longitude: location.longitude, title: title, snippet: subtitle, iconImageName: AppImages.Radius))
////            self.mainAddrLbl.text = title
////            self.subAddrLbl.text = subtitle
//            
//                    let vc: AddNewAddressVC = AddNewAddressVC.instantiate(appStoryboard: .purchase)
//                    vc.isModalInPresentation = true
//                    vc.modalPresentationStyle = .pageSheet
//                    self.present(vc, animated: true)
//        }
        present(vc, animated: true)
    }
    
}
extension ChooseAddressPopUpVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.addressData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTVC", for: indexPath) as? AddressTVC else {
            return UITableViewCell()
        }
        cell.configure(addressData: self.addressData?[indexPath.row])
        cell.imgSelectedStatus.image = UIImage(named: indexPath.row == currentSelectedAddress ? "Radio" : "Unradio")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TapticEngine.selection.feedback()
        let previousCell = self.tableViewAddress.cellForRow(at: IndexPath(item: currentSelectedAddress, section: 0)) as? AddressTVC
        previousCell?.imgSelectedStatus.image = UIImage(named: "Unradio")
        let newCell = self.tableViewAddress.cellForRow(at: indexPath) as? AddressTVC
        newCell?.imgSelectedStatus.image = UIImage(named: "Radio")
        currentSelectedAddress = indexPath.item
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
}
