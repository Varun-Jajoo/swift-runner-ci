//
//  TrainerFilterViewController.swift
//  MyPT
//
//  Created by techsaga corp on 02/07/25.
//

import UIKit

class TrainerFilterViewController: UIViewController {

    //MARK: --------------- VARIABLE
    var sendGenderStr: ((String, String, [FilterLstDataModel]) -> Void)?
    var sendLanguageStr: ((String, String, [FilterLstDataModel]) -> Void)?
    var sendNationalityStr: ((String, String, [FilterLstDataModel]) -> Void)?
//    var sendTime_slotStr: ((String, String, [FilterLstDataModel]) -> Void)?
    
    var inputType:String?
    var selectedMenuFilterStr: String?
    var filterMenu: [String]?
    var selectedIndexPaths: [IndexPath] = []
    var selectedMenuIndexPath: IndexPath?
    

    var filterData: FilterTrainerDataModel?
    var filterLstData:[FilterLstDataModel]? = []
   
    var genderLstData:[FilterLstDataModel]? = []
    var languageLstData:[FilterLstDataModel]? = []
    var nationalityLstData:[FilterLstDataModel]? = []
//    var timeSlotData:[FilterLstDataModel]? = []
    
    var localGenderLstData:[FilterLstDataModel]? = []
    var localLanguageLstData:[FilterLstDataModel]? = []
    var localNationalityLstData:[FilterLstDataModel]? = []
//    var localTimeSlotData:[FilterLstDataModel]? = []
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var trainerFilterPopupMBV: UIView!
    @IBOutlet weak var filterDataMBV: UIView!
    @IBOutlet weak var filterMenuMBV: UIView!
    @IBOutlet weak var filterLstMBV: UIView!
    @IBOutlet weak var dividerLineV: UIView!
    @IBOutlet weak var topLineV: UIView!
    @IBOutlet weak var filterTitleLbl: UILabel!
    
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    
    @IBOutlet weak var filterMenuTblView: UITableView!
    @IBOutlet weak var filterLstTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFont()
        
