//
//  ProductsListCollViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 11/11/24.
//

import UIKit

class ProductsListCollViewCell: UICollectionViewCell {

    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var productImgView: UIImageView!
    @IBOutlet weak var descMBV: UIView!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpFont()
        DispatchQueue.main.async {
            self.ratingBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
           
            self.descMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 0)
        }
    }
    
    //------------------************Font
    func setUpFont(){
        self.productNameLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
//        self.priceLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.ratingBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)

        
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.medium.size(20.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.medium.size(12.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "299",
            NSAttributedString(string: "AED",
                               attributes: makeAttributes), "329AED".strikeThrough(with: AppFont.medium.size(16.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray)
        ] as [AttributedStringComponent]
        
        self.priceLbl.attributedText       =  NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
        
    }

}
