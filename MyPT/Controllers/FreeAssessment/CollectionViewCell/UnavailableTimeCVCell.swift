//
//  UnavailableTimeCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 14/03/26.
//

import UIKit

class UnavailableTimeCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewUnavailableTime: UIView!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }
    
    private func uiSetup() {
        self.viewUnavailableTime.cornersWithBorder(radius: 8, corners: .allCorners, borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1), borderWidth: 1)
        self.lblTime.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
    }
    
    /// Call this from cellForItemAt to reflect the current selection state
    func setSelected(_ selected: Bool) {
        if selected {
            // Selected state — highlight border + background
            viewUnavailableTime.cornersWithBorder(
                radius: 8,
                corners: .allCorners,
                borderColor: UIColor(red: 158/255, green: 188/255, blue: 255/255, alpha: 1.0),
                borderWidth: 1
            )
            viewUnavailableTime.backgroundColor = UIColor(red: 158/255, green: 188/255, blue: 255/255, alpha: 0.15)
            lblTime.textColor = UIColor(red: 158/255, green: 188/255, blue: 255/255, alpha: 1.0)
        } else {
            // Unselected state — default border
            viewUnavailableTime.cornersWithBorder(
                radius: 8,
                corners: .allCorners,
                borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1),
                borderWidth: 1
            )
            viewUnavailableTime.backgroundColor = .clear
            lblTime.textColor = .white
        }
    }
}
