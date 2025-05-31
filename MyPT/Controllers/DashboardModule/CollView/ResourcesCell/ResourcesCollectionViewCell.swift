//
//  ResourcesCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 09/05/25.
//

import UIKit

class ResourcesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var bckImgView: UIImageView!
    @IBOutlet weak var resourceTitleLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var dot1Btn: UIButton!
    @IBOutlet weak var viewsCountBtn: UIButton!
    @IBOutlet weak var dot2Btn: UIButton!
    @IBOutlet weak var likesCountBtn: UIButton!
    @IBOutlet weak var stckBottomConstrnt: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupFont()
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            self.bckImgView.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 24.0)
          
//            self.bckImgView.addGradientImgV(colors: [UIColor.red, UIColor.green, UIColor.appLightYellow], locations: [0, 0.3, 1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0))
          
//            self.bckImgView.addGradientImgV(colors: [UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 54.0/255.0, alpha: 1.0), UIColor(red: 13.0/255.0, green: 14.0/255.0, blue: 17.0/255.0, alpha: 0.31), UIColor(red: 0, green: 0, blue: 0, alpha: 0)], locations: [0, 0.3, 1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0))
            
            self.bckImgView.addGradientImgV(colors: [UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 54.0/255.0, alpha: 1.0), UIColor(red: 13.0/255.0, green: 14.0/255.0, blue: 17.0/255.0, alpha: 0.31), UIColor(red: 0, green: 0, blue: 0, alpha: 0)], locations: [0, 0.3, 1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1, y: 0))
            
        }
        
    }
    
    private func setupFont(){
        
        self.resourceTitleLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        
        [
            self.ratingBtn,
            self.viewsCountBtn,
            self.likesCountBtn
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        })
        
    }

}
