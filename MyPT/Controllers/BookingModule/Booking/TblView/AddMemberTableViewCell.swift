//
//  AddMemberTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 02/04/25.
//

import UIKit

class AddMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var ageMBV: UIView!
    @IBOutlet weak var genderMBV: UIView!
    @IBOutlet weak var memberNameLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.ageMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.genderMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
        }
        
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: ------------SET UP CELL
    func setupCell(data: MemberModel?){
        self.memberNameLbl.text = data?.name
        self.ageLbl.text = data?.age?.value
        self.genderLbl.text = data?.gender
    }
    
    private func setupFont(){
        self.memberNameLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.ageLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.genderLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
    
}
