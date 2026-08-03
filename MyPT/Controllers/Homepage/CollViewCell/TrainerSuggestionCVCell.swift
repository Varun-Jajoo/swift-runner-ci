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
    @IBOutlet weak var lblInfo: UILabel!
    
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
        self.lblInfo.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        
        DispatchQueue.main.async {
            self.btnQuickBook.setTitle("QUICK BOOK  ", for: .normal)
            self.btnQuickBook.setImage(UIImage(named: "blackRightArrow"), for: .normal)
            self.btnQuickBook.semanticContentAttribute = .forceRightToLeft
            self.btnQuickBook.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnQuickBook.tintColor = .mainBg   // arrow color
            self.btnQuickBook.backgroundColor = .appWhite
            self.btnQuickBook.setTitleColor(.mainBg, for: .normal)
            self.btnQuickBook.cornersWithBorder(radius: 8, corners: .allCorners)
            self.viewInfo.cornersWithBorder(
                radius: 12,
                corners: .allCorners,
                borderColor: UIColor(red: 238/255, green: 77/255, blue: 55/255, alpha: 0.13),
                borderWidth: 3
            )
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
    
//    // Prevent inner TimeSlotCVCell highlight from dimming viewInfo/lblInfo
//    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//        return false
//    }
}
