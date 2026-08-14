//
//  RenewPlanTVCell.swift
//  MyPT
//
//  Created by Manik Goel on 14/08/26.
//

import UIKit

class RenewPlanTVCell: UITableViewCell {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var lblPlanType: UILabel!
    @IBOutlet weak var lblTrainingType: UILabel!
    @IBOutlet weak var lblRemainingSession: UILabel!
    @IBOutlet weak var lblRemainingSessionData: UILabel!
    @IBOutlet weak var lblValidDays: UILabel!
    @IBOutlet weak var lblValidDaysData: UILabel!
    @IBOutlet weak var viewSaveAED: UIView!
    @IBOutlet weak var lblSaveAED: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var heightOfTopView: NSLayoutConstraint!
    @IBOutlet weak var heightOfBottomView: NSLayoutConstraint!
    @IBOutlet weak var imgPlanType: UIImageView!
    @IBOutlet weak var viewExpired: UIView!
    @IBOutlet weak var lblExpiredActive: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }

    private func uiSetup() {
        lblPlanType.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        lblTrainingType.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        lblRemainingSession.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        lblRemainingSessionData.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        lblValidDays.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        lblValidDaysData.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        lblSaveAED.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        lblExpiredActive.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        viewBackground.setCornerRadius(cornerRadious: 12.0)
        viewExpired.layer.cornerRadius = 8
        viewExpired.layer.masksToBounds = true
        viewExpired.layer.borderWidth = 1
        viewSaveAED.layer.cornerRadius = 8
        viewSaveAED.layer.masksToBounds = true
        viewSaveAED.layer.borderWidth = 1
        viewSaveAED.layer.borderColor = UIColor(red: 56/255, green: 118/255, blue: 45/255, alpha: 1).cgColor
    }
    
    func configure(with model: PlanDetailsModel) {
        lblPlanType.text = model.name?.value
        lblTrainingType.text = (model.is_membership ?? false) ? "Gym Access" : "Personal Training"
        lblRemainingSessionData.text = "\(model.remaining_sessions?.value ?? "0")"
        lblValidDaysData.text = "\(model.validity_days?.value ?? "0") days"
        
        let hasSaveMsg = !(model.msg?.value ?? "").isEmpty
        if hasSaveMsg {
            lblSaveAED.text = model.msg?.value
            viewSaveAED.isHidden = false
        } else {
            lblSaveAED.text = ""
            viewSaveAED.isHidden = true
        }
        
        let isExpired = model.is_expired ?? false
        viewBottom.isHidden = isExpired
        viewSeparator.isHidden = isExpired
        
        let isMembership = model.is_membership ?? false
        lblValidDays.isHidden = isMembership
        lblValidDaysData.isHidden = isMembership
        if isMembership {
            lblRemainingSession.text = "DAYS REMAINING"
            lblRemainingSessionData.text = "\(model.validity_days?.value ?? "0")"
        } else {
            lblRemainingSession.text = "SESSIONS REMAINING"
        }
        
        if isExpired {
            lblExpiredActive.text = "Expired"
            lblExpiredActive.textColor = UIColor(red: 254/255, green: 248/255, blue: 221/255, alpha: 1)
            viewExpired.backgroundColor = UIColor(red: 161/255, green: 67/255, blue: 50/255, alpha: 1)
            viewExpired.layer.borderColor = UIColor(red: 111/255, green: 45/255, blue: 33/255, alpha: 1).cgColor
            heightOfBottomView.constant = 0
            heightOfTopView.constant = 85.67
        } else {
            lblExpiredActive.text = "Active"
            lblExpiredActive.textColor = UIColor(red: 214/255, green: 235/255, blue: 207/255, alpha: 1)
            viewExpired.backgroundColor = UIColor(red: 45/255, green: 51/255, blue: 43/255, alpha: 1)
            viewExpired.layer.borderColor = UIColor(red: 72/255, green: 117/255, blue: 55/255, alpha: 1).cgColor
            heightOfBottomView.constant = hasSaveMsg ? 131.33 : 85.33
            heightOfTopView.constant = 85.67
        }
        imgPlanType.image = UIImage(named: (model.is_membership ?? false) ? "GymContainer" : "PtContainer")
    }
}
