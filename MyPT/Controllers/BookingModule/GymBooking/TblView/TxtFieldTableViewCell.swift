//
//  TxtFieldTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 15/03/25.
//

import UIKit

class TxtFieldTableViewCell: UITableViewCell, UITextFieldDelegate{

    //MARK: --------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var leftImgView: UIImageView!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var hintTitleLbl: UILabel!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var leftImgViewWidthConstrnt: NSLayoutConstraint!
    @IBOutlet weak var rightBtnWidthConstrnt: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        txtField.delegate = self
//        txtField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
        
        //----------------********* font
        self.hintTitleLbl.font = AppFont.medium.size(10.0, familyName: familyManrope)
        self.txtField.font = AppFont.semibold.size(16.0, familyName: familyManrope)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
        
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//    }
//    
////    func textFieldDidBeginEditing(_ textField: UITextField) {
//        
//        if let isEmptyTxt = self.txtField.text?.isEmpty, !isEmptyTxt {
//            self.hintTitleLbl.isHidden = false
//            self.hintTitleLbl.text = "Test"
//        } else {
//            self.hintTitleLbl.isHidden = true
//            self.hintTitleLbl.text = nil
//        }
//    }
    
//    
//    @objc func textFieldDidChange(textField: UITextField){
//        
//        if let isEmptyTxt = textField.text?.isEmpty, !isEmptyTxt {
//            self.hintTitleLbl.isHidden = false
//            self.hintTitleLbl.text = "Test"
//        } else {
//            
//            self.hintTitleLbl.isHidden = true
//            self.hintTitleLbl.text = nil
//        }
//        self.reloadInputViews()
//        self.layoutIfNeeded()
//    }
    
}
