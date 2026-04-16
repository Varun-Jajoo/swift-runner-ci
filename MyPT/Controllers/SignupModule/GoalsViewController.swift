//
//  GoalsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit

class GoalsViewController: CommonViewController {
    
    // MARK: ----------VARIABLE
//    var dataGoals:[[String:Any]]?
    var dataGoals: [PersonalizedDataModel]? = []
    var selectIds: [Int]? = []
    var selecteInd: IndexPath = IndexPath(row: -0, section: 0)
    private var backgroundGradient: CAGradientLayer?
    
    // MARK: -----------IBOUTLET
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var goalsCollView: UICollectionView!
    @IBOutlet weak var goalsCollViewHeightConstrnt: NSLayoutConstraint!
//    @IBOutlet weak var bottomContainerMBV: UIView!
//    @IBOutlet weak var bottomNoteMBV: UIView!
//    @IBOutlet weak var bottomNoteLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet var viewBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpFont()
        self.continueBtn.isUserInteractionEnabled = false
//        bottomContainerMBV.isHidden = true
//        bottomNoteMBV.isHidden = true
        setupBackgroundGradient()
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
        continueBtn.adjustsImageWhenDisabled = false
        continueBtn.adjustsImageWhenHighlighted = false
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
    }
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.7)
        
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(setTitle: [AppStrings.skipStr], setTintColor: .black, setTitleColor: UIColor.txtSkip)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite) skipe remove need of client
        
        //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
    }
    
    private func setupBackgroundGradient() {
        // Remove old gradient if any
        backgroundGradient?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.colors = UIColor.appMultiColor(.greenBgGradient).map { $0.cgColor }

        // VERY IMPORTANT – match first UI direction
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint   = CGPoint(x: 1.0, y: 1.0)

        gradient.locations = [0.0, 0.5, 1.0]
        gradient.cornerRadius = 0

        viewBackground.layer.insertSublayer(gradient, at: 0)
        backgroundGradient = gradient
    }
    
    func updateContinueButton(isEnabled: Bool) {
        continueBtn.isEnabled = isEnabled
        continueBtn.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0.2) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
