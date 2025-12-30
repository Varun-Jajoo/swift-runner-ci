//
//  BookingNotificationTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 05/08/25.
//

import UIKit

class BookingNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var trainerDetailsMSctk: UIStackView!
    @IBOutlet weak var bookingStatusMBV: UIView!
    @IBOutlet weak var profileTrainerMBV: UIView!
    @IBOutlet weak var rescheduleMBV: UIView!
    @IBOutlet weak var rescheduleSubMBV: UIView!
    @IBOutlet weak var addressMBV: UIView!
    @IBOutlet weak var statusBtn: UIButton!
    @IBOutlet weak var denyRequestBtn: UIButton!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var landMarkLbl: UILabel!
    @IBOutlet weak var rescheduleMsgLbl: UILabel!
    @IBOutlet weak var rescheduleBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var emptyBtn: UIButton!
    @IBOutlet weak var addAddressBtn: UIButton!
    @IBOutlet weak var addressNoteLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(cellData: BookingDataModel?){
        guard let cellData = cellData else { return }
        addressMBV.isHidden = true
        ratingBtn.setTitle(cellData.averageRating?.value, for: .normal)
        trainerImgView.loadImage(urlString: cellData.trainer_image?.value, placeholder: AppImages.profile_placeholder, resize: CGSize(width: 60, height: 60))
        trainerNameLbl.text = cellData.trainer?.value
        distanceLbl.text = cellData.distance?.value
        landMarkLbl.text = cellData.location?.value
        rescheduleMsgLbl.text = cellData.scheduleMsg?.value
       
        if let bookingType = cellData.type?.value, bookingType.lowercased() == "home", let locationAdd = cellData.location?.value, locationAdd.isEmpty{
            addressMBV.isHidden = false
        }
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.trainerImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.rescheduleSubMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 7.0)
            self.rescheduleBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.acceptBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.addAddressBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        statusBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        addressNoteLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        [
            ratingBtn.titleLabel,
            distanceLbl,
            landMarkLbl,
            rescheduleMsgLbl,
            denyRequestBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        [
            trainerNameLbl,
            rescheduleBtn.titleLabel,
            acceptBtn.titleLabel,
            addAddressBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        })
    }
}
