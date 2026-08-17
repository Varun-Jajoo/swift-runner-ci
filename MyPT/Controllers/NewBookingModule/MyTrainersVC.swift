//
//  MyTrainersVC.swift
//  MyPT
//
//  Created by Manik Goel on 26/07/26.
//

import UIKit

class MyTrainersVC: CommonViewController {
    
    // MARK: --------------VARIBALE
    var categorySelectedIndex:IndexPath?
    var inputLat: String?
    var inputLong: String?
    var studioId:String?
    var package_type: String?
    
    var tagData:[TagModel]? = []
    var trainerData:[TrainerModel]? = []
//    var gymTrainerData:[GymTrainerModel]? = []
    var trainerDataLocal: [TrainerModel]? = []
//    var gymTrainerDataLocal: [GymTrainerModel]? = []
    var filterMenu: [String]?
    
    var isGridShow: Bool?
    private var genderFilterStr : String?
    private var languageFilterStr : String?
    private var nationalityFilterStr : String?
    private var time_slotFilterStr : String?
    private var is_filterStr : String?
    private var inpuntTagId: Int?
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
                    } else {
                        self.emptyTitle = "You’re not following anyone at the moment"
                        self.emptyDesc = nil
                        self.emptyImg = AppImages.MyFavourite_Workouts?.resized(to: CGSize(width: 200.0, height: 200.0))
                    }
                    self.getUserTrainersApi(inputFilter: nil, inpuntTagId: nil)
                } else {
                    self.getCurrentLocation()
                }
            }
        }
    }
    
    // MARK: ----------------IBOUTLET
//    @IBOutlet weak var workoutCategoryCollView: UICollectionView!
    @IBOutlet weak var trainerListTblView: UITableView!
    @IBOutlet weak var trainerGridCollView: UICollectionView!
    @IBOutlet weak var tblMBV: UIView!
    @IBOutlet weak var collMBV: UIView!
