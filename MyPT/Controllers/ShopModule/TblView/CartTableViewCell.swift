//
//  CartTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 27/02/25.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    //MARK: ---------------VARIABLE
    private var procutCount: Int = 0{
        didSet{
            if procutCount > 0{
                itemsCount.setTitle("\(procutCount)", for: .normal)
            }
        }
    }
    
    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var productImgMBV: UIView!
    @IBOutlet weak var productImgView: UIImageView!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var productPriceLbl: UILabel!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var itemsCount: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupFont()
        
        self.minusBtn.addTarget(self, action: #selector(minusProductBtnActn(sender: )), for: .touchUpInside)
        self.addBtn.addTarget(self, action: #selector(addProductsBtnActn(sender: )), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.productImgMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12)
            self.productImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont(){
        self.productNameLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.itemsCount.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
            
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.medium.size(20.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.medium.size(12.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
                
        let discountAttributed = [
            "299",
            NSAttributedString(string: "AED",
                               attributes: makeAttributes),
            "329AED".strikeThrough(with: AppFont.regular.size(12.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray)
        ] as [AttributedStringComponent]
        
        self.productPriceLbl.attributedText = NSAttributedString(from: discountAttributed, defaultAttributes: defaultAttributes)
    }
    
    @objc func minusProductBtnActn(sender: UIButton){
        guard procutCount != 0 else {
            return
        }
        procutCount -= 1
    }
    
    @objc func addProductsBtnActn(sender: UIButton){
        
        procutCount += 1
    }
}
