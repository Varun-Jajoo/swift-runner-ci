//
//  TrainerListViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import UIKit

class TrainerListViewController: CommonViewController {

    //MARK: --------------VARIBALE
    var isFromHome:Bool?
    var categorySelectedIndex:IndexPath?
    var flowSlot:calendarFlow = .defaultFlow
    var inputType:String?
    var inputIs_filter:String?
    var inputLat:String?
    var inputLong:String?
    var studioId:String?
    
    var tagData:[TagModel]? = []
    var trainerData:[TrainerModel]? = []
    var gymTrainerData:[GymTrainerModel]? = []
    var isGridShow:Bool?
    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var workoutCategoryCollView: UICollectionView!
    @IBOutlet weak var trainerListTblView: UITableView!
    @IBOutlet weak var trainerGridCollView: UICollectionView!
    @IBOutlet weak var tblMBV: UIView!
    @IBOutlet weak var collMBV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categorySelectedIndex = IndexPath(row: 0, section: 0)
        self.setupUI()
        
        if let isFromHome = isFromHome, isFromHome {
            self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
        }else{
            self.getSelectGymList(inputFilter: "0", inpuntTagId: 0)
        }
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        if let tagData = tagData?.count, tagData > 0 {
//            // Automatically select the first cell
//            let firstIndexPath = IndexPath(item: 0, section: 0)
//            DispatchQueue.main.async {
//                self.workoutCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
//                // Optional: perform any additional setup for the selected cell
//                self.workoutCategoryCollView.delegate?.collectionView?(self.workoutCategoryCollView, didSelectItemAt: firstIndexPath)
//                self.view.layoutIfNeeded()
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.trainers], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.grid, AppImages.menuNav,  AppImages.search_normal], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func rightBtnActn(sender: UIButton) {
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
            let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
            vc.searchStr = "Trainers"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    private func setupUI(){
        workoutCategoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        
        trainerGridCollView.register(UINib(nibName: "GridTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridTrainerCollectionViewCell")
        
        trainerListTblView.register(UINib(nibName: "TrainerListTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerListTableViewCell")
        
        tblMBV.isHidden = false
        collMBV.isHidden = true
        trainerListTblView.reloadData()
    }
    
    
//    private func firstCellSelect(getCount: Int?){
//        if let tagData = getCount, tagData > 0 {
//            let firstIndexPath = IndexPath(item: 0, section: 0)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.workoutCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
//                self.workoutCategoryCollView.delegate?.collectionView?(self.workoutCategoryCollView, didSelectItemAt: firstIndexPath)
//                self.view.layoutIfNeeded()
//            }
//        }
//    }
    
}

//MARK: --------------UICOLLECTIONVIEW DELEGATE/DATASOURCE
extension TrainerListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == trainerGridCollView {
            if let isFromHome = isFromHome, isFromHome {
                return collectionView.numberOfRows(count: self.trainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
            }else{
                return collectionView.numberOfRows(count: self.gymTrainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
            }
            
        }else{
            return tagData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == trainerGridCollView {
            let cell:GridTrainerCollectionViewCell = trainerGridCollView.dequeueReusableCell(withReuseIdentifier: "GridTrainerCollectionViewCell", for: indexPath) as! GridTrainerCollectionViewCell
            
            cell.landMarkBtn.titleLabel?.numberOfLines = 2
            cell.distanceBtn.titleLabel?.numberOfLines = 2
            cell.landMarkBtn.titleLabel?.lineBreakMode = .byClipping
            cell.distanceBtn.titleLabel?.lineBreakMode = .byClipping
//            cell.trainerTagsData = self.trainerData?[indexPath.row].tags
//            cell.setupCellData(trainerData: self.trainerData?[indexPath.row])
            
            if let isFromHome = isFromHome, isFromHome {
                cell.trainerTagsData = self.trainerData?[indexPath.row].tags
                cell.setupCellData(trainerData: self.trainerData?[indexPath.row])
                
            }else{
                cell.trainerTagsData = self.gymTrainerData?[indexPath.row].tags
                cell.setGymCellData(trainerData: self.gymTrainerData?[indexPath.row])
            }
         
            return cell
        }else{
            let cell:WorkoutCategoryCollectionViewCell = workoutCategoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            
            DispatchQueue.main.async {
                if self.categorySelectedIndex?.row == indexPath.row {
                    cell.cellMBV.backgroundColor = UIColor.clear
                    cell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 12.0)
                }else{
                    cell.cellMBV.backgroundColor = UIColor.clear
                    cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
                }
            }
            
            cell.categoryImgView.loadImage(urlString: self.tagData?[indexPath.row].image as? String, placeholder: UIImage(named: "ic_barbell_ diagonal"))
            cell.categoryTitleLbl.text = self.tagData?[indexPath.row].name as? String
        
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == trainerGridCollView {
            
            if let isFromHome = isFromHome, isFromHome {
                
                let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
                vc.inputParam = DetailsParam(trainer_id: "\(self.trainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.trainerData?[indexPath.row].id ?? 0)", type: self.inputType, long: self.inputLat, lat: self.inputLong)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                
                let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
                vc.inputParam = DetailsParam(trainer_id: "\(self.gymTrainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.gymTrainerData?[indexPath.row].studioID ?? "0")", type: self.inputType, long: self.inputLat, lat: self.inputLong)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            
        }else if collectionView == workoutCategoryCollView{
            
            if let isFromHome = isFromHome, isFromHome {
                if indexPath.row > 0 {
                    self.getTrainerApi(inputFilter: "1", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                }else{
                    self.getTrainerApi(inputFilter: "0", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                }
            }else{
                if indexPath.row > 0 {
                    self.getSelectGymList(inputFilter: "1", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                }else{
                    self.getSelectGymList(inputFilter: "0", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                }
            }
           
            self.categorySelectedIndex = indexPath
            collectionView.reloadData()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == trainerGridCollView {
            return CGSize(width: collectionView.frame.size.width*0.46, height: 340)
        }else{
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
    }
    
}

//MARK: --------------UITABLEVIEW DELEGATE/DATASOURCE
extension TrainerListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let isFromHome = isFromHome, isFromHome {
            return tableView.numberOfRows(count: self.trainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
        }else{
            return tableView.numberOfRows(count: self.gymTrainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainerListTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "TrainerListTableViewCell", for: indexPath) as! TrainerListTableViewCell
        if let isFromHome = isFromHome, isFromHome {
            cell.trainerTagsData = self.trainerData?[indexPath.row].tags
            cell.setCellData(trainerData: self.trainerData?[indexPath.row])
            
            cell.bookSlotBtn.accessibilityHint = "\(self.trainerData?[indexPath.row].id ?? 0)"
        }else{
            cell.trainerTagsData = self.gymTrainerData?[indexPath.row].tags
            cell.setGymCellData(trainerData: self.gymTrainerData?[indexPath.row])
           
            cell.bookSlotBtn.accessibilityHint = "\(self.gymTrainerData?[indexPath.row].id ?? 0)"
        }
        
       
        cell.bookSlotBtn.addTarget(self, action: #selector(bookSlotBtnActn(sender: )), for: .touchUpInside)
        
//        cell.bookSlotBtn.addTarget(self, action: #selector(bookSlotBtnActn(sender: )), for: .touchUpInside)
//        cell.trainerTagsData = self.trainerData?[indexPath.row].tags
//        cell.setCellData(trainerData: self.trainerData?[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let isFromHome = isFromHome, isFromHome {
            let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
            vc.inputParam = DetailsParam(trainer_id: "\(self.trainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.trainerData?[indexPath.row].id ?? 0)", type: self.inputType, long: self.inputLat, lat: self.inputLong)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
            vc.inputParam = DetailsParam(trainer_id: "\(self.gymTrainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.gymTrainerData?[indexPath.row].studioID ?? "")", type: self.inputType, long: self.inputLat, lat: self.inputLong)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        
//        let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
//        vc.inputParam = DetailsParam(trainer_id: "\(self.trainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.trainerData?[indexPath.row].id ?? 0)", type: self.inputType, long: self.inputLat, lat: self.inputLong)
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func bookSlotBtnActn(sender:UIButton) {
        
        if let isFromHome = isFromHome, isFromHome {
            let getIndx = self.trainerData?.firstIndex(where: {
                $0.id == Int(sender.accessibilityHint ?? "0")
            })
            
            if let getIndx = getIndx {
                let trainerDetails = self.trainerData?[getIndx]
                
                let vc:SelectYourLocationViewController = SelectYourLocationViewController.instantiate(appStoryboard: .booking)
                vc.trainerIdStr = "\(trainerDetails?.id ?? 0)"
                vc.studioIdStr = studioId
                vc.inputType = self.inputType
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            
            let getIndx = self.gymTrainerData?.firstIndex(where: {
                $0.id == Int(sender.accessibilityHint ?? "0")
            })
            
            if let getIndx = getIndx {
                let trainerDetails = self.gymTrainerData?[getIndx]
                
                
                let currentMonth = Calendar.current.component(.month, from: Date())
                
                let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
                vc.slotBookFlow = .bookTrainer
                vc.params = AvailParmsModel(type: self.inputType, trainer_id: "\(trainerDetails?.id ?? 0)", studio_id: studioId, month: "\(currentMonth)", address_id: "")
                self.navigationController?.pushViewController(vc, animated: true)
                
                
                /*
                let vc:SelectYourLocationViewController = SelectYourLocationViewController.instantiate(appStoryboard: .booking)
                vc.trainerIdStr = "\(trainerDetails?.id ?? 0)"
                vc.studioIdStr = studioId
                vc.inputType = self.inputType
                self.navigationController?.pushViewController(vc, animated: true)
                
                */
            }
        }
        
 
        
//        let vc:SelectYourLocationViewController = SelectYourLocationViewController.instantiate(appStoryboard: .booking)
//        
//        self.navigationController?.pushViewController(vc, animated: true)
        
        /*
        let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
        vc.slotBookFlow = flowSlot
        self.navigationController?.pushViewController(vc, animated: true)
        */
    }
    
}
    

//MARK: -----------------------EXTENSION FOR API
extension TrainerListViewController {
    
    //MARK: --------------------GET TRAINER LIST API
    private func getTrainerApi(inputFilter: String?, inpuntTagId: Int?){
        let params:[String:String] = [
            "type": self.inputType ?? "",
            "is_filter": inputFilter ?? "",
            "tag_id": "\(inpuntTagId ?? 0)" ,
            "long": self.inputLong ?? "",
            "lat": self.inputLat ?? ""
        ]
        
        TrainerVM.gerTrainerApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("get trainer list result data: ", getResultData as Any)
            
            DispatchQueue.main.async {
                self.tagData?.removeAll()
                self.trainerData?.removeAll()
                self.tagData?.append(contentsOf: getResultData.data?.tags ?? [])
                self.trainerData?.append(contentsOf: getResultData.data?.trainers ?? [])
                
                //-------------------Reload to set data
                let tagModelData = TagModel(id: 1, name: "All Workouts", description: "", icon: "", image: "")
                self.tagData?.insert(tagModelData, at: 0)
                self.workoutCategoryCollView.reloadData()
                
                if let isGridshow = self.isGridShow, isGridshow {
                    self.trainerGridCollView.reloadData()
                }else{
                    self.trainerListTblView.reloadData()
                }
            }
        })
    }
    
    //MARK: -------------SELECT GYM
    /*
     id = 5 , this is studio id , for get studio trainers
     long = 77.391029, this is always required for current location
     lat = 28.535517, this is always required for current location
     is_filter = 1, if select tag based trainer
     tag_id = 4, required if is_filter is 1
     */
    
    private func getSelectGymList(inputFilter: String?, inpuntTagId: Int?){
        
        let params:[String:String] = [
            "id": self.studioId ?? "",
            "long": self.inputLong ?? "",
            "lat": self.inputLat ?? "",
            "is_filter": inputFilter ?? "",
            "tag_id": "\(inpuntTagId ?? 0)"
        ]
        
        TrainerVM.selectGymApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            print(getResultData)
            
            self.gymTrainerData?.removeAll()
            self.tagData?.removeAll()
            self.trainerData?.removeAll()
            self.tagData?.append(contentsOf: getResultData.data?.tags ?? [])
            self.gymTrainerData?.append(contentsOf: getResultData.data?.trainers ?? [])
            
            //-------------------Reload to set data
            let tagModelData = TagModel(id: 1, name: "All Workouts", description: "", icon: "", image: "")
            self.tagData?.insert(tagModelData, at: 0)
            self.workoutCategoryCollView.reloadData()
//            self.trainerListTblView.reloadData()
            
            if let isGridshow = isGridShow, isGridshow {
                self.trainerGridCollView.reloadData()
            }else{
                self.trainerListTblView.reloadData()
            }
        })
        
    }
}


