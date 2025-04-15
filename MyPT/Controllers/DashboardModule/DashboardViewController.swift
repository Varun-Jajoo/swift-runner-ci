//
//  DashboardViewController.swift
//  MyPT
//
//  Created by techsaga corp on 12/11/24.
//

import UIKit

class DashboardViewController: CommonViewController {
    
    //MARK: ------------------VARIABLE
    var productCategory:[String]?
    var workoutDays:[String]?
    private let pageControl = CustomPageControl()
    
    //MARK: ------------IBOUTLET
    
    @IBOutlet weak var bookTrainerAtHomeBtn: UIButton!
    @IBOutlet weak var membershipBtn: UIButton!
    
    @IBOutlet weak var userImgView: UIButton!
    @IBOutlet weak var memberTypeLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var upcomingSessionsLbl: UILabel!
    @IBOutlet weak var upcomingSessionsCollView: UICollectionView!
    @IBOutlet weak var customPageControl: CustomPageControl!
    @IBOutlet weak var upcomingMealsLbl: UILabel!
    @IBOutlet weak var upcomingMealsCollView: UICollectionView!
    @IBOutlet weak var classesNearYouLbl: UILabel!
    @IBOutlet weak var classesNearYouCollView: UICollectionView!
    @IBOutlet weak var gymsNearbyLbl: UILabel!
    @IBOutlet weak var gymsNearbyCollView: UICollectionView!
    @IBOutlet weak var shopProductsLbl: UILabel!
    @IBOutlet weak var productCategoryCollView: UICollectionView!
    @IBOutlet weak var productListCollView: UICollectionView!
    @IBOutlet weak var dailyProgressLbl: UILabel!
    @IBOutlet weak var waterIntekMBV: UIView!
    @IBOutlet weak var waterIntekLbl: UILabel!
    @IBOutlet weak var quantityMBV: UIView!
    @IBOutlet weak var roundupQuantityLbl: UILabel!
    @IBOutlet weak var plusQuantityBtn: UIButton!
    @IBOutlet weak var calorieIntakeMBV: UIView!
    @IBOutlet weak var calorieTitleLbl: UILabel!
    @IBOutlet weak var quantitykcalLbl: UILabel!
    @IBOutlet weak var kcalProgressView: UIView!
    @IBOutlet weak var calorieBurnMBV: UIView!
    @IBOutlet weak var calorieBurnLbl: UILabel!
    @IBOutlet weak var quantityburnKcalLbl: UILabel!
    @IBOutlet weak var dayStreakMBV: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var calendarMBV: UIView!
    
    @IBOutlet weak var sundayLbl: UILabel!
    @IBOutlet weak var sunSubMBV: UIView!
    @IBOutlet weak var day1CountLbl: UILabel!
    @IBOutlet weak var day1ImgView: UIImageView!
    @IBOutlet weak var day2Lbl:UILabel!
    @IBOutlet weak var day2MBV:UIView!
    @IBOutlet weak var day2CountLbl:UILabel!
    @IBOutlet weak var day2CountImgView:UIImageView!

    @IBOutlet weak var day3Lbl:UILabel!
    @IBOutlet weak var day3MBV:UIView!
    @IBOutlet weak var day3CountLbl:UILabel!
    @IBOutlet weak var day3CountImgView:UIImageView!
    @IBOutlet weak var day4Lbl:UILabel!
    @IBOutlet weak var day4MBV:UIView!
    @IBOutlet weak var day4CountLbl:UILabel!
    @IBOutlet weak var day4CountImgView:UIImageView!
    @IBOutlet weak var day5Lbl:UILabel!
    @IBOutlet weak var day5MBV:UIView!
    @IBOutlet weak var day5CountLbl:UILabel!
    @IBOutlet weak var day5CountImgView:UIImageView!
    @IBOutlet weak var day6Lbl:UILabel!
    @IBOutlet weak var day6MBV:UIView!
    @IBOutlet weak var day6CountLbl:UILabel!
    @IBOutlet weak var day6CountImgView:UIImageView!
    @IBOutlet weak var day7Lbl:UILabel!
    @IBOutlet weak var day7MBV:UIView!
    @IBOutlet weak var day7CountLbl:UILabel!
    @IBOutlet weak var day7CountImgView:UIImageView!

