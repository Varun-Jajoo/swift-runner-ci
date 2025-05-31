//
//  GoalsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit

class GoalsViewController: CommonViewController {
    
    //MARK: ----------VARIABLE
//    var dataGoals:[[String:Any]]?
    var dataGoals:[PersonalizedDataModel]? = []
    var selectIds:[Int]? = []
    var selecteInd:IndexPath = IndexPath(row: -0, section: 0)
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var goalsCollView: UICollectionView!
    @IBOutlet weak var goalsCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var bottomContainerMBV: UIView!
    @IBOutlet weak var bottomNoteMBV: UIView!
    @IBOutlet weak var bottomNoteLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpFont()
        self.continueBtn.isUserInteractionEnabled = false
        bottomContainerMBV.isHidden = true
        bottomNoteMBV.isHidden = true
        
        /*
        dataGoals = [ ["title":"Mental Health","images":AppImages.mentalHealth as Any,"seleced_images":AppImages.mentalHealth_selected as Any],
                      ["title":"Weight Loss","images":AppImages.weightLoss as Any,"seleced_images":AppImages.weightLoss_selected as Any],
                      ["title":"Muscle Building","images":AppImages.muscleBuilding as Any,"seleced_images":AppImages.muscleBuilding_selected as Any],
                      ["title":"Improved CV Endurance","images":AppImages.improvedCVEndurance as Any,"seleced_images":AppImages.improvedCVEndurance_selected as Any],
                      ["title":"Flexibility & Mobility","images":AppImages.flexibilityMobility as Any,"seleced_images":AppImages.flexibilityMobility_selected as Any],
                      ["title":"Holistic Fitness","images":AppImages.holisticFitness as Any,"seleced_images":AppImages.holisticFitness_selected as Any],
                      ["title":"Sports Conditioning","images":AppImages.sportsConditioning as Any,"seleced_images":AppImages.sportsConditioning_selected as Any],
                      ["title":"Others","images":AppImages.goalsOthers as Any,"seleced_images":AppImages.goalsOthers_Selected as Any]
        ]
        */
        
        //-----------------------
        if let userData = appUserDefaults.getUserFromUserDefaults(as: UserModel.self), let userName = userData.name, let userHeight = userData.information?.height {
            print("userData", userData)
            print("userData Height: ", userHeight,"userData name: ", userName, "Id: ",userData.id ?? "",  userData.phone ?? "")
        }
        
        self.getGoalsDataApi()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        
//        self.getGoalsDataApi()
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.6)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
        //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
    }
    
    override func rightBtnActn(sender: UIButton) {
        appUserDefaults.setRegistrationSkip(value: true)
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
//        appSceneDelegate?.goToGuestDashboard()
    }
    
    //------------------************Font
    func setUpFont(){
        self.descLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.bottomNoteLbl.font = AppFont.regular.size(12.0, familyName: familyOverpassMono)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        goalsCollView.register(UINib(nibName: "PersonalizedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PersonalizedCollectionViewCell")
        goalsCollView.allowsMultipleSelection = true
        
        //-----------*************
        DispatchQueue.main.async {
            self.bottomNoteMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        self.continueBtn.isUserInteractionEnabled = false
        if let selectIds = selectIds, !selectIds.isEmpty || selectIds.count != 0 {
            let inputIdString:String = selectIds.map { String($0) }.joined(separator: ",")
            
            self.addGoalsApi(inputIds: inputIdString)
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: "Please select at least one.")
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        DispatchQueue.main.async {
            let height = self.goalsCollView.collectionViewLayout.collectionViewContentSize.height
            
            if self.goalsCollView.contentSize.height != 0 {
                DispatchQueue.main.async {
                    self.goalsCollViewHeightConstrnt.constant = 50.0
                    self.goalsCollViewHeightConstrnt.constant = height
                }
                
                self.goalsCollView.layoutIfNeeded()
            }
        }
     
        self.view.layoutIfNeeded()
    }
}

//MARK: --------------********Extension for Datasource/Delegate UICollectionview
extension GoalsViewController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataGoals?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PersonalizedCollectionViewCell = goalsCollView.dequeueReusableCell(withReuseIdentifier: "PersonalizedCollectionViewCell", for: indexPath) as! PersonalizedCollectionViewCell
        cell.cellMBV.backgroundColor = UIColor.clear
        DispatchQueue.main.async {
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 0.0)
        }
