//
//  SuccessfullyPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 21/12/24.
//

import UIKit

class SuccessfullyPopupViewController: UIViewController {
    
    //MARK: -------------VARIABLE
    var navCtrl:UINavigationController?
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var successfulMBV: UIView!
    @IBOutlet weak var successImgView: UIImageView!
    @IBOutlet weak var successTitleLbl: UILabel!
    @IBOutlet weak var successDescLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.successfulMBV.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.7, timingFunction: .easeInEaseOut)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    @IBAction func doneBtnActn(_ sender: Any) {
        print("done btn clicked....")
        self.dismiss(animated: true)
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.successfulMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.successfulMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.doneBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.successTitleLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.successDescLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.doneBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

}
