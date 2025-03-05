//
//  ExclusiveDealCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 24/02/25.
//

import UIKit

class ExclusiveDealCollectionViewCell: UICollectionViewCell {

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var offerMBV: UIView!
    @IBOutlet weak var detailsMBV: UIView!
    @IBOutlet weak var productImgView: UIImageView!
    @IBOutlet weak var offerLbl: UILabel!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var productPriceLbl: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupFont()
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 13.5)
            self.cellMBV.setGradientBorder(cornerRadious: 13.5, width: 1.5, colors: UIColor.appMultiColor(.borderGradientColor), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
           
            self.detailsMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0)
            
            self.productImgView.roundSideCorners(radius: 13.5, cornerSide: [.topLeft, .topRight])
            self.addBtn.roundSideCorners(radius: 8.0, cornerSide: [.bottomLeft, .bottomRight])
            
            self.offerMBV.addGradient(colors: UIColor.appMultiColor(.cynGradient), locations: [0, 0.3, 1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0)
        }
    }

    func setupFont(){
        self.offerLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.productNameLbl.font = AppFont.semibold.size(21.0, familyName: familyManrope)
        self.productPriceLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.medium.size(21.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.medium.size(18.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "299",
            NSAttributedString(string: "AED",
                               attributes: makeAttributes), "329AED".strikeThrough(with: AppFont.medium.size(18.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray)
        ] as [AttributedStringComponent]
        
        self.productPriceLbl.attributedText       =  NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
}
