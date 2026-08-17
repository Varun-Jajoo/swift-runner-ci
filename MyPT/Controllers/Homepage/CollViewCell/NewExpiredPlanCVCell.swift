//
//  NewExpiredPlanCVCell.swift
//  MyPT
//
//  Created by Manik Goel on 13/08/26.
//

import UIKit

class NewExpiredPlanCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewPlan: UIView!
    @IBOutlet weak var imgPlan: UIImageView!
    @IBOutlet weak var lblPlanImg: UILabel!
    @IBOutlet weak var lblExpiredDate: UILabel!
    @IBOutlet weak var lblNoPlan: UILabel!
    @IBOutlet weak var lblRenewPlan: UILabel!
    @IBOutlet weak var viewRenewPlan: UIView!
    @IBOutlet weak var btnRenewNow: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }
    
    private func uiSetup() {
        self.lblPlanImg.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.lblExpiredDate.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.lblNoPlan.font = AppFont.regular.size(20.0, familyName: familyClashDisplay)
        self.lblRenewPlan.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        self.imgPlan.setCornerRadius(cornerRadious: 16)
        self.btnRenewNow.setTitle("RENEW NOW", for: .normal)
        self.btnRenewNow.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnRenewNow.tintColor = .mainBg   // arrow color
        self.btnRenewNow.backgroundColor = .appWhite
        self.btnRenewNow.setTitleColor(.mainBg, for: .normal)
        DispatchQueue.main.async {
            self.viewRenewPlan.cornersWithBorder(
                radius: 12,
                corners: .allCorners,
                borderColor: UIColor(red: 238/255, green: 77/255, blue: 55/255, alpha: 0.13),
                borderWidth: 3
            )
            self.viewPlan.cornersWithBorder(
                radius: 12,
                corners: .allCorners,
                borderColor: UIColor(red: 238/255, green: 77/255, blue: 55/255, alpha: 0.13),
                borderWidth: 3
            )
            self.btnRenewNow.cornersWithBorder(radius: 8, corners: .allCorners)
        }
    }
    
    func configure(with model: PlanDetailsModel) {
        
        let total = CGFloat(model.sessions?.intValue ?? 0)
        let remaining = CGFloat(model.remaining_sessions?.intValue ?? 0)
        let used = total - remaining
        
        // Labels
        lblPlanImg.text = model.name?.value
//        lblRemainingSession.text = model.is_membership ?? false ? "\(Int(remaining)) days remaining" : "\(Int(remaining)) sessions remaining"
//        lblTotalSesion.text = model.is_membership ?? false ? "Total \(Int(total)) days" : "Total \(Int(total)) sessions"
//        lblSessionUtilization.text = model.is_membership ?? false ? "Days Utilization" : "Session Utilization"
        
        if let remainingDays = model.remaining_days?.intValue {
//            lblValidDate.text = "Valid for \(remainingDays) days"
        }
        
//        if let imageUrl = model.image {
//            self.imgPlan.loadImage(urlString: imageUrl, placeholder: nil)
//        }
//        lblMsg.text = model.msg?.value
        lblExpiredDate.text = model.end_date?.value
//        // Progress
//        progressBar.total = total
//        progressBar.setProgress(used)
    }

}
