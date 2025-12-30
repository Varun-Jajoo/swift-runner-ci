//
//  WorkoutsCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 06/01/25.
//

import UIKit

class WorkoutsCollectionViewCell: UICollectionViewCell {

    //MARK: -----------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var topMBV: UIView!
    @IBOutlet weak var timingMBV: UIView!
    @IBOutlet weak var kcalMBV: UIView!
    @IBOutlet weak var repsMBV: UIView!
    @IBOutlet weak var topCategoryLbl: UILabel!
    @IBOutlet weak var workoutNameLbl: UILabel!
    @IBOutlet weak var workoutseriesLbl: UILabel!
    @IBOutlet weak var timingTitleLbl: UILabel!
    @IBOutlet weak var kcalTitleLbl: UILabel!
    @IBOutlet weak var repsTitleLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var videoPlayBtn: UIButton!
    @IBOutlet weak var timing: UIImageView!
    @IBOutlet weak var kcal: UIImageView!
    @IBOutlet weak var reps: UIImageView!
    @IBOutlet weak var bckMImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setupUI()
        self.setupFont()
    }

    func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 24.0)
//            self.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0), UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 24.0)
            self.topMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
        }
    }
    
    func setupFont(){
        self.topCategoryLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.workoutNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.workoutseriesLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.timingTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.kcalTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.repsTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        
        //bold - 14
        //semi-bold - 12
        
//        //-------------------- Attributed Text for Price
//        let defaultAttributes = [
//            .font: AppFont.bold.size(14.0, familyName: familyManrope),
//            .foregroundColor: UIColor.appWhite
//        ] as [NSAttributedString.Key : Any]
//        
//        let makeAttributes = [
//            .font: AppFont.semibold.size(12.0, familyName: familyManrope),
//            .foregroundColor: UIColor.appWhite
//        ] as [NSAttributedString.Key : Any]
//        
//        let attributedNickName = [
//            "360",
//            NSAttributedString(string: "AED",
//                               attributes: makeAttributes)
//        ] as [AttributedStringComponent]
//        
//        self.timingTitleLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
 
    
//    @objc func likeBtnActn(sender: UIButton){
//        sender.isSelected = !sender.isSelected
//        if sender.isSelected {
//            self.likeBtn.setImage(UIImage(named: "ic_redHeartbeat"), for: .selected)
//        }else{
//            self.likeBtn.setImage(UIImage(named: "ic_heart"), for: .normal)
//        }
//        
//    }
    
    //MARK: -------------SET feature Cell CELL DATA
    func featureCell(cellData: FeaturedModel?){
        guard let cellData = cellData else { return }
        if let imgBck = cellData.image?.value {
            self.bckMImgView.loadImage(urlString: "\(imgBck)", placeholder: AppImages.othersGender, resize: CGSize(width: 400.0, height: 400.0))
        }
        
        self.topCategoryLbl.text = cellData.category?.value
        self.workoutNameLbl.text = cellData.title?.value
        self.workoutseriesLbl.text = cellData.seriesName?.value
        
        self.repsMBV.isHidden = false
        self.timingMBV.isHidden = false
        self.kcalMBV.isHidden = true
        
        self.timing.image = UIImage(named: "ic_solid_fireGray")
        self.reps.image = UIImage(named: "ic_clockGray")
        
        if let caloriesStr = cellData.calories?.value {
            self.timingTitleLbl.text = "\(caloriesStr)" + " kcal"
        }
        self.repsTitleLbl.text = cellData.duration
        
        self.likeBtn.setImage(UIImage(named: "ic_heart"), for: .normal)
        if let isFavourite = cellData.isFavourite, isFavourite {
            self.likeBtn.setImage(UIImage(named: "ic_redHeartbeat"), for: .normal)
        }
        
//            featuredCell.timingTitleLbl.text = "\(String(describing: self.gymFeaturedData?[indexPath.row].calories?.value))" + " kcal" //"251 kcal"
//        self.repsTitleLbl.text = cellData.duration
    }
    
    
    //MARK: -------------SET workoutsCell CELL DATA
    func workoutsCell(cellData: GetWorkoutsModel?){
        guard let cellData = cellData else { return }
        if let imgBck = cellData.image {
            self.bckMImgView.loadImage(urlString: "\(imgBck)", placeholder: AppImages.othersGender, resize: CGSize(width: 400.0, height: 400.0))
        }
        
        self.topCategoryLbl.text = cellData.category_name
        self.workoutNameLbl.text = cellData.name
        self.workoutseriesLbl.text = nil
        
        self.repsMBV.isHidden = false
        self.timingMBV.isHidden = false
        self.kcalMBV.isHidden = true
        
        self.timing.image = UIImage(named: "ic_solid_fireGray")
        self.reps.image = UIImage(named: "ic_clockGray")
        
        self.repsTitleLbl.text = cellData.time
        if let exercises = cellData.exercises?.value {
            self.timingTitleLbl.text = exercises + " Exercises"
        }else{
            self.timingTitleLbl.text = nil
        }
        
        self.likeBtn.setImage(UIImage(named: "ic_heart"), for: .normal)
        if let isFavourite = cellData.isFeatured, isFavourite {
            self.likeBtn.setImage(UIImage(named: "ic_redHeartbeat"), for: .normal)
        }
        
    }
    
}
