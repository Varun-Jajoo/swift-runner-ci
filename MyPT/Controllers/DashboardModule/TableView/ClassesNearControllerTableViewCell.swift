//
//  ClassesNearControllerTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/05/25.
//

import UIKit

class ClassesNearControllerTableViewCell: UITableViewCell {

    //MARK: ------------ VARIABLE
    let statusColorMap: [String: UIColor] = [
        "Sold Out".uppercased(): UIColor.txtDarkGray,
        "AVAILABLE".uppercased(): UIColor.appGreen,
        "FAST FILLING".uppercased(): UIColor.appLightYellow,
        "Almost Full".uppercased(): UIColor(red: 150.0/255.0, green: 0, blue: 0, alpha: 1.0)
    ]
    
    //MARK: -------------- IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var classesBckImgView: UIImageView!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var myStudioBtn: UIButton!
    @IBOutlet weak var intermediateBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var trianerProfileImgView: UIImageView!
    @IBOutlet weak var trainByLbl: UILabel!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var classFreeAmt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 24.0)
            
            self.classesBckImgView.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            
            self.classesBckImgView.addGradientImgV(colors: [UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 54.0/255.0, alpha: 1.0), UIColor(red: 13.0/255.0, green: 14.0/255.0, blue: 17.0/255.0, alpha: 0.31), UIColor(red: 0, green: 0, blue: 0, alpha: 0)], locations: [0, 0.3, 1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1, y: 0))
            
            self.trianerProfileImgView.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 36.0/255.0, green: 38.0/255.0, blue: 43.0/255.0, alpha: 1.0), cornerRadious: self.trianerProfileImgView.frame.size.height/2.0)
            self.statusBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
        }
    }
    
    private func setupFont(){
        self.classNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.trainByLbl.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.trainerNameLbl.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.classFreeAmt.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        
        [
            self.statusBtn.titleLabel,
            self.myStudioBtn.titleLabel,
            self.intermediateBtn.titleLabel,
            self.dateLbl
        ].forEach({ [weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
            
        })
    }
    
    //--------------Set Cell Data
    func setCell(cellData: UpcomingClassModel?){
        guard let cellData = cellData else { return  }
        self.classesBckImgView.loadImage(urlString: cellData.image, placeholder: nil)
        self.trianerProfileImgView.loadImage(urlString: cellData.trainerImage, placeholder: nil)
        self.statusBtn.setTitle(cellData.status, for: .normal)
        self.classNameLbl.text = cellData.className
        self.myStudioBtn.setTitle(cellData.studioName, for: .normal)
        self.intermediateBtn.setTitle(cellData.type, for: .normal)
        self.dateLbl.text = cellData.time
        self.trainerNameLbl.text = cellData.trainedBy
        if let priceValue = cellData.price?.value, let price = Double(priceValue)?.formattedTwoDecimal  {
            self.classFreeAmt.text = "AED " + price //String(format: "%.1f", Double(price))
        }
        
        if let status = cellData.status?.uppercased(), let color = self.statusColorMap[status] {
            self.statusBtn.backgroundColor = color
        }
    }
    
}
