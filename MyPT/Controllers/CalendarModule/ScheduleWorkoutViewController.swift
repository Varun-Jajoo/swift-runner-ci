//
//  ScheduleWorkoutViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/12/24.
//

import UIKit

class ScheduleWorkoutViewController: CommonViewController {
    
    //MARK: ------------- VARIABLE
    var workoutIdStr: String?
    var noteData:[String]?
    private var getWorkoutData: SupersetWorkoutModelAPI?
    var exerciseData:[ExercisesDatailsModel]? = [] {
        didSet{
            if (self.exerciseData?.count ?? 0) < 1 {
                self.saveBtn.isHidden = true
            }
            else{
                self.saveBtn.isHidden = false
            }
        }
    }
    
    var startDateTimeStr: String?
    private var reminderTime: RemindWorkoutDataModel? = nil
    private var weekDaysFreq: String? = nil
    private var endDateStr: String? = nil
    private var localDaysFreq: [String]? = []
    private var createWorkoutParam: RegularWorkoutModel? = RegularWorkoutModel()
    
//    {
//        didSet{
//            print("createWorkoutParam: ", createWorkoutParam as Any)
//        }
//    }
    
    private var addExerciseData: [ExerciseModel]? = []
    
    //MARK: ------------- IBOIUTLET
    @IBOutlet weak var headerUserMBV: UIView!
    @IBOutlet weak var userDetailsMBV: UIView!
    @IBOutlet weak var tutorialNoteMBV: UIView!
    @IBOutlet weak var userProfileImgView: UIImageView!
    @IBOutlet weak var workoutNameTitleLbl: UILabel!
    @IBOutlet weak var workoutNameTxtField: UITextField!
    @IBOutlet weak var slotTimeLbl: UILabel!
    @IBOutlet weak var slotTimeBtn: UIButton!
    @IBOutlet weak var workoutTypeBtn: UIButton!
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
    @IBOutlet weak var noteTitleLbl: UILabel!
    @IBOutlet weak var addExerciseBtn: UIButton!
    @IBOutlet weak var addExerciseBtnHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var exerciseTblView: UITableView!
    @IBOutlet weak var exerciseTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var noteTutorialTblView: UITableView!
    @IBOutlet weak var noteTutorialTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.workoutNameTxtField.delegate = self
       
        /*
         noteData = [
         "Add exercies",
         "Create a superset, and choose form the added exercies",
         "Define number of sets for each superset",
         "Add rest period"
         ]
         */
        self.tutorialNoteMBV.isHidden = true
        
        self.workoutTypeBtn.isHidden = true
        self.setupFont()
        self.saveBtn.isHidden = true
        self.exerciseTblView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
        self.noteTutorialTblView.register(UINib(nibName: "NoteDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteDescTableViewCell")
        //        self.noteTutorialTblView.sectionFooterHeight = 0.01
        //        self.noteTutorialTblView.sectionHeaderHeight = 0.01
        self.setInputData()
        
        
        //------------------Api
        if let workoutIdStr = workoutIdStr, !workoutIdStr.isEmpty {
            self.getCreatedWorkouts(inputWorkId: workoutIdStr)
        }
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
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
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        print("notification", notification)
        self.customBlurViewRemove(viewShow: self.view)
    }
    
