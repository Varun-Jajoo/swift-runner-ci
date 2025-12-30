//
//  ShowAddressTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 11/08/25.
//

import UIKit

class ShowAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var addrTypeLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var selectAddrBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addrTypeLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        addressLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
