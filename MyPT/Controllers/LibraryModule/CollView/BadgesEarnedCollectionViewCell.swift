//
//  BadgesEarnedCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 05/09/25.
//

import UIKit

class BadgesEarnedCollectionViewCell: UICollectionViewCell {

    //MARK: ----------VARIABLE
    private var blurView: UIVisualEffectView?
    private var originalImage: UIImage?
    private var blurredImage: UIImage?
    
    //MARK: --------- IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var badgeDescMBV: UIView!
    @IBOutlet weak var badgeImgView: UIImageView!
    @IBOutlet weak var podiumaImgView: UIImageView!
    @IBOutlet weak var badgeImgWithPodium: UIImageView!
    @IBOutlet weak var badgeDateLbl: UILabel!
    @IBOutlet weak var badgeNameLbl: UILabel!
    @IBOutlet weak var bagdeImgViewTopConstrnt: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUpFont()
    
//        self.originalImage = badgeImgWithPodium.image
//        self.badgeImgWithPodium.image = badgeImgWithPodium.image
        
        self.originalImage = badgeImgView.image
        self.badgeImgView.image = badgeImgView.image
        self.badgeImgView.makeCircular()
        
        self.blurredImage = createGrayBlurImage(from: badgeImgView.image ?? UIImage())
    }

    
    private func setUpFont(){
        badgeDateLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        badgeNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
    }
    
    func setBlurred(_ blurred: Bool) {
        badgeImgView.image = blurred ? blurredImage : originalImage
//        bagdeImgView.textColor =  blurred ? UIColor.appLightGray.withAlphaComponent(0.4) : UIColor(red: 255.0/255.0, green: 152.0/255.0, blue: 0, alpha: 1.0)
        }
}
