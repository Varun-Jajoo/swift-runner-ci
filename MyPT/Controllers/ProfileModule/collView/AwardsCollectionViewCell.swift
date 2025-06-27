//
//  AwardsCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 13/06/25.
//

import UIKit

class AwardsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var awardsImgVIew: UIImageView!
    @IBOutlet weak var awardTitleLbl: UILabel!
    @IBOutlet weak var awardWeightLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        setupUI()
        setupFont()
    }

//    private func setupUI(){
//        DispatchQueue.main.async {
//            self.awardsImgVIew.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: self.awardsImgVIew.frame.size.height/2.0)
//        }
//    }
    
    private func setupFont(){
        awardTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        awardWeightLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
    }
}
