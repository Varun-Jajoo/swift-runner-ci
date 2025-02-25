//
//  TrainerListViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import UIKit

class TrainerListViewController: CommonViewController {

    //MARK: --------------VARIBALE
    var trainerListData:[Any]?
    var trainerGridData:[Any]?
    var flowSlot:calendarFlow = .defaultFlow
    
    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var workoutCategoryCollView: UICollectionView!
    @IBOutlet weak var trainerListTblView: UITableView!
    @IBOutlet weak var trainerGridCollView: UICollectionView!
    
    @IBOutlet weak var tblMBV: UIView!
    
    @IBOutlet weak var collMBV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        workoutCategoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        
        trainerGridCollView.register(UINib(nibName: "GridTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridTrainerCollectionViewCell")
        
        trainerListTblView.register(UINib(nibName: "TrainerListTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerListTableViewCell")
        
        trainerListData = ["1","2","3","4"]
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
        
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            self.workoutCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.workoutCategoryCollView.delegate?.collectionView?(self.workoutCategoryCollView, didSelectItemAt: firstIndexPath)
            self.view.layoutIfNeeded()
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
            trainerListData = []
            trainerGridData = ["1","2","3","4"]
            trainerGridCollView.reloadData()
            trainerListTblView.reloadData()
            tblMBV.isHidden = true
            collMBV.isHidden = false
            
        }else if sender.tag == 1{
            print("show list view")
            trainerListData = ["1","2","3","4"]
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
            return 5
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
        return trainerListData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainerListTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "TrainerListTableViewCell", for: indexPath) as! TrainerListTableViewCell
        
//        cell.setupSelection()
        cell.bookSlotBtn.addTarget(self, action: #selector(bookSlotBtnActn(sender: )), for: .touchUpInside)
        
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
    

////MARK: --------------UICOLLECTIOVIEW DELEGATE/DATASOURCE
//
//extension TrainerListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
//    
//}


