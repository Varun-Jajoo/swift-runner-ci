//
//  SessionCompleteViewController.swift
//  MyPT
//
//  Created by techsaga corp on 14/01/25.
//

import UIKit

class SessionCompleteViewController: CommonViewController {
    
    //MARK: -------------- VARIABLE
    var completeWorkoutData: CompleteWorkoutDataModel?
    
    //MARK: --------------IBOUTLET
    //    @IBOutlet weak var polygonChartMBV: PolygonChartView!
    @IBOutlet weak var myScoreGraphMBV: UIView!
    @IBOutlet weak var detailsMBV: UIView!
    @IBOutlet weak var scoretitleLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var noteMBV: UIView!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFont()
        self.setIputData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupUI()
        /*  only testing
         self.initPolygonChartView()
         */
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
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.session_Summary], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("continue btn actn..")
        let vc:SessionStatusViewController = SessionStatusViewController.instantiate(appStoryboard: .library)
        vc.sessionIdStr = self.completeWorkoutData?.sessionID?.value
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func setIputData(){
        scoreLbl.text = ""
        if let ptScore = completeWorkoutData?.ptScore?.value {
            let ptScrValue = String(format: "%.2f", Double(ptScore) ?? 0.0)
            self.scoreLbl.attributedText = gradientAttr(labl: self.scoreLbl, txtStr: ptScrValue)
        }
        
        self.chartUI()
    }
    
    private func gradientAttr(labl: UILabel, txtStr: String, inputFont: UIFont? = AppFont.semibold.size(80.0, familyName: familyClashDisplay)) -> NSAttributedString {
        let attStr = txtStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: labl.bounds, font: inputFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
        
        return attStr
    }
    
    private func chartUI(){
        
        let radarChart = RadarChartView()
        //        radarChart.data = [
        //            RadarData(label: "Calories", value: 1.0),
        //            RadarData(label: "Steps ", value: 0.6),
        //            RadarData(label: "Routine adherence ", value: 0.95),
        //            RadarData(label: "Exercises Completed ", value: 0.6),
        //            RadarData(label: "Duration", value: 0.75),
        //            RadarData(label: "Heart zone", value: 0.6)
        //        ]
        
        var caloriesValue = (Double(completeWorkoutData?.workoutData?.calories?.value ?? "0.2") ?? 20.0)/100.0
        var stepsValue = (Double(completeWorkoutData?.workoutData?.steps?.value ?? "0.2") ?? 20.0)/100.0
        var routineValue = (Double(completeWorkoutData?.workoutData?.routine?.value ?? "0.2") ?? 20.0)/100.0
        var exercisesCompleteValue = (Double(completeWorkoutData?.workoutData?.minuteDuration?.value ?? "0.2") ?? 20.0)/100.0
        var durationValue = (Double(completeWorkoutData?.workoutData?.durationScore?.value ?? "0.2") ?? 20.0)/100.0
        var heartZoneValue = (Double(completeWorkoutData?.workoutData?.heartZone?.value ?? "0.2") ?? 20.0)/100.0
        
        caloriesValue = caloriesValue > 1.0 ? 1.0 : caloriesValue
        stepsValue = stepsValue > 1.0 ? 1.0 : stepsValue
        routineValue = routineValue > 1.0 ? 1.0 : routineValue
        exercisesCompleteValue = exercisesCompleteValue > 1.0 ? 1.0 : exercisesCompleteValue
        durationValue = durationValue > 1.0 ? 1.0 : durationValue
        heartZoneValue = heartZoneValue > 1.0 ? 1.0 : heartZoneValue
        
        radarChart.data = [
            RadarData(label: "Calories", value: caloriesValue),
            RadarData(label: "Steps ", value: stepsValue),
            RadarData(label: "Routine adherence ", value: routineValue),
            RadarData(label: "Exercises Completed ", value: exercisesCompleteValue),
            RadarData(label: "Duration", value: durationValue),
            RadarData(label: "Heart zone", value: heartZoneValue)
        ]
        
        //rgba(161, 221, 112, 1)
        radarChart.datasetFillColor = UIColor(red: 161.0/255.0, green: 221.0/255.0, blue: 112.0/255.0, alpha: 0.3) //UIColor.appGreen.withAlphaComponent(0.3)
        radarChart.datasetStrokeColor = UIColor(red: 161.0/255.0, green: 221.0/255.0, blue: 112.0/255.0, alpha: 1.0)  //UIColor.appGreen.withAlphaComponent(0.7)
        radarChart.gridColor = UIColor.white.withAlphaComponent(0.15)
        radarChart.labelColor = UIColor.white.withAlphaComponent(0.8)
        radarChart.numberOfGridPolygons = 4
        radarChart.centerStarFillColor = UIColor.mainBg
        radarChart.backgroundColor = UIColor.mainBg
        myScoreGraphMBV.addSubview(radarChart)
        radarChart.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            radarChart.widthAnchor.constraint(equalToConstant: self.myScoreGraphMBV.frame.size.width),
            radarChart.heightAnchor.constraint(equalToConstant: self.myScoreGraphMBV.frame.size.width),
            radarChart.centerXAnchor.constraint(equalTo: myScoreGraphMBV.centerXAnchor),
            radarChart.centerYAnchor.constraint(equalTo: myScoreGraphMBV.centerYAnchor)
        ])
        
        /*
         let radarChart = RadarChartView()
         radarChart.data = [
         RadarData(label: "Calories", value: 1.0),
         RadarData(label: "Steps ", value: 0.5),
         RadarData(label: "Routine adherence ", value: 0.95),
         RadarData(label: "Exercises Completed ", value: 0.5),
         RadarData(label: "Duration", value: 0.75),
         RadarData(label: "Heart zone", value: 0.4)
         ]
         
         radarChart.datasetFillColor = UIColor.appGreen.withAlphaComponent(0.3)
         radarChart.datasetStrokeColor = UIColor.appGreen.withAlphaComponent(0.7)
         radarChart.gridColor = UIColor.white.withAlphaComponent(0.15)
         radarChart.labelColor = UIColor.white.withAlphaComponent(0.8)
         radarChart.numberOfGridPolygons = 4
         radarChart.centerStarFillColor = UIColor.mainBg
         radarChart.backgroundColor = UIColor.mainBg
         view.addSubview(radarChart)
         radarChart.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
         radarChart.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
         radarChart.heightAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
         radarChart.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         radarChart.centerYAnchor.constraint(equalTo: view.centerYAnchor)
         ])
         */
        
    }
    
    //    func initPolygonChartView() {
    //        self.polygonChartMBV.delegate = self
    //        self.polygonChartMBV.backgroundColor = .clear
    //        self.polygonChartMBV.start()
    //    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.noteMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.scoretitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.scoreLbl.font = AppFont.semibold.size(80.0, familyName: familyClashDisplay)
        self.noteLbl.font = AppFont.regular.size(14.0, familyName: familyOverpass)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
}

