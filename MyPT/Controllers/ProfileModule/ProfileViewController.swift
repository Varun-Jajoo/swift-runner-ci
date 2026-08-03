//
//  ProfileViewController.swift
//  MyPT
//
//  Created by techsaga corp on 15/05/25.
//

import UIKit
import Charts
import DGCharts
import Mixpanel

class ProfileViewController: CommonViewController, ChartViewDelegate {

    //MARK: ---------------- VARIABLE
    var profileData: ProfileDataModel? 
    var barChartView = BarChartView()
    var chartValues: [Double]? = []
    var userPlans: [OtherSubscriptionsModel]? = []
    
    let planColorMap: [String: [UIColor]] = [
        "Silver".uppercased(): [
            UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0),
            UIColor.appWhite,
            UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        ],
        "Gold".uppercased(): [
            UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),
            UIColor.appWhite.withAlphaComponent(0.7),
            UIColor(red: 173.0/255.0, green: 130.0/255.0, blue: 54.0/255.0, alpha: 1.0)
        ],
        "Platinum".uppercased(): [
            UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0),
            UIColor.appWhite,
            UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        ],
        "VIP".uppercased(): [
            UIColor(red: 188.0/255.0, green: 140.0/255.0, blue: 210.0/255.0, alpha: 1.0),
            UIColor.appWhite,
            UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),
            UIColor(red: 195.0/255.0, green: 139.0/255.0, blue: 221.0/255.0, alpha: 1.0)
        ]
    ]
    
    //MARK: ------------------ IBOUTLET
    @IBOutlet weak var profileHeaderImgView: UIImageView!
    @IBOutlet weak var profileFooterImgView: UIImageView!
    @IBOutlet weak var userNameMBV: UIView!
    @IBOutlet weak var userNameMBVTopConstrnt: NSLayoutConstraint!
    @IBOutlet weak var personalInfoMBV: UIView!
    @IBOutlet weak var planMBV: UIView!
    @IBOutlet weak var achievementsMBV: UIView!
    @IBOutlet weak var notDataAchievementsV: UIView!
    @IBOutlet weak var myTrainersMBV: UIView!
    @IBOutlet weak var healthPreferencesMBV: UIView!
    @IBOutlet weak var activityMBV: UIView!
    @IBOutlet weak var MyPTScoreMBV: UIView!
    @IBOutlet weak var myStoreGraph: UIView!
    @IBOutlet weak var weeklyMBV: UIView!
    @IBOutlet weak var awardsMBV: UIView!
    @IBOutlet weak var awardsEmptyMBV: UIView!
    @IBOutlet weak var settingsMBV: UIView!
    @IBOutlet weak var supportsMBV: UIView!
    @IBOutlet weak var activityLogMBV: UIView!
    @IBOutlet weak var helpCenterMBV: UIView!
    @IBOutlet weak var motivationMBV: UIView!
    @IBOutlet weak var distanceMBV: UIView!
    @IBOutlet weak var addrMBV: UIView!
    @IBOutlet weak var bookFirstSessionMBV: UIView!
    @IBOutlet weak var userProfileImgView: UIImageView!
    
    @IBOutlet weak var firstSessionImgView: UIImageView!
    @IBOutlet weak var bookYourSessionDescLbl: UILabel!
    @IBOutlet weak var connectYourDeviceDescLbl: UILabel!
    @IBOutlet weak var trackNowBtn: UIButton!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var addressBtn: UIButton!
    @IBOutlet weak var addrLbl: UILabel!
    @IBOutlet weak var memberBtn: UIButton!
    @IBOutlet weak var infoIconImgView: UIImageView!
    @IBOutlet weak var personalInfoLbl: UILabel!
    @IBOutlet weak var personalInfoBtn: UIButton!
    @IBOutlet weak var achievementsTitleLbl: UILabel!
    @IBOutlet weak var myTainerTitleLbl: UILabel!
    @IBOutlet weak var dontHaveTrainerDescLbl: UILabel!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var updateNoteLbl: UILabel!
    @IBOutlet weak var versionBtn: UIButton!
    @IBOutlet weak var healthPreferencesTitleLbl: UILabel!
    @IBOutlet weak var healthPreferencesNoDataLbl: UILabel!
    @IBOutlet weak var myHealthPrefBtn: UIButton!
    @IBOutlet weak var healthPrefCollView: UICollectionView!
    @IBOutlet weak var healthPrefCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var activityTitleLbl: UILabel!
    @IBOutlet weak var emptyActivityImgView: UIImageView!
    @IBOutlet weak var emptyActivityDescLbl: UILabel!
    @IBOutlet weak var myStoreTitleLbl: UILabel!
    @IBOutlet weak var weeklyTitleBtn: UIButton!
    @IBOutlet weak var awardsTitleLbl: UILabel!
    @IBOutlet weak var awardsEmptyTitleLbl: UILabel!
    @IBOutlet weak var emptyAwardsImgView: UIImageView!
    @IBOutlet weak var emptyAwardsDescLbl: UILabel!
    @IBOutlet weak var awardsBtn: UIButton!
    @IBOutlet weak var awardsCollView: UICollectionView!
    @IBOutlet weak var settingsImgView: UIImageView!
    @IBOutlet weak var settingsLbl: UILabel!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var helpCentreTitleLbl: UILabel!
    @IBOutlet weak var helpDescLbl: UILabel!
    @IBOutlet weak var activityLogLbl: UILabel!
    @IBOutlet weak var chstMsgImgView: UIImageView!
    @IBOutlet weak var msgCount: UILabel!
    @IBOutlet weak var notificationImgView: UIImageView!
    @IBOutlet weak var notificationsCountLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var motivationMsgView: UIView!
    @IBOutlet weak var motivationMsgLbl: UILabel!
    @IBOutlet weak var motivationWriterNameLbl: UILabel!
    @IBOutlet weak var myTrainersCollView: UICollectionView!
    @IBOutlet weak var moreTrainersBtn: UIButton!
    @IBOutlet weak var userPlanCollView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Mixpanel.mainInstance().track(
            event: "Profile_Viewed",
            properties: [:]
        )
        self.moreTrainersBtn.isHidden = true
        self.myHealthPrefBtn.isUserInteractionEnabled = true
        self.registerCollV()
        self.setupUI()
        self.setupFont()
        self.setInputData()
