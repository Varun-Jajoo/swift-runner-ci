//
//  SearchViewController.swift
//  MyPT
//
//  Created by techsaga corp on 11/03/25.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: ---------------VARIABLE
    var inputType:String?
    var inputLat:String?
    var inputLong:String?
    var gymStudioFlow: calendarFlow = .defaultFlow
    var searchStr: String?
    var searchStudiosData:[TrainerModel]? = []
    var seacrhGymTrainerData:[GymTrainerModel]? = []
    private var localSearchStudiosData:[TrainerModel]? = []
    private var localhGymTrainerData:[GymTrainerModel]? = []
    private var suggestedWorkoutTags: [String]? = ["WEIGHT LOSS", "YOGA", "PILATES", "HEAVY-LIFTING", "CROSS-FIT", "WEIGHT GAIN", "ZUMBA"]
    var isFromHome: Bool? = true
    var inputParam: DetailsParam?
    
    // MARK: ----------------IBOUTLET
    @IBOutlet weak var topSearchMBV: UIView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var recordTblView: UITableView!
    @IBOutlet weak var shortcutCollView: UICollectionView!
    @IBOutlet weak var recentSearchLbl: UILabel!
    @IBOutlet weak var quickShortcutsLbl: UILabel!
    @IBOutlet weak var tfSearch: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.localSearchStudiosData = self.searchStudiosData
        self.localhGymTrainerData = self.seacrhGymTrainerData
        self.setupUI()
