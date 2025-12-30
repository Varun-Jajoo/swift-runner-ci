//
//  TrainerListViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import UIKit

class TrainerListViewController: CommonViewController {

    //MARK: --------------VARIBALE
    var istagMenuHeight: Bool?
    var isLoadFirst: Bool? = nil
    
    private lazy var searchContainerView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.mainBg
        container.layer.cornerRadius = 8
        container.layer.masksToBounds = true
        container.setCornerRadius(borderWidth: 1, borderColor: UIColor.appCard, cornerRadious: 12.0)

        let searchBar = UISearchBar()
        searchBar.tag = 101
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage() // Removes border
        searchBar.isTranslucent = false
        searchBar.backgroundColor = .clear
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.mainBg
        searchBar.backgroundColor = UIColor.mainBg
        searchBar.barTintColor = UIColor.mainBg
        searchBar.tintColor = UIColor.appWhite
        searchBar.searchTextField.backgroundColor = UIColor.mainBg
        searchBar.searchTextField.textColor = UIColor.appWhite
        searchBar.isTranslucent = false
        searchBar.placeholder = ""
        searchBar.searchTextField.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        searchBar.showsCancelButton = false
        searchBar.searchTextField.rightView = nil
        searchBar.searchTextField.rightViewMode = .never
        searchBar.setBackgroundImage(UIImage.init(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        searchBar.backgroundImage = UIImage()
        searchBar.addDoneButtonOnKeyboard()
            
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            //            textField.clearButtonMode = .never
            textField.leftView = nil
            textField.rightView = nil
            textField.rightViewMode = .never
            textField.translatesAutoresizingMaskIntoConstraints = false
            // Optional: Customize appearance
            textField.borderStyle = .none
            textField.layer.cornerRadius = 8
            textField.backgroundColor = UIColor.mainBg
            
            // Add constraints to fill the search bar
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 0),
                textField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 2),
                textField.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 0),
                textField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0)
            ])
        }

        let clearButton = UIButton()
        clearButton.setImage(UIImage(named: "ic_cross"), for: .normal)
        clearButton.tintColor = UIColor.mainBg
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.backgroundColor = UIColor.clear
        clearButton.addTarget(self, action: #selector(clearSearch), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [searchBar, clearButton])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20)
        ])

        return container
    }()

//----------------****** Trainer filgter local
    var localGenderLstData:[FilterLstDataModel]? = []
    var localLanguageLstData:[FilterLstDataModel]? = []
    var localNationalityLstData:[FilterLstDataModel]? = []
    var localTimeSlotData:[FilterLstDataModel]? = []
    
    var isFromHome:Bool?
    var categorySelectedIndex:IndexPath?
    var flowSlot:calendarFlow = .defaultFlow
    var inputType:String?
    var inputIs_filter:String?
    var inputLat:String?
    var inputLong:String?
    var studioId:String?
    
    var tagData:[TagModel]? = []
    var trainerData:[TrainerModel]? = []
    var gymTrainerData:[GymTrainerModel]? = []
    var trainerDataLocal: [TrainerModel]? = []
    var gymTrainerDataLocal: [GymTrainerModel]? = []
    var filterMenu: [String]?
    
    var isGridShow:Bool?
    private var genderFilterStr : String?
    private var languageFilterStr : String?
    private var nationalityFilterStr : String?
    private var time_slotFilterStr : String?
    private var is_filterStr : String?
    private var inpuntTagId: Int?
    
    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var searchMBVTopConstrnt: NSLayoutConstraint!
    @IBOutlet weak var searchMBVLeading: NSLayoutConstraint!
    @IBOutlet weak var searchMBVTrailing: NSLayoutConstraint!
    @IBOutlet weak var workoutCategoryCollView: UICollectionView!
    @IBOutlet weak var filterMenuCollView: UICollectionView!
    @IBOutlet weak var trainerListTblView: UITableView!
    @IBOutlet weak var trainerGridCollView: UICollectionView!
    @IBOutlet weak var tblMBV: UIView!
    @IBOutlet weak var collMBV: UIView!
    
//    @IBOutlet weak var workoutCategoryCollViewHeightConstrnt: NSLayoutConstraint!
//    
//    @IBOutlet weak var filterMenuCollViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isLoadFirst = true
        self.categorySelectedIndex = IndexPath(row: 0, section: 0)
        self.setupUI()
        self.flowTrainers()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.istagMenuHeight = true
        
