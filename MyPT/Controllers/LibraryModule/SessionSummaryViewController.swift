//
//  SessionSummaryViewController.swift
//  MyPT
//
//  Created by techsaga corp on 13/01/25.
//

import UIKit

class SessionSummaryViewController: CommonViewController {

    //MARK: ------------IBOUTLET
    @IBOutlet weak var playVideoMBV: UIView!
    @IBOutlet weak var bottomMBV: UIView!
    @IBOutlet weak var totalCountMBV: UIView!
    @IBOutlet weak var durationMBV: UIView!
    @IBOutlet weak var caloriesMBV: UIView!
    @IBOutlet weak var exercisesMBV: UIView!
    @IBOutlet weak var workoutMBV: UIView!
    @IBOutlet weak var shadowImgView: UIImageView!
    @IBOutlet weak var durationImgView: UIImageView!
    @IBOutlet weak var caloriesimgView: UIImageView!
    @IBOutlet weak var exercisesImgView: UIImageView!
    @IBOutlet weak var totalCountLbl: UILabel!
    @IBOutlet weak var workoutNameLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var durationTitleLbl: UILabel!
    @IBOutlet weak var caloriesLbl: UILabel!
    @IBOutlet weak var caloriesTitleLbl: UILabel!
    @IBOutlet weak var exercisesLbl: UILabel!
    @IBOutlet weak var exercisesTitleLbl: UILabel!
    @IBOutlet weak var workoutTitleLbl: UILabel!
    @IBOutlet weak var workoutTblView: UITableView!
    @IBOutlet weak var detailsBtn: UIButton!
    @IBOutlet weak var completeBtn: UIButton!
    @IBOutlet weak var workoutScrlView: UIScrollView!
    @IBOutlet weak var workoutTblViewHeightConstrnt: NSLayoutConstraint!
//    @IBOutlet weak var bottomMBVTopConstrnt: NSLayoutConstraint!
//    @IBOutlet weak var workoutLstMBV: UIStackView!
//    @IBOutlet weak var totalCountMBVTopConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupFont()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Explore Library"], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.totalCountMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
//            self.bottomMBV.addBlurView(viewShow: self.bottomMBV, alphBlur: 1.0, bgColor: UIColor.mainBg)
            
            self.detailsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.completeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            [self.durationMBV, self.caloriesMBV, self.exercisesMBV].forEach({
                $0.setCornerRadius(borderWidth: 0.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            })
            
            self.workoutMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 0.5, opacity: 0.4, offset: .zero, cornerRadius: 12.0)
            self.workoutMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.workoutMBV.backgroundColor = UIColor.clear
            
            //------------------Gradient
            
            [self.durationMBV,self.caloriesMBV,self.exercisesMBV].forEach({
                $0.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8))
            })
        }
    }
    
    func setupFont(){
       
        //----------------************
        self.totalCountLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.workoutNameLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.durationLbl.font = AppFont.medium.size(20.0, familyName: familyManrope)
        self.durationTitleLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.caloriesLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.caloriesTitleLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.exercisesLbl.font = AppFont.medium.size(20.0, familyName: familyClashDisplay)
        self.exercisesTitleLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.workoutTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.detailsBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.completeBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    

    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        if sender.tag == 801 {
            print("details btn clicked.")
        }else{
            print("complete btn clicked.")
            let vc:SessionCompleteViewController = SessionCompleteViewController.instantiate(appStoryboard: .library)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
}