//    @IBOutlet weak var btnFilter: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputType = "1"
        self.categorySelectedIndex = IndexPath(row: 0, section: 0)
        self.setupUI()
        collMBV.isHidden = true
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.istagMenuHeight = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.searchContainerView.removeFromSuperview()
//        stopAllVisibleVideos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        stopAllVisibleVideos()
    }
    
    func setNavUI() {
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [AppStrings.trainers], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func getCurrentLocation() {
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first,  let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last {
            self.inputLat = lat
            self.inputLong = long
        } else {
            GetLocationManager.shared.requestLocation(completion: { [weak self] getLocation in
                guard let self = self, let getLocation = getLocation else { return  }
                self.inputLat = "\(getLocation.coordinate.latitude)"
                self.inputLong = "\(getLocation.coordinate.longitude)"
            })
        }
        self.getUserTrainersApi(inputFilter: nil, inpuntTagId: nil)
    }
    
    private func setupUI() {
        //        self.filterMenu = ["Time slot", "Gender", "Language", "Nationality"]
        self.filterMenu = ["Nationality", "Gender", "Language"]
        
//        workoutCategoryCollView.register(UINib(nibName: "WorkoutCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCategoryCollectionViewCell")
        
        trainerGridCollView.register(UINib(nibName: "GridTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridTrainerCollectionViewCell")
        
        trainerListTblView.register(UINib(nibName: "TrainerListTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerListTableViewCell")
        trainerListTblView.delegate = self
        trainerListTblView.dataSource = self
        tblMBV.isHidden = false
        collMBV.isHidden = true
        trainerListTblView.reloadData()
    }
}

//MARK: --------------UITABLEVIEW DELEGATE/DATASOURCE
extension MyTrainersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let isFromHome = isFromHome, isFromHome {
            return tableView.numberOfRows(count: self.trainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
//        }else{
//            return tableView.numberOfRows(count: self.gymTrainerData?.count, title: AppAlertStrings.no_results_found, message: nil, messageImage: AppImages.search_NoResult, messageImageHeight: 200.0, fromTop: 50)
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainerListTableViewCell = trainerListTblView.dequeueReusableCell(withIdentifier: "TrainerListTableViewCell", for: indexPath) as! TrainerListTableViewCell
            cell.trainerTagsData = self.trainerData?[indexPath.row].tags
            cell.setCellData(trainerData: self.trainerData?[indexPath.row], indexPath: indexPath)
            cell.btnSelectTrainer.accessibilityHint = "\(self.trainerData?[indexPath.row].id ?? 0)"
            cell.viewDetailsBtn.accessibilityHint = "\(self.trainerData?[indexPath.row].id ?? 0)"
        cell.btnSelectTrainer.isHidden = true
        //        cell.viewDetailsBtn.accessibilityHint = "\(self.gymTrainerData?[indexPath.row].id ?? 0)"
//        cell.btnSelectTrainer.addTarget(self, action: #selector(bookSlotBtnActn(sender: )), for: .touchUpInside)
        cell.viewDetailsBtn.addTarget(self, action: #selector(viewProfileBtnActn(sender: )), for: .touchUpInside)
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? TrainerListTableViewCell else { return }
        
        stopAllVisibleVideos()
        
        cell.playVideoAfterDelay()
    }
    
    // Screen se hatne par video band
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? TrainerListTableViewCell else { return }
        cell.stopVideo()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        playMostVisibleCell()
    }
    
    func playMostVisibleCell() {
        
        let visibleCells = trainerListTblView.visibleCells.compactMap { $0 as? TrainerListTableViewCell }
        
        guard visibleCells.count > 0 else { return }
        
        var maxVisibleCell: TrainerListTableViewCell?
        var maxVisiblePercentage: CGFloat = 0
        
        for cell in visibleCells {
            
            // Calculate visibility in tableView's own coordinate space for stable ratio.
            let cellFrameInTable = trainerListTblView.convert(cell.frame, from: cell.superview)
            let visibleFrame = trainerListTblView.bounds.intersection(cellFrameInTable)
            
            let visibleHeight = visibleFrame.height
            let totalHeight = cell.frame.height
            
            let visiblePercentage = visibleHeight / totalHeight
            
            if visiblePercentage > maxVisiblePercentage {
                maxVisiblePercentage = visiblePercentage
                maxVisibleCell = cell
            }
        }
        
        // Keep currently playing cell as long as it remains the top-visible one.
        let currentlyPlayingCell = visibleCells.first(where: { ($0.player?.rate ?? 0) > 0 })
        
        if let cellToPlay = maxVisibleCell,
           maxVisiblePercentage >= 0.7 {
            if currentlyPlayingCell !== cellToPlay {
                stopAllVisibleVideos()
                cellToPlay.playVideoAfterDelay()
            }
        } else {
            // No cell has enough visibility, then stop all.
            stopAllVisibleVideos()
        }
    }
    
    func stopAllVisibleVideos() {
        for visibleCell in trainerListTblView.visibleCells {
            if let videoCell = visibleCell as? TrainerListTableViewCell {
                videoCell.stopVideo()
            }
        }
    }
    
    @objc func viewProfileBtnActn(sender:UIButton) {
        TapticEngine.selection.feedback()
        let vc: TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
        let getIndx = self.trainerData?.firstIndex(where: {
            $0.id == Int(sender.accessibilityHint ?? "0")
        })
        vc.inputParam = DetailsParam(
            trainer_id: "\(self.trainerData?[getIndx ?? 0].id ?? 0)",
            type: self.package_type,
            long: self.inputLong ?? "",
            lat: self.inputLat ?? ""
        )
        vc.package_type = self.package_type
        vc.fromMyTrainer = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: -----------------------EXTENSION FOR API
extension MyTrainersVC {
    
    //MARK: --------------------GET TRAINER LIST API
    private func getUserTrainersApi(inputFilter: String?, inpuntTagId: Int?) {
        
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
            self.package_type = getResultData.data?.type ?? ""
            
            //-------------------Reload to set data
            let tagModelData = TagModel(id: 1, name: "All Workouts", description: "", icon: "", image: "")
            self.tagData?.insert(tagModelData, at: 0)
//            self.tagsCollView.reloadData()
            
            if let isGridshow = self.isGridShow, isGridshow {
//                self.trainersGridCollView.reloadData()
            } else {
                self.trainerListTblView.reloadData()
            }
        })
    }
}
