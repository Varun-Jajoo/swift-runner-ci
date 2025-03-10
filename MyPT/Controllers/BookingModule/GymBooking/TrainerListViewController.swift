//
//  TrainerListViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import UIKit

class TrainerListViewController: CommonViewController {

    //MARK: --------------VARIBALE
//    var trainerListData:[Any]?
    var trainerGridData:[Any]?
    var flowSlot:calendarFlow = .defaultFlow
    var inputType:String?
    var inputIs_filter:String?
    var inputTag_id:String?
    var inputLat:String?
    var inputLong:String?
    var tagData:[TagModel]? = []
    var trainerData:[TrainerModel]? = []
    
   
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var workoutCategoryCollView: UICollectionView!
    @IBOutlet weak var trainerListTblView: UITableView!
    @IBOutlet weak var trainerGridCollView: UICollectionView!
    
    @IBOutlet weak var tblMBV: UIView!
    
    @IBOutlet weak var collMBV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.inputType = "home"
        self.inputIs_filter = ""
        self.inputTag_id = ""
        self.inputLat = " 77.391029"
        self.inputLong = "28.535517"
        
        self.getTrainerApi()
        
        workoutCategoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        
        trainerGridCollView.register(UINib(nibName: "GridTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridTrainerCollectionViewCell")
        
        trainerListTblView.register(UINib(nibName: "TrainerListTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerListTableViewCell")
        
//        trainerListData = ["1","2","3","4"]
        
        trainerGridData = []
        tblMBV.isHidden = false
        collMBV.isHidden = true
        trainerGridCollView.reloadData()
        trainerListTblView.reloadData()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tagData = tagData?.count, tagData > 0 {
            // Automatically select the first cell
            let firstIndexPath = IndexPath(item: 0, section: 0)
            DispatchQueue.main.async {
                self.workoutCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
                // Optional: perform any additional setup for the selected cell
                self.workoutCategoryCollView.delegate?.collectionView?(self.workoutCategoryCollView, didSelectItemAt: firstIndexPath)
                self.view.layoutIfNeeded()
            }
        }
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
//            trainerListData = []
            trainerGridData = ["1","2","3","4"]
            trainerGridCollView.reloadData()
            trainerListTblView.reloadData()
            tblMBV.isHidden = true
            collMBV.isHidden = false
            
        }else if sender.tag == 1{
            print("show list view")
//            trainerListData = ["1","2","3","4"]
            trainerGridData = []
            trainerGridCollView.reloadData()
            trainerListTblView.reloadData()
            tblMBV.isHidden = false
            collMBV.isHidden = true
            
        }else{
            print("cliecked at search...")
        }
    }
    
}

//MARK: --------------UICOLLECTIONVIEW DELEGATE/DATASOURCE
extension TrainerListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == trainerGridCollView {
            return trainerGridData?.count ?? 0
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
            return cell
        }else{
            let cell:WorkoutCategoryCollectionViewCell = workoutCategoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            cell.categoryImgView.loadImage(urlString: self.tagData?[indexPath.row].image as? String, placeholder: AppImages.navLeft)
            cell.categoryTitleLbl.text = self.tagData?[indexPath.row].name as? String
            
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == trainerGridCollView {
            let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
            self.navigationController?.pushViewController(vc, animated: true)
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
        return self.trainerData?.count ?? 00
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainerListTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "TrainerListTableViewCell", for: indexPath) as! TrainerListTableViewCell
        
        cell.trainerImgView.loadImage(urlString: self.trainerData?[indexPath.row].profile as? String, placeholder: AppImages.navLeft)
        cell.gymNameLbl.text = self.trainerData?[indexPath.row].name as? String
//        cell.setupSelection()
        cell.bookSlotBtn.addTarget(self, action: #selector(bookSlotBtnActn(sender: )), for: .touchUpInside)
        cell.trainerTagsData = self.trainerData?[indexPath.row].tags
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func bookSlotBtnActn(sender:UIButton) {
        let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
        vc.slotBookFlow = flowSlot
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
    

//MARK: -----------------------EXTENSION FOR API
extension TrainerListViewController {
    
    private func getTrainerApi(){
        let params:[String:String] = [
            "type": self.inputType ?? "",
            "is_filter": self.inputIs_filter ?? "",
            "tag_id": self.inputTag_id ?? "",
            "long": self.inputLong ?? "",
            "lat": self.inputLat ?? ""
        ]
        
        DashboardVM.gerTrainerApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("get trainer list result data: ", getResultData as Any)
            
            self.tagData?.removeAll()
            self.trainerData?.removeAll()
            self.tagData?.append(contentsOf: getResultData.data?.tags ?? [])
            self.trainerData?.append(contentsOf: getResultData.data?.trainers ?? [])
            self.workoutCategoryCollView.reloadData()
            self.trainerListTblView.reloadData()
        })
    }
    
    //        let params:[String:String] = [
    //            "type": "home",
    //            "is_filter": "",
    //            "tag_id": "",
    //            "long": " 77.391029",
    //            "lat": "28.535517"
    //        ]
}



////MARK: --------------UICOLLECTIOVIEW DELEGATE/DATASOURCE
//
//extension TrainerListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
//    
//}


