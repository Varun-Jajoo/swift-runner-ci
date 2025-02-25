//
//  UpcomingClassCollViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 11/11/24.
//

import UIKit

class UpcomingClassCollViewCell: UICollectionViewCell {

    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var mainBckImgView: UIImageView!
    @IBOutlet weak var dateMBV: UIView!
    @IBOutlet weak var descMBV: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var upcomingTitleLbl: UILabel!
    @IBOutlet weak var upcomingLocLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var onwardsLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        setUpFont()
        DispatchQueue.main.async {
            self.mainBckImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.dateMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.descMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
        
        //-------------------- Attributed Text for Price
        
        let defaultAttributes = [
            .font: AppFont.medium.size(20.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.medium.size(12.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "299",
            NSAttributedString(string: "AED",
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.amountLbl.attributedText       =  NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
    
    //------------------************Font
    func setUpFont(){
        self.dateLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.upcomingTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.upcomingLocLbl.font = AppFont.regular.size(10.0, familyName: familyManrope)
//        self.amountLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.onwardsLbl.font = AppFont.medium.size(12.0, familyName: familyClashDisplay)
    }

}
