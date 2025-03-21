//
//  GridTrainerCollectionViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 21/11/24.
//

import UIKit

class GridTrainerCollectionViewCell: UICollectionViewCell {

    //MARK: -------------VARIABLE
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
    //MARK: -------------VARIABLE
    var trainerTagsData:[TrainerTagModel]? = [] {
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
    @IBOutlet weak var nameMBV: UIView!
    @IBOutlet weak var gymNameLbl: UILabel!
    @IBOutlet weak var trainerBadgeImgView: UIImageView!
    @IBOutlet weak var gymCategoryCollView: UICollectionView!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var landMarkBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gymCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        
        DispatchQueue.main.async {
            self.cellMBV.addGradient(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 1), UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.trainerImgView.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            
//            self.trainerImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupCellData(trainerData: TrainerModel?){
        guard let trainerData = trainerData else { return }
        
        self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: AppImages.navLeft)
        self.ratingBtn.setTitle(trainerData.noOfRating, for: .normal)
        self.gymNameLbl.text = trainerData.name
        self.distanceBtn.setTitle(trainerData.distance, for: .normal)
        self.landMarkBtn.setTitle(trainerData.location, for: .normal)
    }
    
    //MARK: -------------SET CELL INPUTDATA
    func setGymCellData(trainerData: GymTrainerModel?){
        guard let trainerData = trainerData else { return  }
        
        DispatchQueue.main.async {
            
            self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: AppImages.navLeft)
            self.ratingBtn.setTitle(trainerData.noOfRating, for: .normal)
            self.gymNameLbl.text = trainerData.name
            self.distanceBtn.setTitle(trainerData.distance, for: .normal)
            self.landMarkBtn.setTitle(trainerData.location, for: .normal)
            
//            self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: AppImages.navLeft)
//            self.gymNameLbl.text = trainerData.name
//            self.distanceBtn.setTitle(trainerData.distance, for: .normal)
//            self.ratingBtn.setTitle("\(trainerData.averageRating ?? 0)", for: .normal)
//            self.avgRatingBtn.setTitle(trainerData.noOfRating ?? "", for: .normal)
//            self.landMarkBtn.setTitle(trainerData.location, for: .normal)
//            self.numberSlotLbl.text = "Only \(trainerData.slot ?? "") slots available"
        }
    }
    
}

//MARK: ----------------DELEGATE/DATASOURCE
extension GridTrainerCollectionViewCell:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let totalCount = trainerTagsData?.count, totalCount > 2 {
            return 3
        }else{
            return trainerTagsData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = gymCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        DispatchQueue.main.async {
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 9.0)
            cell.layoutIfNeeded()
        }
        
        cell.titleLblLeading.constant = 8.0
        cell.titleLblTopConstrnt.constant = 5.0
        cell.titleLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        cell.layoutIfNeeded()
    
        if let lastCell = collectionView.isLastCell(), let totalCount = trainerTagsData?.count,( lastCell == indexPath.row && totalCount > 2) {
            cell.titleLbl.text = "+3"
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 2.0)
            cell.layoutIfNeeded()
        }else{
            cell.titleLbl.text = trainerTagsData?[indexPath.row].name as? String
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
