//
//  UpcomingClassesNearCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 09/05/25.
//

import UIKit

class UpcomingClassesNearCollectionViewCell: UICollectionViewCell {

    //MARK: ------------ VARIABLE
    let statusColorMap: [String: UIColor] = [
        "Sold Out".uppercased(): UIColor.txtDarkGray,
        "AVAILABLE".uppercased(): UIColor.appGreen,
        "FAST FILLING".uppercased(): UIColor.appLightYellow,
        "Almost Full".uppercased(): UIColor(red: 150.0/255.0, green: 0, blue: 0, alpha: 1.0)
    ]
  
    //classStaus =>['Almost Full'=>'Red', 'Fast Filling'=>'Yellow', 'Available' => 'Green' , 'Sold Out' =>Grey]
    
    //MARK: ------------- IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var cardBackImgView: UIImageView!
    @IBOutlet weak var trainerProfileImgView: UIImageView!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var gymCategoryLbl: UILabel!
    @IBOutlet weak var gymTag1Btn: UIButton!
    @IBOutlet weak var gymTag2Btn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var trainedByLbl: UILabel!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupFont()
        
//        self.cardBackImgView.addGradientImgV(colors: UIColor.appMultiColor(.gradientColor), locations: [0, 1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
    }

    //--------------Set Cell Data
    func setCell(cellData: UpcomingClassModel?){
        guard let cellData = cellData else { return  }
        self.cardBackImgView.loadImage(urlString: cellData.image, placeholder: nil)
        self.trainerProfileImgView.loadImage(urlString: cellData.trainerImage, placeholder: nil)
        self.statusBtn.setTitle(cellData.status, for: .normal)
        self.gymCategoryLbl.text = cellData.className
        self.gymTag1Btn.setTitle(cellData.studioName, for: .normal)
        self.gymTag2Btn.setTitle(cellData.type, for: .normal)
        self.dateLbl.text = cellData.time
        self.trainerNameLbl.text = cellData.trainedBy
        if let priceValue = cellData.price?.value, let price = Double(priceValue)?.formattedTwoDecimal  {
            self.priceLbl.text = "AED " + price //String(format: "%.1f", Double(price))
        }
        
        
        if let status = cellData.status?.uppercased(), let color = self.statusColorMap[status] {
            self.statusBtn.backgroundColor = color
        }
    }
    
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 24.0)
            self.cardBackImgView.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 24.0)
         
//            self.cardBackImgView.addGradientImgV(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.8), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0, 1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
            
            self.cardBackImgView.addGradientImgV(colors: [UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 54.0/255.0, alpha: 1.0), UIColor(red: 13.0/255.0, green: 14.0/255.0, blue: 17.0/255.0, alpha: 0.31), UIColor(red: 0, green: 0, blue: 0, alpha: 0)], locations: [0, 0.3, 1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1, y: 0))
            
            self.trainerProfileImgView.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 36.0/255.0, green: 38.0/255.0, blue: 43.0/255.0, alpha: 1.0), cornerRadious: self.trainerProfileImgView.frame.size.height/2.0)
            self.statusBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
            
        }
    }
    
    private func setupFont(){        
        self.gymCategoryLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.trainedByLbl.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.trainerNameLbl.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.priceLbl.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        
        [
            self.statusBtn.titleLabel,
            self.gymTag1Btn.titleLabel,
            self.gymTag2Btn.titleLabel,
            self.dateLbl
        ].forEach({ [weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
            
        })
    }
    
}
