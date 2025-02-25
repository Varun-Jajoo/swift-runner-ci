//
//  DailyInsightPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 14/02/25.
//

import UIKit

class DailyInsightPopupViewController: UIViewController {

    //MARK: ------------IBOUTLET
    @IBOutlet weak var popupMBV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        
        self.setupUI()
                
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.popupMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.preferredContentSize = CGSize(width: max(200, self.popupMBV.bounds.width*0.5), height: max(120, self.popupMBV.bounds.height))
        }
    }
    
}
