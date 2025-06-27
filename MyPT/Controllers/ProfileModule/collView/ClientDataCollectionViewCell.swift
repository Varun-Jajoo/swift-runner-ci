//
//  ClientDataCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 26/06/25.
//

import UIKit

class ClientDataCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var cellMainGrdImgView: UIImageView!
    @IBOutlet weak var cellMStckView: UIStackView!
    @IBOutlet weak var clientDataDescMBV: UIView!
    @IBOutlet weak var noDataMBV: UIView!
    @IBOutlet weak var noDataSubV: UIView!
    @IBOutlet weak var clientDataProgressMBV: UIView!
    @IBOutlet weak var topTitleBtn: UIButton!
    @IBOutlet weak var unitLbl: UILabel!
    @IBOutlet weak var doDataDescLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupFont()
        self.setupUI()
    }

    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMainGrdImgView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor(red: 46.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0), cornerRadious: 18.0)
            self.cellMStckView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor(red: 46.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0), cornerRadious: 18.0)
            
            self.noDataSubV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        self.unitLbl.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
        
        topTitleBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        unitLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        doDataDescLbl.font = AppFont.bold.size(11.0, familyName: familyManrope)
    }
    
}
