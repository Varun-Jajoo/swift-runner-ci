//
//  PurchasePopupVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 25/01/26.
//

import UIKit

class PurchasePopupVC: UIViewController {
    
    var callBack: (() -> Void)?
    var couponData: CoupenData?
    
    @IBOutlet weak var Viewcenter: UIView!
    @IBOutlet weak var lblGymName: UILabel!
    @IBOutlet weak var lblAED: UILabel!
    @IBOutlet weak var lblBookSession: UILabel!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var btnProceed: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setupUI()
        setData()
    }
   
    private func uiSetup() {
        self.lblGymName.font = AppFont.regular.size(16, familyName: familyFunnelSans)
        self.lblAED.font = AppFont.medium.size(28, familyName: familyClashDisplay)
        self.lblBookSession.font = AppFont.regular.size(16, familyName: familyFunnelSans)
        self.btnProceed.setTitle("PROCEED   ", for: .normal)
        self.btnProceed.setImage(UIImage(named: "blackArrowRight"), for: .normal)
        self.btnProceed.semanticContentAttribute = .forceRightToLeft
        self.btnProceed.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnProceed.tintColor = .mainBg   // arrow color
        self.btnProceed.backgroundColor = .appWhite
        self.btnProceed.setTitleColor(.mainBg, for: .normal)
    }
    
    private func setupUI() {
        self.btnProceed.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
    }
    
    func setData() {
        lblGymName.text = couponData?.offerCode
        lblAED.text = couponData?.description
        lblBookSession.text = (couponData?.offerCode ?? "") + " every time you book sessions"
    }
    
    @IBAction func onTapProceed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.callBack?()
        })
    }
    
    @IBAction func onTapDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
