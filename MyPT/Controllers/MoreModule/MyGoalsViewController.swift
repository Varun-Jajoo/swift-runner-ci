//
//  MyGoalsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 10/02/25.
//

import UIKit

class MyGoalsViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource {
   
    //MARK: --------------- VARIABLE
//    var headerData1:[String]?
    var headerData:[SectionModel]?
    
    
    //MARK: -----------------IBOUTLET
    @IBOutlet weak var headerMBV: UIView!
    @IBOutlet weak var headerSubMBV: UIView!
    @IBOutlet weak var stepsCountLbl: UILabel!
    @IBOutlet weak var myGoalsTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
             
//        self.headerData1 = ["Workout Goals","Nutrition Goals","Habit Tracking"]
       
        self.headerData = [
            SectionModel(title: "Workout Goals", items: ["Calories Burn"]),
            SectionModel(title: "Nutrition Goals", items: ["Calories Intake","HYDRATION"]),
            SectionModel(title: "Habit Tracking", items: [])
        ]
        
        self.myGoalsTblView.register(UINib(nibName: "MyGoalsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyGoalsTableViewCell")
        
        //------------------upcoming
//        self.setTopBackgroundImage(named: "ic_Mygoals_Upcoming")
        
        self.view.setComingSoon(bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_upcomingStripe", lockImgName: "ic_upcomingLock" ,title: AppStrings.coming_soon, desc: "Goal setting and progress tracking will be live soon. Get ready to aim higher!")
//        self.view.addTopNavigationButton(title: "Profile", image: AppImages.backarrow, target: self.view)
       
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
//        self.setTopBackgroundImage(named: "ic_Mygoals_Upcoming")
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.my_Goals], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //MARK: -----------------UITABLEVIEW DATASOURCE/ DELEGATE
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 2 {
//            return 0
//        }else{
//            return self.headerData?[section].items.count ?? 0
//        }
        return self.headerData?[section].items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyGoalsTableViewCell = myGoalsTblView.dequeueReusableCell(withIdentifier: "MyGoalsTableViewCell", for: indexPath) as! MyGoalsTableViewCell
        DispatchQueue.main.async {
            cell.progressMBV.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor.appRatingYellow, cornerRadius: 3.0)
        }
        
        cell.caloriesBurnTitleLbl.text = (self.headerData?[indexPath.section].items[indexPath.row] as? String)?.uppercased()
        
        cell.seeAllBtn.tag = 101 + indexPath.row
        cell.seeAllBtn.accessibilityLabel = (self.headerData?[indexPath.section].items[indexPath.row] as? String)?.uppercased()
        cell.seeAllBtn.addTarget(self, action: #selector(seeAllBtnActn(sender: )), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.headerData?[indexPath.section].title.uppercased() == "Workout Goals".uppercased() {
            let vc:CaloriesIntakeViewController = CaloriesIntakeViewController.instantiate(appStoryboard: .more)
            vc.intakeFlow = .caloriesBrun
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else  if self.headerData?[indexPath.section].title.uppercased() == "Nutrition Goals".uppercased() && (self.headerData?[indexPath.section].items[indexPath.row] as? String)?.uppercased() == "Calories Intake".uppercased() {
            
            let vc:CaloriesIntakeViewController = CaloriesIntakeViewController.instantiate(appStoryboard: .more)
            vc.intakeFlow = .addIntake
            self.navigationController?.pushViewController(vc, animated: true)
            
//            if (self.headerData?[indexPath.section].items[indexPath.row] as? String)?.uppercased() == "" {
//                let vc:CaloriesIntakeViewController = CaloriesIntakeViewController.instantiate(appStoryboard: .more)
//                vc.intakeFlow = .addIntake
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
        } else if self.headerData?[indexPath.section].title.uppercased() == "Nutrition Goals".uppercased() && (self.headerData?[indexPath.section].items[indexPath.row] as? String)?.uppercased() == "HYDRATION".uppercased(){
            
//            let vc:MealsViewController = MealsViewController.instantiate(appStoryboard: .more)
            
            let vc:HydrationViewViewController = HydrationViewViewController.instantiate(appStoryboard: .more)
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        }

    
//        let vc:CaloriesIntakeViewController = CaloriesIntakeViewController.instantiate(appStoryboard: .more)
        
//        let vc:StepCountViewController = StepCountViewController.instantiate(appStoryboard: .more)
//        let vc:SleepGoalsViewController = SleepGoalsViewController.instantiate(appStoryboard: .more)
        
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerV = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        let headerSubVMBV = UIView()
        let headerLbltLbl = UILabel()
        
        headerV.backgroundColor = UIColor.clear
        headerSubVMBV.backgroundColor = UIColor.clear
        headerV.addSubview(headerSubVMBV)
        headerSubVMBV.addSubview(headerLbltLbl)
        
        headerSubVMBV.translatesAutoresizingMaskIntoConstraints = false
        headerLbltLbl.translatesAutoresizingMaskIntoConstraints = false
        //----------make constraint
        NSLayoutConstraint.activate([
            headerSubVMBV.leadingAnchor.constraint(equalTo: headerV.leadingAnchor, constant: 20),
            headerSubVMBV.trailingAnchor.constraint(equalTo: headerV.trailingAnchor, constant: -20),
            headerSubVMBV.topAnchor.constraint(equalTo: headerV.topAnchor, constant: 2),
            headerSubVMBV.bottomAnchor.constraint(equalTo: headerV.bottomAnchor, constant: -2),
            headerLbltLbl.leadingAnchor.constraint(equalTo: headerSubVMBV.leadingAnchor, constant: 1),
            headerLbltLbl.trailingAnchor.constraint(equalTo: headerSubVMBV.trailingAnchor, constant: -1),
            headerLbltLbl.topAnchor.constraint(equalTo: headerSubVMBV.topAnchor, constant: 2),
            headerLbltLbl.bottomAnchor.constraint(equalTo: headerSubVMBV.bottomAnchor, constant: -2)
            ])
        
        //------------------Input Data
        headerLbltLbl.text = self.headerData?[section].title as? String // headerData?[section] as? String
        headerLbltLbl.textColor = UIColor.txtDarkGray
        headerLbltLbl.font = AppFont.semibold.size(16, familyName: familyManrope)
        
        return headerV //headerMBV
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 85))
        let connectMBV = UIView()
        let stepsImgView = UIImageView()
        let rightImgView = UIImageView()
        let stepsCountLbl = UILabel()
        let stepsConnectLbl = UILabel()
       
