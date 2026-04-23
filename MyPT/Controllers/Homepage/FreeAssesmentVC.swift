//
//  FreeAssesmentVC.swift
//  MyPT
//
//  Created by Manik Goel on 20/02/26.
//

import UIKit

class FreeAssesmentVC: UIViewController {

    
    @IBOutlet weak var lblFreeAssesment: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblFreeAssesment.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
    }
    
    @IBAction func onTapBackHome(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
        
    }
    
    @IBAction func ontapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
}
