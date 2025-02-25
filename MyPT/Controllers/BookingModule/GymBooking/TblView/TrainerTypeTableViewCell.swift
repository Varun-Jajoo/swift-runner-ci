//
//  TrainerTypeTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import UIKit

class TrainerTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var bgImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
          
            self.bgImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cellMBV.layerGradient(startPoint: .topLeft, endPoint: .centerRight, colorArray: [UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor ,UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor], type: .axial)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            DispatchQueue.main.async {
                self.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 158/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
//                self.trainerImgView.image = UIImage(named: "ic_homeWorkout")
            }
        }else{
            DispatchQueue.main.async {
                self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
                
//                if let imgView = UIImage(named: "ic_homeWorkout") {
//                    self.trainerImgView.image = createGrayBlurImage(from: imgView, blurRadius: 2.0)
//                }
            }
        }
    }
    
    
    func setSelectdBGCell(_ img:UIImage? = nil, selectedImg:UIImage? = nil,isSelectedCell:Bool){
        if !isSelectedCell {
            self.bgImgView.image = img
        }else{
            if let imgView = selectedImg {
                self.bgImgView.image = imgView
            }
        }
    }
    
    func setSelectdCell(_ img:UIImage? = nil, selectedImg:UIImage? = nil,isSelectedCell:Bool){
        if isSelectedCell {
            self.trainerImgView.image = img
        }else{
            if let imgView = selectedImg {
                self.trainerImgView.image = createGrayBlurImage(from: imgView, blurRadius: 2.0)?.resized(to: CGSize(width: imgView.size.width, height: imgView.size.height))
                self.trainerImgView.contentMode = .scaleToFill
                self.trainerImgView.layer.masksToBounds = true
            }
            
//            self.trainerImgView.image = img
        }
    }
}
