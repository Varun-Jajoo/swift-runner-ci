//
//  RefundVC.swift
//  MyPT
//
//  Created by Manik Goel on 12/04/26.
//

import UIKit

class RefundVC: UIViewController {

    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDone: UILabel!
    @IBOutlet weak var lblDesp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
    }
    
    private func uiSetup() {
        DispatchQueue.main.async {
            self.lblHeading.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
            self.lblDone.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
            self.lblDesp.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
        }
    }

    @IBAction func ontapDismiss(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func iunderstand(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
