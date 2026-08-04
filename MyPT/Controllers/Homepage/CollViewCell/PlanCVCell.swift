//
//  PlanCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 16/02/26.
//

import UIKit

class PlanCVCell: UICollectionViewCell {
    
    private let progressBar = GradientProgressBar()

    @IBOutlet weak var viewPlan: UIView!
    @IBOutlet weak var imgPlan: UIImageView!
    @IBOutlet weak var lblPlanImg: UILabel!
    @IBOutlet weak var lblValidDate: UILabel!
    @IBOutlet weak var lblRemainingSession: UILabel!
    @IBOutlet weak var lblSessionUtilization: UILabel!
    @IBOutlet weak var lblTotalSesion: UILabel!
    @IBOutlet weak var viewProgress: UIView!
    @IBOutlet weak var btnUseSession: UIButton!
    @IBOutlet weak var btnBuyMore: UIButton!
    @IBOutlet weak var lblGymExpiry: UILabel!
    
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
        self.lblValidDate.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.lblRemainingSession.font = AppFont.medium.size(20, familyName: familyClashDisplay)
        self.lblSessionUtilization.font = AppFont.regular.size(12, familyName: familyFunnelSans)
        self.lblTotalSesion.font = AppFont.regular.size(12, familyName: familyFunnelSans)
        self.lblGymExpiry.font = AppFont.regular.size(12, familyName: familyFunnelSans)
        self.imgPlan.setCornerRadius(cornerRadious: 16)
        self.btnUseSession.backgroundColor = .white
        self.btnUseSession.setTitleColor(.black, for: .normal)
        self.btnUseSession.setCornerRadius(cornerRadious: 8)
        self.btnUseSession.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
    func configure(with model: PlanDetailsModel) {
        
        let totalSession = CGFloat(model.sessions?.intValue ?? 0)
        let remainingSession = CGFloat(model.remaining_sessions?.intValue ?? 0)
        let usedSession = totalSession - remainingSession
        
        let totalDays = CGFloat(model.validity_days?.intValue ?? 0)
        let remainingDays = CGFloat(model.remaining_days?.intValue ?? 0)
        let usedDays = totalDays - remainingDays
        
        // Labels
        lblPlanImg.text = model.name?.value
        lblGymExpiry.text = model.end_date?.value
        lblGymExpiry.isHidden = !(model.is_membership ?? false)
//        lblRemainingSession.text = "\(Int(remaining)) sessions remaining"
//        lblTotalSesion.text = "Total \(Int(total)) sessions"
        
        lblRemainingSession.text = model.is_membership ?? false ? "\(Int(remainingDays)) days remaining" : "\(Int(remainingSession)) sessions remaining"
        lblTotalSesion.text = model.is_membership ?? false ? "\(Int(usedDays)) of \(Int(totalDays)) total" : "Total \(Int(totalSession)) sessions"
        lblSessionUtilization.text = model.is_membership ?? false ? "Day Used" : "Session Utilization"
        
        if let remainingDays = model.remaining_days?.intValue, let gymName = model.studio_name {
            lblValidDate.text = (model.is_membership ?? false) ? gymName : "Valid for \(remainingDays) days"
        }
        
        if let imageUrl = model.image {
            self.imgPlan.loadImage(urlString: imageUrl, placeholder: nil)
        }
        // Progress
        progressBar.total = model.is_membership ?? false ? totalDays : totalSession
        progressBar.setProgress(model.is_membership ?? false ? usedDays : usedSession)
        btnBuyMore.isHidden = true
        btnUseSession.setTitle((model.is_membership ?? false ? "RENEW MEMBERSHIP" : "USE SESSION"), for: .normal)
    }

    @IBAction func onTapUseSession(_ sender: UIButton) {
    }
    
    @IBAction func onTapBuyMOre(_ sender: UIButton) {
    }
}
