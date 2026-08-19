//
//  HealthDataViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/06/25.
//

import UIKit

class HealthDataViewController: CommonViewController {

    //MARK: ------------VARIABLE
    var fatsDataLst:[HydrationDataModel]? = []
    var waistHipDataLst:[HydrationDataModel]? = []
    var cardiovascularDataLst:[HydrationDataModel]? = []
    var timer: Timer?
    var healthStatsData: HealthStatsDataModel?
    var resourceList: [ResourceModel]? = []
    var userMeals: [UserMealsDataModel]? = []
    var todayString:String?
    
    
    //MARK: ------------IBOUTLET
    @IBOutlet weak var healthDataMStck: UIStackView!
    @IBOutlet weak var topSegMBV: UIStackView!
    @IBOutlet weak var healthMBV: UIView!
    @IBOutlet weak var myStatsMBV: UIView!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var heightWeightMV: UIStackView!
    @IBOutlet weak var heightMBV: UIView!
    @IBOutlet weak var weightMBV: UIView!
    @IBOutlet weak var clientDataMBV: UIView!
    @IBOutlet weak var goalMBV: UIView!
    @IBOutlet weak var dietMBV: UIView!
    @IBOutlet weak var UpcomingMealsMBV: UIView!
    @IBOutlet weak var fitnessResourceMBV: UIView!
    @IBOutlet weak var motivationMBV: UIView!
    @IBOutlet weak var footerImgView: UIImageView!
    @IBOutlet weak var healthBtn: UIButton!
    @IBOutlet weak var myStatsBtn: UIButton!
    @IBOutlet weak var heightTitleLbl: UILabel!
    @IBOutlet weak var heightUnitLbl: UILabel!
    @IBOutlet weak var weightTitleLbl: UILabel!
    @IBOutlet weak var weightUnitLbl: UILabel!
    @IBOutlet weak var clientDataTitleLbl: UILabel!
    @IBOutlet weak var specificGoalTitleLbl: UILabel!
    @IBOutlet weak var showGoalBtn: UIButton!
    @IBOutlet weak var dietTitleLbl: UILabel!
    @IBOutlet weak var dietSeeMoreBtn: UIButton!
    @IBOutlet weak var upcomingMealsTitleLbl: UILabel!
    @IBOutlet weak var upcomingMealsSeeMoreBtn: UIButton!
    @IBOutlet weak var upcomingMealsImgView: UIImageView!
    @IBOutlet weak var fuelBodyNutritionLbl: UILabel!
    @IBOutlet weak var fuelBodyNutritionDescLbl: UILabel!
    @IBOutlet weak var fitnessResourceTitleLbl: UILabel!
    @IBOutlet weak var fitnessSeeMoreBtn: UIButton!
    @IBOutlet weak var motivationLineV: UILabel!
    @IBOutlet weak var motivationSubV: UIView!
    @IBOutlet weak var motivationQuotesLbl: UILabel!
    @IBOutlet weak var writerLbl: UILabel!
    @IBOutlet weak var fitnessTblView: UITableView!
    @IBOutlet weak var clientDataCollView: UICollectionView!
    @IBOutlet weak var dietCollView: UICollectionView!
    @IBOutlet weak var fitnessTblViewHeightConstrrnt: NSLayoutConstraint!
    
    //------------------**************
    @IBOutlet weak var myStatsMStck: UIStackView!
    @IBOutlet weak var healthOverviewMBV: UIView!
    @IBOutlet weak var activitySubView: UIView!
    @IBOutlet weak var activityProgressV: UIView!
    @IBOutlet weak var caloriesSubView: UIView!
    @IBOutlet weak var caloriesProgressV: UIView!
    @IBOutlet weak var execriseSubView: UIView!
    @IBOutlet weak var exerciseProgressV: UIView!
    @IBOutlet weak var physicalMeasurementMBV: UIView!
    @IBOutlet weak var myStatsheightMBV: UIView!
    @IBOutlet weak var myStatsWeightMBV: UIView!
    @IBOutlet weak var bodyCompositionMBV: UIView!
    @IBOutlet weak var bodyCompositionDetailsMBV: UIView!
    @IBOutlet weak var bodyMassDataMBV: UIView!
    @IBOutlet weak var noDataBodyMassMBV: UIView!
    @IBOutlet weak var bodyFatPerMBV: UIView!
    @IBOutlet weak var bodyFatPerDetailsMBV: UIView!
    @IBOutlet weak var fatDataMBV: UIView!
    @IBOutlet weak var noFatDataMBV: UIView!
    @IBOutlet weak var fatsBodyPartsLstMBV: UIView!
    @IBOutlet weak var waistHipRatioMBV: UIView!
    @IBOutlet weak var waistHipRatioDetailsMBV: UIView!
    @IBOutlet weak var showDataWaistMBV: UIView!
    @IBOutlet weak var noDataWaistMBV: UIView!
    @IBOutlet weak var waistRatioLstMBV: UIView!
    @IBOutlet weak var cardiovascularHealthMBV: UIView!
    @IBOutlet weak var cardiovascularHealthDetailsMBV: UIView!
    @IBOutlet weak var cardiovascularNAMBV: UIView!
    @IBOutlet weak var noDataCardiovascularHealthMBV: UIView!
    @IBOutlet weak var cardiovascularHealthLstMBV: UIView!
    
    @IBOutlet weak var activityProgressImgView: UIImageView!
    @IBOutlet weak var caloriesProgressImgView: UIImageView!
    @IBOutlet weak var exerciseProgressImgView: UIImageView!
    
    @IBOutlet weak var healthOverTitleLbl: UILabel!
    @IBOutlet weak var activitiesCountLbl: UILabel!
    @IBOutlet weak var activitiesTitleLbl: UILabel!
    @IBOutlet weak var caloriesCountLbl: UILabel!
    @IBOutlet weak var caloriesTitleLbl: UILabel!
    @IBOutlet weak var execriseCountLbl: UILabel!
    @IBOutlet weak var execriseTitleLbl: UILabel!
    @IBOutlet weak var physicalMeasurementTitleLbl: UILabel!
    @IBOutlet weak var myStatsHeightTitleLbl: UILabel!
    @IBOutlet weak var myStatsHeightUnitLbl: UILabel!
    @IBOutlet weak var myStatsWeightTitleLbl: UILabel!
    @IBOutlet weak var myStatsWeightUnitLbl: UILabel!
    @IBOutlet weak var bodyCompositionTitleLbl: UILabel!
    @IBOutlet weak var bodyMassIndexLbl: UILabel!
    @IBOutlet weak var bodyMassIndexUnitLbl: UILabel!
    @IBOutlet weak var bodyMassNoDataDescLbl: UILabel!
    @IBOutlet weak var bodyFatPerTitleLbl: UILabel!
    @IBOutlet weak var bodyFatPerLbl: UILabel!
    @IBOutlet weak var fatPerNoDataDescLbl: UILabel!
    @IBOutlet weak var waistHipRatioTitleLbl: UILabel!
    @IBOutlet weak var waistHipRatioUnitLbl: UILabel!
    @IBOutlet weak var waistHipRatioNoDataDescLbl: UILabel!
    @IBOutlet weak var cardiovascularHealthTitleLbl: UILabel!
    @IBOutlet weak var cardiovascularHealthSubTitleLbl: UILabel!
    @IBOutlet weak var cardiovascularNALbl: UILabel!
    @IBOutlet weak var cardiovascularNADescLbl: UILabel!
    @IBOutlet weak var cardiovascularTblView: UITableView!
    @IBOutlet weak var fatsBodyPartsTblView: UITableView!
    @IBOutlet weak var waistHipRatioTblView: UITableView!
    
