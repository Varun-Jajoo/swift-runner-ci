//
//  PlanListTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 25/12/24.
//

import UIKit

class PlanListTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var planLogoImgView: UIImageView!
    @IBOutlet weak var forwardImgView: UIImageView!
    @IBOutlet weak var planTitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.planTitleLbl.font = AppFont.bold.size(18.0, familyName: familyManrope)
        
        DispatchQueue.main.async {
            self.planLogoImgView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 16.0)
            self.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1.0, y: 1.0))
            self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.cellMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 0.4, opacity: 0.7, offset: .zero, cornerRadius: 12.0)
        }
    }
    
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
