//
//  PersonalizedCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit

class PersonalizedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var fitnessImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.titleLbl.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        cellMBV.backgroundColor = UIColor.appBorder
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
    }
    
    
    override var isSelected: Bool {
            didSet {
//                if self.isSelected {
//                    self.cellMBV.backgroundColor = UIColor.appDarkGray
//                    self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 16.0)
//                }
//                else {
//                    self.cellMBV.backgroundColor = UIColor.appBorder
//                    self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
//                }
            }
        }
    
    func setSelectdCell(_ img:UIImage? = nil, selectedImg:UIImage? = nil,isSelectedCell:Bool){
        if isSelectedCell {
         fitnessImgView.image = selectedImg
        }else{
            fitnessImgView.image = img
        }
    }
    
    func setSelectdCellUrl(_ imgStr:String? = nil, selectedImgStr:String? = nil,isSelectedCell:Bool){
        if isSelectedCell {
            fitnessImgView.loadImage(urlString: selectedImgStr, placeholder: UIImage())
        }else{
            fitnessImgView.loadImage(urlString: imgStr, placeholder: UIImage())
        }
    }
    
    
    func setupCell(){
//        cell.titleLbl.text = dataPersonalized?[indexPath.row].name as? String
        //dataPersonalized?[indexPath.row]["title"] as? String
        self.titleLbl.lineBreakMode = .byClipping
        
//        cell.fitnessImgView.loadImage(urlString: dataPersonalized?[indexPath.row].image as? String, placeholder: UIImage(named: ""))
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
    }
}
