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
    @IBOutlet weak var gradientImgView: UIImageView!
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
        self.setupUI()
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(cellData: MyWorkoutsDataModel?){
        guard let cellData = cellData else { return }
        
        self.completedUserMBV.isHidden = true
        self.userMBV.isHidden = false
        self.lineMBV.isHidden = false
        self.progressView.isHidden = false
        self.selectedImgView.isHidden = true
        self.fitnesStatusBtn.isHidden = true
        self.dotBtn.isHidden = true
        
        self.userNameLbl.text = cellData.title?.value
        self.completedUserNameLbl.text = cellData.title?.value
        self.fitnessTypeBtn.setTitle(cellData.category?.value, for: .normal)
        self.completedFitnessTypeBtn.setTitle(cellData.category?.value, for: .normal)
        self.scoreBtn.setTitle((cellData.percentage?.value ?? "") + "%", for: .normal)
        self.scoreBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -6)
                
        self.userImgView.loadImage(urlString: cellData.previewImage?.value, placeholder: AppImages.profile_placeholder, resize: CGSize(width: self.cellMBV.bounds.height - 15, height: self.cellMBV.bounds.height - 15))
        
        //------------*********
        DispatchQueue.main.async {
            self.cellMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0)
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            
//            self.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0),UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 0.1)], locations: [0,1.0], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
            
//            self.cellMBV.layer.sublayers?.filter({ $0.name == "addGradient"}).forEach({$0.removeFromSuperlayer()})
            
        }
        
        self.gradientImgView.image = UIImage(named: "ic_WorkoutNormalGradient")
       
        if let isCompleted = cellData.isCompleted, isCompleted {
            self.gradientImgView.image = UIImage(named: "ic_WorkoutCompletedGrnt")
            
            self.scoreBtn.setTitle(cellData.pt_score?.value, for: .normal)
            self.fitnesStatusBtn.setTitle("Completed", for: .normal)
            self.fitnesStatusBtn.setImage(nil, for: .normal)
            self.scoreBtn.setImage(nil, for: .normal)
            self.completedUserMBV.isHidden = false
            self.userMBV.isHidden = true
            self.lineMBV.isHidden = true
            self.progressView.isHidden = true
            self.selectedImgView.isHidden = false
            self.fitnesStatusBtn.isHidden = false
            self.dotBtn.isHidden = false
            
            if let ptScore = cellData.pt_score?.value{        
//                let ptValue = Int(round(Double(ptScore) ?? 0.0))
                
                self.scoreBtn.setTitle("+" + "\(ptScore)" + " score", for: .normal)
                self.scoreBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
              
            DispatchQueue.main.async {
                self.cellMBV.layer.sublayers?
                    .filter { $0.name == "apply_Shadow" }.forEach({$0.removeFromSuperlayer()})
                
                self.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 19.0/255.0, blue: 17.0/255.0, alpha: 0.6),UIColor(red: 69.0/255.0, green: 117.0/255.0, blue: 85.0/255.0, alpha: 0.5)], locations: [0.2,1.0], startPoint: CGPoint(x: 0, y: 1.0), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            }
            
        }else{
            self.fitnesStatusBtn.setTitle("", for: .normal)
        }
        
        //--------------------- progress setup
        if let scorePer = cellData.percentage?.value {
            let valuePer = (Double(scorePer) ?? 0) / 100
            
            DispatchQueue.main.async {
                self.progressView.drawLineProgress(progressfill: valuePer,fillLineColor: UIColor.appRatingYellow, cornerRadius: 2.0)
            }
        }
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }

    private func setupUI(){
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
    
    private func setupFont(){
        self.userNameLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.completedUserNameLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.fitnessTypeBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.completedFitnessTypeBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.fitnesStatusBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.scoreBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        //        self.progressView.font = AppFont.semibold.size(14.0, familyName: familyManrope)
    }
        
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.completedFitnessTypeBtn.setTitle("Complete", for: .normal)
//    }
    
    func selectionCell(isSelected:Bool){
        
        if isSelected {
            //
        }else{
           //
        }
    
    }
}
