//
//  TrainerFilterTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 02/07/25.
//

import UIKit

class TrainerFilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var selectionBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellMBV.removeGradient()
        removeLeftBorder(named: "left_border")
        titleLbl.textColor = UIColor.appWhite
    }
    
    func addLeftBorder(borderColor: UIColor? = UIColor.clear, cornerRadius: CGFloat = 2.5, borderWidth: CGFloat = 5.0) {
        /*
        let leftBorder = CALayer()
        self.cellMBV.layer.sublayers?.removeAll(where: { $0.name == "left_border" })
        leftBorder.name = "left_border"
        leftBorder.backgroundColor = borderColor?.cgColor // Set your border color
        DispatchQueue.main.async {
            leftBorder.frame = CGRect(x: 0, y: 0, width: 5.0, height: self.cellMBV.frame.height)
        }
        self.cellMBV.layer.addSublayer(leftBorder)
        */
        
        let leftBorder = CALayer()
        self.cellMBV.layer.sublayers?.removeAll(where: { $0.name == "left_border" })
        leftBorder.name = "left_border"
        leftBorder.backgroundColor = borderColor?.cgColor

        DispatchQueue.main.async {
            let height = self.cellMBV.frame.height
            leftBorder.frame = CGRect(x: 0, y: 0, width: borderWidth, height: height)
            leftBorder.cornerRadius = cornerRadius

            // Optional: Mask only specific corners if needed (iOS 11+)
            if #available(iOS 11.0, *) {
                leftBorder.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner] // //[.layerMinXMinYCorner, .layerMinXMaxYCorner] // top-left & bottom-left
            }
        }

        self.cellMBV.layer.addSublayer(leftBorder)
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
    
    func removeLeftBorder(named name: String = "left_border") {
        self.cellMBV.layer.sublayers?.removeAll(where: { $0.name == name })
    }
    
}
