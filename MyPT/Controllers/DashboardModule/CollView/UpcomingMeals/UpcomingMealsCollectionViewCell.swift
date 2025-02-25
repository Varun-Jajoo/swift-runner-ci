//
//  UpcomingMealsCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/11/24.
//

import UIKit

class UpcomingMealsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var kcalBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var proteinBtn: UIButton!
    @IBOutlet weak var fatBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24.0)
            
            self.cellMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .axial)
            
            
        }
        
        self.proteinBtn.titleLabel?.numberOfLines = 2
        self.proteinBtn.titleLabel?.lineBreakMode = .byClipping
        
  
    }
    

}
