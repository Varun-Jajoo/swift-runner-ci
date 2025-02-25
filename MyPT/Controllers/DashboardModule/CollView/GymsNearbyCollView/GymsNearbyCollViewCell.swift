//
//  GymsNearbyCollViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 11/11/24.
//

import UIKit

class GymsNearbyCollViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var gymImgView: UIImageView!
    @IBOutlet weak var myStudioImgView: UIImageView!
    @IBOutlet weak var gymNameLbl: UILabel!
    @IBOutlet weak var distance: UIButton!
    @IBOutlet weak var landmark: UIButton!
    @IBOutlet weak var timing: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var crossfittLbl: UILabel!
    @IBOutlet weak var categoryGymsLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var voucherImgView: UIImageView!
    @IBOutlet weak var voucherLbl: UILabel!
    @IBOutlet weak var ratingGym: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpFont()
        DispatchQueue.main.async {
            self.voucherImgView.roundBottomCorners(radius: 8.0)
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.gymImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
            self.cellMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .axial)
            //rgba(16, 17, 19, 1)
            //rgba(71, 77, 96, 1)
        }
    }

    //------------------************Font
    func setUpFont(){
        
        self.voucherLbl.font = AppFont.bold.size(10.0, familyName: familyManrope)
        self.gymNameLbl.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        self.distance.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.landmark.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.timing.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.descLbl.font = AppFont.regular.size(10.0, familyName: familyManrope)
        self.crossfittLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.categoryGymsLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.countLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.ratingGym.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
    
    
}
