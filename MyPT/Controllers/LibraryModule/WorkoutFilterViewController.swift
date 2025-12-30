//
//  WorkoutFilterViewController.swift
//  MyPT
//
//  Created by techsaga corp on 08/01/25.
//

import UIKit

class WorkoutFilterViewController: UIViewController {
    
    //MARK: --------------VARIABLE
    private var WorkoutTypeIds = Set<String>()
    var sendBckFilters: ((FilterDataParamsModel?) -> Void)?
    var filterData: FilterDataParamsModel? = FilterDataParamsModel()
    var workoutFilters:[WorkoutLevelModel]? = []
    var workLevelData:[WorkoutLevelModel]? = []
    var workoutsTypeLst: [WorkoutAllcategoryModel]? = []
    var bodyPartsLst:[WorkoutAllcategoryModel]? = []
    var filterCount:((Int)-> Void)?
    
    var countItems:Int = 0{
        didSet{
            self.applyFilterBtn.setTitle("APPLY FILTER (\(countItems))", for: .normal)
        }
    }
    
    private var iscalorieBurn: Bool? {
        didSet{
            if let iscalorieBurn = iscalorieBurn, iscalorieBurn {
                countItems += 1
            }
        }
    }
    
    private var isDuration: Bool? {
        didSet{
            if let isDuration = isDuration, isDuration {
                countItems += 1
            }
        }
    }
    
    private var isFilterBy: Bool? {
        didSet{
            if let isFilterBy = isFilterBy, isFilterBy {
                countItems += 1
            }
        }
    }
    
    private var WorkoutTypeIdStr: String {
        return WorkoutTypeIds.joined(separator: ",")
    }
    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var filterPopupMBV: UIView!
    @IBOutlet weak var filterByMBV: UIView!
    @IBOutlet weak var filterBySubMbv: UIView!
    @IBOutlet weak var workoutTypeMBV: UIView!
    @IBOutlet weak var bodyPartsMBV: UIView!
    @IBOutlet weak var workoutLevelMBV: UIView!
    @IBOutlet weak var workoutDurationMBV: UIView!
    @IBOutlet weak var workoutRangeMBV: CustomRangeSlider!
    @IBOutlet weak var calorieBurnMBV: UIView!
    @IBOutlet weak var applyFilterMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var filterTitleLbl: UILabel!
    @IBOutlet weak var workoutTypeTitleLbl: UILabel!
    @IBOutlet weak var bodypartsLbl: UILabel!
    @IBOutlet weak var workoutLevelTitleLbl: UILabel!
    @IBOutlet weak var durationTitleLbl: UILabel!
    @IBOutlet weak var minutesLbl: UILabel!
    @IBOutlet weak var calorieBurnTitleLbl: UILabel!
    @IBOutlet weak var KcalLbl: UILabel!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var applyFilterBtn: UIButton!
    @IBOutlet weak var filterByTxtField: UITextField!
    @IBOutlet weak var workoutTypeCollView: UICollectionView!
    @IBOutlet weak var bodypartsCollView: UICollectionView!
    @IBOutlet weak var workoutLevelCollView: UICollectionView!
    @IBOutlet weak var customThumbSlider: ThumbTextSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupFont()
        self.getBodyPartsApi()
        self.getWorkoutTypeApi()
        self.filterByTxtField.text = "Select" //"Most Popular"
        self.workoutRangeMBV.delegate = self
        
        //        self.workTypeData = ["ic_filterRunning","ic_Filter_scadling","ic_filter_walking","ic_filter_walking2","ic_filter_cycling","ic_barbell_ diagonal"]
        //        self.workoutTypeCollView.reloadData()
        
        self.setupCustomSlider()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    @IBAction func helpBtnActn(_ sender: Any) {
        print("helpBtn clicked...")
    }
    
    @IBAction func filterByDropDownBtnActn(_ sender: Any) {
        print("Filter by btn actn clicked.....")
        self.filterByTxtField.becomeFirstResponder()
    }
    
    @IBAction func applyFilterBtnActn(_ sender: Any) {
        self.filterData?.type = WorkoutTypeIdStr
        print("applyFilterBtnActn clicked..", self.filterData as Any)
        self.dismiss(animated: true, completion: {[weak self] in
            self?.filterData?.page = "1"
            self?.sendBckFilters?(self?.filterData)
            if let countItems = self?.countItems , countItems != 0 {
                self?.filterCount?(countItems)
            }
        })
    }
    
