//
//  TopPlanVC.swift
//  MyPT
//
//  Created by Manik Goel on 20/02/26.
//

import UIKit

enum PlanType {
    case topup
    case renew
    case upgrade
    case myTrainers
    case groupClasses
}

class TopPlanVC: UIViewController {

    var selectedPlanType: PlanType?
    
    @IBOutlet weak var imgTopupSession: UIImageView!
    @IBOutlet weak var lblMoreSession: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblMoreSession.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        configureUI()
    }
    
    private func configureUI() {
        switch selectedPlanType {
         case .topup:
             imgTopupSession.image = UIImage(named: "topUpPlan")
             lblMoreSession.text = "More Sessions\nMore Progress"
             
         case .renew:
             imgTopupSession.image = UIImage(named: "renewImage")
             lblMoreSession.text = "Renew your plan easily"
             
         case .upgrade:
             imgTopupSession.image = UIImage(named: "upgradeImage")
             lblMoreSession.text = "Upgrade your plan easily"
             
         default:
             break
         }
     }
    
    @IBAction func onTapback(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    @IBAction func ontapBackHome(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
