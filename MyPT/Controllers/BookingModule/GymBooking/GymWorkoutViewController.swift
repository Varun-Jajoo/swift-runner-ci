//
//  GymWorkoutViewController.swift
//  MyPT
//
//  Created by techsaga corp on 11/12/24.
//

import UIKit
import Mixpanel

class GymWorkoutViewController: CommonViewController {

    //MARK: -------------VARIABEL
    var isGridShow:Bool?
    var inputType:String?
    var inputIs_filter:String?
    var inputLat:Double?
    var inputLong:Double?
    var gymTagData:[TagModel]? = []
    var studiosData:[TrainerModel]? = []
    var categorySelectedIndex:IndexPath?
    var flowGymwork:calendarFlow = .defaultFlow
    var inputParam: DetailsParam?
    var hasGymPackage: Bool? = false
//    var gymCountNear: Int? {
//        didSet{
//            self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["\(gymCountNear ?? 0) Gyms Near You."], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        }
//    }
    
    //MARK: ----------------IBOUTLET
//    @IBOutlet weak var searchMBV: UIView!
//    @IBOutlet weak var searchLocBtn: UIButton!
//    @IBOutlet weak var searchTxtField: UITextField!
//    @IBOutlet weak var selectLocBtn: UIButton!
    @IBOutlet weak var categoryCollView: UICollectionView!
    @IBOutlet weak var categoryCollHieghtConstrnt: NSLayoutConstraint!
    @IBOutlet weak var trainerListTblView: UITableView!
    @IBOutlet weak var trainerGridCollView: UICollectionView!
    @IBOutlet weak var tblMBV: UIView!
    @IBOutlet weak var collMBV: UIView!
    @IBOutlet weak var btnFilter: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setUpUI()
        self.categorySelectedIndex = IndexPath(row: 0, section: 0)
        self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
        
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
    