    private func setInputData(){
        slotTimeLbl.text = startDateTimeStr
//        self.slotTimeBtn.setTitle(startDateTimeStr, for: .normal)
        durationTimeLbl.text = "0"
        caloriesCountLbl.text = "0"
        exercisesCountLbl.text = "0"
        
        //-----------------------------############
        self.workoutNameTxtField.text = getWorkoutData?.name?.value
        self.workoutTypeBtn.setTitle(getWorkoutData?.type?.value, for: .normal)
//        self.durationTimeLbl.text = getWorkoutData?.repeatDuration?.value ?? "0"
//        self.caloriesCountLbl.text = getWorkoutData?.calories?.value ?? "0"
//        self.exercisesCountLbl.text = getWorkoutData?.totalExercise?.value ?? "0"
        
        if let _ = getWorkoutData?.repeatDuration?.value {
//            self.durationTimeLbl.attributedText = repeatDurationStr.gradientAttr(labl: self.durationTimeLbl, txtStr: repeatDurationStr)
            
            let exercisesDurationsFilter = getWorkoutData?.exercises?.filter({ $0.type?.value != "rest" })
            let totalDurations = exercisesDurationsFilter?
                .compactMap { Int($0.duration?.value ?? "0") }
                .reduce(0, +)
            
//            let totalDurations = getWorkoutData?.exercises?
//                .compactMap { Int($0.duration?.value ?? "0") }
//                .reduce(0, +)
            
            self.durationTimeLbl.attributedText = "\(totalDurations ?? 0)s".gradientAttr(labl: self.durationTimeLbl, txtStr: "\(totalDurations ?? 0)s")
        }else{
            self.durationTimeLbl.attributedText = "0s".gradientAttr(labl: self.durationTimeLbl, txtStr: "0s")
        }
        
        if let caloriesStr = getWorkoutData?.calories?.value {
            self.caloriesCountLbl.attributedText = caloriesStr.gradientAttr(labl: self.caloriesCountLbl, txtStr: caloriesStr)
        }else{
            self.caloriesCountLbl.attributedText = "0".gradientAttr(labl: self.caloriesCountLbl, txtStr: "0")
        }
        
        if let totalExerciseStr = getWorkoutData?.totalExercise?.value {
            self.exercisesCountLbl.attributedText = totalExerciseStr.gradientAttr(labl: self.exercisesCountLbl, txtStr: totalExerciseStr)
        }else{
            self.exercisesCountLbl.attributedText = "0".gradientAttr(labl: self.exercisesCountLbl, txtStr: "0")
        }
    
        if let getStartDate = getWorkoutData?.startDate?.value , let getTime = getWorkoutData?.time?.value {
            let startDate = DateFormatterHelper.shared.getDateFromFormat(fromDate: getStartDate, fromFormat: "yyy-MM-dd", toFormat: "dd-MM-yyy") ?? ""
            self.slotTimeLbl.text = startDate + ", " + getTime
          
            self.startDateTimeStr = startDate + ", " + getTime
//            self.slotTimeBtn.setTitle(startDateTimeStr, for: .normal)
        }
        
        self.weekDaysFreq = getWorkoutData?.repeatDuration?.value
        self.endDateStr = DateFormatterHelper.shared.getDateFromFormat(fromDate: getWorkoutData?.endDate?.value ?? "", fromFormat: "yyy-MM-dd", toFormat: "dd-MM-yyy")
        self.localDaysFreq = getWorkoutData?.repeatDays?.value?.components(separatedBy: ",")
        
        let reminerModel:RemindWorkoutDataModel = RemindWorkoutDataModel(id: FlexibleValue(value: getWorkoutData?.remindMe?.value), remind_time: nil, time: nil)
        self.reminderTime = reminerModel
        
        //-------------- when perform editing
        if let getWorkoutId = self.getWorkoutData?.workoutId?.value, !getWorkoutId.isEmpty {
            self.addExerciseBtnHeightConstrnt.constant = 90.0
        }
    }
    
    
    @IBAction func editDateTimeBtnActn(_ sender: Any) {

        let vc:TimeSlotPopupViewController = TimeSlotPopupViewController.instantiate(appStoryboard: .calendar)
        vc.modalPresentationStyle = .automatic
        vc.navCtrl = self.navigationController
      
        vc.isUpdateTime = true
        vc.timePopFlow = .regularWorkout
        vc.sentBackDateTime = {[weak self] getDateTime in
            guard let self = self else { return }
            self.slotTimeLbl.text = getDateTime
            self.startDateTimeStr = getDateTime
//            self.slotTimeBtn.setTitle(startDateTimeStr, for: .normal)
        }
        
        vc.selectedDate = DateFormatterHelper.shared.dateFromString(from: self.startDateTimeStr ?? "", format: "dd-MM-yyyy, hh:mm a")
        
        self.navigationController?.present(vc, animated: false)
    }
    
    
    
