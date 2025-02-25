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
    @IBOutlet weak var footerImgView: UIImageView!
    @IBOutlet weak var planBackImgView: UIImageView!
    @IBOutlet weak var planForDayTitleLbl: UILabel!
    @IBOutlet weak var backTitleLbl: UILabel!
    @IBOutlet weak var upcomingSessionLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var thoughtDescLbl: UILabel!
    @IBOutlet weak var thoughtWriterNameLbl: UILabel!
    @IBOutlet weak var upcomingSessionListHeightConstrnt: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setFontUI()
        
        self.upcomingSessionList.register(UINib(nibName: "SearchWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchWorkoutTableViewCell")
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
    
    func setupUI(){
        DispatchQueue.main.async {
            self.planBackImgView.addGradientWithHeight(colors: [UIColor.mainBg.withAlphaComponent(0.3), UIColor.mainBg.withAlphaComponent(0.3)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), gradientHeight: 0.1)
            
            self.lineLbl.addGradient(colors: [UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0),UIColor(red: 56/255.0, green: 71/255.0, blue: 81/255.0, alpha: 1),UIColor(red: 36/255.0, green: 45/255.0, blue: 50/255.0, alpha: 0)], locations: [0.2,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 1.0)
        }
//        self.planBackImgView.image = UIImage(named: "ic_backSession")
    }
    
    func setFontUI(){
        self.planForDayTitleLbl.font = AppFont.semibold.size(40.0, familyName: familyClashDisplay)
        self.backTitleLbl.font = AppFont.semibold.size(40.0, familyName: familyClashDisplay)
        self.upcomingSessionLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.thoughtDescLbl.font =  AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.thoughtWriterNameLbl.font = AppFont.regular.size(12.0, familyName: familyClashDisplay)
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
        cell.videoPlauyBtn.isHidden = true
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
