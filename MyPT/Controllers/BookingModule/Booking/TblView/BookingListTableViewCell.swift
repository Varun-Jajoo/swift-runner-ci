//
//  BookingListTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 16/12/24.
//

import UIKit

class BookingListTableViewCell: UITableViewCell {

    //MARK: --------------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var gymProfileImgView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var forwarImgView: UIImageView!
    @IBOutlet weak var workoutMBV: UIStackView!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var trainerDetailsMBV: UIStackView!
    @IBOutlet weak var rescheduledMBV: UIView!
    @IBOutlet weak var workoutFocusTitleLbl: UILabel!
    @IBOutlet weak var workoutFocusDescLbl: UILabel!
    @IBOutlet weak var sessionTypeTitleLbl: UILabel!
    @IBOutlet weak var sessionDescLbl: UILabel!
    @IBOutlet weak var durationTitleLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var myTrainerTitleLbl: UILabel!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var trainerLocTitleLbl: UILabel!
    @IBOutlet weak var trainingLocDesc: UILabel!
    @IBOutlet weak var rescheduledBtn: UIButton!
    
    @IBOutlet weak var lineV: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.addLeftBorder(borderColor: UIColor.appYellow)
       
        DispatchQueue.main.async {
            self.cellMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .axial)
          
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.rescheduledBtn.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 255/255.0, green: 198/255.0, blue: 6/255.0, alpha: 1.0).cgColor, UIColor(red: 153/255.0, green: 119/255.0, blue: 4/255.0, alpha: 1).cgColor], type: .axial)
           
            self.rescheduledBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)

            //            self.lineLbl.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0).cgColor, UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0).cgColor, UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1.0).cgColor,UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0).cgColor, UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0).cgColor], type: .conic)
            self.lineLbl.backgroundColor = .clear
            self.lineV.backgroundColor = UIColor.appBorder
//            self.lineV.drawLine(start: CGPoint(x: 0, y: 1), toPoint: CGPoint(x: 1, y: 1.0))
           
//            self.lineV.addGradient(colors: [UIColor.appWhite,UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0), UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1.0),UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0), UIColor.appWhite], locations: [0,2], startPoint: CGPoint(x: 0.4, y: 0), endPoint: CGPoint(x: 0.7, y: 1), type: .axial)
            
        }
        
        self.setUpFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: -----------FONT SETUP
    func setUpFont(){
        self.dateLbl.font = AppFont.semibold.size(18, familyName: familyManrope)
        self.workoutFocusTitleLbl.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.workoutFocusDescLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.sessionTypeTitleLbl.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.sessionDescLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.durationTitleLbl.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.timeLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
//        self.lineLbl.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.myTrainerTitleLbl.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.trainerNameLbl.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.trainerLocTitleLbl.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.trainingLocDesc.font = AppFont.semibold.size(14, familyName: familyManrope)
        self.rescheduledBtn.titleLabel?.font = AppFont.semibold.size(12, familyName: familyManrope)
    }
    
    func addLeftBorder(borderColor: UIColor? = UIColor.appYellow) {
           let leftBorder = CALayer()
        leftBorder.backgroundColor = borderColor?.cgColor // Set your border color
        leftBorder.frame = CGRect(x: 0, y: 0, width: 3.0, height: self.cellMBV.frame.height) // Adjust width as needed
        self.cellMBV.layer.addSublayer(leftBorder)
       }
       
       override func layoutSubviews() {
           super.layoutSubviews()
           // Update the border height dynamically in case cell height changes
//           if let leftBorder = self.cellMBV.layer.sublayers?.first {
//               leftBorder.frame = CGRect(x: 0, y: 0, width: 2.0, height: self.cellMBV.frame.height)
//           }
       }
}
