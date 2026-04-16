//
//  TopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 09/07/25.
//

import UIKit

enum TopUpFlow {
    case upgrade
    case renew
    case defaultTop
}

class TopupViewController: CommonViewController {

    //MARK: ----------------- VARIABLE
    var planDetails: [PlanDetailsModel]? = []
    var menuData:[[String:Any]]?
    var topUpRenewFlow: TopUpFlow = .defaultTop
    var selectedStr: String? = nil
    var getLat:Double?
    var getLong:Double?
    
    //MARK: ------------------ IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var topupMenuTblView: UITableView!
    @IBOutlet weak var topupMenuTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var noteMBV: UIView!
    @IBOutlet weak var noteDescLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topupMenuTblView.isUserInteractionEnabled = true
        self.setUI()
        self.enableContinueBtn(isSelected: false)
        self.flowSetup()
        
        //---------------- for current locations
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
            self.getLat = Double(lat)
            self.getLong = Double(long)
        }
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
        
        
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)

    }
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("Continue btn clicked.")
        
        switch topUpRenewFlow {
        case .upgrade:
            let vc: TopUpgradeSessionViewController = TopUpgradeSessionViewController.instantiate(appStoryboard: .dashboard)
            if let planDetails = planDetails?.first {
                if let selectedStr = selectedStr {
                    vc.planFlow = ChoosePlanFlow.init(from: selectedStr)
                    let planStr:String = selectedStr == "Top-Up" ? selectedStr.replacingOccurrences(of: "-", with: "").lowercased() : selectedStr.lowercased()
                    vc.upgradeParams = UpgradePlanParamModel(type: planStr, sessions: planDetails.sessions?.value, id: planDetails.id?.value, days: planDetails.validity_days?.value)
                }
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case .renew:
            
            let selectedStr = (selectedStr?.components(separatedBy: " ").first)?.lowercased()
            let getIndx = self.planDetails?.firstIndex(where: {
                $0.type?.value?.lowercased() == selectedStr?.lowercased()
            })
//            let getPlanDetails = self.planDetails?[getIndx]
            if let getIndx = getIndx, let getPlanDetails = self.planDetails?[getIndx],  let existPlan = getPlanDetails.type?.value?.lowercased() {
                if selectedStr == existPlan && getPlanDetails.renew_new == true {
                    let vc: TopUpgradeSessionViewController = TopUpgradeSessionViewController.instantiate(appStoryboard: .dashboard)
                    vc.planFlow = ChoosePlanFlow.init(from: "renew")
                    vc.upgradeParams = UpgradePlanParamModel(type: "renew", sessions: getPlanDetails.sessions?.value, id: getPlanDetails.id?.value, days: getPlanDetails.validity_days?.value)
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    print("move to new create package..")
                    if let getLat = getLat, let getLong = getLong {
                        if existPlan == "home" {
                          
                            //-------Then move to home workout flow
                            let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
                            vc.flowSlot = .bookTrainerHomeWorkout
                            vc.inputType = "home"
                            vc.inputLat = getLat
                            vc.inputLong = getLong
                            vc.isFromHome = true
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }else{
                            //-------Then move to gym workout flow
                            let vc:GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
                            vc.flowGymwork = .bookTrainerGymWorkout
                            vc.inputType = "gym"
                            vc.inputLat = getLat
                            vc.inputLong = getLong
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else{
                        self.getLocation()
                    }
                }
            }else{
                
                if let getLat = getLat, let getLong = getLong {
                    if selectedStr == "home" {
                      
                        //-------Then move to home workout flow
                        let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
                        vc.flowSlot = .bookTrainerHomeWorkout
                        vc.inputType = "home"
                        vc.inputLat = getLat
                        vc.inputLong = getLong
                        vc.isFromHome = true
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }else{
                        //-------Then move to gym workout flow
                        let vc:GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
                        vc.flowGymwork = .bookTrainerGymWorkout
                        vc.inputType = "gym"
                        vc.inputLat = getLat
                        vc.inputLong = getLong
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }else{
                    self.getLocation()
                }

            }
            
            
            /*
             if let selectedStr = selectedStr, let typeStr = (selectedStr.components(separatedBy: " ").first)?.lowercased(),  let existPlan = planDetails?.type?.value?.lowercased() {
             if typeStr == existPlan  {
             let vc: TopUpgradeSessionViewController = TopUpgradeSessionViewController.instantiate(appStoryboard: .dashboard)
             vc.planFlow = ChoosePlanFlow.init(from: "renew")
             vc.upgradeParams = UpgradePlanParamModel(type: "renew", sessions: planDetails?.sessions?.value, id: planDetails?.id?.value, days: planDetails?.validity_days?.value)
             
             self.navigationController?.pushViewController(vc, animated: true)
             }else{
             print("move to new create package..")
             if let getLat = getLat, let getLong = getLong {
             
             if existPlan == "home" {
             //-------Then move to gym workout flow
             let vc:GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
             vc.flowGymwork = .bookTrainerGymWorkout
             vc.inputType = "gym"
             vc.inputLat = "\(getLat)"
             vc.inputLong = "\(getLong)"
             self.navigationController?.pushViewController(vc, animated: true)
             
             }else{
             //-------Then move to home workout flow
             let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
             vc.flowSlot = .bookTrainerHomeWorkout
             vc.inputType = "home"
             vc.inputLat = "\(getLat)"
             vc.inputLong = "\(getLong)"
             vc.isFromHome = true
             self.navigationController?.pushViewController(vc, animated: true)
             }
             }else{
             self.getLocation()
             }
             }
             }
             */
            
            break
        case .defaultTop:
            break
        }
    }
    
    private func flowSetup(){
        self.noteMBV.isHidden = false
        topupMenuTblView.register(UINib(nibName: "TrainerTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerTypeTableViewCell")
        
        switch topUpRenewFlow {
        case .upgrade:
            //------------------------****************
            self.topTitleLbl.text = "Do you want to top-up or upgrade"
            self.noteDescLbl.text = "Only packages with a greater number of sessions, longer validity, or higher cost will be displayed."
            
            menuData = [
                ["title":"Top-Up", "desc":"Add on additional sessions \n to your current package","trainerImg":AppImages.withTrainerMembership as Any, "trainerImg_selected":AppImages.topUPSelected as Any],
                ["title":"Upgrade", "desc":"Only available within 30 days \n of purchase","trainerImg":AppImages.withoutTrainerMembership as Any, "trainerImg_selected":AppImages.withoutTrainerMembership_selected as Any]
            ]
           
            self.topupMenuTblView.reloadData()
            
            //------------------******************
            /*
            if let planDetails = planDetails {
                if let isUpgrade = planDetails.isUpgrade, isUpgrade {
                    if let menuData = menuData, menuData.count > 0 {
                        let indexPath = IndexPath(row: 1, section: 0)
                        self.topupMenuTblView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                        self.topupMenuTblView.delegate?.tableView?(self.topupMenuTblView, didSelectRowAt: indexPath)
                    }
                }else{
                    if let menuData = menuData, menuData.count > 0 {
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.topupMenuTblView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                        self.topupMenuTblView.delegate?.tableView?(self.topupMenuTblView, didSelectRowAt: indexPath)
                    }
                }
            }
            */
            
            break
        case .renew:
            
            self.topTitleLbl.text = "How would you like to train?"
            self.noteMBV.isHidden = true
            self.noteDescLbl.text = nil
            
            menuData = [
                ["title":"Home Workout", "desc":"","trainerImg":AppImages.withTrainerMembership as Any, "trainerImg_selected":AppImages.withTrainerMembership_selected as Any],
                ["title":"Gym Workout", "desc":"","trainerImg":AppImages.withoutTrainerMembership as Any, "trainerImg_selected":AppImages.withoutTrainerMembership_selected as Any]
            ]
            
            self.topupMenuTblView.reloadData()
            
            break
            
        case .defaultTop:
            break
        }
    }
    
    //MARK: -------------GET Lat long
    private func getLocation(){
        GetLocationManager.shared.requestLocationWithAddress {[weak self] location, addressPart in
            guard let self = self, let getLocation = location else { return  }
            appUserDefaults.setLatLong(value: "\(getLocation.coordinate.latitude),\(getLocation.coordinate.longitude)")
            appUserDefaults.setCurrentAddr(value: addressPart.0)
            
            self.getLat = getLocation.coordinate.latitude
            self.getLong = getLocation.coordinate.longitude
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if topupMenuTblView.contentSize.height != 0 {
            self.topupMenuTblViewHeightConstrnt.constant = self.topupMenuTblView.contentSize.height
        }
        view.layoutIfNeeded()
    }
    
    private func setUI(){

        //------------------------###############**************
        topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        noteDescLbl.font = AppFont.regular.size(12.0, familyName: familyOverpassMono)
        continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        //-----------********  UI
        DispatchQueue.main.async {
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.noteMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), cornerRadious: 8.0)
        }
    }
    
}

extension TopupViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TrainerTypeTableViewCell = topupMenuTblView.dequeueReusableCell(withIdentifier: "TrainerTypeTableViewCell", for: indexPath) as! TrainerTypeTableViewCell
        
        cell.titleLbl.isHidden = false
        cell.descLbl.isHidden = true
        cell.titleLbl.text = menuData?[indexPath.row]["title"] as? String
        cell.descLbl.text = menuData?[indexPath.row]["desc"] as? String
        cell.bgImgView.image = menuData?[indexPath.row]["trainerImg"] as? UIImage
        
        if let descStr = (menuData?[indexPath.row]["desc"] as? String), !descStr.isEmpty || descStr != "" {
            cell.descLbl.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.enableContinueBtn(isSelected: true)
        let selectedCell = tableView.cellForRow(at: indexPath) as? TrainerTypeTableViewCell
        guard let selectedCell = selectedCell else { return }
        
        selectedCell.bgImgView.image = menuData?[indexPath.row]["trainerImg_selected"] as? UIImage
        self.selectedStr = menuData?[indexPath.row]["title"] as? String
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath) as? TrainerTypeTableViewCell
        guard let deSelectedCell = deSelectedCell else { return }
        
        deSelectedCell.bgImgView.image = menuData?[indexPath.row]["trainerImg"] as? UIImage
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
       
                
        switch topUpRenewFlow {
        case .upgrade:
            guard let planDetails = planDetails else { return nil }
            
            for planData in planDetails.enumerated() {
                if let isUpgrade = planData.element.isUpgrade {
                    if !isUpgrade {
                        // Only allow selection of row 0
                        return indexPath.row == 0 ? indexPath : nil
                    } else {
                        // Allow selection of any row
                        return indexPath
                    }
                }
            }
            
            break
            
        case .renew:
            
            if let planDetails = planDetails {
                return indexPath
                
                /*
                if planDetails.count > indexPath.row {
                    if let renewNew = planDetails[indexPath.row].renew_new {
                        
                        return indexPath
                        /*
                        if !renewNew {
                            // Only allow selection of row 0
                            if let isUpgrade = planDetails[indexPath.row].isUpgrade {
                                if !isUpgrade {
                                    // Only allow selection of row 0
                                    return indexPath.row == 0 ? indexPath : nil
                                } else {
                                    // Allow selection of any row
                                    return indexPath
                                }
                            }
                        } else {
                            // Allow selection of any row
                            return indexPath
                        }
                        */
                    }
                }else{
                    return indexPath
                }
                */
            }
            
            break
            
        case .defaultTop:
            break
        }
                
        /*
        for planData in planDetails.enumerated() {
            if let isUpgrade = planData.element.isUpgrade {
                if !isUpgrade {
                    // Only allow selection of row 0
                    return indexPath.row == 0 ? indexPath : nil
                } else {
                    // Allow selection of any row
                    return indexPath
                }
            }
        }
        */
        
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
}
