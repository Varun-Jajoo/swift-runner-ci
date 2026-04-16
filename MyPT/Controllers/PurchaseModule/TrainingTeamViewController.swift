//
//  TrainingTeamViewController.swift
//  SwiftUiDummy
//
//  Created by techsaga on 13/01/26.
//

import UIKit

enum TrainerSection: Int, CaseIterable {
    case primary
    case secondry
    
    var title: String {
        switch self {
        case.primary:
            return "Primary Trainers"
        case .secondry:
            return "Secondry Trainers"
        }
    }
}

class TrainingTeamViewController: CommonViewController, UITableViewDelegate,UITableViewDataSource {
    
    var trainerIdStr: String?
    var studioIdStr: String?
    var inputType: String?
    var package_type: String?
    private var primaryTrainer: AryTrainer?
    private var secondaryTrainers: [AryTrainer] = []
    var inputParam: DetailsParam?
    var fromHomeToGetgroupDetail: Bool = false
    var groupId: String?
    
    @IBOutlet var viewBckgrnd: UIView!
    @IBOutlet weak var viewTainer: UIView!
    @IBOutlet weak var imgTrainer: UIImageView!
    @IBOutlet weak var lblTrainingTeamReady: UILabel!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var tableviewPrimaryTrainer: UITableView!
    @IBOutlet weak var lblSecondryTrainer: UILabel!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var viewBottom: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setupUI()
//        loadData()
        if fromHomeToGetgroupDetail {
            getGroupDetailApi()
            viewBottom.isHidden = true
        } else {
            groupTrainerApi()
            viewBottom.isHidden = false
        }
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
//        self.setRighMenu(setTitle: [AppStrings.skipStr], setTintColor: .black, setTitleColor: UIColor.txtSkip)
    }
    
    private func uiSetup() {
        tableviewPrimaryTrainer.delegate = self
        tableviewPrimaryTrainer.dataSource = self
        tableviewPrimaryTrainer.register(UINib(nibName: "SecondryTrainerTableViewCell", bundle: nil),
                                         forCellReuseIdentifier: "SecondryTrainerTableViewCell")
        tableviewPrimaryTrainer.register(UINib(nibName: "PrimaryTrainerTableViewCell", bundle: nil),
                                         forCellReuseIdentifier: "PrimaryTrainerTableViewCell")
//        tableviewPrimaryTrainer.separatorStyle = .none
        tableviewPrimaryTrainer.rowHeight = UITableView.automaticDimension
        tableviewPrimaryTrainer.estimatedRowHeight = 140
        if #available(iOS 15.0, *) {
            tableviewPrimaryTrainer.sectionHeaderTopPadding = 0
        }
        
        self.lblTrainingTeamReady.font = AppFont.regular.size(10, familyName: familyFunnelSans)
        self.lblTeamName.font = AppFont.medium.size(32, familyName: familyClashDisplay)
        self.lblDetail.font = AppFont.regular.size(16, familyName: familyFunnelSans)
        self.lblDetail.font = AppFont.regular.size(14, familyName: familyFunnelSans)
        self.btnProceed.setTitle("PROCEED   ", for: .normal)
        self.btnProceed.setImage(UIImage(named: "blackArrowRight"), for: .normal)
        self.btnProceed.semanticContentAttribute = .forceRightToLeft
        self.btnProceed.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnProceed.tintColor = .mainBg   // arrow color
        self.btnProceed.backgroundColor = .appWhite
        self.btnProceed.setTitleColor(.mainBg, for: .normal)
    }
    
    private func setupUI() {
        self.btnProceed.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
    }
        
    private func groupTrainerApi() {

        let params: [String: String] = [
            "type": inputType ?? "home",
            "trainer_id": inputType == "home" ? trainerIdStr ?? "" : studioIdStr ?? ""
        ]

        PurchaseViewModel.groupTrainersApi(
            params: params,
            isShowLoader: true
        ) { [weak self] result in

            guard
                let self = self,
                let data = result?.data
            else { return }

            // Top section (Group info)
            self.lblTeamName.text = data.group?.name
            self.lblDetail.text = data.group?.description
            self.imgTrainer.loadImage(
                urlString: data.group?.image,
                placeholder: nil
            )

            // Trainers
            self.primaryTrainer = data.primaryTrainer
            self.secondaryTrainers = data.secondaryTrainers ?? []

            // Footer note
            self.lblSecondryTrainer.text = data.secondaryTrainersNote

            self.tableviewPrimaryTrainer.reloadData()
        }
    }
    
    private func getGroupDetailApi() {

        let params: [String: String] = [
            "group_id": groupId ?? "0"
        ]

        PurchaseViewModel.getGroupDetailApi(
            params: params,
            isShowLoader: true
        ) { [weak self] result in

            guard
                let self = self,
                let data = result?.data
            else { return }

            // Top section (Group info)
            self.lblTeamName.text = data.group?.name
            self.lblDetail.text = data.group?.description
            self.imgTrainer.loadImage(
                urlString: data.group?.image,
                placeholder: nil
            )

            // Trainers
            self.primaryTrainer = data.primaryTrainer
            self.secondaryTrainers = data.secondaryTrainers ?? []

            // Footer note
            self.lblSecondryTrainer.text = data.secondaryTrainersNote

            self.tableviewPrimaryTrainer.reloadData()
        }
    }

    
    @IBAction func onTapProceed(_ sender: UIButton) {
        let vc: PackagesVC = PackagesVC.instantiate(appStoryboard: .purchase)
        vc.trainerIdStr = trainerIdStr
        vc.studioIdStr = studioIdStr
        vc.inputType = self.inputType
        vc.package_type = self.package_type
        vc.inputParam = self.inputParam
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TrainerSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = TrainerSection(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .primary:
            return primaryTrainer == nil ? 0 : 1
        case .secondry:
            return secondaryTrainers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let sectionType = TrainerSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
            
        case .primary:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PrimaryTrainerTableViewCell", for: indexPath) as? PrimaryTrainerTableViewCell {
//                let trainer = primaryTrainers[indexPath.row]
//                //            cell.configure(lblTeamName: trainer.name, rating: trainer.rating, skills: trainer.skills)
//                cell.constCellWidth.constant = tableView.frame.width
                
                
                if let trainer = primaryTrainer {
                    cell.lblTrainerName.text = trainer.name
                    cell.lblRating.text = "\(trainer.rating ?? 0)"
                    cell.imgTrainer.loadImage(urlString: trainer.profile, placeholder: nil)

                    // tags → chips
                    cell.setCategories(trainer.tags ?? [])
                }
                cell.viewProfileBtn.accessibilityHint = self.primaryTrainer?.id
                cell.constCellWidth.constant = tableView.frame.width
                if !fromHomeToGetgroupDetail {
                    cell.viewProfileBtn.addTarget(self, action: #selector(viewProfileBtnActn(sender: )), for: .touchUpInside)
                }
                return cell
            }
            
        case .secondry:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SecondryTrainerTableViewCell", for: indexPath) as? SecondryTrainerTableViewCell {
//                
//                let trainer = secondryTrainers[indexPath.row]
//                cell.lblTrainerName.text = trainer.name
//                cell.lblRating.text = "\(trainer.rating)"
//                cell.constCellWidth.constant = tableView.frame.width
                let trainer = secondaryTrainers[indexPath.row]

                  cell.lblTrainerName.text = trainer.name
                  cell.lblRating.text = "\(trainer.rating ?? 0)"
                  cell.imgTrainer.loadImage(urlString: trainer.profile, placeholder: nil)
                  cell.btnS1TRainer.text = trainer.badge
                  cell.viewProfileBtn.accessibilityHint = self.secondaryTrainers[indexPath.row].id
                  // tags → chips
                  cell.setCategories(trainer.tags ?? [])

                  cell.constCellWidth.constant = tableView.frame.width
                if !fromHomeToGetgroupDetail {
                    cell.viewProfileBtn.addTarget(self, action: #selector(viewProfileBtnActn(sender: )), for: .touchUpInside)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - Section Headers
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionType = TrainerSection(rawValue: section) else { return nil }
        
        let header = UIView()
        header.backgroundColor = .clear
        
        let label = UILabel()
        label.text = sectionType.title
        label.textColor = .white
        label.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        label.textColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 0.75)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -12)
        ])
        
        return header
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = TrainerSection(rawValue: indexPath.section) else {
            return 120
        }
        
        switch section {
        case .primary:
//            return 114
            return 126
        case .secondry:
            return 126
        }
    }
    
    @objc func viewProfileBtnActn(sender:UIButton) {
        if sender.tag == 0 {
            let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
            var inputData = inputParam
            inputData?.trainer_id = self.primaryTrainer?.id
            vc.inputParam = inputData
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc:TrainerDescriptionViewController = TrainerDescriptionViewController.instantiate(appStoryboard: .booking)
            let getIndx = self.secondaryTrainers.firstIndex(where: {
                $0.id == (sender.accessibilityHint ?? "0")
            })
            var inputData = inputParam
            inputData?.trainer_id = self.secondaryTrainers[getIndx ?? 0].id
            vc.inputParam = inputData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


struct Trainer {
    let name: String
    let rating: Double
    let skills: [String]
    let isPrimary: Bool
}

struct GroupTrainerParam {
    var type: String?
    var id: String?
    
    func getParams() -> [String:Any] {
        var dictVar: [String:Any] =  [:]
        
        if let type = type { dictVar["type"] = type }
        if let id = id { dictVar["id"] = id }
        
        return dictVar
    }
}