    @IBOutlet weak var showBodyFatBtn: UIButton!
    @IBOutlet weak var showHealthDateBtn: UIButton!
    @IBOutlet weak var showBodyMassBtn: UIButton!
    @IBOutlet weak var showWaistHealthBtn: UIButton!
    
    @IBOutlet weak var fatsBodyPartsTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var waistHipRatioTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var cardiovascularTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fitnessTblView.isHidden = true
        dietCollView.isHidden = true
        healthDataMStck.isHidden = true
        myStatsMStck.isHidden = true
        setupFont()
        setupUI()
        self.registerCell()
        self.setSegBtn(isHealth: true)
        self.inputData()
        self.healthStatsApi(typeStr: "1")
        self.getResourceApi() 
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" //"2025-07-10"
        todayString = formatter.string(from: Date())
        self.getUserMealsApi(todayDateStr: todayString)
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Health Data"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
        self.loadViewIfNeeded()
    }
    
    private func inputData(){
        self.UpcomingMealsMBV.isHidden = true
        self.dietMBV.isHidden = true
        self.noDataBodyMassMBV.isHidden = true
        self.bodyFatPerMBV.isHidden = false
        self.noFatDataMBV.isHidden = true
        self.fatsBodyPartsLstMBV.isHidden = true
        self.noDataWaistMBV.isHidden = true
        self.cardiovascularNAMBV.isHidden = true
        self.noDataCardiovascularHealthMBV.isHidden = true
        self.fitnessResourceMBV.isHidden = true
        
        self.fatDataMBV.isHidden = false
        self.showDataWaistMBV.isHidden = false
        self.bodyMassDataMBV.isHidden = false
        self.fatsBodyPartsLstMBV.isHidden = false
        self.waistRatioLstMBV.isHidden = false
        self.cardiovascularHealthLstMBV.isHidden = false
        
        
        //------------------------HEALTH FLOW
        if let cholesterol = healthStatsData?.cardioInsights?.cholesterol?.value, let hdlValue = healthStatsData?.cardioInsights?.hdl?.value, !cholesterol.isEmpty || !hdlValue.isEmpty {
            self.clientDataCollView.reloadData()
        }
        
        if let goalStr =  healthStatsData?.customGoal, !goalStr.isEmpty {
            self.showGoalBtn.setTitle(goalStr, for: .normal)
        }else{
            self.showGoalBtn.setTitle("Data not available", for: .normal)
        }
        
        let heightStr = healthStatsData?.healthData?.height?.components(separatedBy: " ")
        let heightUnit = ((heightStr?.count ?? 0) > 1 ? heightStr?.last ?? "" : "")
        
        let heightfirstPart = setAttributedTxt(inputLabel: self.heightUnitLbl, mainStr: heightStr?.first ?? "", subStr: heightUnit, mainFont: AppFont.medium.size(30.0, familyName: familyClashDisplay), subFont: AppFont.medium.size(25.0, familyName: familyClashDisplay))
//        let heightsecondPart = setAttributedTxt(inputLabel: self.heightUnitLbl, mainStr: "7", subStr: "in")
        let heightCombind = NSMutableAttributedString(attributedString: heightfirstPart)
//        heightCombind.append(heightsecondPart)
//        heightUnitLbl.attributedText = heightCombind
        
        if let heightHealthFlow = healthStatsData?.healthData?.height, !heightHealthFlow.isEmpty {
            heightUnitLbl.attributedText = heightCombind
        }else{
            heightUnitLbl.text = "NA"
        }
        
        let weightStr = healthStatsData?.healthData?.weight?.components(separatedBy: " ")
        let weightUnit = ((weightStr?.count ?? 0) > 1 ? weightStr?.last ?? "" : "")
        
//        weightUnitLbl.attributedText = setAttributedTxt(inputLabel: self.weightUnitLbl, mainStr: weightStr?.first ?? "", subStr: weightUnit,  mainFont: AppFont.medium.size(30.0, familyName: familyClashDisplay), subFont: AppFont.medium.size(25.0, familyName: familyClashDisplay))
        
        if let weightHealthFlow = healthStatsData?.healthData?.weight, !weightHealthFlow.isEmpty {
            weightUnitLbl.attributedText = setAttributedTxt(inputLabel: self.weightUnitLbl, mainStr: weightStr?.first ?? "", subStr: weightUnit,  mainFont: AppFont.medium.size(30.0, familyName: familyClashDisplay), subFont: AppFont.medium.size(25.0, familyName: familyClashDisplay))
        }else{
            weightUnitLbl.text = "NA"
        }
        
        if let userMealsCount = userMeals, userMealsCount.count < 0 || userMealsCount.isEmpty {
            self.UpcomingMealsMBV.isHidden = false
            self.upcomingMealsTitleLbl.text = "Diet & Nutrition"
            
        }else{
            self.dietMBV.isHidden = false
        }
        
        
        //------------------------************ Mystats FLOW
        self.activitiesCountLbl.text = healthStatsData?.healthOverview?.activities?.value
        self.caloriesCountLbl.text = healthStatsData?.healthOverview?.calories?.value
        self.execriseCountLbl.text = healthStatsData?.healthOverview?.exercise?.value
        self.showHealthDateBtn.setTitle(" " + (healthStatsData?.healthOverview?.month?.value ?? ""), for: .normal)

        if let bodyMassValue = healthStatsData?.bodyComposition?.bodyMass?.value, !bodyMassValue.isEmpty {
            showBodyMassBtn.isHidden = false
            bodyMassIndexUnitLbl.text = bodyMassValue
//            showBodyMassBtn.setTitle(healthStatsData?.bodyComposition?.bodyMassStatus, for: .normal)
            
            if let bodyMassStatus = healthStatsData?.bodyComposition?.bodyMassStatus, !bodyMassStatus.isEmpty {
                showBodyMassBtn.setTitle(bodyMassStatus, for: .normal)
            }else{
                self.showBodyMassBtn.isHidden = true
            }
            
        }else{
            showBodyMassBtn.isHidden = true
            bodyMassIndexUnitLbl.text = "NA"
            self.noDataBodyMassMBV.isHidden = false
        }
        
        if let bodyFatPercentage = healthStatsData?.bodyFat?.bodyFat?.value, !bodyFatPercentage.isEmpty {
            self.noFatDataMBV.isHidden = true
            self.fatsBodyPartsLstMBV.isHidden = false
            self.bodyFatPerMBV.isHidden = false
            self.showBodyFatBtn.isHidden = false
            
            bodyFatPerTitleLbl.text = "Body Fat Percentage" //bodyFatPercentage
            self.bodyFatPerLbl.text = bodyFatPercentage + "%"
//            showBodyFatBtn.setTitle(healthStatsData?.bodyFat?.bodyFatStatus, for: .normal)
            
            if let bodyFatStatus = healthStatsData?.bodyFat?.bodyFatStatus, !bodyFatStatus.isEmpty {
                self.showBodyFatBtn.setTitle(bodyFatStatus, for: .normal)
            }else{
                self.showBodyFatBtn.isHidden = true
            }
            
            self.fatsDataLst = [
                HydrationDataModel(subTitle: "Chest", qnty: healthStatsData?.bodyFat?.chest ?? ""),
                HydrationDataModel(subTitle: "Abdomen", qnty: healthStatsData?.bodyFat?.abdomen ?? ""),
                HydrationDataModel(subTitle: "Thigs", qnty: healthStatsData?.bodyFat?.thighs ?? ""),
                HydrationDataModel(subTitle: "Triceps", qnty: healthStatsData?.bodyFat?.triceps ?? ""),
                HydrationDataModel(subTitle: "Subscapular", qnty: healthStatsData?.bodyFat?.subscapular ?? ""),
                HydrationDataModel(subTitle: "Axilla", qnty: healthStatsData?.bodyFat?.axila ?? ""),
                HydrationDataModel(subTitle: "Subscapula", qnty: healthStatsData?.bodyFat?.subscapula ?? "")
            ]
            self.fatsBodyPartsTblView.reloadData()
            
        }else{
            self.noFatDataMBV.isHidden = false
            self.fatsBodyPartsLstMBV.isHidden = true
            self.showBodyFatBtn.isHidden = true
            self.bodyFatPerLbl.text = "NA"
            
            self.fatsDataLst?.removeAll()
            self.fatsBodyPartsTblView.reloadData()
        }
        
        if let waistHipRatio = healthStatsData?.waistHipRatio?.ratio, !waistHipRatio.isEmpty {
            self.showWaistHealthBtn.isHidden = false
            self.noDataWaistMBV.isHidden = true
            self.waistRatioLstMBV.isHidden = true
            
            self.waistHipRatioUnitLbl.text = waistHipRatio
//            self.showWaistHealthBtn.setTitle(healthStatsData?.waistHipRatio?.status, for: .normal)
            if let waistHipRatioStatus = healthStatsData?.waistHipRatio?.status, !waistHipRatioStatus.isEmpty {
                self.showWaistHealthBtn.setTitle(waistHipRatioStatus, for: .normal)
            }else{
                self.showWaistHealthBtn.isHidden = true
            }
            
            self.waistHipDataLst = [
                HydrationDataModel(subTitle: "Hip Circumference", qnty: healthStatsData?.waistHipRatio?.hip ?? ""),
                HydrationDataModel(subTitle: "Waist Circumference", qnty: healthStatsData?.waistHipRatio?.waist ?? ""),
            ]
            self.waistHipRatioTblView.reloadData()
            
        }else{
            self.showWaistHealthBtn.isHidden = true
            self.noDataWaistMBV.isHidden = false
            self.waistRatioLstMBV.isHidden = true
            self.waistHipRatioUnitLbl.text = "NA"
            self.waistHipDataLst?.removeAll()
            self.waistHipRatioTblView.reloadData()
        }
        
        let restingHeartRate = healthStatsData?.cardiovascular?.restingHeartRate ?? ""
        let maxHeartRate = healthStatsData?.cardiovascular?.maxHeartRate ?? ""
        let diastolicBp = healthStatsData?.cardiovascular?.diastolicBp ?? ""
        let systolicBp = healthStatsData?.cardiovascular?.systolicBp ?? ""
        
        if !restingHeartRate.isEmpty || !maxHeartRate.isEmpty || !diastolicBp.isEmpty || !systolicBp.isEmpty {
            self.cardiovascularNAMBV.isHidden = true
            self.noDataCardiovascularHealthMBV.isHidden = true
            self.cardiovascularHealthLstMBV.isHidden = false
            
            self.cardiovascularDataLst =
            [
                HydrationDataModel(subTitle: "Resting Heart Rate", qnty: restingHeartRate),
                HydrationDataModel(subTitle: "Maximum Heart Rate", qnty: maxHeartRate),
                HydrationDataModel(subTitle: "Diastolic Blood Pressure", qnty: diastolicBp),
                HydrationDataModel(subTitle: "Systolic Blood Pressure", qnty: systolicBp)
            ]
            
            self.cardiovascularTblView.reloadData()
            
        }else{
            self.cardiovascularNAMBV.isHidden = false
            self.noDataCardiovascularHealthMBV.isHidden = false
            self.cardiovascularHealthLstMBV.isHidden = true
            self.cardiovascularNALbl.text = "NA"
           
            self.cardiovascularDataLst?.removeAll()
            self.cardiovascularTblView.reloadData()
        }
                
        //--------------------********** Mystats physical measurement
        let myStatsheightStr = healthStatsData?.physicalMeasurement?.height?.components(separatedBy: " ")
        let myStatsheightUnit = ((myStatsheightStr?.count ?? 0) > 1 ? myStatsheightStr?.last ?? "" : "")
        
        let myStatsheight = setAttributedTxt(inputLabel: self.myStatsHeightUnitLbl, mainStr: myStatsheightStr?.first ?? "", subStr: myStatsheightUnit, mainFont: AppFont.medium.size(30.0, familyName: familyClashDisplay), subFont: AppFont.medium.size(25.0, familyName: familyClashDisplay))
        
        if let myStatsheightData = healthStatsData?.physicalMeasurement?.height, !myStatsheightData.isEmpty {
            myStatsHeightUnitLbl.attributedText = myStatsheight
        }else{
            myStatsHeightUnitLbl.text = "NA"
        }
//        heightUnitLbl.attributedText = myStatsheight
        
        let myStatsweightStr = healthStatsData?.physicalMeasurement?.weight?.components(separatedBy: " ")
        let myStatsweightUnit = ((myStatsweightStr?.count ?? 0) > 1 ? myStatsweightStr?.last ?? "" : "")
        
//        weightUnitLbl.attributedText = setAttributedTxt(inputLabel: self.weightUnitLbl, mainStr: myStatsweightStr?.first ?? "", subStr: myStatsweightUnit,  mainFont: AppFont.medium.size(30.0, familyName: familyClashDisplay), subFont: AppFont.medium.size(25.0, familyName: familyClashDisplay))
        
        if let myStatsweightData = healthStatsData?.physicalMeasurement?.weight, !myStatsweightData.isEmpty {
            myStatsWeightUnitLbl.attributedText = setAttributedTxt(inputLabel: self.myStatsWeightUnitLbl, mainStr: myStatsweightStr?.first ?? "", subStr: myStatsweightUnit,  mainFont: AppFont.medium.size(30.0, familyName: familyClashDisplay), subFont: AppFont.medium.size(25.0, familyName: familyClashDisplay))
        }else{
            myStatsWeightUnitLbl.text = "NA"
        }
        
        
//        self.UpcomingMealsMBV.isHidden = false
        
        //healthStatsData
//        self.fatsDataLst = [
//            HydrationDataModel(subTitle: "Chest", qnty: "15 mm"),
//            HydrationDataModel(subTitle: "Abdomen", qnty: "15 mm"),
//            HydrationDataModel(subTitle: "Thigs", qnty: "15 mm"),
//            HydrationDataModel(subTitle: "Triceps", qnty: "15 mm"),
//            HydrationDataModel(subTitle: "Subscapular", qnty: "15 mm"),
//            HydrationDataModel(subTitle: "Axilla", qnty: "15 mm"),
//            HydrationDataModel(subTitle: "Subscapula", qnty: "15 mm")
//        ]
        //        self.waistHipDataLst = [
        //            HydrationDataModel(subTitle: "Hip Circumference", qnty: "70cm"),
        //            HydrationDataModel(subTitle: "Waist Circumference", qnty: "90cm"),
        //        ]
        //        self.cardiovascularDataLst =
        //        [
        //            HydrationDataModel(subTitle: "Resting Heart Rate", qnty: "72 bmp"),
        //            HydrationDataModel(subTitle: "Maximum Heart Rate", qnty: "72 bmp"),
        //            HydrationDataModel(subTitle: "Diastolic Blood Pressure", qnty: "72 bmp"),
        //            HydrationDataModel(subTitle: "Systolic Blood Pressure", qnty: "72 bmp")
        //        ]
                
        //        self.cardiovascularDataLst =
        //        [
        //            HydrationDataModel(subTitle: "Resting Heart Rate", qnty: healthStatsData?.cardiovascular?.restingHeartRate ?? ""),
        //            HydrationDataModel(subTitle: "Maximum Heart Rate", qnty: healthStatsData?.cardiovascular?.maxHeartRate ?? ""),
        //            HydrationDataModel(subTitle: "Diastolic Blood Pressure", qnty: healthStatsData?.cardiovascular?.diastolicBp ?? ""),
        //            HydrationDataModel(subTitle: "Systolic Blood Pressure", qnty: healthStatsData?.cardiovascular?.systolicBp ?? "")
        //        ]
        //
        //        self.cardiovascularTblView.reloadData()
        
        //        let myStatsHeight1Part = setAttributedTxt(inputLabel: self.myStatsHeightUnitLbl, mainStr: "5", subStr: "ft")
        //        let myStatsHeight2Part = setAttributedTxt(inputLabel: self.myStatsHeightUnitLbl, mainStr: "7", subStr: "in")
        //
        //        let myStatsPhysicalMs = NSMutableAttributedString(attributedString: myStatsHeight1Part)
        //        myStatsPhysicalMs.append(myStatsHeight2Part)
        //
        //        myStatsHeightUnitLbl.attributedText = myStatsPhysicalMs
                
        //        myStatsWeightUnitLbl.attributedText = setAttributedTxt(inputLabel: self.myStatsWeightUnitLbl, mainStr: "58", subStr: "kg")
        
    }
    
    //MARK: -----------------MY STATS
    private func gaugeProgressV(){
        
        let outerProgerssGradient: [CGColor] = [
            UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 27.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 63.0/255.0, green: 40.0/255.0, blue: 14.0/255.0, alpha: 1.0).cgColor
        ]
        
        let container = GaugeContainerView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.clear
        activityProgressV.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: activityProgressV.leadingAnchor, constant: -30),
            container.trailingAnchor.constraint(equalTo: activityProgressV.trailingAnchor, constant: 30),
            container.bottomAnchor.constraint(equalTo: activityProgressV.bottomAnchor),
            container.heightAnchor.constraint(equalTo: activityProgressV.heightAnchor, multiplier: 1.1)
        ])
        
        container.gaugeThickness = 20.0
        container.progersColor = outerProgerssGradient
        activityProgressImgView.transform =  CGAffineTransform(rotationAngle: -CGFloat.pi / 4.5)  //CGAffineTransform(rotationAngle: -CGFloat.pi * 5 / 180)
    
        container.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 3)
        container.setGaugeProgress(0.4)
            
        
