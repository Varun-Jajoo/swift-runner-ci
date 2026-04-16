//
//  LibraryViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/11/24.
//

import UIKit

class LibraryViewController: CommonViewController {
    
    
    //MARK: ------------------- VARIABLE
    //    var gymCategoryData:[[String:Any]]?
    var gymCategoryData:[CategoryModel]? = []
    var gymFeaturedData:[FeaturedModel]? = []
    var workoutsCategory: [WorkoutAllcategoryModel]? = []
    var getWorkoutData: [GetWorkoutsModel]? = []
    var myWorkoutsData: [MyWorkoutsDataModel]? = []
    
    
    //    var workoutCategoryData:[[String:Any]]?
    var featuredIndex:IndexPath = IndexPath(row: -1, section: 0)
    var myWorkoutIndexPath:IndexPath = IndexPath(row: -1, section: 0)
    
    var typeId: String? {
        didSet{
//            self.getWorkoutsApi(inputType: typeId, page: pageNum)
        }
    }
    
    var pageNum: Int? {
        didSet{
//            self.getWorkoutsApi(inputType: typeId, page: pageNum)
        }
    }
    
    var myWorkoutDates: [[String: String]]? = []
    
    
    //MARK: ----------------------IBOUTLET
    @IBOutlet weak var topSearchMBV: UIView!
    @IBOutlet weak var searchWorkoutTxtField: UITextField!
    @IBOutlet weak var searchWorkoutBtn: UIButton!
    @IBOutlet weak var gymCategoryMBV: UIView!
    @IBOutlet weak var workoutCategoryMBV: UIView!
    @IBOutlet weak var featuredMBV: UIView!
    @IBOutlet weak var workoutsMBV: UIView!
    @IBOutlet weak var yourActiveChallengeMBV: UIView!
    @IBOutlet weak var activeChallengeSubMBV: UIView!
    @IBOutlet weak var activeProgressMBV: UIView!
    @IBOutlet weak var footerNoteMBV: UIView!
    @IBOutlet weak var footerImgView: UIImageView!
    @IBOutlet weak var gymCatCollView: UICollectionView!
    @IBOutlet weak var featuredTitleLbl: UILabel!
    @IBOutlet weak var featuredBtn: UIButton!
    @IBOutlet weak var featuredCollView: UICollectionView!
    @IBOutlet weak var myworkoutsTitleLbl: UILabel!
    @IBOutlet weak var myworkoutsViewMoreBtn: UIButton!
    @IBOutlet weak var myworkoutsDaysCollView: UICollectionView!
    @IBOutlet weak var myworkoutsTblView: UITableView!
    @IBOutlet weak var myworkoutsTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var workoutsTitlLbl: UILabel!
    @IBOutlet weak var workoutsViewMoreBtn: UIButton!
    @IBOutlet weak var workoutsCategoryCollView: UICollectionView!
    @IBOutlet weak var workoutsCollView: UICollectionView!
    @IBOutlet weak var yourworkoutTitle: UILabel!
    @IBOutlet weak var activeTitleLbl: UILabel!
    @IBOutlet weak var activeChallengeNameLbl: UILabel!
    @IBOutlet weak var activeProgressLbl: UILabel!
    @IBOutlet weak var activeCompleteLbl: UILabel!
    @IBOutlet weak var activeWeeksBtn: UIButton!
    @IBOutlet weak var activeWorkoutBtn: UIButton!
    @IBOutlet weak var activeResumeBtn: UIButton!
    @IBOutlet weak var yourworkoutViewMoreBtn: UIButton!
    @IBOutlet weak var footerLineLbl: UILabel!
    @IBOutlet weak var thoughtsLbl: UILabel!
    @IBOutlet weak var thoughtWritterLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupFont()
        self.registerColl()
        self.setupProgress()
        self.myWorkoutDates?.removeAll()
        self.myWorkoutDates = DateFormatterHelper.shared.getDatesDays()
        
