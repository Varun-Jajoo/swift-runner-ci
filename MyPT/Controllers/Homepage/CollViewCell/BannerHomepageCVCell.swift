//
//  BannerHomepageCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 07/02/26.
//

import UIKit

class BannerHomepageCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewBckground: UIView!
    @IBOutlet weak var imgBanner: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }

    private func uiSetup() {
        DispatchQueue.main.async {
            self.imgBanner.cornersWithBorder(radius: 12, corners: .allCorners, borderColor: .clear, borderWidth: 0)
        }
    }
    
}
