//
//  ChooseExerciseViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/12/24.
//

import UIKit

struct GetExerciseParam {
    var page: Int?
    var category_id: String?
    var level: String?
    var group_ids:String?
}

class ChooseExerciseViewController: CommonViewController {

    //MARK: ---------- VARIABLE
    private var searchTxtFieldWorkItem: DispatchWorkItem?
    private var searchTxt: String?
    var exerciseData:[ExercisesDatailsModel]? = []
    var selectedExerciseData:[ExercisesDatailsModel]? = []
    var filterBodyPartsData:[WorkoutAllcategoryModel]? = []
    var filterEquipmentWorkoutsCategory: [WorkoutAllcategoryModel]? = []
    
    var paramsExercise: GetExerciseParam? = GetExerciseParam(){
        didSet{
            self.paramsExercise?.level = self.searchTxt
            self.getExercisesApi(inputParams: paramsExercise)
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
            paramsExercise?.page = currentPageNum
        }
    }

    
    
    var filterData:[[String:Any]]?
    var categoryData:[[String:Any]]?
    var sentExerciseData: (([ExercisesDatailsModel]?) -> Void)?
    
    var addExerciseCount:Int = 0{
        didSet{
            if let selectedExerciseData = selectedExerciseData {
                if selectedExerciseData.count > 0 {
                    self.addExerciseBtn.setTitle("ADD EXERCISE (\(selectedExerciseData.count))", for: .normal)
                    self.enableDateBtn(isSelected: true, btn: self.addExerciseBtn)
                }else{
                    self.addExerciseBtn.setTitle("ADD EXERCISE", for: .normal)
                    self.enableDateBtn(isSelected: false, btn: self.addExerciseBtn)
                }
            }
            
            
            //            if addExerciseCount > 0 {
            //                self.addExerciseBtn.setTitle("ADD EXERCISE (\(addExerciseCount))", for: .normal)
            //            }else{
            //                self.addExerciseBtn.setTitle("ADD EXERCISE", for: .normal)
            //            }
        }
    }
        
    //MARK: --------------IBOUTLET
    @IBOutlet var customHeaderView: UIView!
    @IBOutlet weak var serchTxtFiled: UITextField!
    @IBOutlet weak var serchTxtFiledHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var logoBtn: UIButton!
    @IBOutlet weak var gymCategoryCollView: UICollectionView!
    @IBOutlet weak var gymCategoryCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var filterCategoryCollView: UICollectionView!
    @IBOutlet weak var filterCategoryCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var filterCategoryCollViewBottomConstrnt: NSLayoutConstraint!
    @IBOutlet weak var exerciseTblView: UITableView!
    @IBOutlet weak var addExerciseBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.exerciseTblView.isHidden = true

        self.enableDateBtn(isSelected: false, btn: self.addExerciseBtn)
        self.exerciseData?.removeAll()
        self.setupUI()
        self.setupFont()
        self.setupInputData()
        self.serchTxtFiled.delegate = self
        self.serchTxtFiled.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        if let getSelExerciseData = selectedExerciseData {
            self.selectedExerciseData = getSelExerciseData
        }
        
