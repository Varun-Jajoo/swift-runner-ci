//
//  FollowersViewController.swift
//  MyPT
//
//  Created by techsaga corp on 22/05/25.
//

import UIKit

class FollowersViewController: CommonViewController {

    //MARK: --------------- VARIABLE
    var isGridShow:Bool?
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var followersMStckBV: UIStackView!
    @IBOutlet weak var myTrainersBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var tagsCollView: UICollectionView!
    @IBOutlet weak var listMBV: UIView!
    @IBOutlet weak var gridMBV: UIView!
    @IBOutlet weak var trainerListTblView: UITableView!
    @IBOutlet weak var trainersGridCollView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        setSegBtn(isTraineer: true)
        self.registerCell()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["My " + AppStrings.trainers], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.grid?.resized(to: CGSize(width: 25.0, height: 25.0)), AppImages.menuNav?.resized(to: CGSize(width: 25.0, height: 25.0)),  AppImages.search_normal], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func rightBtnActn(sender: UIButton) {
        if sender.tag != 2 {
            let grid: UIImage? = (sender.tag == 0 ? AppImages.selected_grid : AppImages.grid)
            let list: UIImage? = (sender.tag == 1 ? AppImages.menuNav : AppImages.unselectedList)
            
            self.setRighMenu(rightImgs: [grid?.resized(to: CGSize(width: 25.0, height: 25.0)), list?.resized(to: CGSize(width: 25.0, height: 25.0)), AppImages.search_normal], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
            
            if sender.tag == 0 {
                print("Gridlayout")
                self.isGridShow = true
                trainersGridCollView.reloadData()
                listMBV.isHidden = true
                gridMBV.isHidden = false
                
            }else if sender.tag == 1{
                print("show list view")
                self.isGridShow = false
                trainerListTblView.reloadData()
                listMBV.isHidden = false
                gridMBV.isHidden = true
                
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
        }else if sender.tag == 2{
            
            
                        
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
    
    @IBAction func myTrainerCommonBtnActn(_ sender: UIButton) {
        if sender.tag == 1101 {
            print("My Trainers.......")
            setSegBtn(isTraineer: true)
        }else{
            print("Following....")
            setSegBtn(isTraineer: false)
        }
    }
    
    private func registerCell(){
        tagsCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        trainersGridCollView.register(UINib(nibName: "GridTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridTrainerCollectionViewCell")
        trainerListTblView.register(UINib(nibName: "TrainerListTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerListTableViewCell")
        
        self.isGridShow = false
        trainerListTblView.reloadData()
        listMBV.isHidden = false
        gridMBV.isHidden = true
    }
    
    private func setSegBtn(isTraineer:Bool){
        if isTraineer {
            self.myTrainersBtn.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: nil)
            
            self.myTrainersBtn.backgroundColor = UIColor.appWhite
            self.followingBtn.backgroundColor = UIColor.clear
            self.myTrainersBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.followingBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
        else{
            self.followingBtn.applyTransition(type: .moveIn, subtype: .fromLeft, duration: 0.5, timingFunction: .easeInEaseOut, completion: nil)
            self.myTrainersBtn.backgroundColor = UIColor.clear
            self.followingBtn.backgroundColor = UIColor.appWhite
            self.followingBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.myTrainersBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    func updateUI(selectedView:[UIButton]){
        
        for i in selectedView{
            if i.isSelected {
                i.backgroundColor = UIColor.clear
                i.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
            }else{
                i.backgroundColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1)
                i.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
        }
    }
    
    private func setupUI(){
        [
            myTrainersBtn.titleLabel,
            followingBtn.titleLabel
        ].forEach({[weak self]  in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
        self.followersMStckBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)
        DispatchQueue.main.async {
            self.followersMStckBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.myTrainersBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.followingBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
        }
    }

}

extension FollowersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == trainersGridCollView {
            let cell:GridTrainerCollectionViewCell = trainersGridCollView.dequeueReusableCell(withReuseIdentifier: "GridTrainerCollectionViewCell", for: indexPath) as! GridTrainerCollectionViewCell
            
            return cell
        }else{
            let cell:WorkoutCategoryCollectionViewCell = tagsCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            
//            DispatchQueue.main.async {
//                if self.categorySelectedIndex?.row == indexPath.row {
//                    cell.cellMBV.backgroundColor = UIColor.clear
//                    cell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: cell.cellMBV.frame.size.height/2.0)//12.0
//                }else{
//                    cell.cellMBV.backgroundColor = UIColor.clear
//                    cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: cell.cellMBV.frame.size.height/2.0)
//                }
//            }
            
//            cell.categoryImgView.loadImage(urlString: self.tagData?[indexPath.row].image as? String, placeholder: UIImage(named: "ic_barbell_ diagonal"))
//            cell.categoryTitleLbl.text = self.tagData?[indexPath.row].name as? String
        
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == trainersGridCollView {
            let cellWdth = collectionView.frame.size.width*0.46
            return CGSize(width: cellWdth, height: cellWdth * 1.5)
        }else{
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
    }
}

extension FollowersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainerListTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "TrainerListTableViewCell", for: indexPath) as! TrainerListTableViewCell
        
        return cell
    }
    
    
}
