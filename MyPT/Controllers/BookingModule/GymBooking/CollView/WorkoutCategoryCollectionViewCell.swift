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
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
        }
    }

    
    //------------------************Font
    func setUpFont(){
        self.categoryTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
    
    
    override var isSelected: Bool {
            didSet {
                if self.isSelected {
                    self.cellMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0)
                    self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: self.cellMBV.frame.size.height/2.0) //12.0
                }
                else {
                    self.cellMBV.backgroundColor = UIColor.clear
                    self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.cellMBV.frame.size.height/2.0)
                }
            }
        }
    
}
