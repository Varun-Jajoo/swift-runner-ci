//
//  SearchWorkoutViewController.swift
//  MyPT
//
//  Created by techsaga corp on 07/01/25.
//

import UIKit

class SearchWorkoutViewController: CommonViewController {

    //MARK: -----------VARIABLE
    var workoutData:[Any]? = []
    
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
        
        workoutData = [1,1,1]
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
        
        let vc:WorkoutFilterViewController = WorkoutFilterViewController.instantiate(appStoryboard: .library)
        vc.modalPresentationStyle = .automatic
        
        vc.filterCount = { [weak self] getData in
            guard let self = self else { return }
            
            self.filterBtn.setTitle("FILTER(\(getData))", for: .normal)
        }
        self.present(vc, animated: true)
    }
    
    func setUISearchbar(){
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
        
        guard let countReturn = inputTable?.numberOfRows(count: self.workoutData?.count, title: AppAlertStrings.no_results_found, message: AppAlertStrings.no_Match_alterMsg, messageImage: msgImage, messageImageHeight: (msgImage?.size.height ?? 10) * 0.4, reloadSetTitle: nil, target: self, action: #selector(reloadData(sender: )), fromCenter: -20) else { return 0}
        
        return  countReturn
    }
    
    @objc func reloadData(sender: UIButton){
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        self.workoutData?.append(1)
        
        
        self.workoutTblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noSessionsConfig(inputTable: self.workoutTblView, getCount: self.workoutData?.count) //self.workoutData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchWorkoutTableViewCell = workoutTblView.dequeueReusableCell(withIdentifier: "SearchWorkoutTableViewCell", for: indexPath) as! SearchWorkoutTableViewCell
        cell.shareBtn.addTarget(self, action: #selector(shareToSocial(sender: )), for: .touchUpInside)
        
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
}
