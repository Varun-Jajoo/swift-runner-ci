//
//  BestPlanPointsTVCell.swift
//  MyPT
//
//  Created by Manik Goel on 03/02/26.
//

import UIKit

class BestPlanPointsTVCell: UITableViewCell {

    @IBOutlet weak var lblPriorities: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblPriorities.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
