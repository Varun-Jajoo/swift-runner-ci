//
//  UserPlansCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 10/07/25.
//

import UIKit

class UserPlansCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var planCellMBV: UIView!
    @IBOutlet weak var planImgView: UIImageView!
    @IBOutlet weak var planNameLbl: UILabel!
    @IBOutlet weak var progressMBV: UIView!
    @IBOutlet weak var sessionDescLbl: UILabel!
    @IBOutlet weak var planSaveBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        setupFont()
    }
    
    func setupCell(cellData: OtherSubscriptionsModel?){
        guard let cellData = cellData else { return }
        self.planImgView.loadImage(urlString: cellData.tier_image, placeholder: nil, resize: CGSize(width: 100.0, height: 100.0))
        self.planNameLbl.text = cellData.getTier
        if let remainingSession = cellData.remaining_sessions?.value, let remainingDays = cellData.remaining_days?.value {
            self.sessionDescLbl.text = "\(remainingSession) Sessions Remaining ending in \(remainingDays) days"
        }
        
        if let remainingSessions = cellData.remaining_sessions?.value, let totalSessions = cellData.total_sessions?.value {
            let progressRateSession = ((Double(remainingSessions) ?? 0.0) / (Double(totalSessions) ?? 0.0))
            DispatchQueue.main.async {
                self.progressMBV.drawLineProgress(progressfill: progressRateSession, fillLineColor: UIColor.appWhite, cornerRadius: 3.0)
            }
        }
        
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.planCellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.planImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
          
            self.planSaveBtn.addGradient(colors: [UIColor(red: 29.0/255.0, green: 215.0/255.0, blue: 148.0/255.0, alpha: 1.0),UIColor(red: 9.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0), UIColor(red: 9.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0)], locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: self.planSaveBtn.frame.size.height/2.0)
           
            self.progressMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
//            self.progressMBV.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor.appWhite, cornerRadius: 3.0)
        }
    }
    
    private func setupFont(){
        planNameLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        [
            sessionDescLbl,
            planSaveBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
    }

}
