//
//  GymsNearbyCollViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 11/11/24.
//

import UIKit

class GymsNearbyCollViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var gymImgView: UIImageView!
    @IBOutlet weak var myStudioImgView: UIImageView!
    @IBOutlet weak var studioTitleLbl: UILabel!
    @IBOutlet weak var gymNameLbl: UILabel!
    @IBOutlet weak var distance: UIButton!
    @IBOutlet weak var landmark: UIButton!
    @IBOutlet weak var timing: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var crossfittLbl: UILabel!
    @IBOutlet weak var categoryGymsLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var voucherImgView: UIImageView!
    @IBOutlet weak var voucherLbl: UILabel!
    @IBOutlet weak var ratingGym: UIButton!
    @IBOutlet weak var card1MBV: UIView!
    @IBOutlet weak var card2MBV: UIView!
    @IBOutlet weak var card3MBV: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpFont()
        self.setupUI()
    }

    //MARK: ---------------SET INPUT DATA
    func setCellData(studioData: TrainerModel?){
        guard let studioData = studioData else { return }
        self.studioTitleLbl.text = studioData.studioTag
        self.gymImgView.loadImage(urlString: studioData.profile, placeholder: UIImage())
        self.gymNameLbl.text = studioData.name
        self.distance.setTitle(studioData.distance, for: .normal)
        self.landmark.setTitle(studioData.location, for: .normal)
        self.timing.setTitle(studioData.timing, for: .normal)
        self.descLbl.text = studioData.description
        self.ratingGym.setTitle(studioData.noOfRating, for: .normal)
        self.card1MBV.isHidden = true
        self.card2MBV.isHidden = true
        self.card3MBV.isHidden = true
        
        if let tagCount = studioData.activity?.count {
            if tagCount >= 1 {
                self.card1MBV.isHidden = false
                self.crossfittLbl.text = studioData.activity?.first?.name
            }else{
                self.crossfittLbl.text = nil
            }
            
            if tagCount >= 2 {
                self.card2MBV.isHidden = false
                self.categoryGymsLbl.text = studioData.activity?[1].name
            }else{
                self.categoryGymsLbl.text = nil
            }
            
            if tagCount >= 3 {
                self.card3MBV.isHidden = false
                self.countLbl.text = "+3"
            }else{
                self.countLbl.text = nil
            }
            
        }
        
        /*
         card1MBV
         card2MBV
         card3MBV
         */
        //        self.crossfittLbl
        //        self.categoryGymsLbl
        //        self.countLbl
        //        self.voucherLbl
        //        self.ratingGym
        
//        self.setupUI()
    }
    
    //MARK: ---------------SETUPUI
    private func setupUI(){
        DispatchQueue.main.async {
            self.voucherImgView.roundBottomCorners(radius: 8.0)
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.gymImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,0.8], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
            
            [
                self.ratingGym,
                self.card1MBV,
                self.card2MBV,
                self.card3MBV
            ].forEach({[weak self] in
                guard self != nil else { return }
//                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8)
                $0.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.25), offSet: .zero, opacity: 0.4, shadowRadius: 5.0, cornerRadious: 8.0)
            })
            
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
    }
    
    //------------------************Font
    private func setUpFont(){
        self.studioTitleLbl.font = AppFont.bold.size(12.0, familyName: familyManrope)
        self.voucherLbl.font = AppFont.bold.size(10.0, familyName: familyManrope)
        self.gymNameLbl.font = AppFont.semibold.size(16.0, familyName: familyClashDisplay)
        self.descLbl.font = AppFont.regular.size(10.0, familyName: familyManrope)
        
        [
            self.distance.titleLabel,
            self.landmark.titleLabel,
            self.timing.titleLabel
        ].forEach({[weak self] in
            guard self != nil else { return }
            $0?.font = AppFont.semibold.size(8.0, familyName: familyManrope)
        })
        
        [
            self.crossfittLbl,
            self.categoryGymsLbl,
            self.countLbl,
            self.ratingGym.titleLabel
        ].forEach({[weak self] in
            guard self != nil else { return }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
    }
    
    
}
