//
//  SeePtActionCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 07/02/26.
//

import UIKit

class SeePtActionCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgaction: UIImageView!
    @IBOutlet weak var lblActionName: UILabel!
    @IBOutlet weak var imgThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }

    private func uiSetup() {
        self.lblActionName.font = AppFont.regular.size(10.0, familyName: familyFunnelSans)
        viewVideo.setCornerRadius(cornerRadious: 8)
        imgaction.setCornerRadius(cornerRadious: 6)
    }
    
    func configure(with completeData: Datum) {
        lblActionName.text = completeData.categoryName
        if let thumb = completeData.categoryImage {
            imgThumbnail.loadImage(urlString: thumb, placeholder: nil)
        }
        if let thumb = completeData.categoryIcon {
            imgaction.loadImage(urlString: thumb, placeholder: nil)
        }
    }
}
