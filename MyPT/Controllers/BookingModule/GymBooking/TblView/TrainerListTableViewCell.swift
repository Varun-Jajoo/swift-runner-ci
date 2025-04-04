//
//  TrainerListTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import UIKit

class TrainerListTableViewCell: UITableViewCell {

    //MARK: -------------VARIABLE
    var trainerTagsData:[TrainerTagModel]? = [] {
        didSet{
            if let trainerTagsData = trainerTagsData {
                restrictedRange = [0...trainerTagsData.count - 1]
                self.gymCategoryCollView.reloadData()
            }
        }
    }
    
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var detailsMBV: UIView!
    @IBOutlet weak var slotMBV: UIView!
    @IBOutlet weak var gymNameLbl: UILabel!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var landMarkBtn: UIButton!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var avgRatingBtn: UIButton!
    @IBOutlet weak var bookSlotBtn: UIButton!
    @IBOutlet weak var gymCategoryCollView: UICollectionView!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var numberSlotLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        gymCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
    
        self.setupUI()
        self.setupFont()
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.bookSlotBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
    }
    
    //MARK: -------------SET CELL INPUTDATA
    func setCellData(trainerData: TrainerModel?){
        guard let trainerData = trainerData else { return  }
            self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: AppImages.navLeft)
            self.gymNameLbl.text = trainerData.name
            self.distanceBtn.setTitle(trainerData.distance, for: .normal)
            self.ratingBtn.setTitle("\(trainerData.averageRating?.doubleValue ?? 0.0)", for: .normal)
            self.avgRatingBtn.setTitle(trainerData.noOfRating ?? "", for: .normal)
            self.landMarkBtn.setTitle(trainerData.location, for: .normal)
            self.numberSlotLbl.text = "Only \(trainerData.slot ?? "") slots available"
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.setupUI()
        
    }
    
    //MARK: -------------SET CELL INPUTDATA
    func setGymCellData(trainerData: GymTrainerModel?){
        guard let trainerData = trainerData else { return  }
        
            self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: AppImages.navLeft)
            self.gymNameLbl.text = trainerData.name
            self.distanceBtn.setTitle(trainerData.distance, for: .normal)
            self.ratingBtn.setTitle("\(trainerData.averageRating ?? 0)", for: .normal)
            self.avgRatingBtn.setTitle(trainerData.noOfRating ?? "", for: .normal)
            self.landMarkBtn.setTitle(trainerData.location, for: .normal)
            self.numberSlotLbl.text = "Only \(trainerData.slot ?? "") slots available"
            
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
            self.setupUI()
    }
    
    
    private func setupFont(){
        
        self.bookSlotBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.noteLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.numberSlotLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        self.gymNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
         
        [
            self.avgRatingBtn.titleLabel,
            self.distanceBtn.titleLabel,
            self.landMarkBtn.titleLabel,
            self.ratingBtn.titleLabel
        ].forEach({
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
    }
  
    
//    func setupSelection(){
//        
//            // Automatically select the first cell
//            let firstIndexPath = IndexPath(item: 0, section: 0)
//            DispatchQueue.main.async {
//                self.gymCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
//                // Optional: perform any additional setup for the selected cell
//                self.gymCategoryCollView.delegate?.collectionView?(self.gymCategoryCollView, didSelectItemAt: firstIndexPath)
//  
//                self.layoutIfNeeded()
//            }
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
//MARK: ------------UICOLLECIONVIEW DATASOURCE/DELEGATE
extension TrainerListTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let totalCount = trainerTagsData?.count, totalCount > 3 {
            return 4
        }else{
            return trainerTagsData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = gymCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
        
        if let lastCell = collectionView.isLastCell(), let totalCount = trainerTagsData?.count,( lastCell == indexPath.row && totalCount > 3) {
            cell.titleLbl.text = "+3"
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
