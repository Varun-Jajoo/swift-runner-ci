//
//  SessionStatusViewController.swift
//  MyPT
//
//  Created by techsaga corp on 14/01/25.
//

import UIKit

class SessionStatusViewController: CommonViewController {
    
    //MARK: ------------ VARIABLE
    var sessionIdStr: String?
    var workoutSummaryData: WorkoutSummaryDataModel?
    var workoutSummaryLst:[SummaryModel]? = []
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var sessionCompleteMBV: UIView!
    @IBOutlet weak var myScore1MBV: UIView!
    @IBOutlet weak var myScore2MBV: UIView!
    @IBOutlet weak var myScore3MBV: UIView!
    @IBOutlet weak var completeSessionTitleLbl: UILabel!
    @IBOutlet weak var targetAchievedLbl: UILabel!
    @IBOutlet weak var sessionProgressLbl: UILabel!
    
    @IBOutlet weak var worksummaryTitleLbl: UILabel!
    @IBOutlet weak var workoutListTblView: UITableView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var workoutListTblViewHeightConstrnt: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        self.workouSummaryApi(sessionId: sessionIdStr)
        self.setInputData()
        //        self.progressVSet(progressValue:0.0)
        //        self.setupScoreUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        print("contineu")
        let vc:WeekStreakViewController = WeekStreakViewController.instantiate(appStoryboard: .library)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func setInputData(){
        
        self.progressVSet(progressValue: Double(workoutSummaryData?.percentageCompleted?.value ?? "0.0") ?? 0.0)
        
        let dataScore: [Double] = workoutSummaryData?.scoreBlocks?.compactMap { value in
            return Double(value.calories?.value ?? "0.0")
        } ?? []
        self.setupScoreUI(scoreblocks: dataScore)
        
        //        let dataScore: [Double] = workoutSummaryData?.scoreBlocks?.compactMap { value in
        //            return Double(value.value ?? "0.0")
        //        } ?? []
        //        self.setupScoreUI(scoreblocks: dataScore)
    }
    
