//
//  AssesmentDemoVC.swift
//  MyPT
//
//  Created by Manik Goel on 19/03/26.
//

import UIKit

class AssesmentDemoVC: CommonViewController {
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view1Heading: UILabel!
    @IBOutlet weak var view1Detail: UILabel!
    @IBOutlet weak var view2Heading: UILabel!
    @IBOutlet weak var view2Detail: UILabel!
    @IBOutlet weak var view3Heading: UILabel!
    @IBOutlet weak var view3Detail: UILabel!
    @IBOutlet weak var view4Heading: UILabel!
    @IBOutlet weak var view4Detail: UILabel!
    @IBOutlet weak var lblBottomCard: UILabel!
    @IBOutlet weak var lblDetailBottom: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view5Heading: UILabel!
    @IBOutlet weak var view5Detail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setNavUI()
    }
    
    func setNavUI() {
//        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
//        self.setProgress(0.3)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
    }
    
    private func setUpUI() {
        DispatchQueue.main.async {
            self.lblHeading.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
            self.lblDetail.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            [self.view1Heading, self.view2Heading, self.view3Heading,self.view4Heading, self.view5Heading] .forEach {
                $0?.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
            }
            [self.view1Detail, self.view2Detail, self.view3Detail,self.view4Detail, self.view5Detail] .forEach {
                $0?.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
            }
            [self.view1, self.view2, self.view3,self.view4, self.view5] .forEach {
                $0?.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1), cornerRadious: 8)
            }
            self.lblBottomCard.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
            self.lblDetailBottom.font = AppFont.regular.size(14.0, familyName: familyClashDisplay)
            
            self.btnStart.setTitle("CLAIM YOUR FREE ASSESSMENT  ", for: .normal)
            self.btnStart.setImage(UIImage(named: "blackArrowRight"), for: .normal)
            self.btnStart.semanticContentAttribute = .forceRightToLeft
            self.btnStart.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnStart.tintColor = .mainBg   // arrow color
            self.btnStart.backgroundColor = .appWhite
            self.btnStart.setTitleColor(.mainBg, for: .normal)
            self.btnStart.cornersWithBorder(radius: 8, corners: .allCorners)
        }
    }

    @IBAction func onTapBtnStart(_ sender: Any) {
        let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
        vc.isHomeOrGymSelected = true
        vc.isHomePreSelected = true
        vc.isFreeAssessmentSelected = true
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