        self.view.setComingSoon(bgColor: UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 0.7),centerImgName: "ic_upcomingStripe", lockImgName: "ic_upcomingLock" ,title: AppStrings.coming_soon, desc: "Your plan of workouts is almost ready. Hang tight — it's coming soon!.")
        
        
        //        self.setBackgroundImage(named: "ic_upcoming_Library")
        //        self.setTopBackgroundImage(named: "ic_upcoming_Library")
        
        
        /*
         self.gymCategoryData = [
         [
         "title":"Strength",
         "img":"ic_strength",
         "gredientColor":[UIColor(red: 22.0/255.0, green: 26.0/255.0, blue: 27.0/255.0, alpha: 1.0),UIColor(red: 27.0/255.0, green: 47.0/255.0, blue: 76.0/255.0, alpha: 1.0)]
         ],
         [
         "title":"Bicycling",
         "img":"ic_bicycling",
         "gredientColor":[UIColor(red: 22.0/255.0, green: 26.0/255.0, blue: 27.0/255.0, alpha: 1.0),UIColor(red: 27.0/255.0, green: 76.0/255.0, blue: 67.0/255.0, alpha: 1.0)]
         ],
         [
         "title":"Endurance",
         "img":"ic_endurance",
         "gredientColor":[UIColor(red: 22.0/255.0, green: 26.0/255.0, blue: 27.0/255.0, alpha: 1.0),UIColor(red: 76.0/255.0, green: 62.0/255.0, blue: 27.0/255.0, alpha: 1.0)]
         ],
         [
         "title":"Yoga",
         "img":"ic_yoga",
         "gredientColor":[UIColor(red: 22.0/255.0, green: 26.0/255.0, blue: 27.0/255.0, alpha: 1.0),UIColor(red: 76.0/255.0, green: 27.0/255.0, blue: 62.0/255.0, alpha: 1.0)]
         ]
         ]
         */
        
        //        self.workoutCategoryData = [
        //            [
        //                "title":"Strength",
        //                "img":"ic_strength",
        //            ],
        //            [
        //                "title":"Endurance",
        //                "img":"ic_endurance",
        //            ],
        //            [
        //                "title":"Yoga",
        //                "img":"ic_yoga",
        //            ],
        //            [
        //                "title":"Biking",
        //                "img":"ic_bicycling",
        //            ]
        //        ]
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let myWorkoutDates = myWorkoutDates, myWorkoutDates.count > 1 {
            // Automatically select the first cell
            let firstIndexPath = IndexPath(item: 1, section: 0)
            DispatchQueue.main.async {
                self.myworkoutsDaysCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
                // Optional: perform any additional setup for the selected cell
                self.myworkoutsDaysCollView.delegate?.collectionView?(self.myworkoutsDaysCollView, didSelectItemAt: firstIndexPath)
                self.view.layoutIfNeeded()
                
                //            self.workoutsCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
                //            // Optional: perform any additional setup for the selected cell
                //            self.workoutsCategoryCollView.delegate?.collectionView?(self.workoutsCategoryCollView, didSelectItemAt: firstIndexPath)
                //            self.view.layoutIfNeeded()
            }
        }
        
        
        
        //------------------upcoming
        //        self.setTopBackgroundImage(named: "ic_upcoming_Library")
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
//        setNavUI()
//        self.exploreWorkoutApi()
//        self.getWorkoutTypeApi()
        
        getDate()
    }
    
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [nil], setTitle: ["Explore Library"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func getDate(){
        let d = DateFormatterHelper.shared.getDatesDays()
        print("Days: ", d)
    }
    
    //    func setBackgroundImage(named imageName: String) {
    //        let backgroundImageView = UIImageView(frame: self.view.bounds)
    //        backgroundImageView.image = UIImage(named: imageName)
    //        backgroundImageView.contentMode = .scaleAspectFill
    //        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
    //
    //        view.addSubview(backgroundImageView)
    //
    //        NSLayoutConstraint.activate([
    //            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
    //            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    //            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    //            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    //        ])
    //    }
    
    
    //MARK: ---------------BTN TAG
    enum Btntag: Int {
        case searchBtn = 301, featured, myworkouts, workouts, yourActive, activeResume
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton){
        
        switch sender.tag {
        case Btntag.searchBtn.rawValue:
            print("search Btn clicked.")
          
            /* not Flow is complete
            let vc:ChooseWorkoutViewController = ChooseWorkoutViewController.instantiate(appStoryboard: .library)
            self.navigationController?.pushViewController(vc, animated: true)
            */
            
            /*
             let vc:SessionCompleteViewController = SessionCompleteViewController.instantiate(appStoryboard: .library)
             self.navigationController?.pushViewController(vc, animated: true)
             */
            
        case Btntag.featured.rawValue:
            print("featured Btn clicked.")
            
//            let vc:ScheduleWorkoutViewController = ScheduleWorkoutViewController.instantiate(appStoryboard: .calendar)
            
//            let vc:CreateWorkoutViewController = CreateWorkoutViewController.instantiate(appStoryboard: .calendar)
//            self.navigationController?.pushViewController(vc, animated: true) //only Testing
            
        case Btntag.myworkouts.rawValue:
            print("myworkouts Btn clicked.")
        case Btntag.workouts.rawValue:
            print("workouts Btn clicked.")
        case Btntag.yourActive.rawValue:
            print("yourActive Btn clicked.")
        case Btntag.activeResume.rawValue:
            let vc:ActiveChallengeViewController = ActiveChallengeViewController.instantiate(appStoryboard: .library)
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            print("none  ")
        }
    }
    
    func setupProgress(){
        
        let shaddowView = UIView()
        
        let dualProgressView = DualRoundProgressView()
        DispatchQueue.main.async {
            dualProgressView.frame = self.activeProgressMBV.bounds
            dualProgressView.centerImageSize = CGSize(width: self.activeProgressMBV.frame.size.width*0.5, height: self.activeProgressMBV.frame.size.width*0.5)
            
            self.activeProgressMBV.addSubview(dualProgressView)
            //            self.activeProgressMBV.addSubview(self.activeProgressLbl)
            //            self.activeProgressMBV.addSubview(self.activeCompleteLbl)
            
            let centerX = ((dualProgressView.frame.size.width/2) - (self.activeProgressMBV.frame.size.height*0.5)/2)
            
            let centerY = ((dualProgressView.frame.size.width/2) - (self.activeProgressMBV.frame.size.width*0.5)/2)
            
            shaddowView.frame = CGRect(x: centerX, y: centerY, width: self.activeProgressMBV.frame.size.width*0.5, height: self.activeProgressMBV.frame.size.width*0.5)
            shaddowView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            shaddowView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 10.0)
            dualProgressView.addSubview(shaddowView)
            
            self.activeProgressMBV.addSubview(self.activeProgressLbl)
            self.activeProgressMBV.addSubview(self.activeCompleteLbl)
        }
        
        dualProgressView.outerLineWidth = 10.0
        dualProgressView.innerLineWidth = 10.0
        dualProgressView.outerSpace = 5.0
        dualProgressView.outerCornerRadius = 20
        dualProgressView.innerCornerRadius = 10
        dualProgressView.outerColor = UIColor.appOuterProgress
        dualProgressView.innerColor = UIColor.appYellow
        //        dualProgressView.centerImage = UIImage(named: "ic_activeChallanges")
        
        //         Use the blurredGrayImage as needed, e.g., display it in an UIImageView:
        if let imgView = UIImage(named: "ic_activeChallanges") {
            dualProgressView.centerImage = createGrayBlurImage(from: imgView, blurRadius: 2.0)
        }
        
        dualProgressView.imageCornerRadius = 2.0
        //        // Set initial progress
        dualProgressView.outerProgress = 0.7
        dualProgressView.innerProgress = 0.7
        dualProgressView.outerTrackColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1)
        dualProgressView.innerTrackColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1)
        
        //        DispatchQueue.main.async {
        //            // Set initial progress
        //            dualProgressView.outerProgress = 0.7
        //            dualProgressView.innerProgress = 0.7
        //        }
        //
        // Animate progress after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dualProgressView.outerProgress = 0.75
            dualProgressView.innerProgress = 0.75
        }
    }
    
    func registerColl(){
        
        //-------------------********
        self.gymCatCollView.register(UINib(nibName: "WorkoutGymCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutGymCategoryCollectionViewCell")
        self.featuredCollView.register(UINib(nibName: "WorkoutsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutsCollectionViewCell")
        self.myworkoutsDaysCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        self.myworkoutsTblView.register(UINib(nibName: "MyWorkoutsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyWorkoutsTableViewCell")
        self.workoutsCategoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        self.workoutsCollView.register(UINib(nibName: "WorkoutsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutsCollectionViewCell")
    }
    
    func setupUI(){
        self.searchWorkoutTxtField.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        //        self.searchWorkoutTxtField.placeholderSet(placeHolder: "Search for Workout", color: UIColor.txtDarkGray)
        self.searchWorkoutTxtField.setLeftPaddingWithImage(50.0, 0, AppImages.search_normal)
        
        self.searchWorkoutTxtField.setMultiColorPlaceholder(firstStr: "Search for", firstColor: UIColor.txtDarkGray, firstfont: AppFont.semibold.size(14.0, familyName: familyManrope), secondStr: "Workout", secondColor: UIColor.appWhite, secondfont: AppFont.semibold.size(14.0, familyName: familyManrope))
        
        DispatchQueue.main.async {
            self.activeChallengeSubMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 24.0)
            self.activeChallengeSubMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint(x: 0.5, y: 1.0), cornerRadius: 24.0)
            
            self.searchWorkoutTxtField.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.searchWorkoutBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            
            self.activeResumeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
            self.footerLineLbl.addGradient(colors: [UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0),UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1),UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0)], locations: [0.2,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 1.0)
        }
    }
    
    func setupFont(){
        self.searchWorkoutTxtField.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.featuredTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.myworkoutsTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.workoutsTitlLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.yourworkoutTitle.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.activeTitleLbl.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.activeChallengeNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.activeProgressLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.activeCompleteLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.activeWeeksBtn.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.activeWorkoutBtn.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyManrope)
        self.activeResumeBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.thoughtsLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.thoughtWritterLbl.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
        
        self.activeWeeksBtn.titleLabel?.numberOfLines = 2
        self.activeWorkoutBtn.titleLabel?.numberOfLines = 2
        //        self.activeWeeksBtn.setTitle("5/8 weeks", for: .normal)
        //        self.activeWorkoutBtn.setTitle("5/8 workouts", for: .normal)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        DispatchQueue.main.async {
            if self.myworkoutsTblView.contentSize.height != 0 {
                self.myworkoutsTblViewHeightConstrnt.constant = self.myworkoutsTblView.contentSize.height
            }
        }
        view.layoutIfNeeded()
    }
}

