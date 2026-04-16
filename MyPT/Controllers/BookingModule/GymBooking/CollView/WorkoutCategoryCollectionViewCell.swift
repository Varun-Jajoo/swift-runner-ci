//
//  WorkoutCategoryCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 21/11/24.
//

import UIKit

class WorkoutCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var categoryImgView: UIImageView!
    @IBOutlet weak var categoryTitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpFont()
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
        }
    }
    
    func setUpFont() {
        self.categoryTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
    }

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.cellMBV.backgroundColor = UIColor(red: 19.0/255.0, green: 31.0/255.0, blue: 10.0/255.0, alpha: 1.0)
                self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 103.0/255.0, green: 119.0/255.0, blue: 36.0/255.0, alpha: 1.0), cornerRadious: self.cellMBV.frame.size.height/2.0) //12.0
            } else {
                self.cellMBV.backgroundColor = UIColor.clear
                self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.cellMBV.frame.size.height/2.0)
            }
        }
    }
}
