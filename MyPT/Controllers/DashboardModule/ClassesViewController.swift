//
//  ClassesViewController.swift
//  MyPT
//
//  Created by techsaga corp on 12/05/25.
//

import UIKit

class ClassesViewController: CommonViewController {

    //MARK: ---------- VARIABLE
    var classCategoryData: [AllcategoryModel]? = []
    var allClassesData: [UpcomingClassModel]? = []
    var classesWithCategoryData: [ClassesWithCategoryModel]? = []
    var isCategory: Bool?
    var inputLat:String?
    var inputLong:String?
    
    
    var filters: (filterId: String, categoryId: String) = ("", "") {
        didSet {
           viewAllClass(filterIdStr: filters.filterId,
                        categoryIdStr: filters.categoryId)
        }
    }
    
    //MARK: ---------- IBOUTLET
    @IBOutlet weak var searchMBV: UIView!
    @IBOutlet weak var selectLocLeftBtn: UIButton!
    @IBOutlet weak var searchLocsBtn: UIButton!
    @IBOutlet weak var searchLocTxtField: UITextField!
    @IBOutlet weak var classesCategoryCollView: UICollectionView!
    @IBOutlet weak var classesListTblView: UITableView!
    @IBOutlet weak var classesListTblHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var categoryMBV: UIView!
    @IBOutlet weak var lookCategoryBtn: UIButton!
    @IBOutlet weak var lookViewAllBtn: UIButton!
    @IBOutlet weak var lookCategoryCollView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first,  let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
            self.inputLat = lat
            self.inputLong = long
        }
        
        self.registerCell()
        self.setupUI()
        self.isCategory = true
        self.classesCategoryCollView.isHidden = true
        self.lookCategoryCollView.isHidden = true
                
        self.filters = ("0","0")
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func categoryFirstCellSelection(){
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        
        if let categoryCount = classCategoryData?.count, categoryCount > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.classesCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
                self.classesCategoryCollView.delegate?.collectionView?(self.classesCategoryCollView, didSelectItemAt: firstIndexPath)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Classes"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func searchLocBtnActn(_ sender: Any) {
        print("Search btn clicked......")
        
        GetLocationManager.shared.presentSearchPlace(from: self, completion: { [weak self] placeData in
            guard let self = self else { return  }
            self.searchLocTxtField.text = nil
            self.searchLocTxtField.text = placeData.name
            self.inputLat = "\(placeData.coordinate.latitude)"
            self.inputLong = "\(placeData.coordinate.longitude)"

            //            appUserDefaults.setLatLong(value: "\(placeData.coordinate.latitude),\(placeData.coordinate.longitude)")
//            appUserDefaults.setCurrentAddr(value: placeData.name)
            
            self.viewAllClass(filterIdStr: filters.filterId,
                         categoryIdStr: filters.categoryId)
        })
    }
    
    @IBAction func lookViewAllBtnActn(_ sender: Any) {
        let vc: ClassCategoryViewController = ClassCategoryViewController.instantiate(appStoryboard: .dashboard)
        vc.classesWithCategoryData = self.classesWithCategoryData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func setupUI(){
        
        self.searchLocTxtField.text = appUserDefaults.getCurrentAddr() //GetLocationManager.shared.getCurrentAddr.0
        
            self.selectLocLeftBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
            self.searchLocTxtField.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.lookCategoryBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.lookViewAllBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        
            DispatchQueue.main.async {
                self.searchMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 6.0)
            }
       
    }
    
    private func registerCell(){
        classesCategoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        classesListTblView.register(UINib(nibName: "ClassesNearControllerTableViewCell", bundle: nil), forCellReuseIdentifier: "ClassesNearControllerTableViewCell")
        lookCategoryCollView.register(UINib(nibName: "ClassCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ClassCategoryCollectionViewCell")
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if classesListTblView.contentSize.height != 0 {
            self.classesListTblHeightConstrnt.constant = self.classesListTblView.contentSize.height
        }else{
            self.classesListTblHeightConstrnt.constant = 1.0
        }
        view.layoutIfNeeded()
    }
}

