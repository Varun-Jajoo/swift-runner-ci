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
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI(){
        
        self.editBtn.setImage(UIImage(named: "ic_edit_rectBorder")?.resized(to: CGSize(width: 20, height: 20)), for: .normal)
        self.delBtn.setImage(UIImage(named: "ic_delete_Red")?.resized(to: CGSize(width: 20, height: 20)), for: .normal)
        self.editBtn.tintColor = UIColor.appWhite
        self.delBtn.tintColor = UIColor.appRed
        
//        let editImg = UIImage(named: "ic_edit_rectBorder")?.resized2(to: CGSize(width: 20, height: 20))
        
//        self.editBtn.setImage(editImg, for: .normal)
  
        
        
        DispatchQueue.main.async {
            self.scheduleImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 18.0)
            self.dateTimeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
            
            self.cellMBV.setGradientCellBorder(cornerRadius: 16.0, width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0))
            self.cellMBV.addGradient(colors: [ UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 1.0) , UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.2)], locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 16.0)
            
            //            self.cellMBV.setGradientBorder(cornerRadious:12.0,width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
        }
    }
    
    private func updateUI(){
 
        DispatchQueue.main.async {
            self.scheduleImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 18.0)
            self.dateTimeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
            self.cellMBV.setGradientCellBorder(cornerRadius: 16.0, width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0))
            self.cellMBV.addGradient(colors: [ UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 0.8) , UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.2)], locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 16.0)
        }
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
    
    private func setupFont(){
        self.dateTimeBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.nameLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.exerciseLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.timeLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
    }
    
    //MARK: ----------------INPUT DATASET
    func setCellData(cellData: MyWorkoutsDataModel?){
        guard let cellData = cellData else { return }
        self.dateTimeBtn.setTitle(cellData.time?.value, for: .normal)
        self.nameLbl.text = cellData.title?.value
        self.exerciseLbl.text = (cellData.exercise_count?.value ?? "") + " Exercise"
        self.timeLbl.text = "• " + (cellData.totalDuration?.value ?? "") + " min"
        
        self.scheduleImgView.loadImage(urlString: cellData.previewImage?.value, placeholder: UIImage(named: "ic_createworkoutIcon"), resize: CGSize(width: 150.0, height: 150.0))
        
        //-------------*********
        self.updateUI()
    }

}
