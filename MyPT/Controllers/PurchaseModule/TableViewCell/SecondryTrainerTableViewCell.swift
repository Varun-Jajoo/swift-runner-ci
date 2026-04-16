//
//  SecondryTrainerTableViewCell.swift
//  SwiftUiDummy
//
//  Created by techsaga on 14/01/26.
//

import UIKit

protocol ProtocolSecondryTrainer: AnyObject {
    func secondryViewProfile()
    func secondrySelectTrainer()
}

class SecondryTrainerTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: ProtocolSecondryTrainer?
    private var categoryName: [String] = []
    
    @IBOutlet weak var constCellWidth: NSLayoutConstraint!
    @IBOutlet weak var viewBackgrnd: UIView!
    @IBOutlet weak var imgTrainer: UIImageView!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var imgRating: UIImageView!
    @IBOutlet weak var lblViewProfile: UILabel!
    @IBOutlet weak var btnS1TRainer: UILabel!
    @IBOutlet weak var viewProfileBtn: UIButton!
    @IBOutlet weak var secondryCollectionView: UICollectionView! {
        
        didSet{
            secondryCollectionView.delegate = self
            secondryCollectionView.dataSource = self
            secondryCollectionView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
//            self.viewBackgrnd.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24)
            self.lblTrainerName.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
            self.lblRating.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            self.lblViewProfile.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.btnS1TRainer.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            if let layout = secondryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.minimumInteritemSpacing = 5
                layout.minimumLineSpacing = 5
                layout.estimatedItemSize = .zero   // important
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

       guard let viewBackgrnd = viewBackgrnd else { return }

        DispatchQueue.main.async {
            viewBackgrnd.cornersWithBorder(
                radius: 16,
                corners: .allCorners,
                borderColor: .clear,
                borderWidth: 0
            )
        }
      
    }
    
//    func setCategories(_ tags: [String]) {
//        self.categoryName = tags.count > 3
//            ? Array(tags.prefix(2)) + ["+\(tags.count - 2)"]
//            : tags
//
//        secondryCollectionView.reloadData()
//    }
    
    func setCategories(_ tags: [String]) {
        if tags.count > 2 {
            let remainingCount = tags.count - 2
            categoryName = Array(tags.prefix(2))
            categoryName.append("+\(remainingCount)")
        } else {
            categoryName = tags
        }
        
        secondryCollectionView.reloadData() // or primaryCollectionView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let categoryCell: ProductCategoryCollViewCell = secondryCollectionView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as? ProductCategoryCollViewCell {
            
//            categoryCell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            
            DispatchQueue.main.async {
//                categoryCell.cellMBV.backgroundColor = .clear
                categoryCell.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.1), cornerRadious: 8)
                categoryCell.titleLblTopConstrnt.constant = 4
                categoryCell.titleLblLeading.constant = 8
                categoryCell.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
                categoryCell.titleLbl.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
                categoryCell.titleLbl.text = self.categoryName[indexPath.row]
            }
            
            return categoryCell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let text = categoryName[indexPath.row]
        let font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)

        let textWidth = text.size(withAttributes: [.font: font]).width

        let horizontalPadding: CGFloat = 16   // 8 + 8
        let height: CGFloat = 30              // safe chip height
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
//        return CGSize(
////            width: ceil(textWidth + horizontalPadding),
//            width: collectionView.frame.size.width,
//            height: height
//        )
    }
}


//            @IBAction func onTapViewProfile(_ sender: UIButton) {
//                if sender.tag == 0 {
//                    self.delegate?.secondryViewProfile()
//                } else {
//                    self.delegate?.secondrySelectTrainer()
//                }
//            }

//    }
