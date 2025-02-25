//
//  UpcomingSessionsCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/11/24.
//

import UIKit

class UpcomingSessionsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var sessionDateLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var addrBtn: UIButton!
    @IBOutlet weak var bottomMBV: UIView!
    @IBOutlet weak var noteLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24.0)
            self.bgImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24.0)
            self.bottomMBV.roundSideCorners(radius: 24.0, cornerSide: [.topLeft])
            
            self.cellMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0).cgColor,UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0).cgColor, UIColor(red: 42/255.0, green: 45/255.0, blue: 54/255.0, alpha: 1).cgColor], type: .axial)
            
            
            
            self.bottomMBV.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.7)
        }
        
    }

}
