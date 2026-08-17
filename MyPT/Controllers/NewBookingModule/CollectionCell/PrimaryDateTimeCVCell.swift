//
//  PrimaryDateTimeCVCell.swift
//  MyPT
//
//  Created by techsaga on 25/06/26.
//

import UIKit

class PrimaryDateTimeCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewDateTime: UIView!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewRound: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }

    private func uiSetup() {
        viewRound.makeCircular()
        lblDateTime.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        lblTime.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        viewDateTime.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.1), cornerRadious: 8.0)
    }
}

