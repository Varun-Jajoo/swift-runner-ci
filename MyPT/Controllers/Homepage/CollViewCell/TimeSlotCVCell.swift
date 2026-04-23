//
//  TimeSlotCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 13/02/26.
//

import UIKit

class TimeSlotCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewTimeSlot: UIView!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }

    private func uiSetup() {
        self.lblTime.font = AppFont.medium.size(11.0, familyName: familyFunnelSans)
//        self.viewTimeSlot.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.2), cornerRadious: 8)
//        self.viewTimeSlot.applyGradient(
//               colors: [
//                   UIColor.white.withAlphaComponent(1.0),
//                   UIColor.white.withAlphaComponent(0.0)
//               ]
//           )
    }
}

