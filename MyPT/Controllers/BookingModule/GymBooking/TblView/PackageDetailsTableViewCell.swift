//
//  PackageDetailsTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 04/12/24.
//

import UIKit

class PackageDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setfont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setfont(){
        self.titleLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.titleLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
    }
    
}
