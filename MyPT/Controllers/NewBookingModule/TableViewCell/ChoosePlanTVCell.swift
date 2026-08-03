//
//  ChoosePlanTVCell.swift
//  MyPT
//
//  Created by Manik Goel on 16/07/26.
//

import UIKit

class ChoosePlanTVCell: UITableViewCell {
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var lblPackageName: UILabel!
    @IBOutlet weak var imgSession: UIImageView!
    @IBOutlet weak var lblSession: UILabel!
    @IBOutlet weak var lblAvlAED: UILabel!
    @IBOutlet weak var lblNonAvlAED: UILabel!
    @IBOutlet weak var lblValidDays: UILabel!
    @IBOutlet weak var viewRound: UIView!
    @IBOutlet weak var lblPerSession: UILabel!
    @IBOutlet weak var imgSaveAED: UIImageView!
    @IBOutlet weak var lblSaveAED: UILabel!
    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var viewSessions: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }

    private func uiSetup() {
        lblPackageName.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        lblSession.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        lblAvlAED.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        lblNonAvlAED.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        lblPerSession.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        lblValidDays.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        lblSaveAED.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        viewBackground.setCornerRadius(cornerRadious: 12.0)
    }
    
    func configure(with model: BestPlanData, isSelected: Bool) {
        lblPackageName.text = model.title
        
        if let sessions = model.sessions {
            lblSession.text = "\(sessions) SESSIONS"
        } else {
            lblSession.text = ""
        }
        
        lblAvlAED.text = (model.currency ?? "") + " " + (model.price ?? "")
        lblNonAvlAED.isHidden = true
        
        if let pricePerSession = model.pricePerSession {
            lblPerSession.text = (model.currency ?? "") + " " + pricePerSession + "/session"
            viewRound.isHidden = false
        } else {
            lblPerSession.text = ""
            viewRound.isHidden = true
        }
        
        lblValidDays.text = model.validityText
        
        if let badgeText = model.badgeText, !badgeText.isEmpty {
            lblSaveAED.text = badgeText
            imgSaveAED.isHidden = false
            lblSaveAED.isHidden = false
        } else {
            lblSaveAED.text = ""
            imgSaveAED.isHidden = true
            lblSaveAED.isHidden = true
        }
        
        if let bgImage = model.backgroundImage {
            imgBackground.loadImage(urlString: bgImage, placeholder: nil)
        } else {
            imgBackground.image = UIImage(named: "BlackBG")
        }
        
        let selectImage = isSelected ? UIImage(named: "ic_filterChecked") : UIImage(named: "ic_filterUncheck")
        imgSelected.image = selectImage
    }
}
