//
//  ReviewRateViewController.swift
//  MyPT
//
//  Created by techsaga corp on 21/12/24.
//

import UIKit
import Cosmos
import IQTextView

class ReviewRatePopupViewController: UIViewController {
    
    //MARK: -------------VARIABLE
    var navCtrl:UINavigationController?
    
    //MARK: ---------------IBOUTLET
    @IBOutlet weak var reviewMBV: UIView!
    @IBOutlet weak var rateTitleLbl: UILabel!
    @IBOutlet weak var rateTopDescLbl: UILabel!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var fineLbl: UILabel!
    @IBOutlet weak var feedbackTitleLbl: UILabel!
    
    @IBOutlet weak var feedDescTxtView: IQTextView!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupFont()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }

    @IBAction func submitBtnAct(_ sender: UIButton) {
        print("submit btn clicked.........")
        self.dismiss(animated: false, completion: {
            print("completion is called....")
            let vc:SuccessfullyPopupViewController = SuccessfullyPopupViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            vc.navCtrl = self.navigationController
            self.navCtrl?.present(vc, animated: true)
        })
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.reviewMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.reviewMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
            self.feedDescTxtView.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.feedDescTxtView.contentInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
            self.submitBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
//            self.submitBtn.addGradient(colors: [.red,.yellow, .blue], locations: [0,0.5,1.0], startPoint: CGPoint(x: 0.0, y: 1.0), endPoint: CGPoint(x: 1.0, y: 1.0))
        }
    }
    
    func setupFont(){
        self.rateTitleLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.rateTopDescLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.fineLbl.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.feedbackTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.feedDescTxtView.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.submitBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
}