    @IBOutlet weak var streakBadage1ImgView: UIImageView!
    @IBOutlet weak var streakBadage2ImgView: UIImageView!
    @IBOutlet weak var streakBadage3ImgView: UIImageView!
    @IBOutlet weak var dayStrekLbl: UILabel!
    @IBOutlet weak var calendarLine: UILabel!
    @IBOutlet weak var dayStreakNoteLbl: UILabel!
    @IBOutlet weak var footerLine: UILabel!
    @IBOutlet weak var thougthLbl: UILabel!
    @IBOutlet weak var thoughtWriterLbl: UILabel!
    @IBOutlet weak var workoutsMBV: UIView!
    @IBOutlet weak var myWorkoutsLbl: UILabel!
    @IBOutlet weak var workoutsDayCollView: UICollectionView!
    @IBOutlet weak var workoutTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.productCategory = ["All Equipment",
                                "Fitness Equipment",
                                "Apparel & Accessories"
        ]
        
        self.workoutDays = ["day1","day2","day3","day4","day5","day6"]
        
        self.setupUI()
        self.regiterCollections()
        setUpCustomPageControl()
        self.updatePage(to: 0)
        

        // Use the blurredGrayImage as needed, e.g., display it in an UIImageView:
        if let imgView = UIImage(named: "ic_streak_Badage2") {
            self.streakBadage3ImgView.image = createGrayBlurImage(from: imgView, blurRadius: 2.0)
        }
        
        self.setupInputData()
        
//        let originalImage = UIImage(named: "ic_streak_Badage2")!
//        let colors = [UIColor(red: 45/255.0, green: 49/255.0, blue: 45/255.0, alpha: 1.0).cgColor,UIColor(red: 45/255.0, green: 49/255.0, blue: 45/255.0, alpha: 1.0).cgColor,UIColor(red: 45/255.0, green: 49/255.0, blue: 45/255.0, alpha: 1.0).cgColor]
//        let locations: [CGFloat] = [0.0, 0.2, 0.3, 0.5, 1.0]
//
//        let gradientImage = addGradientBackgroundToImage(image: originalImage, colors: colors, locations: locations)
//        
//        self.streakBadage2ImgView.image = gradientImage
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
        
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            self.productCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.productCategoryCollView.delegate?.collectionView?(self.productCategoryCollView, didSelectItemAt: firstIndexPath)
//            self.productCategoryCollView.reloadData()
            