//        self.setUISearchbar()
        setupTextFieldSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: ---------------- Searchbar Customize
    func setupTextFieldSearch() {
        topSearchMBV.setCornerRadius(
            borderWidth: 1,
            borderColor: UIColor.white.withAlphaComponent(0.1),
            cornerRadious: 12
        )
        
        tfSearch.delegate = self
        tfSearch.backgroundColor = .clear
        tfSearch.textColor = .white
        tfSearch.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        
        tfSearch.attributedPlaceholder = NSAttributedString(
            string: inputType != "" ? " Search for your building, street name..." : " Search for area, street name...",
            attributes: [.foregroundColor: UIColor.txtDarkGray]
        )
        tfSearch.setMultiColorPlaceholder(firstStr: "Search for", firstColor: UIColor.txtDarkGray, firstfont: AppFont.semibold.size(14.0, familyName: familyFunnelSans), secondStr: "Weight loss Trainers", secondColor: UIColor.appWhite, secondfont: AppFont.semibold.size(14.0, familyName: familyFunnelSans))
        tfSearch.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        tfSearch.clearButtonMode = .never
        tfSearch.returnKeyType = .search
    }
    
    @objc func textDidChange() {
        searchTrainers()
    }
    
    func searchTrainers() {
        let searchText = tfSearch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if searchText.isEmpty {
            // 🔹 Search empty → original data
            if isFromHome ?? false {
                self.searchStudiosData = self.localSearchStudiosData
            } else {
                self.seacrhGymTrainerData = self.localhGymTrainerData
            }
        } else {
            // 🔹 Search text present → filter by name
            if isFromHome ?? false {
                self.searchStudiosData = self.localSearchStudiosData?.filter {
                    homeTrainerMatchesSearch(trainer: $0, searchText: searchText)
                }
            } else {
                self.seacrhGymTrainerData = self.localhGymTrainerData?.filter {
                    gymTrainerMatchesSearch(trainer: $0, searchText: searchText)
                }
            }
            DispatchQueue.main.async {
                self.quickShortcutsLbl.isHidden = !searchText.isEmpty
                self.shortcutCollView.isHidden = !searchText.isEmpty
                self.recentSearchLbl.text = !searchText.isEmpty ? "Search results" : "Top trainers curated for you"
            }
        }
        recordTblView.reloadData()
    }
    
    func homeTrainerMatchesSearch(trainer: TrainerModel, searchText: String) -> Bool {

        let text = searchText.lowercased()

        // 1️⃣ Name match
        if (trainer.name ?? "").lowercased().contains(text) {
            return true
        }

        // 2️⃣ Tags match
        if let tags = trainer.tags {
            if tags.contains(where: { ($0.name ?? "").lowercased().contains(text) }) {
                return true
            }
        }
        return false
    }
    
    func gymTrainerMatchesSearch(trainer: GymTrainerModel, searchText: String) -> Bool {

        let text = searchText.lowercased()

        // 1️⃣ Name match
        if (trainer.name ?? "").lowercased().contains(text) {
            return true
        }

        // 2️⃣ Tags match
        if let tags = trainer.tags {
            if tags.contains(where: { ($0.name ?? "").lowercased().contains(text) }) {
                return true
            }
        }
        return false
    }

    
    @IBAction func leftBtnActn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        DispatchQueue.main.async {
            self.topSearchMBV.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.txtDarkGray, cornerRadious: 12.0)
        }
        shortcutCollView.delegate = self
        shortcutCollView.dataSource = self
        shortcutCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        recordTblView.delegate = self
        recordTblView.dataSource = self
        recordTblView.register(UINib(nibName: "SearchTrainerTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTrainerTableViewCell")
    }

    @objc func viewProfileBtnActn(sender:UIButton) {
        if let isFromHome = isFromHome, isFromHome {
            let vc: TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
            let getIndx = self.searchStudiosData?.firstIndex(where: {
                $0.id == Int(sender.accessibilityHint ?? "0")
            })
            var inputData = inputParam
            if let data = searchStudiosData {
                inputData?.trainer_id = "\(data[getIndx ?? 0].id ?? 0)"
            }
            vc.inputParam = inputData
            //                vc.isSlotsAvail = self.trainerData?[indexPath.row].isfull
            
            //            if let isFull = self.trainerData?[indexPath.row].isfull, let slotAvail = self.trainerData?[indexPath.row].slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
            //                vc.isSlotsAvail = true
            //            }else{
            //                vc.isSlotsAvail = false
            //            }
            //
            //            vc.detailsFlowSetup = flowSlot
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc: TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
            let getIndx = self.seacrhGymTrainerData?.firstIndex(where: {
                $0.id == Int(sender.accessibilityHint ?? "0")
            })
            var inputData = inputParam
            inputData?.trainer_id = "\(self.seacrhGymTrainerData?[getIndx ?? 0].id ?? 0)"
            vc.inputParam = inputData
//            vc.inputParam = DetailsParam(
//                //                trainer_id: "\(self.gymTrainerData?[indexPath.row].id ?? 0)",
//                //                studio_id: "\(self.gymTrainerData?[indexPath.row].studioID ?? "")",
//                type: self.inputType,
//                long: self.inputLong,
//                lat: self.inputLat
//            )
            //                vc.isSlotsAvail = self.gymTrainerData?[indexPath.row].isfull
            //
            //            if let isFull = self.gymTrainerData?[indexPath.row].isfull, let slotAvail = self.gymTrainerData?[indexPath.row].slot, isFull && slotAvail.lowercased() == "no".lowercased() {
            //                vc.isSlotsAvail = true
            //            }else{
            //                vc.isSlotsAvail = false
            //            }
            //
            //            vc.detailsFlowSetup = flowSlot //.bookTrainerGymWorkout
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: ---------------UITABLEVIEW DATASOURCE/ DELEGATE
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = isFromHome ?? false
        ? self.searchStudiosData?.count ?? 0 >= 3 ? 3 : self.searchStudiosData?.count ?? 0
        : self.seacrhGymTrainerData?.count ?? 0 >= 3 ? 3 : self.seacrhGymTrainerData?.count ?? 0
        return tableView.numberOfRows(count: count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTrainerTableViewCell", for: indexPath) as? SearchTrainerTableViewCell
        cell?.viewBackgrnd.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12)
        if isFromHome ?? false {
            if let data = searchStudiosData?[indexPath.row] {
                cell?.setHomeTraineData(data: data)
                cell?.viewProfileBtn.tag = data.id ?? 0
            }
        } else {
            if let data = seacrhGymTrainerData?[indexPath.row] {
                cell?.setGymTrainerData(data: data)
                cell?.viewProfileBtn.tag = data.id ?? 0
            }
        }
        // remove old targets (VERY IMPORTANT)
        cell?.viewProfileBtn.removeTarget(nil, action: nil, for: .allEvents)
        cell?.viewProfileBtn.addTarget(self, action: #selector(viewProfileBtnActn(sender:)), for: .touchUpInside)
        return cell ?? UITableViewCell()
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let isFromHome = isFromHome, isFromHome {
            let vc: TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
//            let getIndx = self.searchStudiosData?.firstIndex(where: {
//                $0.id == Int(sender.accessibilityHint ?? "0")
//            })
            var inputData = inputParam
            if let data = searchStudiosData {
                inputData?.trainer_id = "\(searchStudiosData?[indexPath.row].id ?? 0)"
            }
            vc.inputParam = inputData
            //                vc.isSlotsAvail = self.trainerData?[indexPath.row].isfull
            
            //            if let isFull = self.trainerData?[indexPath.row].isfull, let slotAvail = self.trainerData?[indexPath.row].slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
            //                vc.isSlotsAvail = true
            //            }else{
            //                vc.isSlotsAvail = false
            //            }
            //
            //            vc.detailsFlowSetup = flowSlot
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc: TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
//            let getIndx = self.seacrhGymTrainerData?.firstIndex(where: {
//                $0.id == Int(sender.accessibilityHint ?? "0")
//            })
            var inputData = inputParam
            inputData?.trainer_id = "\(self.seacrhGymTrainerData?[indexPath.row].id ?? 0)"
            vc.inputParam = inputData
//            vc.inputParam = DetailsParam(
//                //                trainer_id: "\(self.gymTrainerData?[indexPath.row].id ?? 0)",
//                //                studio_id: "\(self.gymTrainerData?[indexPath.row].studioID ?? "")",
//                type: self.inputType,
//                long: self.inputLong,
//                lat: self.inputLat
//            )
            //                vc.isSlotsAvail = self.gymTrainerData?[indexPath.row].isfull
            //
            //            if let isFull = self.gymTrainerData?[indexPath.row].isfull, let slotAvail = self.gymTrainerData?[indexPath.row].slot, isFull && slotAvail.lowercased() == "no".lowercased() {
            //                vc.isSlotsAvail = true
            //            }else{
            //                vc.isSlotsAvail = false
            //            }
            //
            //            vc.detailsFlowSetup = flowSlot //.bookTrainerGymWorkout
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 133
    }
}

//MARK: ---------------UICOLLECTIONVIEW DATASOURCE/ DELEGATE

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestedWorkoutTags?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductCategoryCollViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        cell.titleLbl.text = suggestedWorkoutTags?[indexPath.row].uppercased()
        DispatchQueue.main.async {
//                categoryCell.cellMBV.backgroundColor = .clear
            cell.shouldHandleSelection = false
            cell.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.1), cornerRadious: 8)
            cell.titleLblTopConstrnt.constant = 4
            cell.titleLblLeading.constant = 8
            cell.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            cell.titleLbl.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = suggestedWorkoutTags?[indexPath.row]
        let font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)

        let textWidth = text?.size(withAttributes: [.font: font]).width

        let horizontalPadding: CGFloat = 20   // 8 + 8
        let height: CGFloat = 24            // safe chip height

        return CGSize(
            width: ceil((textWidth ?? 20) + horizontalPadding),
            height: height
        )
    }
}

extension SearchViewController: UITextFieldDelegate {
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        searchTrainers()
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
