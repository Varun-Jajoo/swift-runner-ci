//
//  WorkoutGymCategoryCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 06/01/25.
//

import UIKit

class WorkoutGymCategoryCollectionViewCell: UICollectionViewCell {

    //MARK: ------------ IBOUITLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titlLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titlLbl.font = AppFont.semibold.size(9.0, familyName: familyManrope)
        self.setupUI()
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
//            self.cellMBV.addGradient(colors: [UIColor(red: 22.0/255.0, green: 26.0/255.0, blue: 27.0/255.0, alpha: 1.0),UIColor(red: 27.0/255.0, green: 47.0/255.0, blue: 76.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
            self.imgView.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
        }
        
    }
    
}