//                self.continueBtn.tintColor = .mainBg   // arrow color
//                self.continueBtn.backgroundColor = .appWhite
//                self.continueBtn.setTitleColor(.mainBg, for: .normal)
            } else {
                self.continueBtn.tintColor = .appWhite
                self.continueBtn.backgroundColor = .appDarkGray
                self.continueBtn.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {

            if isEnabled {
                // 🟢 ENABLED → IMAGE ONLY
                let image = UIImage(named: "ButtonNext")?
                    .withRenderingMode(.alwaysOriginal)

                continueBtn.setImage(image, for: .normal)
                continueBtn.setTitle("", for: .normal)

                continueBtn.backgroundColor = .clear
                continueBtn.tintColor = .clear

                continueBtn.imageEdgeInsets = .zero
                continueBtn.titleEdgeInsets = .zero
                continueBtn.contentEdgeInsets = .zero

                continueBtn.semanticContentAttribute = .forceLeftToRight
                continueBtn.adjustsImageWhenHighlighted = false
                continueBtn.adjustsImageWhenDisabled = false

            } else {
                // 🔴 DISABLED → TEXT + ARROW
                continueBtn.setTitle("NEXT", for: .normal)
                continueBtn.setTitleColor(.appWhite, for: .normal)

                let arrowImage = UIImage(named: "whiteRightArrow")?
                    .withRenderingMode(.alwaysOriginal)
                continueBtn.setImage(arrowImage, for: .normal)

                continueBtn.semanticContentAttribute = .forceRightToLeft

                // spacing between text & arrow
                continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
                continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)

                continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
        }
    
    override func rightBtnActn(sender: UIButton) {
        skipProfileApi(completion: { data in
            appUserDefaults.setRegistrationSkip(value: true)
            appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
        })
//        appUserDefaults.setRegistrationSkip(value: true)
//        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
//        appSceneDelegate?.goToGuestDashboard()
    }
    
    //------------------************Font
    func setUpFont() {
        self.descLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
//        self.bottomNoteLbl.font = AppFont.regular.size(12.0, familyName: familyOverpassMono)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
    // MARK: ---------- SET UI
    func setupUI() {
        goalsCollView.register(UINib(nibName: "PersonalizedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PersonalizedCollectionViewCell")
        goalsCollView.allowsMultipleSelection = true
        
        //-----------*************
        DispatchQueue.main.async {
//            self.bottomNoteMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 8.0)
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
        
//        cell.fitnessImgView.loadImage(urlString: dataGoals?[indexPath.row].image as? String, placeholder: UIImage())
        
        cell.fitnessImgView.image = dataGoals?[indexPath.row].cachedUnselectedImg as? UIImage
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
        
        cell.setSelectdCell(dataGoals?[indexPath.row].cachedUnselectedImg, selectedImg: dataGoals?[indexPath.row].cachedSelectedImg, isSelectedCell: true)
        
//        cell.setSelectdCellUrl(dataGoals?[indexPath.row].image as? String, selectedImgStr: dataGoals?[indexPath.row].selectImage as? String, isSelectedCell: true)
        
        updateContinueButton(isEnabled: cell.isSelected)
        
//        if cell.isSelected {
//            self.continueBtn.isUserInteractionEnabled = true
//            self.continueBtn.backgroundColor = UIColor.appWhite
//            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
//        } else {
//            self.continueBtn.isUserInteractionEnabled = false
//            self.continueBtn.backgroundColor = UIColor.appLightGray
//            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        TapticEngine.selection.feedback()
        print("Did deselect a cell at \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath) as! PersonalizedCollectionViewCell
        
        if let id = dataGoals?[indexPath.row].id as? Int, let index = selectIds?.firstIndex(of: id) {
            selectIds?.remove(at: index)
        } else {
            self.selectIds?.append(dataGoals?[indexPath.row].id ?? 0)
        }
            
        cell.setSelectdCell(dataGoals?[indexPath.row].cachedUnselectedImg, selectedImg: dataGoals?[indexPath.row].cachedSelectedImg, isSelectedCell: false)
        
//        cell.setSelectdCellUrl(dataGoals?[indexPath.row].image as? String, selectedImgStr: dataGoals?[indexPath.row].selectImage as? String, isSelectedCell: false)
        
        if let selectIds = selectIds, selectIds.isEmpty || selectIds.count == 0 {
            updateContinueButton(isEnabled: false)
//            self.continueBtn.isUserInteractionEnabled = false
//            self.continueBtn.backgroundColor = UIColor.appDarkGray
//            self.continueBtn.setTitleColor(UIColor.appLightGray, for: .normal)
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
//            self.goalsCollView.reloadData()
            
             if let prefrencesData = getResultData?.data {
                 let group = DispatchGroup()
                 for (index, dataModel) in prefrencesData.enumerated() {
                     group.enter()
                     ImageDownloader.shared.downloadImage(from: dataModel.image ?? "") { [weak self] image in
                         guard let self = self else { return }
                         self.dataGoals?[index].cachedUnselectedImg = image
                         group.leave()
                     }
                     group.enter()
                     ImageDownloader.shared.downloadImage(from: dataModel.selectImage ?? "") { [weak self] selectedImage in
                         guard let self = self else { return }
                         self.dataGoals?[index].cachedSelectedImg = selectedImage
                         group.leave()
                     }
                 }
                 // When all images are loaded
                 group.notify(queue: .main) { [weak self] in
                     guard let self = self else { return }
                     self.goalsCollView.reloadData()
                 }
             }
            
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
                
                let vc: LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    private func skipProfileApi(completion: @escaping (PaymentResponse) -> Void) {
        NetworkManager.shared.genericAPICall(serviceEndPoint: .skipProfile, method: .get, queries: nil, parameters: nil, isShowLoading: false, isShowLoadingWithoutMsg: true, completion: { (getResponce, error) in
            do {
                print(getResponce as Any)
                if let responceData = getResponce {
                    
                    let getResult = try JSONDecoder().decode(PaymentResponse.self, from: responceData)
                    if (getResult.status == true)  {
                        completion(getResult)
                    } else {
                        //                        let errorMsg = (getResult.errors != nil) ? (getResult.errors?.values.first?.first as? String ?? "") :  (getResult.msg)
                        //                        AlertHelper.shared.alertMesssage(view: self, title: "", message: errorMsg ?? "")
                    }
                }
            } catch {
                print(error)
            }
        })
    }
}
