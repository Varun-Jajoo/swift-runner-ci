//
//  DashboardGuestViewController.swift
//  MyPT
//
//  Created by techsaga corp on 08/11/24.
//

import UIKit

class DashboardGuestViewController: CommonViewController {
    
    //MARK: ------------------VARIABLE
    var productCategory:[String]?
    
    //MARK: -------------------IBOUTLET
    @IBOutlet weak var topNameMBV: UIView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var bookTrainerBckImgV: UIImageView!
    @IBOutlet weak var workoutMBckImgView: UIImageView!
    @IBOutlet weak var planWorkoutImgV: UIImageView!
    @IBOutlet weak var purchaseGymPassImgV: UIImageView!
    @IBOutlet weak var grabNowMBckImgV: UIImageView!
    @IBOutlet weak var grabNowMBV: UIView!
    @IBOutlet weak var bookTrainerTitleLbl: UILabel!
    @IBOutlet weak var bookTrainerDescLbl: UILabel!
    @IBOutlet weak var bookTrainerExploreBtn: UIButton!
    @IBOutlet weak var differentWorkoutTitleLbl: UILabel!
    @IBOutlet weak var differentWorkoutExploreBtn: UIButton!
    @IBOutlet weak var planWorkoutTitleLbl: UILabel!
    @IBOutlet weak var planWorkoutExploreBtn: UIButton!
    @IBOutlet weak var purchaseGymPassMBV: UIView!
    @IBOutlet weak var purchaseGymPassTitleLbl: UILabel!
    @IBOutlet weak var purchaseGymPassDescLbl: UILabel!
    @IBOutlet weak var purchaseGymPassBtn: UIButton!
    @IBOutlet weak var transfromationStoriesTitleLbl: UILabel!
    @IBOutlet weak var nearByGymsTitleLbl: UILabel!
    @IBOutlet weak var upcomingClassesTitleLbl: UILabel!
    @IBOutlet weak var shopProductsTitleLbl: UILabel!
    @IBOutlet weak var getFreeSessionTitleLbl: UILabel!
    @IBOutlet weak var bodyAnalysisLbl: UILabel!
    @IBOutlet weak var personalizedWorkoutPlanLbl: UILabel!
    @IBOutlet weak var oneCoachingLbl: UILabel!
    @IBOutlet weak var grabNowPriceLbl: UILabel!
    @IBOutlet weak var grabNowBtn: UIButton!
    @IBOutlet weak var transformationStoriesCollView: UICollectionView!
    @IBOutlet weak var upcomingCollView: UICollectionView!
    @IBOutlet weak var productCategoryCollView: UICollectionView!
    @IBOutlet weak var productListCollView: UICollectionView!
    @IBOutlet weak var nearByYouCollView: UICollectionView!
    @IBOutlet weak var thougthLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var onTheWayLbl: UILabel!
    @IBOutlet weak var startTrackingBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.productCategory = ["All Equipment",
                                "Fitness Equipment",
                                "Apparel & Accessories"
                               ]
        setUpFont()
        setupUI()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.selectedCell()
        
    }
    
    func selectedCell(){
        DispatchQueue.main.async {
            
            // Automatically select the first cell
            let firstIndexPath = IndexPath(item: 0, section: 0)
            self.productCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.productCategoryCollView.delegate?.collectionView?(self.productCategoryCollView, didSelectItemAt: firstIndexPath)
            self.view.layoutIfNeeded()
        }
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.chooseLocation, AppImages.forward], setTitle: [" Choose location",nil], setTintColor: .appWhite, setTitleColor: .appWhite)
        self.setRighMenu(rightImgs: [AppImages.notificationCount,AppImages.notification], setTitle: ["0",nil], setTintColor: nil, setTitleColor: UIColor.appWhite)
    }
    
    override func rightBtnActn(sender: UIButton) {
        AlertHelper.shared.showCustomeAlert(title: "", message: AppAlertStrings.logoutAlertMsg, actions: ["Ok", "Cancel"], withCancel: true, completion: { [weak self] tagGet in
            guard self != nil else { return }
            
            if tagGet == 0 {
                if appUserDefaults.clearUserDefault() {
                    appSceneDelegate?.goToMainView()
                }
            }
        })
    }
    
    //------------------************Font
    func setUpFont(){
        
        self.bookTrainerTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.bookTrainerDescLbl.font = AppFont.medium.size(11.0, familyName: familyManrope)
        self.bookTrainerExploreBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        
        self.differentWorkoutTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.differentWorkoutExploreBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.planWorkoutTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.planWorkoutExploreBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.userNameLbl.font = AppFont.bold.size(18.0, familyName: familyManrope)
        self.purchaseGymPassTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.purchaseGymPassDescLbl.font = AppFont.medium.size(11.0, familyName: familyManrope)
        self.purchaseGymPassBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.getFreeSessionTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.bodyAnalysisLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.personalizedWorkoutPlanLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.oneCoachingLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.grabNowPriceLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.grabNowBtn.titleLabel?.font = AppFont.medium.size(18.0, familyName: familyClashDisplay) //24
        
        self.transfromationStoriesTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.upcomingClassesTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.shopProductsTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.nearByGymsTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.nearByGymsTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.thougthLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.authorLbl.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
        self.onTheWayLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.startTrackingBtn.titleLabel?.font = AppFont.bold.size(12.0, familyName: familyManrope)
    }
    
    
    //MARK: ---------- SET UI
    func setupUI(){
        
        //---------*************UICollectionview init
        
        transformationStoriesCollView.register(UINib(nibName: "TransformationStoriesCollViewCell", bundle: nil), forCellWithReuseIdentifier: "TransformationStoriesCollViewCell")
        upcomingCollView.register(UINib(nibName: "UpcomingClassCollViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingClassCollViewCell")
        productCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        productListCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
        nearByYouCollView.register(UINib(nibName: "GymsNearbyCollViewCell", bundle: nil), forCellWithReuseIdentifier: "GymsNearbyCollViewCell")
        
        //-----------*************
        DispatchQueue.main.async {
            
            //            self.topNameMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0)
            self.bookTrainerExploreBtn.roundSideCorners(radius: 16.0, cornerSide: [.topRight])
            self.bookTrainerExploreBtn.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.4)
            self.differentWorkoutExploreBtn.roundSideCorners(radius: 16.0, cornerSide: [.topRight])
            self.planWorkoutExploreBtn.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.4)
            self.differentWorkoutExploreBtn.roundSideCorners(radius: 16.0, cornerSide: [.topRight])
            self.planWorkoutExploreBtn.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.4)
            
            self.bookTrainerBckImgV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.workoutMBckImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.planWorkoutImgV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.purchaseGymPassImgV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.grabNowMBckImgV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.startTrackingBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
            self.grabNowBtn.setCornerRadius(borderWidth: 0.6, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            
            self.grabNowBtn.layerGradient(startPoint: .topLeft, endPoint: .bottomLeft, colorArray: [UIColor(red: 96/255.0, green: 55/255.0, blue: 9/255.0, alpha: 1).cgColor, UIColor(red: 243/255.0, green: 141/255.0, blue: 27/255.0, alpha: 1).cgColor, UIColor(red: 96/255.0, green: 55/255.0, blue: 9/255.0, alpha: 1).cgColor,], type: .axial)
            
        }
        
        
        //-------------------- Attributed Text for Price
        
        let defaultAttributes = [
            .font: AppFont.medium.size(32.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.medium.size(16.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "299",
            NSAttributedString(string: "AED",
                               attributes: makeAttributes), "329AED".strikeThrough(with: AppFont.medium.size(16.0, familyName: familyClashDisplay), color: UIColor.txtDarkGray)
        ] as [AttributedStringComponent]
        
        self.grabNowPriceLbl.attributedText       =  NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
        
        //UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        
        
        //-------------------------*************
        
        self.bookTrainerBckImgV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookTrainer(sender: ))))
    }
    
    @objc func bookTrainer(sender:Any){
        let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //MARK: --------------COMMON BTN ACTN
    @IBAction func commonBtnActn(_ sender: Any) {
        let vc:LibraryViewController = LibraryViewController.instantiate(appStoryboard: .library)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}


//MARK: --------------------Extension for UICollectionview Delegate/Datasource
extension DashboardGuestViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == productCategoryCollView{
            return productCategory?.count ?? 0
        }
        else{
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == transformationStoriesCollView {
            let cell:TransformationStoriesCollViewCell = transformationStoriesCollView.dequeueReusableCell(withReuseIdentifier: "TransformationStoriesCollViewCell", for: indexPath) as! TransformationStoriesCollViewCell
            
            
            return cell
        }
        else if collectionView == upcomingCollView{
            let cell:UpcomingClassCollViewCell = upcomingCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingClassCollViewCell", for: indexPath) as! UpcomingClassCollViewCell
            
            
            return cell
        }
        else if collectionView == productCategoryCollView{
            let cell:ProductCategoryCollViewCell = productCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
            cell.titleLbl.text = self.productCategory?[indexPath.row] as? String
            return cell
        }
        else if collectionView == productListCollView{
            let cell:ProductsListCollViewCell = productListCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
            
            return cell
        }
        else if collectionView == nearByYouCollView{
            let cell:GymsNearbyCollViewCell = nearByYouCollView.dequeueReusableCell(withReuseIdentifier: "GymsNearbyCollViewCell", for: indexPath) as! GymsNearbyCollViewCell
            
            return cell
        }
        else{
            return  UICollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == transformationStoriesCollView {
            return CGSize(width: collectionView.frame.width*0.88, height: collectionView.frame.height)
        }
        else if collectionView == upcomingCollView{
            return CGSize(width: collectionView.frame.width*0.78, height: collectionView.frame.height)
        }
        else if collectionView == productCategoryCollView{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        else if collectionView == productListCollView{
            return CGSize(width: collectionView.frame.width*0.45, height: collectionView.frame.height)
        }
        else if collectionView == nearByYouCollView{
            return CGSize(width: collectionView.frame.width*0.78, height: collectionView.frame.height)
        }
        return CGSize(width: collectionView.frame.width*0.88, height: collectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}

extension DashboardGuestViewController{
    /*
     http://mypt.test/api/book-trainer
     1=>for home 2=>for gym
     */
    
    //    func getTrainerApi(){
    //        DashboardVM.gerTrainerApi(viewController: self, inputType: "gym", completion: { [weak self] getDataResult in
    //            guard let self = self else { return  }
    //
    //            print(getDataResult as Any)
    //
    //        })
    //    }
}

