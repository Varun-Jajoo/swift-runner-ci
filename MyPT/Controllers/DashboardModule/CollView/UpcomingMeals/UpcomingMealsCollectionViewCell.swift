//
//  UpcomingMealsCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/11/24.
//

import UIKit

class UpcomingMealsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var kcalBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var proteinBtn: UIButton!
    @IBOutlet weak var fatBtn: UIButton!
    @IBOutlet weak var mealTypeImgview: UIImageView!
    @IBOutlet weak var mealsTypeTitleLbl: UILabel!
    @IBOutlet weak var mealTypeImgViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var likeBtnTopconstrnt: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24.0)
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 24.0)
        }
        
        self.proteinBtn.titleLabel?.numberOfLines = 1
        self.proteinBtn.titleLabel?.lineBreakMode = .byClipping
    }
    
    private func setupFont(){
        self.titleLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.mealsTypeTitleLbl.font = AppFont.bold.size(11.0, familyName: familyManrope)
        
        //-------------------- Attributed Text for Price
        let kcalDefaultAttr = [
            .font: AppFont.bold.size(14.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let kcalAttr = [
            .font: AppFont.medium.size(12.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        //-------------------------*******kcal
        let makeKcalattr = [
            "251",
            NSAttributedString(string: " kcal",
                               attributes: kcalAttr)
        ] as [AttributedStringComponent]
        
        self.kcalBtn.titleLabel?.attributedText =  NSAttributedString(from: makeKcalattr, defaultAttributes: kcalDefaultAttr)
        
        //-------------------------*******Proteint
        let makeProteinattr = [
            "25",
            NSAttributedString(string: "g", attributes: kcalAttr),
            NSAttributedString(string: "Protein", attributes: kcalDefaultAttr),
        ] as [AttributedStringComponent]
        
        //-------------------------*******Fat
        let makeFatattr = [
            "17",
            NSAttributedString(string: "g", attributes: kcalAttr),
            NSAttributedString(string: "Fat", attributes: kcalDefaultAttr),
        ] as [AttributedStringComponent]
        
        self.proteinBtn.titleLabel?.attributedText = NSAttributedString(from: makeProteinattr, defaultAttributes: kcalDefaultAttr)
        self.fatBtn.titleLabel?.attributedText = NSAttributedString(from: makeFatattr, defaultAttributes: kcalDefaultAttr)
    }
    
    

}
