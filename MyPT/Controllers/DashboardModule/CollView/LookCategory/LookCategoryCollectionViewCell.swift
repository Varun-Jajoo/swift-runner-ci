//
//  LookCategoryCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/05/25.
//

import UIKit

class LookCategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var categoryBckImgView: UIImageView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var nearYouLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.setupFont()
    }

    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.cellMBV.setGradientBorder(cornerRadious: 20.0, width: 1, colors: [
                UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1.0),
                UIColor(red: 135/255.0, green: 143/255.0, blue: 160/255.0, alpha: 1.0)
            ], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            
            self.categoryBckImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.categoryBckImgView.addGradientImgV(colors: [
                UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 54.0/255.0, alpha: 1.0),
                UIColor(red: 13.0/255.0, green: 14.0/255.0, blue: 17.0/255.0, alpha: 0.31),
                UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            ], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0))
        }
    }
    
    private func setupFont(){
        self.categoryNameLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.nearYouLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
}
