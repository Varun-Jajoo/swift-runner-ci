//
//  WorkoutSummaryTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 14/01/25.
//

import UIKit

class WorkoutSummaryTableViewCell: UITableViewCell {

    //MARK: -------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var repsMBV:UIView!
    @IBOutlet weak var kcalMBV: UIView!
    @IBOutlet weak var workoutImgView: UIImageView!
    @IBOutlet weak var selectionImgView: UIImageView!
    @IBOutlet weak var repsImgView: UIImageView!
    @IBOutlet weak var kcalImgView: UIImageView!
    @IBOutlet weak var workoutNameLbl: UILabel!
    @IBOutlet weak var repsLbl: UILabel!
    @IBOutlet weak var kcalLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1.0), endPoint: CGPoint(x: 1.0, y: 1.0), cornerRadius: 24.0)
            
            self.selectionImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.selectionImgView.frame.size.height/2.0)
        }
    }
    
    func setupFont(){
        self.workoutNameLbl.font = AppFont.bold.size(20.0, familyName: familyManrope)
        self.repsLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        self.kcalLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
    }
    
    func selectionCell(isSelected:Bool){
        
        if isSelected {
            DispatchQueue.main.async {
                self.cellMBV.addGradient(colors: UIColor.appMultiColor(.redGradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1.0), endPoint: CGPoint(x: 1.0, y: 1.0), cornerRadius: 24.0)
            }
        }else{
            DispatchQueue.main.async {
                self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1.0), endPoint: CGPoint(x: 1.0, y: 1.0), cornerRadius: 24.0)
            }
        }
    }
    
}