    private func localInputData(){
        if let filter_by = filterData?.filter_by {
            print("Local filter data: ", filter_by)
            if let indx = self.workoutFilters?.firstIndex(where: { $0.id?.value == filter_by }){
                self.filterByTxtField.text = self.workoutFilters?[indx].name
                
                if let name = self.workoutFilters?[indx].name, !name.isEmpty {
                    if isFilterBy != true {
                        isFilterBy = true
                    }
                }
            }
        }
        
        if let selectedType = filterData?.type?.components(separatedBy: ",") as? [String] {
            print("Selected levels: ", selectedType)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                for level in selectedType {
                    if let indx = self.workoutsTypeLst?.firstIndex(where: { $0.id?.value == level }) {
                        let indexPath = IndexPath(item: indx, section: 0)
                        self.workoutTypeCollView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                        
                        // Trigger delegate manually if needed
                        self.workoutTypeCollView.delegate?.collectionView?(
                            self.workoutTypeCollView,
                            didSelectItemAt: indexPath
                        )
                    }
                }
                self.view.layoutIfNeeded()
            }
        }
        
        if let bodyPartIds = filterData?.muscle_id {
            print("Local bodyPartIds: ", bodyPartIds)
            if let indx = self.bodyPartsLst?.firstIndex(where: { $0.id?.value == bodyPartIds }){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let levelIndexPath = IndexPath(item: indx, section: 0)
                    self.bodypartsCollView.selectItem(at: levelIndexPath, animated: true, scrollPosition: .top)
                    // Optional: perform any additional setup for the selected cell
                    self.bodypartsCollView.delegate?.collectionView?(self.bodypartsCollView, didSelectItemAt: levelIndexPath)
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        if let level = filterData?.level {
            print("Local level: ", level)
            if let indx = self.workLevelData?.firstIndex(where: { $0.id?.value == level }){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let levelIndexPath = IndexPath(item: indx, section: 0)
                    self.workoutLevelCollView.selectItem(at: levelIndexPath, animated: true, scrollPosition: .top)
                    // Optional: perform any additional setup for the selected cell
                    self.workoutLevelCollView.delegate?.collectionView?(self.workoutLevelCollView, didSelectItemAt: levelIndexPath)
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        if let caloriesValue = filterData?.calories, let getValue = Float(caloriesValue) {
            customThumbSlider.setValue(getValue, animated: false)
            customThumbSlider.sendActions(for: .valueChanged)
            
            if iscalorieBurn != true {
                iscalorieBurn = true
            }
        }
        
        if let workoutDuration = filterData?.duration?.components(separatedBy: "-") as? [String],
           workoutDuration.count == 2,
           let minDouble = Double(workoutDuration[0].trimmingCharacters(in: .whitespaces)),
           let maxDouble = Double(workoutDuration[1].trimmingCharacters(in: .whitespaces)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.workoutRangeMBV.selectedMinValue = CGFloat(minDouble)
                self.workoutRangeMBV.selectedMaxValue =  CGFloat(maxDouble)
                self.workoutRangeMBV.setNeedsLayout()
            }
            
            if isDuration != true {
                isDuration = true
            }
        }
    }
    
    
    func setupCustomSlider(){
        self.customThumbSlider.leftThumbImamge = nil
        self.customThumbSlider.thumbBgColor = UIColor.appYellow
        self.customThumbSlider.borderSetup = (UIColor.appWhite, 2.5, 12.0)
        self.customThumbSlider.thumbTextLabel.textColor = UIColor.appWhite
        self.customThumbSlider.thumbTextLabel.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.customThumbSlider.setMinimumValue = 1.0
        self.customThumbSlider.setMaximumValue = 5000
        self.customThumbSlider.setMinvalue = "\u{007E} 1"
        self.customThumbSlider.addTarget(self, action: #selector(sliderValueChanged(slider: )), for: .valueChanged)
        self.customThumbSlider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
    }
    
    //MARK: ------------------Slider action
    @objc func sliderValueChanged(slider:UISlider){
        self.customThumbSlider.thumbTextLabel.text = "\u{007E}" + "\(Int(slider.value))"
        self.customThumbSlider.value = slider.value
    }
    
    @objc func sliderTouchEnded(_ sender: UISlider) {
        // Value when user lifts finger
        let sliderValue = String(format: "%.2f", sender.value)
        filterData?.calories = sliderValue
        
        if iscalorieBurn != true {
            iscalorieBurn = true
        }
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.filterByTxtField.setLeftPaddingWithImage(45.0, self.filterByTxtField.font?.lineHeight.magnitude ?? 1.0, UIImage(named: "ic_mostPopularchart"))
            self.filterPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.filterPopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.filterBySubMbv.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.txtDarkGray, cornerRadious: 12.0)
            self.applyFilterBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appDarkGray, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.workoutTypeCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        
        self.bodypartsCollView.register(UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
        self.workoutLevelCollView.register(UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
        
        self.workoutTypeCollView.allowsMultipleSelection = true
        self.bodypartsCollView.allowsMultipleSelection = false
        self.workoutLevelCollView.allowsMultipleSelection = false
        
        //------------------------************
        self.topTitleLbl.font = AppFont.bold.size(24.0, familyName: familyManrope)
        self.filterTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.workoutTypeTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.bodypartsLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.workoutLevelTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.durationTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.minutesLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.calorieBurnTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.KcalLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.applyFilterBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if self.filterPopupMBV.frame.contains(location) {
                self.dismiss(animated: true, completion: nil)
            }else{
                print("tap at popup view.")
            }
        }
    }
}

//MARK: ------------------UICOLLECTIONVIEW DELEGATE/DATASOURCE
extension WorkoutFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == workoutTypeCollView {
            return self.workoutsTypeLst?.count ?? 0 //self.workTypeData?.count ?? 0
        }
        else if collectionView == bodypartsCollView{
            return self.bodyPartsLst?.count ?? 0
        }
        else if collectionView == workoutLevelCollView{
            return self.workLevelData?.count ?? 0
        }
        else{
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == workoutTypeCollView {
            let workoutTypeCell:WithMeCollectionViewCell = workoutTypeCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
            
            DispatchQueue.main.async {
                workoutTypeCell.cellMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0)
                workoutTypeCell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
            
            workoutTypeCell.videoThumbnailImgView.image = nil
            workoutTypeCell.videoThumbnailImgView.isHidden = true
            workoutTypeCell.centerImgView.isHidden = false
            workoutTypeCell.centerImgView.image = nil
            workoutTypeCell.centerImgView.loadImage(urlString: workoutsTypeLst?[indexPath.row].icon?.value, placeholder: UIImage(named: "ic_filter_walking2"), resize: CGSize(width: 50.0, height: 50.0))
            
            //            workoutTypeCell.centerImgView.image = UIImage(named: self.workTypeData?[indexPath.row] as? String ?? "")
            
            return workoutTypeCell
        }
        else if collectionView == bodypartsCollView{
            let bodypartCell:FilterCategoryCollectionViewCell = bodypartsCollView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCollectionViewCell", for: indexPath) as! FilterCategoryCollectionViewCell
            
            bodypartCell.gymCategoryImgView.isHidden = true
            bodypartCell.gymCategoryImgView.image = nil
            bodypartCell.gymCategoryImgWidthConstrnt.constant = 1.0
            //            bodypartCell.selectionImgView.image = UIImage(named: "ic_filterChecked")
            bodypartCell.selectionImgView.image = UIImage(named: "ic_filterUncheck")
            bodypartCell.gymCategoryNameLbl.text = self.bodyPartsLst?[indexPath.row].name?.value
            
            return bodypartCell
            
        }else{
            let levelCell:FilterCategoryCollectionViewCell = workoutLevelCollView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCollectionViewCell", for: indexPath) as! FilterCategoryCollectionViewCell
            
            levelCell.gymCategoryImgView.isHidden = true
            levelCell.gymCategoryImgView.image = nil
            levelCell.gymCategoryImgWidthConstrnt.constant = 1.0
            //            levelCell.selectionImgView.image = UIImage(named: "ic_filterChecked")
            levelCell.selectionImgView.image = UIImage(named: "ic_filterUncheck")
            levelCell.gymCategoryNameLbl.text = self.workLevelData?[indexPath.row].name  // self.workLevelData?[indexPath.row] as? String
            
            return levelCell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == workoutTypeCollView {
            self.countItems += 1
            let selectedCell = collectionView.cellForItem(at: indexPath) as? WithMeCollectionViewCell
            guard let selectedCell = selectedCell else { return }
            selectedCell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 12.0)
            
            let ids =  workoutsTypeLst?[indexPath.row].id?.value ?? "0"
            if WorkoutTypeIds.contains(ids) {
                WorkoutTypeIds.remove(ids)
            } else {
                WorkoutTypeIds.insert(ids)
            }
        }
        else if collectionView == bodypartsCollView{
            self.countItems += 1
            self.filterData?.muscle_id = bodyPartsLst?[indexPath.row].id?.value
            let bodypartcell = collectionView.cellForItem(at: indexPath) as? FilterCategoryCollectionViewCell
            guard let bodypartcell = bodypartcell else { return }
            bodypartcell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 12.0)
            bodypartcell.selectionImgView.image = UIImage(named: "ic_filterChecked")
            
        }else{
            self.countItems += 1
            self.filterData?.level = workLevelData?[indexPath.row].id?.value
            
            let filtercell = collectionView.cellForItem(at: indexPath) as? FilterCategoryCollectionViewCell
            guard let filtercell = filtercell else { return }
            filtercell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 12.0)
            filtercell.selectionImgView.image = UIImage(named: "ic_filterChecked")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if collectionView == workoutTypeCollView {
            let deselectedcell = collectionView.cellForItem(at: indexPath) as? WithMeCollectionViewCell
            guard let deselectedcell = deselectedcell else { return }
            deselectedcell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            guard self.countItems > 1 else {
                return
            }
            self.countItems -= 1
            let ids =  workoutsTypeLst?[indexPath.row].id?.value ?? "0"
            if WorkoutTypeIds.contains(ids) {
                WorkoutTypeIds.remove(ids)
            }
        }
        else if collectionView == bodypartsCollView{
            
            let bodypartcell = collectionView.cellForItem(at: indexPath) as? FilterCategoryCollectionViewCell
            guard let bodypartcell = bodypartcell else { return }
            bodypartcell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            bodypartcell.selectionImgView.image = UIImage(named: "ic_filterUncheck")
            
            guard self.countItems > 1 else {
                return
            }
            self.countItems -= 1
            
        }else{
            
            let filtercell = collectionView.cellForItem(at: indexPath) as? FilterCategoryCollectionViewCell
            guard let filtercell = filtercell else { return }
            filtercell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            filtercell.selectionImgView.image = UIImage(named: "ic_filterUncheck")
            
            guard self.countItems > 1 else {
                return
            }
            self.countItems -= 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == workoutTypeCollView {
            return CGSize(width: collectionView.frame.width*0.142, height: collectionView.frame.width*0.142)
        }
        else{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
    //MARK: -------------FOR DROP DOWN
    private func openDropDown(inputView: UIView){
        let popupVC:CityDropDownViewController = CityDropDownViewController.instantiate(appStoryboard: .booking)
        popupVC.flowData = .filtersWorkout
        popupVC.modalPresentationStyle = .popover
        popupVC.getAlltCityData = nil
        popupVC.workoutFilters?.removeAll()
        popupVC.workoutFilters?.append(contentsOf: self.workoutFilters ?? [])
        
        popupVC.sentBackData = { [weak self] getFilterName , getId, empty1, empty2 in
            guard let self = self else { return  }
            self.filterByTxtField.text = getFilterName
            self.filterData?.filter_by = "\(getId ?? 0)"
            
            if let name = getFilterName, !name.isEmpty {
                if isFilterBy != true {
                    isFilterBy = true
                }
            }
        }
        popupVC.view.backgroundColor = UIColor.mainBg
        if let popoverController = popupVC.popoverPresentationController {
            popoverController.sourceView = inputView
            popoverController.sourceRect = CGRect(x: inputView.bounds.minX + 70, y: inputView.bounds.minY, width: inputView.bounds.width - 80, height: inputView.bounds.height)
            popoverController.permittedArrowDirections = .up
            popoverController.delegate = self
            popoverController.backgroundColor = UIColor.mainBg
        }
        popupVC.preferredContentSize = CGSize(width: self.view.frame.size.width - 80, height: 150)
        
        present(popupVC, animated: true)
    }
    
}

extension WorkoutFilterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.filterByTxtField {
            view.endEditing(true)
            self.openDropDown(inputView: textField)
            return false
        }
        return true
    }
}

//MARK: ----------------- CUSTOM RANGE SLIDER DELEGATE
extension WorkoutFilterViewController: RangeSeekSliderDelegate {
    
    func didEndTouches(in slider: CustomRangeSlider) {
        let minValue = String(format: "%.2f", slider.selectedMinValue)
        let maxValue = String(format: "%.2f", slider.selectedMaxValue)
        filterData?.duration = "\(minValue)-\(maxValue)"
        print("filterData duration: ", filterData?.duration as Any)
        if isDuration != true {
            isDuration = true
        }
    }
    
}

//MARK: ---------------------- EXTENSION FOR API
extension WorkoutFilterViewController{
    private func getBodyPartsApi(){
        WorkoutLibraryVM.getBodyPartsApi(completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            if getResultData.success == true {
                self.bodyPartsLst?.removeAll()
                self.bodyPartsLst?.append(contentsOf: getResultData.data ?? [])
                self.bodypartsCollView.reloadData()
            }
        })
    }
    
    private func getWorkoutTypeApi(){
        WorkoutLibraryVM.workoutTypeApi(isShowLoader: true, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            if getResultData.status == true {
                self.workoutFilters?.removeAll()
                self.workoutFilters?.append(contentsOf: getResultData.data?.filters ?? [])
                self.workLevelData?.removeAll()
                self.workLevelData?.append(contentsOf: getResultData.data?.workoutLevels ?? [])
                self.workoutLevelCollView.reloadData()
                self.workoutsTypeLst?.removeAll()
                self.workoutsTypeLst?.append(contentsOf: getResultData.data?.allcategory ?? [])
                self.workoutTypeCollView.reloadData()
                
                //----------------********
                self.localInputData()
            }
        })
    }
}

// MARK: ------------ UIPopoverPresentationControllerDelegate
extension WorkoutFilterViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none  // Keeps it as a popover on iPhone instead of full-screen
    }
}
