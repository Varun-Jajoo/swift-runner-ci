//
//  ActiveUpcomingSessionViewController.swift
//  MyPT
//
//  Created by techsaga corp on 23/01/25.
//

import UIKit

class ActiveUpcomingSessionViewController: CommonViewController {
    
    //MARK: ------------------VARIABLE
    
    //MARK: -------------------IBOUTLET
    @IBOutlet weak var upcomingSessionList: UITableView!
    @IBOutlet weak var footerNoteMBV: UIView!
    @IBOutlet weak var planForDayMBV: UIView!
    @IBOutlet weak var trainerDetailsMVB: UIView!
    @IBOutlet weak var remainingTimeMVB: UIView!
    @IBOutlet weak var remainingTimeGraphMBV: UIView!
    @IBOutlet weak var heartRateMVB: UIView!
    @IBOutlet weak var heartRateGraphMVB: UIView!
    @IBOutlet weak var todayGoalsMVB: UIView!
    @IBOutlet weak var durationMBV: UIView!
    @IBOutlet weak var caloriesMBV: UIView!
    @IBOutlet weak var exerciseMBV: UIView!
    @IBOutlet weak var durationGrapghMBV: UIView!
    @IBOutlet weak var caloriesGrapghMBV: UIView!
    @IBOutlet weak var exerciseGrapghMBV: UIView!
    @IBOutlet weak var footerImgView: UIImageView!
    @IBOutlet weak var planBackImgView: UIImageView!
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var durationGraphImgView: UIImageView!
    @IBOutlet weak var caloriesGraphImgView: UIImageView!
    @IBOutlet weak var exerciseGraphImgView: UIImageView!
    @IBOutlet weak var planForDayTitleLbl: UILabel!
    @IBOutlet weak var backTitleLbl: UILabel!
    @IBOutlet weak var upcomingSessionLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var thoughtDescLbl: UILabel!
    @IBOutlet weak var thoughtWriterNameLbl: UILabel!
    @IBOutlet weak var myTrainerTitleLbl: UILabel!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var trainerTimingLbl: UILabel!
    @IBOutlet weak var trainerRatingBtn: UIButton!
    @IBOutlet weak var remainingTimeLbl: UILabel!
    @IBOutlet weak var heartRateTitleLbl: UILabel!
    @IBOutlet weak var todayGoalsTitleLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var durationTitleLbl: UILabel!
    @IBOutlet weak var caloriesLbl: UILabel!
    @IBOutlet weak var caloriesTitleLbl: UILabel!
    @IBOutlet weak var exerciseLbl: UILabel!
    @IBOutlet weak var exerciseTitleLbl: UILabel!
    
    @IBOutlet weak var upcomingSessionListHeightConstrnt: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setFontUI()
        
        self.upcomingSessionList.register(UINib(nibName: "SearchWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchWorkoutTableViewCell")
        
        self.gaugeProgressV()
        
        
//        let gaugeView = ArcGaugeView(frame: CGRect(x: 0, y: 100, width: 400, height: 200))
//        remainingTimeMVB.addSubview(gaugeView)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.active_str + " " + AppStrings.session_str], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings,AppImages.sosActive], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func leftBtnActn(sender: UIButton) {
        print("left action")
    }
    
    
    //MARK: -----------------MY STATS
    private func gaugeProgressV(){
        
        let outerProgerssGradient: [CGColor] = [
            UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 27.0/255.0, alpha: 1.0).cgColor,
            UIColor(red: 63.0/255.0, green: 40.0/255.0, blue: 14.0/255.0, alpha: 1.0).cgColor
        ]
        
        //--------------------- Duration graph
        let durationProgV = GaugeContainerView()
        durationProgV.translatesAutoresizingMaskIntoConstraints = false
        durationProgV.backgroundColor = UIColor.clear
        durationGrapghMBV.addSubview(durationProgV)
        durationProgV.gaugeThickness = 20.0
        durationProgV.showTicks = true
        
