//
//  DayStreakCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 16/05/25.
//

import UIKit

class DayStreakCollectionViewCell: UICollectionViewCell {

    private var blurView: UIVisualEffectView?
    
    private var originalImage: UIImage?
    private var blurredImage: UIImage?
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var dayStreakImgView: UIImageView!
    @IBOutlet weak var dayCountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellMBV.backgroundColor = .clear
        dayCountLbl.font = AppFont.bold.size(30.0, familyName: familyClashDisplay)
        dayCountLbl.textColor = UIColor(red: 255.0/255.0, green: 152.0/255.0, blue: 0, alpha: 1.0)
        
        self.originalImage = dayStreakImgView.image
        self.dayStreakImgView.image = dayStreakImgView.image
        
        self.blurredImage = createGrayBlurImage(from: dayStreakImgView.image ?? UIImage())
    }
    
    func setBlurred(_ blurred: Bool) {
        dayStreakImgView.image = blurred ? blurredImage : originalImage
        dayCountLbl.textColor =  blurred ? UIColor.appLightGray.withAlphaComponent(0.4) : UIColor(red: 255.0/255.0, green: 152.0/255.0, blue: 0, alpha: 1.0)
        }
}