//        var progressInPercents = 0.1
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//          
//            if progressInPercents >= 1.0 {
//                timer.invalidate()
//                self.timer = nil
//            }
//            
//            progressInPercents = progressInPercents + 0.2
//            container.setGaugeProgress(progressInPercents)
//        }
        
        //-----------------********* Calories progress view setup
        let caloriesProgV = GaugeContainerView()
        caloriesProgV.translatesAutoresizingMaskIntoConstraints = false
        caloriesProgV.backgroundColor = UIColor.clear
        caloriesProgressV.addSubview(caloriesProgV)
        
        caloriesProgV.showTicks = true

        NSLayoutConstraint.activate([
            caloriesProgV.leadingAnchor.constraint(equalTo: caloriesProgressV.leadingAnchor, constant: -30),
            caloriesProgV.trailingAnchor.constraint(equalTo: caloriesProgressV.trailingAnchor, constant: 30),
            caloriesProgV.bottomAnchor.constraint(equalTo: caloriesProgressV.bottomAnchor),
            caloriesProgV.heightAnchor.constraint(equalTo: caloriesProgressV.heightAnchor, multiplier: 1.1)
        ])
        
        caloriesProgV.gaugeThickness = 20.0
        caloriesProgV.progersColor = outerProgerssGradient
        caloriesProgV.transform =  CGAffineTransform(rotationAngle: -CGFloat.pi / 4.5) //CGAffineTransform(rotationAngle: -CGFloat.pi / 3)
        caloriesProgV.setGaugeProgress(0.4)
        
