//
//  ChooseBestPlanVC.swift
//  MyPT
//
//  Created by Manik Goel on 22/07/26.
//

import UIKit

class ChooseBestPlanVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bestPlansData: [BestPlanData]?
    var selectedPlanId: String?
    var onPlanSelected: ((BestPlanData) -> Void)?
    var isGymMembership: Bool = false
    private var selectedIndex: Int?
    
    @IBOutlet weak var lblChoosePlan: UILabel!
    @IBOutlet weak var tableChoosePlan: UITableView!
    @IBOutlet weak var btnChoosePlan: UIButton!
    @IBOutlet weak var viewAgreement: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedPlanId = selectedPlanId {
            selectedIndex = bestPlansData?.firstIndex(where: { $0.id == selectedPlanId })
        }
        
        uiSetup()
        btnChoosePlan.isEnabled = selectedIndex != nil
    }
    
    private func uiSetup() {
        tableChoosePlan.delegate = self
        tableChoosePlan.dataSource = self
        tableChoosePlan.register(
            UINib(nibName: "ChoosePlanTVCell", bundle: nil),
            forCellReuseIdentifier: "ChoosePlanTVCell"
        )
        
//        DispatchQueue.main.async {
        self.lblChoosePlan.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
//        }
    }
    
    @IBAction func onTapChoosePlan(_ sender: UIButton) {
        guard let index = selectedIndex, let plans = bestPlansData, index < plans.count else { return }
        let selectedPlan = plans[index]
        dismiss(animated: true) { [weak self] in
            self?.onPlanSelected?(selectedPlan)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bestPlansData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChoosePlanTVCell", for: indexPath) as? ChoosePlanTVCell else {
            return UITableViewCell()
        }
        cell.viewSessions.isHidden = isGymMembership
        if let plan = bestPlansData?[indexPath.row] {
            cell.configure(with: plan, isSelected: selectedIndex == indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        btnChoosePlan.isEnabled = true
        tableChoosePlan.reloadData()
    }
}
