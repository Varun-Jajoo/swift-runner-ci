//
//  FollowersViewController.swift
//  MyPT
//
//  Created by techsaga corp on 22/05/25.
//

import UIKit

class FollowersViewController: CommonViewController {

    //MARK: --------------- VARIABLE
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

    
    var isLoadFirst: Bool? = nil
    
    var isGridShow:Bool?
    var tagData:[TagModel]? = []
    var trainerData:[TrainerModel]? = []
    var trainerDataLocal: [TrainerModel]? = []
    var inputIs_filter:String?
    var inputLat:String?
    var inputLong:String?
    var studioId:String?
    var categorySelectedIndex:IndexPath?
    var emptyTitle: String?
    var emptyDesc: String?
    var emptyImg: UIImage?
    
    var inputType:String? = "1" {
        didSet{
            if let inputType = inputType {
                if let _ = inputLat, let _ = inputLong {
                    
                    if inputType == "1" {
                        self.emptyTitle = "No bookings found"
                        self.emptyDesc = "You haven't booked any training sessions with a trainer yet. Book a session now to get started!"
                        self.emptyImg = AppImages.search_NoResult
                    }else{
                        self.emptyTitle = "You’re not following anyone at the moment"
                        self.emptyDesc = nil
                        self.emptyImg = AppImages.MyFavourite_Workouts?.resized(to: CGSize(width: 200.0, height: 200.0))
                    }
                    
                    self.getUserTrainersApi(inputFilter: nil, inpuntTagId: nil)
                }else{
                    self.getCurrentLocation()
                }
            }
        }
    }
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var followersMStckBV: UIStackView!
    @IBOutlet weak var myTrainersBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var tagsCollView: UICollectionView!
    @IBOutlet weak var listMBV: UIView!
    @IBOutlet weak var gridMBV: UIView!
    @IBOutlet weak var trainerListTblView: UITableView!
    @IBOutlet weak var trainersGridCollView: UICollectionView!
    @IBOutlet weak var heightOfTableView: NSLayoutConstraint!
    
