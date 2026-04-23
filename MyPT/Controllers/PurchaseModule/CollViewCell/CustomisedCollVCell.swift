//
//  CustomisedCollVCell.swift
//  DemoCards
//
//  Created by techsaga on 17/01/26.
//

import UIKit

    class CustomisedCollVCell: UICollectionViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSession: UILabel!
    @IBOutlet weak var lblAED: UILabel!
    @IBOutlet weak var lblAEDSEssion: UILabel!
    @IBOutlet weak var lblValidDays: UILabel!
    @IBOutlet weak var lblSavedAED: UILabel!
    @IBOutlet weak var viewSavedAED: UIView!
    @IBOutlet weak var viewCircle: UIView!
    @IBOutlet weak var viewSecCircle: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }
    
    private func uiSetup() {
        self.lblName.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        self.lblSession.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        self.lblAED.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.lblValidDays.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        self.lblAEDSEssion.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        self.lblSavedAED.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        self.viewSavedAED.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 56/255, green: 118/255, blue: 45/255, alpha: 1), cornerRadious: 8)
        self.viewCircle.transform = CGAffineTransform(rotationAngle: .pi / 4)
        self.viewSecCircle.transform = CGAffineTransform(rotationAngle: .pi / 4)
    }
    
    func cellConfigure(customData : CustoomiseData?) {
        lblName.text = ""
        lblSession.text = "\(customData?.details?.sessions ?? "1") sessions"
        lblAED.text = "AED \(customData?.totalPrice ?? 0)"
        lblAEDSEssion.text = "AED \(customData?.pricePerSession?.value ?? "")/session"
        lblValidDays.text = "valid for \(customData?.totalDays ?? 0) days"
        lblSavedAED.text = customData?.save_price ?? "Saved AED 0"
    }
        
    func cellGymMembershipConfigure(customData: ValityPackageDetailModel?) {
        lblName.text = customData?.name ?? ""
        lblSession.text = "\(customData?.validity?.value ?? "1") Days"
        lblAED.text = "AED \(customData?.price?.value ?? "0")"
        lblAEDSEssion.isHidden = true
        viewSecCircle.isHidden = true
        lblValidDays.isHidden = true
        lblSavedAED.text = customData?.special_msg ?? ""
        viewSavedAED.isHidden = customData?.special_msg == nil
    }
}
