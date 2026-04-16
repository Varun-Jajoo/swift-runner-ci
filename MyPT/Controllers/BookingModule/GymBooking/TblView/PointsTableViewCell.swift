//
//  PointsTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/12/24.
//

import UIKit

class PointsTableViewCell: UITableViewCell {

    //MARK: -------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var leftImgView: UIImageView!
    @IBOutlet weak var leftIgViewTrailingConstrnt: NSLayoutConstraint!
    @IBOutlet weak var widthImgViewConstrnt: NSLayoutConstraint!
    @IBOutlet weak var cellMBVBottomConstrnt: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLbl.font = AppFont.regular.size(14, familyName: familyFunnelSans)
        
        DispatchQueue.main.async {
            self.leftImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.leftImgView.frame.height/2.0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