    private var contentSizeObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        isLoadFirst = true
        inputType = "1"
        listMBV.isHidden = false
        gridMBV.isHidden = true
        self.categorySelectedIndex = IndexPath(row: 0, section: 0)
        setSegBtn(isTraineer: true)
        self.registerCell()
    }
    
    deinit {
        contentSizeObservation?.invalidate()
        contentSizeObservation = nil
        print("------\(#function)------\(String(describing: Self.self))------" )
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
            self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["My " + AppStrings.trainers], setTintColor: .black, setTitleColor: UIColor.appWhite)
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
                trainersGridCollView.reloadData()
                listMBV.isHidden = true
                gridMBV.isHidden = false
                
            }else if sender.tag == 1{
                print("show list view")
                self.isGridShow = false
                trainerListTblView.reloadData()
                listMBV.isHidden = false
                gridMBV.isHidden = true
                
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
        }
    }
    
    @IBAction func myTrainerCommonBtnActn(_ sender: UIButton) {
        if sender.tag == 1101 {
            print("My Trainers.......")
            setSegBtn(isTraineer: true)
        }else{
            print("Following....")
            setSegBtn(isTraineer: false)
        }
    }
    
    private func registerCell(){
        tagsCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        trainersGridCollView.register(UINib(nibName: "GridTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridTrainerCollectionViewCell")
        trainerListTblView.register(UINib(nibName: "MyTrainerTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTrainerTableViewCell")
//        trainerListTblView.register(UINib(nibName: "TrainerListTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerListTableViewCell")
        
        trainerListTblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        trainersGridCollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
        // Disable internal scrolling — the parent UIScrollView handles all scrolling.
        // This prevents the table/collection from capturing the gesture on the first touch.
        trainerListTblView.isScrollEnabled = false
        trainersGridCollView.isScrollEnabled = false
        
        contentSizeObservation = trainerListTblView.observe(\.contentSize, options: [.new]) { [weak self] (tv, change) in
            guard let self = self else { return }
            self.heightOfTableView.constant = tv.contentSize.height
        }
        
        self.isGridShow = false
        trainerListTblView.reloadData()
        listMBV.isHidden = false
        gridMBV.isHidden = true
    }
    
    private func setSegBtn(isTraineer:Bool){
        if isTraineer {
            self.myTrainersBtn.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: nil)
            
            self.myTrainersBtn.backgroundColor = UIColor.appWhite
            self.followingBtn.backgroundColor = UIColor.clear
            self.myTrainersBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.followingBtn.setTitleColor(UIColor.appWhite, for: .normal)
            self.inputType = "1"
        }
        else{
            self.followingBtn.applyTransition(type: .moveIn, subtype: .fromLeft, duration: 0.5, timingFunction: .easeInEaseOut, completion: nil)
            self.myTrainersBtn.backgroundColor = UIColor.clear
            self.followingBtn.backgroundColor = UIColor.appWhite
            self.followingBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.myTrainersBtn.setTitleColor(UIColor.appWhite, for: .normal)
            self.inputType = "2"
        }
    }
    
    @objc func clearSearch(sender: UIButton){
        print("lcear search bar")
        self.removeSearch()
    }
    
    private func removeSearch(){
        self.searchContainerView.applyTransition(type: .moveIn, subtype: .fromLeft, duration: 0.5, timingFunction: .easeInEaseOut, completion: {[weak self] in
            
            self?.searchContainerView.removeFromSuperview()
        })
    }
    
    func updateUI(selectedView:[UIButton]){
        
        for i in selectedView{
            if i.isSelected {
                i.backgroundColor = UIColor.clear
                i.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
            }else{
                i.backgroundColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1)
                i.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
        }
    }
    
    
    //MARK: -------------GET Lat long
    private func getCurrentLocation(){
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first,  let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
            self.inputLat = lat
            self.inputLong = long
        }else{
            GetLocationManager.shared.requestLocation(completion: { [weak self] getLocation in
                guard let self = self, let getLocation = getLocation else { return  }

                self.inputLat = "\(getLocation.coordinate.latitude)"
                self.inputLong = "\(getLocation.coordinate.longitude)"
            })
        }
        
        //----------********** for Api
        self.getUserTrainersApi(inputFilter: nil, inpuntTagId: nil)
    }
    
    private func setupUI(){
        [
            myTrainersBtn.titleLabel,
            followingBtn.titleLabel
        ].forEach({[weak self]  in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
        self.followersMStckBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)
        DispatchQueue.main.async {
            self.followersMStckBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.myTrainersBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            self.followingBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
        }
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
            UIView.animate(withDuration: duration, animations: {
                container.frame = finalFrame
            }, completion: { _ in
                completion?()
            })
    }

}

