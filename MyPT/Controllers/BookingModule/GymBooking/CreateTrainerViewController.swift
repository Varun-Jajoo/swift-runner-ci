//
//  CreateTrainerViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/11/24.
//

import UIKit
import Mixpanel

enum TrainerType {
    case soloTraining
    case buddyTraining
    case groupTraining
    case homeWorkout
    case gymWorkout
    case withTrainer
    case withoutTrainer
    case withMyTeams
    case withAnotherTeam
}

struct TrainerOption {
    var type: TrainerType?
    var normalImage: UIImage?
    var selectedImage: UIImage?
    var title: String?
    var subTitle: String?
}

class CreateTrainerViewController: CommonViewController {

    //MARK: --------------VARIABLE
    var trainerData: [[String:Any]]?
    var getLat: Double?
    var getLong: Double?
    var flowCreatePackage: calendarFlow = .defaultFlow
    var trainerOptions: [TrainerOption]?
    var selectedIndex: IndexPath?
    var addressData: [AddressDataModel]? = []
    var isGuestHomepage: Bool = false
    var isHomeOrGymSelected: Bool = false // Only when comes from guest flow with top Options
    var isHomePreSelected: Bool = false // Only when comes from guest flow with top Options
    var userPlans = [PlanDetailsModel]()
    var isFreeAssessmentSelected: Bool = false
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var trainerListTblView: UITableView!
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFont()
        setupUI()
     
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first, let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last {
            self.getLat = Double(lat)
            self.getLong = Double(long)
        }
        
        self.setFlowCreatePackage()
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
        // Address list api for checking for existing add
        self.getAddressListApi()
        self.getPlansApi()
        
