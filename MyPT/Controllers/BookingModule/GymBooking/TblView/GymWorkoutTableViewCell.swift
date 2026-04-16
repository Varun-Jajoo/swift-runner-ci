//
//  GymWorkoutTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 12/12/24.
//

import UIKit

class GymWorkoutTableViewCell: UITableViewCell {
    
    // MARK: -------------VARIABLE
    var trainerTagsData:[TrainerTagModel]? = [] {
        didSet{
            if let trainerTagsData = trainerTagsData {
                guard trainerTagsData.count > 0 else { return }
                restrictedRange = [0...trainerTagsData.count - 1]
                self.categoryCollView.reloadData()
            }
        }
    }
    
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var gymMainImgV: UIImageView!
    @IBOutlet weak var topStudioImgView: UIImageView!
    @IBOutlet weak var studioTypeLbl: UILabel!
    @IBOutlet weak var shadowImgView: UIImageView!
    @IBOutlet weak var gymNameLbl: UILabel!
    //    @IBOutlet weak var distanceBtn: UIButton!
    //    @IBOutlet weak var landMarkBtn: UIButton!
    //    @IBOutlet weak var timeBtn: UIButton!
    //    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var categoryCollView: UICollectionView!
    @IBOutlet weak var viewDetailsBtn: UIButton!
    @IBOutlet weak var selectViewBtn: UIButton!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblLandmark: UILabel!
    //    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblNumOfRatings: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setupFont()
        
        categoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        
        //        self.distanceBtn.titleLabel?.numberOfLines = 3
        //        self.landMarkBtn.titleLabel?.numberOfLines = 3
        //        self.timeBtn.titleLabel?.numberOfLines = 3
        
        DispatchQueue.main.async {
            self.shadowImgView.backgroundColor = UIColor.clear
            self.shadowImgView.addGradientImgV(colors: UIColor.appMultiColor(.gradientColor2), locations: [0,1], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 0, y: 1))
            
            self.viewDetailsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(hex: "#343534"), cornerRadious: 8.0)
            self.selectViewBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellData(studioData: TrainerModel?){
        guard let studioData = studioData else { return }
        
        DispatchQueue.main.async {
            //            self.gymMainImgV.loadImage(urlString: studioData.profile, placeholder: UIImage())
            self.gymMainImgV.loadImage(urlString: studioData.profile, placeholder: UIImage())
            self.gymNameLbl.text = studioData.name
            self.lblDistance.text = studioData.distance
            self.lblLandmark.text = studioData.location
            //            self.lblTime.text = studioData.timing
            self.lblRating.text = studioData.noOfRating ?? "0.0"
            self.lblNumOfRatings.text = studioData.noOfRating ?? "0" + " " + "ratings"
            self.shadowImgView.image = nil
            self.studioTypeLbl.text = studioData.studioTag?.uppercased()
            
            //            self.shadowImgView.image = UIImage(named: "ic_bckShadow")
        }
        //        self.gymMainImgV.loadImage(urlString: studioData.profile, placeholder: AppImages.navLeft)
        //        self.gymNameLbl.text = studioData.name
        //        self.distanceBtn.setTitle(studioData.distance, for: .normal)
        //        self.landMarkBtn.setTitle(studioData.location, for: .normal)
        //        self.timeBtn.setTitle(studioData.timing, for: .normal)
        //        self.ratingBtn.setTitle(studioData.noOfRating, for: .normal)
    }
    
    
    private func setupFont() {
        self.studioTypeLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        self.gymNameLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        [lblDistance, lblLandmark, lblRating, lblNumOfRatings].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        })
        viewDetailsBtn.titleLabel?.font = AppFont.medium.size(14, familyName: familyFunnelSans)
        selectViewBtn.titleLabel?.font = AppFont.medium.size(14, familyName: familyFunnelSans)
    }
}

//MARK: ---------------EXTENSION FOR DATASOURCE/DELEGATE
extension GymWorkoutTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let totalCount = trainerTagsData?.count, totalCount > 3 {
            return 4
        } else {
            return trainerTagsData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        //        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
        cell.shouldHandleSelection = false
        cell.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 43.0/255.0, green: 44.0/255.0, blue: 45.0/255.0, alpha: 1), cornerRadious: 8)
        cell.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        cell.titleLbl.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
        cell.titleLblTopConstrnt.constant = 7
        cell.cellMBV.backgroundColor = .clear
        if let lastCell = collectionView.isLastCell(), let totalCount = trainerTagsData?.count,( lastCell == indexPath.row && totalCount > 3) {
            cell.titleLbl.text = "+3"
        } else {
            cell.titleLbl.text = trainerTagsData?[indexPath.row].name?.uppercased() as? String
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Check if any range contains the index
        return !restrictedRange.contains { $0.contains(indexPath.item) }
    }
}
