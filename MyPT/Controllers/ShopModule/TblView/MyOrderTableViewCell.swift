//
//  MyOrderTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 05/03/25.
//

import UIKit

class MyOrderTableViewCell: UITableViewCell {

    //MARK: ---------------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var productImgView: UIImageView!
    @IBOutlet weak var stutusTitleLbl: UILabel!
    @IBOutlet weak var estimatedDelDateLbl: UILabel!
    @IBOutlet weak var paymentModeLbl: UILabel!
    @IBOutlet weak var orderIdLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.setupFont()
        
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.productImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.productImgView.addGradientImgV(colors: UIColor.appMultiColor(.gradientColor), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 0))
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupFont(){
        self.stutusTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.estimatedDelDateLbl.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.paymentModeLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.orderIdLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
    
}