extension FollowersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                
        if collectionView == trainersGridCollView {
            return collectionView.numberOfRows(count: self.trainerData?.count, title: emptyTitle, message: emptyDesc, messageImage: emptyImg, messageImageHeight: 200.0, reloadSetTitle: "EXPLORE TRAINERS", target: self, action: #selector(exploreTrainerBtnAtcn(sender: )), fromTop: 10)
        }else{
            return tagData?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == trainersGridCollView {
            let cell:GridTrainerCollectionViewCell = trainersGridCollView.dequeueReusableCell(withReuseIdentifier: "GridTrainerCollectionViewCell", for: indexPath) as! GridTrainerCollectionViewCell
            
//            cell.landMarkBtn.titleLabel?.numberOfLines = 1
            cell.distanceBtn.titleLabel?.numberOfLines = 1
//            cell.landMarkBtn.titleLabel?.lineBreakMode = .byClipping
            cell.distanceBtn.titleLabel?.lineBreakMode = .byClipping
            
            cell.trainerTagsData = self.trainerData?[indexPath.row].tags
            cell.setupCellData(trainerData: self.trainerData?[indexPath.row])
            
            return cell
        }else{
            let cell:WorkoutCategoryCollectionViewCell = tagsCollView.dequeueReusableCell(withReuseIdentifier: "WorkoutCategoryCollectionViewCell", for: indexPath) as! WorkoutCategoryCollectionViewCell
            
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
        
        if collectionView == trainersGridCollView {
            let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
            vc.isFromMyTrainers = true
            vc.inputParam = DetailsParam(trainer_id: "\(self.trainerData?[indexPath.row].id ?? 0)", studio_id: "", type: "home", long: self.inputLong, lat: self.inputLat)
            vc.detailsFlowSetup = .bookTrainerHomeWorkout
            if let isFull = self.trainerData?[indexPath.row].isfull, let slotAvail = self.trainerData?[indexPath.row].slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
                vc.isSlotsAvail = true
            }else{
                vc.isSlotsAvail = false
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            
            self.categorySelectedIndex = indexPath
            collectionView.reloadData()
            
            self.getUserTrainersApi(inputFilter: nil, inpuntTagId: self.tagData?[indexPath.row].id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == trainersGridCollView {
            let cellWdth = collectionView.frame.size.width*0.46
            return CGSize(width: cellWdth, height: cellWdth * 1.5)
        }else{
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
    }
}

extension FollowersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
        return tableView.numberOfRows(count: self.trainerData?.count, title: emptyTitle, message: emptyDesc, messageImage: emptyImg, messageImageHeight: 200.0, reloadSetTitle: "EXPLORE TRAINERS", target: self, action: #selector(exploreTrainerBtnAtcn(sender: )), fromTop: 10)
//        return 10
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyTrainerTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "MyTrainerTableViewCell", for: indexPath) as! MyTrainerTableViewCell
        cell.trainerTagsData = self.trainerData?[indexPath.row].tags
        cell.setMyTrainersCellData(trainerData: self.trainerData?[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
        vc.isFromMyTrainers = true
        vc.inputParam = DetailsParam(trainer_id: "\(self.trainerData?[indexPath.row].id ?? 0)", studio_id: "", type: "home", long: self.inputLong, lat: self.inputLat)
 
        if let isFull = self.trainerData?[indexPath.row].isfull, let slotAvail = self.trainerData?[indexPath.row].slot?.value, isFull && slotAvail.lowercased() == "no".lowercased() {
            vc.isSlotsAvail = true
        }else{
            vc.isSlotsAvail = false
        }
        
        vc.detailsFlowSetup = .bookTrainerHomeWorkout //Only for booking
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: ---------------DATA RELOAD
    @objc func exploreTrainerBtnAtcn(sender: UIButton){
        let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

//MARK: ---------------- SEARCHBAR DELEAGTE
extension FollowersViewController: UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
//        searchBar.showsCancelButton = false
        // Remove focus from the search bar.
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        self.trainerData?.removeAll()
        self.trainerData = self.trainerDataLocal
        if let isGridshow = isGridShow, isGridshow {
            self.trainersGridCollView.reloadData()
        }else{
            self.trainerListTblView.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Perform search action with the search text
        print("Search text: \(searchBar.text ?? "")")
        searchBar.resignFirstResponder()
    }
    
    // SearchBar Delegate
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

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

          if let isGridshow = isGridShow, isGridshow {
              self.trainersGridCollView.reloadData()
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

//MARK: -------------- API
extension FollowersViewController{
    
    private func getUserTrainersApi(inputFilter: String?, inpuntTagId: Int?){
        
        let params: [String:String]? = [
               "lat": self.inputLat ?? "",
               "long": self.inputLong ?? "",
               "type": inputType ?? "1", // 1=>trainer al ,2=>following
               "is_filter": inputFilter ?? "", // if filter wise then 1
               "tag_id": "\(inpuntTagId ?? 0)" // tag id is required if is_filter 1
           ]
                
        ProfileVM.getUserTrainersApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            self.tagData?.removeAll()
            self.trainerData?.removeAll()
            self.tagData?.append(contentsOf: getResultData.data?.tags ?? [])
            self.trainerData?.append(contentsOf: getResultData.data?.trainers ?? [])

            self.trainerDataLocal?.removeAll()
            self.trainerDataLocal = self.trainerData
            
            //-------------------Reload to set data
            let tagModelData = TagModel(id: 1, name: "All Workouts", description: "", icon: "", image: "")
            self.tagData?.insert(tagModelData, at: 0)
            self.tagsCollView.reloadData()
            
            if let isGridshow = self.isGridShow, isGridshow {
                self.trainersGridCollView.reloadData()
            }else{
                self.trainerListTblView.reloadData()
            }
        })
    }
}
