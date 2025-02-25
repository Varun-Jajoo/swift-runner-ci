//
//  TrainerDescriptionViewController.swift
//  MyPT
//
//  Created by techsaga corp on 22/11/24.
//

import UIKit

class TrainerDescriptionViewController: CommonViewController {

    //MARK: -------------VARIABLE
    // Indexes of restricted items
    var restrictedRange: [ClosedRange<Int>] = [0...4]  // These cells can't be selected
    
//    private let toggleButton: UIButton = {
//         let button = UIButton(type: .system)
//         button.setTitle("More", for: .normal)
//         button.translatesAutoresizingMaskIntoConstraints = false
//         button.addTarget(self, action: #selector(toggleText), for: .touchUpInside)
//         return button
//     }()
    
    // State to track expanded or collapsed
    private var isExpanded = false

    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var badgeImgView: UIImageView!
    @IBOutlet weak var followrsMBV: UIView!
    @IBOutlet weak var followrsCountLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var landMark: UIButton!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var ratingCountBtn: UIButton!
    @IBOutlet weak var trainerMenuCollView: UICollectionView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var experienceMBV: UIView!
    @IBOutlet weak var avgRatingMBV: UIView!
    @IBOutlet weak var clientCoachedMBV: UIView!
    @IBOutlet weak var expCountLbl: UILabel!
    @IBOutlet weak var expDescLbl: UILabel!
    @IBOutlet weak var avgRatingCountLbl: UILabel!
    @IBOutlet weak var avgRatingDecLbl: UILabel!
    @IBOutlet weak var clientsCountLbl: UILabel!
    @IBOutlet weak var clientsCoachedLbl: UILabel!
    @IBOutlet weak var specialitiesLbl: UILabel!
    @IBOutlet weak var specialitiesCollView: UICollectionView!
    @IBOutlet weak var certificatesTitleLbl: UILabel!
    @IBOutlet weak var personalTraining1MBV: UIView!
    @IBOutlet weak var personalTraining2MBV: UIView!
    @IBOutlet weak var personalTraining3MBV: UIView!
    @IBOutlet weak var certicate1titleLbl: UILabel!
    @IBOutlet weak var personal1TrainingLbl: UILabel!
    @IBOutlet weak var certicate2titleLbl: UILabel!
    @IBOutlet weak var personal2Training3Lbl: UILabel!
    @IBOutlet weak var certicate3titleLbl: UILabel!
    @IBOutlet weak var personalTraining3Lbl: UILabel!
    @IBOutlet weak var whyTrainMeLbl: UILabel!
    @IBOutlet weak var trainMeCollView: UICollectionView!
    @IBOutlet weak var motivationQuoteTitleLbl: UILabel!
    @IBOutlet weak var quoteMBV: UIView!
    @IBOutlet weak var motivationQuoteDescLbl: UILabel!
    @IBOutlet weak var quoteWriterNameLbl: UILabel!
    @IBOutlet weak var mediaGalleryLbl: UILabel!
    @IBOutlet weak var mediaGalleryCollView: UICollectionView!
    @IBOutlet weak var bookSlotBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpFont()
        
        
        
        //------------------***************--------
//       let """
//Implementing "Read More" and "Read Less" functionality for a UILabel in Swift typically involves dynamically adjusting the number of lines displayed in the label and toggling a button's title (e.g., "More" or "Less"). Below is an example of how you can achieve this:
//"""
        
//        descLbl.addSubview(toggleButton)
//        
//        // Layout
//        NSLayoutConstraint.activate([
//            descLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            descLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            descLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            toggleButton.topAnchor.constraint(equalTo: descLbl.bottomAnchor, constant: 8),
//            toggleButton.leadingAnchor.constraint(equalTo: descLbl.leadingAnchor)
//        ])
        
        
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            self.trainerMenuCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.trainerMenuCollView.delegate?.collectionView?(self.trainerMenuCollView, didSelectItemAt: firstIndexPath)
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.follow], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
        
        //"FOLLOW"
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        
        trainerMenuCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        specialitiesCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        trainMeCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        mediaGalleryCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        
        //---------------------**************UI
        DispatchQueue.main.async {
            self.bookSlotBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.followrsMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.experienceMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.avgRatingMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.clientCoachedMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.clientCoachedMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.personalTraining1MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.personalTraining2MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.personalTraining3MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.quoteMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            
            //----------------Gradient view
            
            self.followrsMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .radial)
            
            self.experienceMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .radial)
            self.avgRatingMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .radial)
            self.clientCoachedMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .radial)
            self.clientCoachedMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .radial)
            self.personalTraining1MBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .radial)
            self.personalTraining2MBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .radial)
            self.personalTraining3MBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .radial)
            self.quoteMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .radial)
        }
    }
    
    //------------------************Font
    func setUpFont(){
//        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
//        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

    
//    // Action for the toggle button
//     @objc private func toggleText() {
//         isExpanded.toggle() // Toggle the state
//         descLbl.numberOfLines = isExpanded ? 0 : 3 // 0 means no limit
//         toggleButton.setTitle(isExpanded ? "Less" : "More", for: .normal)
//     }
    
    //MARK: -------------- BOOK SLOT BTN ACTN
    @IBAction func bookSlotBtnActn(_ sender: Any) {
        let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
        vc.slotBookFlow = .bookTrainer
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


//MARK: -------------------UICOLLECTION VIEW DATASOURCE/DELEAGET
extension TrainerDescriptionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == trainMeCollView{
            return 1
        }
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == trainerMenuCollView {
            let cell:WorkoutCategoryCollectionViewCell = trainerMenuCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            
            
            return cell
        }
        else if collectionView == specialitiesCollView{
            let cell:ProductCategoryCollViewCell = specialitiesCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
            cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            
            return cell
        }
        else if collectionView == trainMeCollView{
            let cell:WithMeCollectionViewCell = trainMeCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
           
            
            return cell
        }
        else if collectionView == mediaGalleryCollView{
            let cell:WithMeCollectionViewCell = mediaGalleryCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            
            return cell
        }
        else{
            return UICollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == trainMeCollView{
            return CGSize(width: collectionView.frame.width*0.90, height: collectionView.frame.height)
            
        }
        else if collectionView == mediaGalleryCollView{
            return CGSize(width: collectionView.frame.width*0.41, height: collectionView.frame.height)
            
        }
        else{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // Check if any range contains the index
        if collectionView == specialitiesCollView{
            return !restrictedRange.contains { $0.contains(indexPath.item) }
        }else{
            return true
        }
    }
    
}
