//
//  CouponsOffersTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 05/12/24.
//

import UIKit

protocol CouponsOffersTableViewCellDelegate: AnyObject {
    func didTapApplyCoupon()
}


class CouponsOffersTableViewCell: UITableViewCell {

    weak var delegate: CouponsOffersTableViewCellDelegate?
    var applyAction: (() -> Void)?
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var lblCouonName: UILabel!
    @IBOutlet weak var lblExpireDate: UILabel!
    @IBOutlet weak var lblSavedAED: UILabel!
    @IBOutlet weak var btnApply: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1), cornerRadious: 16)
            self.lblCouonName.font =  AppFont.regular.size(16, familyName: familyFunnelSans)
            self.lblExpireDate.font =  AppFont.regular.size(14, familyName: familyFunnelSans)
            self.lblSavedAED.font =  AppFont.semibold.size(12, familyName: familyFunnelSans)
        }
    }
    
    
    @IBAction func onTapApply(_ sender: UIButton) {
        applyAction?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

//        if selected {
//            self.checkBtn.isSelected = true
//        }else{
//            self.checkBtn.isSelected = false
//        }
    }
    
//    @objc func checkBtnActn(sender: UIButton){
//         print("check btn clicked", sender.tag)
////         self.checkBtn.isSelected = true
//                 if sender.isSelected {
//                     self.checkBtn.isSelected = true
//                 }else{
//                     self.checkBtn.isSelected = false
//                 }
//         
////        if sender.tag == 101 {
////            self.checkBtn.isSelected = true
////        }else{
////            self.checkBtn.isSelected = false
////        }
//    }

    
}

