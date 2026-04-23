//
//  TraiinerGymAddressTVCell.swift
//  MyPT
//
//  Created by Manik Goel on 05/04/26.
//

import UIKit

class TraiinerGymAddressTVCell: UITableViewCell {
    
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var imageBg: UIImageView!
    @IBOutlet weak var btnRadio: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblKm: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }

    private func uiSetup() {
        self.lblName.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        self.lblAddress.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        self.lblKm.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
    }
    
    func setStudioData(data: StudioModel) {
        lblName.text = data.name
        lblAddress.text = data.address
        lblKm.text = data.distance
    }
    
    @IBAction func onTapRadio(_ sender: UIButton) {
    }
}
