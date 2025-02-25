//
//  MealsTypeTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 14/02/25.
//

import UIKit

class MealsTypeTableViewCell: UITableViewCell {

    //MARK: ---------------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var mealTypesImgView: UIImageView!
    @IBOutlet weak var kcalImgView: UIImageView!
    @IBOutlet weak var proteinImgView: UIImageView!
    @IBOutlet weak var fatImgView: UIImageView!
    @IBOutlet weak var forknspoonImgView: UIImageView!
    @IBOutlet weak var checkImgView: UIImageView!
    @IBOutlet weak var mealTypesTitleLbl: UILabel!
    @IBOutlet weak var mealNameLbl: UILabel!
    @IBOutlet weak var kcalLbl: UILabel!
    @IBOutlet weak var proteinLbl: UILabel!
    @IBOutlet weak var fatLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24.0)
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 24.0)
        }
        
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupFont(){
        self.mealTypesTitleLbl.font = AppFont.bold.size(11.0, familyName: familyManrope)
        self.mealNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.kcalLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.proteinLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.fatLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
    }
    
    
    
}
