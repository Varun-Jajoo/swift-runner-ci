//
//  ExerciseTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 24/12/24.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {

    //MARK: ------------ VARIBALE
    var navCtrl:UINavigationController?
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var topTitleMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var gymNameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var categoryImgView: UIImageView!
    @IBOutlet weak var kcalImgView: UIImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var kcalLbl: UILabel!
    
    @IBOutlet weak var editPopupView: UIStackView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var lineLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.editPopupView.isHidden = true
        
        self.setupFont()
        
        DispatchQueue.main.async {
//            self.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0.2, 0.8], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1.0, y: 1.0))
//            
//            self.bgImgView.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0.2, 0.8], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1.0, y: 1.0))
            
            self.topTitleMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor.appBorder, shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 12.0)
            self.bgImgView.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.bgImgView.addBlurView(viewShow: self.bgImgView)
            self.editPopupView.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
           
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        if isSelected {
//            self.checkBtn.setImage(UIImage(named: "ic_filterChecked"), for: .normal)
//            
//        }else{
//            self.checkBtn.setImage(nil, for: .normal)
//            self.checkBtn.setImage(UIImage(named: "ic_filterUncheck"), for: .normal)
////            self.checkBtn.setCornerRadius(borderWidth: 1.7, borderColor: UIColor.appWhite, cornerRadious: 8.57)
//        }
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.gymNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.userNameLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.categoryLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        self.kcalLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        
        self.editBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.deleteBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)

    }
    
    func setupCheckedTarget(){
        self.checkBtn.addTarget(self, action: #selector(selectionBtnActn(sender: )), for: .touchUpInside)
    }
    
    @objc func selectionBtnActn(sender:UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.checkBtn.setImage(UIImage(named: "ic_filterChecked"), for: .normal)
            
        }else{
            self.checkBtn.setImage(nil, for: .normal)
            self.checkBtn.setImage(UIImage(named: "ic_filterUncheck"), for: .normal)
        }
    }
    
    func setupEditTarget(){
        self.checkBtn.addTarget(self, action: #selector(editSettingBtnActn(sender: )), for: .touchUpInside)
        self.editBtn.addTarget(self, action: #selector(editBtnActn(sender: )), for: .touchUpInside)
        self.deleteBtn.addTarget(self, action: #selector(deleteBtnActn(sender: )), for: .touchUpInside)
    }
    
    @objc func editSettingBtnActn(sender:UIButton){
        sender.isSelected = !sender.isSelected
        self.editPopupView.isHidden = false
//        if sender.isSelected {
//            self.editPopupView.isHidden = false
//        }else{
//            self.editPopupView.isHidden = true
//        }
    }
    
    @objc func editBtnActn(sender:UIButton){
        print("edit btn actn")
        self.editPopupView.isHidden = true
        
        let vc:EditExerciseViewController = EditExerciseViewController.instantiate(appStoryboard: .calendar)
        self.navCtrl?.pushViewController(vc, animated: true)
        
    }
    
    @objc func deleteBtnActn(sender:UIButton){
        print("delete btn actn")
        self.editPopupView.isHidden = true
        
        let vc:DeletePopupViewController = DeletePopupViewController.instantiate(appStoryboard: .calendar)
        vc.modalPresentationStyle = .automatic
        self.navCtrl?.present(vc, animated: true)
    }
    
}
