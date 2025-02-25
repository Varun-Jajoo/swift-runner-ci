//
//  MyScheduleTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 02/01/25.
//

import UIKit

class MyScheduleTableViewCell: UITableViewCell {

    //MARK: ----------------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var scheduleImgView: UIImageView!
    @IBOutlet weak var dateTimeBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var exerciseLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupFont()
        
        DispatchQueue.main.async {
            
            self.scheduleImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 18.0)
            self.dateTimeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
            self.cellMBV.addGradient(colors: [UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)], locations: [0,0.8], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.8, y: 1.0))
            
            self.cellMBV.setGradientBorder(cornerRadious:16.0,width: 2.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
//            self.cellMBV.setGradientBorder(cornerRadious:12.0,width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupFont(){
        self.dateTimeBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.nameLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.exerciseLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.timeLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
    }
    
}