//        var progressInPercents2 = 0.1
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//          
//            if progressInPercents2 >= 1.0 {
//                timer.invalidate()
//                self.timer = nil
//            }
//            
//            progressInPercents2 = progressInPercents2 + 0.2
//            caloriesProgV.setGaugeProgress(progressInPercents)
//        }
        
        //-----------------********* exercise progress view setup
        let exerciseProgV = GaugeContainerView()
        exerciseProgV.translatesAutoresizingMaskIntoConstraints = false
        exerciseProgV.backgroundColor = UIColor.clear
        exerciseProgressV.addSubview(exerciseProgV)

        NSLayoutConstraint.activate([
            exerciseProgV.leadingAnchor.constraint(equalTo: exerciseProgressV.leadingAnchor, constant: -30),
            exerciseProgV.trailingAnchor.constraint(equalTo: exerciseProgressV.trailingAnchor, constant: 30),
            exerciseProgV.bottomAnchor.constraint(equalTo: exerciseProgressV.bottomAnchor),
            exerciseProgV.heightAnchor.constraint(equalTo: exerciseProgressV.heightAnchor, multiplier: 1.1)
        ])

        exerciseProgV.gaugeThickness = 20.0
        exerciseProgV.progersColor = outerProgerssGradient
        exerciseProgV.transform =  CGAffineTransform(rotationAngle: -CGFloat.pi / 4.5) //CGAffineTransform(rotationAngle: -CGFloat.pi / 3)
        exerciseProgressImgView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 50 / 180)
        exerciseProgV.setGaugeProgress(0.4)
        
