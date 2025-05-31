//
//  MyWorkoutsTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 15/11/24.
//

import UIKit

class MyWorkoutsTableViewCell: UITableViewCell {

    //MARK: ----------------VARIABLE
    var callBackReload:((Bool)-> Void )?
    
    //MARK: -----------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var selectedImgView: UIImageView!
    @IBOutlet weak var userMBV: UIView!
    @IBOutlet weak var completedUserMBV: UIView!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var descMBV: UIView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var fitnessTypeBtn: UIButton!
    @IBOutlet weak var completedFitnessTypeBtn: UIButton!
    @IBOutlet weak var completedUserNameLbl: UILabel!
    @IBOutlet weak var progressView: UILabel!
    @IBOutlet weak var fitnesStatusBtn: UIButton!
    @IBOutlet weak var scoreBtn: UIButton!
    @IBOutlet weak var dotBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        DispatchQueue.main.async {
            
//            self.progressView.drawLineProgress(progressfill: 0,fillLineColor: UIColor.appYellow, cornerRadius: 2.0)
            
//            self.fitnessTypeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
//            self.completedFitnessTypeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
            self.fitnessTypeBtn.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.25), offSet: .zero, opacity: 0.4, shadowRadius: 5.0, cornerRadious: 8.0)
            self.completedFitnessTypeBtn.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.25), offSet: .zero, opacity: 0.4, shadowRadius: 5.0, cornerRadious: 8.0)
            
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.userImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.progressView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.progressView.frame.size.height/2.0)
            
//            self.cellMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .conic)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupcellData(){
        DispatchQueue.main.async {
            self.progressView.drawLineProgress(progressfill: 0.5,fillLineColor: UIColor.appYellow, cornerRadius: 2.0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.completedFitnessTypeBtn.setTitle("Complete", for: .normal)
    }
    
    func selectionCell(isSelected:Bool){
        
        if isSelected {
            //
        }else{
           //
        }
    
    }
}
