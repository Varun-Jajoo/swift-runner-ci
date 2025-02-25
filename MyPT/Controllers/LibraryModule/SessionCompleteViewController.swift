//
//  SessionCompleteViewController.swift
//  MyPT
//
//  Created by techsaga corp on 14/01/25.
//

import UIKit

class SessionCompleteViewController: CommonViewController {

    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var polygonChartMBV: PolygonChartView!
    @IBOutlet weak var detailsMBV: UIView!
    @IBOutlet weak var scoretitleLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var noteMBV: UIView!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.initPolygonChartView()
        self.setupUI()
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
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func initPolygonChartView() {
        self.polygonChartMBV.delegate = self
        self.polygonChartMBV.backgroundColor = .clear
        self.polygonChartMBV.start()
    }
    
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

extension SessionCompleteViewController: PolygonChartViewDelegate {
    func setPolygonChartDrawSets(polygonChart: PolygonChartView, radius: CGFloat) -> PolygonChartDrawSet    {
        
        // 100%
        var set1 = PolygonChartDraw()
        set1.radius = radius
        set1.lineWidth = 1
        set1.strokeColor = UIColor.gray.cgColor
        set1.objectTextSet = ["Calories", "Steps", "Routine adherence", "Exercises Completed", "Duration", "Heart zone"]
        set1.unitText = ""
        set1.unitColor = UIColor.gray
        set1.objectColor = UIColor.appWhite
        set1.objectFont = AppFont.semibold.size(14.0, familyName: familyManrope)
        set1.isSkeleton = true
        
        // 50%
        var set2 = PolygonChartDraw()
        set2.radius = radius / 2
        set2.lineWidth = 1
        set2.strokeColor = UIColor.gray.cgColor
        set2.unitText = ""
        set2.unitColor = .gray
        
        return PolygonChartDrawSet(drawSet: [set1, set2])
    }
    
    func setPolygonChartDataSets(polygonChart: PolygonChartView) -> PolygonChartDataSet? {
        
        
        // Data Value2(ex: Average)
        var set1 = PolygonChartData()
        set1.fillColor = UIColor.black.withAlphaComponent(0.3).cgColor
        set1.values = [15,50,15,50,15,50]
        set1.lineWidth = 2.5
        set1.strokeColor = UIColor(red: 161/255.0, green: 221/255.0, blue: 112/255.0, alpha: 1).cgColor
        
        // Data Value1
        var set2 = PolygonChartData()
        set2.fillColor = UIColor(red: 158/255.0, green: 255/255.0, blue: 238/255.0, alpha: 0.4).cgColor
        set2.values = [90,75,65,55,95,70]
        set2.lineWidth = 2.5
        set2.strokeColor = UIColor(red: 161/255.0, green: 221/255.0, blue: 112/255.0, alpha: 1).cgColor
        set2.isAnimate = true
        
//        // Data Value2(ex: Average)
//        var set2 = PolygonChartData()
//        set2.lineDashPattern = [3,3]
//        set2.values = [80,80,80,80,80,80]
//        set2.lineWidth = 1
//        set2.strokeColor = UIColor(red: 161/255.0, green: 221/255.0, blue: 112/255.0, alpha: 1).cgColor
        
        //rgba(161, 221, 112, 1)
        //rgba(158, 255, 238, 0.4)
        
//        return PolygonChartDataSet(dataSet: [set1, set2])
        
        return PolygonChartDataSet(dataSet: [set1, set2])
    }
    
    func numberOfPolygonChart(polygonChart: PolygonChartView) -> Int {
        return 6
    }
}