        NSLayoutConstraint.activate([
            durationProgV.leadingAnchor.constraint(equalTo: durationGrapghMBV.leadingAnchor, constant: -30),
            durationProgV.trailingAnchor.constraint(equalTo: durationGrapghMBV.trailingAnchor, constant: 30),
            durationProgV.bottomAnchor.constraint(equalTo: durationGrapghMBV.bottomAnchor),
            durationProgV.heightAnchor.constraint(equalTo: durationGrapghMBV.heightAnchor, multiplier: 1.2)
        ])
        
        durationProgV.progersColor = outerProgerssGradient
//        durationGraphImgView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 5 / 180)
        durationProgV.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4.5)
        durationProgV.setGaugeProgress(0.4)
        
        //-----------------********* Calories progress view setup
        let caloriesProgV = GaugeContainerView()
        caloriesProgV.translatesAutoresizingMaskIntoConstraints = false
        caloriesProgV.backgroundColor = UIColor.clear
        caloriesGrapghMBV.addSubview(caloriesProgV)
        caloriesProgV.gaugeThickness = 20.0
        caloriesProgV.showTicks = true

        NSLayoutConstraint.activate([
            caloriesProgV.leadingAnchor.constraint(equalTo: caloriesGrapghMBV.leadingAnchor, constant: -30),
            caloriesProgV.trailingAnchor.constraint(equalTo: caloriesGrapghMBV.trailingAnchor, constant: 30),
            caloriesProgV.bottomAnchor.constraint(equalTo: caloriesGrapghMBV.bottomAnchor),
            caloriesProgV.heightAnchor.constraint(equalTo: caloriesGrapghMBV.heightAnchor, multiplier: 1.2)
        ])
        
        caloriesProgV.progersColor = outerProgerssGradient
        caloriesProgV.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4.5)
//        caloriesGraphImgView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 5 / 180)
        caloriesProgV.setGaugeProgress(0.4)
        
        
        //--------------------******** Exercise Grapgh
        let exerciseProgV = GaugeContainerView()
        exerciseProgV.translatesAutoresizingMaskIntoConstraints = false
        exerciseProgV.backgroundColor = UIColor.clear
        exerciseGrapghMBV.addSubview(exerciseProgV)
        exerciseProgV.gaugeThickness = 20.0
        exerciseProgV.showTicks = true
        
        NSLayoutConstraint.activate([
            exerciseProgV.leadingAnchor.constraint(equalTo: exerciseGrapghMBV.leadingAnchor, constant: -30),
            exerciseProgV.trailingAnchor.constraint(equalTo: exerciseGrapghMBV.trailingAnchor, constant: 30),
            exerciseProgV.bottomAnchor.constraint(equalTo: exerciseGrapghMBV.bottomAnchor),
            exerciseProgV.heightAnchor.constraint(equalTo: exerciseGrapghMBV.heightAnchor, multiplier: 1.2)
        ])
        
        exerciseProgV.progersColor = outerProgerssGradient
        exerciseProgV.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4.5)
        exerciseGraphImgView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 50 / 180) //CGAffineTransform(rotationAngle: -CGFloat.pi * 5 / 180)
        exerciseProgV.setGaugeProgress(0.4)
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.planBackImgView.addGradientWithHeight(colors: [UIColor.mainBg.withAlphaComponent(0.3), UIColor.mainBg.withAlphaComponent(0.3)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), gradientHeight: 0.1)
            
            self.lineLbl.addGradient(colors: [UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0),UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1),UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0)], locations: [0.2,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 1.0)
            
            [
                self.durationMBV,
                self.caloriesMBV,
                self.exerciseMBV,
            ].forEach({[weak self] in
                guard self != nil else {
                    return
                }
                $0?.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.7), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
            })
        }
        //        self.planBackImgView.image = UIImage(named: "ic_backSession")
    }
    
    func setFontUI(){
        self.planForDayTitleLbl.font = AppFont.semibold.size(40.0, familyName: familyClashDisplay)
        self.backTitleLbl.font = AppFont.semibold.size(40.0, familyName: familyClashDisplay)
//        self.upcomingSessionLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.thoughtDescLbl.font =  AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.thoughtWriterNameLbl.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
        
        [
            heartRateTitleLbl,
            trainerTimingLbl,
            trainerRatingBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
        /*
         
         
         remainingTimeLbl

         durationLbl
         
         caloriesLbl
         
         exerciseLbl
         
         */
        
        [
            self.trainerNameLbl,
            self.upcomingSessionLbl,
            self.myTrainerTitleLbl,
            self.todayGoalsTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
        
        [
            self.durationTitleLbl,
            self.caloriesTitleLbl,
            self.exerciseTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        
        [
            self.durationLbl,
            self.caloriesLbl,
            self.exerciseLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.medium.size(30, familyName: familyClashDisplay)
            $0?.applyGradientLabel(colors: [UIColor.appWhite, UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], locations: [0, 0.3, 1.0])
        })
        
        //-----------------Remaining time attr
        self.remainingTimeLbl.attributedText = setAttributedTxt(inputLabel: self.remainingTimeLbl, mainStr: "60", subStr: "\n mins remaining")
    }
        
    private func setAttributedTxt(inputLabel:UILabel, mainStr: String, subStr: String, mainFont: UIFont? = AppFont.semibold.size(80.0, familyName: familyClashDisplay), subFont: UIFont? = AppFont.medium.size(16.0, familyName: familyClashDisplay)) -> NSAttributedString{
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: subFont ?? UIFont(),
            .foregroundColor: UIColor.appWhite.withAlphaComponent(0.8)
        ] as [NSAttributedString.Key : Any]
                
        let makeAttributes = [
            mainStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: inputLabel.bounds, font: mainFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.4, y: 0.9)),
            subStr
        ] as [AttributedStringComponent]
        
        return NSAttributedString(from: makeAttributes, defaultAttributes: defaultAttributes) ?? NSAttributedString()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if upcomingSessionList.contentSize.height != 0 {
            self.upcomingSessionListHeightConstrnt.constant = upcomingSessionList.contentSize.height
        }
        view.layoutIfNeeded()
    }
    
}

