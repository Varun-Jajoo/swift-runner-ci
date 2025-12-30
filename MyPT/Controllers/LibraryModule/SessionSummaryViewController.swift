//
//  SessionSummaryViewController.swift
//  MyPT
//
//  Created by techsaga corp on 13/01/25.
//

import UIKit

class SessionSummaryViewController: CommonViewController {
    
    //MARK: ----------- VARIABLE
    var workoutId: String?
    var WorkoutExerciseDetails: WorkoutExerciseModel?
    var workoutData: WorkoutDetailDataModel?
    //    var exercisesData:[WorkoutExerciseModel]? = []
    
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
        
        self.setupFont()
        self.setInputData()
        self.getWorkoutDetailsApi(id: workoutId, type: "")
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
    
    override func leftBtnActn(sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: WorkoutDetailsViewController.self)
    }
    
    private func setInputData(){
        
        self.workoutNameLbl.text = workoutData?.name?.value
        self.totalCountLbl.text = (workoutData?.exercisesCount?.value ?? "") + " Total"
        self.durationLbl.text = " "
        self.caloriesLbl.text = " "
        self.exercisesLbl.text = " "
        
        //-------------- gradient Labels
        if let timeSec = workoutData?.timeInSeconds?.value {
            self.durationLbl.attributedText = gradientAttr(labl: self.durationLbl, txtStr: timeSec + "s")
        }
        if let caloriesCount = workoutData?.calories?.value {
            self.caloriesLbl.attributedText = gradientAttr(labl: self.caloriesLbl, txtStr: caloriesCount)
        }
        if let exercisesCount = workoutData?.exercisesCount?.value {
            self.exercisesLbl.attributedText = gradientAttr(labl: self.exercisesLbl, txtStr: exercisesCount)
        }
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.totalCountMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            
            self.shadowImgView.addGradientImgV(colors: [
                UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.8),
                UIColor(red: 0/255.0, green: 3/255.0, blue: 1/255.0, alpha: 0),
                UIColor(red: 0/255.0, green: 5/255.0, blue: 2/255.0, alpha: 1)
            ], locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
            
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
            
            //            [self.durationMBV,self.caloriesMBV,self.exercisesMBV].forEach({
            //                $0.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8))
            //            })
            
            [self.durationMBV,self.caloriesMBV,self.exercisesMBV].forEach({
                $0.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
            })
        }
    }
    
    private func setupFont(){
        
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
    
    private func gradientAttr(labl: UILabel, txtStr: String, inputFont: UIFont? = AppFont.medium.size(20.0, familyName: familyClashDisplay)) -> NSAttributedString {
        let attStr = txtStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: labl.bounds, font: inputFont ?? UIFont(), startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        
        return attStr
    }
    
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        if sender.tag == 801 {
            print("details btn clicked.")
        }else{
            print("complete btn clicked.")
            WorkoutLibraryVM.workoutCompleteApi(inputSessionId: self.workoutData?.sessionID?.value, completion: {[weak self] getresultData in
                guard let self = self else { return }
                let vc:SessionCompleteViewController = SessionCompleteViewController.instantiate(appStoryboard: .library)
                vc.completeWorkoutData = getresultData?.data
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
            
            //            let vc:SessionCompleteViewController = SessionCompleteViewController.instantiate(appStoryboard: .library)
            //            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
}


//MARK: ------ EXTENSION FOR API
extension SessionSummaryViewController{
    
    private func getWorkoutDetailsApi(id: String?, type: String?){
        WorkoutLibraryVM.workoutDetailsApi(inputId: id, inputType: type, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            self.workoutData = nil
            self.workoutData = getResultData.data
            self.setInputData()
        })
    }
}
