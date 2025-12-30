//
//  SearchWorkoutViewController.swift
//  MyPT
//
//  Created by techsaga corp on 07/01/25.
//

import UIKit

class SearchWorkoutViewController: CommonViewController {
    
    //MARK: -----------VARIABLE
    var GetWorkoutsData: GetWorkoutsDataModel?
    var getWorkoutLst: [GetWorkoutsModel]? = []
    var searchWorkoutLst: [GetWorkoutsModel]? = []
    var categoryIdStr: String?
    private var debounceWorkItem: DispatchWorkItem?
    private var searchTxt: String?
    
    private var WorkoutsApiParams: FilterDataParamsModel? = FilterDataParamsModel() {
        didSet{
            self.WorkoutsApiParams?.name = searchTxt
            self.getWorkoutsApi(inputParams: WorkoutsApiParams)
        }
    }
    
    var isLoading = false
    var isCountInintial = false
    
    private var lastContentHeight: CGFloat = 0 {
        didSet {
            print("lastContentHeight:", lastContentHeight)
            // Increment page only when content height *actually grows*
            if lastContentHeight > oldValue {
                currentPageNum += 1
            }
        }
    }
    
    private var currentPageNum: Int = 1 {
        didSet {
            print("currentPageNum:", currentPageNum)
            if isCountInintial {
                isCountInintial = false
                currentPageNum = 1
                lastContentHeight = (currentPageNum == 1 ? 0 : lastContentHeight)
                return
            }
            WorkoutsApiParams?.page = "\(currentPageNum)"
        }
    }
    
    private var listCount: Int = 0 {
        didSet{
            if let workoutLst = self.getWorkoutLst , workoutLst.count > 0 {
                self.filterBtn.isHidden = false
                let dataMsg: String = workoutLst.count == 1 ? "Result Found" : "Results Found"
                self.searchTitleLbl.text = "\(workoutLst.count)" + " " + dataMsg
            }else{
                self.searchTitleLbl.text = "0 Result Found"
                self.filterBtn.isHidden = true
            }
        }
    }
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var headerMBV: UIView!
    @IBOutlet weak var searchMBV: UIView!
    @IBOutlet weak var workoutSearch: UISearchBar!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchTitleLbl: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var workoutTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.workoutTblView.isHidden = true
        self.filterBtn.isHidden = true
        
        self.getWorkoutLst?.removeAll()
        self.searchWorkoutLst?.removeAll()
        
        if let categoryIdStr = categoryIdStr {
            self.WorkoutsApiParams?.type = categoryIdStr
        }else{
            self.WorkoutsApiParams?.type = ""
        }
        
