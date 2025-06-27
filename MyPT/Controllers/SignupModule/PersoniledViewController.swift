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
    var dynamicHeigthColl: CGFloat?
    
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
     
        if let userData = appUserDefaults.getUserFromUserDefaults(as: SubmitDataModel.self), let userName = userData.name {
            self.titleLbl.text = "Hello " + userName + ","
        }else{
            //appUserDefaults.getUserFromUserDefaults(as: UserModel.self)
            if let userName = appUserDefaults.getUserName() {
                self.titleLbl.text = "Hello " + userName + ","
            }
        }
                
        fitnessCollView.register(UINib(nibName: "PersonalizedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PersonalizedCollectionViewCell")
        fitnessCollView.allowsMultipleSelection = true
        
        self.getPersonalizedApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
//        self.getPersonalizedApi()
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite) skipe remove need of client
    }
    
    override func rightBtnActn(sender: UIButton) {
        appUserDefaults.setRegistrationSkip(value: true)
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
    }
    
    //------------------************Font
    func setUpFont(){
        self.titleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.subDescLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.progressNoteLbl.font = AppFont.regular.size(12.0, familyName: familyOverpassMono)
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
           
                if let localDynamicHeigthColl = self.dynamicHeigthColl {
                    
                    self.fitnessCollViewHeightConstrnt.constant = localDynamicHeigthColl
                    self.fitnessCollView.layoutIfNeeded()
                }else{
                    self.dynamicHeigthColl = height
                    self.fitnessCollViewHeightConstrnt.constant = height
                }
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
        cell.cellMBV.backgroundColor = UIColor.clear
        DispatchQueue.main.async {
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 0.0)
        }
        
        cell.titleLbl.text = dataPersonalized?[indexPath.row].name as? String
        //dataPersonalized?[indexPath.row]["title"] as? String
        cell.titleLbl.lineBreakMode = .byClipping
        cell.fitnessImgView.image = dataPersonalized?[indexPath.row].cachedUnselectedImg as? UIImage
        
//        cell.fitnessImgView.loadImage(urlString: dataPersonalized?[indexPath.row].image as? String, placeholder: UIImage(named: ""))
        
        cell.setupCell()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        return CGSize(width: collectionView.frame.width*0.43, height: collectionView.frame.height*0.25)
        
        return CGSize(width: collectionView.frame.width*0.43, height: collectionView.frame.height*0.30)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PersonalizedCollectionViewCell
        
        if let id = dataPersonalized?[indexPath.row].id as? Int, let index = selectIds?.firstIndex(of: id) {
            selectIds?.remove(at: index)
        } else {
            self.selectIds?.append(dataPersonalized?[indexPath.row].id ?? 0)
        }
        
        cell.setSelectdCell(dataPersonalized?[indexPath.row].cachedUnselectedImg, selectedImg: dataPersonalized?[indexPath.row].cachedSelectedImg, isSelectedCell: true)
                
//        cell.setSelectdCellUrl(dataPersonalized?[indexPath.row].image as? String, selectedImgStr: dataPersonalized?[indexPath.row].selectImage as? String, isSelectedCell: true)
                
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
                        
//        cell.setSelectdCellUrl(dataPersonalized?[indexPath.row].image as? String, selectedImgStr: dataPersonalized?[indexPath.row].selectImage as? String, isSelectedCell: false)
        
        cell.setSelectdCell(dataPersonalized?[indexPath.row].cachedUnselectedImg, selectedImg: dataPersonalized?[indexPath.row].cachedSelectedImg, isSelectedCell: false)
        
        if let selectIds = selectIds, selectIds.isEmpty || selectIds.count == 0 {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appLightGray, for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.updateViewConstraints()
//        }
//        DispatchQueue.main.async {
//            self.updateViewConstraints()
//        }
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
            
            if let prefrencesData = getResultData.data {
                let group = DispatchGroup()
                for (index, dataModel) in prefrencesData.enumerated() {
                    group.enter()
                    ImageDownloader.shared.downloadImage(from: dataModel.image ?? "") { [weak self] image in
                        guard let self = self else { return }
                        self.dataPersonalized?[index].cachedUnselectedImg = image
                        group.leave()
                    }
                    group.enter()
                    ImageDownloader.shared.downloadImage(from: dataModel.selectImage ?? "") { [weak self] selectedImage in
                        guard let self = self else { return }
                        self.dataPersonalized?[index].cachedSelectedImg = selectedImage
                        group.leave()
                    }
                }
                // When all images are loaded
                group.notify(queue: .main) { [weak self] in
                    guard let self = self else { return }
                    self.fitnessCollView.reloadData()
                }
            }
        })
    }
    
    //MARK: ----------------------Add Personalized
    func addPersonalizedApi(inputIds:String){
        print("inputIds= ", inputIds)
        
        RegistrationVM.addPersonalizedApi(viewController: self, inputIds: inputIds, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            print("getResultData: ", getResultData)
            self.continueBtn.isUserInteractionEnabled = true
            if getResultData.status == true {
                appUserDefaults.setRegistrationSkip(value: false)
                
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
