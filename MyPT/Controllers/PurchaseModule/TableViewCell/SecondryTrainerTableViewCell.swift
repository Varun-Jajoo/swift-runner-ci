//
//  SecondryTrainerTableViewCell.swift
//  SwiftUiDummy
//
//  Created by techsaga on 14/01/26.
//

import UIKit


protocol ProtocolSecondryTrainer: AnyObject {
    func secondryViewProfile()
    func secondrySelectTrainer()
}


class SecondryTrainerTableViewCell: UITableViewCell {

            weak var delegate: ProtocolSecondryTrainer?
            
            @IBOutlet weak var viewBackgrnd: UIView!
            @IBOutlet weak var imgTrainer: UIImageView!
            @IBOutlet weak var lblTrainerName: UILabel!
            @IBOutlet weak var lblRating: UILabel!
            @IBOutlet weak var imgRating: UIImageView!
            @IBOutlet weak var lblViewProfile: UILabel!
            @IBOutlet weak var btnS1TRainer: UIButton!
            
            override func awakeFromNib() {
                super.awakeFromNib()
                // Initialization code
            }

            
            @IBAction func onTapViewProfile(_ sender: UIButton) {
                if sender.tag == 0 {
                    self.delegate?.secondryViewProfile()
                } else {
                    self.delegate?.secondrySelectTrainer()
                }
            }
        
    }