//        self.getUserProfileApi()
        self.setupChart()
        self.setData()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        self.topUserNameMBV()
        self.getUserProfileApi()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.topUserNameMBV()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var membershipGrdntColor:[UIColor] = [
            UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),
            UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),
            UIColor(red: 173.0/255.0, green: 130.0/255.0, blue: 54.0/255.0, alpha: 1.0)
            ]
        
        if let userPlansData = self.profileData?.otherSubscriptions {
            if userPlansData.indices.contains(0) {
                if let planStr = userPlansData.first?.getTier, let planColor = self.planColorMap[planStr.uppercased()] {
                    membershipGrdntColor = planColor
                }
            }
        }
        
        DispatchQueue.main.async {
            self.profileHeaderImgView.addGradientLayer(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 0, green: 5/255.0, blue: 2.0/255.0, alpha: 0.1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 0)
            
            self.profileHeaderImgView.addGradientLayer(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 0, green: 5/255.0, blue: 2.0/255.0, alpha: 1.0)], locations: [0.92,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 0)
            self.memberBtn.addGradient(colors: membershipGrdntColor, locations: [0,0.6,1], startPoint: CGPoint(x: 0.4, y: 0), endPoint: CGPoint(x: 1.0, y: 0.4), cornerRadius: 4.0)
            
