//
//  OtherTrainerCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 28/03/26.
//

import UIKit

class OtherTrainerCVCell: UICollectionViewCell {
    
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    var trainerTagsData: [String]? = [] {
        didSet{
            if let trainerTagsData = trainerTagsData {
                if trainerTagsData.count > 0 {
                    restrictedRange = [0...trainerTagsData.count - 1]
                }
                self.gymCategoryCollView.reloadData()
            }
        }
    }
    
    //MARK: ------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var gymNameLbl: UILabel!
    //    @IBOutlet weak var trainerBadgeImgView: UIImageView!
    @IBOutlet weak var gymCategoryCollView: UICollectionView!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var btnRadio: UIButton!
    @IBOutlet weak var imgRecommended: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
        gymCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        gymCategoryCollView.delegate = self
        gymCategoryCollView.dataSource = self
        
        DispatchQueue.main.async {
            self.cellMBV.addGradient(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 1), UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.trainerImgView.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            
            //            self.trainerImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setUI() {
        DispatchQueue.main.async {
            self.gymNameLbl.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
            self.ratingBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            self.distanceBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        }
    }
    
    func setupCellData(trainerData: OtherTrainer?) {
        guard let trainerData = trainerData else { return }
        self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: UIImage())
        self.ratingBtn.setTitle(trainerData.averageRating, for: .normal)
        self.gymNameLbl.text = trainerData.name
        self.distanceBtn.setTitle(trainerData.distance, for: .normal)
        imgRecommended.isHidden = true
    }
    
    /// Call this from cellForItemAt to reflect the current selection state
    func setSelected(_ selected: Bool) {
        btnRadio.setImage(UIImage(named: selected ? "Radio" : "Unradio"), for: .normal)
        imgRecommended.isHidden = !selected
        
//        if selected {
//            // Selected state — highlight border + background
//        } else {
//            // Unselected state — default border
//            viewUnavailableTime.cornersWithBorder(
//                radius: 8,
//                corners: .allCorners,
//                borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1),
//                borderWidth: 1
//            )
//            viewUnavailableTime.backgroundColor = .clear
//            lblTime.textColor = .white
//        }
    }
    
    @IBAction func onTapRadio(_ sender: UIButton) {
    }
    
}

//MARK: ----------------DELEGATE/DATASOURCE
extension OtherTrainerCVCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let totalCount = trainerTagsData?.count, totalCount > 2 {
            return 3
        } else {
            return trainerTagsData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell:ProductCategoryCollViewCell = gymCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as? ProductCategoryCollViewCell else { return UICollectionViewCell() }
        DispatchQueue.main.async {
            //            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            cell.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.1), cornerRadious: 8)
            cell.titleLbl.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
            //            cell.layoutIfNeeded()
            
        }
        
        cell.titleLblLeading.constant = 8.0
        cell.titleLblTopConstrnt.constant = 5.0
        cell.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        //        cell.layoutIfNeeded()
        
        if let lastCell = collectionView.isLastCell(), let totalCount = trainerTagsData?.count,( lastCell == indexPath.row && totalCount > 2) {
            cell.titleLbl.text = "+3"
            //            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 2.0)
            //            cell.layoutIfNeeded()
        } else {
            cell.titleLbl.text = trainerTagsData?[indexPath.row].uppercased() as? String
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Check if any range contains the index
        return !restrictedRange.contains { $0.contains(indexPath.item) }
    }
}