//        if let tagData = tagData?.count, tagData > 0 {
//            // Automatically select the first cell
//            let firstIndexPath = IndexPath(item: 0, section: 0)
//            DispatchQueue.main.async {
//                self.workoutCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
//                // Optional: perform any additional setup for the selected cell
//                self.workoutCategoryCollView.delegate?.collectionView?(self.workoutCategoryCollView, didSelectItemAt: firstIndexPath)
//                self.view.layoutIfNeeded()
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchContainerView.removeFromSuperview()
    }
    
    func setNavUI(){
        if let _ = isLoadFirst {
            isLoadFirst = nil
            self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.trainers], setTintColor: .black, setTitleColor: UIColor.appWhite)
            self.setRighMenu(rightImgs: [AppImages.grid?.resized(to: CGSize(width: 25.0, height: 25.0)), AppImages.menuNav?.resized(to: CGSize(width: 25.0, height: 25.0)),  AppImages.search_normal], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
        }
    }
    
    override func rightBtnActn(sender: UIButton) {
        if sender.tag != 2 {
            let grid: UIImage? = (sender.tag == 0 ? AppImages.selected_grid : AppImages.grid)
            let list: UIImage? = (sender.tag == 1 ? AppImages.menuNav : AppImages.unselectedList)
            
            self.setRighMenu(rightImgs: [grid?.resized(to: CGSize(width: 25.0, height: 25.0)), list?.resized(to: CGSize(width: 25.0, height: 25.0)), AppImages.search_normal], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
            
            if sender.tag == 0 {
                print("Gridlayout")
                self.isGridShow = true
                trainerGridCollView.reloadData()
                tblMBV.isHidden = true
                collMBV.isHidden = false
                
            }else if sender.tag == 1{
                print("show list view")
                self.isGridShow = false
                trainerListTblView.reloadData()
                tblMBV.isHidden = false
                collMBV.isHidden = true
                
            }else{
                print("cliecked at search...")
                
                /*
                 if let isFromHome = isFromHome, isFromHome {
                 let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
                 vc.searchStr = "Trainers"
                 vc.searchTrainerData = self.trainerData
                 vc.seacrhGymTrainerData = nil
                 self.navigationController?.pushViewController(vc, animated: true)
                 }else{
                 let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
                 vc.searchStr = "Trainers"
                 vc.searchTrainerData = nil
                 vc.seacrhGymTrainerData = self.gymTrainerData
                 self.navigationController?.pushViewController(vc, animated: true)
                 }
                 */
                
                //            let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
                //            vc.searchStr = "Trainers"
                //            vc.searchTrainerData = self.trainerData
                //            vc.seacrhGymTrainerData = self.gymTrainerData
                //            self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if sender.tag == 2{
            self.navSearchUI()
            
                        
            /*
            if let isFromHome = isFromHome, isFromHome {
            let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
            vc.searchStr = "Trainers"
            vc.searchTrainerData = self.trainerData
            vc.seacrhGymTrainerData = nil
            self.navigationController?.pushViewController(vc, animated: true)
            }else{
            let vc: SearchViewController = SearchViewController.instantiate(appStoryboard: .dashboard)
            vc.searchStr = "Trainers"
            vc.searchTrainerData = nil
            vc.seacrhGymTrainerData = self.gymTrainerData
            self.navigationController?.pushViewController(vc, animated: true)
            }
            
            */
        }
    }
    
    private func flowTrainers(){
        switch flowSlot {
        case .bookTrainerHomeWorkout, .bookTrainerGymWorkout, .createPackage:
            
            if let isFromHome = isFromHome, isFromHome {
                self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
            }else{
                self.getSelectGymList(inputFilter: "0", inpuntTagId: 0)
            }
            
        case .gymMembership, .withTrainerMembership, .withoutTrainerMembership:
            self.getSelectGymList(inputFilter: "0", inpuntTagId: 0)
            
        case .defaultFlow:
            print("Book trainer flow...")
//            if let isFromHome = isFromHome, isFromHome {
//                self.getTrainerApi(inputFilter: "0", inpuntTagId: 0)
//            }else{
//                self.getSelectGymList(inputFilter: "0", inpuntTagId: 0)
//            }
        }
    }
    
    
    @objc func clearSearch(sender: UIButton){
        print("lcear search bar")
        self.removeSearch()
//        self.searchContainerView.applyTransition(type: .moveIn, subtype: .fromLeft, duration: 0.5, timingFunction: .easeInEaseOut, completion: {[weak self] in
//            
//            self?.searchContainerView.removeFromSuperview()
//        })
    }
    
    private func removeSearch(){
        self.searchContainerView.applyTransition(type: .moveIn, subtype: .fromLeft, duration: 0.5, timingFunction: .easeInEaseOut, completion: {[weak self] in
            
            self?.searchContainerView.removeFromSuperview()
        })
    }
    
    
    private func setupUI(){
        self.filterMenu = ["Time slot", "Gender", "Language", "Nationality"]
        
        workoutCategoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        
        trainerGridCollView.register(UINib(nibName: "GridTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridTrainerCollectionViewCell")
        
        trainerListTblView.register(UINib(nibName: "TrainerListTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerListTableViewCell")
        
        self.filterMenuCollView.register(UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
        
        tblMBV.isHidden = false
        collMBV.isHidden = true
        trainerListTblView.reloadData()
    }
    
    private func navSearchUI(){
        guard let navBar = self.navigationController?.navigationBar else { return }
        
        //        animShowFromRightToLeft(duration: 0.7)
        searchContainerView.alpha = 0
        searchContainerView.isHidden = true
        navBar.addSubview(searchContainerView)
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Positioning vertically inside navbar
        NSLayoutConstraint.activate([
            searchContainerView.topAnchor.constraint(equalTo: navBar.topAnchor, constant: 0),
            searchContainerView.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 0),
        ])
        
        // Leading (after left buttons)
        if let leftLastButton = self.leftNavButtons.last,
           let leftFrame = leftLastButton.superview?.convert(leftLastButton.frame, to: self.view) {
            let trailingLeft = leftFrame.maxX
            self.searchContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: trailingLeft + 8).isActive = true
        } else {
            self.searchContainerView.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 16).isActive = true
        }
        
        // Trailing (before right buttons)
        if let rightLastButton = self.rightNavButtons.last,
           let rightFrame = rightLastButton.superview?.convert(rightLastButton.frame, to: self.view) {
            //                let leadingRight = rightFrame.minX
            let leadingRight = rightFrame.maxX
            self.searchContainerView.trailingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: leadingRight).isActive = true
        } else {
            self.searchContainerView.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16).isActive = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animShowFromRightToLeft(duration: 0.7) {
                let trainerSearchbar = self.searchContainerView.viewWithTag(101) as? UISearchBar
                if let textField = trainerSearchbar?.value(forKey: "searchField") as? UITextField {
                    textField.becomeFirstResponder()
                }
            }
//            self.animShowFromRightToLeft(duration: 0.7)
        }
    }
        
    func animShowFromRightToLeft(duration: TimeInterval = 1, completion: (() -> Void)? = nil) {
        let container = self.searchContainerView
        self.view.layoutIfNeeded()
        let finalFrame = container.frame
        
        // Start with width = 0, origin.x = right edge (finalFrame.maxX)
        container.frame = CGRect(
            x: finalFrame.maxX,
            y: finalFrame.origin.y,
            width: 0,
            height: finalFrame.height
        )
        container.alpha = 1
        container.isHidden = false
        self.searchContainerView.isHidden = false
//        DispatchQueue.main.async {
            UIView.animate(withDuration: duration, animations: {
                container.frame = finalFrame
//                self.searchContainerView.isHidden = false
            }, completion: { _ in
                completion?()
            })
//        }
    }

