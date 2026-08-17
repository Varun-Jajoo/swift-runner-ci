//
//  ExpiredPlanCVCell.swift
//  MyPT
//
//  Created by Manik Goel on 14/04/26.
//

import UIKit

class ExpiredPlanCVCell: UICollectionViewCell {

    private let progressBar = GradientProgressBar()

    @IBOutlet weak var viewPlan: UIView!
    @IBOutlet weak var imgPlan: UIImageView!
    @IBOutlet weak var lblPlanImg: UILabel!
    @IBOutlet weak var lblExpiredDate: UILabel!
    @IBOutlet weak var lblRemainingSession: UILabel!
    @IBOutlet weak var lblSessionUtilization: UILabel!
    @IBOutlet weak var lblTotalSesion: UILabel!
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var btnRenewNow: UIButton!
    @IBOutlet weak var viewMsg: UIView!
    @IBOutlet weak var lblMsg: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
            uiSetup()
            progressBar.translatesAutoresizingMaskIntoConstraints = false
            viewProgress.addSubview(progressBar)

            NSLayoutConstraint.activate([
                progressBar.leadingAnchor.constraint(equalTo: viewProgress.leadingAnchor),
                progressBar.trailingAnchor.constraint(equalTo: viewProgress.trailingAnchor),
                progressBar.topAnchor.constraint(equalTo: viewProgress.topAnchor),
                progressBar.bottomAnchor.constraint(equalTo: viewProgress.bottomAnchor)
            ])
        }

    
    private func uiSetup() {
        self.lblPlanImg.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.lblExpiredDate.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.lblMsg.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.lblRemainingSession.font = AppFont.medium.size(20, familyName: familyClashDisplay)
        self.lblSessionUtilization.font = AppFont.regular.size(12, familyName: familyFunnelSans)
        self.lblTotalSesion.font = AppFont.regular.size(12, familyName: familyFunnelSans)
        self.imgPlan.setCornerRadius(cornerRadious: 16)
//        self.viewPlan.setCornerRadius(cornerRadious: 12)
//        self.viewMsg.setCornerRadius(cornerRadious: 12)
        self.btnRenewNow.setTitle("RENEW NOW", for: .normal)
        self.btnRenewNow.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnRenewNow.tintColor = .mainBg   // arrow color
        self.btnRenewNow.backgroundColor = .appWhite
        self.btnRenewNow.setTitleColor(.mainBg, for: .normal)
        DispatchQueue.main.async {
            self.viewMsg.cornersWithBorder(
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
        lblRemainingSession.text = model.is_membership ?? false ? "\(Int(remaining)) days remaining" : "\(Int(remaining)) sessions remaining"
        lblTotalSesion.text = model.is_membership ?? false ? "Total \(Int(total)) days" : "Total \(Int(total)) sessions"
        lblSessionUtilization.text = model.is_membership ?? false ? "Days Utilization" : "Session Utilization"
        
        if let remainingDays = model.remaining_days?.intValue {
//            lblValidDate.text = "Valid for \(remainingDays) days"
        }
        
//        if let imageUrl = model.image {
//            self.imgPlan.loadImage(urlString: imageUrl, placeholder: nil)
//        }
        lblMsg.text = model.msg?.value
        lblExpiredDate.text = model.end_date?.value
        // Progress
        progressBar.total = total
        progressBar.setProgress(used)
    }
    
}
