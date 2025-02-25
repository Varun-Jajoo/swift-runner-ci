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
        
        setupUI()
        setUpCustomPageControl()
        self.updatePage(to: 0)
        

        // Use the blurredGrayImage as needed, e.g., display it in an UIImageView:
        if let imgView = UIImage(named: "ic_streak_Badage2") {
            self.streakBadage3ImgView.image = createGrayBlurImage(from: imgView, blurRadius: 2.0)
        }
        


       
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
    

    func setNavUI(){
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
    
    
    //MARK: ---------- SET UI
    func setupUI(){
        
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
        
        
        DispatchQueue.main.async {
            //Book a Trainer at Gym/Home
            //Buy MyPT Studio Membership
            
            self.bookTrainerAtHomeBtn.titleLabel?.numberOfLines = 0
            self.bookTrainerAtHomeBtn.titleLabel?.lineBreakMode = .byClipping
            self.membershipBtn.titleLabel?.numberOfLines = 0
            self.membershipBtn.titleLabel?.lineBreakMode = .byClipping
            
            self.bookTrainerAtHomeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.membershipBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.bookTrainerAtHomeBtn.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 8.0/255.0, green: 18.0/255.0, blue: 22.0/255.0, alpha: 0.0).cgColor, UIColor(red: 30.0/255.0, green: 21.0/255.0, blue: 7.0/255.0, alpha: 1.0).cgColor], type: .axial)
            self.membershipBtn.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 8.0/255.0, green: 18.0/255.0, blue: 22.0/255.0, alpha: 0.0).cgColor, UIColor(red: 30.0/255.0, green: 21.0/255.0, blue: 7.0/255.0, alpha: 1.0).cgColor], type: .axial)
        
            self.waterIntekMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .conic)
            self.quantityMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 0/255.0, green: 184/255.0, blue: 251/255.0, alpha: 1.0).cgColor, UIColor(red: 0/255.0, green: 79/255.0, blue: 255/255.0, alpha: 1).cgColor], type: .axial)
            self.calorieIntakeMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .conic)
            self.calorieBurnMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .conic)
            
            self.waterIntekMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 18.0)
            self.quantityMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 18.0)
            self.plusQuantityBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 10.0)
            self.calorieIntakeMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 18.0)
            self.calorieBurnMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 18.0)
            
            self.kcalProgressView.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor.appYellow, cornerRadius: 3.0)
            
            self.topView.setGradientBorder(cornerRadious:9.0,width: 0.8, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
            self.dayStreakMBV.setGradientBorder(cornerRadious:20.0,width: 0.8, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            self.dayStreakMBV.roundSideCorners(radius: 20.0, cornerSide: [.bottomLeft,.bottomRight])
            self.calendarMBV.setGradientBorder(cornerRadious:20.0,width: 0.8, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
            self.dayStreakMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .conic)
            self.topView.layerGradient(startPoint: .center, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .conic)
//            self.calendarMBV.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .conic)
            
//            self.calendarLine.layerGradient(startPoint: .center, endPoint: .bottomLeft, colorArray: [UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0).cgColor, UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1.0).cgColor,UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0).cgColor], type: .axial)
            
            self.calendarMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.calendarMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0), cornerRadius: 20)

            self.calendarMBV.setGradientBorder(cornerRadious:20.0,width: 2.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
            self.footerLine.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0).cgColor, UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1.0).cgColor,UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0).cgColor], type: .axial)
            
            self.sunSubMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            self.day2MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            self.day3MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            self.day4MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            self.day5MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            self.day6MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            self.day7MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
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
            cell.titleLbl.text = self.productCategory?[indexPath.row] as? String
            return cell
        }
        else if collectionView == productListCollView{
            let cell:ProductsListCollViewCell = productListCollView.dequeueReusableCell(withReuseIdentifier: "ProductsListCollViewCell", for: indexPath) as! ProductsListCollViewCell
           
            return cell
        }else if collectionView == workoutsDayCollView{
            let cell:ProductCategoryCollViewCell = workoutsDayCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyWorkoutsTableViewCell = workoutTblView.dequeueReusableCell(withIdentifier: "MyWorkoutsTableViewCell", for: indexPath) as! MyWorkoutsTableViewCell
        
        cell.completedUserMBV.isHidden = true
        cell.setupcellData()
        
        return cell
    }
    
    
}