        // Only when comes from guest flow with top Options
        if isHomeOrGymSelected {
            updateContinueButton(isEnabled: true)
            if isHomePreSelected {
                selectedIndex = IndexPath(row: 0, section: 0)
            } else {
                selectedIndex = IndexPath(row: 1, section: 0)
            }
        }
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
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.1)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
    }
    
    private func setFlowCreatePackage() {

        trainerListTblView.register(
            UINib(nibName: "TrainerTypeTableViewCell", bundle: nil),
            forCellReuseIdentifier: "TrainerTypeTableViewCell"
        )

        if isGuestHomepage == true {
            trainerOptions = [
                TrainerOption(
                    type: .withTrainer,
                    normalImage: AppImages.withTrainerMembership,
                    selectedImage: AppImages.withTrainerMembership_selected,
                    title: "With a Trainer"
                    
                ),
                TrainerOption(
                    type: .withoutTrainer,
                    normalImage: AppImages.withoutTrainerMembership,
                    selectedImage: AppImages.withoutTrainerMembership_selected,
                    title: "Without a Trainer"
                )
            ]
                   self.trainerListTblView.reloadData()
        } else {
            trainerOptions = flowCreatePackage.options
        }
        continueBtn.isUserInteractionEnabled = false

        trainerListTblView.reloadData()
    }

    
    //MARK: -------------GET Lat long
    private func getLocation(){
        GetLocationManager.shared.requestLocationWithAddress {[weak self] location, addressPart in
            guard let self = self, let getLocation = location else { return  }
            appUserDefaults.setLatLong(value: "\(getLocation.coordinate.latitude),\(getLocation.coordinate.longitude)")
            appUserDefaults.setCurrentAddr(value: addressPart.0)
            
            self.getLat = getLocation.coordinate.latitude
            self.getLong = getLocation.coordinate.longitude
        }
    }
    
    //MARK: ---------- SET UI
    private func setupUI(){
        DispatchQueue.main.async {
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //------------------************Font
    private func setUpFont() {
        self.lblBottom.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
    func updateContinueButton(isEnabled: Bool) {
        continueBtn.isEnabled = isEnabled
        continueBtn.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.continueBtn.tintColor = .mainBg   // arrow color
                self.continueBtn.backgroundColor = .appWhite
                self.continueBtn.setTitleColor(.mainBg, for: .normal)
            } else {
                self.continueBtn.tintColor = .appWhite
                self.continueBtn.backgroundColor = .appDarkGray
                self.continueBtn.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        if isEnabled {
            // 🟢 ENABLED → IMAGE ONLY
            let image = UIImage(named: "btnNext")?
                .withRenderingMode(.alwaysOriginal)

            continueBtn.setImage(image, for: .normal)
            continueBtn.setTitle("", for: .normal)

            continueBtn.backgroundColor = .clear
            continueBtn.tintColor = .clear

            continueBtn.imageEdgeInsets = .zero
            continueBtn.titleEdgeInsets = .zero
            continueBtn.contentEdgeInsets = .zero
            continueBtn.semanticContentAttribute = .forceLeftToRight
            continueBtn.adjustsImageWhenHighlighted = false
            continueBtn.adjustsImageWhenDisabled = false

        } else {
            // 🔴 DISABLED → TEXT + ARROW
            continueBtn.setTitle("NEXT", for: .normal)
            continueBtn.setTitleColor(.appWhite, for: .normal)

            let arrowImage = UIImage(named: "whiteRightArrow")?
                .withRenderingMode(.alwaysOriginal)
            continueBtn.setImage(arrowImage, for: .normal)

            continueBtn.semanticContentAttribute = .forceRightToLeft

            // spacing between text & arrow
            continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    func hasPlan(type: String) -> Bool {
        return self.userPlans.contains {
            $0.type?.value == type
        }
    }

    @IBAction func continueBtnActn(_ sender: UIButton) {
        print("Continue btn actn.....")
        if self.addressData?.count != 0 { // when address is
            guard let selectedIndex = selectedIndex,
                  let getLat = getLat,
                  let getLong = getLong else {
                getLocation()
                return
            }
            if selectedIndex.row == 0 { // Home
                if isFreeAssessmentSelected { // Only for Free Assessment flow
                    let vc: TrainerListViewController = TrainerListViewController.instantiate(appStoryboard: .booking)
                    vc.flowSlot = .bookTrainerHomeWorkout
                    vc.isFromHome = true
                    vc.inputType = "home"
                    vc.inputLat = getLat
                    vc.inputLong = getLong
                    vc.inputParam = DetailsParam(
                        type: "home",
                        long: "\(self.getLong ?? 0.0)",
                        lat: "\(self.getLat ?? 0.0)",
                        addressId: self.addressData?.first?.id?.value,
                        addressData: self.addressData?.first,
                        isFreeAssessmentSelected: isFreeAssessmentSelected
                    )
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    let homeTrue = hasPlan(type: "home")
                    if homeTrue { // If user have package
                        let vc: ChoosePrimaryTrainerVC = ChoosePrimaryTrainerVC.instantiate(appStoryboard: .purchase)
                        //                    vc.packageType = packageType
                        vc.inputType = "home"
                        vc.inputLat = getLat
                        vc.inputLong = getLong
                        vc.inputParam = DetailsParam(
                            type: "home",
                            long: "\(self.getLong ?? 0.0)",
                            lat: "\(self.getLat ?? 0.0)",
                            addressId: self.addressData?.first?.id?.value,
                            addressData: self.addressData?.first
                        )
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else { // If user does not have package
                        let vc: CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
                        vc.inputType = "home"
                        vc.inputLat = getLat
                        vc.inputLong = getLong
                        vc.inputParam = DetailsParam(
                            type: "home",
                            long: "\(self.getLong ?? 0.0)",
                            lat: "\(self.getLat ?? 0.0)",
                            addressId: self.addressData?.first?.id?.value,
                            addressData: self.addressData?.first
                        )
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else { // GYM
                // Normal Flow
                let vc: GymWorkoutViewController = GymWorkoutViewController.instantiate(appStoryboard: .booking)
                vc.flowGymwork = .bookTrainerGymWorkout
                vc.inputType = "gym"
                vc.inputLat = getLat
                vc.inputLong = getLong
                vc.hasGymPackage = hasPlan(type: "gym") // check for user have package or not
                vc.inputParam = DetailsParam(
                    type: "gym",
                    long: "\(self.getLong ?? 0.0)",
                    lat: "\(self.getLat ?? 0.0)",
                    isFreeAssessmentSelected: isFreeAssessmentSelected
                )
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc: LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
            vc.flowLocation = .addAddress
            vc.isFromEditAddress = false
            vc.inputType = selectedIndex?.row == 0 ? "home" : "gym"
            vc.inputLat = "\(getLat ?? 0.0)"
            vc.inputLong = "\(getLong ?? 0.0)"
            vc.isFreeAssessmentSelected = isFreeAssessmentSelected
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension CreateTrainerViewController:UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainerOptions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerTypeTableViewCell", for: indexPath) as! TrainerTypeTableViewCell

        let option = trainerOptions?[indexPath.row]
        let isSelected = indexPath == selectedIndex

        // ❌ Title always hidden
//        cell.titleLbl.isHidden = true
        cell.titleLbl.text = option?.title ?? ""
        cell.descLbl.text = option?.subTitle ?? ""
        cell.setSelectdBGCell(
            option?.normalImage,
            selectedImg: option?.selectedImage,
            isSelectedCell: isSelected
        )

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        Mixpanel.mainInstance().track(
            event: "FA_Service_Type_Selected",
            properties: [
                "service_type": selectedIndex?.row == 0 ? "Home" : "Gym",
            ]
        )
//        enableContinueBtn(isSelected: true)
        updateContinueButton(isEnabled: true)
        TapticEngine.selection.feedback()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deSelected index", indexPath.row)
  
        let deSelectedCell = tableView.cellForRow(at: indexPath) as! TrainerTypeTableViewCell
        
        deSelectedCell.setSelectdBGCell(trainerData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: trainerData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: false)
    }
    
}

extension calendarFlow {

    var options: [TrainerOption] {

        switch self {
        case .gymMembership, .withTrainerMembership, .withoutTrainerMembership:
            return [
                TrainerOption(
                    type: .soloTraining,
                    normalImage: AppImages.soloUnselected,
                    selectedImage: AppImages.soloSelected
                ),
                TrainerOption(
                    type: .buddyTraining,
                    normalImage: AppImages.buddyUnselected,
                    selectedImage: AppImages.buddySelected
                ),
                TrainerOption(
                    type: .groupTraining,
                    normalImage: AppImages.groupUnselected,
                    selectedImage: AppImages.groupSelected
                )
            ]

        case .bookTrainerHomeWorkout,
             .bookTrainerGymWorkout,
             .createPackage,
             .defaultFlow:
            return [
                TrainerOption(
                    type: .homeWorkout,
                    normalImage: AppImages.homeUnselect,
                    selectedImage: AppImages.homeSelect,
                    title: "Home Workout",
                    subTitle: "Trainer comes at you"
                ),
                TrainerOption(
                    type: .gymWorkout,
                    normalImage: AppImages.gymUnselect,
                    selectedImage: AppImages.gymSelect,
                    title: "Gym Workout",
                    subTitle: "Train at a nearby gym"
                )
            ]
        }
    }

    var isMembershipFlow: Bool {
        switch self {
        case .gymMembership, .withTrainerMembership, .withoutTrainerMembership:
            return true
        default:
            return false
        }
    }
}

//MARK: -----------------EXTENSION FOR API
extension CreateTrainerViewController {
    
    private func getAddressListApi(){
        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print("getResultData", getResultData.data as Any)
            self.addressData?.removeAll()
            self.addressData?.append(contentsOf: getResultData.data ?? [])
        })
    }
    
    private func getPlansApi() {
        DashboardVM.getHomePagePlansApi(type: "2") { [weak self] result in
            guard let self = self else { return }
            
            if result?.status == true {
                self.userPlans = result?.data ?? []
            }
        }
    }
}
