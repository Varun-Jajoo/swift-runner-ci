//
//  RatingsCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/12/24.
//

import UIKit
import Cosmos

class RatingsCollectionViewCell: UICollectionViewCell {

    //MARK: -------------- IBOULET
    @IBOutlet weak var celMBV: UIView!
    @IBOutlet weak var ratingMBV: CosmosView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var reviewMsgLbl: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dayLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        reviewMsgLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        reviewMsgLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        
        DispatchQueue.main.async {
            self.celMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .axial)
            
            self.celMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.userImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.userImgView.frame.height/2.0)
        }
    }

}
