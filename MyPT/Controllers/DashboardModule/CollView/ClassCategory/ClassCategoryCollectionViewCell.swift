//
//  ClassCategoryCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 09/05/25.
//

import UIKit

class ClassCategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var bckImgView: UIImageView!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var classesNearCountLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupFont()
    }
    
    func setCellData(cellData: ClassesWithCategoryModel?){
        guard let cellData = cellData else { return }
        self.bckImgView.loadImage(urlString: cellData.categoryImage, placeholder: nil)
        self.classNameLbl.text = cellData.categoryName
        self.classesNearCountLbl.text = cellData.classCount
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.bckImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.bckImgView.addGradientImgV(colors: [UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 54.0/255.0, alpha: 1.0),UIColor(red: 13.0/255.0, green: 14.0/255.0, blue: 17.0/255.0, alpha: 0.31),UIColor(red: 0, green: 0, blue: 0, alpha: 0)], locations: [0,0.5, 1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0))
            self.cellMBV.setGradientMultiBorder(cornerRadius: 20.0, width: 1.0, colors: [UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), UIColor(red: 135.0/255.0, green: 143.0/255.0, blue: 160.0/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0))
        }
    }

    private func setupFont(){
        self.classNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.classesNearCountLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
    }
}
