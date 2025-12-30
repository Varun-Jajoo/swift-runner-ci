//
//  UserPlanViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/06/25.
//

import UIKit

class UserPlanViewController: CommonViewController {

    //MARK: -------------- VARIABLE
    var userPlanDetails: OtherSubscriptionsModel?
    
    let planColorMap: [String: [UIColor]] = [
        "Silver".uppercased(): [
            UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0),
            UIColor.appWhite,
            UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        ],
        "Gold".uppercased(): [
            UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),
            UIColor.appWhite.withAlphaComponent(0.7),
            UIColor(red: 173.0/255.0, green: 130.0/255.0, blue: 54.0/255.0, alpha: 1.0)
        ],
        "Platinum".uppercased(): [
            UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0),
            UIColor.appWhite,
            UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        ],
        "VIP".uppercased(): [
            UIColor(red: 188.0/255.0, green: 140.0/255.0, blue: 210.0/255.0, alpha: 1.0),
            UIColor.appWhite,
            UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),
            UIColor(red: 195.0/255.0, green: 139.0/255.0, blue: 221.0/255.0, alpha: 1.0)
        ]
    ]
    
    
    //MARK: --------------- IBOUTLET
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
    @IBOutlet weak var topUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        self.setupUI()
        self.setupInputData()
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
        self.setRighMenu(rightImgs: [AppImages.notificationCount,AppImages.notification], setTitle: ["",nil], setTintColor: nil, setTitleColor: UIColor.appWhite)
    }
    
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.setPlanProgress()
//    }
    
    @IBAction func upgradePlanBtnActn(_ sender: Any) {
        print("Upgrade plan btn actn..")
        let vc: TopUpgradeSessionViewController = TopUpgradeSessionViewController.instantiate(appStoryboard: .dashboard)
        vc.upgradeParams = UpgradePlanParamModel(type: "upgrade", sessions: userPlanDetails?.total_sessions?.value, id: userPlanDetails?.plan_id?.value, days: userPlanDetails?.total_days?.value)
        vc.planFlow = .upgrade
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func topupBtnActn(_ sender: Any) {
        print("Top up btn actn....")
        let vc: TopUpgradeSessionViewController = TopUpgradeSessionViewController.instantiate(appStoryboard: .dashboard)
        vc.upgradeParams = UpgradePlanParamModel(type: "topup", sessions: userPlanDetails?.total_sessions?.value, id: userPlanDetails?.plan_id?.value, days: userPlanDetails?.total_days?.value)
        vc.planFlow = .topUp
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func setupInputData(){
        self.upgradePlanBtn.isHidden = true
        self.userPlanImgView.loadImage(urlString: userPlanDetails?.tier_image, placeholder: nil, resize: CGSize(width: 100.0, height: 100.0))
//        self.userPlanNameLbl.text = (userPlanDetails?.getTier ?? "") + " Plan"
       
        if let planStr = userPlanDetails?.getTier, let planColor = self.planColorMap[planStr.uppercased()] {
            let combinedPlan = planStr + " Plan"
            self.userPlanNameLbl.attributedText = combinedPlan.attributedStringWithGradient(planColor, frame: self.userPlanNameLbl.bounds, font: AppFont.semibold.size(32.0, familyName: familyClashDisplay), startPoint: CGPoint(x: 0.5, y: 0), endPoint: CGPoint(x: 1, y: 0.5))
        }
        
        if let remainingSession = userPlanDetails?.remaining_sessions?.value, let totalSessions = userPlanDetails?.total_sessions?.value,  let remainingDays = userPlanDetails?.remaining_days?.value {
            self.sessionLbl.text = "\(remainingSession)/\(totalSessions) session"
//            self.sessionNoteBtn.setTitle(" \(remainingSession) Sessions remaining ending in \(remainingDays) days", for: .normal)
            
            if remainingSession != "0" {
                self.sessionNoteBtn.isHidden = false
                self.sessionNoteBtn.setTitle(" \(remainingSession) Sessions remaining ending in \(remainingDays) days", for: .normal)
            }else{
                self.sessionNoteBtn.isHidden = true
            }
        }
        
        if let remainingDays = userPlanDetails?.remaining_days?.value, let totalDays = userPlanDetails?.total_days?.value {
          self.validityDaysLbl.text = "\(remainingDays)/\(totalDays) days"
        }
        
        if let remainingSessions = userPlanDetails?.remaining_sessions?.value, let totalSessions = userPlanDetails?.total_sessions?.value {
            let progressRateSession = ((Double(remainingSessions) ?? 0.0) / (Double(totalSessions) ?? 0.0))
            DispatchQueue.main.async {
                self.remainingSessionProgressMBV.drawLineProgress(progressfill: progressRateSession, fillLineColor: UIColor.appWhite, cornerRadius: 3.0)
            }
        }
        
        if let remainingDays = userPlanDetails?.remaining_days?.value, let totalDays = userPlanDetails?.total_days?.value {
            let progressRateSession = ((Double(remainingDays) ?? 0.0) / (Double(totalDays) ?? 0.0))
            DispatchQueue.main.async {
                self.validityProgressMBV.drawLineProgress(progressfill: progressRateSession, fillLineColor: UIColor.appOuterProgress, cornerRadius: 2.5)
            }
        }
        
        if let isUpgrade = userPlanDetails?.isUpgrade, isUpgrade {
            self.upgradePlanBtn.isHidden = false
        }else{
            self.upgradePlanBtn.isHidden = true
        }
    }
    
//    private func setPlanProgress(){
//        remainingSessionProgressMBV.drawLineProgress(progressfill: 0.5, fillLineColor: UIColor.appYellow, cornerRadius: 2.5)
//        validityProgressMBV.drawLineProgress(progressfill: 0.65, fillLineColor: UIColor.appOuterProgress, cornerRadius: 2.5)
//    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.planDetailsMBV.setGradientMultiBorder(cornerRadius: 16.0, width: 1.0, colors: [UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), UIColor(red: 135.0/255.0, green: 143.0/255.0, blue: 160.0/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            
//            self.planDetailsMBV.setGradientMultiBorder(cornerRadius: 16.0, width: 1.0, colors: [UIColor.red, UIColor.green], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            self.lineV.backgroundColor = UIColor.clear
            self.lineV.addGradient(colors: [UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 0), UIColor.appWhite, UIColor.appWhite, UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 0)], locations: [0,0.3,0.7,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            
            self.sessionNoteBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), cornerRadious: 8.0)
            self.topUpBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.upgradePlanBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
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
        topUpBtn.titleLabel?.font = AppFont.bold.size(18.0, familyName: familyManrope)
        upgradePlanBtn.titleLabel?.font = AppFont.bold.size(18.0, familyName: familyManrope)
        
    }
    
}