//MARK: ------------------UITABLEVIEW DELAGATE/DATASOURCE
extension ActiveUpcomingSessionViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noSessionsConfig(inputTable: self.upcomingSessionList, getCount: 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SearchWorkoutTableViewCell = upcomingSessionList.dequeueReusableCell(withIdentifier: "SearchWorkoutTableViewCell", for: indexPath) as! SearchWorkoutTableViewCell
        cell.shareBtn.isHidden = true
        cell.likeBtn.isHidden = true
        cell.videoPlayBtn.isHidden = true
        cell.timingMBV.isHidden = true
        cell.seriesWorkoutLbl.isHidden = false
        
        //------------------DATA SET
        cell.topTitleLbl.text = "Rope"
        cell.workoutNameLbl.text = "Back Twist"
        cell.seriesWorkoutLbl.text = "Shinomiya Kaguya"
        
        cell.kcalImgView.image = UIImage(named: "ic_Solid_fire")?.withRenderingMode(.alwaysTemplate)
        cell.kcalImgView.tintColor = UIColor.appYellow
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch globalWorkoutFlow {
        case .ActiveSession:
            let vc:SessionCompleteViewController = SessionCompleteViewController.instantiate(appStoryboard: .library)
            self.navigationController?.pushViewController(vc, animated: true)
        case .defaultWorkout:
            let vc:WorkoutDuringSessionViewController = WorkoutDuringSessionViewController.instantiate(appStoryboard: .library)
            vc.flowSetWorkout = .ActiveSession
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    //MARK: ------------NO DATA FOUND CONFIGURATION
    func noSessionsConfig(inputTable:UITableView?, getCount:Int?) -> Int{
        let msgImage = UIImage(named: "ic_search_NoResult")
        //        self.workoutData?.count
        guard let countReturn = upcomingSessionList?.numberOfRows(count: 10, title: AppAlertStrings.no_results_found, message: AppAlertStrings.no_Match_alterMsg, messageImage: msgImage, messageImageHeight: (msgImage?.size.height ?? 10) * 0.4, reloadSetTitle: nil, target: self, action: #selector(reloadData(sender: )), fromCenter: -20) else { return 0}
        
        return  countReturn
    }
    
    @objc func reloadData(sender: UIButton){
        
    }
    
}
