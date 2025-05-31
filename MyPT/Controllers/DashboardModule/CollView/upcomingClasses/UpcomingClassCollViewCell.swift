//
//  UpcomingClassCollViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 11/11/24.
//

import UIKit

class UpcomingClassCollViewCell: UICollectionViewCell {

    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var mainBckImgView: UIImageView!
    @IBOutlet weak var dateMBV: UIView!
    @IBOutlet weak var descMBV: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var upcomingTitleLbl: UILabel!
    @IBOutlet weak var upcomingLocLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var onwardsLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        setUpFont()
        DispatchQueue.main.async {
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor2), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            self.mainBckImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.dateMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.descMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.descMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
//            self.onwardsLbl.applyGradientLabel(colors: [UIColor.appWhite,UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0,0.3,1.0])
        }
    }
    
    //--------------Set Cell Data
    func setCell(cellData: UpcomingClassModel?){
        guard let cellData = cellData else { return  }
        self.mainBckImgView.loadImage(urlString: cellData.image, placeholder: nil)
        let getDate = (DateFormatterHelper.shared.getDateFromFormat(fromDate: (cellData.time ?? ""), fromFormat: "dd MMM, HH:mm zzz", toFormat: "dd MMM") ?? "")
        self.dateLbl.text = getDate + " - " + (cellData.start_end ?? "")
        self.upcomingTitleLbl.text = cellData.className
        self.upcomingLocLbl.text = "Loaction: " + (cellData.location ?? "")
        if let priceValue = cellData.price?.value, let price = Double(priceValue)?.formattedTwoDecimal  {
            self.priceLbl(amtStr: price)
        }
    }
    
    private func priceLbl(amtStr: String){
        //-------------------- Attributed Text for Price
        
        let defaultAttributes = [
            .font: AppFont.medium.size(20.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        /*
        let makeAttributes = [
            .font: AppFont.medium.size(12.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "299",
            NSAttributedString(string: "AED",
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        */
        
        let attributedNickName = [
            amtStr,
            "AED".attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: self.amountLbl.bounds, font: AppFont.medium.size(12.0, familyName: familyClashDisplay))
        ] as [AttributedStringComponent]
        
        self.amountLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
      
        let onwardsStr = "onwards"
        self.onwardsLbl.attributedText = onwardsStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: self.onwardsLbl.bounds, font: AppFont.medium.size(12.0, familyName: familyClashDisplay))
    }
    
    //------------------************Font
    func setUpFont(){
        self.dateLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.upcomingTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.upcomingLocLbl.font = AppFont.regular.size(10.0, familyName: familyManrope)
//        self.amountLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.onwardsLbl.font = AppFont.medium.size(12.0, familyName: familyClashDisplay)
    }

}
