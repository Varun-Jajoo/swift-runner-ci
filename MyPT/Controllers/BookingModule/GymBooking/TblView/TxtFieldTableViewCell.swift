//
//  TxtFieldTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 15/03/25.
//

import UIKit

protocol CustomCellDelegate: AnyObject {
    func textFieldDidUpdate(_ placeHoldere: String?, _ text: String, atSectiion Section: Int, at indexPath: IndexPath)
}


class TxtFieldTableViewCell: UITableViewCell, UITextFieldDelegate{

    var indexPath: IndexPath?
    var atSection: Int?
    weak var delegate: CustomCellDelegate?
    
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
    
    func configure(withPlaceHolder placeholder: String?, with text: String, section: Int?, at indexPath: IndexPath) {
        self.indexPath = indexPath
        self.atSection = section

        txtField.text = text
        txtField.placeholder = placeholder
        txtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        updateHintLabel(for: text, placeholder: placeholder)
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, let indexPath = indexPath else { return }
        delegate?.textFieldDidUpdate(textField.placeholder, text, atSectiion: 0, at: indexPath)

        updateHintLabel(for: text, placeholder: textField.placeholder)
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let section = self.atSection, let indexPath = indexPath else { return }
        delegate?.textFieldDidUpdate(textField.placeholder, text, atSectiion: section , at: indexPath)
    }

    private func updateHintLabel(for text: String?, placeholder: String?) {
        let isEmpty = (text ?? "").isEmpty
        hintTitleLbl.text = isEmpty ? nil : placeholder
        hintTitleLbl.isHidden = isEmpty
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}
