//
//  TypesOfSessionCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 13/02/26.
//

import UIKit

class TypesOfSessionCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewTypeOfSession: UIView!
    @IBOutlet weak var imgTypeOfSession: UIImageView!
    @IBOutlet weak var lblTypeOfSession: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup() 
    }
    
    private func uiSetup() {
        self.lblTypeOfSession.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
    }

}
