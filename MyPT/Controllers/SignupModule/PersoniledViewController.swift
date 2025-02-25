//
//  PersoniledViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit
import AlamofireImage

class PersoniledViewController: CommonViewController {
    
    //MARK: ----------VARIABLE
//    var dataPersonalized:[[String:Any]]?
    var dataPersonalized:[PersonalizedDataModel]? = []
    var selectIds:[Int]? = []
//    var selectIds: Set<Int>? = []
    
    var selecteInd:IndexPath = IndexPath(row: -0, section: 0)
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subDescLbl: UILabel!
    @IBOutlet weak var fitnessCollView: UICollectionView!
    @IBOutlet weak var fitnessCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var progressNoteMBV: UIView!
    @IBOutlet weak var progressNoteLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        self.continueBtn.isUserInteractionEnabled = false
        
        /*
        dataPersonalized = [ ["title":"Weight Management","images":AppImages.Weight_Management as Any,"seleced_images":AppImages.Weight_Management_Selected as Any],
                             ["title":"Boost Self Esteem","images":AppImages.Boost_Esteem as Any,"seleced_images":AppImages.Boost_Esteem_selected as Any],
                             ["title":"Health & Fitness","images":AppImages.Health_Fitness as Any,"seleced_images":AppImages.Health_Fitness_selected as Any],
                             ["title":"Chronic illness Care","images":AppImages.Chronic_illness_Care as Any,"seleced_images":AppImages.Chronic_illness_Care_selected as Any],
                             ["title":"Preparing for an event","images":AppImages.Preparing_event as Any,"seleced_images":AppImages.Preparing_event_selected as Any],
                             ["title":"Others","images":AppImages.Others_Presonalized as Any,"seleced_images":AppImages.Others_Presonalized_selected as Any]
        ]
        */
        
        fitnessCollView.register(UINib(nibName: "PersonalizedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PersonalizedCollectionViewCell")
        fitnessCollView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        self.getPersonalizedApi()
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
        //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
    }
    
    override func rightBtnActn(sender: UIButton) {
        appSceneDelegate?.goToGuestDashboard()
    }
    
    //------------------************Font
    func setUpFont(){
        self.titleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.subDescLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.progressNoteLbl.font = AppFont.regular.size(12.0, familyName: familyOverpass)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        DispatchQueue.main.async {
            //8.0
            self.progressNoteMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        self.continueBtn.isUserInteractionEnabled = false
        if let selectIds = selectIds, !selectIds.isEmpty || selectIds.count != 0 {
            let inputIdString:String = selectIds.map { String($0) }.joined(separator: ",")
            
            self.addPersonalizedApi(inputIds: inputIdString)
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: "Please select at least one")
        }
        
        
        /*
        let vc:GenderViewController = GenderViewController.instantiate(appStoryboard: .main)
        self.navigationController?.pushViewController(vc, animated: true)
        */
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        DispatchQueue.main.async {
        let height = self.fitnessCollView.collectionViewLayout.collectionViewContentSize.height
            if self.fitnessCollView.contentSize.height != 0 {
           
                self.fitnessCollViewHeightConstrnt.constant = height
            }
            self.fitnessCollView.layoutIfNeeded()
        }
        self.view.layoutIfNeeded()
    }
    
}

//MARK: -----------EXTENSION FOR DELEGATE/DATASOURCE UICOLLECTIONVIEW
extension PersoniledViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataPersonalized?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PersonalizedCollectionViewCell = fitnessCollView.dequeueReusableCell(withReuseIdentifier: "PersonalizedCollectionViewCell", for: indexPath) as! PersonalizedCollectionViewCell
        cell.titleLbl.text = dataPersonalized?[indexPath.row].name as? String
        //dataPersonalized?[indexPath.row]["title"] as? String
        cell.titleLbl.lineBreakMode = .byClipping
//        cell.fitnessImgView.image = dataPersonalized?[indexPath.row]["images"] as? UIImage
        
        cell.fitnessImgView.loadImage(urlString: dataPersonalized?[indexPath.row].image as? String, placeholder: UIImage(named: "ic_navLeft"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width*0.43, height: collectionView.frame.height*0.25)
        
//        return CGSize(width: collectionView.frame.width*0.43, height: collectionView.frame.height*0.40)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PersonalizedCollectionViewCell
        
        if let id = dataPersonalized?[indexPath.row].id as? Int, let index = selectIds?.firstIndex(of: id) {
            selectIds?.remove(at: index)
        } else {
            self.selectIds?.append(dataPersonalized?[indexPath.row].id ?? 0)
        }
                
        cell.setSelectdCellUrl(dataPersonalized?[indexPath.row].image as? String, selectedImgStr: dataPersonalized?[indexPath.row].selectImage as? String, isSelectedCell: true)
        
//        cell.setSelectdCell(dataPersonalized?[indexPath.row].image as? UIImage, selectedImg: dataPersonalized?[indexPath.row].selectImage as? UIImage, isSelectedCell: true)
        
//        cell.setSelectdCell(dataPersonalized?[indexPath.row]["images"] as? UIImage, selectedImg: dataPersonalized?[indexPath.row]["seleced_images"] as? UIImage, isSelectedCell: true)
        
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
      
        if let id = dataPersonalized?[indexPath.row].id as? Int, let index = selectIds?.firstIndex(of: id) {
            selectIds?.remove(at: index)
        } else {
            self.selectIds?.append(dataPersonalized?[indexPath.row].id ?? 0)
        }
                        
        cell.setSelectdCellUrl(dataPersonalized?[indexPath.row].image as? String, selectedImgStr: dataPersonalized?[indexPath.row].selectImage as? String, isSelectedCell: false)
        
        if let selectIds = selectIds, selectIds.isEmpty || selectIds.count == 0 {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appLightGray, for: .normal)
        }
        
//        cell.setSelectdCell(dataPersonalized?[indexPath.row]["images"] as? UIImage, selectedImg: dataPersonalized?[indexPath.row]["seleced_images"] as? UIImage, isSelectedCell: false)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
}


//MARK: ----------------------API
extension PersoniledViewController {
    
    //MARK: ----------------------Get Personalized data
    func getPersonalizedApi(){
        RegistrationVM.getPrefrencesApi(viewController: self, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            self.dataPersonalized?.removeAll()
            self.dataPersonalized?.append(contentsOf: getResultData.data ?? [])
            print("Data personalized: ",self.dataPersonalized as Any)
            self.fitnessCollView.reloadData()
        })
    }
    
    //MARK: ----------------------Add Personalized
    func addPersonalizedApi(inputIds:String){
        print("inputIds= ", inputIds)
        
        RegistrationVM.addPersonalizedApi(viewController: self, inputIds: inputIds, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            print("getResultData: ", getResultData)
            if getResultData.status == true {
                if let detailsData = getResultData.data {
                    appUserDefaults.saveUserToUserDefaults(detailsData)
                }
                
                let vc:GenderViewController = GenderViewController.instantiate(appStoryboard: .main)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            self.continueBtn.isUserInteractionEnabled = true
        })
    }

}
