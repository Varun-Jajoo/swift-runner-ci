//
//  PrimaryTrainerTableViewCell.swift
//  SwiftUiDummy
//
//  Created by techsaga on 13/01/26.
//

import UIKit

protocol ProtocolPrimaryTrainer: AnyObject {
    func primaryViewProfile()
}

class PrimaryTrainerTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var delegate: ProtocolPrimaryTrainer?
    private var categoryName = ["Crossfit", "Yoga", "+3"]
    
    @IBOutlet weak var viewBackgrnd: UIView!
    @IBOutlet weak var imgTrainer: UIImageView!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var imgRating: UIImageView!
    @IBOutlet weak var lblViewProfile: UILabel!
    @IBOutlet weak var primaryCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.uiSetup()
    }
    
    private func uiSetup() {
        primaryCollectionView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        primaryCollectionView.delegate = self
        primaryCollectionView.dataSource = self
    }
    
    @IBAction func onTapViewProfile(_ sender: UIButton) {
        self.delegate?.primaryViewProfile()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let categoryCell: WorkoutCategoryCollectionViewCell = primaryCollectionView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as? WorkoutCategoryCollectionViewCell {
            
            //        DispatchQueue.main.async {
            //            categoryCell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: categoryCell.cellMBV.frame.size.height/2.0)
            //        }
            categoryCell.categoryTitleLbl.text = categoryName[indexPath.row]
            //        categoryCell.categoryTitleLbl.text = sectionData?[indexPath.row]["title"] as? String
            //        categoryCell.categoryImgView.image = sectionData?[indexPath.row]["img"] as? UIImage
            return categoryCell
        }
        return UICollectionViewCell()
    }
}
