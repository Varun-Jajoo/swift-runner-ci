//
//  BadgeEarnedViewController.swift
//  MyPT
//
//  Created by techsaga corp on 15/01/25.
//

import UIKit

class BadgeEarnedViewController: CommonViewController {

    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var badgeEarnedMBV: UIView!
    @IBOutlet weak var leftPodiumImgView: UIImageView!
    @IBOutlet weak var rightPodiumImgView: UIImageView!
    @IBOutlet weak var maxSetsImgView: UIImageView!
    @IBOutlet weak var badgeEarnedTitleLbl: UILabel!
    @IBOutlet weak var earnedDateTitleLbl: UILabel!
    @IBOutlet weak var maxSetsTitleLbl: UILabel!
    @IBOutlet weak var dayStreakTitleLbl: UILabel!
//    @IBOutlet weak var calendarMBV: UIView!
    @IBOutlet weak var calendarDayStreakMBV: UIView!
    @IBOutlet weak var sunSubMBV: UIView!
    @IBOutlet weak var monSubMBV: UIView!
    @IBOutlet weak var tuesSubMBV: UIView!
    @IBOutlet weak var wedSubMBV: UIView!
    @IBOutlet weak var thuSubMBV: UIView!
    @IBOutlet weak var friSubMBV: UIView!
    @IBOutlet weak var satSubMBV: UIView!
    @IBOutlet weak var sunImgView: UIImageView!
    @IBOutlet weak var monImgView: UIImageView!
    @IBOutlet weak var tuesImgView: UIImageView!
    @IBOutlet weak var wedImgView: UIImageView!
    @IBOutlet weak var thuImgView: UIImageView!
    @IBOutlet weak var friImgView: UIImageView!
    @IBOutlet weak var satImgView: UIImageView!
    @IBOutlet weak var sunTitleLbl: UILabel!
    @IBOutlet weak var monTitleLbl: UILabel!
    @IBOutlet weak var tuesTitleLbl: UILabel!
    @IBOutlet weak var wedTitleLbl: UILabel!
    @IBOutlet weak var thuTitleLbl: UILabel!
    @IBOutlet weak var friTitleLbl: UILabel!
    @IBOutlet weak var satTitleLbl: UILabel!
    @IBOutlet weak var sunCountLbl: UILabel!
    @IBOutlet weak var monCountLbl: UILabel!
    @IBOutlet weak var tuesCountLbl: UILabel!
    @IBOutlet weak var wedCountLbl: UILabel!
    @IBOutlet weak var thuCountLbl: UILabel!
    @IBOutlet weak var friCountLbl: UILabel!
    @IBOutlet weak var satCountLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var dayStreakNoteLbl: UILabel!
    @IBOutlet weak var shareAchievementBtn: UIButton!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupFont()
        self.setupAnimation()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.session_Summary], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    override func leftBtnActn(sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: LibraryViewController.self)
    }
    
    @IBAction func shareAchievementBtnActn(_ sender: Any) {
        
        Utility.shared.shareSocial(viewController: self, textToShare: "Share to social", imageToShare: AppImages.navLeft ?? UIImage(), urlShareStr: "https://www.google.com/")
    }
    
    func setupAnimation(){
        self.badgeEarnedMBV.animShow(duration: 0.7, delay: 0.1) {
            print("anomation done..")
        }
        
        self.earnedDateTitleLbl.animShow(duration: 0.1, delay: 0.7) {
            print("anomation done..")
        }
        self.maxSetsTitleLbl.animShow(duration: 0.1, delay: 0.7) {
            print("anomation done..")
        }
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.calendarDayStreakMBV.backgroundColor = UIColor.appCard2
            self.calendarDayStreakMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            self.calendarDayStreakMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0), cornerRadius: 20)
           
            self.calendarDayStreakMBV.setGradientBorder(cornerRadious:20.0,width: 2.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
            [self.sunSubMBV,
             self.monSubMBV,
             self.tuesSubMBV,
             self.wedSubMBV,
             self.thuSubMBV,
             self.friSubMBV,
             self.satSubMBV].forEach({
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 9.0)
            })
            
            self.shareAchievementBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.badgeEarnedTitleLbl.font = AppFont.semibold.size(32.0, familyName: familyClashDisplay)
        self.earnedDateTitleLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.maxSetsTitleLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
    }

}