    @IBAction func saveBtnActn(_ sender: UIButton) {
//        let repeateDays: String = self.localDaysFreq?.joined(separator: ",") ?? ""
  
        if let getWorkoutId = self.getWorkoutData?.workoutId?.value, let inputWorkoutId = Int(getWorkoutId) {
            self.createWorkoutParam?.id = inputWorkoutId
        }
        
        self.createWorkoutParam?.name = self.workoutNameTxtField.text
        self.createWorkoutParam?.category_id = 1
        self.createWorkoutParam?.type = "regular"
        self.createWorkoutParam?.remind_me = self.reminderTime?.id?.value
        self.createWorkoutParam?.repeat_duration = Int(self.weekDaysFreq ?? "1")
        self.createWorkoutParam?.repeat_days = self.localDaysFreq?.joined(separator: ",") ?? " "
        self.createWorkoutParam?.start_date = DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "yyy-MM-dd")
        self.createWorkoutParam?.end_date = self.endDateStr
        self.createWorkoutParam?.time = DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "hh:mm a")
        self.createWorkoutParam?.rest_status = false
        
        addExerciseData?.removeAll()
        if let exerciseData = exerciseData {
            for item in exerciseData {
                var getExerData = ExerciseModel()
                getExerData.id = Int(item.id?.value ?? "0")
                getExerData.type = "exercise"
                getExerData.sets = 3
//                getExerData.reps = Int(item.reps?.value ?? "0")
                
                if let reps = item.reps?.value, !reps.isEmpty {
                    getExerData.reps = Int(item.reps?.value ?? "")
                }else{
                    getExerData.reps = Int(item.raps?.value ?? "")
                }
                
                getExerData.rest_duration = 30
                getExerData.time_type = 2
                // Append the new object
                addExerciseData?.append(getExerData)
            }
        }
        createWorkoutParam?.exercises?.removeAll()
        createWorkoutParam?.exercises = addExerciseData
        
        if isValid() {
            WorkoutLibraryVM.createWorkoutApi(inputWorkout: createWorkoutParam, completion: {[weak self] gteResultData in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            })
            
            //            let vc:CalendarSecondaryViewController = CalendarSecondaryViewController.instantiate(appStoryboard: .calendar)
            //            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        /* ------------ only for Testing
         let vc:CalendarSecondaryViewController = CalendarSecondaryViewController.instantiate(appStoryboard: .calendar)
         self.navigationController?.pushViewController(vc, animated: true)
         */
        
        //        let vc:EditExerciseViewController = EditExerciseViewController.instantiate(appStoryboard: .calendar)
        //        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func isValid() -> Bool{
        if (workoutNameTxtField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ?? true {
            self.workoutNameTxtField.becomeFirstResponder()
            AlertHelper.shared.showCustomeAlert(message: "Please enter workout name.",actions: ["Ok"])
            return false
        }
        else if startDateTimeStr?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true{
            AlertHelper.shared.showCustomeAlert(message: "Please enter start date and time.",actions: ["Ok"])
            return false
        }
        else if (localDaysFreq?.isEmpty ?? true) || (localDaysFreq?.count ?? 0) < 0{
            AlertHelper.shared.showCustomeAlert(message: "Please select days from Reps Frequency.",actions: ["Ok"])
            return false
        }
        else if reminderTime?.id?.value?.isEmpty ?? true{
            AlertHelper.shared.showCustomeAlert(message: "Please select Notify me.",actions: ["Ok"])
            return false
        }
        else if (exerciseData?.isEmpty ?? true) || (exerciseData?.count ?? 0) < 0{
            AlertHelper.shared.showCustomeAlert(message: "Please add exercise",actions: ["Ok"])
            return false
        }
        
        //        else if (dateStr?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
        //            AlertHelper.shared.showCustomeAlert(message: "Please select date from Reps Frequency.",actions: ["Ok"])
        //        return false
        //        }
        
        return true
        
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
            vc.selectedDate = startDateTimeStr
            vc.sentBackData = {[weak self] weekDays, days, dateStr in
                guard let self = self else { return  }
                print("weekDays: ", weekDays as Any, "days: ", days as Any, "dateStr: ", dateStr as Any)
                self.weekDaysFreq = weekDays
                self.endDateStr = (dateStr == "No" ? nil : dateStr)
                self.localDaysFreq = days
            }
            
            if let weekDaysFreq = weekDaysFreq {
                vc.weekDaysFreq = self.weekDaysFreq
            }
            if let endDateStr = endDateStr {
                vc.dateStr = endDateStr
            }
            if let localDaysFreq = localDaysFreq {
                vc.localDaysFreq = localDaysFreq
            }
            
            self.navigationController?.present(vc, animated: false)
        case btnTag.notifyMe.rawValue:
            print("notify me")
            let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
            vc.modalPresentationStyle = .automatic
            vc.planFlowSetup = .remind
            vc.sentReminderTimeData = {[weak self] getSelectedTime in
                guard let self = self, let getSelectedTime = getSelectedTime else { return  }
                print("getSelectedTime: ", getSelectedTime)
                self.reminderTime = getSelectedTime
            }
            vc.selectedTime = self.reminderTime
            self.navigationController?.present(vc, animated: true)
            
        case btnTag.addExercise.rawValue:
            print("Add exercise..")
            //            var addExerciseData:ExerciseModel?
            
            let vc:ChooseExerciseViewController = ChooseExerciseViewController.instantiate(appStoryboard: .calendar)
            vc.sentExerciseData = { [weak self] getData in
                
                guard let self = self , let getData = getData else { return }
                
                if getData.count > 0 {
                    self.addExerciseBtnHeightConstrnt.constant = 90.0
                    self.exerciseData?.removeAll()
                    self.exerciseData?.append(contentsOf: getData)
                    self.exerciseTblView.reloadData()
                    
                    //---------------------***********
                    self.exercisesCountLbl.text = "\(self.exerciseData?.count ?? 0)"
                    let totalCalories = exerciseData?
                        .compactMap { Int($0.calories?.value ?? "0") }
                        .reduce(0, +)
                    self.caloriesCountLbl.text = "\(totalCalories ?? 0)"
                    
                    let exercisesDurationsFilter = self.exerciseData?.filter({ $0.type?.value != "rest" })
                    let totalDurations = exercisesDurationsFilter?
                        .compactMap { Int($0.duration?.value ?? "0") }
                        .reduce(0, +)
                    self.durationTimeLbl.attributedText = "\(totalDurations ?? 0)s".gradientAttr(labl: self.durationTimeLbl, txtStr: "\(totalDurations ?? 0)s")
                }
            }
            
            if let exerciseData = self.exerciseData {
                vc.selectedExerciseData?.removeAll()
                vc.selectedExerciseData = exerciseData
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            print("Default is called..")
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if exerciseTblView.contentSize.height != 0 {
            self.exerciseTblViewHeightConstrnt.constant = exerciseTblView.contentSize.height
        }
        
        if noteTutorialTblView.contentSize.height != 0 {
            self.noteTutorialTblViewHeightConstrnt.constant = noteTutorialTblView.contentSize.height
        }
        
        view.layoutIfNeeded()
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.userProfileImgView.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.txtDarkGray, cornerRadious: 8.0)
            self.workoutTypeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.workoutTypeBtn.frame.height/2.0)
            self.frequencyBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.notifyMeBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.durationMBV.setCornerRadius(borderWidth:0 , borderColor: nil, cornerRadious: 12.0)
            self.caloriesMBV.setCornerRadius(borderWidth:0 , borderColor: nil, cornerRadious: 12.0)
            self.exerciseMBV.setCornerRadius(borderWidth:0 , borderColor: nil, cornerRadious: 12.0)
            
            self.caloriesMBV.setCornerRadius(borderWidth:0 , borderColor: nil, cornerRadious: 12.0)
            
            self.addExerciseBtn.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 16.0, dashPattern: [15,8])
            //rgba(49, 52, 58, 1)
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.tutorialNoteMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            /*
             self.durationMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8))
             
             self.caloriesMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8))
             self.exerciseMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 1.0, y: 0.8))
             */
            
            //------------------Gradient
            [self.durationMBV,self.caloriesMBV,self.exerciseMBV].forEach({
                $0.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
            })
        }
    }
    
    private func setupFont(){
        self.workoutNameTitleLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.workoutTypeBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.workoutNameTxtField.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.workoutNameTxtField.setPlaceholder(text: "Eg: Shoulder day", font: AppFont.semibold.size(20.0, familyName: familyManrope), color: UIColor(red: 137.0/255.0, green: 131/255.0, blue: 132/255.0, alpha: 1.0))
        self.slotTimeLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        self.slotTimeBtn.titleLabel?.font = AppFont.regular.size(14.0, familyName: familyManrope)
        self.frequencyBtn.titleLabel?.font = AppFont.bold.size(12.0, familyName: familyManrope)
        self.notifyMeBtn.titleLabel?.font = AppFont.bold.size(12.0, familyName: familyManrope)
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
        if tableView == exerciseTblView {
            return exerciseData?.count ?? 0 //addExerciseData.count
        }else{
            return noteData?.count ?? 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == exerciseTblView {
            let cell:ExerciseTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
            
            cell.setCellData(cellData: exerciseData?[indexPath.row])
            cell.checkBtn.setImage(UIImage(named: "ic_moreSettings"), for: .normal)
            cell.navCtrl = self.navigationController
            cell.setupMenuActn()
            cell.onMenuBtnTapped = { [weak self, weak cell] button in
                guard let self = self, let cell = cell else { return }
                self.presentCustomMenu(for: cell, at: indexPath, from: button)
            }
            
            /*
            cell.checkBtn.addTarget(self, action: #selector(cell.editBtnActn(sender:)), for: .touchUpInside)
            cell.navCtrl = self.navigationController
            
            cell.setupEditTarget()
            */
            
            return cell
        }else{
            let cell:NoteDescTableViewCell = noteTutorialTblView.dequeueReusableCell(withIdentifier: "NoteDescTableViewCell", for: indexPath) as! NoteDescTableViewCell
            
            cell.noteNumLbl.text = "\(indexPath.row + 1)."
            cell.noteDescLbl.text = noteData?[indexPath.row] as? String
            return cell
        }
        
        //        let cell:ExerciseTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
        //
        //        cell.checkBtn.setImage(UIImage(named: "ic_moreSettings"), for: .normal)
        ////        cell.checkBtn.addTarget(self, action: #selector(cell.editBtnActn(sender:)), for: .touchUpInside)
        //        cell.navCtrl = self.navigationController
        //
        //        cell.setupEditTarget()
        //
        //        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected indexpath: ", indexPath)
    }
    
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return 1
    //    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //
    //        if tableView == exerciseTblView {
    //            return headerMBV
    //        }else{
    //            let vv = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    //            vv.backgroundColor = UIColor.clear
    //            self.view.addSubview(vv)
    //            return vv
    //        }
    //
    //    }
    
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //
    ////        return UITableView.automaticDimension
    //        if tableView == noteTutorialTblView {
    //            return 2
    //        }else{
    //            return UITableView.automaticDimension
    //        }
    //
    //    }
    
    //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //        if tableView == noteTutorialTblView {
    //            return 2
    //        }else{
    //            return UITableView.automaticDimension
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView == exerciseTblView {
            DispatchQueue.main.async {
                self.updateViewConstraints()
            }
        }
        else if tableView == noteTutorialTblView {
            DispatchQueue.main.async {
                self.updateViewConstraints()
            }
        }
    }
    
    //MARK: ---------------EDIT / DELETE
    private func presentCustomMenu(for cell: ExerciseTableViewCell, at indexPath: IndexPath, from sourceView: UIView) {
        
        let menuVC = CustomMenuViewController()
        menuVC.menuItems = [
            MenuItem(title: "Edit", image: UIImage(named: "ic_edit_black")?.resized(to: CGSize(width: 20, height: 20)), isDestructive: false, titleColor: UIColor.mainBg, backgroundColor: .clear, font: AppFont.semibold.size(14.0, familyName: familyManrope), separatorColor: .clear),
            MenuItem(title: "Delete", image: UIImage(named: "ic_delete_Red")?.resized(to: CGSize(width: 20, height: 20)), isDestructive: true, titleColor: UIColor.appRed, backgroundColor: .clear, font: AppFont.semibold.size(14.0, familyName: familyManrope), separatorColor: UIColor(red: 189.0/255.0, green: 189.0/255.0, blue: 189.0/255.0, alpha: 1.0))
        ]

        menuVC.onMenuItemSelected = { [weak self] actionTitle in
            guard let self = self else { return }
            
            if actionTitle == "Edit" {
                print("Edit is clicked")
                let vc: EditRegularExerciseViewController = EditRegularExerciseViewController.instantiate(appStoryboard: .calendar)
                vc.createWorkoutFlow = .regularCreateWorkout
                vc.exerciseName = exerciseData?[indexPath.row].name?.value
                vc.exerciseImgStr = exerciseData?[indexPath.row].image?.value
                vc.durationStr = exerciseData?[indexPath.row].duration?.value //"60s"
                vc.restTimeStr = exerciseData?[indexPath.row].duration?.value
                vc.caloriesStr = exerciseData?[indexPath.row].calories?.value
                vc.inputSetsCont = Int(exerciseData?[indexPath.row].sets?.value ?? "3")
//                vc.inputRepsCont = Int(exerciseData?[indexPath.row].reps?.value ?? "1")
                
                if let reps = exerciseData?[indexPath.row].reps?.value, !reps.isEmpty {
                    vc.inputRepsCont = Int(reps)
                }else{
                    vc.inputRepsCont = Int(exerciseData?[indexPath.row].raps?.value ?? "1")
                }
                
                if let position = exerciseData?[indexPath.row].position?.value, !position.isEmpty {
                    vc.setsPositionStr = exerciseData?[indexPath.row].sets_position?.value
                    vc.workoutIdStr = self.workoutIdStr
                    vc.workoutExerciseId = exerciseData?[indexPath.row].id?.value
                }
                
                vc.sentEditedData = { (setsCount, repsCount, restTime, noteDesc) in
                    if let repsCount = repsCount {
//                        self.exerciseData?[indexPath.row].reps?.value = "\(repsCount)"
                        
                        if let reps = self.exerciseData?[indexPath.row].reps?.value, !reps.isEmpty {
                            self.exerciseData?[indexPath.row].reps?.value = "\(repsCount)"
//                            vc.inputRepsCont = Int(reps)
                        }else{
                            self.exerciseData?[indexPath.row].raps?.value = "\(repsCount)"
//                            vc.inputRepsCont = Int(exerciseData?[indexPath.row].raps?.value ?? "1")
                        }
                        
                        self.exerciseData?[indexPath.row].sets?.value = "\(setsCount ?? 3)"
                        
                        self.exerciseTblView.reloadData()
                        
                        //---------------------- EDITED DATA ALREADY CREATED REGULAR WORKOUT
                        if let workoutIdStr = self.getWorkoutData?.workoutId?.value, !workoutIdStr.isEmpty, let exerciseIdStr = self.exerciseData?[indexPath.row].workout_exercise_id?.value {
                            self.getCreatedWorkouts(inputWorkId: workoutIdStr)
                        }
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if actionTitle == "Delete" {
                print("Delete is clicked")
                self.dismiss(animated: true) {   // dismiss popover first
                    let vc: DeletePopupViewController = DeletePopupViewController.instantiate(appStoryboard: .calendar)
                    vc.delTilteStr = "Delete Exercise"
                    vc.altMsgStr = "You’re going to delete this exercise. Are you sure?"
                    vc.modalPresentationStyle = .automatic
                    vc.sentBackData = { isDelete in
                        if let isDelete = isDelete, isDelete,
                           let data = self.exerciseData, data.indices.contains(indexPath.row) {
                          
                            if let workoutIdStr = self.getWorkoutData?.workoutId?.value, !workoutIdStr.isEmpty, let exerciseIdStr = self.exerciseData?[indexPath.row].workout_exercise_id?.value {
                                
                                WorkoutLibraryVM.deleteWorkoutExerciseApi(inputWorkoutExerciseId: exerciseIdStr, completion: {[weak self] getResultData in
                                    guard let self = self else { return }
                                    self.getCreatedWorkouts(inputWorkId: workoutIdStr)
                                })
                                
                            }else{
                                
                                self.exerciseData?.remove(at: indexPath.row)
                                self.exerciseTblView.reloadData()
                                
                                //---------------------***********
                                self.exercisesCountLbl.text = "\(self.exerciseData?.count ?? 0)"
                                let totalCalories = self.exerciseData?
                                    .compactMap { Int($0.calories?.value ?? "0") }
                                    .reduce(0, +)
                                self.caloriesCountLbl.text = "\(totalCalories ?? 0)"
                            }
                            
                            let exercisesDurationsFilter = self.exerciseData?.filter({ $0.type?.value != "rest" })
                            let totalDurations = exercisesDurationsFilter?
                                .compactMap { Int($0.duration?.value ?? "0") }
                                .reduce(0, +)
                            self.durationTimeLbl.attributedText = "\(totalDurations ?? 0)s".gradientAttr(labl: self.durationTimeLbl, txtStr: "\(totalDurations ?? 0)s")
                            
                            /*
                            self.exerciseData?.remove(at: indexPath.row)
                            self.exerciseTblView.reloadData()
                            
                            //---------------------***********
                            self.exercisesCountLbl.text = "\(self.exerciseData?.count ?? 0)"
                            let totalCalories = self.exerciseData?
                                .compactMap { Int($0.calories?.value ?? "0") }
                                .reduce(0, +)
                            self.caloriesCountLbl.text = "\(totalCalories ?? 0)"
                            */
                        }
                    }
                    self.present(vc, animated: true)
                }
            }
        }
        menuVC.modalPresentationStyle = .popover
        menuVC.preferredContentSize = CGSize(width: 130, height: 90)
        if let popover = menuVC.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = sourceView
            popover.permittedArrowDirections = [] // <-- Remove arrow
            popover.sourceRect = CGRect(
                x: sourceView.bounds.minX - 50,   // horizontally center
                y: sourceView.bounds.maxY + 60.0,   // bottom edge of the button
                width: 0,
                height: 0
            )
            
            popover.backgroundColor = UIColor.clear
        }
        present(menuVC, animated: true, completion: nil)
       }
    
}

extension ScheduleWorkoutViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("Started dragging")
        self.view.endEditing(true)
    }
}

extension ScheduleWorkoutViewController: UIPopoverPresentationControllerDelegate, UITextFieldDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // This makes the popover appear correctly on iPhone
        return .none
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == workoutNameTxtField {
            // Allowed characters: English alphabets (uppercase/lowercase) + space
            let allowedCharacters = CharacterSet.letters.union(.whitespaces)
            
            // Check if all characters in the input string are allowed
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false // Contains disallowed character
            }
        }
            return true
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}


extension ScheduleWorkoutViewController{
   
    private func getCreatedWorkouts(inputWorkId: String?){
        WorkoutLibraryVM.setEditWorkoutsApi(inputWorkoutId: inputWorkId, completion: {[weak self] getWorkoutData in
            guard let self = self else { return }
            
            self.getWorkoutData = nil
            self.getWorkoutData = getWorkoutData?.data
            self.exerciseData?.removeAll()
            self.exerciseData?.append(contentsOf: self.getWorkoutData?.exercises ?? [])
            self.exerciseTblView.reloadData()
            self.setInputData()
        })
    }
}
