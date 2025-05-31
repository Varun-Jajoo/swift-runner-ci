//
//  ProfileViewController.swift
//  MyPT
//
//  Created by techsaga corp on 15/05/25.
//

import UIKit

class ProfileViewController: CommonViewController {

    
    //MARK: ------------------ IBOUTLET
    @IBOutlet weak var profileHeaderImgView: UIImageView!
    @IBOutlet weak var profileFooterImgView: UIImageView!
    @IBOutlet weak var userNameMBV: UIView!
    @IBOutlet weak var userNameMBVTopConstrnt: NSLayoutConstraint!
    @IBOutlet weak var personalInfoMBV: UIView!
    @IBOutlet weak var planMBV: UIView!
    @IBOutlet weak var achievementsMBV: UIView!
    @IBOutlet weak var myTrainersMBV: UIView!
    @IBOutlet weak var healthPreferencesMBV: UIView!
    @IBOutlet weak var MyPTScoreMBV: UIView!
    @IBOutlet weak var awardsMBV: UIView!
    @IBOutlet weak var settingsMBV: UIView!
    @IBOutlet weak var supportsMBV: UIView!
    @IBOutlet weak var activityLogMBV: UIView!
    @IBOutlet weak var helpCenterMBV: UIView!
    @IBOutlet weak var motivationMBV: UIView!
    @IBOutlet weak var userProfileImgView: UIImageView!
    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var addressBtn: UIButton!
    @IBOutlet weak var memberBtn: UIButton!
    @IBOutlet weak var infoIconImgView: UIImageView!
    @IBOutlet weak var personalInfoLbl: UILabel!
    @IBOutlet weak var personalInfoBtn: UIButton!
    @IBOutlet weak var planLogoImg: UIImageView!
    @IBOutlet weak var planNameLbl: UILabel!
    @IBOutlet weak var planProgressView: UIView!
    @IBOutlet weak var planDetailsLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var achievementsTitleLbl: UILabel!
    @IBOutlet weak var myTainerTitleLbl: UILabel!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var updateNoteLbl: UILabel!
    @IBOutlet weak var versionBtn: UIButton!
    @IBOutlet weak var healthPreferencesTitleLbl: UILabel!
    @IBOutlet weak var healthPrefCollView: UICollectionView!
    @IBOutlet weak var myStoreTitleLbl: UILabel!
    @IBOutlet weak var awardsTitleLbl: UILabel!
    @IBOutlet weak var awardsBtn: UIButton!
    @IBOutlet weak var awardsCollView: UICollectionView!
    @IBOutlet weak var settingsImgView: UIImageView!
    @IBOutlet weak var settingsLbl: UILabel!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var helpCentreTitleLbl: UILabel!
    @IBOutlet weak var helpDescLbl: UILabel!
    @IBOutlet weak var activityLogLbl: UILabel!
    @IBOutlet weak var chstMsgImgView: UIImageView!
    @IBOutlet weak var msgCount: UILabel!
    @IBOutlet weak var notificationImgView: UIImageView!
    @IBOutlet weak var notificationsCountLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var motivationMsgView: UIView!
    @IBOutlet weak var motivationMsgLbl: UILabel!
    @IBOutlet weak var motivationWriterNameLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.topUserNameMBV()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.topUserNameMBV()
    }
    
    private func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [ "My " + AppStrings.profile], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.notificationCount,AppImages.notification], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func topUserNameMBV(){
        //---------------------- Navigationview
        if let navigationController = self.navigationController {
            let navBarHeight = navigationController.navigationBar.frame.height
            let topSafeArea = (self.view.safeAreaInsets.top + 20.0)
            let totalTopHeight = navBarHeight + topSafeArea
            self.userNameMBVTopConstrnt.constant = totalTopHeight
            
            self.userNameMBV.setNeedsLayout()
            self.userNameMBV.layoutIfNeeded()
        }
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            
            [
                self.personalInfoMBV,
                self.planMBV,
                self.achievementsMBV,
                self.myTrainersMBV,
                self.healthPreferencesMBV,
                self.MyPTScoreMBV,
                self.awardsMBV,
                self.settingsMBV,
                self.helpCenterMBV,
                self.activityLogMBV
            ].forEach({[weak self] in
                guard self != nil else { return }
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
            
            self.memberBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 4.0)
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.saveBtn.frame.size.height/2.0)
            self.memberBtn.addGradient(colors: [
                                                UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),
                                                UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),
                                                UIColor(red: 173.0/255.0, green: 130.0/255.0, blue: 54.0/255.0, alpha: 1.0)
                                               ], locations: [0,0.3,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 4.0)
            
            self.saveBtn.addGradient(colors: [UIColor(red: 29.0/255.0, green: 215.0/255.0, blue: 148.0/255.0, alpha: 1.0),UIColor(red: 9.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0), UIColor(red: 9.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0)], locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1), cornerRadius: self.saveBtn.frame.size.height/2.0)
            
            self.planProgressView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 3.0)
            self.planProgressView.drawLineProgress(progressfill: 0.2, fillLineColor: UIColor.appWhite, cornerRadius: 3.0)
            
            self.userProfileImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
            self.userProfileImgView.setGradientMultiBorder(cornerRadius: 16.0, width: 3.5, colors: [
                UIColor(red: 207.0/255.0, green: 171.0/255.0, blue: 104.0/255.0, alpha: 1.0),
                UIColor(red: 255.0/255.0, green: 241.0/255.0, blue: 216.0/255.0, alpha: 1.0),
                UIColor(red: 173.0/255.0, green: 130.0/255.0, blue: 54.0/255.0, alpha: 1.0)
               ], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 1, y: 1))
            
            //rgba(207, 171, 104, 1)
            //rgba(255, 241, 216, 1)
            //rgba(173, 130, 54, 1)
           
            //save
            //rgba(29, 215, 148, 1)
            //rgba(9, 46, 46, 1)
        }
    }
    
}
