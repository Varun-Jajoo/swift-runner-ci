//
//  DateCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 14/02/26.
//

import UIKit

class DateCVCell: UICollectionViewCell {

    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }

    private func uiSetup() {
        self.lblDate.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
    }
}
