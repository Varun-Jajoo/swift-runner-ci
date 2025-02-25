//
//  HydrationDataInnerTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 17/02/25.
//

import UIKit

class HydrationDataInnerTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var lineVLbl: UILabel!
    @IBOutlet weak var qntyBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupFont()
        
        DispatchQueue.main.async {
            self.lineVLbl.addGradient(colors: UIColor.appMultiColor(.lineVGradient), locations: [0.3,0.5], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.3)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupFont(){
        self.subTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.descLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.qntyBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
    }
    
}
