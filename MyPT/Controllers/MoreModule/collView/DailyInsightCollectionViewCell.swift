//
//  DailyInsightCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 13/02/25.
//

import UIKit

class DailyInsightCollectionViewCell: UICollectionViewCell {

   var onMenuButtonTapped: ((_ button: UIButton) -> Void)?
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var insightModeBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var rangeBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupFont()
        
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
        }
    }
    
    func setupFont(){
        self.insightModeBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.infoBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.rangeBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.timeLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        infoBtn.addTarget(self, action: #selector(handleMenuButtonTap), for: .touchUpInside)
    }

    @objc private func handleMenuButtonTap() {
           // Call the closure and pass the button itself, so the view controller knows the tap came from this button
           onMenuButtonTapped?(infoBtn)
       }

}