//            self.memberBtn.addGradient(colors: membershipGrdntColor, locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 4.0)
        }
    }
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [ "My " + AppStrings.profile], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.notificationCount,AppImages.notification], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    enum btnTag: Int {
    case personalInfo = 801, setting, moreTrainer, awardsBtn, myHealthPreference
    }
    
    @IBAction func profileCommonBtnActn(_ sender: UIButton) {
        switch sender.tag {
        case btnTag.personalInfo.rawValue:
            print("Personal info..")
            let vc: ProfileEditViewController = ProfileEditViewController.instantiate(appStoryboard: .profile)
            self.navigationController?.pushViewController(vc, animated: true)
        case btnTag.setting.rawValue:
            print("Setting ")
            /*
            let vc: FollowersViewController = FollowersViewController.instantiate(appStoryboard: .profile)
            self.navigationController?.pushViewController(vc, animated: true)
            */
        case btnTag.moreTrainer.rawValue:
            print("moreTrainer ")
        case btnTag.awardsBtn.rawValue:
            print("Awards details")
            /*
            let vc: AchievmentsViewController = AchievmentsViewController.instantiate(appStoryboard: .profile)
            self.navigationController?.pushViewController(vc, animated: true)
            */
        case btnTag.myHealthPreference.rawValue:
            let vc: HealthDataViewController = HealthDataViewController.instantiate(appStoryboard: .profile)
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            print("None...")
        }
    }
    
    private func registerCollV(){
        
        if let layout = myTrainersCollView.collectionViewLayout as? UICollectionViewFlowLayout {
                 layout.scrollDirection = .horizontal
             }
        myTrainersCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
       
        healthPrefCollView.register(UINib(nibName: "MoreExploreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MoreExploreCollectionViewCell")
        awardsCollView.register(UINib(nibName: "AwardsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AwardsCollectionViewCell")
        userPlanCollView.register(UINib(nibName: "UserPlansCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UserPlansCollectionViewCell")
    }
    
    private func setInputData(){
        self.bookFirstSessionMBV.isHidden = false
        distanceMBV.isHidden = true
        distanceBtn.isHidden = true
        planMBV.isHidden = true
        memberBtn.isHidden = true
        self.activityMBV.isHidden = false
        self.MyPTScoreMBV.isHidden = true
        
        userName.text = profileData?.name
//        self.profileHeaderImgView.loadImage(urlString: profileData?.cover_image, placeholder: UIImage(named: "ic_profileHeader"))
        userProfileImgView.loadImage(urlString: profileData?.image, placeholder: AppImages.profile_placeholder)
        addrLbl.text = profileData?.location?.address
                    
        if let otherSubscriptions = self.profileData?.otherSubscriptions, otherSubscriptions.count > 0 || !otherSubscriptions.isEmpty {
            planMBV.isHidden = false
            self.bookFirstSessionMBV.isHidden = true
            
            if let userPlansData = self.profileData?.otherSubscriptions {
                self.userPlans?.removeAll()
                self.userPlans?.append(contentsOf: userPlansData)
                self.userPlanCollView.reloadData()
                
                if userPlansData.indices.contains(0) {
                    self.memberBtn.isHidden = false
                    self.memberBtn.setTitle((userPlansData.first?.getTier ?? "") + " Member", for: .normal)
                }
            }
            
        }else{
            planMBV.isHidden = true
            memberBtn.isHidden = true
            self.bookFirstSessionMBV.isHidden = false
        }
        
        self.profileHeaderImgView.loadImage(urlString: profileData?.cover_image, placeholder: UIImage(named: "ic_profileHeader"), resize: CGSize(width: self.view.frame.size.width, height: 150))
                        
        if let myptChartData = profileData?.myptChart, myptChartData.count > 0 {
            self.activityMBV.isHidden = true
//            self.MyPTScoreMBV.isHidden = false
        }
        
        if let activityData = profileData?.activityLog {
            self.msgCount.text = "\(activityData.msg ?? 0)"
            self.notificationsCountLbl.text = "\(activityData.notification ?? 0)"
        }
        
        Utility.shared.checkForUpdate(completion: {[weak self] (oldV, newV, isUpdated) in
            guard let self = self, let oldV = oldV else { return  }
            self.versionBtn.setTitle("v." + oldV, for: .normal)
        })

    }
    
    private func topUserNameMBV(){
        //---------------------- Navigationview
        if let navigationController = self.navigationController {
            let navBarHeight = navigationController.navigationBar.frame.height
            let topSafeArea = (self.view.safeAreaInsets.top + 20.0)
            let totalTopHeight = navBarHeight + topSafeArea
            self.userNameMBVTopConstrnt.constant = totalTopHeight
            
            self.userNameMBV.setNeedsLayout()
            self.userNameMBV.layoutIfNeeded()
        }
    }
    
    private func setupFont(){
        userName.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        motivationMsgLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        moreTrainersBtn.titleLabel?.font = AppFont.semibold.size(9.0, familyName: familyManrope)
        
        [
            distanceBtn.titleLabel,
            addressBtn.titleLabel,
            addrLbl,
            updateNoteLbl,
            helpDescLbl,
            connectYourDeviceDescLbl,
            healthPreferencesNoDataLbl,
            activityTitleLbl,
            emptyActivityDescLbl,
            awardsEmptyTitleLbl,
            emptyAwardsDescLbl,
            dontHaveTrainerDescLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
        [
            memberBtn.titleLabel,
            versionBtn.titleLabel,
            motivationWriterNameLbl,
            weeklyTitleBtn.titleLabel,
            trackNowBtn.titleLabel
            
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        [
            bookYourSessionDescLbl,
            personalInfoLbl,
            achievementsTitleLbl,
            myTainerTitleLbl,
            updateBtn.titleLabel,
            healthPreferencesTitleLbl,
            myStoreTitleLbl,
            awardsTitleLbl,
            settingsLbl,
            helpCentreTitleLbl,
            activityLogLbl,
            msgCount,
            notificationsCountLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
    }
    
//    @objc func planViewTap(_ sender: UITapGestureRecognizer) {
//          print("View was tapped!")
//        let vc: UserPlanViewController = UserPlanViewController.instantiate(appStoryboard: .profile)
//        self.navigationController?.pushViewController(vc, animated: true)
//          
//      }
    
    private func setupUI() {
        
        /*
        self.planMBV.isUserInteractionEnabled = true
        let tapPlan = UITapGestureRecognizer(target: self, action: #selector(planViewTap(_ :)))
        self.planMBV.addGestureRecognizer(tapPlan)
        */
        
        self.bookFirstSessionMBV.isHidden = false
        self.activityMBV.isHidden = false
        self.awardsMBV.isHidden = true
        self.awardsEmptyMBV.isHidden = false
        self.healthPreferencesMBV.isHidden = false
        
        //------------------------UI
        DispatchQueue.main.async {
            
            [
                self.personalInfoMBV,
                self.planMBV,
                self.achievementsMBV,
                self.myTrainersMBV,
                self.healthPreferencesMBV,
                self.MyPTScoreMBV,
                self.awardsMBV,
                self.settingsMBV,
                self.helpCenterMBV,
                self.activityLogMBV,
                self.bookFirstSessionMBV,
                self.activityMBV,
                self.awardsEmptyMBV
                
            ].forEach({[weak self] in
                guard self != nil else { return }
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
            self.weeklyMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.moreTrainersBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 6.0)
            self.versionBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 6.0)
            self.memberBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 4.0)
//            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.saveBtn.frame.size.height/2.0)
            self.addressBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.addressBtn.frame.size.height/2.0)
            
            self.memberBtn.addGradient(colors: [
                                                UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),
                                                UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),
                                                UIColor(red: 173.0/255.0, green: 130.0/255.0, blue: 54.0/255.0, alpha: 1.0)
                                               ], locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 4.0)
            
            //[0,0.5,1]
            
//            self.saveBtn.addGradient(colors: [UIColor(red: 29.0/255.0, green: 215.0/255.0, blue: 148.0/255.0, alpha: 1.0),UIColor(red: 9.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0), UIColor(red: 9.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0)], locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: self.saveBtn.frame.size.height/2.0)
            
//            self.planProgressView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
//            self.planProgressView.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor.appWhite, cornerRadius: 3.0)
            
            self.userProfileImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
            self.userProfileImgView.setGradientMultiBorder(cornerRadius: 16.0, width: 3.5, colors: [
                UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),
                UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),
                UIColor(red: 173.0/255.0, green: 130.0/255.0, blue: 54.0/255.0, alpha: 1.0)
               ], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 1, y: 1))
            
            //rgba(207, 171, 104, 1)
            //rgba(255, 241, 216, 1)
            //rgba(173, 130, 54, 1)
           
            //save
            //rgba(29, 215, 148, 1)
            //rgba(9, 46, 46, 1)
        }
        
        achievementsMBV.isHidden = true
        healthPreferencesMBV.isHidden = true
        MyPTScoreMBV.isHidden = true
        awardsMBV.isHidden = true
        awardsEmptyMBV.isHidden = true
    }
    
    //-------------------Make Chart
    func setupChart() {
        DispatchQueue.main.async {
            self.barChartView.frame = self.myStoreGraph.bounds
        }
    
        barChartView.delegate = self
        barChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        barChartView.isUserInteractionEnabled = true
        // X-Axis customization
        barChartView.xAxis.labelPosition = .bottom
//        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["01\nMon", "02\nTue", "03\nWed", "04\nThu", "05\nFri", "06\nSat", "07\nSun"])
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
        barChartView.xAxis.labelTextColor = UIColor.appDarkGray
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.rightAxis.drawGridLinesEnabled = false // just in case
        
        // Y-Axis customization
        let leftAxis = barChartView.leftAxis
        leftAxis.labelTextColor = UIColor.appDarkGray
        leftAxis.axisMinimum = 60
        leftAxis.axisMaximum = 100  // Set your max value here (e.g. 100 like an image)
        leftAxis.granularity = 5 //10   // Spacing between labels
        leftAxis.labelCount = 5     // How many labels to show (it auto adjusts)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor.appDarkGray
        leftAxis.drawAxisLineEnabled = false  // hides left vertical line
        leftAxis.gridLineWidth = 0.5
        barChartView.leftAxis.drawGridLinesEnabled = true
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        
        // Disable zooming
        barChartView.setScaleEnabled(false)
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false

        // Optionally disable dragging/panning too
        barChartView.dragEnabled = false
        barChartView.highlightPerDragEnabled = true
        barChartView.highlightPerTapEnabled = true
        
        // Chart styling
        barChartView.legend.enabled = false  // Hide legend
        barChartView.backgroundColor = UIColor.clear
        barChartView.animate(yAxisDuration: 1.0)
        
        myStoreGraph.addSubview(barChartView)
        barChartView.renderer = RoundedBarChartRenderer(dataProvider: barChartView, animator: barChartView.chartAnimator, viewPortHandler: barChartView.viewPortHandler)
        
//        barChartView.renderer = GradientBarChartRenderer(dataProvider: barChartView,
//                                                              animator: barChartView.chartAnimator,
//                                                              viewPortHandler: barChartView.viewPortHandler)

        
        let marker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        marker.chartView = barChartView
        barChartView.marker = marker
    }
    
        func setData() {
//            let values: [Double] = [75, 95, 87, 72, 90, 82, 97]
                        
            chartValues = profileData?.myptChart?.map({Double($0.score?.intValue as? Int ?? 0)}) ?? []
            
            guard let chartValues = chartValues else { return }
            var dataEntries: [BarChartDataEntry] = []
    
            for (index, value) in chartValues.enumerated() {
                let entry = BarChartDataEntry(x: Double(index), y: value)
                dataEntries.append(entry)
            }
            let dataSet = BarChartDataSet(entries: dataEntries, label: "")
            //rgba(49, 52, 58, 1)
            //rgba(0, 193, 170, 1)
            let deSelectedColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0)
            let selectedColor = UIColor(red: 0/255.0, green: 193/255.0, blue: 170/255.0, alpha: 1.0)
            dataSet.colors = [deSelectedColor, UIColor.red, deSelectedColor, deSelectedColor, deSelectedColor, deSelectedColor, deSelectedColor ]
            dataSet.valueFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
            dataSet.valueTextColor = UIColor.white
            let highlightIndex = 1 // e.g., index for Tuesday
            dataSet.colors = chartValues.enumerated().map { index, _ in
                return index == highlightIndex ? selectedColor : deSelectedColor
            }
    
            let data = BarChartData(dataSet: dataSet)
            data.barWidth = 0.2  // Adjust width to match the desired style
    
            barChartView.data = data
        }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == healthPrefCollView {
            return profileData?.healthPrefernce?.count ?? 0
        }else if collectionView == myTrainersCollView {
            let myTrainers: [ProfileTrainerModel] = Array(profileData?.trainers?.prefix(3) ?? [ProfileTrainerModel(image: "")])
            
            return myTrainers.count
        }
        else if collectionView == awardsCollView{
            return profileData?.awards?.count ?? 0
        }
        else if collectionView == userPlanCollView {
            return self.userPlans?.count ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == healthPrefCollView {
            let healthcell: MoreExploreCollectionViewCell = healthPrefCollView.dequeueReusableCell(withReuseIdentifier: "MoreExploreCollectionViewCell", for: indexPath) as! MoreExploreCollectionViewCell
            
            healthcell.categoryImgView.loadImage(urlString: profileData?.healthPrefernce?[indexPath.row].icon, placeholder: nil)
            healthcell.titleLbl.text = profileData?.healthPrefernce?[indexPath.row].name
            
            return healthcell
        }else if collectionView == myTrainersCollView {
            let cell: WithMeCollectionViewCell = myTrainersCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            DispatchQueue.main.async {
                cell.videoThumbnailImgView.backgroundColor = UIColor.appCard2.withAlphaComponent(0.8)
                cell.videoThumbnailImgView.setCornerRadius(borderWidth: 2, borderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.2), cornerRadious: cell.videoThumbnailImgView.frame.size.height/2.0)
            }
            cell.centerImgView.isHidden = true
            
            cell.videoThumbnailImgView.loadImage(urlString: profileData?.trainers?[indexPath.row].image, placeholder: nil)
            
            // First cell (0) on top (highest zPosition)
            cell.layer.zPosition = CGFloat(1000 - indexPath.item)
            
            return cell
        }
        else if collectionView == awardsCollView{
            let awardsCell: AwardsCollectionViewCell = awardsCollView.dequeueReusableCell(withReuseIdentifier: "AwardsCollectionViewCell", for: indexPath) as! AwardsCollectionViewCell
            awardsCell.awardsImgVIew.loadImage(urlString: profileData?.awards?[indexPath.row].icon, placeholder: nil)
            awardsCell.awardTitleLbl.text = profileData?.awards?[indexPath.row].name
            awardsCell.awardWeightLbl.text = profileData?.awards?[indexPath.row].title
            return awardsCell
        }
        else if collectionView == userPlanCollView {
            let planCell: UserPlansCollectionViewCell = userPlanCollView.dequeueReusableCell(withReuseIdentifier: "UserPlansCollectionViewCell", for: indexPath) as! UserPlansCollectionViewCell
            planCell.setupCell(cellData: userPlans?[indexPath.row])
            
            return planCell
        }
        
        
