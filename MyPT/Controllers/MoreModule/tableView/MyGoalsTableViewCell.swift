//
//  MyGoalsTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 10/02/25.
//

import UIKit

class MyGoalsTableViewCell: UITableViewCell {

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var cellMStckView: UIStackView!
    @IBOutlet weak var caloriesMBV: UIView!
    @IBOutlet weak var progressMBV: UIView!
    @IBOutlet weak var infoMBV: UIView!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var caloriesBurnTitleLbl: UILabel!
    @IBOutlet weak var caloriesQuantityLbl: UILabel!
    @IBOutlet weak var burnProgressTitleLbl: UILabel!
//    @IBOutlet weak var seeAllLbl: UILabel!
    @IBOutlet weak var outOffTitleLbl: UILabel!
    @IBOutlet weak var remainingTitleLbl: UILabel!
    @IBOutlet weak var targetInfoTitleLbl: UILabel!
    @IBOutlet weak var infoImgView: UIImageView!
//    @IBOutlet weak var rightArrowImgView: UIImageView!
    @IBOutlet weak var seeAllBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupFont()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.cellMStckView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cellMStckView.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1.0), cornerRadius: 12.0)
//            self.lineMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [ 0, 1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.5)
            
            self.lineMBV.addGradient(colors: [UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 47.0/255.0, alpha: 0), UIColor(red: 52.0/255.0, green: 55.0/255.0, blue: 57.0/255.0, alpha: 1),UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 47.0/255.0, alpha: 0)], locations: [0.2,1], startPoint: CGPoint(x: 1.0, y: 1.0), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 2.0)
        }
    }
    
    func setupFont(){
        self.caloriesBurnTitleLbl.font = AppFont.regular.size(12.0, familyName: familyManrope)
        self.caloriesQuantityLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.burnProgressTitleLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.seeAllBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
//        self.seeAllLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.outOffTitleLbl.font = AppFont.regular.size(11.0, familyName: familyManrope)
        self.remainingTitleLbl.font = AppFont.regular.size(11.0, familyName: familyManrope)
        self.targetInfoTitleLbl.font = AppFont.regular.size(11.0, familyName: familyManrope)
    }
    
    
}
