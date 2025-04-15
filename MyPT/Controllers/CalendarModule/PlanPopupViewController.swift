//
//  PlanPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/12/24.
//

import UIKit

enum PlanPopupFlow {
    case planselect
    case remind
    case checkListActiveSession
    case productSortBy
    case planpopupDefault
}

class PlanPopupViewController: UIViewController {

    //MARK: ----------VARIABLE
    var planListData:[[String:Any]]?
    var planFlowSetup:PlanPopupFlow = .planpopupDefault
    var navCtrnl:UINavigationController?
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var popupMBV: UIView!
    @IBOutlet weak var topBarBtn: UIButton!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var popTitleLbl: UILabel!
    @IBOutlet weak var planListTbl: UITableView!
    @IBOutlet weak var planListTblHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var planListTblLeadingConstrnt: NSLayoutConstraint!
    @IBOutlet weak var planListTblTrailingConstrnt: NSLayoutConstraint!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      setupInputData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        //-----------------**************###### Flow Setup
        switch planFlowSetup {
        case .planselect:
            print("planselect")
        case .remind:
            print("remind")
//            self.view.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: {
//                print("Animation done.")
//            })
        case .productSortBy:
            print("Product sort by")
        case .planpopupDefault:
            print("planpopupDefault")
        case .checkListActiveSession:
            print("checkListActiveSession")
        }
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
   
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    func setupUI(){
        
        DispatchQueue.main.async {
            self.popupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            
            self.popupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.doneBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appDarkGray, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.popTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.clearBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.doneBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    func setupInputData(){
        self.setupFont()
        self.enableContinueBtn(isSelected: false, btn: doneBtn)
        self.doneBtn.isHidden = true
        
        //-----------------**************###### Flow Setup
        switch planFlowSetup {
        case .planselect:
            print("planselect")
        case .remind:
            print("remind")
            self.doneBtn.isHidden = false
            
            self.popTitleLbl.text = "Remind Me"
            self.planListTblLeadingConstrnt.constant = 19.0
            self.planListTblTrailingConstrnt.constant = 19.0
            self.planListTbl.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
            
            self.planListData = [
                ["title":"5 Minutes Before","trainerImg":""],
                ["title":"10 Minutes Before","trainerImg":""],
                ["title":"15 Minutes Before","trainerImg":""],
                ["title":"30 Minutes Before","trainerImg":""],
                ["title":"1 Hour Before","trainerImg":""],
                ["title":"6 Hour Before","trainerImg":""],
                ["title":"1 day Before","trainerImg":""]
            ]
            self.planListTbl.reloadData()
            
        case .checkListActiveSession:
            self.popTitleLbl.text = "Checklist Items"
            self.planListTbl.register(UINib(nibName: "CheckListTableViewCell", bundle: nil), forCellReuseIdentifier: "CheckListTableViewCell")
           
            self.planListData = [
                ["title":"Space","trainerImg":""],
                ["title":"Space","trainerImg":""],
                ["title":"Space","trainerImg":""],
                ["title":"Space","trainerImg":""],
                ["title":"Space","trainerImg":""],
                ["title":"Space","trainerImg":""],
                ["title":"Space","trainerImg":""]
            ]
            self.planListTbl.reloadData()
            
        case .productSortBy:
            
            self.enableContinueBtn(isSelected: true, btn: doneBtn)
            self.doneBtn.isHidden = false
            
            self.planListTblLeadingConstrnt.constant = 19.0
            self.planListTblTrailingConstrnt.constant = 19.0
            self.popTitleLbl.text = "Sort By"
            self.planListTbl.register(UINib(nibName: "PointsTableViewCell", bundle: nil), forCellReuseIdentifier: "PointsTableViewCell")
           
            self.planListData = [
                ["title":"Price (Highest First)","trainerImg":""],
                ["title":"Price (Lowest First)","trainerImg":""],
                ["title":"Discount","trainerImg":""],
                ["title":"Ratings","trainerImg":""],
                ["title":"Relevance","trainerImg":""]
            ]
            self.planListTbl.reloadData()
            
        case .planpopupDefault:
            print("planpopupDefault")
            self.popTitleLbl.text = "Plan your fitness journey"
            self.planListTbl.register(UINib(nibName: "PlanListTableViewCell", bundle: nil), forCellReuseIdentifier: "PlanListTableViewCell")
            self.planListTblLeadingConstrnt.constant = 1.0
            self.planListTblTrailingConstrnt.constant = 1.0
            
            self.planListData = [
                ["title":"Schedule Personal Workout","trainerImg":AppImages.personal_workout as Any],
                ["title":"Book a Trainer at Home","trainerImg":AppImages.trainer_AtHome as Any],
                ["title":"Book Trainer at Gym","trainerImg":AppImages.trainer_atGym as Any]
            ]
            self.planListTbl.reloadData()
        }
    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false, btn:UIButton){
        if isSelected {
            btn.isUserInteractionEnabled = true
            btn.backgroundColor = UIColor.appWhite
            btn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            btn.isUserInteractionEnabled = false
            btn.backgroundColor = UIColor.appDarkGray
            btn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    @IBAction func commonBtnActn(sender:UIButton){
        print("common btn clicked..")
        self.dismiss(animated: true, completion: {
            print("complition is done....")
        })
    }
    
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        let vcHeight = (self.view.frame.size.height*0.6)
        
        planListTblHeightConstrnt.constant = planListTbl.contentSize.height < vcHeight ? planListTbl.contentSize.height : vcHeight
        self.view.layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
                  if !self.popupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
    
}

//MARK: ---------------EXTENSION UITABLEVIEW DELEGATE/DATASOURCE
extension PlanPopupViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planListData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
//        let cell:PlanListTableViewCell = planListTbl.dequeueReusableCell(withIdentifier: "PlanListTableViewCell", for: indexPath) as! PlanListTableViewCell
//        cell.planLogoImgView.image = planListData?[indexPath.row]["trainerImg"] as? UIImage
//        cell.planTitleLbl.text =  planListData?[indexPath.row]["title"] as? String
//        return cell
        
        switch planFlowSetup {
        case .planselect:
            print("planselect")
        case .remind:
            print("remind")
            let cell:PointsTableViewCell = planListTbl.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
            cell.titleLbl.text =  planListData?[indexPath.row]["title"] as? String
           
            cell.leftImgView.image = UIImage(named: "ic_filterUncheck")
            
            return cell
            
        case .checkListActiveSession:
            let checkListCell:CheckListTableViewCell = planListTbl.dequeueReusableCell(withIdentifier: "CheckListTableViewCell", for: indexPath) as! CheckListTableViewCell
            
            return checkListCell
            
        case .productSortBy:
            let cell:PointsTableViewCell = planListTbl.dequeueReusableCell(withIdentifier: "PointsTableViewCell", for: indexPath) as! PointsTableViewCell
            cell.titleLbl.text =  planListData?[indexPath.row]["title"] as? String
           
            cell.leftImgView.image = AppImages.filterUncheck
            
            return cell
            
        case .planpopupDefault:
            print("planpopupDefault")
            let cell:PlanListTableViewCell = planListTbl.dequeueReusableCell(withIdentifier: "PlanListTableViewCell", for: indexPath) as! PlanListTableViewCell
            cell.planLogoImgView.image = planListData?[indexPath.row]["trainerImg"] as? UIImage
            cell.planTitleLbl.text =  planListData?[indexPath.row]["title"] as? String
            return cell
 
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch planFlowSetup {
        case .planselect:
            print("planselect")
            
//            self.dismiss(animated: true, completion: {
//                let vc:TimeSlotPopupViewController = TimeSlotPopupViewController.instantiate(appStoryboard: .calendar)
//                
//                vc.modalPresentationStyle = .automatic
//                self.navigationController?.present(vc, animated: true)
//            })
   
        case .remind:
            print("remind")
            let selectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
            selectedCell.leftImgView.image = UIImage(named: "ic_filterChecked")
            
            self.enableContinueBtn(isSelected: true, btn: doneBtn)
            
        case .checkListActiveSession:
            print("checkListActiveSession")
            
        case .productSortBy:
            print("product sort by")
            let deselectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
            deselectedCell.leftImgView.image = AppImages.filterChecked
            
        case .planpopupDefault:
            print("planpopupDefault")
            if indexPath.row == 0 {
                self.dismiss(animated: true, completion: {
                    let vc:TimeSlotPopupViewController = TimeSlotPopupViewController.instantiate(appStoryboard: .calendar)
                    vc.modalPresentationStyle = .automatic
                    vc.navCtrl = self.navCtrnl
                    vc.timePopFlow = .personalWorkout
                    self.navCtrnl?.present(vc, animated: false)
                })
            }
            else if indexPath.row == 1 {
                self.dismiss(animated: true, completion: {
                    let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
                    vc.flowSlot = calendarFlow.bookTrainerHomeWorkout
                    self.navCtrnl?.pushViewController(vc, animated: true)
                })
            }
            else if indexPath.row == 2 {
                self.dismiss(animated: true, completion: {
                    let vc:GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
                    //        vc.flowSlot = calendarFlow.bookTrainer
                    self.navCtrnl?.pushViewController(vc, animated: true)
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        switch planFlowSetup {
        case .planselect:
            print("planselect")
        case .remind:
            print("remind")
            let deselectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
            deselectedCell.leftImgView.image = UIImage(named: "ic_filterUncheck")
            
        case .checkListActiveSession:
            print("checkListActiveSession")
            
        case .productSortBy:
            let deselectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
            deselectedCell.leftImgView.image = AppImages.filterUncheck
            
        case .planpopupDefault:
            print("planpopupDefault")
       
        }
    }
   
}