//extension SessionCompleteViewController: PolygonChartViewDelegate {
//
//    func setPolygonChartDrawSets(polygonChart: PolygonChartView, radius: CGFloat) -> PolygonChartDrawSet    {
//
//        // 100%
//        var set1 = PolygonChartDraw()
//        set1.radius = radius
//        set1.lineWidth = 1
//        set1.strokeColor = UIColor.gray.cgColor
//        set1.objectTextSet = ["Calories", "Steps", "Routine adherence", "Exercises Completed", "Duration", "Heart zone"]
//        set1.unitText = ""
//        set1.unitColor = UIColor.gray
//        set1.objectColor = UIColor.appWhite
//        set1.objectFont = AppFont.semibold.size(14.0, familyName: familyManrope)
//        set1.isSkeleton = true
//
//        // 50%
//        var set2 = PolygonChartDraw()
//        set2.radius = radius / 2
//        set2.lineWidth = 1
//        set2.strokeColor = UIColor.gray.cgColor
//        set2.unitText = ""
//        set2.unitColor = .gray
//
//        return PolygonChartDrawSet(drawSet: [set1, set2])
//    }
//
//    func setPolygonChartDataSets(polygonChart: PolygonChartView) -> PolygonChartDataSet? {
//
//
//        // Data Value2(ex: Average)
//        var set1 = PolygonChartData()
//        set1.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
//        set1.values = [15,50,15,50,15,50]
//        set1.lineWidth = 2.5
//        set1.strokeColor = UIColor(red: 161/255.0, green: 221/255.0, blue: 112/255.0, alpha: 1).cgColor
//
//        // Data Value1
//        var set2 = PolygonChartData()
//        set2.fillColor = UIColor(red: 158/255.0, green: 255/255.0, blue: 238/255.0, alpha: 0.4).cgColor
//        set2.values = [90,75,65,55,95,70]
//        set2.lineWidth = 2.5
//        set2.strokeColor = UIColor(red: 161/255.0, green: 221/255.0, blue: 112/255.0, alpha: 1).cgColor
//        set2.isAnimate = true
//
//
////        // Data Value2(ex: Average)
////        var set2 = PolygonChartData()
////        set2.lineDashPattern = [3,3]
////        set2.values = [80,80,80,80,80,80]
////        set2.lineWidth = 1
////        set2.strokeColor = UIColor(red: 161/255.0, green: 221/255.0, blue: 112/255.0, alpha: 1).cgColor
//
//        //rgba(161, 221, 112, 1)
//        //rgba(158, 255, 238, 0.4)
//
////        return PolygonChartDataSet(dataSet: [set1, set2])
//
//        return PolygonChartDataSet(dataSet: [set2])
//
////        return PolygonChartDataSet(dataSet: [set1, set2])
//    }
//
//    func numberOfPolygonChart(polygonChart: PolygonChartView) -> Int {
//        return 6
//    }
//}