//        let cell: WithMeCollectionViewCell = myTrainersCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
//        DispatchQueue.main.async {
//            cell.videoThumbnailImgView.setCornerRadius(borderWidth: 2, borderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.2), cornerRadious: cell.videoThumbnailImgView.frame.size.height/2.0)
//        }
//        cell.centerImgView.isHidden = true
//        
//        cell.videoThumbnailImgView.loadImage(urlString: profileData?.trainers?[indexPath.row].image, placeholder: UIImage(named: "ic_profile_placeholder"))
//        
//        // First cell (0) on top (highest zPosition)
//        cell.layer.zPosition = CGFloat(1000 - indexPath.item)
//        
//        return cell
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == myTrainersCollView {
            let vc: FollowersViewController = FollowersViewController.instantiate(appStoryboard: .profile)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView == userPlanCollView{
            let vc: UserPlanViewController = UserPlanViewController.instantiate(appStoryboard: .profile)
            vc.userPlanDetails = self.userPlans?[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        if collectionView == healthPrefCollView {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }else if collectionView == myTrainersCollView {
            // Choose how many items you want to show partially overlapping
               let totalVisibleWidth = collectionView.bounds.width
               let visibleCells = 3 //profileData?.trainers?.count ?? 0
               let overlapOffset: CGFloat = 20

               // Calculate cell width considering overlap
               let cellWidth = (totalVisibleWidth + (CGFloat(visibleCells - 1) * overlapOffset)) / CGFloat(visibleCells)

               return CGSize(width: cellWidth, height: cellWidth) // Square
        }
        else if collectionView == awardsCollView {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
        else if collectionView == userPlanCollView {
            if let userplanCount = self.userPlans?.count, userplanCount == 1 {
                return CGSize(width: collectionView.frame.size.width * 0.9, height: collectionView.frame.size.height)
            }else{
                return CGSize(width: collectionView.frame.size.width * 0.8, height: collectionView.frame.size.height)
            }
            
//            return CGSize(width: collectionView.frame.size.width * 0.8, height: collectionView.frame.size.height)
        }
        
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return -20 // Negative for overlap
        
        if collectionView == healthPrefCollView {
            return 40
        }else if collectionView == myTrainersCollView {
            return -20 // Negative for overlap
        }
        else  if collectionView == awardsCollView {
            return 16
        }
        else{
            return 10
        }
    }
}

extension ProfileViewController {
    private func getUserProfileApi() {
        ProfileVM.getUserProfileApi(inputParams: nil, completion: {[weak self] getResultData in
            guard let self = self, var getResultData = getResultData else { return }
            self.profileData = getResultData.data
            print("getResultData", getResultData)
            self.setInputData()
                        
            if let _ = profileData?.myptChart {
                self.setData()
            }
            if let awardsData = profileData?.awards , !awardsData.isEmpty {
//                self.awardsMBV.isHidden = false
//                self.awardsEmptyMBV.isHidden = true
                self.awardsCollView.reloadData()
            }else{
//                self.awardsMBV.isHidden = true
//                self.awardsEmptyMBV.isHidden = false
            }
            
            if let healthPrefernce = profileData?.healthPrefernce , !healthPrefernce.isEmpty {
//                self.healthPreferencesMBV.isHidden = false
                self.myHealthPrefBtn.isUserInteractionEnabled = true
                self.healthPreferencesNoDataLbl.isHidden = true
                self.healthPrefCollViewHeightConstrnt.constant = 140.0
                self.healthPrefCollView.layoutIfNeeded()
                self.healthPrefCollView.reloadData()
            }else{
//                self.healthPreferencesMBV.isHidden = true
                self.myHealthPrefBtn.isUserInteractionEnabled = false
                self.healthPreferencesNoDataLbl.isHidden = false
                self.healthPrefCollViewHeightConstrnt.constant = 10.0
                self.healthPrefCollView.layoutIfNeeded()
            }
            
            if let trainersCount = getResultData.data?.trainers?.count, trainersCount > 0 {
                self.myTrainersCollView.isHidden = false
                self.dontHaveTrainerDescLbl.isHidden = true
                self.myTrainersCollView.reloadData()
                if trainersCount > 3 {
                    self.moreTrainersBtn.isHidden = false
                }
                
                
                /*
                if let flowLayout = self.myTrainersCollView.collectionViewLayout as? UICollectionViewFlowLayout {
                    if trainersCount == 1 {
                        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.myTrainersCollView.bounds.width)
                    } else {
                        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    }
                }
                
                DispatchQueue.main.async {
                    let numberOfItems = self.myTrainersCollView.numberOfItems(inSection: 0)
                    if trainersCount == 1, numberOfItems > 0 {
                        self.myTrainersCollView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
                    }
                }
                */
            }
            else{
                self.myTrainersCollView.isHidden = true
                self.dontHaveTrainerDescLbl.isHidden = false
            }
        })
    }
}


//-------------------------------Customize chart

//  MARK: - Calss for make round for calorie bar chart
class RoundedBarChartRenderer: BarChartRenderer {
    override func drawDataSet(context: CGContext, dataSet: BarChartDataSetProtocol, index: Int) {
        guard let dataProvider = dataProvider,
              let barData = dataProvider.barData else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        let phaseY = animator.phaseY
        let barWidthHalf = CGFloat(barData.barWidth / 2.0)
        
        for i in 0..<dataSet.entryCount {
            guard let entry = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
            
            var rect = CGRect.zero
            rect.origin.x = CGFloat(entry.x - barWidthHalf)
            rect.size.width = CGFloat(barData.barWidth)
            rect.origin.y = CGFloat(entry.y * phaseY) // Starts from the x-axis
            rect.size.height = CGFloat(-entry.y * phaseY) // Adjust for negative bars if necessary
            // Adjust the bottom part of the rect for rounding the bottom corners
            if entry.y < 0 {
                rect.origin.y = CGFloat(entry.y * phaseY) + CGFloat(entry.y) // for negative values
                rect.size.height = -rect.size.height
            }
            
            trans.rectValueToPixel(&rect)
            // Create a rounded rect with all corners rounded
            let roundedPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 4)
            context.addPath(roundedPath.cgPath)
            context.setFillColor(dataSet.colors[i % dataSet.colors.count].cgColor)
            context.fillPath()
        }
    }
}

class CustomMarkerView: MarkerView {
    private var label: UILabel!
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.appWhite
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
 
        label = UILabel()
        label.textColor = UIColor.mainBg
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        label.backgroundColor = UIColor.clear
        self.addSubview(label)
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        label.text = "\(Int(entry.y))"
        super.refreshContent(entry: entry, highlight: highlight)
    }
 
    override func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)
 
        // Triangle size
        let triangleWidth: CGFloat = 12
        let triangleHeight: CGFloat = 8
 
        let bubbleWidth = self.bounds.width
        let triangleX = point.x - triangleWidth / 2
        let triangleY = point.y - triangleHeight
 
        context.saveGState()
        context.setFillColor(UIColor.appWhite.cgColor)