//        cell.titleLbl.text = dataGoals?[indexPath.row]["title"] as? String
        cell.titleLbl.lineBreakMode = .byClipping
        cell.titleLbl.text = dataGoals?[indexPath.row].name as? String
        
        cell.fitnessImgView.loadImage(urlString: dataGoals?[indexPath.row].image as? String, placeholder: UIImage())
        
//        cell.fitnessImgView.image = dataGoals?[indexPath.row]["images"] as? UIImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width*0.43, height: collectionView.frame.height*0.25)
        
//        return CGSize(width: collectionView.frame.width*0.43, height: collectionView.frame.height*0.35)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PersonalizedCollectionViewCell
        
        if let id = dataGoals?[indexPath.row].id as? Int, let index = selectIds?.firstIndex(of: id) {
            selectIds?.remove(at: index)
        } else {
            self.selectIds?.append(dataGoals?[indexPath.row].id ?? 0)
        }
        
        cell.setSelectdCellUrl(dataGoals?[indexPath.row].image as? String, selectedImgStr: dataGoals?[indexPath.row].selectImage as? String, isSelectedCell: true)
        
        /*
        cell.setSelectdCell(dataGoals?[indexPath.row]["images"] as? UIImage, selectedImg: dataGoals?[indexPath.row]["seleced_images"] as? UIImage, isSelectedCell: true)
        */
        
        if cell.isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appLightGray
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Did deselect a cell at \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath) as! PersonalizedCollectionViewCell
        
        if let id = dataGoals?[indexPath.row].id as? Int, let index = selectIds?.firstIndex(of: id) {
            selectIds?.remove(at: index)
        } else {
            self.selectIds?.append(dataGoals?[indexPath.row].id ?? 0)
        }
                        
        cell.setSelectdCellUrl(dataGoals?[indexPath.row].image as? String, selectedImgStr: dataGoals?[indexPath.row].selectImage as? String, isSelectedCell: false)
        
        if let selectIds = selectIds, selectIds.isEmpty || selectIds.count == 0 {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appLightGray, for: .normal)
        }
        
        /*
        cell.setSelectdCell(dataGoals?[indexPath.row]["images"] as? UIImage, selectedImg: dataGoals?[indexPath.row]["seleced_images"] as? UIImage, isSelectedCell: false)
        */
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}


//MARK: --------------EXTENSION FOR API

extension GoalsViewController {
    
    //MARK: ----------------------Get Goals
    func getGoalsDataApi(){
        RegistrationVM.getGoalsApi(viewController: self, completion: { [weak self] getResultData in
            guard let self = self else { return  }
            
            self.dataGoals?.removeAll()
            self.dataGoals?.append(contentsOf: getResultData?.data ?? [])
            self.goalsCollView.reloadData()
        })
    }
    
    //MARK: ----------------------Add Goals
    func addGoalsApi(inputIds:String){
        print("inputIds= ", inputIds)
        
        RegistrationVM.addGoalApi(viewController: self, inputIds: inputIds, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            self.continueBtn.isUserInteractionEnabled = true
            if getResultData.status == true {
                appUserDefaults.setRegistrationSkip(value: false)
                if let detailsData = getResultData.data {
                    appUserDefaults.saveUserToUserDefaults(detailsData)
                }
                
                let vc:PreferenceViewController = PreferenceViewController.instantiate(appStoryboard: .main)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
}