//        var progressInPercents3 = 0.1
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//          
//            if progressInPercents3 >= 1.0 {
//                timer.invalidate()
//                self.timer = nil
//            }
//            
//            progressInPercents3 = progressInPercents3 + 0.2
//            exerciseProgV.setGaugeProgress(progressInPercents)
//        }
    }
        
    private func registerCell(){
        clientDataCollView.register(UINib(nibName: "ClientDataCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ClientDataCollectionViewCell")
        dietCollView.register(UINib(nibName: "UpcomingMealsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingMealsCollectionViewCell")
        fitnessTblView.register(UINib(nibName: "FitnessResourcesTableViewCell", bundle: nil), forCellReuseIdentifier: "FitnessResourcesTableViewCell")
        
        self.cardiovascularTblView.register(UINib(nibName: "HydrationDataInnerTableViewCell", bundle: nil), forCellReuseIdentifier: "HydrationDataInnerTableViewCell")
        self.fatsBodyPartsTblView.register(UINib(nibName: "HydrationDataInnerTableViewCell", bundle: nil), forCellReuseIdentifier: "HydrationDataInnerTableViewCell")
        self.waistHipRatioTblView.register(UINib(nibName: "HydrationDataInnerTableViewCell", bundle: nil), forCellReuseIdentifier: "HydrationDataInnerTableViewCell")
    }
    
    enum healthBtnTag: Int {
    case health = 1201, myStats, moreDiet, moreUpcoming, moreFitness
    }
    
    @IBAction func commonHealthBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case healthBtnTag.health.rawValue:
            print("health btn clicked")
            self.setSegBtn(isHealth: true)
        case healthBtnTag.myStats.rawValue:
            print("myStats btn clicked")
            self.setSegBtn(isHealth: false)
        case healthBtnTag.moreDiet.rawValue:
            print("moreDiet btn clicked")
        case healthBtnTag.moreUpcoming.rawValue:
            print("moreUpcoming btn clicked")
        case healthBtnTag.moreFitness.rawValue:
            print("moreFitness btn clicked")
        default:
            print("None.......")
            break
        }
    }
    
    
    private func setSegBtn(isHealth:Bool){
        if isHealth {
            self.healthStatsApi(typeStr: "1")
            self.getResourceApi()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            todayString = formatter.string(from: Date())
            self.getUserMealsApi(todayDateStr: todayString)
            
            self.healthBtn.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: {[weak self] in
                guard self != nil else {
                    return
                }
            })
            
            //------------------------- Health Animation
//            self.healthDataMStck.isHidden = false
            self.healthDataMStck.applyTransition(type: .moveIn, subtype: .fromTop, duration: 0.7, timingFunction: .easeInEaseOut, completion: {[weak self] in
                guard self != nil else {
                    return
                }
                self?.myStatsMStck.isHidden = true
            })
            
            self.myStatsMStck.applyTransition(type: .moveIn, subtype: .fromLeft, duration: 0.3, timingFunction: .easeInEaseOut, completion: {[weak self] in
                guard self != nil else {
                    return
                }
                self?.healthDataMStck.isHidden = false
                self?.myStatsMStck.isHidden = true
            })
            
            self.healthBtn.backgroundColor = UIColor.appWhite
            self.myStatsBtn.backgroundColor = UIColor.clear
            self.healthBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.myStatsBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
        else{
            self.healthStatsApi(typeStr: "2")
            self.myStatsBtn.applyTransition(type: .moveIn, subtype: .fromLeft, duration: 0.8, timingFunction: .easeInEaseOut, completion: {[weak self] in
                guard self != nil else {
                    return
                }
//                self?.gaugeViewSet()
            })
            
        //---------------------------- MyStats Animation
            self.myStatsMStck.isHidden = false
            self.myStatsMStck.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.7, timingFunction: .easeInEaseOut, completion: {[weak self] in
                guard self != nil else {
                    return
                }
                self?.gaugeProgressV()
                self?.healthDataMStck.isHidden = true
            })
            
            self.healthDataMStck.applyTransition(type: .moveIn, subtype: .fromBottom, duration: 0.5, timingFunction: .easeInEaseOut, completion: {[weak self] in
                guard self != nil else {
                    return
                }
                self?.myStatsMStck.isHidden = false
                self?.healthDataMStck.isHidden = true
            })
            
            self.healthBtn.backgroundColor = UIColor.clear
            self.myStatsBtn.backgroundColor = UIColor.appWhite
            self.myStatsBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.healthBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
//            self.gaugeViewSet()
        }
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            [
                self.fatsBodyPartsLstMBV,
                self.waistRatioLstMBV,
                self.cardiovascularHealthLstMBV,
                self.noDataBodyMassMBV,
                self.noFatDataMBV,
                self.noDataWaistMBV,
                self.noDataCardiovascularHealthMBV
            ].forEach({[weak self] in
                guard self != nil else {
                    return
                }
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
            
            [
                self.heightMBV,
                self.weightMBV,
                self.myStatsheightMBV,
                self.myStatsWeightMBV,
                self.activitySubView,
                self.caloriesSubView,
                self.execriseSubView,
                self.bodyCompositionDetailsMBV,
                self.bodyFatPerDetailsMBV,
                self.waistHipRatioDetailsMBV,
                self.cardiovascularHealthDetailsMBV
            ].forEach({[weak self] in
                guard self != nil else {
                    return
                }
                $0?.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.7), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
            })
            
            self.showGoalBtn.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
                                    
            self.motivationLineV.backgroundColor = UIColor.clear
            self.motivationLineV.addGradient(colors: UIColor.appMultiColor(.lineVGradient2), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            
            self.topSegMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)
            DispatchQueue.main.async {
                self.topSegMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
                self.healthBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
                self.myStatsBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            }
            
            [
                self.showBodyFatBtn,
                self.showBodyMassBtn,
                self.showWaistHealthBtn
            ].forEach({[weak self] in
                guard self != nil else {
                    return
                }
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: ($0?.frame.size.height ?? 4)/2.0)
            })
            
            self.showHealthDateBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            
            //---------------------- Gradient
            self.showBodyMassBtn.addGradient(colors: [UIColor(red: 244.0/255.0, green: 178.0/255.0, blue: 51.0/255.0, alpha: 1.0), UIColor(red: 110.0/255.0, green: 81.0/255.0, blue: 23.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 0), cornerRadius: self.showBodyMassBtn.frame.size.height/2.0)
            self.showBodyFatBtn.addGradient(colors: [UIColor(red: 51.0/255.0, green: 244.0/255.0, blue: 73.0/255.0, alpha: 1.0), UIColor(red: 26.0/255.0, green: 110.0/255.0, blue: 23.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 0), cornerRadius: self.showBodyFatBtn.frame.size.height/2.0)
            self.showWaistHealthBtn.addGradient(colors: [UIColor(red: 51.0/255.0, green: 244.0/255.0, blue: 73.0/255.0, alpha: 1.0), UIColor(red: 26.0/255.0, green: 110.0/255.0, blue: 23.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 0), cornerRadius: self.showWaistHealthBtn.frame.size.height/2.0)
        }
    }
    
    private func setupFont(){
        
        [
            bodyMassNoDataDescLbl,
            fatPerNoDataDescLbl,
            waistHipRatioNoDataDescLbl,
            cardiovascularNADescLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        })
        
        [
            showHealthDateBtn.titleLabel,
            showBodyFatBtn.titleLabel,
            showBodyMassBtn.titleLabel,
            showWaistHealthBtn.titleLabel,
            activitiesTitleLbl,
            caloriesTitleLbl,
            execriseTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font =  AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        [
            activitiesCountLbl,
            caloriesCountLbl,
            execriseCountLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.medium.size(30, familyName: familyClashDisplay)
            $0?.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
        })
        
//        $0.attributedText = $0.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: 0.bounds, font: AppFont.medium.size(12.0, familyName: familyClashDisplay))
        
        //onwardsStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: self.onwardsLbl.bounds, font: AppFont.medium.size(12.0, familyName: familyClashDisplay))
        
        ////            $0?.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
        
        [
            bodyMassIndexUnitLbl,
            bodyFatPerLbl,
            waistHipRatioUnitLbl,
            cardiovascularNALbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.medium.size(48, familyName: familyClashDisplay)
            $0?.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
        })
        
