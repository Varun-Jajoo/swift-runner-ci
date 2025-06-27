//
//  UserPlanViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/06/25.
//

import UIKit

class UserPlanViewController: CommonViewController {

    
    @IBOutlet weak var planBckShadowImgView: UIImageView!
    @IBOutlet weak var userPlanImgView: UIImageView!
    @IBOutlet weak var userPlanNameLbl: UILabel!
    @IBOutlet weak var lineV: UIView!
    @IBOutlet weak var planDetailsMBV: UIStackView!
    @IBOutlet weak var validityMBV: UIView!
    @IBOutlet weak var validityLbl: UILabel!
    @IBOutlet weak var remainingSessionMBV: UIView!
    @IBOutlet weak var validityRemainingMBV: UIView!
    @IBOutlet weak var remainingSessionTitleLbl: UILabel!
    @IBOutlet weak var sessionLbl: UILabel!
    @IBOutlet weak var remainingSessionProgressMBV: UIView!
    @IBOutlet weak var validityRemainingTitleLbl: UILabel!
    @IBOutlet weak var validityDaysLbl: UILabel!
    @IBOutlet weak var validityProgressMBV: UIView!
    @IBOutlet weak var sessionNoteBtn: UIButton!
    @IBOutlet weak var upgradePlanBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        self.setupUI()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["My Plan"], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.notificationCount,AppImages.notification], setTitle: ["10",nil], setTintColor: nil, setTitleColor: UIColor.appWhite)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setPlanProgress()
    }
    
    @IBAction func upgradePlanBtnActn(_ sender: Any) {
        print("Upgrade plan btn actn..")
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.planDetailsMBV.setGradientMultiBorder(cornerRadius: 16.0, width: 1.0, colors: [UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), UIColor(red: 135.0/255.0, green: 143.0/255.0, blue: 160.0/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            
//            self.planDetailsMBV.setGradientMultiBorder(cornerRadius: 16.0, width: 1.0, colors: [UIColor.red, UIColor.green], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            self.lineV.backgroundColor = UIColor.clear
            self.lineV.addGradient(colors: [UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 0), UIColor.appWhite, UIColor.appWhite, UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 0)], locations: [0,0.3,0.7,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            
            self.sessionNoteBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), cornerRadious: 8.0)
            self.upgradePlanBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    private func setPlanProgress(){
        remainingSessionProgressMBV.drawLineProgress(progressfill: 0.5, fillLineColor: UIColor.appYellow, cornerRadius: 2.5)
        validityProgressMBV.drawLineProgress(progressfill: 0.65, fillLineColor: UIColor.appOuterProgress, cornerRadius: 2.5)
    }
    
    private func setupFont(){
        userPlanNameLbl.font = AppFont.semibold.size(32.0, familyName: familyClashDisplay)
        validityLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        [
            remainingSessionTitleLbl,
            validityRemainingTitleLbl
        ].forEach({[weak self]  in
            guard self != nil else { return }
            $0?.font = AppFont.medium.size(12.0, familyName: familyManrope)
        })
        
        [
            sessionLbl,
             validityDaysLbl
        ].forEach({[weak self]  in
            guard self != nil else { return }
            $0?.font = AppFont.semibold.size(18.0, familyName: familyClashDisplay)
        })
        sessionNoteBtn.titleLabel?.font = AppFont.regular.size(12.0, familyName: familyOverpassMono)
        upgradePlanBtn.titleLabel?.font = AppFont.bold.size(18.0, familyName: familyManrope)
        
    }
    
}