        let topBtn = UIButton() //UIButton(type: .custom)
        
        footerView.backgroundColor = UIColor.clear
        topBtn.backgroundColor = UIColor.clear
        
//        // Define an explicit height constraint (if using Auto Layout)
        let heightConstraint = footerView.heightAnchor.constraint(equalToConstant: 90)
        heightConstraint.isActive = true
       
        connectMBV.backgroundColor = UIColor.clear
        
        footerView.addSubview(connectMBV)
        connectMBV.addSubview(topBtn)
        connectMBV.addSubview(stepsImgView)
        connectMBV.addSubview(rightImgView)
        connectMBV.addSubview(stepsCountLbl)
        connectMBV.addSubview(stepsConnectLbl)
        
        topBtn.translatesAutoresizingMaskIntoConstraints = false
        connectMBV.translatesAutoresizingMaskIntoConstraints = false
        stepsImgView.translatesAutoresizingMaskIntoConstraints = false
        rightImgView.translatesAutoresizingMaskIntoConstraints = false
        stepsCountLbl.translatesAutoresizingMaskIntoConstraints = false
        stepsConnectLbl.translatesAutoresizingMaskIntoConstraints = false
        
        //----------make constraint
        NSLayoutConstraint.activate([
            connectMBV.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            connectMBV.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
            connectMBV.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 2),
            connectMBV.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -20),
            topBtn.leadingAnchor.constraint(equalTo: connectMBV.leadingAnchor, constant: 1),
            topBtn.trailingAnchor.constraint(equalTo: connectMBV.trailingAnchor, constant: 1),
            topBtn.topAnchor.constraint(equalTo: connectMBV.topAnchor, constant: 1),
            topBtn.bottomAnchor.constraint(equalTo: connectMBV.bottomAnchor, constant: -1),
            
