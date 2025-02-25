//
//  SessionStatusViewController.swift
//  MyPT
//
//  Created by techsaga corp on 14/01/25.
//

import UIKit

class SessionStatusViewController: CommonViewController {

    //MARK: --------------IBOUTLET
    @IBOutlet weak var worksummaryTitleLbl: UILabel!
    @IBOutlet weak var workoutListTblView: UITableView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var workoutListTblViewHeightConstrnt: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupFont()
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
    
    func setupUI(){
        self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
    }
    
    func setupFont(){
        
        self.workoutListTblView.register(UINib(nibName: "WorkoutSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "WorkoutSummaryTableViewCell")
        self.workoutListTblView.isMultipleTouchEnabled = true
        
        //---------------***********
        self.worksummaryTitleLbl.font = AppFont.medium.size(16.0, familyName: familyManrope)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:WorkoutSummaryTableViewCell = workoutListTblView.dequeueReusableCell(withIdentifier: "WorkoutSummaryTableViewCell", for: indexPath) as! WorkoutSummaryTableViewCell
        
        let img = UIImage(named: "ic_femaleplaceholder")?.resized(to: CGSize(width: (cell.frame.width * 0.5), height: cell.frame.size.height))
        cell.workoutImgView.image = img
//        cell.selectionImgView.image = UIImage(named: "ic_checkDay")
        
        if indexPath.row % 2 == 0 {
            cell.selectionImgView.image = UIImage(named: "ic_clock_redbg")
            cell.selectionCell(isSelected: true)
        }else{
            cell.selectionImgView.image = UIImage(named: "ic_checkDay")
            cell.selectionCell(isSelected: false)
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
