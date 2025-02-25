//
//  CheckListTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 23/01/25.
//

import UIKit

class CheckListTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var chekListImgView: UIImageView!
    @IBOutlet weak var chckListTitleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
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
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 20.0)
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.cellMBV.setGradientBorder(cornerRadious: 20, width: 1.5, colors: UIColor.appMultiColor(.borderGradientColor), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            self.chekListImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
        }
    }
    
    func setupFont(){
        self.chckListTitleLbl.font = AppFont.medium.size(18.0, familyName: familyClashDisplay)
        self.descLbl.font = AppFont.medium.size(12.0, familyName: familyManrope)
    }
}
