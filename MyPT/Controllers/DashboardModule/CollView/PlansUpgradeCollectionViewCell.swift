//
//  UserPlansCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 28/07/25.
//

import UIKit

class PlansUpgradeCollectionViewCell: UICollectionViewCell {

    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var subsTitleMBV: UIView!
    @IBOutlet weak var leftlineMBV: UIView!
    @IBOutlet weak var rightlineMBV: UIView!
    @IBOutlet weak var sessionDetailsStck: UIStackView!
    @IBOutlet weak var validityMBV: UIView!
    @IBOutlet weak var sessionNumMBV: UIView!
    @IBOutlet weak var sessionAmtMBV: UIView!
    @IBOutlet weak var renewPartMBV: UIView!
    @IBOutlet weak var planGrdntImgView: UIImageView!
    @IBOutlet weak var subscriptionImgView: UIImageView!
    @IBOutlet weak var subscriptionTitleLbl: UILabel!
    @IBOutlet weak var sessionDescLbl: UILabel!
    @IBOutlet weak var validityTitleLbl: UILabel!
    @IBOutlet weak var validityShowLbl: UILabel!
    @IBOutlet weak var numSessionTitleLbl: UILabel!
    @IBOutlet weak var showNumSessionLbl: UILabel!
    @IBOutlet weak var sessionAmtTitleLbl: UILabel!
    @IBOutlet weak var showSessionAmtLbl: UILabel!
    @IBOutlet weak var renewRemainingDurationBtn: UIButton!
    @IBOutlet weak var topupUpgrateBtn: UIButton!
    @IBOutlet weak var renewBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.renewRemainingDurationBtn.isUserInteractionEnabled = false
        self.setupUI()
        self.setupFont()
    }

    func setCellData(cellData: PlanDetailsModel?){
        guard let cellData = cellData else { return }
        self.subscriptionTitleLbl.text = (cellData.type?.value ?? "") + " Subscription"
       
        if let remaining_days = cellData.remaining_days?.value {
            let subscriptionDescStr = "Subscription Ending in \(remaining_days) Days!"
            self.sessionDescLbl.attributedText = gradientAttr(labl: self.sessionDescLbl, txtStr: subscriptionDescStr, inputFont: AppFont.medium.size(22.0, familyName: familyClashDisplay))
        }
       
        if let validity_days = cellData.validity_days?.value {
            self.validityShowLbl.attributedText = gradientAttr(labl: self.validityShowLbl, txtStr: "\(validity_days) Days")
        }
        
        if let sessions = cellData.sessions?.value {
            self.showNumSessionLbl.attributedText = gradientAttr(labl: self.showNumSessionLbl, txtStr: "\(sessions)")
        }
       
        if let amount = cellData.amount?.value {
            self.showSessionAmtLbl.attributedText = gradientAttr(labl: self.showSessionAmtLbl, txtStr: "\(amount) AED")
        }
        
        self.renewRemainingDurationBtn.setTitle(cellData.msg?.value, for: .normal)
       
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.leftlineMBV.addGradient(colors: [UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1),UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            self.rightlineMBV.addGradient(colors: [UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0),UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            
            self.topupUpgrateBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.renewBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.renewPartMBV.applyShadow(fillColor: UIColor.clear, shadowColor: UIColor.mainBg.withAlphaComponent(0.6), shadowRadius: 0.4, opacity: 0.8, offset: .zero, cornerRadius: 0)
              
            self.renewPartMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
            self.renewPartMBV.setCornerRadius(borderWidth: 0.7, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.renewRemainingDurationBtn.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
        }
    }
    
    private func setupFont(){
        
//        let subscriptionDescStr = "Subscription Ending in 30 Days!"
//        self.sessionDescLbl.attributedText = gradientAttr(labl: self.sessionDescLbl, txtStr: subscriptionDescStr, inputFont: AppFont.medium.size(22.0, familyName: familyClashDisplay))
//        self.validityShowLbl.attributedText = gradientAttr(labl: self.validityShowLbl, txtStr: "365 Days")
//        self.showNumSessionLbl.attributedText = gradientAttr(labl: self.showNumSessionLbl, txtStr: "100")
//        self.showSessionAmtLbl.attributedText = gradientAttr(labl: self.showSessionAmtLbl, txtStr: "960 AED")
        
        subscriptionTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
       
        renewRemainingDurationBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
    
        [
            self.validityTitleLbl,
            self.numSessionTitleLbl,
            self.sessionAmtTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            
            $0?.font = AppFont.medium.size(12.0, familyName: familyManrope)
        })
        
        self.topupUpgrateBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.renewBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
    }
    
    private func gradientAttr(labl: UILabel, txtStr: String, inputFont: UIFont? = AppFont.medium.size(20.0, familyName: familyClashDisplay)) -> NSAttributedString {
        let attStr = txtStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: labl.bounds, font: inputFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        
        return attStr
    }
}