//        context.setFillColor(UIColor.white.cgColor)
 
        // Draw triangle
        let trianglePath = CGMutablePath()
        trianglePath.move(to: CGPoint(x: triangleX, y: triangleY))
        trianglePath.addLine(to: CGPoint(x: triangleX + triangleWidth, y: triangleY))
        trianglePath.addLine(to: CGPoint(x: triangleX + triangleWidth / 2, y: triangleY + triangleHeight))
        trianglePath.closeSubpath()
 
        context.addPath(trianglePath)
        context.fillPath()
        context.restoreGState()
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let size = self.bounds.size
        return CGPoint(x: -size.width / 2, y: -size.height - 12) // shift up a bit more
    }
    
}
 

class GradientBarChartRenderer: BarChartRenderer {
    override func drawHighlighted(context: CGContext, indices: [Highlight]) {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
        else { return }

        context.saveGState()

        for high in indices {
            guard
                let set = barData[high.dataSetIndex] as? BarChartDataSetProtocol,
                set.isHighlightEnabled,
                let entry = set.entryForXValue(high.x, closestToY: high.y) as? BarChartDataEntry
            else {
                continue
            }

            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            let barWidth = barData.barWidth
            let y = entry.y
            let x = entry.x

            var barRect = CGRect(x: x - barWidth / 2.0, y: 0, width: barWidth, height: y)
            var pt1 = CGPoint(x: barRect.origin.x, y: y)
            var pt2 = CGPoint(x: barRect.origin.x + barRect.width, y: 0)

            trans.pointValueToPixel(&pt1)
            trans.pointValueToPixel(&pt2)

            let rect = CGRect(x: pt1.x,
                              y: pt1.y,
                              width: pt2.x - pt1.x,
                              height: pt2.y - pt1.y)

            // Draw gradient
            let path = UIBezierPath(rect: rect)
            context.addPath(path.cgPath)
            context.clip()

            let gradientColors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors as CFArray, locations: nil)!

            let startPoint = CGPoint(x: rect.midX, y: rect.minY)
            let endPoint = CGPoint(x: rect.midX, y: rect.maxY)

            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])

            context.resetClip()
        }

        context.restoreGState()
    }
}


