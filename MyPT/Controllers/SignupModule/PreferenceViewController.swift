//
//  PreferenceViewController.swift
//  MyPT
//
//  Created by techsaga corp on 04/11/24.
//

import UIKit

class PreferenceViewController: CommonViewController {
    //MARK: ----------VARIABLE
    var dataPreference:[[String:Any]]?
    var selectPreference:String?
    
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var topDescLbl: UILabel!
    @IBOutlet weak var preferenceCollView: UICollectionView!
    @IBOutlet weak var preferencCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var prefernceNoteMBV: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var preferenceNoteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueBtn.isUserInteractionEnabled = false
        self.prefernceNoteMBV.isHidden = true
        setupUI()
        setUpFont()
        
        dataPreference = [ ["title":"By Myself","images":AppImages.byMyself as Any,"seleced_images":AppImages.byMyself_selected as Any],
                           ["title":"Personal Trainer","images":AppImages.personalTrainer as Any,"seleced_images":AppImages.personalTrainer_selected as Any],
                           ["title":"Group Session","images":AppImages.groupSession as Any,"seleced_images":AppImages.groupSession_selected as Any],
                           ["title":"Dont Know Yet","images":AppImages.dontKnowYet as Any,"seleced_images":AppImages.dontKnowYet_selected as Any]
        ]
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
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.8)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite) skipe remove need of client
        
        //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
    }
    
    override func rightBtnActn(sender: UIButton) {
        appUserDefaults.setRegistrationSkip(value: true)
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
    }
    
    //------------------************Font
    func setUpFont(){
        self.topDescLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        //        self.subDescLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.preferenceNoteBtn.setTitle("No worries, we’ve got your gym needs covered", for: .normal)
        
        self.preferenceNoteBtn.titleLabel?.numberOfLines = 2
        self.preferenceNoteBtn.titleLabel?.font = AppFont.regular.size(12.0, familyName: familyOverpassMono)
        
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    
    //MARK: ---------- SET UI
    func setupUI(){
        preferenceCollView.register(UINib(nibName: "PersonalizedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PersonalizedCollectionViewCell")
        preferenceCollView.allowsMultipleSelection = false
        
        //-----------*************
        DispatchQueue.main.async {
            self.prefernceNoteMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        self.prefernceNoteMBV.isHidden = false
        self.continueBtn.isUserInteractionEnabled = false
        
        if let selectPreference = self.selectPreference , !selectPreference.isEmpty {
            RegistrationVM.addPreferworkApi(viewController: self, inputName: selectPreference.lowercased(), completion: {[weak self] getResultData in
                guard let self = self , let getResultData = getResultData else { return }
               
                self.continueBtn.isUserInteractionEnabled = true
                if getResultData.status == true {
                    appUserDefaults.setRegistrationSkip(value: false)
                    if let detailsData = getResultData.data {
                        appUserDefaults.saveUserToUserDefaults(detailsData)
                    }
                    
                    let vc:LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                self.continueBtn.isUserInteractionEnabled = true
            })
            
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: "Please select at least one.")
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        DispatchQueue.main.async {
            let height = self.preferenceCollView.collectionViewLayout.collectionViewContentSize.height
            
            if self.preferenceCollView.contentSize.height != 0 {
                
                self.preferencCollViewHeightConstrnt.constant = height
                
                self.preferenceCollView.layoutIfNeeded()
            }
        }
        self.view.layoutIfNeeded()
    }
    
}


//MARK: --------------********Extension for Datasource/Delegate UICollectionview

extension PreferenceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataPreference?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PersonalizedCollectionViewCell = preferenceCollView.dequeueReusableCell(withReuseIdentifier: "PersonalizedCollectionViewCell", for: indexPath) as! PersonalizedCollectionViewCell
        cell.cellMBV.backgroundColor = UIColor.clear
        DispatchQueue.main.async {
            cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 0.0)
        }
        cell.titleLbl.text = dataPreference?[indexPath.row]["title"] as? String
        cell.titleLbl.lineBreakMode = .byClipping
        cell.fitnessImgView.image = dataPreference?[indexPath.row]["images"] as? UIImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PersonalizedCollectionViewCell
        self.selectPreference = nil
        self.selectPreference = dataPreference?[indexPath.row]["title"] as? String
        
        cell.setSelectdCell(dataPreference?[indexPath.row]["images"] as? UIImage, selectedImg: dataPreference?[indexPath.row]["seleced_images"] as? UIImage, isSelectedCell: true)
        
        if cell.isSelected {
            self.prefernceNoteMBV.isHidden = false
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appLightGray
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width*0.43, height: collectionView.frame.height*0.45)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Did deselect a cell at \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath) as! PersonalizedCollectionViewCell
        
        cell.setSelectdCell(dataPreference?[indexPath.row]["images"] as? UIImage, selectedImg: dataPreference?[indexPath.row]["seleced_images"] as? UIImage, isSelectedCell: false)
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10 // Spacing between rows
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10 // Spacing between columns
//    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}
