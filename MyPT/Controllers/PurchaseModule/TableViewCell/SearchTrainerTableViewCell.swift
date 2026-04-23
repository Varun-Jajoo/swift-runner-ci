//
//  SearchTrainerTableViewCell.swift
//  MyPT
//
//  Created by Manik Goel on 31/01/26.
//

import UIKit

class SearchTrainerTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: ProtocolSecondryTrainer?
    private var categoryName = ["Crossfit", "Yoga"]
    
    @IBOutlet weak var constCellWidth: NSLayoutConstraint!
    @IBOutlet weak var viewBackgrnd: UIView!
    @IBOutlet weak var imgTrainer: UIImageView!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var imgRating: UIImageView!
    @IBOutlet weak var lblViewProfile: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var viewProfileBtn: UIButton!
    @IBOutlet weak var secondryCollectionView: UICollectionView!
    
    
//    {
//        
//        didSet{
//            self.lblTrainerName.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
//            self.lblRating.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
//            self.lblViewProfile.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
//            self.lblDistance.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
//            self.viewProfileBtn.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
//            if let layout = secondryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//                layout.scrollDirection = .horizontal
//                layout.minimumInteritemSpacing = 5
//                layout.minimumLineSpacing = 5
//                layout.estimatedItemSize = .zero   // important
//            }
//        }
//    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        secondryCollectionView.delegate = self
//        secondryCollectionView.dataSource = self
//        secondryCollectionView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
//       guard let viewBackgrnd = viewBackgrnd else { return }
//
//        DispatchQueue.main.async {
//            viewBackgrnd.cornersWithBorder(
//                radius: 16,
//                corners: .allCorners,
//                borderColor: .clear,
//                borderWidth: 0
//            )
//        }
//      
//    }
    


    override func awakeFromNib() {
        super.awakeFromNib()

        // collection view setup
        secondryCollectionView.delegate = self
        secondryCollectionView.dataSource = self
        secondryCollectionView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")

        if let layout = secondryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
            layout.estimatedItemSize = .zero
        }

        // fonts & UI (SAFE here)
        lblTrainerName.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
        lblRating.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        lblViewProfile.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
        lblDistance.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        viewProfileBtn.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryName = []
        secondryCollectionView.reloadData()
    }
    
    func setHomeTraineData(data: TrainerModel) {
        imgTrainer.loadImage(urlString: data.profile, placeholder: UIImage())
        lblTrainerName.text = data.name
        lblRating.text = data.averageRating?.value
        categoryName = data.tags?.compactMap({$0.name}) ?? []
        lblDistance.text = (data.distance ?? "0kms") + " away"
        secondryCollectionView.reloadData()
    }
    
    func setGymTrainerData(data: GymTrainerModel) {
        imgTrainer.loadImage(urlString: data.profile, placeholder: UIImage())
        lblTrainerName.text = data.name
        lblRating.text = data.averageRating?.value
        categoryName = data.tags?.compactMap({$0.name}) ?? []
        lblDistance.text = (data.distance ?? "0kms") + " away"
        secondryCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < categoryName.count else {
            return UICollectionViewCell()
        }
        
        if let categoryCell: ProductCategoryCollViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as? ProductCategoryCollViewCell {
//            DispatchQueue.main.async {
                categoryCell.shouldHandleSelection = false
                categoryCell.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.1), cornerRadious: 12)
                categoryCell.titleLblTopConstrnt.constant = 4
                categoryCell.titleLblLeading.constant = 8
                categoryCell.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
                categoryCell.titleLbl.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
                categoryCell.titleLbl.text = categoryName[indexPath.item].uppercased()
//            }
            return categoryCell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.item < categoryName.count else {
            return CGSize(width: 1, height: collectionView.frame.height)
        }
        
        let value = categoryName[indexPath.item]

           // Use the same font as NumberCell label
        let font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
           
           // Measure text width
           let textWidth = (value as NSString).size(withAttributes: [.font: font]).width
           
           return CGSize(width: textWidth + 50, height: collectionView.frame.height)
        
        
//        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
//        let text = categoryName[indexPath.row]
//        let font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
//
//        let textWidth = text.size(withAttributes: [.font: font]).width
//
//        let horizontalPadding: CGFloat = 20   // 8 + 8
//        let height: CGFloat = 30              // safe chip height
//
//        return CGSize(
//            width: ceil(textWidth + horizontalPadding),
//            height: height
//        )
    }
}
