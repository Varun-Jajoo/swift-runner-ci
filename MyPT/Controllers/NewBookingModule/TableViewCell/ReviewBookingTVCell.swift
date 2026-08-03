//
//  ReviewBookingTVCell.swift
//  MyPT
//
//  Created by Manik Goel on 05/07/26.
//

import UIKit

class ReviewBookingTVCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var primaryCollection: UICollectionView!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var imgBadge: UIImageView!
    @IBOutlet weak var lblBadge: UILabel!
    @IBOutlet weak var heightOfCollectionView: NSLayoutConstraint!
    
    // MARK: - Closure — parent VC calls this to get the natural height once the collection is laid out
    var onHeightResolved: ((CGFloat) -> Void)?

    // MARK: - Data
    private var trainerData: TrainersSlotData?

    // MARK: - Setup
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollection()
        setupFonts()
    }

    private func setupFonts() {
        lblTrainerName.font = AppFont.medium.size(18.0, familyName: familyClashDisplay)
        lblBadge.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
    }

    private func setupCollection() {
        primaryCollection.delegate = self
        primaryCollection.dataSource = self
        primaryCollection.register(
            UINib(nibName: "PrimaryDateTimeCVCell", bundle: nil),
            forCellWithReuseIdentifier: "PrimaryDateTimeCVCell"
        )
        primaryCollection.isScrollEnabled = false

        // Left-aligned wrapping layout
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        primaryCollection.collectionViewLayout = layout
    }

    // MARK: - Configure
    func configure(with trainer: TrainersSlotData) {
        self.trainerData = trainer
        lblTrainerName.text = trainer.trainer_name

        // Show badge image if badge string maps to an asset name
        if let badge = trainer.badge, !badge.isEmpty {
//            imgBadge.image = UIImage(named: badge)
//            imgBadge.isHidden = false
            lblBadge.text = badge
        } else {
//            imgBadge.isHidden = true
        }
        primaryCollection.reloadData()

        // After reload, let the layout settle then update the collection's height constraint
        // and notify the table view
        DispatchQueue.main.async {
            self.primaryCollection.layoutIfNeeded()
            let collectionHeight = self.primaryCollection.collectionViewLayout.collectionViewContentSize.height
            
            // Set the constant directly on the height constraint outlet
            self.heightOfCollectionView.constant = collectionHeight
            self.layoutIfNeeded()
            
            self.onHeightResolved?(collectionHeight)
        }
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trainerData?.grouped_slots?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PrimaryDateTimeCVCell",
            for: indexPath
        ) as? PrimaryDateTimeCVCell else { return UICollectionViewCell() }
        let slot = trainerData?.grouped_slots?[indexPath.row]
        cell.lblDateTime.text = slot?.date_display
        cell.lblTime.text = slot?.time_display
        return cell
    }
}
