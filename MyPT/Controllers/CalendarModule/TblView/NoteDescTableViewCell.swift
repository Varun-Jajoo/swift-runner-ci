//
//  NoteDescTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 25/08/25.
//

import UIKit

class NoteDescTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var noteNumLbl: UILabel!
    @IBOutlet weak var noteDescLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupFont(){
        self.noteNumLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.noteDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
    }
}
