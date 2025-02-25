//
//  ScheduleWorkoutViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/12/24.
//

import UIKit

class ScheduleWorkoutViewController: CommonViewController {

    //MARK: ------------- VARIABLE
    var addExerciseData:[Any] = []
    
    //MARK: ------------- IBOIUTLET
    @IBOutlet weak var headerMBV: UIView!
    @IBOutlet weak var userDetailsMBV: UIView!
    @IBOutlet weak var userProfileImgView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var workoutNamelbl: UILabel!
    @IBOutlet weak var slotTimeLbl: UILabel!
    @IBOutlet weak var frequencyBtn: UIButton!
    @IBOutlet weak var notifyMeBtn: UIButton!
    @IBOutlet weak var durationMBV: UIView!
    @IBOutlet weak var caloriesMBV: UIView!
    @IBOutlet weak var exerciseMBV: UIView!
    @IBOutlet weak var durationImgView: UIImageView!
    @IBOutlet weak var durationTimeLbl: UILabel!
    @IBOutlet weak var durationTitleLbl: UILabel!
    @IBOutlet weak var caloriesImgView: UIImageView!
    @IBOutlet weak var caloriesCountLbl: UILabel!
    @IBOutlet weak var caloriesTitleLbl: UILabel!
    @IBOutlet weak var exercisesImgView: UIImageView!
    @IBOutlet weak var exercisesCountLbl: UILabel!
    @IBOutlet weak var exercisesTitleLbl: UILabel!
    @IBOutlet weak var addExerciseBtn: UIButton!
    @IBOutlet weak var addExerciseBtnHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var exerciseTblView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupFont()
        
        self.exerciseTblView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.schedule_Personal_Workout], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func saveBtnActn(_ sender: UIButton) {
        
        let vc:CalendarSecondaryViewController = CalendarSecondaryViewController.instantiate(appStoryboard: .calendar)
        self.navigationController?.pushViewController(vc, animated: true)
        
        //        let vc:EditExerciseViewController = EditExerciseViewController.instantiate(appStoryboard: .calendar)
        //        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MAARK: --------------- COMMON BTN ACTN
    enum btnTag:Int {
    case repsFreq = 401, notifyMe, addExercise
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        print("common btn actn..")
        
        switch sender.tag {
        case btnTag.repsFreq.rawValue:
            let vc:RepeatFrequencyPopupViewController = RepeatFrequencyPopupViewController.instantiate(appStoryboard: .calendar)
            vc.modalPresentationStyle = .automatic
            vc.navCtnl = self.navigationController
            self.navigationController?.present(vc, animated: false)
        case btnTag.notifyMe.rawValue:
            print("notify me")
            
            let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
            vc.modalPresentationStyle = .automatic
            vc.planFlowSetup = .remind
            self.navigationController?.present(vc, animated: true)
            
        case btnTag.addExercise.rawValue:
            print("Add exercise..")
            let vc:ChooseExerciseViewController = ChooseExerciseViewController.instantiate(appStoryboard: .calendar)
            vc.sentBackData = { [weak self] isData in
                
                guard let self = self else { return }
                
                if isData {
                    self.addExerciseBtnHeightConstrnt.constant = 90.0
                    self.addExerciseData = [1,2]
                    self.exerciseTblView.reloadData()
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            print("Default is called..")
        }
    }
    
    
    
    func setupUI(){
        DispatchQueue.main.async {
            self.userProfileImgView.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.txtDarkGray, cornerRadious: 8.0)
            
            self.frequencyBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.notifyMeBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.durationMBV.setCornerRadius(borderWidth:0 , borderColor: nil, cornerRadious: 12.0)
            self.caloriesMBV.setCornerRadius(borderWidth:0 , borderColor: nil, cornerRadious: 12.0)
            self.exerciseMBV.setCornerRadius(borderWidth:0 , borderColor: nil, cornerRadious: 12.0)
            
            self.caloriesMBV.setCornerRadius(borderWidth:0 , borderColor: nil, cornerRadious: 12.0)
          
            self.addExerciseBtn.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 16.0, dashPattern: [15,8])
            //rgba(49, 52, 58, 1)
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.durationMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8))
            
            self.caloriesMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8))
            self.exerciseMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8))
        }
    }
    
    func setupFont(){
        self.userNameLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.workoutNamelbl.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.slotTimeLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        self.frequencyBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.notifyMeBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.durationTimeLbl.font = AppFont.regular.size(20.0, familyName: familyClashDisplay)
        self.durationTitleLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.caloriesCountLbl.font = AppFont.regular.size(20.0, familyName: familyClashDisplay)
        self.caloriesTitleLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.exercisesCountLbl.font = AppFont.regular.size(20.0, familyName: familyClashDisplay)
        self.exercisesTitleLbl.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.addExerciseBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.saveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

}


extension ScheduleWorkoutViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addExerciseData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ExerciseTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
        
        cell.checkBtn.setImage(UIImage(named: "ic_moreSettings"), for: .normal)
//        cell.checkBtn.addTarget(self, action: #selector(cell.editBtnActn(sender:)), for: .touchUpInside)
        cell.navCtrl = self.navigationController
        
        cell.setupEditTarget()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected indexpath: ", indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return headerMBV
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
}