//        bodyMassIndexUnitLbl.attributedText = makeGradientLbl(inputLabel: bodyMassIndexUnitLbl, mainStr: "17.3", subStr: "")
        
        [
            healthBtn.titleLabel,
            myStatsBtn.titleLabel,
            fuelBodyNutritionDescLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
    
        [
            heightTitleLbl,
            weightTitleLbl,
            myStatsHeightTitleLbl,
            myStatsWeightTitleLbl,
            clientDataTitleLbl,
            specificGoalTitleLbl,
            dietTitleLbl,
            upcomingMealsTitleLbl,
            fitnessResourceTitleLbl,
            healthOverTitleLbl,
            physicalMeasurementTitleLbl,
            bodyCompositionTitleLbl,
            cardiovascularHealthTitleLbl,
            bodyMassIndexLbl,
            bodyFatPerTitleLbl,
            waistHipRatioTitleLbl,
            cardiovascularHealthTitleLbl,
            cardiovascularHealthSubTitleLbl
            
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
                
        self.showGoalBtn.titleLabel?.font = AppFont.medium.size(18.0, familyName: familyClashDisplay)
        fuelBodyNutritionLbl.font = AppFont.medium.size(24, familyName: familyClashDisplay)
        motivationQuotesLbl.font = AppFont.medium.size(24, familyName: familyClashDisplay)
        writerLbl.font = AppFont.regular.size(12, familyName: familyClashDisplay)
        
        /*
        let firstPart = setAttributedTxt(inputLabel: self.heightUnitLbl, mainStr: "5", subStr: "ft")
        let secondPart = setAttributedTxt(inputLabel: self.heightUnitLbl, mainStr: "7", subStr: "in")

        let combined = NSMutableAttributedString(attributedString: firstPart)
        combined.append(secondPart)

        heightUnitLbl.attributedText = combined
        
        weightUnitLbl.attributedText = setAttributedTxt(inputLabel: self.weightUnitLbl, mainStr: "58", subStr: "kg")
        
        //--------------------********** Mystats physical measurement
        let myStatsHeight1Part = setAttributedTxt(inputLabel: self.myStatsHeightUnitLbl, mainStr: "5", subStr: "ft")
        let myStatsHeight2Part = setAttributedTxt(inputLabel: self.myStatsHeightUnitLbl, mainStr: "7", subStr: "in")

        let myStatsPhysicalMs = NSMutableAttributedString(attributedString: myStatsHeight1Part)
        myStatsPhysicalMs.append(myStatsHeight2Part)

        myStatsHeightUnitLbl.attributedText = myStatsPhysicalMs
        
        myStatsWeightUnitLbl.attributedText = setAttributedTxt(inputLabel: self.myStatsWeightUnitLbl, mainStr: "58", subStr: "kg")
        */
    }
    
    private func setAttributedTxt(inputLabel:UILabel, mainStr: String, subStr: String, mainFont: UIFont? = AppFont.medium.size(48.0, familyName: familyClashDisplay), subFont: UIFont? = AppFont.medium.size(30.0, familyName: familyClashDisplay)) -> NSAttributedString{
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: mainFont ?? UIFont(),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            mainStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: inputLabel.bounds, font: subFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.4, y: 0.9)),
            subStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: inputLabel.bounds, font: subFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.4, y: 0.9))
        ] as [AttributedStringComponent]
        
        // subStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: inputLabel.bounds, font: subFont ?? UIFont(), startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0))
                
        return NSAttributedString(from: makeAttributes, defaultAttributes: defaultAttributes) ?? NSAttributedString()
    }
    
    private func makeGradientLbl(inputLabel:UILabel, mainStr: String, fontMain:UIFont? = AppFont.medium.size(48.0, familyName: familyClashDisplay), subStr: String, fontSub:UIFont? = AppFont.medium.size(30.0, familyName: familyClashDisplay)) -> NSAttributedString{
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: fontMain ?? AppFont.medium.size(48.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            mainStr,
            subStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: inputLabel.bounds, font: fontSub ?? AppFont.medium.size(30.0, familyName: familyClashDisplay), startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0))
        ] as [AttributedStringComponent]
                
        return NSAttributedString(from: makeAttributes, defaultAttributes: defaultAttributes) ?? NSAttributedString()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if fitnessTblView.contentSize.height != 0 {
            self.fitnessResourceMBV.isHidden = false
            self.fitnessTblViewHeightConstrrnt.constant = fitnessTblView.contentSize.height
        }else{
            self.fitnessResourceMBV.isHidden = true
            self.fitnessTblViewHeightConstrrnt.constant = 1 //350
        }
        
        if cardiovascularTblView.contentSize.height != 0 {
            self.cardiovascularTblViewHeightConstrnt.constant = cardiovascularTblView.contentSize.height
        }
        
        if fatsBodyPartsTblView.contentSize.height != 0 {
            self.fatsBodyPartsTblViewHeightConstrnt.constant = fatsBodyPartsTblView.contentSize.height
        }
       
        if waistHipRatioTblView.contentSize.height != 0 {
            self.waistHipRatioTblViewHeightConstrnt.constant = waistHipRatioTblView.contentSize.height
        }
        
        view.layoutIfNeeded()
    }
    
  }


