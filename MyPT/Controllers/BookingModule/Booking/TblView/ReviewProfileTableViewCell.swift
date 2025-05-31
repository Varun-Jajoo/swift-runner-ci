//
//  ReviewProfileTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 03/04/25.
//

import UIKit

class ReviewProfileTableViewCell: UITableViewCell {

    //MARK: ------------VARIABLE
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
    var trainerTagsData:[String]? = [] {
        didSet{
            if let trainerTagsData = trainerTagsData {
                if trainerTagsData.count > 0 {
                    restrictedRange = [0...trainerTagsData.count - 1]
                }
                self.workoutCategoryCollView.reloadData()
            }
        }
    }
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var workoutCategoryCollView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.workoutCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI(){
        self.trainerNameLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        DispatchQueue.main.async {
            self.profileImgView.setCornerRadius(borderWidth: 0.3, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.profileImgView.contentMode = .scaleToFill
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    

    //MARK: ---------------SET CELL DATA
    func setCellData(inputData: PackageCheckoutTrainerModel?){
        guard let inputData = inputData else { return  }
        self.profileImgView.loadImage(urlString: inputData.profile, placeholder: UIImage())
        self.trainerNameLbl.text = inputData.name
        
         //------------------rating atttibuted btn text
        let numRating = inputData.noOfRating ?? ""
        let avgRating = "• " + (inputData.averageRating ?? "")
         
         let ratingDefaultAttr = [
             .font: AppFont.semibold.size(12.0, familyName: familyManrope),
             .foregroundColor: UIColor.appWhite
         ] as [NSAttributedString.Key : Any]
         
         let avgRatingAttr = [
             .font: AppFont.semibold.size(12.0, familyName: familyManrope),
             .foregroundColor: UIColor.appDarkGray
         ] as [NSAttributedString.Key : Any]
         
         let makeAttr = [
             numRating ,
             NSAttributedString(string: avgRating ,
                                attributes: avgRatingAttr)
         ] as [AttributedStringComponent]
         
         
         self.ratingBtn.setAttributedTitle(NSAttributedString(from: makeAttr, defaultAttributes: ratingDefaultAttr), for: .normal)
         
    }
    
}


//MARK: -------------UICOLLECTIONVIEW DATASOURCE/ DELAGATE
extension ReviewProfileTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let totalCount = trainerTagsData?.count, totalCount > 2 {
            return 3
        }else{
            return trainerTagsData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:ProductCategoryCollViewCell = workoutCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        
        DispatchQueue.main.async {
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 9.0)
            cell.layoutIfNeeded()
        }
        
        cell.titleLblLeading.constant = 8.0
        cell.titleLblTopConstrnt.constant = 5.0
        cell.layoutIfNeeded()
        
        if let lastCell = collectionView.isLastCell(), let totalCount = trainerTagsData?.count,( lastCell == indexPath.row && totalCount > 2) {
            cell.titleLbl.text = "+3"
           
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 2.0)
            cell.layoutIfNeeded()
        }
        else{
            cell.titleLbl.text = trainerTagsData?[indexPath.row] as? String
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
