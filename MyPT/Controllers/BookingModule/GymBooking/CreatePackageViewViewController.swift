//
//  CreatePackageViewViewController.swift
//  MyPT
//
//  Created by techsaga corp on 29/11/24.
//

import UIKit
import Mixpanel

class CreatePackageViewViewController: CommonViewController {

    // MARK: --------------VARIABLE
    var packageData:[[String:Any]]?
    var createParams: CreatePackageParamsModel?
    var avialCalanderparams:AvailParmsModel?
    var packageType: String?
    var inputType:String?
    var inputLat:Double?
    var inputLong:Double?
    var inputParam: DetailsParam?
    
    // MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var packageList: UITableView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var lblBottom: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createParams?.package_type = "1"
        
        packageData = [
            ["title": "Solo Training",
            "subtitle": "1-on-1 focus and personal attention.",
            "titleImage": "soloIcon",
             "trainerImg": AppImages.soloUnselected as Any,
             "trainerImg_selected": AppImages.soloSelected as Any
            ],
            ["title": "Buddy Training",
             "subtitle": "Train together, stay accountable",
             "titleImage": "buddyIcon",
             "trainerImg":AppImages.buddyUnselected as Any,
             "trainerImg_selected":AppImages.buddySelected as Any
            ],
            ["title": "Group Training",
             "subtitle": "High energy, shared motivation",
             "titleImage": "groupIcon",
             "trainerImg":AppImages.groupUnselected as Any,
             "trainerImg_selected":AppImages.groupSelected as Any
            ]
        ]

        packageList.register(UINib(nibName: "TrainerTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerTypeTableViewCell")
//        self.continueBtn.isUserInteractionEnabled = false
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
        self.setupUI()
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
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.3)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //MARK: ---------- SET UI
    func setupUI() {
        DispatchQueue.main.async {
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //------------------************Font
    func setUpFont() {
        self.lblBottom.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("continue btn clicked..")
        var data = inputParam
        data?.package_type = packageType
        Mixpanel.mainInstance().track(
            event: inputType == "home" ? "HomePT_Service_Type_Selected" : "GymPT_Service_Type_Selected",
            properties: [
                "training_type": packageType == "1" ? "Solo" : packageType == "2" ? "Buddy" : "Group"
            ]
        )
        if packageType == "1" { // Solo
            let vc: ChoosePrimaryTrainerVC = ChoosePrimaryTrainerVC.instantiate(appStoryboard: .purchase)
            vc.packageType = packageType
            vc.inputType = inputType
            vc.inputLat = inputLat
            vc.inputLong = inputLong
            vc.inputParam = data
            self.navigationController?.pushViewController(vc, animated: true)
        } else if packageType == "2" { // Buddy
            let vc: AddBuddylViewController = AddBuddylViewController.instantiate(appStoryboard: .purchase)
            vc.packageType = packageType
            vc.inputType = inputType
            vc.inputLat = inputLat
            vc.inputLong = inputLong
            vc.inputParam = data
            self.navigationController?.pushViewController(vc, animated: true)
        } else { // Group
            let vc: AddBuddylViewController = AddBuddylViewController.instantiate(appStoryboard: .purchase)
            vc.packageType = packageType
            vc.inputType = inputType
            vc.inputLat = inputLat
            vc.inputLong = inputLong
            vc.isGroup = true
            vc.inputParam = data
            self.navigationController?.pushViewController(vc, animated: true)
            
//            let vc: AddMemberViewController = AddMemberViewController.instantiate(appStoryboard: .booking)
//            vc.getMemberParams = MemberParamsModel(package_type: "2", type: "home")
//            vc.createPackageParamsAddMember = self.createParams
////            vc.avialCalanderparamsAddMember = self.avialCalanderparams
//            self.navigationController?.pushViewController(vc, animated: true)
        }
       
//        if let  package_type = createParams?.package_type, package_type == "3" {
//            let vc: AddMemberViewController = AddMemberViewController.instantiate(appStoryboard: .booking)
//            vc.getMemberParams = MemberParamsModel(package_type: package_type, type: self.createParams?.type, trainer_id: self.createParams?.trainer_id, studio_id: self.createParams?.studio_id)
//            vc.createPackageParamsAddMember = self.createParams
//            vc.avialCalanderparamsAddMember = self.avialCalanderparams
//            self.navigationController?.pushViewController(vc, animated: true)
//        } else {
//            let vc:ChooseSessionViewController = ChooseSessionViewController.instantiate(appStoryboard: .booking)
//            vc.inputParams = self.createParams
//            vc.availParams = self.avialCalanderparams
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    // MARK: -------------- ENABLE CONTINUE
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
}

extension CreatePackageViewViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packageData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainerTypeTableViewCell = packageList.dequeueReusableCell(withIdentifier: "TrainerTypeTableViewCell", for: indexPath) as! TrainerTypeTableViewCell
        cell.titleLbl.isHidden = true
        cell.descLbl.isHidden = true
        cell.trainerImgView.isHidden = true
        
        cell.setSelectdBGCell(packageData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: packageData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        TapticEngine.selection.feedback()
        updateContinueButton(isEnabled: true)
        let selectedCell = tableView.cellForRow(at: indexPath) as! TrainerTypeTableViewCell
        packageType = "\(indexPath.row + 1)"
        createParams?.package_type = "\(indexPath.row + 1)"
        selectedCell.setSelectdBGCell(packageData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: packageData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath) as! TrainerTypeTableViewCell
        
        deSelectedCell.setSelectdBGCell(packageData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: packageData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: false)
    }
}
