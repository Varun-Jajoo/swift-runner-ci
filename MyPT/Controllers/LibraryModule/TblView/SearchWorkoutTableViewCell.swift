//
//  SearchWorkoutTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 07/01/25.
//

import UIKit

class SearchWorkoutTableViewCell: UITableViewCell {

    //MARK: ------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var bckImgView: UIImageView!
    @IBOutlet weak var topTitleMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var workoutNameLbl: UILabel!
    @IBOutlet weak var seriesWorkoutLbl: UILabel!
    @IBOutlet weak var repsMBV: UIView!
    @IBOutlet weak var kcalMBV: UIView!
    @IBOutlet weak var timingMBV: UIView!
    @IBOutlet weak var repsImgView: UIImageView!
    @IBOutlet weak var repsTitleLbl: UILabel!
    @IBOutlet weak var kcalImgView: UIImageView!
    @IBOutlet weak var kcalTitleLbl: UILabel!
    @IBOutlet weak var timingImgView: UIImageView!
    @IBOutlet weak var timingTitleLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var videoPlauyBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.setupUI()
        self.setupFont()
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            self.bckImgView.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            self.topTitleMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)

        }
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.workoutNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.seriesWorkoutLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.repsTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.kcalTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.timingTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
    }
    
}