        self.setupUI()
        self.setupFont()
        self.setUISearchbar()
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
    
    
    override func keyboardWillShow(_ notification: Notification) {
        self.customBlurViewRemove(viewShow: view)
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Explore Library"], setTintColor: .black, setTitleColor: UIColor.appWhite)
        //        self.setRighMenu(rightImgs: [AppImages.shareGymWorkout], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func searchBtnActn(_ sender: Any) {
        print("seacrch btn actn clicked..")
        let vc:ChooseWorkoutViewController = ChooseWorkoutViewController.instantiate(appStoryboard: .library)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func filterBtnActn(_ sender: Any) {
        print("filter btn clicked")
        //        self.filterBtn.setTitle("FILTER", for: .normal)
        workoutSearch.endEditing(true)
        workoutSearch.resignFirstResponder()
        
        let vc:WorkoutFilterViewController = WorkoutFilterViewController.instantiate(appStoryboard: .library)
        vc.modalPresentationStyle = .automatic
        
        vc.filterCount = { [weak self] getData in
            guard let self = self else { return }
            
            self.filterBtn.setTitle("FILTER(\(getData))", for: .normal)
        }
        
        vc.sendBckFilters = {[weak self] getFilterData in
            guard let self = self else { return }
            self.getWorkoutLst?.removeAll()
            self.workoutTblView.reloadData()
            self.isCountInintial = true
            self.lastContentHeight = 0
            self.currentPageNum = 1
            self.WorkoutsApiParams = getFilterData
        }
        
        //        vc.filterData = self.WorkoutsApiParams
        if let _ = self.WorkoutsApiParams {
            vc.filterData = self.WorkoutsApiParams
        }else{
            vc.filterData = FilterDataParamsModel()
        }
        self.present(vc, animated: true)
    }
    
    func setUISearchbar(){
        self.workoutSearch.delegate = self
        self.workoutSearch.barTintColor = UIColor.clear
        self.workoutSearch.isTranslucent = false
        self.workoutSearch.backgroundColor = .clear
        self.workoutSearch.searchTextField.backgroundColor = .clear
        self.workoutSearch.layer.borderWidth = 0
        self.workoutSearch.layer.borderColor = UIColor.black.cgColor
        
        self.workoutSearch.setImage(UIImage(named: "ic_search_normal"), for: .search, state: .normal)
        
        if let searchTextField = self.workoutSearch.value(forKey: "searchField") as? UITextField {
            searchTextField.backgroundColor = UIColor.clear
            searchTextField.textColor = UIColor.appWhite
            searchTextField.setMultiColorPlaceholder(firstStr: "Search for", firstColor: UIColor.txtDarkGray, firstfont: AppFont.semibold.size(14.0, familyName: familyManrope), secondStr: "Workout", secondColor: UIColor.appWhite, secondfont: AppFont.semibold.size(14.0, familyName: familyManrope))
        }
    }
    
    func setupUI(){
        self.workoutTblView.register(UINib(nibName: "SearchWorkoutTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchWorkoutTableViewCell")
        
        DispatchQueue.main.async {
            self.workoutSearch.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            self.searchBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.workoutSearch.searchTextField.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.searchTitleLbl.font =  AppFont.semibold.size(18.0, familyName: familyManrope)
        self.filterBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
    }
}

extension SearchWorkoutViewController: UITableViewDelegate, UITableViewDataSource{
    
    //MARK: ------------NO DATA FOUND CONFIGURATION
    func noSessionsConfig(inputTable:UITableView?, getCount:Int?) -> Int{
        let msgImage = UIImage(named: "ic_search_NoResult")
        guard let countReturn = inputTable?.numberOfRows(count: self.getWorkoutLst?.count, title: AppAlertStrings.no_results_found, message: AppAlertStrings.no_Match_alterMsg, messageImage: msgImage, messageImageHeight: (msgImage?.size.height ?? 10) * 0.4, reloadSetTitle: nil, target: self, action: #selector(reloadData(sender: )), fromCenter: -20) else { return 0}
        
        return  countReturn
    }
    
    @objc func reloadData(sender: UIButton){
        self.workoutTblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return noSessionsConfig(inputTable: self.workoutTblView, getCount: self.getWorkoutLst?.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchWorkoutTableViewCell = workoutTblView.dequeueReusableCell(withIdentifier: "SearchWorkoutTableViewCell", for: indexPath) as! SearchWorkoutTableViewCell
        cell.seriesWorkoutLbl.isHidden = true
        cell.seriesWorkoutLbl.text = nil
        cell.repsMBV.isHidden = false
        cell.kcalMBV.isHidden = true
        cell.timingMBV.isHidden = false
        cell.repsImgView.image = UIImage(named: "ic_clockGray")
        cell.timingImgView.image = UIImage(named: "ic_solid_fireGray")
        
        cell.shareBtn.addTarget(self, action: #selector(shareToSocial(sender: )), for: .touchUpInside)
        cell.setExercisesData(cellData: getWorkoutLst?[indexPath.row])
        
        cell.videoPlayBtn.accessibilityLabel = cell.workoutNameLbl.text
        cell.videoPlayBtn.accessibilityValue = self.getWorkoutLst?[indexPath.row].id?.value
        cell.videoPlayBtn.addTarget(self, action: #selector(playExerciseBtnActn(sender: )), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return headerMBV
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    @objc func shareToSocial(sender: UIButton){
        Utility.shared.shareSocial(viewController: self, textToShare: "Share to social", imageToShare: AppImages.navLeft ?? UIImage(), urlShareStr: "https://www.google.com/")
    }
    
    @objc func playExerciseBtnActn(sender: UIButton){
        let vc:WorkoutDetailsViewController = WorkoutDetailsViewController.instantiate(appStoryboard: .library)
        vc.workoutNameStr = sender.accessibilityLabel
        vc.workoutId = sender.accessibilityValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchWorkoutViewController{
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // Trigger when scrolled near bottom
        if offsetY + frameHeight >= contentHeight - 50 { // 50px threshold
            if !isLoading {
                isLoading = true
                lastContentHeight = contentHeight - 50
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//          print("Started dragging")
        workoutSearch.endEditing(true)
        workoutSearch.resignFirstResponder()
      }
    
}

extension SearchWorkoutViewController {
    private func getWorkoutsApi(inputParams: FilterDataParamsModel?){
        
        let params:[String:Any]? = [
            "filter_by": inputParams?.filter_by ?? "",
            "type": inputParams?.type ?? "1",
            "page": inputParams?.page ?? "" ,
            "muscle_id": inputParams?.muscle_id ?? "",
            "level": inputParams?.level ?? "",
            "calories": inputParams?.calories ?? "",
            "duration": inputParams?.duration ?? "",
            "per_page": inputParams?.per_page ?? "",
            "name": inputParams?.name ?? ""
        ]
        
        print("params: ", params as Any)
        
        WorkoutLibraryVM.getWorkoutApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            print("getResultData: ", getResultData)
            self.workoutTblView.isHidden = false
            if getResultData.status == true {
                self.isLoading = false
                self.GetWorkoutsData = nil
                self.GetWorkoutsData = getResultData.data
//                self.getWorkoutLst?.removeAll()
                self.getWorkoutLst?.append(contentsOf: getResultData.data?.workouts ?? [])
//                self.searchWorkoutLst?.removeAll()
                self.searchWorkoutLst?.append(contentsOf: self.getWorkoutLst ?? [])
                self.listCount = self.getWorkoutLst?.count ?? 0
                self.workoutTblView.reloadData()
            }
        })
    }
    
    //    private func getExercisesApi(currentPageNum: Int?){
    //        WorkoutLibraryVM.getExercisesApi(inputPageNum: currentPageNum, completion: {[weak self] getResultData in
    //            guard let self = self, let getResultData = getResultData else { return }
    //            print("getResultData: ", getResultData)
    //            self.workoutTblView.isHidden = false
    //            if getResultData.status == true {
    //                self.exerciseData = nil
    //                self.exerciseData = getResultData.data
    //                self.exercisesLst?.removeAll()
    //                self.exercisesLst?.append(contentsOf: getResultData.data?.exercisesData ?? [])
    //                self.workoutTblView.reloadData()
    //            }
    //        })
    //    }
}


extension SearchWorkoutViewController: UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        //searchBar.showsCancelButton = false
        // Remove focus from the search bar.
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        
        /*
        self.getWorkoutLst?.removeAll()
        self.getWorkoutLst = self.searchWorkoutLst
        self.listCount = self.getWorkoutLst?.count ?? 0
        self.workoutTblView.reloadData()
        */
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Perform search action with the search text
        print("Search text: \(searchBar.text ?? "")")
        searchBar.resignFirstResponder()
    }
    
    // SearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Cancel any pending task
        debounceWorkItem?.cancel()
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // This runs only after 0.5s of no typing
            self.getWorkoutLst?.removeAll()
            self.workoutTblView.reloadData()
            self.searchTxt = searchText.lowercased()
            self.lastContentHeight = 0
            self.currentPageNum = 1
            
//            self.WorkoutsApiParams?.name = searchText.lowercased()
        }
        // Save it and run after 0.5s
        debounceWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
        
        /*
         if searchText.isEmpty {
         self.getWorkoutLst?.removeAll()
         self.getWorkoutLst = self.searchWorkoutLst
         self.listCount = self.getWorkoutLst?.count ?? 0
         } else {
         if let trainerData = self.searchWorkoutLst {
         self.getWorkoutLst = trainerData.filter { ($0.name ?? "").lowercased().contains(searchText.lowercased()) }
         print("in filter trainerData: ", self.getWorkoutLst?.count as Any)
         }else{
         print("in outer trainerData: ", self.getWorkoutLst?.count as Any)
         }
         }
         
         self.listCount = self.getWorkoutLst?.count ?? 0
         self.workoutTblView.reloadData()
         */
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print(searchBar.text as Any)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


//MARK: -------------FILTER MODEL PARAMETERS
struct FilterDataParamsModel {
    var filter_by: String?
    var type: String?
    var page: String?
    var muscle_id: String?
    var level: String?
    var calories: String?
    var duration: String?
    var per_page: String?
    var name: String?
}

