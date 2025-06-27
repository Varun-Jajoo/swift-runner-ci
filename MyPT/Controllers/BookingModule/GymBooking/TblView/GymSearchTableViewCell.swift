//
//  GymSearchTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 09/06/25.
//

import UIKit

class GymSearchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var studioNameLbl: UILabel!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var addrMBV: UIView!
    @IBOutlet weak var distanceMBV: UIView!
    @IBOutlet weak var locImgView: UIImageView!
    @IBOutlet weak var dotImgView: UIImageView!
    @IBOutlet weak var addrLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    
    
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
    
    private func setupUI(){
        //rgba(243, 141, 27, 1)
        //rgba(217, 217, 217, 1)
        locImgView.image = UIImage(named: "ic_chooseLocation")?.withRenderingMode(.alwaysTemplate)
        locImgView.tintColor = UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 27.0/255.0, alpha: 1.0)
        
        dotImgView.image = UIImage(named: "ic_grayDot")?.withRenderingMode(.alwaysTemplate)
        dotImgView.tintColor = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
    
    private func setupFont(){
        studioNameLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        addrLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        distanceLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
    }
    
    func seupCellData(){
        
    }
}
