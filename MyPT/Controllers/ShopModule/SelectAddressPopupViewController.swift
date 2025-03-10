//
//  SelectAddressPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 06/03/25.
//

import UIKit

class SelectAddressPopupViewController: UIViewController {

    //MARK: --------------IBOUTLET
    @IBOutlet weak var addressPopupMBV: UIView!
    @IBOutlet weak var checkPinMBV: UIView!
    @IBOutlet weak var deliveryAddrMBV: UIView!
    @IBOutlet weak var deliveryAddressTitleLbl: UILabel!
    @IBOutlet weak var savedAddressTitleLbl: UILabel!
    @IBOutlet weak var homeDeliveryTitleLbl: UILabel!
    @IBOutlet weak var homeAddressLbl: UILabel!
    @IBOutlet weak var checkPincodeBtn: UIButton!
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var cancelOrderBtn: UIButton!
    @IBOutlet weak var pincodeTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFont()
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
    
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.addressPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.checkPinMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appDarkGray, cornerRadious: 8.0)
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
        self.pincodeTxtField.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        self.pincodeTxtField.placeholderSet(placeHolder: "Enter Postcode", color: UIColor.appWhite.withAlphaComponent(0.7))
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
