//
//  TrainerAvailabilityTVCell.swift
//  MyPT
//
//  Created by Manik Goel on 07/03/26.
//

import UIKit

class TrainerAvailabilityTVCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var secondaryTrainerData: PrimaryTrainer?

    /// Index of this trainer row in the secondary trainers array.
    var trainerIndex: Int = 0

    /// Callback fired when a secondary slot is selected or deselected.
    /// Parameters: (trainerIndex, slotIndex, isSelected)
    var onSlotSelected: ((_ trainerIndex: Int, _ slotIndex: Int, _ isSelected: Bool) -> Void)?
    
    @IBOutlet weak var viewRound: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var collectiondate: UICollectionView!
//    @IBOutlet weak var btnViewSchedule: UIButton!
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var viewUnavilable: UIView!
    @IBOutlet weak var lblUnavailableTrainer: UILabel!
    @IBOutlet weak var viewUnavailableText: UIView!
    @IBOutlet weak var lblUnavailableText: UILabel!
    @IBOutlet weak var viewAvailable: UIView!
    @IBOutlet weak var viewAvailableTag: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
        setData()
    }

    private func uiSetup() {
        collectiondate.delegate = self
        collectiondate.dataSource = self
        collectiondate.register(
            UINib(nibName: "UnavailableTimeCVCell", bundle: nil),
            forCellWithReuseIdentifier: "UnavailableTimeCVCell"
        )
        viewRound.makeCircular()
        lblName.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        lblUnavailableTrainer.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        lblUnavailableText.font = AppFont.regular.size(8.0, familyName: familyFunnelSans)
        viewUnavilable.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 61.0/255.0, green: 62/255.0, blue: 63/255.0, alpha: 1.0), cornerRadious: 12.0)
    }
    
    func setData(showAvailableTag: Bool = false) {
        lblName.text = secondaryTrainerData?.name
        lblUnavailableTrainer.text = secondaryTrainerData?.name
        viewAvailable.isHidden = secondaryTrainerData?.slots?.count == 0
        viewUnavilable.isHidden = !(secondaryTrainerData?.slots?.count == 0)
        viewAvailableTag.isHidden = !showAvailableTag
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return secondaryTrainerData?.slots?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "UnavailableTimeCVCell", for: indexPath
        ) as? UnavailableTimeCVCell else { return UICollectionViewCell() }
        let slot = secondaryTrainerData?.slots?[indexPath.row]
        cell.lblTime.text = slot?.time_display?.components(separatedBy: "-").first
        cell.setSelectedSlot(slot?.isSelected ?? false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TapticEngine.selection.feedback()

        let isAlreadySelected = secondaryTrainerData?.slots?[indexPath.row].isSelected ?? false

        // Deselect all slots within this trainer's row
        for i in 0..<(secondaryTrainerData?.slots?.count ?? 0) {
            secondaryTrainerData?.slots?[i].isSelected = false
        }

        if !isAlreadySelected {
            secondaryTrainerData?.slots?[indexPath.row].isSelected = true
        }

        collectiondate.reloadData()

        // Notify the parent VC via callback
        onSlotSelected?(trainerIndex, indexPath.row, !isAlreadySelected)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 4 items per row with 8pt spacing between them
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 3  // 3 gaps for 4 columns
        let cellWidth = (collectionView.frame.size.width - totalSpacing) / 4
        return CGSize(width: cellWidth, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
