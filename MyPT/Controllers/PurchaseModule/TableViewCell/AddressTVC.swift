//
//  AddressTVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 31/01/26.
//

import UIKit

class AddressTVC: UITableViewCell {

    @IBOutlet weak var imgSelectedStatus: UIImageView!
    @IBOutlet weak var lblAddressHeading: UILabel!
    
    @IBOutlet weak var lblAddressDescription: UILabel!
    @IBOutlet weak var lblAddressName: UILabel!
    @IBOutlet weak var viewAddressName: UIView!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewAddressName.layer.cornerRadius = 10
        mainView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(addressData : AddressDataModel?) {
        lblAddressName.text = addressData?.type ?? ""
        lblAddressHeading.text = addressData?.building_name?.value ?? "" + (addressData?.villa_name?.value ?? "") + (addressData?.street?.value ?? "")
        lblAddressDescription.text = addressData?.emirate_name?.value ?? ""
    }
}