            self.workoutsDayCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.workoutsDayCollView.delegate?.collectionView?(self.workoutsDayCollView, didSelectItemAt: firstIndexPath)
//            self.workoutsDayCollView.reloadData()
            
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.chooseLocation, AppImages.forward], setTitle: [" Near Dubai Mall",nil], setTintColor: .appWhite, setTitleColor: .appWhite)
        self.setRighMenu(rightImgs: [AppImages.notificationCount,AppImages.notification], setTitle: ["10",nil], setTintColor: nil, setTitleColor: UIColor.appWhite)
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
    
    //MARK: ---------------BTN TAG
    enum Btntag: Int {
        case bookTrainer = 2201, membership
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        print("btn tag", sender.tag)
        
        switch sender.tag {
        case Btntag.bookTrainer.rawValue:
            print("book trainer")
            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
            vc.flowCreatePackage = .createPackage
            self.navigationController?.pushViewController(vc, animated: false)
        default:
            print("None.....")
            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
            vc.flowCreatePackage = .gymMembership
            self.navigationController?.pushViewController(vc, animated: false)
            
            break
        }
    }
    
    private func setupInputData(){
        if let userData = appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self), let userName = userData.user?.name {
            print("userData", userData)
            print("userData name: ", userName)
            self.userNameLbl.text = userName
        }
    }
    
    private func regiterCollections(){
        //------------------------*************UICollectionview init
        upcomingSessionsCollView.register(UINib(nibName: "UpcomingSessionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingSessionsCollectionViewCell")
        upcomingMealsCollView.register(UINib(nibName: "UpcomingMealsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingMealsCollectionViewCell")
        
        classesNearYouCollView.register(UINib(nibName: "UpcomingClassCollViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingClassCollViewCell")
        gymsNearbyCollView.register(UINib(nibName: "GymsNearbyCollViewCell", bundle: nil), forCellWithReuseIdentifier: "GymsNearbyCollViewCell")
        productCategoryCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        productListCollView.register(UINib(nibName: "ProductsListCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductsListCollViewCell")
        workoutsDayCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        
        //----------------------*************UITableview init
        self.workoutTblView.register(UINib(nibName: "MyWorkoutsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyWorkoutsTableViewCell")
    }
    
    
    //MARK: ---------- SET UI
    private func setupUI(){
        
        if let imgView = UIImage(named: "ic_bookTranierBackImg") {
            self.bookTrainerAtHomeBtn.setBackgroundImage(imgView, for: .normal)
            self.bookTrainerAtHomeBtn.clipsToBounds = true
            self.bookTrainerAtHomeBtn.addGradientLayer(colors: [UIColor.mainBg.withAlphaComponent(0.9), UIColor.clear], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
        }
        
        self.membershipBtn.addGradientLayer(colors: [UIColor.mainBg.withAlphaComponent(0.9), UIColor.clear], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
        
        
        DispatchQueue.main.async {
            //Book a Trainer at Gym/Home
            //Buy MyPT Studio Membership
            
            self.bookTrainerAtHomeBtn.titleLabel?.numberOfLines = 0
            self.bookTrainerAtHomeBtn.titleLabel?.lineBreakMode = .byClipping
            self.membershipBtn.titleLabel?.numberOfLines = 0
            self.membershipBtn.titleLabel?.lineBreakMode = .byClipping
            
            self.bookTrainerAtHomeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.membershipBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
                        
            [
                self.waterIntekMBV,
                self.calorieIntakeMBV,
                self.calorieBurnMBV
            ].forEach({
                $0.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 18.0)
            })
            
            self.quantityMBV.addGradient(colors: [UIColor(red: 0/255.0, green: 184/255.0, blue: 251/255.0, alpha: 1.0), UIColor(red: 0/255.0, green: 79/255.0, blue: 255/255.0, alpha: 1)], locations: [0.3,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 18)
            self.plusQuantityBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 10.0)
                        
            self.kcalProgressView.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor.appRatingYellow, cornerRadius: 3.0)
          
            self.topView.setGradientBorder(cornerRadious:9.0,width: 0.8, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
            self.dayStreakMBV.setGradientBorder(cornerRadious:20.0,width: 0.8, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
           
            self.dayStreakMBV.roundSideCorners(radius: 20.0, cornerSide: [.bottomLeft,.bottomRight])

            self.topView.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0), cornerRadius: 9.0)
            
            self.dayStreakMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0), cornerRadius: 20)
            
            self.calendarMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0), cornerRadius: 20)
            
            self.calendarMBV.setGradientBorder(cornerRadious:20.0,width: 2.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            self.calendarMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
                        
            self.footerLine.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            
            [
                self.sunSubMBV,
                self.day2MBV,
                self.day3MBV,
                self.day4MBV,
                self.day5MBV,
                self.day6MBV,
                self.day7MBV
            ].forEach({
                $0.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            })
        }
        
    }
    
    //MARK: --------------SETUP page controll
    func setUpCustomPageControl(){
        self.customPageControl.numberOfPages = 5  // Set the total number of pages
        self.customPageControl.currentPage = 0    // Set the initial page
        self.customPageControl.activeDotSize = CGSize(width: 26, height: 8)
        self.customPageControl.currentDotColor = UIColor(red: 158/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1)
        self.customPageControl.defaultDotColor = UIColor.txtDarkGray
        
    }
    
    // Update the current page based on some user interaction (e.g., swiping between views)
    func updatePage(to index: Int) {
        self.customPageControl.currentPage = index
    }
    
}


//MARK: --------------------Extension for UICollectionview Delegate/Datasource
extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == productCategoryCollView{
            return productCategory?.count ?? 0
        }
        else if collectionView == workoutsDayCollView{
            return workoutDays?.count ?? 0
        }
        else{
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == upcomingSessionsCollView {
            let cell:UpcomingSessionsCollectionViewCell = upcomingSessionsCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingSessionsCollectionViewCell", for: indexPath) as! UpcomingSessionsCollectionViewCell
//             self.updatePage(to: indexPath.row)
            
            return cell
        }
        else if collectionView == upcomingMealsCollView{
            let cell:UpcomingMealsCollectionViewCell = upcomingMealsCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingMealsCollectionViewCell", for: indexPath) as! UpcomingMealsCollectionViewCell
            
            
            return cell
        }
        else if collectionView == classesNearYouCollView{
            let cell:UpcomingClassCollViewCell = classesNearYouCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingClassCollViewCell", for: indexPath) as! UpcomingClassCollViewCell
            
            
            return cell
        }
        else if collectionView == gymsNearbyCollView{
            let cell:GymsNearbyCollViewCell = gymsNearbyCollView.dequeueReusableCell(withReuseIdentifier: "GymsNearbyCollViewCell", for: indexPath) as! GymsNearbyCollViewCell
            
            
            return cell
        }
        else if collectionView == productCategoryCollView{
            let cell:ProductCategoryCollViewCell = productCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
            cell.titleLblTopConstrnt.constant = 6.0
            cell.titleLbl.text = self.productCategory?[indexPath.row] as? String
            return cell
        }
        else if collectionView == productListCollView{
            let cell:ProductsListCollViewCell = productListCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
           
            return cell
        }else if collectionView == workoutsDayCollView{
            let cell:ProductCategoryCollViewCell = workoutsDayCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
            cell.titleLblTopConstrnt.constant = 6.0
            cell.titleLbl.text = self.workoutDays?[indexPath.row] as? String
            return cell
        }
        
        
        else{
          return  UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == upcomingSessionsCollView {
            return CGSize(width: collectionView.frame.width*0.86, height: collectionView.frame.height)
        }
        else if collectionView == upcomingMealsCollView{
            return CGSize(width: collectionView.frame.width*0.75, height: collectionView.frame.height)
        }
        else if collectionView == classesNearYouCollView{
            return CGSize(width: collectionView.frame.width*0.78, height: collectionView.frame.height)
        }
        else if collectionView == gymsNearbyCollView{
            return CGSize(width: collectionView.frame.width*0.78, height: collectionView.frame.height)
        }
        else if collectionView == productCategoryCollView{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        else if collectionView == productListCollView{
            return CGSize(width: collectionView.frame.width*0.45, height: collectionView.frame.height)
        }
        else if collectionView == workoutsDayCollView{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        return CGSize(width: collectionView.frame.width*0.88, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
          // Get the visible cell closest to the center of the collection view
          let centerPoint = CGPoint(x: upcomingSessionsCollView.bounds.midX + upcomingSessionsCollView.contentOffset.x,
                                    y: upcomingSessionsCollView.bounds.midY + upcomingSessionsCollView.contentOffset.y)
          
          if let indexPath = upcomingSessionsCollView.indexPathForItem(at: centerPoint) {
              print("Currently visible index: \(indexPath.row)")
              
              self.updatePage(to: indexPath.row)
          }
      }
    
}

//MARK: ---------------------------EXTENSION FOR UITABLEVIEW DATASOURSE/DELEGATE
extension DashboardViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyWorkoutsTableViewCell = workoutTblView.dequeueReusableCell(withIdentifier: "MyWorkoutsTableViewCell", for: indexPath) as! MyWorkoutsTableViewCell
        
        DispatchQueue.main.async {
            cell.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
        }
        
        cell.completedUserMBV.isHidden = true
        cell.setupcellData()
        
        return cell
    }
    
    
}





