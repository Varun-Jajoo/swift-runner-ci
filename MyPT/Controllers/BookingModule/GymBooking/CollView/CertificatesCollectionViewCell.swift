//
//  CertificatesCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/03/25.
//

import UIKit

class CertificatesCollectionViewCell: UICollectionViewCell {
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var achivementImgView: UIImageView!
    @IBOutlet weak var lavelTitleLbl: UILabel!
    @IBOutlet weak var certificateNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.subView.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
        }
        
        self.lavelTitleLbl.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        self.certificateNameLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
    
}
