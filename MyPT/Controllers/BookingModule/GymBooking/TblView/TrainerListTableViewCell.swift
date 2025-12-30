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
                guard trainerTagsData.count > 0 else { return }
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
    @IBOutlet weak var trainerVerifyImgView: UIImageView!
    @IBOutlet weak var topConstrntLoctionConstrnt: NSLayoutConstraint!
//    @IBOutlet weak var landMarkLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gymCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
    
        self.setupUI()
        self.setupFont()
    }
    
    private func setupUI(){
        self.landMarkBtn.titleLabel?.numberOfLines = 3
        self.landMarkBtn.titleLabel?.lineBreakMode = .byWordWrapping
        self.landMarkBtn.sizeToFit()
        self.topConstrntLoctionConstrnt.constant = 12.0
        
        
        if let label = self.landMarkBtn.titleLabel,
           let text = label.text {
            
            let maxSize = CGSize(width: label.frame.width, height: .greatestFiniteMagnitude)
            let attributes: [NSAttributedString.Key: Any] = [.font: label.font ??  AppFont.semibold.size(12.0, familyName: familyManrope)]

            let rect = (text as NSString).boundingRect(
                with: maxSize,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            )

            let numberOfLines = Int(ceil(rect.height / label.font.lineHeight))
            print("Number of lines in titleLabel: \(numberOfLines)")
            
            if numberOfLines >= 2 {
                self.topConstrntLoctionConstrnt.constant = 19.0
            }
        }
        
        
        DispatchQueue.main.async {
            
            self.trainerImgView.addGradientImgV(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.7)], locations: [0, 1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cellMBV.addGradient(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
            self.bookSlotBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.trainerImgView.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
    }
    
    /*
    //MARK: -------------SET CELL INPUTDATA FOR MY TRAINERS
    func setMyTrainersCellData(trainerData: TrainerModel?){
        guard let trainerData = trainerData else { return  }
        
//        self.bookSlotBtn.backgroundColor = UIColor.appWhite
//        self.bookSlotBtn.setTitleColor(UIColor.mainBg, for: .normal)
        self.noteLbl.text = nil
        self.numberSlotLbl.text = nil
        self.bookSlotBtn.isHidden = true
        self.bookSlotBtn.setTitle(nil, for: .normal)
        
        self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: UIImage())
            self.gymNameLbl.text = trainerData.name
        
        self.landMarkBtn.setTitle(trainerData.location, for: .normal)
        
            self.distanceBtn.setTitle(trainerData.distance, for: .normal)
            self.ratingBtn.setTitle("\(trainerData.averageRating?.doubleValue ?? 0.0)", for: .normal)
            self.avgRatingBtn.setTitle(trainerData.noOfRating ?? "" + "ratings", for: .normal)
        
        /*
        if let isFull = trainerData.isfull, let slotAvail = trainerData.slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
            self.noteLbl.text = "No slots available"
            self.numberSlotLbl.text = nil
            self.bookSlotBtn.backgroundColor = UIColor.appDarkGray
            self.bookSlotBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
        else{
            self.noteLbl.text = "Hurry Up!"
            self.numberSlotLbl.text = "Only \(trainerData.slot?.value ?? "") slots available"
            self.bookSlotBtn.isUserInteractionEnabled = true
        }
        */
        
//        self.noteLbl.text = nil
//        self.numberSlotLbl.text = nil
//        self.bookSlotBtn.isHidden = true
//        self.bookSlotBtn.setTitle(nil, for: .normal)
        
        self.trainerVerifyImgView.isHidden = true
        if let isVerify = trainerData.isVerified, isVerify {
            self.trainerVerifyImgView.isHidden = false
        }
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.setupUI()
        
    }
    */
    
    //MARK: -------------SET CELL INPUTDATA
    func setCellData(trainerData: TrainerModel?){
        guard let trainerData = trainerData else { return  }
        
        self.bookSlotBtn.backgroundColor = UIColor.appWhite
        self.bookSlotBtn.setTitleColor(UIColor.mainBg, for: .normal)
        
        self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: UIImage())
            self.gymNameLbl.text = trainerData.name
        
//        self.landMarkLbl.text = trainerData.location
        self.landMarkBtn.setTitle(trainerData.location, for: .normal)
        
            self.distanceBtn.setTitle(trainerData.distance, for: .normal)
            self.ratingBtn.setTitle("\(trainerData.averageRating?.doubleValue ?? 0.0)", for: .normal)
            self.avgRatingBtn.setTitle(trainerData.noOfRating ?? "" + "ratings", for: .normal)
//            self.landMarkBtn.setTitle(trainerData.location, for: .normal)
      
//        if let isFull = trainerData.isfull, isFull {
        
        if let isFull = trainerData.isfull, let slotAvail = trainerData.slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
            self.noteLbl.text = "No slots available"
            self.numberSlotLbl.text = nil
            self.bookSlotBtn.backgroundColor = UIColor.appDarkGray
            self.bookSlotBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
        else{
            self.noteLbl.text = "Hurry Up!"
            self.numberSlotLbl.text = "Only \(trainerData.slot?.value ?? "") slots available"
            self.bookSlotBtn.isUserInteractionEnabled = true
        }
        
        self.trainerVerifyImgView.isHidden = true
        if let isVerify = trainerData.isVerified, isVerify {
            self.trainerVerifyImgView.isHidden = false
        }
        
        /*
         if isSelected {
             self.continueBtn.isUserInteractionEnabled = true
             self.continueBtn.backgroundColor = UIColor.appWhite
             self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
         } else {
             self.continueBtn.isUserInteractionEnabled = false
             self.continueBtn.backgroundColor = UIColor.appDarkGray
             self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
         }
         */
        
//        self.numberSlotLbl.text = "Only \(trainerData.slot?.value ?? "") slots available"
//            self.numberSlotLbl.text = "Only \(trainerData.slot ?? "") slots available"
        
        
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.setupUI()
        
    }
    
    //MARK: -------------SET CELL INPUTDATA
    func setGymCellData(trainerData: GymTrainerModel?){
        guard let trainerData = trainerData else { return  }
        
        self.bookSlotBtn.backgroundColor = UIColor.appWhite
        self.bookSlotBtn.setTitleColor(UIColor.mainBg, for: .normal)
        
        self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: UIImage())
            self.gymNameLbl.text = trainerData.name
