//
//  workTypeCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 29/08/25.
//

import UIKit

class workTypeCollectionViewCell: UICollectionViewCell {
   
    //MARK: ------------ VARIABLE
    var onMenuButtonTapped: ((_ button: UIButton) -> Void)?
    
    //MARK: ----------- IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var grdntImgView: UIImageView!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var workoutCategoryBtn: UIButton!
    @IBOutlet weak var repsBtn: UIButton!
    @IBOutlet weak var workoutNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupFont()
        self.setupUI()
        settingsBtn.addTarget(self, action: #selector(handleMenuButtonTap), for: .touchUpInside)
    }
    
    
    @objc private func handleMenuButtonTap() {
        onMenuButtonTapped?(settingsBtn)
    }
    
    func setupCell(cellData: ExercisesDatailsModel? ){
        guard let cellData = cellData else { return }
        self.workoutNameLbl.text = cellData.name?.value
        self.workoutCategoryBtn.setTitle(cellData.category?.value, for: .normal)
//        let repsStr: String = (cellData.raps?.value ?? cellData.reps?.value ?? "") + " Reps"
       
        if let raps = cellData.raps?.value {
            self.repsBtn.setTitle(raps + " Reps", for: .normal)
        }else{
            self.repsBtn.setTitle((cellData.reps?.value ?? "") + " Reps" , for: .normal)
        }
        
//        self.repsBtn.setTitle(repsStr , for: .normal)
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
            self.workoutCategoryBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 6.0)
        }
    }
    
    private func setupFont(){
        self.workoutCategoryBtn.titleLabel?.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.repsBtn.titleLabel?.font = AppFont.regular.size(12.0, familyName: familyManrope)
        self.workoutNameLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
    }
    
}