        self.paramsExercise?.page = 1
        self.addExerciseCount = 1
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.choose_Exercise], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        self.customBlurViewRemove(viewShow: view)
    }
    
    func setupInputData(){
        
        self.exerciseTblView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
        self.gymCategoryCollView.register(UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
        self.filterCategoryCollView.register(UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
        
        self.categoryData = [
            ["title":"All muscles","filterImg": UIImage(named: "ic_running_ jogging") as Any],
            ["title":"All equipment's","filterImg": UIImage(named: "ic_barbell_ diagonal") as Any]
        ]
    
        self.gymCategoryCollView.reloadData()
    }
    
    func setupUI(){
        
        self.exerciseTblView.allowsMultipleSelection = true
        
        DispatchQueue.main.async {
            self.serchTxtFiled.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.logoBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.addExerciseBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.serchTxtFiled.font = AppFont.semibold.size(14.0, familyName: familyManrope)
//        self.serchTxtFiled.placeholderSet(placeHolder: "Search for Exercise", color: UIColor.txtDarkGray)
        self.serchTxtFiled.setLeftPaddingWithImage(50.0, 0, AppImages.search_normal)
        
        self.serchTxtFiled.setMultiColorPlaceholder(firstStr: "Search for", firstColor: UIColor.txtDarkGray, firstfont: AppFont.semibold.size(14.0, familyName: familyManrope), secondStr: "Exercise", secondColor: UIColor.appWhite, secondfont: AppFont.semibold.size(14.0, familyName: familyManrope))
        
        self.addExerciseBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.serchTxtFiledHeightConstrnt.constant = 46.0
        self.gymCategoryCollViewHeightConstrnt.constant = 46.0
//        self.filterCategoryCollViewHeightConstrnt.constant = 46.0
        
        self.filterCategoryCollViewHeightConstrnt.constant = 1.0
        self.filterCategoryCollViewBottomConstrnt.constant = 2.0
        
//        if let countF = filterData?.count, countF != 0 {
//            self.filterCategoryCollViewHeightConstrnt.constant = 46.0
//            self.filterCategoryCollViewBottomConstrnt.constant = 10.0
//        }else{
//            self.filterCategoryCollViewHeightConstrnt.constant = 1.0
//            self.filterCategoryCollViewBottomConstrnt.constant = 2.0
//        }
        
//        if let countF = filterBodyPartsData?.count, countF != 0 {
//            self.filterCategoryCollViewHeightConstrnt.constant = 46.0
//            self.filterCategoryCollViewBottomConstrnt.constant = 10.0
//        }else{
//            self.filterCategoryCollViewHeightConstrnt.constant = 1.0
//            self.filterCategoryCollViewBottomConstrnt.constant = 2.0
//        }
        
//        self.filterCategoryCollViewBottomConstrnt.constant = 20.0
        
        self.customHeaderView.layoutIfNeeded()
        self.exerciseTblView.reloadData()
    }
    
    @IBAction func addExerciseBtnActn(_ sender: UIButton) {
        if let selectedExerciseData = selectedExerciseData {
            if selectedExerciseData.count > 0 {
                sentExerciseData?(selectedExerciseData)
                self.navigationController?.popViewController(animated: true)
            }
        }else{
             AlertHelper.shared.showCustomeAlert(message: "Please select at least 1 exercise!")
         }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        searchTxtFieldWorkItem?.cancel()
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // This runs only after 0.5s of no typing
            self.exerciseData?.removeAll()
            self.exerciseTblView.reloadData()
            self.searchTxt = textField.text?.lowercased()
            self.lastContentHeight = 0
            self.currentPageNum = 1
        }
        // Save it and run after 0.5s
        searchTxtFieldWorkItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
        
       }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        guard let headerView = exerciseTblView.tableHeaderView else {return}
//        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        if customHeaderView.frame.size.height != size.height {
//            customHeaderView.frame.size.height = size.height
//            exerciseTblView.tableHeaderView = customHeaderView
//            exerciseTblView.layoutIfNeeded()
//        }
//    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableDateBtn(isSelected:Bool = false, btn:UIButton){
        if isSelected {
            btn.isUserInteractionEnabled = true
            btn.backgroundColor = UIColor.appWhite
            btn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            btn.isUserInteractionEnabled = false
            btn.backgroundColor = UIColor.appDarkGray
            btn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
}

//MARK: -------------EXTENSION FOR UITABLEVIEW DELEGATE/DATASOURCE
extension ChooseExerciseViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableView.numberOfRows(count: self.exerciseData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 200, height: 200)), messageImageHeight: 100, fromCenter: 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ExerciseTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
        cell.bgImgView.image = UIImage(named: "ic_calendarFilter")
        cell.checkBtn.isUserInteractionEnabled = false
        
        cell.setCellData(cellData: self.exerciseData?[indexPath.row])
        
//        if indexPath.row % 2 == 0 {
//            cell.workoutGroupMBV.isHidden = false
//        }
        
        //---------------for make already selected cell
        let alreadySelectedExercise = exerciseData?[indexPath.row]
        if let alreadySelectedExercise = alreadySelectedExercise {
//            if let index = selectedExerciseData?.firstIndex(where: { $0.id?.value == alreadySelectedExercise.id?.value}) {
//               
//                cell.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 24.0)
//                
//                cell.checkBtn.setImage(UIImage(named: "ic_filterChecked"), for: .normal)
//            }
            
            let alreadySelected = selectedExerciseData?.contains(where: { $0.id?.value == alreadySelectedExercise.id?.value }) ?? false
            
            if alreadySelected {
                DispatchQueue.main.async {
                    cell.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 24.0)
                    
                    cell.checkBtn.setImage(UIImage(named: "ic_filterChecked"), for: .normal)
                }
               
            }else{
                DispatchQueue.main.async {
                    cell.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor.appBorder, shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 24.0)
                    
                    cell.checkBtn.setImage(UIImage(named: "ic_filterUncheck"), for: .normal)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ExerciseTableViewCell
        
        selectedCell.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 24.0)
        
        selectedCell.checkBtn.setImage(UIImage(named: "ic_filterChecked"), for: .normal)
        
        let selectedExercise = exerciseData?[indexPath.row]

        if let selectedExercise = selectedExercise {
            // Check if it's already in selectedExerciseData
            let alreadySelected = selectedExerciseData?.contains(where: { $0.id?.value == selectedExercise.id?.value }) ?? false
            
            if !alreadySelected {
                selectedExerciseData?.append(selectedExercise)
            }else{
                //----------- It's use when already selected cell
                selectedCell.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor.appBorder, shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 24.0)
                selectedCell.checkBtn.setImage(UIImage(named: "ic_filterUncheck"), for: .normal)

                    if let index = selectedExerciseData?.firstIndex(where: { $0.id?.value == selectedExercise.id?.value}) {
                        selectedExerciseData?.remove(at: index)
                    }
            }
        }
        
        self.addExerciseCount = 1
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath) as! ExerciseTableViewCell
        
        deSelectedCell.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor.appBorder, shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 24.0)
        
        deSelectedCell.checkBtn.setImage(UIImage(named: "ic_filterUncheck"), for: .normal)
        
        
        let deselectedExercise = exerciseData?[indexPath.row]
        if let deselectedExercise = deselectedExercise {
            if let index = selectedExerciseData?.firstIndex(where: { $0.id?.value == deselectedExercise.id?.value}) {
                selectedExerciseData?.remove(at: index)
            }else{
                //--------- For Handle already selecte/deselected
                deSelectedCell.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 24.0)
                
                deSelectedCell.checkBtn.setImage(UIImage(named: "ic_filterChecked"), for: .normal)
                selectedExerciseData?.append(deselectedExercise)
            }
        }
        
        self.addExerciseCount = 1
        
        /*
        let deselectedExercise = exerciseData?[indexPath.row]
        if let deselectedExercise = deselectedExercise {
            if let index = selectedExerciseData?.firstIndex(where: { $0.id?.value == deselectedExercise.id?.value}) {
                selectedExerciseData?.remove(at: index)
            }
        }
        */
        
        
