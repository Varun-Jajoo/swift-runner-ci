//
//  CouponsOffersTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 05/12/24.
//

import UIKit

class CouponsOffersTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var couponMBV: UIView!
    @IBOutlet weak var couponLbl: UILabel!
    @IBOutlet weak var savedLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        checkBtn.addTarget(self, action: #selector(checkBtnActn(sender: )), for: .touchUpInside)
        
        DispatchQueue.main.async {
            self.couponMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
            self.couponMBV.addDashedBorder(UIColor.txtDarkGray, filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 3.0, dashPattern: [6,2])
        }
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