//MARK: ----------------------EXTENSION FOR UICOLLECTIONVIEW
extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == gymCatCollView {
            return gymCategoryData?.count ?? 0
        }
        else if collectionView == featuredCollView{
            return collectionView.numberOfRows(count: self.gymFeaturedData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 200, height: 200)), messageImageHeight: 100, fromTop: 10)
        }
        else if collectionView == myworkoutsDaysCollView{
            return self.myWorkoutDates?.count ?? 0
        }
        else if collectionView == workoutsCategoryCollView{
            return self.workoutsCategory?.count ?? 0
        }
        else if collectionView == workoutsCollView{
            return collectionView.numberOfRows(count: self.getWorkoutData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 200, height: 200)), messageImageHeight: 80, fromTop: 10)
        }
        else {
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == gymCatCollView {
            let gymCatCell:WorkoutGymCategoryCollectionViewCell  = gymCatCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutGymCategoryCollectionViewCell", for: indexPath) as! WorkoutGymCategoryCollectionViewCell
            
            gymCatCell.imgView.loadImage(urlString: "\(self.gymCategoryData?[indexPath.row].image?.value ?? "")", placeholder: UIImage())
            gymCatCell.imgView.contentMode = .scaleToFill
            
            gymCatCell.titlLbl.text = self.gymCategoryData?[indexPath.row].name?.value as? String
            
            /*
             DispatchQueue.main.async {
             gymCatCell.cellMBV.addGradient(colors: self.gymCategoryData?[indexPath.row]["gredientColor"] as? [UIColor] ?? [.red,.green] , locations: [0,1], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
             }
             
             
             gymCatCell.titlLbl.text = gymCategoryData?[indexPath.row]["title"] as? String
             gymCatCell.imgView.image = UIImage(named: gymCategoryData?[indexPath.row]["img"] as? String ?? "")
             */
            
            return gymCatCell
        }
        else if collectionView == featuredCollView{
            let featuredCell:WorkoutsCollectionViewCell  = featuredCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutsCollectionViewCell", for: indexPath) as! WorkoutsCollectionViewCell
            
            featuredCell.repsMBV.isHidden = false
            featuredCell.timingMBV.isHidden = false
            featuredCell.kcalMBV.isHidden = true
            featuredCell.featureCell(cellData: self.gymFeaturedData?[indexPath.row])
            
            featuredCell.shareBtn.accessibilityValue = self.gymFeaturedData?[indexPath.row].id?.value
            featuredCell.shareBtn.addTarget(self, action: #selector(shareToSocial(sender: )), for: .touchUpInside)
            
            featuredCell.videoPlayBtn.accessibilityLabel = featuredCell.workoutNameLbl.text
            featuredCell.videoPlayBtn.accessibilityValue = self.gymFeaturedData?[indexPath.row].id?.value
            featuredCell.videoPlayBtn.addTarget(self, action: #selector(workoutDetialsPlayBtnActn(sender: )), for: .touchUpInside)
            featuredIndex = indexPath
            featuredCell.likeBtn.accessibilityValue = self.gymFeaturedData?[indexPath.row].id?.value
            featuredCell.likeBtn.addTarget(self, action: #selector(likeBtnActn(sender: )), for: .touchUpInside)
            
            /*
             DispatchQueue.main.async {
             //                featuredCell.bckMImgView.removeAddedBlurView(viewShow: featuredCell.bckMImgView)
             //                featuredCell.bckMImgView?.addBlurView(viewShow: featuredCell.bckMImgView, alphBlur: 0.2, bgColor: UIColor.mainBg.withAlphaComponent(0.3))
             
             //                let gradientLayer = CAGradientLayer()
             //                gradientLayer.frame = featuredCell.bckMImgView.bounds
             //                gradientLayer.colors = [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0), UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1)]
             //                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
             //                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
             //
             //                // Add Gradient Layer
             //                featuredCell.bckMImgView.layer.addSublayer(gradientLayer)
             }
             */
            
            //ic_trainer_AtHome
            //            featuredCell.bckMImgView.image = UIImage(named: "ic_person_workout")
            /*
             featuredCell.bckMImgView.image = UIImage(named: "ic_Health_Fitness")
             
             featuredCell.repsMBV.isHidden = false
             featuredCell.timingMBV.isHidden = false
             featuredCell.kcalMBV.isHidden = true
             
             featuredCell.timing.image = UIImage(named: "ic_solid_fireGray")
             featuredCell.reps.image = UIImage(named: "ic_clockGray")
             
             featuredCell.timingTitleLbl.text = "251 kcal"
             featuredCell.repsTitleLbl.text = "1h 30min"
             */
            
            
            /*
             if let imgBck = self.gymFeaturedData?[indexPath.row].image?.value {
             featuredCell.bckMImgView.loadImage(urlString: "\(imgBck)", placeholder: UIImage())
             }
             
             featuredCell.topCategoryLbl.text = self.gymFeaturedData?[indexPath.row].title?.value
             featuredCell.workoutNameLbl.text = self.gymFeaturedData?[indexPath.row].description?.value
             featuredCell.workoutseriesLbl.text = self.gymFeaturedData?[indexPath.row].seriesName?.value
             
             featuredCell.repsMBV.isHidden = false
             featuredCell.timingMBV.isHidden = false
             featuredCell.kcalMBV.isHidden = true
             
             featuredCell.timing.image = UIImage(named: "ic_solid_fireGray")
             featuredCell.reps.image = UIImage(named: "ic_clockGray")
             
             if let caloriesStr = self.gymFeaturedData?[indexPath.row].calories?.value {
             featuredCell.timingTitleLbl.text = "\(caloriesStr)" + " kcal"
             }
             
             //            featuredCell.timingTitleLbl.text = "\(String(describing: self.gymFeaturedData?[indexPath.row].calories?.value))" + " kcal" //"251 kcal"
             featuredCell.repsTitleLbl.text = "1h 30min"
             */
            
            return featuredCell
        }
        else if collectionView == myworkoutsDaysCollView{
            let daysCell:ProductCategoryCollViewCell  = myworkoutsDaysCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
           
            DispatchQueue.main.async {
                daysCell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: daysCell.cellMBV.frame.height/2.0)
            }
            
            daysCell.titleLblTopConstrnt.constant = 9.0
            daysCell.titleLbl.text = self.myWorkoutDates?[indexPath.row]["displayDate"] as? String
            /*
             displayDate
             storageDate
             */
            return daysCell
        }
        else if collectionView == workoutsCategoryCollView{
            let workoutsCategoryCell:WorkoutCategoryCollectionViewCell  = workoutsCategoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            
            workoutsCategoryCell.categoryTitleLbl.text = workoutsCategory?[indexPath.row].name?.value //self.workoutCategoryData?[indexPath.row]["title"] as? String
            workoutsCategoryCell.categoryImgView.loadImage(urlString: workoutsCategory?[indexPath.row].icon?.value, placeholder: UIImage(named: "ic_barbell_ diagonal"), resize: CGSize(width: 20.0, height: 20.0))   // = //UIImage(named: self.workoutCategoryData?[indexPath.row]["img"] as? String ?? "")
            
            return workoutsCategoryCell
        }
        else {
            let workoutCell:WorkoutsCollectionViewCell  = workoutsCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutsCollectionViewCell", for: indexPath) as! WorkoutsCollectionViewCell
            
            DispatchQueue.main.async {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = workoutCell.bckMImgView.bounds
                gradientLayer.colors = [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0), UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1)]
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
                
                // Add Gradient Layer
                workoutCell.bckMImgView.layer.addSublayer(gradientLayer)
            }
            
            workoutCell.repsMBV.isHidden = false
            workoutCell.timingMBV.isHidden = false
            workoutCell.kcalMBV.isHidden = true
            workoutCell.timing.image = UIImage(named: "ic_solid_fireGray")
            workoutCell.reps.image = UIImage(named: "ic_clockGray")
            
            workoutCell.workoutsCell(cellData: self.getWorkoutData?[indexPath.row])
            
            workoutCell.shareBtn.accessibilityHint = "workoutsCollView"
            workoutCell.shareBtn.accessibilityValue = self.getWorkoutData?[indexPath.row].id?.value
            workoutCell.shareBtn.addTarget(self, action: #selector(shareToSocial(sender: )), for: .touchUpInside)
            
            workoutCell.videoPlayBtn.accessibilityLabel = workoutCell.workoutNameLbl.text
            workoutCell.videoPlayBtn.accessibilityValue = self.getWorkoutData?[indexPath.row].id?.value
            workoutCell.videoPlayBtn.addTarget(self, action: #selector(workoutDetialsPlayBtnActn(sender: )), for: .touchUpInside)
            
            workoutCell.likeBtn.accessibilityHint = "workoutsCollView"
            workoutCell.likeBtn.accessibilityValue = self.getWorkoutData?[indexPath.row].id?.value
            workoutCell.likeBtn.addTarget(self, action: #selector(likeBtnActn(sender: )), for: .touchUpInside)
            
            return workoutCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == gymCatCollView{
            let categoryCell = collectionView.cellForItem(at: indexPath) as? WorkoutGymCategoryCollectionViewCell
            let vc:SearchWorkoutViewController = SearchWorkoutViewController.instantiate(appStoryboard: .library)
            vc.categoryIdStr = self.gymCategoryData?[indexPath.row].id?.value
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == featuredCollView{
            let featuredCell = collectionView.cellForItem(at: indexPath) as? WorkoutsCollectionViewCell
            
            featuredIndex = indexPath
            
            featuredCell?.videoPlayBtn.accessibilityLabel = featuredCell?.workoutNameLbl.text
        }
        else if collectionView == workoutsCategoryCollView{
            self.typeId = self.workoutsCategory?[indexPath.row].id?.value
        }
        else if collectionView == workoutsCollView{
            let workoutsCell = collectionView.cellForItem(at: indexPath) as? WorkoutsCollectionViewCell
            
            workoutsCell?.videoPlayBtn.accessibilityLabel = workoutsCell?.workoutNameLbl.text
        }
        else if collectionView == myworkoutsDaysCollView{
            let cell = collectionView.cellForItem(at: indexPath) as? ProductCategoryCollViewCell
            guard let cell = cell else { return }
            cell.cellMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0)
            
//            self.myWorkoutsApi(dateStr: self.myWorkoutDates?[indexPath.row]["storageDate"] as? String, displayDate: self.myWorkoutDates?[indexPath.row]["displayDate"] as? String)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == gymCatCollView {
            return CGSize(width: collectionView.frame.width*0.226, height: collectionView.frame.height)
        }
        else if collectionView == featuredCollView{
            return CGSize(width: collectionView.frame.width*0.82, height: collectionView.frame.height)
        }
        else if collectionView == myworkoutsDaysCollView{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        else if collectionView == workoutsCategoryCollView{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
        else {
            
            return CGSize(width: collectionView.frame.width*0.82, height: collectionView.frame.height)
        }
    }
    
    @objc func workoutDetialsPlayBtnActn(sender: UIButton){
        
        let vc:WorkoutDetailsViewController = WorkoutDetailsViewController.instantiate(appStoryboard: .library)
        vc.workoutNameStr = sender.accessibilityLabel
        vc.workoutId = sender.accessibilityValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    //MARK: ------------------Share btn actiom
    @objc func shareToSocial(sender: UIButton){
        //        Utility.shared.shareSocial(viewController: self, textToShare: "Share to social", imageToShare: AppImages.navLeft ?? UIImage(), urlShareStr: "https://www.google.com/")
        
        //gymFeaturedData
        if sender.accessibilityHint == "workoutsCollView" {
            if let shareBtnId = sender.accessibilityValue {
                //getWorkoutData
                if let indx = self.getWorkoutData?.firstIndex(where: {$0.id?.value == shareBtnId}){
                    let workoutDetails = self.getWorkoutData?[indx]
                    print("share shareMealsData: ", workoutDetails as Any)
                    
                    let getBaseUrl:String = AppBaseUrl.baseScheme.rawValue + "://" + AppBaseUrl.baseDevUrl.rawValue
                    print(getBaseUrl)
                    
                    // let urlString = "https://mobileapp.mypt-me.com/\(self.inputType ?? "")/\(studioDetails?.id ?? 0)/\(gymDetailsFlow)"
                    
                    let urlString = "\(getBaseUrl)/\("workout")/\(workoutDetails?.id?.value ?? "0")/\("workoutLibrary")"
                    Utility.shared.shareSocial(viewController: self, textToShare: workoutDetails?.name ?? "", imageToShare: nil, urlShareStr: urlString)
                    
                    
                    /*
                     ImageDownloader.shared.downloadImage(from: "", completion: {[weak self] img in
                     guard let self = self , let img = img else {
                     return
                     }
                     
                     let getBaseUrl:String = AppBaseUrl.baseScheme.rawValue + "://" + AppBaseUrl.baseDevUrl.rawValue
                     print(getBaseUrl)
                     
                     //            let urlString = "https://mobileapp.mypt-me.com/\(self.inputType ?? "")/\(studioDetails?.id ?? 0)/\(gymDetailsFlow)"
                     
                     let urlString = "\(getBaseUrl)/\(self.inputType ?? "")/\(studioDetails?.id ?? 0)/\(gymDetailsFlow)"
                     Utility.shared.shareSocial(viewController: self, textToShare: studioDetails?.name ?? "", imageToShare: img, urlShareStr: urlString)
                     })
                     */
                }
            }
            
            
        }else{
            if let shareBtnId = sender.accessibilityValue {
                if let indx = self.gymFeaturedData?.firstIndex(where: {$0.id?.value == shareBtnId}){
                    let featuredDetails = self.gymFeaturedData?[indx]
                    print("share featuredDetails: ", featuredDetails as Any)
                    
                    let getBaseUrl:String = AppBaseUrl.baseScheme.rawValue + "://" + AppBaseUrl.baseDevUrl.rawValue
                    print(getBaseUrl)
                    
                    // let urlString = "https://mobileapp.mypt-me.com/\(self.inputType ?? "")/\(studioDetails?.id ?? 0)/\(gymDetailsFlow)"
                    
                    let urlString = "\(getBaseUrl)/\("workout")/\(featuredDetails?.id?.value ?? "0")/\("workoutLibrary")"
                    Utility.shared.shareSocial(viewController: self, textToShare: featuredDetails?.title?.value ?? "", imageToShare: nil, urlShareStr: urlString)
                }
            }
        }
    }
    
    //MARK: ---------------LIKE BTN ACTN
    @objc func likeBtnActn(sender: UIButton){
        sender.isSelected = !sender.isSelected
        
        if sender.accessibilityHint == "workoutsCollView" {
            
            //------------make it favourite
            if let likeBtnId = sender.accessibilityValue {
                self.likeFeatureApi(featuredId: likeBtnId, sender: sender)
            }
            
            /*
             let convertedPoint : CGPoint = sender.convert(CGPoint.zero, to: self.workoutsCollView)
             let indexPath = self.workoutsCollView.indexPathForItem(at: convertedPoint)
             guard let indexPath = indexPath else { return }
             let cell = self.workoutsCollView.cellForItem(at: indexPath) as! WorkoutsCollectionViewCell
             
             if sender.isSelected {
             cell.likeBtn.setImage(UIImage(named: "ic_redHeartbeat"), for: .normal)
             
             } else {
             cell.likeBtn.setImage(UIImage(named: "ic_heart"), for: .normal)
             }
             */
            
        }else{
            
            //------------make it favourite
            if let likeBtnId = sender.accessibilityValue {
                self.likeFeatureApi(featuredId: likeBtnId, sender: sender)
            }
            
            /*
             sender.isSelected = !sender.isSelected
             let convertedPoint : CGPoint = sender.convert(CGPoint.zero, to: self.featuredCollView)
             let indexPath = self.featuredCollView.indexPathForItem(at: convertedPoint)
             guard let indexPath = indexPath else { return }
             let cell = self.featuredCollView.cellForItem(at: indexPath) as! WorkoutsCollectionViewCell
             
             if sender.isSelected {
             cell.likeBtn.setImage(UIImage(named: "ic_redHeartbeat"), for: .normal)
             
             } else {
             cell.likeBtn.setImage(UIImage(named: "ic_heart"), for: .normal)
             }
             */
            
            
        }
    }
    
    private func likeWorkoutsCell(sender: UIButton){
        if sender.accessibilityHint == "workoutsCollView" {
            let convertedPoint : CGPoint = sender.convert(CGPoint.zero, to: self.workoutsCollView)
            let indexPath = self.workoutsCollView.indexPathForItem(at: convertedPoint)
            guard let indexPath = indexPath else { return }
            let cell = self.workoutsCollView.cellForItem(at: indexPath) as! WorkoutsCollectionViewCell
            
            if sender.isSelected {
                cell.likeBtn.setImage(UIImage(named: "ic_redHeartbeat"), for: .normal)
                
            } else {
                cell.likeBtn.setImage(UIImage(named: "ic_heart"), for: .normal)
            }
        }else{
            let convertedPoint : CGPoint = sender.convert(CGPoint.zero, to: self.featuredCollView)
            let indexPath = self.featuredCollView.indexPathForItem(at: convertedPoint)
            guard let indexPath = indexPath else { return }
            let cell = self.featuredCollView.cellForItem(at: indexPath) as! WorkoutsCollectionViewCell
            if sender.isSelected {
                cell.likeBtn.setImage(UIImage(named: "ic_redHeartbeat"), for: .normal)
                
            } else {
                cell.likeBtn.setImage(UIImage(named: "ic_heart"), for: .normal)
            }
        }
    }
}

//MARK: --------------------EXTENSION FOR UITABLEVIEW
extension LibraryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.numberOfRows(count: self.myWorkoutsData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 200, height: 200)), messageImageHeight: 100, fromTop: 20)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyWorkoutsTableViewCell = myworkoutsTblView.dequeueReusableCell(withIdentifier: "MyWorkoutsTableViewCell", for: indexPath) as! MyWorkoutsTableViewCell
        
        cell.completedUserMBV.isHidden = true
        cell.userMBV.isHidden = true
        cell.progressView.isHidden = false
        cell.selectedImgView.isHidden = true
        cell.setCellData(cellData: myWorkoutsData?[indexPath.row])
        
        
        /*
         if myWorkoutIndexPath != indexPath {
         
         DispatchQueue.main.async {
         cell.cellMBV.layer.sublayers?.filter({ $0.name == "addGradient"}).forEach({$0.removeFromSuperlayer()})
         
         cell.cellMBV.applyShadow(fillColor: UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0), shadowColor: UIColor.black, shadowRadius: 0.5, opacity: 0.4, offset: .zero, cornerRadius: 12.0)
         
         let img =  UIImage(named: "ic_Book_Trainer")?.resized(to: CGSize(width: cell.cellMBV.bounds.height - 15, height: cell.cellMBV.bounds.height - 15))
         
         cell.userImgView.image = img
         
         }
         cell.userMBV.isHidden = false
         
         }else{
         
         cell.selectedImgView.isHidden = false
         cell.progressView.isHidden = true
         cell.completedUserMBV.isHidden = false
         
         DispatchQueue.main.async {
         cell.cellMBV.layer.sublayers?
         .filter { $0.name == "apply_Shadow" }.forEach({$0.removeFromSuperlayer()})
         
         cell.cellMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 19.0/255.0, blue: 17.0/255.0, alpha: 0.6),UIColor(red: 69.0/255.0, green: 117.0/255.0, blue: 85.0/255.0, alpha: 0.5)], locations: [0.2,1.0], startPoint: CGPoint(x: 0, y: 1.0), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12.0)
         
         let img =  UIImage(named: "ic_Book_Trainer")?.resized(to: CGSize(width: cell.cellMBV.bounds.height - 15, height: cell.cellMBV.bounds.height - 15))
         cell.userImgView.image = img
         }
         
         //            cell.selectedImgView.isHidden = false
         //            cell.progressView.isHidden = true
         //            cell.completedUserMBV.isHidden = false
         }
         */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("table selection: ", indexPath.row)
        
        if let isCompleted = myWorkoutsData?[indexPath.row].isCompleted, !isCompleted, let displayDate = myWorkoutsData?[indexPath.row].displayDate , displayDate.lowercased() == "today".lowercased() {
            
            let vc:WorkoutDetailsViewController = WorkoutDetailsViewController.instantiate(appStoryboard: .library)
            vc.workoutNameStr = myWorkoutsData?[indexPath.row].title?.value
            vc.workoutId = myWorkoutsData?[indexPath.row].id?.value
            vc.assignmentId = myWorkoutsData?[indexPath.row].assigned_id?.value
            self.navigationController?.pushViewController(vc, animated: true)
            
            /*
             WorkoutLibraryVM.workoutStartApi(inputId: Int(myWorkoutsData?[indexPath.row].id?.value ?? "0"), assignmentId: myWorkoutsData?[indexPath.row].assigned_id?.value, completion: {[weak self] getResultData in
             guard let self = self else { return  }
             let getData = getResultData?["data"] as? [String:Any]
             
             let vc:WorkoutDuringSessionViewController = WorkoutDuringSessionViewController.instantiate(appStoryboard: .library)
             vc.sessionId = getData?["session_id"] as? Int
             vc.workoutData = WorkoutDetailDataModel(id: FlexibleValue(value:myWorkoutsData?[indexPath.row].id?.value), type: FlexibleValue(value: myWorkoutsData?[indexPath.row].type?.value))
             self.navigationController?.pushViewController(vc, animated: true)
             
             })
             */
        }else{
            print("My workout completed....")
        }
        
        //        myWorkoutIndexPath = indexPath
        //        tableView.reloadData()
        /*
         let vc:ArrivingViewController = ArrivingViewController.instantiate(appStoryboard: .library)
         self.navigationController?.pushViewController(vc, animated: true)
         */
        
        //        let cell = tableView.cellForRow(at: indexPath) as? MyWorkoutsTableViewCell
        //        guard let cell = cell else { return  }
        //        cell.selectionCell(isSelected: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //        let cell = tableView.cellForRow(at: indexPath) as? MyWorkoutsTableViewCell
        //        guard let cell = cell else { return  }
        //        cell.selectionCell(isSelected: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.updateViewConstraints()
    }
}

extension LibraryViewController: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.searchWorkoutTxtField {
            let vc:SearchWorkoutViewController = SearchWorkoutViewController.instantiate(appStoryboard: .library)
            self.navigationController?.pushViewController(vc, animated: true)
            return false
        }else{
            return true
        }
    }
}