//        guard self.addExerciseCount > -1 else {
//            return
//        }
//        self.addExerciseCount -= 1
        
    }
    
    /*
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
         let deSelectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
         deSelectedCell.leftImgView.image = nil
     }
     */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return customHeaderView
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
        
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//       {
//           return UITableView.automaticDimension
//       }
    
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

           return UITableView.automaticDimension

       }
}


//MARK: -----------------EXTENSION FOR UICOLLECTIONVIEW DATASOURCE/DELEGATE
extension ChooseExerciseViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == gymCategoryCollView {
            return categoryData?.count ?? 0
        }else{
            return self.filterBodyPartsData?.count ?? 0 //filterData?.count ?? 0
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == gymCategoryCollView {
            let cell:FilterCategoryCollectionViewCell = gymCategoryCollView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCollectionViewCell", for: indexPath) as! FilterCategoryCollectionViewCell
            cell.gymCategoryImgView.image = categoryData?[indexPath.row]["filterImg"] as? UIImage //filterImg
            cell.gymCategoryNameLbl.text = categoryData?[indexPath.row]["title"] as? String
            
            return cell
        } else{
            let cell:FilterCategoryCollectionViewCell = filterCategoryCollView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCollectionViewCell", for: indexPath) as! FilterCategoryCollectionViewCell
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: cell.cellMBV.frame.size.height/2.0)
            }
            
            cell.gymCategoryImgView.image = UIImage(named: "ic_running_ jogging") //filterData?[indexPath.row]["filterImg"] as? UIImage //filterImg
            cell.selectionImgView.image = UIImage(named: "ic_cross_circle")
            cell.gymCategoryNameLbl.text = self.filterBodyPartsData?[indexPath.row].name?.value //filterData?[indexPath.row]["title"] as? String
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vc:ExerciseFilterPopupViewController = ExerciseFilterPopupViewController.instantiate(appStoryboard: .calendar)
            vc.modalPresentationStyle = .automatic
            vc.setupExerciseFilterFlow = .muscles
            vc.sentBackFilterData = { [weak self] (getBodyPartFilter, getEquipmentFilter) in
                
                guard let self = self, let getBodyPartFilter = getBodyPartFilter else { return  }
                
                self.filterBodyPartsData?.removeAll()
                self.filterBodyPartsData?.append(contentsOf: getBodyPartFilter)
   
                self.exerciseData?.removeAll()
                self.exerciseTblView.reloadData()
                self.isCountInintial = true
                self.lastContentHeight = 0
                self.currentPageNum = 1
                
                let groupIdStr = filterBodyPartsData?
                    .compactMap { $0.id?.value }
                    .joined(separator: ",")
                self.paramsExercise?.group_ids = groupIdStr
                
                /*
                 group_ids: 1,2,3, group ids comma sepearted
                 */
            
//                self.filterCategoryCollView.reloadData()
                
//                self.filterData = [
//                    ["title": getbackData.first as? String as Any,"filterImg": UIImage(named: "ic_running_ jogging") as Any],
//                    ["title":getbackData.first as? String as Any,"filterImg": UIImage(named: "ic_barbell_ diagonal") as Any]
//                ]
//                self.filterCategoryCollView.reloadData()
            }
            
            if let filterBodyPartsData = self.filterBodyPartsData {
                vc.localBodyPartsData = filterBodyPartsData
            }
            
            self.navigationController?.present(vc, animated: true)
        }else{
            let vc:ExerciseFilterPopupViewController = ExerciseFilterPopupViewController.instantiate(appStoryboard: .calendar)
            vc.modalPresentationStyle = .automatic
            vc.setupExerciseFilterFlow = .equipment
            
            vc.sentBackFilterData = { [weak self] (getBodyPartFilter, getEquipmentFilter) in
                
                guard let self = self, let getEquipmentFilter = getEquipmentFilter else { return  }
                
                self.filterEquipmentWorkoutsCategory?.removeAll()
                self.filterEquipmentWorkoutsCategory?.append(contentsOf: getEquipmentFilter)
            
                self.exerciseData?.removeAll()
                self.exerciseTblView.reloadData()
                self.isCountInintial = true
                self.lastContentHeight = 0
                self.currentPageNum = 1
                
                let groupIdStr = filterEquipmentWorkoutsCategory?
                    .compactMap { $0.id?.value }
                    .joined(separator: ",")
                self.paramsExercise?.group_ids = groupIdStr
                
                /*
                 category_id:1,2,3,  comma separated
                 */
                //                self.filterData = [
                //                    ["title": getbackData.first as? String as Any,"filterImg": UIImage(named: "ic_running_ jogging") as Any],
                //                    ["title":getbackData.first as? String as Any,"filterImg": UIImage(named: "ic_barbell_ diagonal") as Any]
                //                ]
//                self.filterCategoryCollView.reloadData()
                
            }
            
            if let filterEquipmentWorkoutsCategory = self.filterEquipmentWorkoutsCategory {
                vc.localWorkoutsCategory = filterEquipmentWorkoutsCategory
            }
            
            self.navigationController?.present(vc, animated: true)
        }
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.updateViewConstraints()
    }
}

extension ChooseExerciseViewController{
  
    private func getExercisesApi(inputParams: GetExerciseParam?){
     
         let params:[String:Any]? = [
            "page" : inputParams?.page ?? 1,
            "category_id": inputParams?.category_id ?? "", // 1,2,3
            "level": inputParams?.level ?? "" , //name
            "group_ids": inputParams?.group_ids ?? "" //1,2,3 , group ids comma sepearted
         ]
         
        WorkoutLibraryVM.getExercisesApi(params: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            print("getResultData: ", getResultData)
                self.exerciseTblView.isHidden = false
            if getResultData.status == true {
                self.isLoading = false
//                self.exerciseData = getResultData.data?.exercisesData
//                self.exerciseData?.removeAll()
                self.exerciseData?.append(contentsOf: getResultData.data?.exercisesData ?? [])
                self.exerciseTblView.reloadData()
            }
        })
    }
}

extension ChooseExerciseViewController{
    
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
        serchTxtFiled.endEditing(true)
        serchTxtFiled.resignFirstResponder()
      }
    
}

//MARK: --------------- UITextFieldDelegate
extension ChooseExerciseViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
