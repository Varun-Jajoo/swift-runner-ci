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

class TrainingTeamViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    private var primaryTrainers: [Trainer] = []
    private var secondryTrainers: [Trainer] = []
    
    @IBOutlet var viewBckgrnd: UIView!
    @IBOutlet weak var viewTainer: UIView!
    @IBOutlet weak var imgTrainer: UIImageView!
    @IBOutlet weak var lblTrainingTeamReady: UILabel!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var tableviewPrimaryTrainer: UITableView!
    @IBOutlet weak var lblSecondryTrainer: UILabel!
    @IBOutlet weak var btnProceed: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        loadData()
    }
    
    private func uiSetup() {
        tableviewPrimaryTrainer.register(UINib(nibName: "SecondryTrainerTableViewCell", bundle: nil),
                                         forCellReuseIdentifier: "SecondryTrainerTableViewCell")
        tableviewPrimaryTrainer.register(UINib(nibName: "PrimaryTrainerTableViewCell", bundle: nil),
                                         forCellReuseIdentifier: "PrimaryTrainerTableViewCell")
        tableviewPrimaryTrainer.delegate = self
        tableviewPrimaryTrainer.dataSource = self
//        tableviewPrimaryTrainer.separatorStyle = .none
        tableviewPrimaryTrainer.rowHeight = UITableView.automaticDimension
        tableviewPrimaryTrainer.estimatedRowHeight = 140
        if #available(iOS 15.0, *) {
            tableviewPrimaryTrainer.sectionHeaderTopPadding = 0
        }
    }
    
    private func loadData() {
        // Simulating API
        let all = [
            Trainer(name: "Ruby John", rating: 4.2, skills: ["Crossfit","Yoga"], isPrimary: true),
            Trainer(name: "Iqra Shehzadi", rating: 4.2, skills: ["Crossfit","Yoga"], isPrimary: false),
            Trainer(name: "Ejila Zeme", rating: 4.2, skills: ["Crossfit","Yoga"], isPrimary: false),
        ]
        
        primaryTrainers = all.filter { $0.isPrimary }
        secondryTrainers = all.filter { !$0.isPrimary }
        //        lblSecondryTrainer.text = "Secondary Trainers (\(secondryTrainers.count))"
        
        tableviewPrimaryTrainer.reloadData()
    }
    
    @IBAction func onTapProceed(_ sender: UIButton) {
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TrainerSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = TrainerSection(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .primary:
            return primaryTrainers.count
        case .secondry:
            return secondryTrainers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let sectionType = TrainerSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
            
        case .primary:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PrimaryTrainerTableViewCell", for: indexPath) as? PrimaryTrainerTableViewCell {
                let trainer = primaryTrainers[indexPath.row]
                //            cell.configure(lblTeamName: trainer.name, rating: trainer.rating, skills: trainer.skills)
                return cell
            }
            
        case .secondry:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SecondryTrainerTableViewCell", for: indexPath) as? SecondryTrainerTableViewCell {
                
                let trainer = secondryTrainers[indexPath.row]
                cell.lblTrainerName.text = trainer.name
                cell.lblRating.text = "\(trainer.rating)"
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
        header.backgroundColor = .black
        
        let label = UILabel()
        label.text = sectionType.title
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8)
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
            return 114
        case .secondry:
            return 114
        }
    }
}


struct Trainer {
    let name: String
    let rating: Double
    let skills: [String]
    let isPrimary: Bool
}