    private func progressVSet(progressValue: CGFloat? = 0.1, progressColor: [CGColor]? = [UIColor(red: 63.0/255.0, green: 40.0/255.0, blue: 14.0/255.0, alpha: 1.0).cgColor, UIColor(red: 243/255.0, green: 141/255.0, blue: 27/255.0, alpha: 1.0).cgColor]){
        
        let container = GaugeView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.clear
        sessionCompleteMBV.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: sessionCompleteMBV.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: sessionCompleteMBV.trailingAnchor),
            //               container.bottomAnchor.constraint(equalTo: sessionCompleteMBV.bottomAnchor),
            container.bottomAnchor.constraint(equalTo: sessionCompleteMBV.bottomAnchor, constant: -20),
            container.heightAnchor.constraint(equalTo: sessionCompleteMBV.heightAnchor, multiplier: 1)
        ])
        
        container.gaugeProgersColor = progressColor ?? [ UIColor(red: 63.0/255.0, green: 40.0/255.0, blue: 14.0/255.0, alpha: 1.0).cgColor, UIColor(red: 243/255.0, green: 141/255.0, blue: 27/255.0, alpha: 1.0).cgColor]
        container.trackColor = UIColor(red: 63.0/255.0, green: 40.0/255.0, blue: 14.0/255.0, alpha: 1.0)
        container.showTicks = false
        container.gaugeThickness = 50
        
        if let progressValue = progressValue {
            container.progress = (progressValue / 100)
        }
        
        sessionProgressLbl.text = " "
        if let completePer = workoutSummaryData?.percentageCompleted?.value {
            self.sessionProgressLbl.attributedText = gradientAttr(labl: self.sessionProgressLbl, txtStr: completePer + "%")
        }
    }
    
    private func setupScoreUI(scoreblocks:[Double]){
        
        let bar = VerticalProgressBar()
        DispatchQueue.main.async {
            bar.frame = self.myScore1MBV.bounds
        }
        bar.gradientColors = [
            UIColor(red: 75.0/255.0, green: 35.0/255.0, blue: 115.0/255.0, alpha: 1.0),
            UIColor(red: 183.0/255.0, green: 96.0/255.0, blue: 214.0/255.0, alpha: 1.0)
        ]
        bar.progress = (scoreblocks.indices.contains(0) ? scoreblocks[0] : 0.0) / 100.0
        myScore1MBV.addSubview(bar)
        
        let bar2 = VerticalProgressBar()
        DispatchQueue.main.async {
            bar2.frame = self.myScore2MBV.bounds
        }
        bar2.gradientColors = [
            UIColor(red: 27.0/255.0, green: 55.0/255.0, blue: 76.0/255.0, alpha: 1.0),
            UIColor(red: 93.0/255.0, green: 182.0/255.0, blue: 195.0/255.0, alpha: 1.0)
        ]
        bar2.progress = (scoreblocks.indices.contains(1) ? scoreblocks[1] : 0.0) / 100.0
        myScore2MBV.addSubview(bar2)
        
        let bar3 = VerticalProgressBar()
        DispatchQueue.main.async {
            bar3.frame = self.myScore3MBV.bounds
        }
        
        bar3.gradientColors = [
            UIColor(red: 35/255.0, green: 47/255.0, blue: 115/255.0, alpha: 1.0),
            UIColor(red: 93.0/255.0, green: 182.0/255.0, blue: 195.0/255.0, alpha: 1.0)
        ]
        bar3.progress = (scoreblocks.indices.contains(2) ? scoreblocks[2] : 0.0) / 100.0
        myScore3MBV.addSubview(bar3)
    }
    
    func setupUI(){
        self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        [
            self.myScore1MBV,
            self.myScore2MBV,
            self.myScore3MBV
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
        })
    }
    
    func setupFont(){
        
        self.workoutListTblView.register(UINib(nibName: "WorkoutSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "WorkoutSummaryTableViewCell")
        self.workoutListTblView.isMultipleTouchEnabled = true
        
        //---------------***********
        self.worksummaryTitleLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
        self.completeSessionTitleLbl.font = AppFont.semibold.size(25.0, familyName: familyClashDisplay)
        self.targetAchievedLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        sessionProgressLbl.text = " "
        //        if let ptScore = completeWorkoutData?.ptScore?.value{
        //        self.sessionProgressLbl.attributedText = gradientAttr(labl: self.sessionProgressLbl, txtStr: "52%")
        //        }
    }
    
    private func gradientAttr(labl: UILabel, txtStr: String, inputFont: UIFont? = AppFont.semibold.size(58.0, familyName: familyClashDisplay)) -> NSAttributedString {
        
        let attStr = txtStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: labl.bounds, font: inputFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
        
        return attStr
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if workoutListTblView.contentSize.height != 0 {
            self.workoutListTblViewHeightConstrnt.constant = workoutListTblView.contentSize.height
        }
        
        self.view.layoutIfNeeded()
    }
    
}


extension SessionStatusViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutSummaryLst?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:WorkoutSummaryTableViewCell = workoutListTblView.dequeueReusableCell(withIdentifier: "WorkoutSummaryTableViewCell", for: indexPath) as! WorkoutSummaryTableViewCell
        
        cell.setCellData(cellData: workoutSummaryLst?[indexPath.row])
        
        //        let img = UIImage(named: "ic_femaleplaceholder")?.resized(to: CGSize(width: (cell.frame.width * 0.5), height: cell.frame.size.height))
        //        cell.workoutImgView.image = img
        //        cell.selectionImgView.image = UIImage(named: "ic_checkDay")
        
        
        if let status = workoutSummaryLst?[indexPath.row].status?.value , status.lowercased() == "completed".lowercased() {
            cell.selectionImgView.image = UIImage(named: "ic_checkDay")
            cell.selectionCell(isSelected: false)
        }else{
            cell.selectionImgView.image = UIImage(named: "ic_clock_redbg")
            cell.selectionCell(isSelected: true)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
         let cell:WorkoutSummaryTableViewCell = workoutListTblView.cellForRow(at: indexPath) as! WorkoutSummaryTableViewCell
         cell.selectionImgView.image = UIImage(named: "ic_clock_redbg")
         cell.selectionCell(isSelected: true)
         */
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        /*
         let cell:WorkoutSummaryTableViewCell = workoutListTblView.cellForRow(at: indexPath) as! WorkoutSummaryTableViewCell
         cell.selectionImgView.image = UIImage(named: "ic_checkDay")
         cell.selectionCell(isSelected: false)
         */
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}


extension SessionStatusViewController{
    
    private func workouSummaryApi(sessionId: String?){
        WorkoutLibraryVM.getWorkoutSummaryApi(inputSessionId: sessionId, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            print("getResultData: ", getResultData)
            self.workoutSummaryData = getResultData.data
            self.workoutSummaryLst?.removeAll()
            self.workoutSummaryLst?.append(contentsOf: getResultData.data?.summary ?? [])
            self.workoutListTblView.reloadData()
            self.setInputData()
        })
    }
}
