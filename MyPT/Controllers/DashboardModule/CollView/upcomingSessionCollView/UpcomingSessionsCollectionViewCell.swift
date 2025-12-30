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
    @IBOutlet weak var trackBtn: UIButton!
    
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
        trackBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
    }
    
    func setinputData(data: BookingDataModel?){
        
        guard let getData = data else { return }
        
//        self.bgImgView.loadImage(urlString: getData.trainer_image, placeholder: UIImage())
//        self.leftUserImg.loadImage(urlString: getData.trainer_image, placeholder: UIImage())
        
        let dateStr = (DateFormatterHelper.shared.getDateFromFormat(fromDate: (getData.timing?.value ?? ""), fromFormat: "MMM dd, yyyy, h:mm a", toFormat: "dd/MM/yy") ?? "")
        let slot = (getData.selected_slot?.value ?? "")
        let bullet = "\u{2022}"

        // Create attributed strings
        let dateAttr = NSAttributedString(string: dateStr + " ", attributes: [
            .foregroundColor: UIColor.appWhite
        ])
        let bulletAttr = NSAttributedString(string: bullet + " ", attributes: [
            .foregroundColor: UIColor.txtDarkGray
        ])

        let slotAttr = NSAttributedString(string: slot, attributes: [
            .foregroundColor: UIColor.appWhite
        ])

        // make Attr date time
        let dateTimeAttr = NSMutableAttributedString()
        dateTimeAttr.append(dateAttr)
        dateTimeAttr.append(bulletAttr)
        dateTimeAttr.append(slotAttr)
        
//        self.sessionTitleLbl.text = "4th Session"
        self.sessionDateLbl.attributedText = dateTimeAttr
        self.userNameLbl.text = getData.trainer?.value
        self.distanceBtn.setTitle(getData.distance?.value, for: .normal)
        self.addrBtn.setTitle(getData.location?.value, for: .normal)
        self.noteLbl.text = "Training Session Details"
        
//        self.bgImgView.image = UIImage(named: "ic_UpcomingSessions")
        self.leftUserImg.loadImage(urlString: getData.trainer_image?.value, placeholder: UIImage()) //some time image auto cropped if ratio of image is not getting 0.4 (i.e. width = 0.4 × height)
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }

}