    private func setNavUI(){
//        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["\(gymCountNear ?? 0) Gyms Near You."], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [" Gyms"], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.grid?.resized(to: CGSize(width: 20.0, height: 20.0)), AppImages.menuNav?.resized(to: CGSize(width: 20.0, height: 20.0))], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            self.categoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.categoryCollView.delegate?.collectionView?(self.categoryCollView, didSelectItemAt: firstIndexPath)
            self.view.layoutIfNeeded()
        }
        */
    }
    
    
    override func rightBtnActn(sender: UIButton) {
        TapticEngine.selection.feedback()
        if sender.tag != 2 {
            let grid: UIImage? = (sender.tag == 0 ? AppImages.selected_grid : AppImages.grid)
            let list: UIImage? = (sender.tag == 1 ? AppImages.menuNav : AppImages.unselectedList)
            
            self.setRighMenu(rightImgs: [grid?.resized(to: CGSize(width: 25.0, height: 25.0)), list?.resized(to: CGSize(width: 25.0, height: 25.0))], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
            
            if sender.tag == 0 {
                print("Gridlayout")
                self.isGridShow = true
                trainerGridCollView.reloadData()
                tblMBV.isHidden = true
                collMBV.isHidden = false
                
            }else if sender.tag == 1{
                print("show list view")
                self.isGridShow = false
                trainerListTblView.reloadData()
                tblMBV.isHidden = false
                collMBV.isHidden = true
                
            }else{
                print("cliecked at search...")
                
                /*
                 if let isFromHome = isFromHome, isFromHome {
                 let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
                 vc.searchStr = "Trainers"
                 vc.searchTrainerData = self.trainerData
                 vc.seacrhGymTrainerData = nil
                 self.navigationController?.pushViewController(vc, animated: true)
                 }else{
                 let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
                 vc.searchStr = "Trainers"
                 vc.searchTrainerData = nil
                 vc.seacrhGymTrainerData = self.gymTrainerData
                 self.navigationController?.pushViewController(vc, animated: true)
                 }
                 */
                
                //            let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
                //            vc.searchStr = "Trainers"
                //            vc.searchTrainerData = self.trainerData
                //            vc.seacrhGymTrainerData = self.gymTrainerData
                //            self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if sender.tag == 2  {
//            self.navSearchUI()
            
                        
            /*
            if let isFromHome = isFromHome, isFromHome {
            let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
            vc.searchStr = "Trainers"
            vc.searchTrainerData = self.trainerData
            vc.seacrhGymTrainerData = nil
            self.navigationController?.pushViewController(vc, animated: true)
            }else{
            let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
            vc.searchStr = "Trainers"
            vc.searchTrainerData = nil
            vc.seacrhGymTrainerData = self.gymTrainerData
            self.navigationController?.pushViewController(vc, animated: true)
            }
            
            */
        }
    }
    
    @IBAction func searchLocBtnActn(_ sender: Any) {
//        print("search btn clicked..")
//
//        GetLocationManager.shared.presentSearchPlace(from: self, completion: { [weak self] placeData in
//            guard let self = self else { return  }
//            self.searchTxtField.text = nil
//            self.searchTxtField.text = placeData.name
//            self.inputLong = "\(placeData.coordinate.longitude)"
//            self.inputLat = "\(placeData.coordinate.latitude)"
//            self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
//        })
    }
    
    private func setUpUI() {
//        self.searchTxtField.text = appUserDefaults.getCurrentAddr() //GetLocationManager.shared.getCurrentAddr.0
//
//        searchLocBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
//        searchTxtField.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        //-------------------Register collectionview
        trainerGridCollView.register(UINib(nibName: "GridTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridTrainerCollectionViewCell")
        categoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
       
        self.trainerListTblView.register(UINib(nibName: "GymWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "GymWorkoutTableViewCell")
        
        trainerListTblView.delegate = self
        trainerListTblView.dataSource = self
        trainerGridCollView.delegate = self
        trainerGridCollView.dataSource = self
        btnFilter.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 32/255, green: 41/255, blue: 32/255, alpha: 1), cornerRadious: 8.0)
        btnFilter.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        tblMBV.isHidden = false
        collMBV.isHidden = true
        trainerListTblView.reloadData()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        if categoryCollView.contentSize.height != 0 {
            self.categoryCollHieghtConstrnt.constant = self.categoryCollView.contentSize.height
            self.categoryCollView.layoutIfNeeded()
        }
        view.layoutIfNeeded()
    }
}


//MARK: ---------------EXTENSION FOR UICOLLECTIONVIEW DELEGATE/DATASOURCR
extension GymWorkoutViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == trainerGridCollView {
            return collectionView.numberOfRows(count: self.studiosData?.count ?? 3, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
        } else {
            return gymTagData?.count ?? 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == trainerGridCollView {
            let cell:GridTrainerCollectionViewCell = trainerGridCollView.dequeueReusableCell(withReuseIdentifier: "GridTrainerCollectionViewCell", for: indexPath) as! GridTrainerCollectionViewCell
            
            //            cell.landMarkBtn.titleLabel?.numberOfLines = 1
            cell.distanceBtn.titleLabel?.numberOfLines = 1
            //            cell.landMarkBtn.titleLabel?.lineBreakMode = .byClipping
            cell.distanceBtn.titleLabel?.lineBreakMode = .byClipping
            
            //            if let isFromHome = isFromHome, isFromHome {
            cell.trainerTagsData = self.studiosData?[indexPath.row].activity
            cell.setupCellData(trainerData: self.studiosData?[indexPath.row])
            cell.viewProfileBtn.accessibilityHint = "\(self.studiosData?[indexPath.row].id ?? 0)"
            cell.viewProfileBtn.addTarget(self, action: #selector(viewDetailsBtnActn(sender: )), for: .touchUpInside)
            
            //            }else{
            //                cell.trainerTagsData = self.gymTrainerData?[indexPath.row].tags
            //                cell.setGymCellData(trainerData: self.gymTrainerData?[indexPath.row])
            //            }
            
            return cell
        } else {
            let cell: WorkoutCategoryCollectionViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            
            DispatchQueue.main.async {
                if self.categorySelectedIndex?.row == indexPath.row {
                    cell.cellMBV.backgroundColor = UIColor(red: 19.0/255.0, green: 31.0/255.0, blue: 10.0/255.0, alpha: 1.0)
                    cell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 103.0/255.0, green: 119.0/255.0, blue: 36.0/255.0, alpha: 1.0), cornerRadious: 8.0)
                } else {
                    cell.cellMBV.backgroundColor = UIColor.clear
                    cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: cell.cellMBV.frame.size.height/2.0)
                }
            }
            cell.categoryImgView.loadImage(urlString: self.gymTagData?[indexPath.row].image as? String, placeholder: UIImage())
            cell.categoryTitleLbl.text = self.gymTagData?[indexPath.row].name as? String
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollView {
            if indexPath.row > 0 {
                self.getTrainerApi(inputFilter: "1", inpuntTagId: self.gymTagData?[indexPath.row].id as? Int)
            } else {
                self.getTrainerApi(inputFilter: "0", inpuntTagId: self.gymTagData?[indexPath.row].id as? Int)
            }
            self.categorySelectedIndex = indexPath
            collectionView.reloadData()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == trainerGridCollView {
            let cellWdth = collectionView.frame.size.width * 0.46
            return CGSize(width: cellWdth, height: cellWdth * 1.5)
        } else  if collectionView == categoryCollView {
            return CGSize(width: collectionView.frame.size.width, height: 32)
        } else {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}

extension GymWorkoutViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.numberOfRows(count: self.studiosData?.count ?? 3, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:GymWorkoutTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "GymWorkoutTableViewCell", for: indexPath) as! GymWorkoutTableViewCell
           
        cell.setupCellData(studioData: self.studiosData?[indexPath.row])
        cell.trainerTagsData = self.studiosData?[indexPath.row].activity
        
        cell.viewDetailsBtn.addTarget(self, action: #selector(viewDetailsBtnActn(sender: )), for: .touchUpInside)
        cell.selectViewBtn.addTarget(self, action: #selector(selectGymBtnActn(sender: )), for: .touchUpInside)
        cell.selectViewBtn.accessibilityHint = String(self.studiosData?[indexPath.row].id ?? 0)
        cell.viewDetailsBtn.accessibilityHint = String(self.studiosData?[indexPath.row].id ?? 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let vc:GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
 
    //MARK: -----------------BTN ACTN
    @objc func viewDetailsBtnActn(sender: UIButton){
        let vc: GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
        let getIndx = self.studiosData?.firstIndex(where: {
            $0.id == Int(sender.accessibilityHint ?? "0")
        })
        vc.inputStudioId = sender.accessibilityHint
        vc.inputLat = self.inputLat
        vc.inputLong = self.inputLong
        vc.inputType = self.inputType
        vc.gymDetailsFlow = flowGymwork
        vc.hasGymPackage = hasGymPackage
        var inputData = self.inputParam
        inputData?.studio_id = "\(self.studiosData?[getIndx ?? 0].id ?? 0)"
        vc.inputParam = inputData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectGymBtnActn(sender: UIButton) {
        let getIndx = self.studiosData?.firstIndex(where: {
            $0.id == Int(sender.accessibilityHint ?? "0")
        })
        if flowGymwork == .withoutTrainerMembership {
            Mixpanel.mainInstance().track(
                event: "Buy_Membership_Tapped",
                properties: [:]
            )
            let vc: PackagesVC = PackagesVC.instantiate(appStoryboard: .purchase)
            vc.studioIdStr = self.inputParam?.studio_id
            vc.flowGymwork = self.flowGymwork
            vc.inputType = self.inputType
            vc.package_type = "4" // -> Gym membership
            var inputData = self.inputParam
            inputData?.studio_id = "\(self.studiosData?[getIndx ?? 0].id ?? 0)"
            inputData?.package_type = "4" 
            vc.inputParam = inputData
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            if inputParam?.isFreeAssessmentSelected ?? false { // Only for Free Assessment flow
                let vc: TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
                vc.flowSlot = .bookTrainerHomeWorkout
                vc.isFromHome = false
                vc.inputType = "gym"
                vc.inputLat = self.inputLat
                vc.inputLong = self.inputLong
                vc.studioId = "\(self.studiosData?[getIndx ?? 0].id ?? 0)"
                var inputData = self.inputParam
                inputData?.studio_id = "\(self.studiosData?[getIndx ?? 0].id ?? 0)"
                vc.inputParam = inputData
                navigationController?.pushViewController(vc, animated: true)
            } else {
                if hasGymPackage ?? false {
                    let vc: ChoosePrimaryTrainerVC = ChoosePrimaryTrainerVC.instantiate(appStoryboard: .purchase)
                    //                vc.packageType = packageType
                    vc.inputType = "gym"
                    vc.inputLat = self.inputLat
                    vc.inputLong = self.inputLong
                    var inputData = self.inputParam
                    inputData?.studio_id = "\(self.studiosData?[getIndx ?? 0].id ?? 0)"
                    vc.inputParam = inputData
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc: CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
                    vc.inputType = "gym"
                    vc.inputLat = self.inputLat
                    vc.inputLong = self.inputLong
                    var inputData = self.inputParam
                    inputData?.studio_id = "\(self.studiosData?[getIndx ?? 0].id ?? 0)"
                    vc.inputParam = inputData
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
//        switch flowGymwork {
//        case .bookTrainerGymWorkout:
//            let vc: CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
//            let getIndx = self.studiosData?.firstIndex(where: {
//                $0.id == Int(sender.accessibilityHint ?? "0")
//            })
//            vc.inputType = "gym"
//            vc.inputLat = self.inputLat
//            vc.inputLong = self.inputLong
//            vc.inputParam = DetailsParam(
//                studio_id: "\(self.studiosData?[getIndx ?? 0].id ?? 0)",
//                type: "gym",
//                long: "\(self.inputLong ?? 0.0)",
//                lat: "\(self.inputLat ?? 0.0)"
//            )
////            vc.createParams = CreatePackageParamsModel(
////                package_type: "",
////                sessions: "",
////                type: inputGetSlotParams?.type,
////                timing: inputGetSlotParams?.timing,
////                trainer_id: inputGetSlotParams?.trainer_id,
////                studio_id: inputGetSlotParams?.studio_id,
////                month: "\(Int(self.getMonth(inputDateStr: selectedDate ?? "").0) ?? 0)",
////                address_id: inputGetSlotParams?.address_id
////            )
////            vc.avialCalanderparams = self.avialCalanderparams
////            vc.isFirst = false
//            self.navigationController?.pushViewController(vc, animated: true)
//            
//        case .bookTrainerHomeWorkout, .createPackage, .defaultFlow:
//            let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
//            vc.isFromHome = false
//            vc.studioId = sender.accessibilityHint
//            vc.inputLat = self.inputLat
//            vc.inputLong = self.inputLong
//            vc.inputType = self.inputType
//            vc.flowSlot = flowGymwork
//            self.navigationController?.pushViewController(vc, animated: true)
//            
//        case .gymMembership:
//            print("gymMembership")
//        case .withTrainerMembership:
//            print("withTrainerMembership")
//            
//            let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
//            vc.isFromHome = false
//            vc.studioId = sender.accessibilityHint
//            vc.inputLat = self.inputLat
//            vc.inputLong = self.inputLong
//            vc.inputType = self.inputType
//            //--------------Flow for membership
//            vc.flowSlot = flowGymwork
//            self.navigationController?.pushViewController(vc, animated: true)
//            
//        case .withoutTrainerMembership:
//            let vc:ChooseSessionViewController = ChooseSessionViewController.instantiate(appStoryboard: .booking)
//            vc.validityMembershipParam = (sender.accessibilityHint,"1")
//            vc.flowSession = .validityMembership
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
}

//MARK: -------------EXTENSION FOR API
extension GymWorkoutViewController{
    //MARK: --------------------GET TRAINER LIST API
    private func getTrainerApi(inputFilter: String?, inpuntTagId: Int?) {
        let params: [String: String] = [
            "type": self.inputType ?? "",
            "is_filter": inputFilter ?? "",
            "tag_id": "\(inpuntTagId ?? 0)" ,
            "long": "\(self.inputLong ?? 0.0)",
            "lat": "\(self.inputLat ?? 0.0)"
        ]
        
        TrainerVM.gerTrainerApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("get trainer list result data: ", getResultData as Any)
            
            self.gymTagData?.removeAll()
            self.studiosData?.removeAll()
            self.gymTagData?.append(contentsOf: getResultData.data?.tags ?? [])
            self.studiosData?.append(contentsOf: getResultData.data?.studios ?? [])
            
            //-------------------Reload to set data
            let tagModelData = TagModel(id: 1, name: "All Workouts", description: "", icon: "", image: "")
            
            self.gymTagData?.insert(tagModelData, at: 0)
            self.categoryCollView.reloadData()
            
            if let isGridshow = self.isGridShow, isGridshow {
                self.trainerGridCollView.reloadData()
            } else {
                self.trainerListTblView.reloadData()
            }
            //            self.trainerListTblView.reloadData()
            
            //            self.gymCountNear = self.studiosData?.count
            
        })
    }
}