//MARK: -------------------EXTENSION FOR API
extension LibraryViewController{
    
    private func exploreWorkoutApi(){
        WorkoutLibraryVM.workoutsApi(params: nil, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            if getResultData.status == true {
                self.gymCategoryData?.removeAll()
                if let categoryData = getResultData.data?.categories as? [CategoryModel] {
                    self.gymCategoryData?.append(contentsOf: categoryData)
                    self.gymCatCollView.reloadData()
                }
                
                self.gymFeaturedData?.removeAll()
                self.gymFeaturedData?.append(contentsOf: getResultData.data?.featured ?? [])
                self.featuredCollView.reloadData()
            }
        })
    }
    
    private func likeFeatureApi(featuredId: String?, sender: UIButton){
        WorkoutLibraryVM.makeFavouriteWorkoutApi(inputFeatureId: featuredId, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            if let getDataArr = getResultData["data"] as? [[String:Any]], let firstItem = getDataArr.first, let isFavourite = firstItem["isFavourite"] as? Bool  {
                sender.isSelected = isFavourite
                self.likeWorkoutsCell(sender: sender)
                
                //------------ Manage likes
                if sender.accessibilityHint == "workoutsCollView" {
                    if let indx = self.getWorkoutData?.firstIndex(where: {$0.id?.value == featuredId}){
                        if let isLiked = self.getWorkoutData?[indx].isFeatured {
                            self.getWorkoutData?[indx].isFeatured = !isLiked
                        }
                        //                        self.getWorkoutData?[indx].isFeatured = isLiked
                    }
                    
                }else{
                    if let indx = self.gymFeaturedData?.firstIndex(where: {$0.id?.value == featuredId}){
                        if let isLiked = self.gymFeaturedData?[indx].isFavourite {
                            self.gymFeaturedData?[indx].isFavourite = !isLiked
                        }
                        //self.gymFeaturedData?[indx].isFavourite = !self.gymFeaturedData?[indx].isFavourite
                    }
                }
            }
        })
        
    }
    
    private func getWorkoutTypeApi(){
        WorkoutLibraryVM.workoutTypeApi(isShowLoader: true, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            if getResultData.status == true {
                self.workoutsCategory?.removeAll()
                self.workoutsCategory?.append(contentsOf: getResultData.data?.allcategory ?? [])
                self.workoutsCategoryCollView.reloadData()
                
                if let workoutsCategory = self.workoutsCategory, workoutsCategory.count >= 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        let firstIndexPath = IndexPath(item: 0, section: 0)
                        self.workoutsCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
                        // Optional: perform any additional setup for the selected cell
                        self.workoutsCategoryCollView.delegate?.collectionView?(self.workoutsCategoryCollView, didSelectItemAt: firstIndexPath)
                        self.view.layoutIfNeeded()
                    }
                }
            }
        })
    }
    
    private func getWorkoutsApi(inputType: String? , page: Int?){
        
        let params:[String:Any]? = [
            "type": inputType ?? "",
            "page": page ?? 1 ,
            "muscle_id": "",
            "level": "",
            "calories": "",
            "duration": ""
        ]
        print("params: ", params as Any)
        WorkoutLibraryVM.getWorkoutApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            if getResultData.status == true {
                self.getWorkoutData?.removeAll()
                self.getWorkoutData?.append(contentsOf: getResultData.data?.workouts ?? [])
                self.workoutsCollView.reloadData()
            }
        })
    }
    
    private func myWorkoutsApi(dateStr: String?, displayDate: String?){
        WorkoutLibraryVM.myWorkoutsApi(inputDateStr: dateStr, inputStatus: nil, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            self.myWorkoutsData?.removeAll()
            //            self.myWorkoutsData?.append(contentsOf: getResultData.data ?? [])
            
            self.myWorkoutsData = (getResultData.data ?? []).map { item in
                var newItem = item
                newItem.displayDate = displayDate
                return newItem
            }
            self.myworkoutsTblView.reloadData()
        })
    }
    
    
    //    func getTrainerApi(){
    //        DashboardVM.workoutsApi(viewController: self, params: nil, completion: { [weak self] getResultData in
    //            guard let self = self, let getResultData = getResultData else { return }
    //
    //            if getResultData.status == true {
    //                self.gymCategoryData?.removeAll()
    //                if let categoryData = getResultData.data?.categories as? [CategoryModel] {
    //                    self.gymCategoryData?.append(contentsOf: categoryData)
    //                    self.gymCatCollView.reloadData()
    //                }
    //
    //                self.gymFeaturedData?.removeAll()
    //                self.gymFeaturedData?.append(contentsOf: getResultData.data?.featured ?? [])
    //                self.featuredCollView.reloadData()
    //            }
    //        })
    //    }
}
