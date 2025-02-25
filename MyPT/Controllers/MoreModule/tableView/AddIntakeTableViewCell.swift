//
//  AddIntakeTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/02/25.
//

import UIKit

class AddIntakeTableViewCell: UITableViewCell {

    //MARK: ----------- IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var mealBtn: UIButton!
    @IBOutlet weak var kcalBtn: UIButton!
    @IBOutlet weak var bgImgView: UIImageView!
    
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
            self.addBtn.addDashedBorder(UIColor.appDarkGray, filledColor: UIColor.clear, withWidth: 2, cornerRadius: 16, dashPattern: [5,8])
            self.addBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
            self.bgImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.bgImgView.addBlurView(viewShow: self.bgImgView, alphBlur: 1.0, bgColor: UIColor.mainBg)
        }
    }
    
    func setupFont(){
        self.addBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.mealBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.kcalBtn.titleLabel?.font = AppFont.semibold.size(18.0, familyName: familyManrope)
    }
}
