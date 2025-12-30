//
//  WorkoutTypeTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 21/08/25.
//

import UIKit

class WorkoutTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var rightArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1.5, borderColor: UIColor(red: 53.0/255.0, green: 53.0/255.0, blue: 53.0/255.0, alpha: 1.0), cornerRadious: 16.0)
//            self.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.7)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.5, y: 1.0), cornerRadius: 16.0)
            
            self.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.7), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 16.0)
            
            /*
             self.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1.0, y: 1.0), cornerRadius: 16.0)
             */
        }
    }
    
    private func setupFont(){
        self.titleLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.descLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
    }
}