            stepsImgView.leadingAnchor.constraint(equalTo: connectMBV.leadingAnchor, constant: 20),
            stepsImgView.topAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: connectMBV.topAnchor, multiplier: 10),
            
//            stepsImgView.topAnchor.constraint(equalTo: connectMBV.topAnchor, constant: 10),
//            stepsImgView.bottomAnchor.constraint(equalTo: connectMBV.bottomAnchor, constant: -10),
            stepsImgView.centerYAnchor.constraint(equalTo: connectMBV.centerYAnchor),
            stepsImgView.widthAnchor.constraint(equalToConstant: 50),
            stepsImgView.heightAnchor.constraint(equalToConstant: 50),
           
            stepsCountLbl.leadingAnchor.constraint(equalTo: stepsImgView.trailingAnchor, constant: 8),
            stepsCountLbl.centerYAnchor.constraint(equalTo: stepsImgView.centerYAnchor, constant: 0),

            rightImgView.trailingAnchor.constraint(equalTo: connectMBV.trailingAnchor, constant: -20),
            rightImgView.centerYAnchor.constraint(equalTo: stepsImgView.centerYAnchor),
            rightImgView.heightAnchor.constraint(equalToConstant: 20),
            rightImgView.widthAnchor.constraint(equalToConstant: 20),
            
            stepsConnectLbl.trailingAnchor.constraint(equalTo: rightImgView.leadingAnchor, constant: -4),
            stepsConnectLbl.centerYAnchor.constraint(equalTo: rightImgView.centerYAnchor),
            stepsConnectLbl.leadingAnchor.constraint(greaterThanOrEqualTo: stepsCountLbl.trailingAnchor, constant: 12)
        ])
        
        stepsConnectLbl.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        stepsConnectLbl.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        stepsCountLbl.numberOfLines = 2
        stepsConnectLbl.numberOfLines = 2
      
        //-------------Set Input Data
        stepsImgView.image = UIImage(named: "ic_running_ jogging")
        rightImgView.image = AppImages.arrow_right
//        stepsCountLbl.text = "Steps Count"
        stepsConnectLbl.text = "Connect"
        stepsCountLbl.textColor = UIColor.appWhite
        stepsConnectLbl.textColor = UIColor.appWhite
        stepsCountLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
        stepsConnectLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        
        stepsImgView.backgroundColor = UIColor.mainBg
        stepsImgView.contentMode = .center
        
        topBtn.tag = 101 + section
        topBtn.addTarget(self, action: #selector(footerBtnActn(sender: )), for: .touchUpInside)
        
        DispatchQueue.main.async {
            
            if section == 0{
                stepsCountLbl.text = "Steps Count"
                connectMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12)
                connectMBV.addGradient(colors: UIColor.appMultiColor( .stepsConnect), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
            }else if section == 2{
                stepsCountLbl.text = "Sleep"
                connectMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12)
                connectMBV.addGradient(colors: UIColor.appMultiColor(.stepsDiconnect), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12)
            }
            
            stepsImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: stepsImgView.frame.size.height/2.0)
        }
        
