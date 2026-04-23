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
        self.imgPlan.setCornerRadius(cornerRadious: 16)
    }
    
    func configure(with model: PlanDetailsModel) {
        
        let total = CGFloat(model.sessions?.intValue ?? 0)
        let remaining = CGFloat(model.remaining_sessions?.intValue ?? 0)
        let used = total - remaining
        
        // Labels
        lblPlanImg.text = model.name?.value
        lblRemainingSession.text = "\(Int(remaining)) sessions remaining"
        lblTotalSesion.text = "Total \(Int(total)) sessions"
        
        if let remainingDays = model.remaining_days?.intValue {
            lblValidDate.text = "Valid for \(remainingDays) days"
        }
        
        if let imageUrl = model.image {
            self.imgPlan.loadImage(urlString: imageUrl, placeholder: nil)
        }
        // Progress
        progressBar.total = total
        progressBar.setProgress(used)
    }

    
    @IBAction func onTapUseSession(_ sender: UIButton) {
        
    }
    
    
    @IBAction func onTapBuyMOre(_ sender: UIButton) {
    }
    
}
