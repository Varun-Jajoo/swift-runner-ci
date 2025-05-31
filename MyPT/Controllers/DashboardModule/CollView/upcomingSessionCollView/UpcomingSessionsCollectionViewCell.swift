//
//  UpcomingSessionsCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/11/24.
//

import UIKit

class UpcomingSessionsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    
    @IBOutlet weak var leftUserImg: UIImageView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var sessionDateLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var addrBtn: UIButton!
    @IBOutlet weak var bottomMBV: UIView!
    @IBOutlet weak var noteLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24.0)
            self.bgImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24.0)
            self.bottomMBV.roundSideCorners(radius: 24.0, cornerSide: [.topLeft])
            
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 24.0)
                        
            self.bottomMBV.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.7)
        }
        
        self.fontSetup()
    }
    
    private func fontSetup(){
        sessionTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        sessionDateLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        userNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        distanceBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        addrBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        noteLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
    }
    
    func setinputData(data: BookingDataModel?){
        
        guard let getData = data else { return }
        
//        self.bgImgView.loadImage(urlString: getData.trainer_image, placeholder: UIImage())
//        self.leftUserImg.loadImage(urlString: getData.trainer_image, placeholder: UIImage())
        
        self.sessionTitleLbl.text = "8th session"
        self.sessionDateLbl.text = getData.timing
        self.userNameLbl.text = getData.trainer
        self.distanceBtn.setTitle("2km", for: .normal)
        self.addrBtn.setTitle(getData.location, for: .normal)
        self.noteLbl.text = "Training Session Details"
        
        self.bgImgView.image = UIImage(named: "ic_UpcomingSessions")
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }

}