//        self.landMarkLbl.text = trainerData.location
        
        self.landMarkBtn.setTitle(trainerData.location, for: .normal)
        
        
        
            self.distanceBtn.setTitle(trainerData.distance, for: .normal)
            self.ratingBtn.setTitle("\(trainerData.averageRating ?? 0)", for: .normal)
            self.avgRatingBtn.setTitle(trainerData.noOfRating ?? "", for: .normal)
//            self.landMarkBtn.setTitle(trainerData.location, for: .normal)
//            self.numberSlotLbl.text = "Only \(trainerData.slot ?? "") slots available"
        
        self.trainerVerifyImgView.isHidden = true
        if let isVerify = trainerData.isVerified, isVerify {
            self.trainerVerifyImgView.isHidden = false
        }
        
        if let isFull = trainerData.isfull, let slotAvail = trainerData.slot, isFull && slotAvail.lowercased() == "no".lowercased() {
            self.noteLbl.text = "No slots available"
            self.numberSlotLbl.text = nil
            self.bookSlotBtn.backgroundColor = UIColor.appDarkGray
            self.bookSlotBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
        else{
            self.noteLbl.text = "Hurry Up!"
            self.numberSlotLbl.text = "Only \(trainerData.slot ?? "") slots available"
            self.bookSlotBtn.isUserInteractionEnabled = true
        }
        
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
//            self.landMarkLbl,
            self.ratingBtn.titleLabel
        ].forEach({
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        self.landMarkBtn.titleLabel?.numberOfLines = 3
        self.landMarkBtn.titleLabel?.lineBreakMode = .byWordWrapping
        self.landMarkBtn.titleLabel?.textAlignment = .center
        self.landMarkBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        self.landMarkBtn.sizeToFit()
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
        DispatchQueue.main.async {
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
        }
       
        cell.titleLblTopConstrnt.constant = 7.5
        
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
