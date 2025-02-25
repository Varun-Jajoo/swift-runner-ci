//
//  FilterCategoryCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 25/12/24.
//

import UIKit

class FilterCategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var gymCategoryImgView: UIImageView!
    @IBOutlet weak var gymCategoryImgWidthConstrnt: NSLayoutConstraint!
    @IBOutlet weak var gymCategoryNameLbl: UILabel!
    @IBOutlet weak var selectionImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupFont()
        
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
        }
    }

    func setupFont(){
        self.gymCategoryNameLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
    
}
