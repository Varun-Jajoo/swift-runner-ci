//
//  GymWorkoutViewController.swift
//  MyPT
//
//  Created by techsaga corp on 11/12/24.
//

import UIKit

class GymWorkoutViewController: CommonViewController {

    //MARK: ----------------IBOUTLET
    @IBOutlet weak var searchMBV: UIView!
    @IBOutlet weak var searchLocBtn: UIButton!
    @IBOutlet weak var searchTxtField: UITextField!
    @IBOutlet weak var selectLocBtn: UIButton!
    @IBOutlet weak var categoryCollView: UICollectionView!
    @IBOutlet weak var categoryCollHieghtConstrnt: NSLayoutConstraint!
    @IBOutlet weak var trainerListTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpUI()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["12 Gyms Near You."], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.search_normal], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            self.categoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.categoryCollView.delegate?.collectionView?(self.categoryCollView, didSelectItemAt: firstIndexPath)
            self.view.layoutIfNeeded()
        }
    }
    
    func setUpUI(){
        //-------------------Register collectionview
        categoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
       
        self.trainerListTblView.register(UINib(nibName: "GymWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "GymWorkoutTableViewCell")
        
        DispatchQueue.main.async {
            self.searchMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 6.0)
        }
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
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:WorkoutCategoryCollectionViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}

extension GymWorkoutViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:GymWorkoutTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "GymWorkoutTableViewCell", for: indexPath) as! GymWorkoutTableViewCell
        
        cell.landMarkBtn.setTitle("Near Dubai", for: .normal)
        cell.viewDetailsBtn.addTarget(self, action: #selector(viewDetailsBtnActn(sender: )), for: .touchUpInside)
        cell.selectViewBtn.addTarget(self, action: #selector(selectGymBtnActn(sender: )), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let vc:GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
 
    //MARK: -----------------BTN ACTN
    @objc func viewDetailsBtnActn(sender: UIButton){
        let vc:GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectGymBtnActn(sender: UIButton){
         let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
         vc.flowSlot = calendarFlow.bookTrainer
         self.navigationController?.pushViewController(vc, animated: true)
    }
    
  
}