//class GradientBarChartRenderer: BarChartRenderer {
//    override func drawHighlighted(context: CGContext, indices: [Highlight]) {
//        guard
//            let dataProvider = dataProvider,
//            let barData = dataProvider.barData
//        else { return }
//
//        context.saveGState()
//
//        for high in indices {
//            guard
//                let set = barData.getDataSetByIndex(high.dataSetIndex) as? BarChartDataSetProtocol,
//                set.isHighlightEnabled
//            else { continue }
//
//            guard let entry = set.entryForXValue(high.x, closestToY: high.y) as? BarChartDataEntry else {
//                continue
//            }
//
//            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
//
//            var barRect = CGRect()
//            self.prepareBarHighlight(x: entry.x, y: entry.y,
//                                     barWidthHalf: barData.barWidth / 2.0,
//                                     trans: trans,
//                                     rect: &barRect)
//
//            // Clip and draw gradient
//            let path = UIBezierPath(rect: barRect)
//            context.addPath(path.cgPath)
//            context.clip()
//
//            // Gradient fill
//            let colors = [UIColor.red.cgColor, UIColor.orange.cgColor] // Your gradient colors
//            let colorSpace = CGColorSpaceCreateDeviceRGB()
//            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil)!
//
//            let startPoint = CGPoint(x: barRect.midX, y: barRect.minY)
//            let endPoint = CGPoint(x: barRect.midX, y: barRect.maxY)
//
//            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
//
//            context.resetClip()
//        }
//
//        context.restoreGState()
//    }
//}