extension HealthDataViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dietCollView {
            return collectionView.numberOfRows(count: self.userMeals?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 50, height: 50)), messageImageHeight: 50, fromTop: 1)
        }else if collectionView == clientDataCollView{
            return 2
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == dietCollView {
            let dietCell: UpcomingMealsCollectionViewCell = dietCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingMealsCollectionViewCell", for: indexPath) as! UpcomingMealsCollectionViewCell
            DispatchQueue.main.async {
                dietCell.setGradientMultiBorder(cornerRadius: 24.0, width: 1.5, colors: [UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), UIColor(red: 135.0/255.0, green: 143.0/255.0, blue: 160.0/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            }
            
            dietCell.mealTypeImgViewHeightConstrnt.constant = 10.0
            dietCell.likeBtnTopconstrnt.constant = 1.0
            dietCell.mealTypeImgview.isHidden = true
            dietCell.mealsTypeTitleLbl.isHidden = true
            dietCell.setHealthCellData(data: self.userMeals?[indexPath.row])
          
            dietCell.shareBtn.accessibilityHint = self.userMeals?[indexPath.row].id?.value
            dietCell.shareBtn.addTarget(self, action: #selector(dietShareBtnActn(sender: )), for: .touchUpInside)
            dietCell.likeBtn.accessibilityHint = self.userMeals?[indexPath.row].id?.value
            dietCell.likeBtn.addTarget(self, action: #selector(dietLikeBtnActn(sender: )), for: .touchUpInside)
            
            return dietCell
        }else if collectionView == clientDataCollView{
            let dataCell: ClientDataCollectionViewCell = clientDataCollView.dequeueReusableCell(withReuseIdentifier: "ClientDataCollectionViewCell", for: indexPath) as! ClientDataCollectionViewCell
            dataCell.clientDataProgressMBV.isHidden = false
            dataCell.noDataMBV.isHidden = true
            dataCell.clientDataProgressMBV.isHidden = true
            
            if indexPath.row == 0 {
                dataCell.topTitleBtn.setTitle("CHOLESTEROL", for: .normal)
                if let cholesterolValue = healthStatsData?.cardioInsights?.cholesterol?.value{
                    
                    dataCell.unitLbl.attributedText = makeAttrGradientTxt(inputLabel: dataCell.unitLbl, mainStr: cholesterolValue, subStr: "mg/dL")
                    dataCell.clientDataProgressMBV.isHidden = false
                    
                    let value = Double(cholesterolValue) ?? 0.0
                    let percentage = (value * 100.0) / 240.0
                    let cholesterolRatio = Double(round(10 * percentage) / 10)
                    
//                    //--------------
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dataCell.progressVSet(progressValue: cholesterolRatio, progressTitle: "DESIRABLE", progressTitleColor: UIColor(red: 161.0/255.0, green: 221.0/255.0, blue: 112.0/255.0, alpha: 1.0), progressColor: [
                            UIColor(red: 63.0/255.0, green: 216.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor,
                            UIColor(red: 167.0/255.0, green: 224.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor,
                            UIColor(red: 250.0/255.0, green: 206.0/255.0, blue: 52.0/255.0, alpha: 1.0).cgColor,
                            UIColor(red: 255.0/255.0, green: 85.0/255.0, blue: 99.0/255.0, alpha: 1.0).cgColor
                        ])
                    }
                    //rgba(161, 221, 112, 1)
                        
                }else{
                    dataCell.noDataMBV.isHidden = false
                    dataCell.unitLbl.text = "NA"
                    
                    //--------------
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        
//                        dataCell.progressVSet(progressValue: 0.7, progressTitle: "DESIRABLE", progressTitleColor: UIColor(red: 161.0/255.0, green: 221.0/255.0, blue: 112.0/255.0, alpha: 1.0), progressColor: [
//                            UIColor(red: 63.0/255.0, green: 216.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor,
//                            UIColor(red: 167.0/255.0, green: 224.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor,
//                            UIColor(red: 250.0/255.0, green: 206.0/255.0, blue: 52.0/255.0, alpha: 1.0).cgColor,
//                            UIColor(red: 255.0/255.0, green: 85.0/255.0, blue: 99.0/255.0, alpha: 1.0).cgColor
//                        ])
//                    }
                }
            }else{
                dataCell.topTitleBtn.setTitle("HDL", for: .normal)
                if let hdlValue = healthStatsData?.cardioInsights?.hdl?.value{
//                    dataCell.unitLbl.text = hdlValue + "mg/dL"
                    dataCell.unitLbl.attributedText = makeAttrGradientTxt(inputLabel: dataCell.unitLbl, mainStr: hdlValue, subStr: "mg/dL")
                    
                    //makeAttrGradientTxt
                    dataCell.clientDataProgressMBV.isHidden = false
                    
                    //---------------******
                    
                    let hdlValue = Double(hdlValue) ?? 0.0
                    let hdlPerceent = (hdlValue * 100.0) / 100
                    let hdlRaio = Double(round(10 * hdlPerceent) / 10)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dataCell.progressVSet(progressValue: hdlRaio, progressTitle: "BIT HIGH", progressTitleColor: UIColor(red: 255.0/255.0, green: 198.0/255.0, blue: 6.0/255.0, alpha: 1.0), progressColor: [
                            UIColor(red: 229.0/255.0, green: 184.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor,
                            UIColor(red: 229.0/255.0, green: 184.0/255.0, blue: 25.0/255.0, alpha: 1.0).cgColor
                        ])
                    }
                    
                }else{
                    dataCell.noDataMBV.isHidden = false
                    dataCell.unitLbl.text = "NA"
                }
            }

            
            return dataCell
        }
       
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         if collectionView == dietCollView{
            return CGSize(width: collectionView.frame.width*0.75, height: collectionView.frame.height)
         }else{
             return CGSize(width: collectionView.frame.width*0.43, height: collectionView.frame.height)
         }
    }
    
    @objc func dietLikeBtnActn(sender: UIButton){
        print("like sender", sender.accessibilityHint as Any)
        if let likeBtnId = sender.accessibilityHint {
            if let indx = self.userMeals?.firstIndex(where: {$0.id?.value == likeBtnId}){
                let getMealData = self.userMeals?[indx]
                print("getMealData: ", getMealData as Any)
                print("getMealData id: ", getMealData?.id as Any)
                self.mealLikeApi(inputMealId: getMealData?.id?.value)
            }
        }
    }
    
    @objc func dietShareBtnActn(sender: UIButton){
        print("share sender", sender.accessibilityHint as Any)
        if let likeBtnId = sender.accessibilityHint {
            if let indx = self.userMeals?.firstIndex(where: {$0.id?.value == likeBtnId}){
                let shareMealsDetails = self.userMeals?[indx]
                print("share shareMealsData: ", shareMealsDetails as Any)
                print("share shareMealsData id: ", shareMealsDetails?.id?.value as Any)
                
                let getBaseUrl:String = AppBaseUrl.baseScheme.rawValue + "://" + (isTesting ? AppBaseUrl.baseDevUrl.rawValue : AppBaseUrl.baseProductionUrl.rawValue)
                print(getBaseUrl)

                // let urlString = "https://mobileapp.mypt-me.com/\(self.inputType ?? "")/\(studioDetails?.id ?? 0)/\(gymDetailsFlow)"
                
                let urlString = "\(getBaseUrl)/\("health")/\(shareMealsDetails?.id?.value ?? "0")/\("healthProfile")"
                Utility.shared.shareSocial(viewController: self, textToShare: shareMealsDetails?.mealName ?? "", imageToShare: nil, urlShareStr: urlString)
                
                
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
    }
    
    private func makeAttrGradientTxt(inputLabel:UILabel, mainStr: String, subStr: String, mainFont: UIFont? = AppFont.semibold.size(20.0, familyName: familyClashDisplay), subFont: UIFont? = AppFont.regular.size(12.0, familyName: familyClashDisplay), mainStrColor: [UIColor]? = [UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], subStrColor: UIColor? = UIColor.appWhite) -> NSAttributedString{
        //-------------------- Attributed Text for Price
        let subAttr = [
            .font: subFont ?? UIFont(),
            .foregroundColor: subStrColor!
        ] as [NSAttributedString.Key : Any]
                
        let makeAttributes = [
            mainStr.attributedStringWithGradient(mainStrColor!, frame: inputLabel.bounds, font: mainFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.5, y: 0.8)),
            subStr
        ] as [AttributedStringComponent]
                
        return NSAttributedString(from: makeAttributes, defaultAttributes: subAttr) ?? NSAttributedString()
    }
        
}

extension HealthDataViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
               
        if tableView == fitnessTblView {
            return tableView.numberOfRows(count: self.resourceList?.count ?? 0, title: "No Fitness Resources found!", message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 150, height: 150)), messageImageHeight: 150.0, reloadBtnBgColor: UIColor.appWhite , fromTop: 10)
        }else if tableView == cardiovascularTblView{
            return cardiovascularDataLst?.count ?? 0
        }else if tableView == fatsBodyPartsTblView{
            return fatsDataLst?.count ?? 0
        }else if tableView == waistHipRatioTblView{
            
            return waistHipDataLst?.count ?? 0
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if tableView == fitnessTblView {
            let fitnessCell: FitnessResourcesTableViewCell = fitnessTblView.dequeueReusableCell(withIdentifier: "FitnessResourcesTableViewCell", for: indexPath) as! FitnessResourcesTableViewCell
            fitnessCell.setupCell(data: self.resourceList?[indexPath.row])
            
            return fitnessCell
        }else if tableView == cardiovascularTblView{
            let cardioCell:HydrationDataInnerTableViewCell = cardiovascularTblView.dequeueReusableCell(withIdentifier: "HydrationDataInnerTableViewCell", for: indexPath) as! HydrationDataInnerTableViewCell
            
            cardioCell.lineVLbl.isHidden = false
            
            cardioCell.subTitleLbl.text = cardiovascularDataLst?[indexPath.row].subTitle as? String
            cardioCell.qntyBtn.setTitle(cardiovascularDataLst?[indexPath.row].qnty as? String, for: .normal)
            
//            if sectionInnerData?.title.uppercased() == "Settings".uppercased() {
//                cardioCell.qntyBtn.setImage(AppImages.forward, for: .normal)
//                cell.qntyBtn.tag = 101 + indexPath.row
//                cell.qntyBtn.accessibilityHint = innerData?[indexPath.row].subTitle as? String
//                cell.qntyBtn.addTarget(self, action: #selector(settingsBtnActn(sender: )), for: .touchUpInside)
//            }else{
                cardioCell.qntyBtn.setImage(nil, for: .normal)
//            }
            
            cardioCell.qntyBtn.setImage(nil, for: .normal)
            if tableView.isLastRow() == indexPath.row {
                cardioCell.lineVLbl.isHidden = true
            }
            
            return cardioCell
        }else if tableView == fatsBodyPartsTblView{
            let fatsBodyCell:HydrationDataInnerTableViewCell = fatsBodyPartsTblView.dequeueReusableCell(withIdentifier: "HydrationDataInnerTableViewCell", for: indexPath) as! HydrationDataInnerTableViewCell
            fatsBodyCell.lineVLbl.isHidden = false
            fatsBodyCell.qntyBtn.setImage(nil, for: .normal)
            fatsBodyCell.qntyBtn.setImage(nil, for: .normal)
            
            fatsBodyCell.subTitleLbl.text = fatsDataLst?[indexPath.row].subTitle as? String
            fatsBodyCell.qntyBtn.setTitle(fatsDataLst?[indexPath.row].qnty as? String, for: .normal)
            
            if tableView.isLastRow() == indexPath.row {
                fatsBodyCell.lineVLbl.isHidden = true
            }
            
            return fatsBodyCell
        }else if tableView == waistHipRatioTblView{
            let waistHipCell:HydrationDataInnerTableViewCell = waistHipRatioTblView.dequeueReusableCell(withIdentifier: "HydrationDataInnerTableViewCell", for: indexPath) as! HydrationDataInnerTableViewCell
            
            waistHipCell.lineVLbl.isHidden = false
            waistHipCell.qntyBtn.setImage(nil, for: .normal)
            waistHipCell.qntyBtn.setImage(nil, for: .normal)
            
            waistHipCell.subTitleLbl.text = waistHipDataLst?[indexPath.row].subTitle as? String
            waistHipCell.qntyBtn.setTitle(waistHipDataLst?[indexPath.row].qnty as? String, for: .normal)
            
            
            if tableView.isLastRow() == indexPath.row {
                waistHipCell.lineVLbl.isHidden = true
            }
            
            return waistHipCell
        }
        else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == fitnessTblView {
            let vc: ResourceDetailsViewController = ResourceDetailsViewController.instantiate(appStoryboard: .dashboard)
            vc.resourceData = self.resourceList?[indexPath.row]
            vc.inputShreId = self.resourceList?[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        }else if tableView == cardiovascularTblView{
            print("cardiovascularTblView")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}


extension HealthDataViewController {
    private func healthStatsApi(typeStr: String?){
        ProfileVM.healthStatsApi(inputType: typeStr, completion: {[weak self] getResultData in
            
            guard let self = self, let getResultData = getResultData else { return  }
            
            print("getResultData", getResultData)
            if getResultData.status == true {
                self.healthStatsData = getResultData.data
                print("self.healthStatsData", self.healthStatsData as Any)
                self.inputData()
            }
            
        })
    }
    
    private func getResourceApi(){
        UpcomingClassVM.getResourcesApi(inputParams: nil, completion: {[weak self] getResaultData in
            guard let self = self, let getResaultData = getResaultData else { return }
           
            self.fitnessTblView.isHidden = false
            self.resourceList?.removeAll()
            self.resourceList?.append(contentsOf: getResaultData.data ?? [])
            self.fitnessTblView.reloadData()
            
//            if let _ = self.self.resourceList {
//                self.fitnessTblView.reloadData()
//            }
        })
    }
    
    private func getUserMealsApi(todayDateStr: String?){
        //date: 2025-05-22
        UpcomingClassVM.getuserMealsApi(inputDate: todayDateStr, completion: {
            [weak self] getResaultData in
            guard let self = self, let getResaultData = getResaultData else { return }
            self.dietCollView.isHidden = false
           
            if getResaultData.status == true {
                self.userMeals?.removeAll()
                self.userMeals?.append(contentsOf: getResaultData.data ?? [])
                self.dietCollView.reloadData()
                
                if let userMealsCount = self.userMeals, userMealsCount.count < 0 || userMealsCount.isEmpty {
                    self.UpcomingMealsMBV.isHidden = false
                    self.upcomingMealsTitleLbl.text = "Diet & Nutrition"
                    
                }else{
                    self.dietMBV.isHidden = false
                }
                
                
//                if let mealsCount = self.userMeals, mealsCount.count > 0 {
//                    self.dietCollView.reloadData()
//                }
            }
        })
    }
    
    private func mealLikeApi(inputMealId: String?){
        UpcomingClassVM.mealFavoriteApi(inputMealId: inputMealId, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            if let statusLike = getResultData["status"] as? Bool, statusLike {
                self.getUserMealsApi(todayDateStr: self.todayString)
            }
        })
    }
}
