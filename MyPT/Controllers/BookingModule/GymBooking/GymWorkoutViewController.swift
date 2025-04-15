//
//  GymWorkoutViewController.swift
//  MyPT
//
//  Created by techsaga corp on 11/12/24.
//

import UIKit

class GymWorkoutViewController: CommonViewController {

    //MARK: -------------VARIABEL
    var inputType:String?
    var inputIs_filter:String?
    var inputLat:String?
    var inputLong:String?
    var gymTagData:[TagModel]? = []
    var studiosData:[TrainerModel]? = []
    var categorySelectedIndex:IndexPath?
    var flowGymwork:calendarFlow = .defaultFlow
    
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
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["12 Gyms Near You."], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.search_normal], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
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
        return gymTagData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:WorkoutCategoryCollectionViewCell = categoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
        
        DispatchQueue.main.async {
            if self.categorySelectedIndex?.row == indexPath.row {
                cell.cellMBV.backgroundColor = UIColor.clear
                cell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 12.0)
            }else{
                cell.cellMBV.backgroundColor = UIColor.clear
                cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
        }
        
        cell.categoryImgView.loadImage(urlString: self.gymTagData?[indexPath.row].image as? String, placeholder: UIImage(named: "ic_barbell_ diagonal"))
        cell.categoryTitleLbl.text = self.gymTagData?[indexPath.row].name as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row > 0 {
            self.getTrainerApi(inputFilter: "1", inpuntTagId: self.gymTagData?[indexPath.row].id as? Int)
        }else{
            self.getTrainerApi(inputFilter: "0", inpuntTagId: self.gymTagData?[indexPath.row].id as? Int)
        }
       
        self.categorySelectedIndex = indexPath
        collectionView.reloadData()
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
        return tableView.numberOfRows(count: self.studiosData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
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
                
        let vc:GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
        vc.inputStudioId = sender.accessibilityHint
        vc.inputLat = self.inputLat
        vc.inputLong = self.inputLong
        vc.inputType = self.inputType
        vc.gymDetailsFlow = flowGymwork
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectGymBtnActn(sender: UIButton){
        
        switch flowGymwork{
            
        case .bookTrainerHomeWorkout, .bookTrainerGymWorkout, .createPackage, .defaultFlow:
            let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
            vc.isFromHome = false
            vc.studioId = sender.accessibilityHint
            vc.inputLat = self.inputLat
            vc.inputLong = self.inputLong
            vc.inputType = self.inputType
            vc.flowSlot = flowGymwork
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .gymMembership:
            print("gymMembership")
        case .withTrainerMembership:
            print("withTrainerMembership")
            
            let vc:TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
            vc.isFromHome = false
            vc.studioId = sender.accessibilityHint
            vc.inputLat = self.inputLat
            vc.inputLong = self.inputLong
            vc.inputType = self.inputType
            //--------------Flow for membership
            vc.flowSlot = flowGymwork
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .withoutTrainerMembership:
            let vc:ChooseSessionViewController = ChooseSessionViewController.instantiate(appStoryboard: .booking)
            vc.validityMembershipParam = (sender.accessibilityHint,"1")
            vc.flowSession = .validityMembership
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
}

//MARK: -------------EXTENSION FOR API
extension GymWorkoutViewController{
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
            
            self.gymTagData?.removeAll()
            self.studiosData?.removeAll()
            self.gymTagData?.append(contentsOf: getResultData.data?.tags ?? [])
            self.studiosData?.append(contentsOf: getResultData.data?.studios ?? [])
            
            //-------------------Reload to set data
            let tagModelData = TagModel(id: 1, name: "All Workouts", description: "", icon: "", image: "")
            
            self.gymTagData?.insert(tagModelData, at: 0)
            self.categoryCollView.reloadData()
            self.trainerListTblView.reloadData()
            
        })
    }
}