//        if section == 0{
//            stepsCountLbl.text = "Steps Count"
//        }else if section == 2{
//            stepsCountLbl.text = "Sleep"
//        }
        
        //--------------------HIDE/SHOW FOOTER
        if section == 1 {
            footerView.isHidden = true
        }else{
            footerView.isHidden = false
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 1
        }else{
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
    @objc func seeAllBtnActn(sender: UIButton){
        print("See all",sender.tag)
      
        if sender.accessibilityLabel?.uppercased() == "Calories Intake".uppercased() {
            let vc:CaloriesIntakeViewController = CaloriesIntakeViewController.instantiate(appStoryboard: .more)
            vc.intakeFlow = .addIntake
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: --------------------footer btn actn
    @objc func footerBtnActn(sender: UIButton){
        print(sender)
//        let footerV = sender.superview?.viewWithTag(sender.tag) as? UIView
        
        if sender.tag == 101 {
            let vc:StepCountViewController = StepCountViewController.instantiate(appStoryboard: .more)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc:SleepGoalsViewController = SleepGoalsViewController.instantiate(appStoryboard: .more)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
//        if sender.tag == 101 {
//            footerV?.addGradient(colors: UIColor.appMultiColor(.stepsConnect), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12)
//        }else{
//            footerV?.addGradient(colors: UIColor.appMultiColor(.stepsDiconnect), locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12)
//        }
    }
    
    //MARK: --------------FOOTERVIEW
    /*
   lazy var footerV:UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: myGoalsTblView.frame.size.width, height: 80)) //UIView()
        let connectMBV = UIView()
        let stepsImgView = UIImageView()
        let rightImgView = UIImageView()
        let stepsCountLbl = UILabel()
        let stepsConnectLbl = UILabel()
        
        footerView.backgroundColor = UIColor.white
        
//        // Define an explicit height constraint (if using Auto Layout)
        let heightConstraint = footerView.heightAnchor.constraint(equalToConstant: 80)
        heightConstraint.isActive = true
       
        connectMBV.backgroundColor = UIColor.green
        
        footerView.addSubview(connectMBV)
        connectMBV.addSubview(stepsImgView)
        connectMBV.addSubview(rightImgView)
        connectMBV.addSubview(stepsCountLbl)
        connectMBV.addSubview(stepsConnectLbl)
        
     
        
        connectMBV.translatesAutoresizingMaskIntoConstraints = false
        stepsImgView.translatesAutoresizingMaskIntoConstraints = false
        rightImgView.translatesAutoresizingMaskIntoConstraints = false
        stepsCountLbl.translatesAutoresizingMaskIntoConstraints = false
        stepsConnectLbl.translatesAutoresizingMaskIntoConstraints = false
        
        //----------make constraint
        NSLayoutConstraint.activate([
            connectMBV.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            connectMBV.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
            stepsImgView.leadingAnchor.constraint(equalTo: connectMBV.leadingAnchor, constant: 20),
            stepsImgView.topAnchor.constraint(equalTo: connectMBV.topAnchor, constant: 20),
            stepsImgView.bottomAnchor.constraint(equalTo: connectMBV.bottomAnchor, constant: -20),
            stepsImgView.centerYAnchor.constraint(equalTo: connectMBV.centerYAnchor),
            stepsImgView.widthAnchor.constraint(equalToConstant: 42),
            stepsImgView.heightAnchor.constraint(equalToConstant: 42),
           
            stepsCountLbl.leadingAnchor.constraint(equalTo: stepsImgView.trailingAnchor, constant: 8),
            stepsCountLbl.centerYAnchor.constraint(equalTo: stepsImgView.centerYAnchor, constant: 0),

            rightImgView.trailingAnchor.constraint(equalTo: connectMBV.trailingAnchor, constant: -20),
            rightImgView.centerYAnchor.constraint(equalTo: stepsImgView.centerYAnchor),
            rightImgView.heightAnchor.constraint(equalToConstant: 20),
            rightImgView.widthAnchor.constraint(equalToConstant: 20),
            
            stepsConnectLbl.trailingAnchor.constraint(equalTo: rightImgView.leadingAnchor, constant: -4),
            stepsConnectLbl.centerYAnchor.constraint(equalTo: rightImgView.centerYAnchor),
            stepsConnectLbl.leadingAnchor.constraint(greaterThanOrEqualTo: stepsCountLbl.trailingAnchor, constant: 12)
        ])
        
        stepsConnectLbl.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        stepsConnectLbl.setContentHuggingPriority(UILayoutPriority(1000), for: .horizontal)
        stepsCountLbl.numberOfLines = 2
        stepsConnectLbl.numberOfLines = 2
      
        //-------------Set Input Data
        stepsImgView.image = UIImage(named: "ic_running_ jogging")
        rightImgView.image = AppImages.arrow_right
        stepsCountLbl.text = "Steps Count"
        stepsConnectLbl.text = "Connect"
        stepsCountLbl.textColor = UIColor.appWhite
        stepsConnectLbl.textColor = UIColor.appWhite
        
        stepsImgView.backgroundColor = UIColor.mainBg
        
        return footerView
   }()
    */
    
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        UITableView.automaticDimension
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return
//    }
    
}

