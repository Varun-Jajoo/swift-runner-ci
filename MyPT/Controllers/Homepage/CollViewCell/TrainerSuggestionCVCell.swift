//
//  TrainerSuggestionCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 08/02/26.
//

import UIKit

class TrainerSuggestionCVCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    var trainerData: SubscriptionSlotTrainer?

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var lblTrainerAvailability: UILabel!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var collectionTime: UICollectionView!
    @IBOutlet weak var btnQuickBook: UIButton!
    @IBOutlet weak var btnFullReschedule: UIButton!
    @IBOutlet weak var imgTrainer: UIImageView!
    @IBOutlet weak var btnStackView: UIStackView!
    @IBOutlet weak var viewInfo: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }
    
    private func uiSetup() {
        collectionTime.delegate = self
        collectionTime.dataSource = self
        collectionTime.register(
            UINib(nibName: "TimeSlotCVCell", bundle: nil),
            forCellWithReuseIdentifier: "TimeSlotCVCell"
        )
        viewBackground.cornersWithBorder(radius: 16, corners: .allCorners)
        imgBackground.cornersWithBorder(radius: 16, corners: .allCorners)
        imgTrainer.cornersWithBorder(radius: 18, corners: .allCorners)
        self.lblTrainerAvailability.font = AppFont.regular.size(13.0, familyName: familyFunnelSans)
        self.lblTrainerName.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        
        DispatchQueue.main.async {
             self.btnQuickBook.setTitle("QUICK BOOK  ", for: .normal)
             self.btnQuickBook.setImage(UIImage(named: "blackRightArrow"), for: .normal)
             self.btnQuickBook.semanticContentAttribute = .forceRightToLeft
             self.btnQuickBook.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
             self.btnQuickBook.tintColor = .mainBg   // arrow color
             self.btnQuickBook.backgroundColor = .appWhite
             self.btnQuickBook.setTitleColor(.mainBg, for: .normal)
             self.btnQuickBook.cornersWithBorder(radius: 8, corners: .allCorners)
        }
    }

    func configure(with data: SubscriptionSlotTrainer) {
        self.trainerData = data
        lblTrainerName.text = data.name
        
        if let profileUrl = data.profile {
            imgTrainer.loadImage(urlString: profileUrl, placeholder: nil)
        }
        collectionTime.reloadData()
    }

    
    @IBAction func onTapQuickBook(_ sender: UIButton) {
        if sender.tag == 0 {
            
        } else {
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trainerData?.slots?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TimeSlotCVCell",
            for: indexPath
        ) as! TimeSlotCVCell
        let slot = trainerData?.slots?[indexPath.row]
        cell.lblTime.text = slot?.time
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150, height: 32)
    }
}
