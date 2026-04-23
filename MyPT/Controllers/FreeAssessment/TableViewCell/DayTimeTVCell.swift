//
//  DayTimeTVCell.swift
//  MyPT
//
//  Created by Manik Goel on 07/03/26.
//

import UIKit

class DayTimeTVCell: UITableViewCell {
    
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func uiSetup() {
        lblDay.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        lblName.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
    }
    
}