extension ClassesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allClassesData?.count ?? 0
       
//        return tableView.numberOfRows(count: self.allClassesData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ClassesNearControllerTableViewCell = classesListTblView.dequeueReusableCell(withIdentifier: "ClassesNearControllerTableViewCell", for: indexPath) as! ClassesNearControllerTableViewCell
        
//        cell.classesBckImgView.image = UIImage(named: "ic_trainer")?.resized(to: CGSize(width: cell.frame.size.width, height: 250))
        
        cell.setCell(cellData: allClassesData?[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: ClassDetailsViewController = ClassDetailsViewController.instantiate(appStoryboard: .dashboard)
        vc.scheludeIdStr = "\(self.allClassesData?[indexPath.row].scheduleID ?? 0)"
        vc.inputLat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first
        vc.inputLong = appUserDefaults.getLatLong()?.components(separatedBy: ",").last
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
}

extension ClassesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == classesCategoryCollView {
            return classCategoryData?.count ?? 0
        }else{
            return collectionView.numberOfRows(count: classesWithCategoryData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100.0, height: 80.0)), messageImageHeight: 80.0, fromTop: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == classesCategoryCollView {
            let cell: WorkoutCategoryCollectionViewCell = classesCategoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            
            cell.categoryImgView.loadImage(urlString: self.classCategoryData?[indexPath.row].icon, placeholder: UIImage(named: "ic_barbell_ diagonal"))
            cell.categoryTitleLbl.text = classCategoryData?[indexPath.row].name
            
            return cell
        }else{
            let lookCell: ClassCategoryCollectionViewCell = lookCategoryCollView.dequeueReusableCell(withReuseIdentifier: "ClassCategoryCollectionViewCell", for: indexPath) as! ClassCategoryCollectionViewCell
            
            lookCell.setCellData(cellData: classesWithCategoryData?[indexPath.row])
            return lookCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == classesCategoryCollView {
            let filterId = indexPath.row == 0 ? "0" : "1"
            self.filters = (filterId,"\(classCategoryData?[indexPath.row].id ?? 0)")
        }else{
            let vc: CategoryWiseClassesViewController = CategoryWiseClassesViewController.instantiate(appStoryboard: .dashboard)
            vc.categoryIdStr = "\(classesWithCategoryData?[indexPath.row].categoryID ?? 0)"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == classesCategoryCollView {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }else{
            return CGSize(width: collectionView.frame.size.width * 0.43, height: collectionView.frame.size.height)
        }
    }
}


//MARK: ----------------- API
extension ClassesViewController{
    
    private func viewAllClass(filterIdStr: String?, categoryIdStr: String?){
        
        if let lat = self.inputLat, let long = self.inputLong {
            let params:[String:String] = [
                "long": long,
                "lat": lat,
                "is_filter": filterIdStr ?? "",
                "category_id": categoryIdStr ?? ""
            ]
            
            UpcomingClassVM.viewAllClassesApi(inputParams: params, completion: {[weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                
                print("getResultData: ", getResultData)
                self.classesCategoryCollView.isHidden = false
                self.lookCategoryCollView.isHidden = false
                
                self.allClassesData?.removeAll()
                self.classesWithCategoryData?.removeAll()
                
                if let _ = isCategory {
                    self.isCategory = nil
                    self.classCategoryData?.removeAll()
                    self.classCategoryData?.append(contentsOf: getResultData.data?.allcategories ?? [])
                    let categoryData: AllcategoryModel = AllcategoryModel(id: 0, name: "All Workouts", icon: nibName, image: "")
                    self.classCategoryData?.insert(categoryData, at: 0)
                    self.classesCategoryCollView.reloadData()
                    self.categoryFirstCellSelection()
                }
                
                self.allClassesData?.append(contentsOf: getResultData.data?.allClasses ?? [])
                self.classesWithCategoryData?.append(contentsOf: getResultData.data?.classesWithCategory ?? [])
                self.classesListTblView.reloadData()
                self.lookCategoryCollView.reloadData()
                
            })
        }
    }
}
