//
//  WorkoutTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 09/01/25.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {

    //MARK: --------------IBOUTLDET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var repsMBV: UIView!
    @IBOutlet weak var kcalMBV: UIView!
    @IBOutlet weak var workoutImgView: UIImageView!
    @IBOutlet weak var workoutNameLbl: UILabel!
    @IBOutlet weak var repsTitleLbl: UILabel!
    @IBOutlet weak var kcalTitleLbl: UILabel!
    @IBOutlet weak var repsImgView: UIImageView!
    @IBOutlet weak var kcalImgView: UIImageView!
    @IBOutlet weak var rightImgView: UIImageView!
    
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
            self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.txtDarkGray, cornerRadious: 12.0)
            self.workoutImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.workoutNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.repsTitleLbl.font = AppFont.ExtraBold.size(14.0, familyName: familyManrope)
        self.kcalTitleLbl.font = AppFont.ExtraBold.size(14.0, familyName: familyManrope)
    }
}
