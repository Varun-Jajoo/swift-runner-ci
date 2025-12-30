//
//  MyTrainerTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 15/07/25.
//

import UIKit

class MyTrainerTableViewCell: UITableViewCell {

    //MARK: -------------VARIABLE
    var trainerTagsData:[TrainerTagModel]? = [] {
        didSet{
            if let trainerTagsData = trainerTagsData {
                guard trainerTagsData.count > 0 else { return }
                restrictedRange = [0...trainerTagsData.count - 1]
                self.trainerCategoryCollView.reloadData()
            }
        }
    }
    
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
    
    //MARK: ---------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var verifyImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var landMarkBtn: UIButton!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var avgRatingBtn: UIButton!
    @IBOutlet weak var trainerCategoryCollView: UICollectionView!
    @IBOutlet weak var trainerNameBottomConstrnt: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        trainerCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        
        self.setupUI()
        self.setupFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: -------------SET CELL INPUTDATA FOR MY TRAINERS
    func setMyTrainersCellData(trainerData: TrainerModel?){
        guard let trainerData = trainerData else { return  }
                
        self.trainerImgView.loadImage(urlString: trainerData.profile, placeholder: UIImage())
            self.trainerNameLbl.text = trainerData.name
        
        self.landMarkBtn.setTitle(trainerData.location, for: .normal)
        
            self.distanceBtn.setTitle(trainerData.distance, for: .normal)
            self.ratingBtn.setTitle("\(trainerData.averageRating?.doubleValue ?? 0.0)", for: .normal)
            self.avgRatingBtn.setTitle(trainerData.noOfRating ?? "" + "ratings", for: .normal)
        
        self.verifyImgView.isHidden = true
        if let isVerify = trainerData.isVerified, isVerify {
            self.verifyImgView.isHidden = false
        }
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.setupUI()
        
    }
    
    private func setupUI(){
        self.landMarkBtn.titleLabel?.numberOfLines = 3
        self.landMarkBtn.titleLabel?.lineBreakMode = .byWordWrapping
        self.landMarkBtn.sizeToFit()
//        self.topConstrntLoctionConstrnt.constant = 12.0
        
        
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
                self.trainerNameBottomConstrnt.constant = 19.0
            }
        }
        
        
        DispatchQueue.main.async {
            self.trainerImgView.addGradientImgV(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.7)], locations: [0, 1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cellMBV.addGradient(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
            self.trainerImgView.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
    }
    
    private func setupFont(){
        self.trainerNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
           
        [
            self.avgRatingBtn.titleLabel,
            self.distanceBtn.titleLabel,
            self.landMarkBtn.titleLabel,
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
}

//MARK: ------------UICOLLECIONVIEW DATASOURCE/DELEGATE
extension MyTrainerTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let totalCount = trainerTagsData?.count, totalCount > 3 {
            return 4
        }else{
            return trainerTagsData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = trainerCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
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
