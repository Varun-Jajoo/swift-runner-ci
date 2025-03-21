//
//  SearchTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 11/03/25.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var searchTitleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var rightBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.searchTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.subTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        DispatchQueue.main.async {
            self.lineLbl.addGradient(colors: UIColor.appMultiColor(.lineVGradient), locations: [0, 0.5], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.1)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
