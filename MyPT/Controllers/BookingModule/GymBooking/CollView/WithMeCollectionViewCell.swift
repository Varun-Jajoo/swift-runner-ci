//
//  WithMeCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 22/11/24.
//

import UIKit

class WithMeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var videoThumbnailImgView: UIImageView!
    @IBOutlet weak var centerImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.videoThumbnailImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }

}
