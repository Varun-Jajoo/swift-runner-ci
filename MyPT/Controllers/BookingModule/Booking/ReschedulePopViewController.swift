//
//  ReschedulePopViewController.swift
//  MyPT
//
//  Created by techsaga corp on 19/12/24.
//

import UIKit

class ReschedulePopViewController: UIViewController {
    
    //MARK: ------------- VARIABLE
    var rescheduleNavCtrl:UINavigationController?
    
    //MARK: --------------IBOUTEL
    @IBOutlet weak var reschedulePopupMBV: UIView!
    @IBOutlet weak var rescheduleTitleLbl: UILabel!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var rescheduleDescMBV: UIView!
    @IBOutlet weak var descTitleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var proceedToCancelBtn: UIButton!
    @IBOutlet weak var rescheduleBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
        self.setupFont()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        if sender.tag == 301 {
            print("cross btn actn..")
            self.dismiss(animated: true)
        }
        else if sender.tag == 302 {
            print("Proceed to cancel btn clicked..")
            self.dismiss(animated: true, completion: {
                let vc:FilterViewController = FilterViewController.instantiate(appStoryboard: .booking)
                vc.modalTransitionStyle = .coverVertical
                vc.flowUI = .cancellationReason
                vc.navFilterCtrl = self.rescheduleNavCtrl
                self.rescheduleNavCtrl?.present(vc, animated: true)
            })
            
        }else{
            print("Reschedule btn clicked ......")
        }
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.reschedulePopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.reschedulePopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
            self.rescheduleDescMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.proceedToCancelBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appRed, cornerRadious: 12.0)
            self.rescheduleBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.rescheduleTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.descTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.descLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.proceedToCancelBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.rescheduleBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

}
