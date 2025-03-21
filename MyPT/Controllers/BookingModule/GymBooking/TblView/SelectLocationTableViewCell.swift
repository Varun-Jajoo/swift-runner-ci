//
//  SelectLocationTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 17/03/25.
//

import UIKit

//protocol SelectionAddressProtocol {
//    func selectedId(idStr: String?)
//}

class SelectLocationTableViewCell: UITableViewCell {

//    var delegate:SelectionAddressProtocol?
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var addrLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        setupFont()
//        selectBtn.addTarget(self, action: #selector(selectAddrBtnActn(sender: )), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(cellData: AddressDataModel?){
        guard let cellData = cellData else { return  }
        self.homeBtn.setTitle(cellData.type?.localizedCapitalized, for: .normal)
        
        let fullAddrStr = [cellData.building_name?.value, cellData.street?.value, cellData.landmark, cellData.city_name, cellData.country_name]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        
        self.addrLbl.text = fullAddrStr
     
        //-------------------- Attributed Text for Mobile
        let defaultAttributes = [
            .font:  AppFont.semibold.size(14.0, familyName: familyManrope),
            .foregroundColor: UIColor.txtDarkGray
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font:  AppFont.semibold.size(14.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
                
        let txtAttributed = [
            "Mobile: ",
            NSAttributedString(string: (cellData.mobile_no?.value ?? ""),
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.mobileLbl.attributedText = NSAttributedString(from: txtAttributed, defaultAttributes: defaultAttributes)
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 13.0)
            self.homeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.editBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
    }
    
    
    private func setupFont(){
        self.addrLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.mobileLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.homeBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.editBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
    }
    
    /*
    @objc func selectAddrBtnActn(sender: UIButton){
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            sender.isSelected = true
            delegate?.selectedId(idStr: sender.accessibilityHint)
        }else {
            sender.isSelected = false
        }
    }
    */
}