//    private func firstCellSelect(getCount: Int?){
//        if let tagData = getCount, tagData > 0 {
//            let firstIndexPath = IndexPath(item: 0, section: 0)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.workoutCategoryCollView.selectItem(at: firstIndexPath, animated: true, scrollPosition: .top)
//                self.workoutCategoryCollView.delegate?.collectionView?(self.workoutCategoryCollView, didSelectItemAt: firstIndexPath)
//                self.view.layoutIfNeeded()
//            }
//        }
//    }
    
}

//MARK: --------------UICOLLECTIONVIEW DELEGATE/DATASOURCE
extension TrainerListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == trainerGridCollView {
            if let isFromHome = isFromHome, isFromHome {
                return collectionView.numberOfRows(count: self.trainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
            }else{
                return collectionView.numberOfRows(count: self.gymTrainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
            }
            
        }else if collectionView == filterMenuCollView{
            return self.filterMenu?.count ?? 0
        }
        
        else{
            return tagData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == trainerGridCollView {
            let cell:GridTrainerCollectionViewCell = trainerGridCollView.dequeueReusableCell(withReuseIdentifier: "GridTrainerCollectionViewCell", for: indexPath) as! GridTrainerCollectionViewCell
            
            cell.landMarkBtn.titleLabel?.numberOfLines = 1
            cell.distanceBtn.titleLabel?.numberOfLines = 1
            cell.landMarkBtn.titleLabel?.lineBreakMode = .byClipping
            cell.distanceBtn.titleLabel?.lineBreakMode = .byClipping
            
            if let isFromHome = isFromHome, isFromHome {
                cell.trainerTagsData = self.trainerData?[indexPath.row].tags
                cell.setupCellData(trainerData: self.trainerData?[indexPath.row])
                
            }else{
                cell.trainerTagsData = self.gymTrainerData?[indexPath.row].tags
                cell.setGymCellData(trainerData: self.gymTrainerData?[indexPath.row])
            }
         
            return cell
        }else if collectionView == filterMenuCollView{
            let filterMenuCell: FilterCategoryCollectionViewCell = filterMenuCollView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCollectionViewCell", for: indexPath) as! FilterCategoryCollectionViewCell
            
            DispatchQueue.main.async {
                filterMenuCell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.15), cornerRadious: 8.0)
            }
            filterMenuCell.gymCategoryNameLbl.font = AppFont.semibold.size(11.0, familyName: familyManrope)
            filterMenuCell.gymCategoryImgView.isHidden = true
            filterMenuCell.gymCategoryImgWidthConstrnt.constant = 0
            filterMenuCell.selectionImgView.isHidden = false
            filterMenuCell.selectionImgViewWidthConstrnt.constant = 15
            filterMenuCell.selectionImgViewTrainlingConstrnt.constant = 8
            filterMenuCell.titleTopConstrnt.constant = 8.0
            filterMenuCell.titleBottomConstrnt.constant = 8.0
            
            filterMenuCell.selectionImgView.image = UIImage(named: "ic_downArrow")
            filterMenuCell.gymCategoryNameLbl.text = self.filterMenu?[indexPath.row] as? String
            filterMenuCell.gymCategoryNameLbl.textAlignment = .center
            
            return filterMenuCell
        }
        else{
            let cell:WorkoutCategoryCollectionViewCell = workoutCategoryCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            
            DispatchQueue.main.async {
                if self.categorySelectedIndex?.row == indexPath.row {
                    cell.cellMBV.backgroundColor = UIColor.clear
                    cell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: cell.cellMBV.frame.size.height/2.0)//12.0
                }else{
                    cell.cellMBV.backgroundColor = UIColor.clear
                    cell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: cell.cellMBV.frame.size.height/2.0)
                }
            }
            
            cell.categoryImgView.loadImage(urlString: self.tagData?[indexPath.row].image as? String, placeholder: UIImage(named: "ic_barbell_ diagonal"))
            cell.categoryTitleLbl.text = self.tagData?[indexPath.row].name as? String
        
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == trainerGridCollView {
            
            switch flowSlot {
            case .bookTrainerHomeWorkout, .bookTrainerGymWorkout, .createPackage:
              
                //----------------From book trainer
                if let isFromHome = isFromHome, isFromHome {
                    
                    let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
//                    vc.inputParam = DetailsParam(trainer_id: "\(self.trainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.trainerData?[indexPath.row].id ?? 0)", type: self.inputType, long: self.inputLat, lat: self.inputLong)
                    
                    vc.inputParam = DetailsParam(trainer_id: "\(self.trainerData?[indexPath.row].id ?? 0)", studio_id: "", type: self.inputType, long: self.inputLong, lat: self.inputLat)
                    vc.detailsFlowSetup = flowSlot //.bookTrainerHomeWorkout
//                    vc.isSlotsAvail = self.trainerData?[indexPath.row].isfull
                    
                    if let isFull = self.trainerData?[indexPath.row].isfull, let slotAvail = self.trainerData?[indexPath.row].slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
                        vc.isSlotsAvail = true
                    }else{
                        vc.isSlotsAvail = false
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else{
                    
                    let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
                    
                    vc.inputParam = DetailsParam(trainer_id: "\(self.gymTrainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.gymTrainerData?[indexPath.row].studioID ?? "0")", type: self.inputType, long: self.inputLong, lat: self.inputLat )
                    vc.detailsFlowSetup = flowSlot //.bookTrainerGymWorkout
//                    vc.isSlotsAvail = self.gymTrainerData?[indexPath.row].isfull
                    
                    if let isFull = self.gymTrainerData?[indexPath.row].isfull, let slotAvail = self.gymTrainerData?[indexPath.row].slot, isFull && slotAvail.lowercased() == "no".lowercased() {
                        vc.isSlotsAvail = true
                    }else{
                        vc.isSlotsAvail = false
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                
            case .gymMembership, .withTrainerMembership, .withoutTrainerMembership:
                //----------------
                let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
                vc.detailsFlowSetup = flowSlot //.gymMembership
                vc.inputParam = DetailsParam(trainer_id: "\(self.gymTrainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.gymTrainerData?[indexPath.row].studioID ?? "")", type: self.inputType, long: self.inputLong, lat: self.inputLat)
//                vc.isSlotsAvail = self.gymTrainerData?[indexPath.row].isfull
                
                if let isFull = self.gymTrainerData?[indexPath.row].isfull, let slotAvail = self.gymTrainerData?[indexPath.row].slot, isFull && slotAvail.lowercased() == "no".lowercased() {
                    vc.isSlotsAvail = true
                }else{
                    vc.isSlotsAvail = false
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .defaultFlow:
                print("default .......")
                break
            }
            
            
        }else if collectionView == workoutCategoryCollView{
            
//            if let isFromHome = isFromHome, isFromHome {
//                if indexPath.row > 0 {
//                    self.inpuntTagId = self.tagData?[indexPath.row].id
//                    self.getTrainerApi(inputFilter: "1", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
//                }else{
//                    self.inpuntTagId = self.tagData?[indexPath.row].id
//                    self.getTrainerApi(inputFilter: "0", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
//                }
//            }else{
//                if indexPath.row > 0 {
//                    self.inpuntTagId = self.tagData?[indexPath.row].id
//                    self.getSelectGymList(inputFilter: "1", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
//                }else{
//                    self.inpuntTagId = self.tagData?[indexPath.row].id
//                    self.getSelectGymList(inputFilter: "0", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
//                }
//            }
            
            if let is_filterStr = self.is_filterStr , is_filterStr == "1" {
                if let isFromHome = isFromHome, isFromHome {
                    if indexPath.row > 0 {
                        self.inpuntTagId = self.tagData?[indexPath.row].id
                        self.getFilterTrainerApi(inpuntTagId: self.inpuntTagId)
                    }else{
                        self.inpuntTagId = self.tagData?[indexPath.row].id
                        self.getFilterTrainerApi(inpuntTagId: self.inpuntTagId)
                    }
                }else{
                    if indexPath.row > 0 {
                        self.inpuntTagId = self.tagData?[indexPath.row].id
                        self.getFilterSelectGymList(inpuntTagId: self.inpuntTagId)
                       
                        //                                    self.getSelectGymList(inputFilter: "1", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                        
                    }else{
                        self.inpuntTagId = self.tagData?[indexPath.row].id
                        self.getFilterSelectGymList(inpuntTagId: self.inpuntTagId)
                        
                        //                                    self.getSelectGymList(inputFilter: "0", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                    }
                }
            }else{
                if let isFromHome = isFromHome, isFromHome {
                    if indexPath.row > 0 {
                        self.inpuntTagId = self.tagData?[indexPath.row].id
                        self.getTrainerApi(inputFilter: "1", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                    }else{
                        self.inpuntTagId = self.tagData?[indexPath.row].id
                        self.getTrainerApi(inputFilter: "0", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                    }
                }else{
                    if indexPath.row > 0 {
                        self.inpuntTagId = self.tagData?[indexPath.row].id
                        self.getSelectGymList(inputFilter: "1", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                    }else{
                        self.inpuntTagId = self.tagData?[indexPath.row].id
                        self.getSelectGymList(inputFilter: "0", inpuntTagId: self.tagData?[indexPath.row].id as? Int)
                    }
                }
            }
            
           
            self.categorySelectedIndex = indexPath
            collectionView.reloadData()
        }else if collectionView == filterMenuCollView{
            
            let vc: TrainerFilterViewController = TrainerFilterViewController.instantiate(appStoryboard: .booking)
            vc.selectedMenuFilterStr = self.filterMenu?[indexPath.row] as? String
            vc.inputType = self.inputType
            vc.modalPresentationStyle = .automatic
            
            if let _ = self.inpuntTagId{
            }else{
                self.inpuntTagId = nil
            }
            
            vc.sendGenderStr = { [weak self] idStr , getData, gernderLstData in
                guard self != nil else {
                    return
                }
                self?.localGenderLstData = gernderLstData
                self?.is_filterStr = "1"
                self?.genderFilterStr = getData
                
                if self?.inputType?.capitalized == "home".capitalized {
                    self?.getFilterTrainerApi(inpuntTagId: self?.inpuntTagId)
                }else{
                    self?.getFilterSelectGymList(inpuntTagId: self?.inpuntTagId)
                }
                
            }
            
            vc.sendLanguageStr = { [weak self] idStr , getData, langLstData in
                guard self != nil else {
                    return
                }
                  
                self?.localLanguageLstData = langLstData
                self?.is_filterStr = "1"
                self?.languageFilterStr = idStr
//                self?.getFilterTrainerApi(inpuntTagId: self?.inpuntTagId)
                
                if self?.inputType?.capitalized == "home".capitalized {
                    self?.getFilterTrainerApi(inpuntTagId: self?.inpuntTagId)
                }else{
                    self?.getFilterSelectGymList(inpuntTagId: self?.inpuntTagId)
                }
            }
            
            vc.sendNationalityStr = { [weak self] idStr , getData, nationalityLstData in
                guard self != nil else {
                    return
                }
               
                self?.localNationalityLstData = nationalityLstData
                self?.is_filterStr = "1"
                self?.nationalityFilterStr = idStr
//                self?.getFilterTrainerApi(inpuntTagId: self?.inpuntTagId)
                
                if self?.inputType?.capitalized == "home".capitalized {
                    self?.getFilterTrainerApi(inpuntTagId: self?.inpuntTagId)
                }else{
                    self?.getFilterSelectGymList(inpuntTagId: self?.inpuntTagId)
                }
            }
            
            vc.sendTime_slotStr = { [weak self] idStr , getData, timeSlotData in
                guard self != nil else {
                    return
                }
               
                self?.localTimeSlotData = timeSlotData
                self?.is_filterStr = "1"
                self?.time_slotFilterStr = idStr
//                self?.getFilterTrainerApi(inpuntTagId: self?.inpuntTagId)
                
                if self?.inputType?.capitalized == "home".capitalized {
                    self?.getFilterTrainerApi(inpuntTagId: self?.inpuntTagId)
                }else{
                    self?.getFilterSelectGymList(inpuntTagId: self?.inpuntTagId)
                }
            }
            
            vc.localGenderLstData =  self.localGenderLstData
            vc.localLanguageLstData = self.localLanguageLstData
            vc.localNationalityLstData = self.localNationalityLstData
            vc.localTimeSlotData = self.localTimeSlotData
            
            self.navigationController?.present(vc, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == trainerGridCollView {
            let cellWdth = collectionView.frame.size.width*0.46
            return CGSize(width: cellWdth, height: cellWdth * 1.5)
            
        }else    if collectionView == filterMenuCollView {
            let cellWdth = collectionView.frame.size.width*0.24
            return CGSize(width: cellWdth, height: collectionView.frame.size.height)
        }
        else{
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
    }
    
}

//MARK: --------------UITABLEVIEW DELEGATE/DATASOURCE
extension TrainerListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let isFromHome = isFromHome, isFromHome {
            return tableView.numberOfRows(count: self.trainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
        }else{
            return tableView.numberOfRows(count: self.gymTrainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainerListTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "TrainerListTableViewCell", for: indexPath) as! TrainerListTableViewCell
      
//        cell.isUserInteractionEnabled = false
        
        if let isFromHome = isFromHome, isFromHome {
            cell.trainerTagsData = self.trainerData?[indexPath.row].tags
            cell.setCellData(trainerData: self.trainerData?[indexPath.row])
            
            cell.bookSlotBtn.accessibilityHint = "\(self.trainerData?[indexPath.row].id ?? 0)"
        }else{
            cell.trainerTagsData = self.gymTrainerData?[indexPath.row].tags
            cell.setGymCellData(trainerData: self.gymTrainerData?[indexPath.row])
           
            cell.bookSlotBtn.accessibilityHint = "\(self.gymTrainerData?[indexPath.row].id ?? 0)"
        }
        
        cell.bookSlotBtn.addTarget(self, action: #selector(bookSlotBtnActn(sender: )), for: .touchUpInside)
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        switch flowSlot {
        case .bookTrainerHomeWorkout, .bookTrainerGymWorkout, .createPackage:
            //----------------From book trainer
            if let isFromHome = isFromHome, isFromHome {
                let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
//                vc.inputParam = DetailsParam(trainer_id: "\(self.trainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.trainerData?[indexPath.row].id ?? 0)", type: self.inputType, long: self.inputLat, lat: self.inputLong)
                vc.inputParam = DetailsParam(trainer_id: "\(self.trainerData?[indexPath.row].id ?? 0)", studio_id: "", type: self.inputType, long: self.inputLong, lat: self.inputLat)
//                vc.isSlotsAvail = self.trainerData?[indexPath.row].isfull
                
                if let isFull = self.trainerData?[indexPath.row].isfull, let slotAvail = self.trainerData?[indexPath.row].slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
                    vc.isSlotsAvail = true
                }else{
                    vc.isSlotsAvail = false
                }
                
                vc.detailsFlowSetup = flowSlot
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
                vc.inputParam = DetailsParam(trainer_id: "\(self.gymTrainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.gymTrainerData?[indexPath.row].studioID ?? "")", type: self.inputType, long: self.inputLong, lat: self.inputLat)
//                vc.isSlotsAvail = self.gymTrainerData?[indexPath.row].isfull
                
                if let isFull = self.gymTrainerData?[indexPath.row].isfull, let slotAvail = self.gymTrainerData?[indexPath.row].slot, isFull && slotAvail.lowercased() == "no".lowercased() {
                    vc.isSlotsAvail = true
                }else{
                    vc.isSlotsAvail = false
                }
                
                vc.detailsFlowSetup = flowSlot //.bookTrainerGymWorkout
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .gymMembership, .withTrainerMembership, .withoutTrainerMembership:
            //----------------
            let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
//            vc.isSlotsAvail = self.gymTrainerData?[indexPath.row].isfull
            
            if let isFull = self.gymTrainerData?[indexPath.row].isfull, let slotAvail = self.gymTrainerData?[indexPath.row].slot, isFull && slotAvail.lowercased() == "no".lowercased() {
                vc.isSlotsAvail = true
            }else{
                vc.isSlotsAvail = false
            }
            vc.detailsFlowSetup = flowSlot
            vc.inputParam = DetailsParam(trainer_id: "\(self.gymTrainerData?[indexPath.row].id ?? 0)", studio_id: "\(self.gymTrainerData?[indexPath.row].studioID ?? "")", type: self.inputType, long: self.inputLong, lat: self.inputLat )
            self.navigationController?.pushViewController(vc, animated: true)
            
            /*
             if let isFull = trainerDetails?.isfull, let slotAvail = trainerDetails?.slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
             */
            
        case .defaultFlow:
            print("default....")
            break
        }
                
    }
    
    @objc func bookSlotBtnActn(sender:UIButton) {
        
        if let isFromHome = isFromHome, isFromHome {
            let getIndx = self.trainerData?.firstIndex(where: {
                $0.id == Int(sender.accessibilityHint ?? "0")
            })
            
            if let getIndx = getIndx {
                let trainerDetails = self.trainerData?[getIndx]
                
                
//                if let isFull = trainerDetails?.isfull, isFull {
                
                if let isFull = trainerDetails?.isfull, let slotAvail = trainerDetails?.slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
                    print("No slots available")
                }
                else{
                    let vc:SelectYourLocationViewController = SelectYourLocationViewController.instantiate(appStoryboard: .booking)
                    vc.trainerIdStr = "\(trainerDetails?.id ?? 0)"
                    vc.studioIdStr = studioId
                    vc.inputType = self.inputType
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
//                let vc:SelectYourLocationViewController = SelectYourLocationViewController.instantiate(appStoryboard: .booking)
//                vc.trainerIdStr = "\(trainerDetails?.id ?? 0)"
//                vc.studioIdStr = studioId
//                vc.inputType = self.inputType
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            
            let getIndx = self.gymTrainerData?.firstIndex(where: {
                $0.id == Int(sender.accessibilityHint ?? "0")
            })
            
            if let getIndx = getIndx {
                let trainerDetails = self.gymTrainerData?[getIndx]
                let currentMonth = Calendar.current.component(.month, from: Date())
                
//                if let isFull = trainerDetails?.isfull, isFull {
                
                if let isFull = trainerDetails?.isfull , let slotAvail = trainerDetails?.slot, isFull && slotAvail.lowercased() == "no".lowercased() {
                    print("No slots available")
                }
                else{
                    let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
                    vc.slotBookFlow = .bookTrainerGymWorkout
                    vc.params = AvailParmsModel(type: self.inputType, trainer_id: "\(trainerDetails?.id ?? 0)", studio_id: studioId, month: "\(currentMonth)", address_id: "")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                
//                let vc:BookingCalendarViewController = BookingCalendarViewController.instantiate(appStoryboard: .booking)
//                vc.slotBookFlow = .bookTrainerGymWorkout
//                vc.params = AvailParmsModel(type: self.inputType, trainer_id: "\(trainerDetails?.id ?? 0)", studio_id: studioId, month: "\(currentMonth)", address_id: "")
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

//MARK: ---------------- SEARCHBAR DELEAGTE
extension TrainerListViewController: UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
//        searchBar.showsCancelButton = false
        // Remove focus from the search bar.
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        
        /*
        if let isFromHome = isFromHome, isFromHome {
                self.trainerData?.removeAll()
                self.trainerData = self.trainerDataLocal
        }else{
                self.gymTrainerDataLocal?.removeAll()
                self.gymTrainerData = self.gymTrainerDataLocal
        }
        
        if let isGridshow = isGridShow, isGridshow {
            self.trainerGridCollView.reloadData()
        }else{
            self.trainerListTblView.reloadData()
        }
        */
        
        // Perform any necessary work.  E.g., repopulating a table view
        // if the search bar performs filtering.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Perform search action with the search text
        print("Search text: \(searchBar.text ?? "")")
        searchBar.resignFirstResponder()
    }
    
    // SearchBar Delegate
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//          if searchText.isEmpty {
//                   filteredPeople = people
//               } else {
//                   filteredPeople = people.filter { $0.name.lowercased().contains(searchText.lowercased()) }
//               }
          
          if let isFromHome = isFromHome, isFromHome {
              if searchText.isEmpty {
                  self.trainerData?.removeAll()
                  self.trainerData = self.trainerDataLocal
                  print("in empty self.trainerData: ", self.trainerData?.count as Any)
              } else {
                  if let trainerData = self.trainerDataLocal {
                      self.trainerData = trainerData.filter { ($0.name ?? "").lowercased().contains(searchText.lowercased()) }
                      print("in filter trainerData: ", self.trainerData?.count as Any)
                  }else{
                      print("in outer trainerData: ", self.trainerData?.count as Any)
                  }
              }
          }else{
              if searchText.isEmpty {
                  self.gymTrainerDataLocal?.removeAll()
                  self.gymTrainerData = self.gymTrainerDataLocal
              } else {
                  if let trainerData = self.gymTrainerData {
                      self.gymTrainerData = trainerData.filter { ($0.name ?? "").lowercased().contains(searchText.lowercased()) }
                  }
              }
          }
          
          if let isGridshow = isGridShow, isGridshow {
              self.trainerGridCollView.reloadData()
          }else{
              self.trainerListTblView.reloadData()
          }
      }
    
 
     func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
         print(searchBar.text as Any)
         }
    
     
         func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
                searchBar.resignFirstResponder()
         }
}

//MARK: -----------------------EXTENSION FOR API
extension TrainerListViewController {
    
    //MARK: --------------------GET TRAINER LIST API
    private func getTrainerApi(inputFilter: String?, inpuntTagId: Int?){
        let params:[String:String] = [
            "type": self.inputType ?? "",
            "is_filter": inputFilter ?? "",
            "tag_id": "\(inpuntTagId ?? 0)" ,
            "long": self.inputLong ?? "",
            "lat": self.inputLat ?? ""
        ]
        
        TrainerVM.gerTrainerApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("get trainer list result data: ", getResultData as Any)
            
//            DispatchQueue.main.async {
                self.tagData?.removeAll()
                self.trainerData?.removeAll()
                self.tagData?.append(contentsOf: getResultData.data?.tags ?? [])
                self.trainerData?.append(contentsOf: getResultData.data?.trainers ?? [])
                self.trainerDataLocal?.removeAll()
                self.trainerDataLocal = self.trainerData
               
                //-------------------Reload to set data
                let tagModelData = TagModel(id: 1, name: "All Workouts", description: "", icon: "", image: "")
                self.tagData?.insert(tagModelData, at: 0)
                self.workoutCategoryCollView.reloadData()
                
                if let isGridshow = self.isGridShow, isGridshow {
                    self.trainerGridCollView.reloadData()
                }else{
                    self.trainerListTblView.reloadData()
                }
//            }
        })
    }
    
    //-----------------Filter Trainer list(Home)
    private func getFilterTrainerApi(inpuntTagId: Int?){
        var params:[String:Any] = [
            "gender": genderFilterStr ?? "",
            "language": languageFilterStr ?? "",
            "nationality": nationalityFilterStr ?? "",
            "time_slot": time_slotFilterStr ?? "",
            "is_filter": is_filterStr ?? "",
            "long": self.inputLong ?? "",
            "lat": self.inputLat ?? "",
            "type": self.inputType ?? "",
//            "tag_id": "\(inpuntTagId ?? 0)" ,
            
        ]
        
        if let inpuntTagId = inpuntTagId {
            params["tag_id"] = inpuntTagId
        }else{
            
        }
        
        print("params: ", params)
        /*
         let params:[String:Any] = [
         "gender": 1,2,
         "language": 1,2
         "is_filter":1
         "lat": 1.344444
         "long":4.8999
         "time_slot":
         "type": home , type: gym, home, gym based on selection
         "tag_id":49 , //tag_id: 1, tag id is required when is filter 1
         "nationality": 1,2
         ]
         */
        
        TrainerVM.gerFilterTrainerApi(viewController: self, inputParams: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("get trainer list result data: ", getResultData as Any)
            
            DispatchQueue.main.async {
                self.tagData?.removeAll()
                self.trainerData?.removeAll()
                self.tagData?.append(contentsOf: getResultData.data?.tags ?? [])
                self.trainerData?.append(contentsOf: getResultData.data?.trainers ?? [])
                self.trainerDataLocal?.removeAll()
                self.trainerDataLocal = self.trainerData
               
                //-------------------Reload to set data
                let tagModelData = TagModel(id: nil, name: "All Workouts", description: "", icon: "", image: "")
                self.tagData?.insert(tagModelData, at: 0)
                self.workoutCategoryCollView.reloadData()
                                
                if let isGridshow = self.isGridShow, isGridshow {
                    self.trainerGridCollView.reloadData()
                }else{
                    self.trainerListTblView.reloadData()
                }
            }
        })
    }
    
    //MARK: -------------SELECT GYM
    /*
     id = 5 , this is studio id , for get studio trainers
     long = 77.391029, this is always required for current location
     lat = 28.535517, this is always required for current location
     is_filter = 1, if select tag based trainer
     tag_id = 4, required if is_filter is 1
     */
    
    private func getSelectGymList(inputFilter: String?, inpuntTagId: Int?){
        
        let params:[String:String] = [
            "id": self.studioId ?? "",
            "long": self.inputLong ?? "",
            "lat": self.inputLat ?? "",
            "is_filter": inputFilter ?? "",
            "tag_id": "\(inpuntTagId ?? 0)"
        ]
        
        TrainerVM.selectGymApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            print(getResultData)
            
            self.gymTrainerData?.removeAll()
            self.tagData?.removeAll()
            self.trainerData?.removeAll()
            self.tagData?.append(contentsOf: getResultData.data?.tags ?? [])
            self.gymTrainerData?.append(contentsOf: getResultData.data?.trainers ?? [])
            self.gymTrainerDataLocal?.removeAll()
            self.gymTrainerDataLocal = self.gymTrainerData
            
            //-------------------Reload to set data
            let tagModelData = TagModel(id: 1, name: "All Workouts", description: "", icon: "", image: "")
            self.tagData?.insert(tagModelData, at: 0)
            self.workoutCategoryCollView.reloadData()
//            self.trainerListTblView.reloadData()
            
            if let isGridshow = isGridShow, isGridshow {
                self.trainerGridCollView.reloadData()
            }else{
                self.trainerListTblView.reloadData()
            }
        })
        
    }
    
    
    
    //-----------------Filter Trainer list(from gym)
    private func getFilterSelectGymList(inpuntTagId: Int?){
        
        var params:[String:Any] = [
            "id": self.studioId ?? "",
            "gender": genderFilterStr ?? "",
            "language": languageFilterStr ?? "",
            "nationality": nationalityFilterStr ?? "",
            "time_slot": time_slotFilterStr ?? "",
            "long": self.inputLong ?? "",
            "lat": self.inputLat ?? "",
            "type": self.inputType ?? "",
            
        ]
        
        if let inpuntTagId = inpuntTagId {
            params["tag_id"] = inpuntTagId
        }else{
            
        }
        
        TrainerVM.selectGymFilterTrainerApi(viewController: self, inputParams: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }

            print(getResultData)

            self.gymTrainerData?.removeAll()
            self.tagData?.removeAll()
            self.trainerData?.removeAll()
            self.tagData?.append(contentsOf: getResultData.data?.tags ?? [])
            self.gymTrainerData?.append(contentsOf: getResultData.data?.trainers ?? [])
            self.gymTrainerDataLocal?.removeAll()
            self.gymTrainerDataLocal = self.gymTrainerData

            //-------------------Reload to set data
            let tagModelData = TagModel(id: nil, name: "All Workouts", description: "", icon: "", image: "")
            self.tagData?.insert(tagModelData, at: 0)
            self.workoutCategoryCollView.reloadData()

            if let isGridshow = isGridShow, isGridshow {
                self.trainerGridCollView.reloadData()
            }else{
                self.trainerListTblView.reloadData()
            }
        })
    }
}


