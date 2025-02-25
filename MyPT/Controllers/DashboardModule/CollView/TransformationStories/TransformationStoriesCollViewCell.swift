//
//  TransformationStoriesCollViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 11/11/24.
//

import UIKit

class TransformationStoriesCollViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var transformationSeriesImgView: UIImageView!
    @IBOutlet weak var quatImgView: UIImageView!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var beforeMBV: UIView!
    @IBOutlet weak var afterMBV: UIView!
    @IBOutlet weak var beforeLbl: UILabel!
    @IBOutlet weak var afterLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpFont()
        DispatchQueue.main.async {
            self.cellMBV.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)
            self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
        }
    }
    
    
    //------------------************Font
    func setUpFont(){
        self.messageLbl.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.nameLbl.font = AppFont.medium.size(14.0, familyName: familyClashDisplay)
        self.beforeLbl.font = AppFont.medium.size(10.0, familyName: familyClashDisplay)
        self.afterLbl.font = AppFont.medium.size(10.0, familyName: familyClashDisplay)
    }
    
}