        //-----------------*************
        filterMenuTblView.allowsMultipleSelection = false
        filterLstTblView.allowsMultipleSelection = false
        filterMenu = ["Nationality", "Gender", "Language"]
        self.filterMenuTblView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.filterDataApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let filterMenu = filterMenu {
            if let selectedStr = selectedMenuFilterStr?.uppercased(),
               let index = filterMenu.map({ $0.uppercased() }).firstIndex(of: selectedStr) {
                
                let indexPath = IndexPath(row: index, section: 0)
                self.selectedMenuIndexPath = indexPath
                filterMenuTblView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                filterMenuTblView.delegate?.tableView?(filterMenuTblView, didSelectRowAt: indexPath)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    enum filterBtnTag: Int {
    case help = 1201, resetFilter, applyFilter
    }
    
    @IBAction func filterCommonBtnActn(_ sender: UIButton) {
        switch sender.tag {
        case filterBtnTag.help.rawValue:
            print("Help filter btn clicked.")
            self.dismiss(animated: true)
            break
        case filterBtnTag.resetFilter.rawValue:
            print("resetFilter btn clicked.")
            if let selectedMenuIndexPath = selectedMenuIndexPath {
                if selectedMenuIndexPath.row == 0 { // Nationality
                    self.nationalityLstData?.removeAll()
                    self.localNationalityLstData?.removeAll()
                    self.sendNationalityStr?("", "", self.nationalityLstData ?? [])
                    
                    if let nationalitiesList = self.filterData?.languages {
                        let nationalltiesLst = nationalitiesList.map { nationalities in
                            var mutableNationality = nationalities
                            mutableNationality.isSelected = false
                            return mutableNationality
                        }
                        self.filterData?.nationalities = nationalltiesLst
                        self.filterLstData = nationalltiesLst
                    }
                    
                    self.filterLstTblView.reloadData()
                    
                } else if selectedMenuIndexPath.row == 1 { // Gender
                    self.genderLstData?.removeAll()
                    self.localGenderLstData?.removeAll()
                    self.sendGenderStr?("","", self.genderLstData ?? [])
                    
                    if let genderList = self.filterData?.gender {
                        let updatedGenderList = genderList.map { gender in
                            var mutableGender = gender
                            mutableGender.isSelected = false
                            return mutableGender
                        }
                        self.filterData?.gender = updatedGenderList
                        self.filterLstData = updatedGenderList
                    }
                    
                    self.filterLstTblView.reloadData()
                    
                    //                    self.filterLstData = self.filterData?.gender?.map { gender in
                    //                        var updatedGender = gender
                    //                        updatedGender.isSelected = false
                    //                        return updatedGender
                    //                    }
                    
                } else if selectedMenuIndexPath.row == 2 { // Language
                    self.languageLstData?.removeAll()
                    self.localLanguageLstData?.removeAll()
                    self.sendLanguageStr?("", "", self.languageLstData ?? [])
                    
                    if let languagesList = self.filterData?.languages {
                        let languageLst = languagesList.map { languages in
                            var mutableLanguages = languages
                            mutableLanguages.isSelected = false
                            return mutableLanguages
                        }
                        self.filterData?.languages = languageLst
                        self.filterLstData = languageLst
                    }
                    self.filterLstTblView.reloadData()
                }
                //                else  if selectedMenuIndexPath.row == 3 {
                ////                    self.timeSlotData?.removeAll()
                ////                    self.localTimeSlotData?.removeAll()
                ////                    self.sendTime_slotStr?("", "", self.timeSlotData ?? [])
                //
                //                    if let timeSlotsList = self.filterData?.time_slots {
                //                        let timeSlotsLst = timeSlotsList.map { timeSlots in
                //                            var mutableTimeSlots = timeSlots
                //                            mutableTimeSlots.isSelected = false
                //                            return mutableTimeSlots
                //                        }
                //                        self.filterData?.time_slots = timeSlotsLst
                //                        self.filterLstData = timeSlotsLst
                //                    }
                //
                //                    self.filterLstTblView.reloadData()
                //                }
            }
            
            break
            
        case filterBtnTag.applyFilter.rawValue:
            print("applyFilter btn clicked.")
            
            self.dismiss(animated: true, completion: {[weak self] in
                if let genderLstData = self?.genderLstData, genderLstData.count != 0 {
                    let idList = genderLstData.map { "\($0.id?.value ?? "")" }.joined(separator: ",")
                    let nameStr = genderLstData.map { "\($0.name ?? "")".lowercased() }.joined(separator: ",")
                    self?.sendGenderStr?(idList, nameStr, self?.genderLstData ?? [])
                }
                
                if let languageLstData = self?.languageLstData, languageLstData.count != 0  {
                    let idList = languageLstData.map { "\($0.id?.value ?? "")" }.joined(separator: ",")
                    let nameStr = languageLstData.map { "\($0.name ?? "")" }.joined(separator: ",")
                    self?.sendLanguageStr?(idList, nameStr, self?.languageLstData ?? [])
                }
                
                if let nationalityLstData = self?.nationalityLstData, nationalityLstData.count != 0  {
                    let idList = nationalityLstData.map { "\($0.id?.value ?? "")" }.joined(separator: ",")
                    let nameStr = nationalityLstData.map { "\($0.name ?? "")" }.joined(separator: ",")
                    self?.sendNationalityStr?(idList, nameStr, self?.nationalityLstData ?? [])
                }
                
//                if let timeSlotLstData = self?.timeSlotData {
//                    let idList = timeSlotLstData.map { "\($0.id?.value ?? "")" }.joined(separator: ",")
//                    let nameStr = timeSlotLstData.map { "\($0.name ?? "")" }.joined(separator: ",")
//                    self?.sendTime_slotStr?(idList, nameStr, self?.timeSlotData ?? [])
//                }
            })
            
            break
        default:
            print("None....")
            break
        }
    }
    
    private func setupUI() {
        DispatchQueue.main.async {
            self.trainerFilterPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.trainerFilterPopupMBV.applyShadow(fillColor: UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 0.25), shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.resetBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.applyBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setupFont() {
        filterMenuTblView.register(UINib(nibName: "TrainerFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerFilterTableViewCell")
        filterLstTblView.register(UINib(nibName: "TrainerFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerFilterTableViewCell")
        
        //--------------------------------
        filterTitleLbl.font = AppFont.medium.size(20, familyName: familyClashDisplay)
//        resetBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        applyBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.trainerFilterPopupMBV.frame.contains(location) {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("tap at popup view.")
            }
        }
    }
}

//MARK: -------------------UITABLEVIEW DELEGATE/DATASOURCE
extension TrainerFilterViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == filterMenuTblView {
            return filterMenu?.count ?? 0
        } else {
            return filterLstData?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == filterMenuTblView {
            let menuCell: TrainerFilterTableViewCell = filterMenuTblView.dequeueReusableCell(withIdentifier: "TrainerFilterTableViewCell", for: indexPath) as! TrainerFilterTableViewCell
            menuCell.backgroundColor = UIColor.clear
            menuCell.selectionBtn.isHidden = true
            menuCell.selectionBtn.setImage(nil, for: .normal)
            menuCell.titleLbl.text = filterMenu?[indexPath.row] as? String
            return menuCell
        } else {
            let filterCell: TrainerFilterTableViewCell = filterLstTblView.dequeueReusableCell(withIdentifier: "TrainerFilterTableViewCell", for: indexPath) as! TrainerFilterTableViewCell
            filterCell.selectionBtn.isHidden = false
            filterCell.selectionBtn.isUserInteractionEnabled = false
            filterCell.titleLbl.text = filterLstData?[indexPath.row].name ?? filterLstData?[indexPath.row].nationality
            
            if self.filterLstData?[indexPath.row].isSelected == true {
                filterCell.selectionBtn.setImage(UIImage(named: "ic_filter_tick"), for: .normal)
            }else{
                filterCell.selectionBtn.setImage(AppImages.filterUncheck, for: .normal)
            }
            
            return filterCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select: ", indexPath.row)
        if tableView == filterMenuTblView {
            // 🔥 remove gradient from all visible cells
            for cell in tableView.visibleCells {
                if let menuCell = cell as? TrainerFilterTableViewCell {
                    menuCell.cellMBV.removeGradient()
                    menuCell.removeLeftBorder(named: "left_border")
                    menuCell.titleLbl.textColor = UIColor.appWhite
                }
            }
            let selectedCell = tableView.cellForRow(at: indexPath) as? TrainerFilterTableViewCell
            guard let selectedCell = selectedCell else { return }
            
            selectedCell.cellMBV.addGradient(
                colors: [
                    UIColor(red: 224/255, green: 254/255, blue: 8/255, alpha: 0.2), // yellow glow
                    UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 0.1)   // dark
                ],
                locations: [0, 1],
                startPoint: CGPoint(x: 0, y: 0.5),
                endPoint: CGPoint(x: 1, y: 0.5),
                cornerRadius: 0
            )
            selectedCell.titleLbl.textColor = UIColor.white
            selectedCell.addLeftBorder(borderColor: UIColor(red: 224.0/255.0, green: 254.0/255.0, blue: 8.0/255.0, alpha: 1), cornerRadius: 1.0)
            self.selectedMenuIndexPath = indexPath
            guard let lstData = filterMenu?[indexPath.row] as? String else { return }
            self.selectedMenuFilterStr = lstData
            self.getAllData(item: lstData.localizedCapitalized)
        } else {
            print("filterLstTblView selected")
            selectedIndexPaths.append(indexPath)
            let filterCell = tableView.cellForRow(at: indexPath) as? TrainerFilterTableViewCell
            filterCell?.selectionBtn.setImage(UIImage(named: "ic_filter_tick"), for: .normal)
          
            if let cellSelected = self.filterLstData?[indexPath.row].isSelected {
                self.filterLstData?[indexPath.row].isSelected = !cellSelected
            } else {
                self.filterLstData?[indexPath.row].isSelected = true
            }
            self.filterLstTblView.reloadData()
            let str = filterLstData?[indexPath.row].name ?? filterLstData?[indexPath.row].nationality
            self.getSelectedFilter(selectedMenu: selectedMenuFilterStr ?? "", selectedFilter: str ?? "")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselect: ",indexPath.row)
        if tableView == filterMenuTblView {
            let deSelectedCell = tableView.cellForRow(at: indexPath) as? TrainerFilterTableViewCell
            deSelectedCell?.cellMBV.removeGradient()   // 🔥 THIS
            deSelectedCell?.removeLeftBorder(named: "left_border")
            deSelectedCell?.backgroundColor = UIColor.clear
            deSelectedCell?.titleLbl.textColor = UIColor.appWhite
            
            
            guard let lstData = filterMenu?[indexPath.row] as? String else { return }
            self.getAllData(item: lstData.localizedCapitalized)
            self.selectedMenuFilterStr = lstData
            
            
//            if let menuData = filterMenu?[indexPath.row] as? String , menuData.capitalized == "Gender".capitalized {
//                self.getAllData(item: menuData)
//                deSelectedCell?.backgroundColor = UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)
//                deSelectedCell?.titleLbl.textColor = UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 27.0/255.0, alpha: 0.8)
//               
//                deSelectedCell?.addLeftBorder(borderColor: UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 27.0/255.0, alpha: 0.9), cornerRadius: 3.0)
//            }
            
        } else {
            print("filterLstTblView selected")
            
            let filterCell = tableView.cellForRow(at: indexPath) as? TrainerFilterTableViewCell
            filterCell?.selectionBtn.setImage(AppImages.filterUncheck, for: .normal)
            
//            self.filterLstData?[indexPath.row].isSelected = false
//            self.filterLstTblView.reloadData()
            
            let str = filterLstData?[indexPath.row].name ?? filterLstData?[indexPath.row].nationality
            self.getSelectedFilter(selectedMenu: selectedMenuFilterStr ?? "", selectedFilter: str ?? "")
        }
    }
    
    private func getSelectedFilter(selectedMenu:String, selectedFilter:String){
        switch selectedMenu.capitalized {
        case "Gender".capitalized:
            print("Gender")
            if let genderLstDataLocal = localGenderLstData , genderLstDataLocal.count != 0 {
                for name in genderLstDataLocal {
                    if let index = filterLstData?.firstIndex(where: {$0.name == name.name}){
                        self.filterData?.gender?[index].isSelected = true
                        self.filterLstData?[index].isSelected = self.filterData?.gender?[index].isSelected
                    }
                }
                self.genderLstData = self.filterData?.gender?.filter({ $0.isSelected == true })
                self.localGenderLstData?.removeAll()
                self.filterLstTblView.reloadData()
                
            } else {
                if let index = filterLstData?.firstIndex(where: { $0.name?.capitalized == selectedFilter.capitalized }),
                   let filterGernder = filterLstData?[index] {
                    
                    if let existingIndex = genderLstData?.firstIndex(where: { $0.name?.capitalized == filterGernder.name?.capitalized }) {
                        // Already exists → remove it
                        self.filterData?.gender?[index].isSelected = false
                        genderLstData?.remove(at: existingIndex)
                    } else {
                        // Not exists → append it
                        self.filterData?.gender?[index].isSelected = true
//                        genderLstData?.append(filterGernder)
                        genderLstData = filterLstData?.filter({ $0.isSelected == true })
                    }
                }
            }
        
//            if let index = filterLstData?.firstIndex(where: { $0.name == selectedFilter }),
//               let filterGernder = filterLstData?[index] {
//                
//                if let existingIndex = genderLstData?.firstIndex(where: { $0.name == filterGernder.name }) {
//                    // Already exists → remove it
//                    self.filterData?.gender?[index].isSelected = false
//                    genderLstData?.remove(at: existingIndex)
//                } else {
//                    // Not exists → append it
//                    self.filterData?.gender?[index].isSelected = true
//                    genderLstData?.append(filterGernder)
//                }
//            }
            
        case "Time slot".capitalized:
            print("Time slot")
            
//            if let timeSlotLstDataLocal = localTimeSlotData , timeSlotLstDataLocal.count != 0 {
//                for name in timeSlotLstDataLocal {
//                    if let index = filterLstData?.firstIndex(where: {$0.name == name.name}){
//                        self.filterData?.time_slots?[index].isSelected = true
//                        self.filterLstData?[index].isSelected = self.filterData?.time_slots?[index].isSelected
//                    }
//                }
//                
//                self.timeSlotData = self.filterData?.time_slots?.filter({ $0.isSelected == true })
//                self.localTimeSlotData?.removeAll()
//                self.filterLstTblView.reloadData()
//                
//            }else{
//                if let index = filterLstData?.firstIndex(where: { $0.name?.capitalized == selectedFilter.capitalized }),
//                   let filterTimeSlot = filterLstData?[index] {
//                    
//                    if let existingIndex = timeSlotData?.firstIndex(where: { $0.name?.capitalized == filterTimeSlot.name?.capitalized }) {
//                        // Already exists → remove it
//                        self.filterData?.time_slots?[index].isSelected = false
//                        timeSlotData?.remove(at: existingIndex)
//                    } else {
//                        // Not exists → append it
//                        self.filterData?.time_slots?[index].isSelected = true
//                        timeSlotData = filterLstData?.filter({ $0.isSelected == true })
//                    }
//                }
//            }

        case "Language".capitalized:
            print("Language")
            
            if let langDataLocal = localLanguageLstData , langDataLocal.count != 0 {
                for name in langDataLocal {
                    if let index = filterLstData?.firstIndex(where: {$0.name == name.name}){
                        self.filterData?.languages?[index].isSelected = true
                        self.filterLstData?[index].isSelected = self.filterData?.languages?[index].isSelected
                    }
                }
                
                self.languageLstData = self.filterData?.languages?.filter({ $0.isSelected == true })
                self.localLanguageLstData?.removeAll()
                self.filterLstTblView.reloadData()
                
            }else{
                if let index = filterLstData?.firstIndex(where: { $0.name == selectedFilter }),
                   let filterGernder = filterLstData?[index] {

                    if let existingIndex = languageLstData?.firstIndex(where: { $0.name == filterGernder.name }) {
                        // Already exists → remove it
                        self.filterData?.languages?[index].isSelected = false
                        languageLstData?.remove(at: existingIndex)
                    } else {
                        // Not exists → append it
                        self.filterData?.languages?[index].isSelected = true
                        languageLstData = filterLstData?.filter({ $0.isSelected == true })
                    }
                }
            }
            
            
            /*
            if let index = filterLstData?.firstIndex(where: { $0.name == selectedFilter }),
               let filterGernder = filterLstData?[index] {

                if let existingIndex = languageLstData?.firstIndex(where: { $0.name == filterGernder.name }) {
                    // Already exists → remove it
                    self.filterData?.languages?[index].isSelected = false
                    languageLstData?.remove(at: existingIndex)
                } else {
                    // Not exists → append it
                    self.filterData?.languages?[index].isSelected = true
                    languageLstData?.append(filterGernder)
                }
            }
            */
     
        case "Nationality".capitalized:
            print("Nationality")
            
            if let nationalityDataLocal = localNationalityLstData , nationalityDataLocal.count != 0 {
                for name in nationalityDataLocal {
                    if let index = filterLstData?.firstIndex(where: {$0.name == name.name}){
                        self.filterData?.nationalities?[index].isSelected = true
                        self.filterLstData?[index].isSelected = self.filterData?.nationalities?[index].isSelected
                    }
                }
                
                self.nationalityLstData = self.filterData?.nationalities?.filter({ $0.isSelected == true })
                self.localNationalityLstData?.removeAll()
                self.filterLstTblView.reloadData()
                
            }else{
                if let index = filterLstData?.firstIndex(where: { $0.nationality == selectedFilter || $0.name == selectedFilter}),
                   let filterNationality = filterLstData?[index] {
                    if let existingIndex = nationalityLstData?.firstIndex(where: { $0.nationality == filterNationality.nationality || $0.name == filterNationality.name }) {
                        // Already exists → remove it
                        self.filterData?.nationalities?[index].isSelected = false
                        nationalityLstData?.remove(at: existingIndex)
                    } else {
                        // Not exists → append it
                        self.filterData?.nationalities?[index].isSelected = true
                        nationalityLstData = filterLstData?.filter({ $0.isSelected == true })
                    }
                }
            }
            
            /*
            if let index = filterLstData?.firstIndex(where: { $0.nationality == selectedFilter || $0.name == selectedFilter}),
               let filterNationality = filterLstData?[index] {
                if let existingIndex = nationalityLstData?.firstIndex(where: { $0.nationality == filterNationality.nationality || $0.name == filterNationality.name }) {
                    // Already exists → remove it
                    self.filterData?.nationalities?[index].isSelected = false
                    nationalityLstData?.remove(at: existingIndex)
                } else {
                    // Not exists → append it
                    self.filterData?.nationalities?[index].isSelected = true
                    nationalityLstData?.append(filterNationality)
                }
            }
            */
            
        default:
            print("Non")
        }
    }
    
    private func getAllData(item: String) {
        switch item.capitalized {
        case "Gender".capitalized:
            print("Gender")
            self.filterLstData?.removeAll()
            self.filterLstData?.append(contentsOf: self.filterData?.gender ?? [])
//            self.filterLstTblView.reloadData()
            
            if let genderData = localGenderLstData, genderData.count != 0 || !genderData.isEmpty {
                self.getSelectedFilter(selectedMenu: item , selectedFilter: "male")
            }
            
            self.filterLstTblView.reloadData()
                        
        case "Time slot".capitalized:
            print("Time slot")
            
//            self.filterLstData?.removeAll()
//            self.filterLstData?.append(contentsOf: self.filterData?.time_slots ?? [])
//            if let timeSlotData = localTimeSlotData, timeSlotData.count != 0 || !timeSlotData.isEmpty {
//                self.getSelectedFilter(selectedMenu: item , selectedFilter: "Time slot")
//            }
//            
//            self.filterLstTblView.reloadData()

        case "Language".capitalized:
            print("Language")
            
            self.filterLstData?.removeAll()
            self.filterLstData?.append(contentsOf: self.filterData?.languages ?? [])
//            self.filterLstTblView.reloadData()
            
            if let langData = localLanguageLstData, langData.count != 0 || !langData.isEmpty {
                self.getSelectedFilter(selectedMenu: item , selectedFilter: "english")
            }else{
                self.filterLstTblView.reloadData()
            }
            
        case "Nationality".capitalized:
            
            self.filterLstData?.removeAll()
            self.filterLstData?.append(contentsOf: self.filterData?.nationalities ?? [])
//            self.filterLstTblView.reloadData()
            
            if let nationalityData = localNationalityLstData, nationalityData.count != 0 || !nationalityData.isEmpty {
                self.getSelectedFilter(selectedMenu: item , selectedFilter: "Dubai")
            }
            
            self.filterLstTblView.reloadData()
            
        default:
            print("None")
        }
    }
}

//MARK: ------------------- API
extension TrainerFilterViewController{
    private func filterDataApi(){
        TrainerVM.trainerFilterApi(inputParams: nil, isShowLoader: false, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            if getResultData.status == true {
                self.filterData = getResultData.data

                if let _ = self.filterData {
                    self.getAllData(item: selectedMenuFilterStr ?? "")
                }
            }
        })
    }
}

extension UIView {
    func removeGradient() {
        self.layer.sublayers?
            .filter { $0.name == "addGradient" }
            .forEach { $0.removeFromSuperlayer() }
    }
}
