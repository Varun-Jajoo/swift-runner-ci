//
//  SleepGoalsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 13/02/25.
//

import UIKit

class SleepGoalsViewController: CommonViewController {

    //MARK: ------------------VARIABLR
    var insightData:[[String:Any]]?
    
    
    //MARK: -------------------IBOUTLET
    @IBOutlet weak var daysMBV: UIView!
    @IBOutlet weak var upcomingClassMBV: UIView!
    @IBOutlet weak var dailyInsightMBV: UIView!
    @IBOutlet weak var daysSegment: UISegmentedControl!
    @IBOutlet weak var nightModeMBV: UIView!
    @IBOutlet weak var dayModeMBV: UIView!
    @IBOutlet weak var sleptAtNightLbl: UILabel!
    @IBOutlet weak var sleptAtDayLbl: UILabel!
    @IBOutlet weak var morningTitleLbl: UILabel!
    @IBOutlet weak var morningDescLbl: UILabel!
    @IBOutlet weak var dailyInsightTitle: UILabel!
    @IBOutlet weak var sleptNightBtn: UIButton!
    @IBOutlet weak var sleptDayBtn: UIButton!
    @IBOutlet weak var editGoalsBtn: UIButton!
    @IBOutlet weak var dailyInsightCollView: UICollectionView!
    @IBOutlet weak var dailyInsightCollViewHeightConstrnt: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupFont()
        
        insightData = [
            ["title":"Deep Sleep","colorInfo":UIColor(red: 83.0/255.0, green: 32.0/255.0, blue: 189.0/255.0, alpha: 1.0)],
            ["title":"Light Sleep","colorInfo":UIColor(red: 127.0/255.0, green: 201.0/255.0, blue: 204.0/255.0, alpha: 1.0)],
            ["title":"REM","colorInfo":UIColor(red: 196.0/255.0, green: 209.0/255.0, blue: 128.0/255.0, alpha: 1.0)],
            ["title":"Awake","colorInfo":UIColor(red: 209.0/255.0, green: 163.0/255.0, blue: 129.0/255.0, alpha: 1.0)]
        ]
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Sleep"], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [UIImage(named: "ic_mostPopularchart")], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func setupUI(){
        dailyInsightCollView.register(UINib(nibName: "DailyInsightCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DailyInsightCollectionViewCell")
        
        DispatchQueue.main.async {
            self.daysSegment.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.editGoalsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
           
            self.daysSegment.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0)
            self.daysSegment.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
        
        //--------------------***************
     
        self.daysSegment.selectedSegmentIndex = 0
        
        self.daysSegment.setTitleTextAttributes([.foregroundColor: UIColor.mainBg, .font : AppFont.semibold.size(14.0, familyName: familyManrope)], for: .selected)
        self.daysSegment.setTitleTextAttributes([.foregroundColor: UIColor.appWhite, .font: AppFont.semibold.size(14.0, familyName: familyManrope)], for: .normal)
        
        self.flowSetup(flow: 0)
    }
    
    func setupFont(){
//        self.daysSegment
        self.sleptAtNightLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.sleptAtDayLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.morningTitleLbl.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.morningDescLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.dailyInsightTitle.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.sleptNightBtn.titleLabel?.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.sleptDayBtn.titleLabel?.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.editGoalsBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    //MARK: -------------------DAYA SEGMENT ACTN
    @IBAction func daysSegActn(_ sender: UISegmentedControl) {
        self.flowSetup(flow: sender.selectedSegmentIndex)
    }
    
    //MARK: --------------------EDIT GOALS BTN ACTN
    @IBAction func editGoalsBtnActn(_ sender: UIButton) {
        print("edit Goals btn action")
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if self.dailyInsightCollView.contentSize.height != 0 {
            self.dailyInsightCollViewHeightConstrnt.constant = self.dailyInsightCollView.contentSize.height
        }
        self.view.layoutIfNeeded()
    }
    
    //MARK: -----------FLOW SET
    func flowSetup(flow: Int){
        if flow == 0 {
            self.daysMBV.isHidden = false
            self.upcomingClassMBV.isHidden = true
            self.dailyInsightMBV.isHidden = false
        }
        else if flow == 1 {
            self.daysMBV.isHidden = false
            self.upcomingClassMBV.isHidden = true
            self.dailyInsightMBV.isHidden = false
        }
        else if flow == 2 {
            self.daysMBV.isHidden = true
            self.upcomingClassMBV.isHidden = false
            self.dailyInsightMBV.isHidden = false
        }
    }
}

//MARK: --------------------------UICOLLECTIONVIEW DELEGATE/ DATASOURCE
extension SleepGoalsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return insightData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:DailyInsightCollectionViewCell = dailyInsightCollView.dequeueReusableCell(withReuseIdentifier: "DailyInsightCollectionViewCell", for: indexPath) as! DailyInsightCollectionViewCell
        
        let tintColor = insightData?[indexPath.row]["colorInfo"] as? UIColor
        
        cell.insightModeBtn.setTitle(insightData?[indexPath.row]["title"] as? String, for: .normal)
        
        cell.insightModeBtn.setImage(UIImage(named: "ic_fastFilling")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cell.insightModeBtn.tintColor = tintColor
        
        cell.infoBtn.tag = 401 + indexPath.row
        cell.infoBtn.addTarget(self, action: #selector(infoBtnActn(sender: )), for: .touchUpInside)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let widthCell = collectionView.frame.width*0.49
        //widthCell*0.7
        return CGSize(width: widthCell, height: 140.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    @objc func infoBtnActn(sender: UIButton){
       
        let popupVC:DailyInsightPopupViewController = DailyInsightPopupViewController.instantiate(appStoryboard: .more)
        popupVC.modalPresentationStyle = .popover
//        popupVC.preferredContentSize = CGSize(width: 200, height: 100)
        popupVC.view.backgroundColor = UIColor.appWhite
        if let popoverController = popupVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
        }
        present(popupVC, animated: false)
        
    }
}

// MARK: ------------ UIPopoverPresentationControllerDelegate
extension SleepGoalsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none  // Keeps it as a popover on iPhone instead of full-screen
    }
}
