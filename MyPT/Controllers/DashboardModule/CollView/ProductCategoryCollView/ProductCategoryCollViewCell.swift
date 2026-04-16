//
//  ProductCategoryCollViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 11/11/24.
//

import UIKit

class ProductCategoryCollViewCell: UICollectionViewCell {
    
    var shouldHandleSelection: Bool = true   // 🔥 NEW FLAG
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var titleLblTopConstrnt: NSLayoutConstraint!
    @IBOutlet weak var titleLblLeading: NSLayoutConstraint!
    @IBOutlet weak var imgBackground: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpFont()
        DispatchQueue.main.async {
            self.imgBackground.isHidden = false
            self.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(hex: "#2B2C2D"), cornerRadious: 8)
            self.cellMBV.backgroundColor = UIColor(hex: "#131416")
        }
    }
    
    //------------------************Font
    func setUpFont() {
        self.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
    }
    
    
    override var isSelected: Bool {
        didSet {
            guard shouldHandleSelection else { return } // ✅ key line
            if self.isSelected {
                self.cellMBV.backgroundColor = UIColor.clear
                self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 8.0)
            } else {
                self.cellMBV.backgroundColor = UIColor.clear
                self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            }
        }
    }
}
