//
//  ActiveChallengeViewController.swift
//  MyPT
//
//  Created by techsaga corp on 15/01/25.
//

import UIKit

class ActiveChallengeViewController: CommonViewController {

    //MARK: --------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var workoutNameLbl: UILabel!
    @IBOutlet weak var workoutLogoImgView: UIImageView!
    @IBOutlet weak var workoutProgressMBV: UIView!
    @IBOutlet weak var workoutResumeBtn: UIButton!
    @IBOutlet weak var weeksBtn: UIButton!
    @IBOutlet weak var workoutsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupProgress()
        self.setupFont()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Active Challenge"], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.workoutResumeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.workoutNameLbl.font = AppFont.semibold.size(28.0, familyName: familyClashDisplay)
        self.weeksBtn.titleLabel?.font = AppFont.medium.size(16.0, familyName: familyManrope)
        self.workoutsBtn.titleLabel?.font = AppFont.medium.size(16.0, familyName: familyManrope)
        self.workoutResumeBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.weeksBtn.titleLabel?.numberOfLines = 2
        self.workoutsBtn.titleLabel?.numberOfLines = 2
    }
    
    func setupProgress(){
        
        let dualProgressView = DualRoundProgressView()
        DispatchQueue.main.async {
            dualProgressView.frame = self.workoutProgressMBV.bounds
            self.workoutProgressMBV.addSubview(dualProgressView)
        }
        
        dualProgressView.outerLineWidth = 20.0
        dualProgressView.innerLineWidth = 20.0
        dualProgressView.outerSpace = 10.0
        dualProgressView.outerCornerRadius = 51.94
        dualProgressView.innerCornerRadius = 51.94
        dualProgressView.outerColor = UIColor.appOuterProgress
        dualProgressView.innerColor = UIColor.appYellow
        dualProgressView.centerImage = UIImage(named: "ic_activeChallanges") // Replace with your image name
        dualProgressView.centerImageSize = CGSize(width: 160, height: 160)
        dualProgressView.imageCornerRadius = 37.61
        // Set initial progress
        dualProgressView.outerProgress = 0.5
        dualProgressView.innerProgress = 0.5
        dualProgressView.outerTrackColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1)
        dualProgressView.innerTrackColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1)
        //rgba(49, 52, 58, 1)
          
        // Animate progress after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dualProgressView.outerProgress = 0.8
            dualProgressView.innerProgress = 0.8
        }
    }

    @IBAction func workoutResumeBtnActn(_ sender: Any) {
        print("Resume btn clicked..")
        let vc:WorkoutDuringSessionViewController = WorkoutDuringSessionViewController.instantiate(appStoryboard: .library)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
