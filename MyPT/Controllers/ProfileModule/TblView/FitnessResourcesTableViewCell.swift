//
//  FitnessResourcesTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 26/06/25.
//

import UIKit

class FitnessResourcesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var cellGradientImgView: UIImageView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var fitnessTitleLbl: UILabel!
    @IBOutlet weak var fitnessDescLbl: UILabel!
    @IBOutlet weak var viewsBtn: UIButton!
    @IBOutlet weak var dotBtn: UIButton!
    @IBOutlet weak var readTimesBtn: UIButton!
    
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
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.userImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 18.0)
        }
    }
    
    private func setupFont(){
        fitnessTitleLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        [
            fitnessDescLbl,
            viewsBtn.titleLabel,
            readTimesBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        })
    }
    
}
