//
//  SupersetExercisesTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 09/09/25.
//

import UIKit

class SupersetExercisesTableViewCell: UITableViewCell {

    //MARK: -------------- VARIABLE
    var onMenuBtnTapped: ((_ button: UIButton) -> Void)?
    
    //MARK: -------------- IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var workoutCellMBV: UIView!
    @IBOutlet weak var workoutGroupMBV: UIView!
    @IBOutlet weak var topTitleMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var editMenuBtn: UIButton!
    @IBOutlet weak var gymNameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var repsImgView: UIImageView!
    @IBOutlet weak var kcalImgView: UIImageView!
    @IBOutlet weak var repsLbl: UILabel!
    @IBOutlet weak var kcalLbl: UILabel!
    @IBOutlet weak var selectedWorkoutBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupUI()
        self.setupFont()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setCellData(cellData: ExercisesDatailsModel?){
        guard let cellData = cellData else { return }
        
        self.repsImgView.image = UIImage(named: "ic_solid_barbell_diagonalGray")
        self.kcalImgView.image = UIImage(named: "ic_solid_fireGray")
        
        self.topTitleLbl.text = cellData.category?.value
        self.gymNameLbl.text = cellData.name?.value
        self.userNameLbl.text = ""
        self.repsLbl.text = (cellData.raps?.value ?? cellData.reps?.value ?? "") + " Reps"
        self.kcalLbl.text = (cellData.calories?.value ?? "") + " kcal"
        self.bgImgView.loadImage(urlString: cellData.image?.value, placeholder: AppImages.profile_placeholder, resize: CGSize(width: (self.frame.width * 0.2), height: self.frame.size.height * 0.2))
                
        self.setupUI()
    }
    
    func setupMenuActn(){
        self.editMenuBtn.addTarget(self, action: #selector(handleMenuBtnTap), for: .touchUpInside)
    }
    
    @objc private func handleMenuBtnTap() {
        onMenuBtnTapped?(editMenuBtn)
    }
    
    
    func setupUI(){
        
        DispatchQueue.main.async {
            
            self.topTitleMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor.appBorder, shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 24.0)
            
            self.bgImgView.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            self.bgImgView.addCellImgGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.6)], locations: [0, 1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 24.0)
            
            self.workoutGroupMBV.cornersWithBorder(radius: 24.0, corners: [.bottomLeft, .bottomRight], borderColor: UIColor(red: 62.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0), borderWidth: 1.0)
            
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
        
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.gymNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.userNameLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.repsLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        self.kcalLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
    }

}
