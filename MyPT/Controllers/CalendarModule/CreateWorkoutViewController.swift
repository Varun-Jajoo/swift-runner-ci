//
//  CreateWorkoutViewController.swift
//  MyPT
//
//  Created by techsaga corp on 27/08/25.
//

import UIKit

enum CreateWorkoutFlow {
    case regularCreateWorkout
    case superCreateWorkout
    case circuitCreateWorkout
    case defaultWorkout
    
    var type: TimePopupFlow {
           switch self {
           case .regularCreateWorkout:
                   .regularWorkout
           case .superCreateWorkout:
                   .superWorkout
           case .circuitCreateWorkout:
                   .circuitWorkout
           case .defaultWorkout:
                   .timepopupDefault
           }
       }
}


class CreateWorkoutViewController: CommonViewController, deleteRestProtocol {
    
    //MARK: --------------VARIABLE
    var workoutIdStr: String?
    var createWorkoutFlow: CreateWorkoutFlow = .defaultWorkout
    let restTimePicker = RestTimePickerView()
    
    var plusCount: Int = 1{
        didSet{
            circuitRestCountLbl.text = "\(plusCount)"
        }
    }

    private var localExerciseDetails:[ExercisesDatailsModel]? = []

    private var caloriesCount : Int? = 1{
        didSet{
            //---------------------***********
//            if let geteExerciseData = self.exerciseData, !geteExerciseData.isEmpty {
            if let geteExerciseData = self.exerciseData{
                print("exerciseData 1st: ", geteExerciseData.count)
                
                let originalData = self.exerciseData
                let exerciseWithoutRestData: [ExercisesDatailsModel] = originalData?.filter { $0.localRest?.value?.lowercased() != "localrest" } ?? []
            
                self.exercisesCountLbl.text = "\(exerciseWithoutRestData.count)"
                let totalCalories = exerciseWithoutRestData
                    .compactMap { Int($0.calories?.value ?? "0") }
                    .reduce(0, +)
                self.caloriesCountLbl.text = "\(totalCalories)"
                
                let exercisesDurationsFilter = self.exerciseData?.filter({ $0.type?.value != "rest" })
                let totalDurations = exercisesDurationsFilter?
                    .compactMap { Int($0.duration?.value ?? "0") }
                    .reduce(0, +)
                self.durationTimeLbl.attributedText = "\(totalDurations ?? 0)s".gradientAttr(labl: self.durationTimeLbl, txtStr: "\(totalDurations ?? 0)s")
               
                //---------------------- *************
                if let exerciseData = self.exerciseData, exerciseData.count == 1 {
                    //localrest
                    if let lstIndx = self.exerciseData?.firstIndex(where: {$0.localRest?.value == "localrest"}){
                        self.exerciseData?.remove(at: lstIndx)
                        self.exerciseTblView.reloadData()
                        self.restCircuitSwtch.isSelected = false
                    }
                    
                    if self.exerciseData?.count ?? 0 < 1 {
                        self.saveBtn.isHidden = true
                    }
                }else{
                    if self.exerciseData?.count ?? 0 < 1 {
                        self.saveBtn.isHidden = true
                    }
                }
            }
        }
    }
    
    private var createCircuitWorkoutParam: RegularWorkoutModel? = RegularWorkoutModel()
    var exerciseData:[ExercisesDatailsModel]? = []
    private  var localSupersetExerciseData:[ExercisesDatailsModel]? = []
    private var restExerciseData:[ExercisesDatailsModel]? = []
    private var getSupsetWorkoutData: SupersetWorkoutModelAPI?
    var supersetExerciseData:[ExercisesDatailsModel]? = []
    var supersetData:[SupersetModelAPI]? = []
    var startDateTimeStr: String?
    private var reminderTime: RemindWorkoutDataModel? = nil
    private var weekDaysFreq: String? = nil
    private var endDateStr: String? = nil
    private var localDaysFreq: [String]? = []
    private var addExerciseData: [ExerciseModel]? = []
    
    private var restAfterForAllTimeStr: String? {
        didSet{
            
            if !restCircuitSwtch.isSelected{
                if let last = self.exerciseData?.last, last.localRest?.value?.lowercased() == "localrest" || last.type?.value?.lowercased() == "rest" , let indx = self.exerciseData?.firstIndex(where: {$0.localRest?.value?.lowercased() == "localrest" || $0.type?.value?.lowercased() == "rest"}) {
                    let indxPath: IndexPath = IndexPath(row: indx, section: 0)
                    self.exerciseData?[indxPath.row].restDuration?.value = "\(restAfterForAllTimeStr ?? "1")"
                    self.exerciseTblView.reloadRows(at: [indxPath], with: .none)
                    
                }
            }
        }
    }
    
    private var restBetweenExerciseTimeStr: String?
    private var noteData:[String]?
    private var isFirstLoadingSuperset: Bool?
    private var supersetCount: Int?
    
    //MARK: -------------------- IBOUTLET
    @IBOutlet weak var headerUserMBV: UIView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var workoutNameTitleLbl: UILabel!
    @IBOutlet weak var workoutNameTxtField: UITextField!
    @IBOutlet weak var workoutTypeBtn: UIButton!
    @IBOutlet weak var workoutTimeSlotLbl: UILabel!
    @IBOutlet weak var workoutTimeSlotBtn: UIButton!
    @IBOutlet weak var repsFrequencyBtn: UIButton!
    @IBOutlet weak var notifyBtn: UIButton!
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
    
    @IBOutlet weak var circuitSettingMSTCkV: UIStackView!
    @IBOutlet weak var setRoundsMStckV: UIStackView!
    @IBOutlet weak var circuitRoundsMBV: UIView!
    @IBOutlet weak var restTimeMBV: UIView!
    @IBOutlet weak var restInCircuitOuterMBV: UIView!
    @IBOutlet weak var restInCircuitMBV: UIView!
    @IBOutlet weak var restCircuitSwtch: CustomSwipeSwitch!
    @IBOutlet weak var restTimeScaleMBV: UIView!
    @IBOutlet weak var showCircuitSettingsMBV: UIView!
    @IBOutlet weak var addRestMBV: UIView!
    @IBOutlet weak var addExerciseMBV: UIView!
    @IBOutlet weak var circuitRoundsTitleLbl: UILabel!
    @IBOutlet weak var circuitRestCountLbl: UILabel!
    @IBOutlet weak var restAfterCircuitLbl: UILabel!
    @IBOutlet weak var restBetweenExerciseTitleLbl: UILabel!
    @IBOutlet weak var addSupersetExerciseBtn: UIButton!
    @IBOutlet weak var addRestBtn: UIButton!
    @IBOutlet weak var showCircuitSettingsBtn: UIButton!
    
    @IBOutlet weak var addExerciseBtn: UIButton!
    @IBOutlet weak var addExerciseBtnHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var addRestBtnHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var exerciseTblView: UITableView!
    @IBOutlet weak var exerciseTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var supersetNoteMBV: UIView!
    @IBOutlet weak var supersetNoteDescMBV: UIView!
    @IBOutlet weak var howToTilelbl: UILabel!
    @IBOutlet weak var noteLstTblView: UITableView!
    @IBOutlet weak var noteLstTblViewHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.workoutNameTxtField.delegate = self
        self.restCircuitSwtch.isSelected = false
        self.registerCells()
        self.setupUI()
        self.setupFont()
        self.setTimerUI()
        
        self.saveBtn.isHidden = true
        
        self.setInputData()
        self.customRestSwtch()
        
        //------------------Api
        if let workoutIdStr = workoutIdStr, !workoutIdStr.isEmpty {
            self.getCreatedWorkouts(inputWorkId: workoutIdStr)
        }
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.setupUI()
        
        self.addSupersetExerciseBtn.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 16.0, dashPattern: [15,8])
        self.addRestBtn.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 16.0, dashPattern: [15,8])
        self.addExerciseBtn.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 16.0, dashPattern: [15,8])
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        print("notification", notification)
        self.customBlurViewRemove(viewShow: self.view)
    }
    
    private func registerCells(){
        
//        self.exerciseTblView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
        
        self.exerciseTblView.isScrollEnabled = false
        
        self.exerciseTblView.register(UINib(nibName: "RestTableViewCell", bundle: nil), forCellReuseIdentifier: "RestTableViewCell")
        self.noteLstTblView.register(UINib(nibName: "NoteDescTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteDescTableViewCell")
        
        switch createWorkoutFlow {
        case .superCreateWorkout:
//            self.exerciseTblView.register(UINib(nibName: "SupersetTableViewCell", bundle: nil), forCellReuseIdentifier: "SupersetTableViewCell")
            
            self.exerciseTblView.register(UINib(nibName: "SupersetGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "SupersetGroupTableViewCell")
            
            self.exerciseTblView.register(UINib(nibName: "SupersetExercisesTableViewCell", bundle: nil), forCellReuseIdentifier: "SupersetExercisesTableViewCell")
            
            break
        case .circuitCreateWorkout:
            self.exerciseTblView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
            
            break
        case .regularCreateWorkout, .defaultWorkout:
            print("None of these....")
            break
        }
       
    }
    
    //----------------- INPUT DATA AND FLOW
    private func setInputData(){
        workoutTimeSlotLbl.text = self.startDateTimeStr
        durationTimeLbl.text = "0"
        caloriesCountLbl.text = "0"
        exercisesCountLbl.text = "0"
        
        self.durationTimeLbl.attributedText = "0s".gradientAttr(labl: self.durationTimeLbl, txtStr: "0s")
        self.caloriesCountLbl.attributedText = "0".gradientAttr(labl: self.caloriesCountLbl, txtStr: "0")
        self.exercisesCountLbl.attributedText = "0".gradientAttr(labl: self.exercisesCountLbl, txtStr: "0")
        
        //----------
        //        createWorkoutParam?.start_date  = startDateTimeStr
        //        createWorkoutParam?.time = dateTimeStr
        
        //------------ Flow setup
        self.addRestMBV.isHidden = true
        self.setRoundsMStckV.isHidden = false
        self.restInCircuitOuterMBV.isHidden = false
        self.showCircuitSettingsMBV.isHidden = false
        self.supersetNoteMBV.isHidden = true
        
        switch createWorkoutFlow {
        case .superCreateWorkout:
            print("superCreateWorkout")
            self.addRestMBV.isHidden = true
            self.setRoundsMStckV.isHidden = true
            self.restInCircuitOuterMBV.isHidden = true
            self.showCircuitSettingsMBV.isHidden = true
            self.supersetNoteMBV.isHidden = false
//            self.isFirstLoadingSuperset = true
            
//            if let isFirstLoadingSuperset = isFirstLoadingSuperset , isFirstLoadingSuperset{
//                self.isFirstLoadingSuperset = nil
//                self.addSupersetExerciseBtn.isHidden = false
//            }else{
//                self.addSupersetExerciseBtn.isHidden = true
//            }
            
            self.workoutTypeBtn.setTitle("Superset", for: .normal)
            self.workoutTypeBtn.backgroundColor = UIColor(red: 44.0/255.0, green: 171.0/255.0, blue: 105.0/255.0, alpha: 1.0)
            
            noteData = [
            "Add exercies",
            "Create a superset, and choose form the added exercies",
            "Define number of sets for each superset",
            "Add rest period"
            ]
            
            break
            
        case .circuitCreateWorkout:
            print("circuitCreateWorkout")
            self.workoutTypeBtn.setTitle("Circuit", for: .normal)
            self.workoutTypeBtn.backgroundColor = UIColor(red: 239.0/255.0, green: 179.0/255.0, blue: 109.0/255.0, alpha: 1.0)
            self.addExerciseBtn.setTitle("Add Exercise", for: .normal)
            
            break
            
        case .regularCreateWorkout, .defaultWorkout:
            print("None of these....")
            break
            
        }
        
    }
    
    private func inputApiData(){
        
        if let workoutId = getSupsetWorkoutData?.workoutId?.value, !workoutId.isEmpty, let type = getSupsetWorkoutData?.type?.value, type.lowercased() == "superset" {
            self.workoutNameTxtField.text = getSupsetWorkoutData?.name?.value
            self.workoutTypeBtn.setTitle(getSupsetWorkoutData?.type?.value, for: .normal)
            self.durationTimeLbl.text = "0" //getSupsetWorkoutData?.repeatDuration?.value
            self.caloriesCountLbl.text = "0" //getSupsetWorkoutData?.calories?.value
            self.exercisesCountLbl.text = "0" //getSupsetWorkoutData?.totalExercise?.value
            
            if let _ = getSupsetWorkoutData?.repeatDuration?.value {
                
                let totalDurations = getSupsetWorkoutData?.supersets?
                    .flatMap { $0.exercises ?? [] }
                    .compactMap { Int($0.duration?.value ?? "0") }
                    .reduce(0, +) // sum
            
                self.durationTimeLbl.attributedText = "\(totalDurations ?? 0)s".gradientAttr(labl: self.durationTimeLbl, txtStr: "\(totalDurations ?? 0)s")
                
//                self.durationTimeLbl.attributedText = repeatDurationStr.gradientAttr(labl: self.durationTimeLbl, txtStr: repeatDurationStr)
            }else{
                self.durationTimeLbl.attributedText = "0s".gradientAttr(labl: self.durationTimeLbl, txtStr: "0s")
            }
            
            if let caloriesStr = getSupsetWorkoutData?.calories?.value {
                self.caloriesCountLbl.attributedText = caloriesStr.gradientAttr(labl: self.caloriesCountLbl, txtStr: caloriesStr)
            }else{
                self.caloriesCountLbl.attributedText = "0".gradientAttr(labl: self.caloriesCountLbl, txtStr: "0")
            }
            
            if let totalExerciseStr = getSupsetWorkoutData?.totalExercise?.value {
                self.exercisesCountLbl.attributedText = totalExerciseStr.gradientAttr(labl: self.exercisesCountLbl, txtStr: totalExerciseStr)
            }else{
                self.exercisesCountLbl.attributedText = "0".gradientAttr(labl: self.exercisesCountLbl, txtStr: "0")
            }
            
            if let getStartDate = getSupsetWorkoutData?.startDate?.value , let getTime = getSupsetWorkoutData?.time?.value {
                let startDate = DateFormatterHelper.shared.getDateFromFormat(fromDate: getStartDate, fromFormat: "yyy-MM-dd", toFormat: "dd-MM-yyy") ?? ""
                self.workoutTimeSlotLbl.text = startDate + ", " + getTime
                self.startDateTimeStr = startDate + ", " + getTime
            }
            
            self.weekDaysFreq = getSupsetWorkoutData?.repeatDuration?.value
            self.endDateStr = DateFormatterHelper.shared.getDateFromFormat(fromDate: getSupsetWorkoutData?.endDate?.value ?? "", fromFormat: "yyy-MM-dd", toFormat: "dd-MM-yyy")
            self.localDaysFreq = getSupsetWorkoutData?.repeatDays?.value?.components(separatedBy: ",")
            
            let reminerModel:RemindWorkoutDataModel = RemindWorkoutDataModel(id: FlexibleValue(value: getSupsetWorkoutData?.remindMe?.value), remind_time: nil, time: nil)
            self.reminderTime = reminerModel
            
            //----------------------*************
            self.addRestBtn.isHidden = false
            self.addSupersetExerciseBtn.isHidden = true
            self.addExerciseBtn.setTitle("Add a new Superset", for: .normal)
            
            //-------------------------*****************
            if let localSupersetExerciseData = self.localSupersetExerciseData , localSupersetExerciseData.count > 0 && !localSupersetExerciseData.isEmpty{
                self.isFirstLoadingSuperset = nil
                self.addSupersetExerciseBtn.isHidden = true
            }else{
                self.addSupersetExerciseBtn.isHidden = false
            }
            
        }else{
            
            self.workoutNameTxtField.text = getSupsetWorkoutData?.name?.value
            self.workoutTypeBtn.setTitle(getSupsetWorkoutData?.type?.value, for: .normal)
            self.durationTimeLbl.text = "0" //getSupsetWorkoutData?.repeatDuration?.value
            self.caloriesCountLbl.text = "0" //getSupsetWorkoutData?.calories?.value
            self.exercisesCountLbl.text = "0" //getSupsetWorkoutData?.totalExercise?.value
            
            if let _ = getSupsetWorkoutData?.repeatDuration?.value {
//                self.durationTimeLbl.attributedText = repeatDurationStr.gradientAttr(labl: self.durationTimeLbl, txtStr: repeatDurationStr)
                                
                let exercisesDurationsFilter = getSupsetWorkoutData?.exercises?.filter({ $0.type?.value != "rest" })
                let totalDurations = exercisesDurationsFilter?
                    .compactMap { Int($0.duration?.value ?? "0") }
                    .reduce(0, +)
               
                self.durationTimeLbl.attributedText = "\(totalDurations ?? 0)s".gradientAttr(labl: self.durationTimeLbl, txtStr: "\(totalDurations ?? 0)s")
            }
            
            if let caloriesStr = getSupsetWorkoutData?.calories?.value {
                self.caloriesCountLbl.attributedText = caloriesStr.gradientAttr(labl: self.caloriesCountLbl, txtStr: caloriesStr)
            }
            
            if let totalExerciseStr = getSupsetWorkoutData?.totalExercise?.value {
                self.exercisesCountLbl.attributedText = totalExerciseStr.gradientAttr(labl: self.exercisesCountLbl, txtStr: totalExerciseStr)
            }

            if let circuitRound = getSupsetWorkoutData?.sets_round?.value {
                self.plusCount = Int(circuitRound) ?? 1
            }
           
            if let getStartDate = getSupsetWorkoutData?.startDate?.value , let getTime = getSupsetWorkoutData?.time?.value {
                let startDate = DateFormatterHelper.shared.getDateFromFormat(fromDate: getStartDate, fromFormat: "yyy-MM-dd", toFormat: "dd-MM-yyy") ?? ""
                self.workoutTimeSlotLbl.text = startDate + ", " + getTime
                self.startDateTimeStr = startDate + ", " + getTime
            }
            
            self.weekDaysFreq = getSupsetWorkoutData?.repeatDuration?.value
            self.endDateStr = DateFormatterHelper.shared.getDateFromFormat(fromDate: getSupsetWorkoutData?.endDate?.value ?? "", fromFormat: "yyy-MM-dd", toFormat: "dd-MM-yyy")
            self.localDaysFreq = getSupsetWorkoutData?.repeatDays?.value?.components(separatedBy: ",")
            
            let reminerModel:RemindWorkoutDataModel = RemindWorkoutDataModel(id: FlexibleValue(value: getSupsetWorkoutData?.remindMe?.value), remind_time: nil, time: nil)
            self.reminderTime = reminerModel
            
            //+  Add a new Superset
            self.addExerciseBtn.setTitle("Add Exercise", for: .normal)
            self.saveBtn.isHidden = false
            
            //-------------------*****************
            self.addExerciseBtnHeightConstrnt.constant = 90.0
            self.addExerciseMBV.layoutIfNeeded()
            self.saveBtn.layoutIfNeeded()
        }
    }
    
    private func customRestSwtch(){
        //-----------------***************** Custom switch
        //        restCircuitSwtch.selectedColor = UIColor.appYellow
        //        restCircuitSwtch.deSelectedColor = UIColor.appLightGray
        
        restCircuitSwtch.onToggle = { [weak self] isSelected in
            guard let self = self else { return  }

            if isSelected {
//                let restDurationFilterData = self.restExerciseData?.filter { $0.type?.value?.lowercased() == "rest" || $0.localRest?.value?.lowercased() == "localrest" }
//                guard let restDurationFilterData = restDurationFilterData, restDurationFilterData.count < 1 else { return }
                
                if let exerciseData = self.exerciseData, exerciseData.count > 0 {
                    let vc: AddRestTimePopupViewController = AddRestTimePopupViewController.instantiate(appStoryboard: .calendar)
                    vc.modalPresentationStyle = .automatic
                    vc.senBacktTime = { (getTimeStr, isDismiss) in
                        guard let isDismiss = isDismiss else { return }
                        //let getTimeStr = getTimeStr
                        if isDismiss {
                            self.restCircuitSwtch.isSelected = !isDismiss
                        }
                        
                        if let getTimeStr = getTimeStr {
                            self.restExerciseData?.removeAll()
                            self.restBetweenExerciseTimeStr = getTimeStr
                            //-=----=-------- ***** for make between each rest
                            self.insertLocalRestBetweenEachExercises()
                        }
                    }
                    if let restBetweenExerciseTimeStr = self.restBetweenExerciseTimeStr {
                        vc.selectedTime = restBetweenExerciseTimeStr
                    }
                    self.present(vc, animated: true)
                }
                else{
                    self.restCircuitSwtch.isSelected = false
                    AlertHelper.shared.showCustomeAlert(message: "Please add exercise at least one!")
                }
                
            }else{
                self.restBetweenExerciseTimeStr = nil
                if let exerciseData = self.exerciseData, exerciseData.count > 0  {
                    self.exerciseData?.removeAll()
                    self.exerciseData = keepOnlyLastRest(from: exerciseData, restDuration: self.restAfterForAllTimeStr)
                    self.exerciseTblView.reloadData()
                }
            }
        }
    }
    
    func insertLocalRestBetweenEachExercises() {
        guard let originalData = self.exerciseData else { return }
        self.exerciseData?.removeAll()
        self.exerciseData = insertRestInBetweenEachExercises(in: originalData, restDuration: self.restBetweenExerciseTimeStr)
        self.exerciseTblView.reloadData()
        
    }
    
    private func insertRestInBetweenEachExercises(
        in items: [ExercisesDatailsModel],
        restDuration: String?
    ) -> [ExercisesDatailsModel] {
        var itemsCopy = items
        var updatedList: [ExercisesDatailsModel] = []
        var restExercises = self.restExerciseData ?? []
        
        // Remove trailing rest if already exists
        if let last = itemsCopy.last,
           last.localRest?.value == "localrest" || last.type?.value?.lowercased() == "rest" {
            itemsCopy.removeLast()
        }
        
        restExercises = restExercises.filter({ $0.type?.value?.lowercased() == "rest" || $0.type?.value?.lowercased() == "localrest" })
        
        for (index, item) in itemsCopy.enumerated() {
            updatedList.append(item)
            
            if item.type?.value?.lowercased() == "exercise" {
                // Use rest at the same index if available, else fallback
                let matchingRest = index < restExercises.count ? restExercises[index] : nil
                
//                let finalRestDuration =
//                    matchingRest?.restDuration?.value ??
//                    restDuration ??
//                    item.restDuration?.value
                
                let finalRestDuration =
                    matchingRest?.restDuration?.value ??
                    restDuration ?? "60"
                
                let restItem = ExercisesDatailsModel(
                    type: FlexibleValue(value: "rest"),
                    localRest: FlexibleValue(value: "localrest"),
                    timeType: FlexibleValue(value: item.timeType?.value),
                    restDuration: FlexibleValue(value: finalRestDuration)
                )
                
                updatedList.append(restItem)
            }
        }
        
        return updatedList
    }

    
    
    /*
    private func insertRestInBetweenEachExercises(
        in items: [ExercisesDatailsModel],
        restDuration: String?
    ) -> [ExercisesDatailsModel] {
        var itemsCopy = items
        var updatedList: [ExercisesDatailsModel] = []
        let restExercises = self.restExerciseData ?? []
        
        if let last = itemsCopy.last, last.localRest?.value == "localrest" || last.type?.value?.lowercased() == "rest" {
            itemsCopy.removeLast()
        }
        
        for (index, item) in itemsCopy.enumerated() {
            updatedList.append(item)
            
            // Insert rest after *every* exercise (including last one)
            if item.type?.value?.lowercased() == "exercise" {
                // Try to find a matching rest from restExerciseData
                let matchingRest = restExercises.first {
                    $0.type?.value?.lowercased() == "rest"
                }
                
                let finalRestDuration =
                    matchingRest?.restDuration?.value ??
                    restDuration ??
                    item.restDuration?.value
                
                let restItem = ExercisesDatailsModel(
                    type: FlexibleValue(value: "rest"),
                    localRest: FlexibleValue(value: "localrest"),
                    timeType: FlexibleValue(value: item.timeType?.value),
                    restDuration: FlexibleValue(value: finalRestDuration)
                )
                updatedList.append(restItem)
            }
        }
        
        return updatedList
    }
    */
    
 /*
    private func insertRestInBetweenEachExercises(in items: [ExercisesDatailsModel], restDuration: String?) -> [ExercisesDatailsModel] {
        var itemsCopy = items   // now mutable
        var updatedList: [ExercisesDatailsModel] = []
        // remove last if it's rest
//        if let last = itemsCopy.last, last.localRest?.value == "localrest" {
//            itemsCopy.removeLast()
//        }
        
        if let last = itemsCopy.last, last.localRest?.value == "localrest" || last.type?.value?.lowercased() == "rest" {
            itemsCopy.removeLast()
        }
        
        for item in itemsCopy {
            updatedList.append(item)
            if item.type?.value?.lowercased() == "exercise" {
               
                let localRest = ExercisesDatailsModel(
                    type: FlexibleValue(value: "rest"),
                    localRest: FlexibleValue(value: "localrest"),
                    timeType: FlexibleValue(value: item.timeType?.value),
                    restDuration: FlexibleValue(value: restDuration)
                )
                updatedList.append(localRest)
            }
        }
        return updatedList
    }
   */
    
    
    func keepOnlyLastRest(from items: [ExercisesDatailsModel], restDuration: String?) -> [ExercisesDatailsModel] {
        //  Remove all existing localrest items
        var filtered = items.filter { $0.localRest?.value?.lowercased() != "localrest" && $0.type?.value?.lowercased() != "rest" }
        
        // Check if the original last was a localrest
        if let last = items.last, last.localRest?.value?.lowercased() == "localrest" && last.type?.value?.lowercased() == "rest" {
            // Keep only one rest at the end and update its duration
            var updatedLast = last
            updatedLast.restDuration?.value = restDuration
            updatedLast.type?.value = "rest"
            updatedLast.timeType?.value = "2"
            filtered.append(updatedLast)
        } else {
            // Append a new rest at the end
            let lastRestElement = ExercisesDatailsModel(
                type: FlexibleValue(value: "rest"),
                localRest: FlexibleValue(value: "localrest"),
                timeType: FlexibleValue(value: "2"),
                restDuration: FlexibleValue(value: restDuration ?? "")
            )
            filtered.append(lastRestElement)
        }
        
        return filtered
    }
    
    func supersetOnlyLastRest(from items: [SupersetModelAPI], restDuration: String?) -> [SupersetModelAPI] {
        var result: [SupersetModelAPI] = []
        
        for (index, item) in items.enumerated() {
            if item.type?.value?.lowercased() == "rest" {
                // If it's the last element, skip for now (we'll handle at end)
                if index == items.count - 1 { continue }
                //If it's in between, keep it as-is
                result.append(item)
            } else {
                // Non-rest items always added
                result.append(item)
            }
        }
        
        // Ensure there is one rest at the end
        let lastRest = SupersetModelAPI(
            type: FlexibleValue(value: "rest"),
            sets_position: FlexibleValue(value: "0"),
            duration: FlexibleValue(value: restDuration ?? "")
        )
        result.append(lastRest)
        
        return result
    }
    
//    func supersetOnlyLastRest(from items: [SupersetModelAPI], restDuration: String?) -> [SupersetModelAPI] {
//        //  Remove all existing localrest items
//        var restFiltered = items.filter { $0.type?.value?.lowercased() != "rest" }
//        
//        // Check if the original last was a localrest
//        if let last = items.last, last.type?.value?.lowercased() == "rest" {
//            // Keep only one rest at the end and update its duration
//            var updatedLast = last
//            updatedLast.duration?.value = restDuration
//            restFiltered.append(updatedLast)
//        } else {
//            // Append a new rest at the end
//            let lastSupersetRest = SupersetModelAPI(
//                type: FlexibleValue(value: "rest"),
//                sets_position: FlexibleValue(value: "0"),
//                duration: FlexibleValue(value: restDuration ?? "")
//            )
//            restFiltered.append(lastSupersetRest)
//        }
//        return restFiltered
//    }
    
    
    @IBAction func editWorkoutTimeBtn(_ sender: Any) {
        let vc:TimeSlotPopupViewController = TimeSlotPopupViewController.instantiate(appStoryboard: .calendar)
        vc.modalPresentationStyle = .automatic
        vc.navCtrl = self.navigationController
//        vc.timePopFlow = CreateWorkoutFlow.self.circuitCreateWorkout.type
        vc.isUpdateTime = true
        if let isSupset = getSupsetWorkoutData?.type?.value?.lowercased(),  isSupset == "superset" {
            vc.timePopFlow = .superWorkout
        }else{
            vc.timePopFlow = CreateWorkoutFlow.self.circuitCreateWorkout.type
            print("CreateWorkoutFlow.self.circuitCreateWorkout.type", CreateWorkoutFlow.self.circuitCreateWorkout.type)
        }
        vc.sentBackDateTime = {[weak self] getDateTime in
            guard let self = self else { return }
            self.workoutTimeSlotLbl.text = getDateTime
            self.startDateTimeStr = getDateTime
        }
        vc.selectedDate = DateFormatterHelper.shared.dateFromString(from: self.startDateTimeStr ?? "", format: "dd-MM-yyyy, hh:mm a") 
        
        self.navigationController?.present(vc, animated: false)
    }
    
    
    enum WorkoutBtntag: Int {
    case repsFrequency = 801, notifyMe, minusBtn, plusBtn, circuitSettingShow, addExercise, addSupersetExercise, saveExercises, addSupersetRest
    }
    
    @IBAction func createWorkoutCommonBtnActn(_ sender: UIButton) {
        switch sender.tag {
        case WorkoutBtntag.repsFrequency.rawValue:
            print("repsFrequency btn clicked.")
            
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
            
            if let _ = weekDaysFreq {
                vc.weekDaysFreq = self.weekDaysFreq
            }
            if let endDateStr = endDateStr {
                vc.dateStr = endDateStr
            }
            if let localDaysFreq = localDaysFreq {
                vc.localDaysFreq = localDaysFreq
            }
            
            self.navigationController?.present(vc, animated: false)
            
            break
        case WorkoutBtntag.notifyMe.rawValue:
            print("notifyMe btn clicked.")
            
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
            
            break
        case WorkoutBtntag.minusBtn.rawValue:
            print("minusBtn btn clicked.")
            guard plusCount > 1 else {
                return
            }
            plusCount -= 1
            
            break
        case WorkoutBtntag.plusBtn.rawValue:
            print("plusBtn btn clicked.")
            guard plusCount > 0 else {
                return
            }
            plusCount += 1
            break
        case WorkoutBtntag.circuitSettingShow.rawValue:
            print("circuitSettingShow btn clicked.")
            showCircuitSettingsBtn.isSelected = !showCircuitSettingsBtn.isSelected
            
            if showCircuitSettingsBtn.isSelected {
                setRoundsMStckV.isHidden = true
                restInCircuitOuterMBV.isHidden = true
                showCircuitSettingsBtn.setTitle(" Show Circuit Settings", for: .normal)
                showCircuitSettingsBtn.setImage(UIImage(named: "ic_arrow_up_White"), for: .normal)
            }else{
                setRoundsMStckV.isHidden = false
                restInCircuitOuterMBV.isHidden = false
                showCircuitSettingsBtn.setTitle("Hide Circuit Settings", for: .normal)
                showCircuitSettingsBtn.setImage(UIImage(named: "ic_downArrow"), for: .normal)
            }
            
            break
            
        case WorkoutBtntag.addExercise.rawValue:
            print("addExercise btn clicked.")
            
            if let titleLbl = self.addExerciseBtn.titleLabel, titleLbl.text?.lowercased() == "Add a new Superset".lowercased(){
                self.enableContinueBtn(isSelected: false, btn: saveBtn)
            }else{
                self.enableContinueBtn(isSelected: true, btn: saveBtn)
            }
            
            //MARK: --------------------- ADD EXERCISE/
            if let workoutId = getSupsetWorkoutData?.workoutId?.value, !workoutId.isEmpty , let supersetData = self.supersetData, supersetData.count > 0 {
                
                self.exerciseTblViewHeightConstrnt.constant = 90
              /*
                self.supersetData?.removeAll()
                self.supersetExerciseData?.removeAll() //add supersetExerciseData
                self.exerciseData?.removeAll()
                self.exerciseTblView.reloadData()
                self.setInputData()
                self.addExerciseBtn.setTitle("Add Exercise", for: .normal)
                self.saveBtn.isHidden = true
                */
                
                if let localSupersetExerciseData = self.localSupersetExerciseData, localSupersetExerciseData.count > 0 && !localSupersetExerciseData.isEmpty {
                    
                    self.supersetData?.removeAll()
                    self.supersetExerciseData?.removeAll() //add supersetExerciseData
                    self.exerciseData?.removeAll()
                    self.exerciseData?.append(contentsOf: self.localSupersetExerciseData ?? [])
                    self.exerciseTblView.reloadData()
                    self.addExerciseBtn.setTitle("Add Exercise", for: .normal)
                    self.saveBtn.setTitle("CREATE SUPERSET GROUP", for: .normal)
                    self.addRestMBV.isHidden = true
                    
                }else{
                    self.supersetData?.removeAll()
                    self.supersetExerciseData?.removeAll() //add supersetExerciseData
                    self.exerciseData?.removeAll()
                    self.exerciseTblView.reloadData()
                    self.setInputData()
                    self.addExerciseBtn.setTitle("Add Exercise", for: .normal)
                    self.saveBtn.isHidden = true
                }
                
                
//                if let supersetData = self.supersetData, supersetData.count < 1 {
//                    let vc:ChooseExerciseViewController = ChooseExerciseViewController.instantiate(appStoryboard: .calendar)
//                    vc.sentExerciseData = { [weak self] getData in
//                        
//                        guard let self = self , let getData = getData else { return }
//                        
//                        if getData.count > 0 {
//                            self.saveBtn.isHidden = false
//                            self.exerciseData?.removeAll()
//                            self.exerciseData = getData.map { item in
//                                var newItem = item
//                                newItem.type = FlexibleValue(value: "exercise")
//                                return newItem
//                            }
//                            self.setActionflow()
//                        }
//                    }
//                    
//                    if let exerciseData = self.exerciseData, !exerciseData.isEmpty {
//                        let originalData = self.exerciseData
//                        let exerciseWithoutRestData: [ExercisesDatailsModel] = originalData?.filter { $0.localRest?.value?.lowercased() != "localrest" } ?? []
//                        
//                        vc.selectedExerciseData?.removeAll()
//                        vc.selectedExerciseData = exerciseWithoutRestData
//                    }
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
                
            }else{
                print("New circuit/superset")
                
                let vc:ChooseExerciseViewController = ChooseExerciseViewController.instantiate(appStoryboard: .calendar)
                vc.sentExerciseData = { [weak self] getData in
                    
                    guard let self = self , let getData = getData else { return }
                    
                    if getData.count > 0 {
                        self.saveBtn.isHidden = false
                        self.exerciseData?.removeAll()
                        self.exerciseData = getData.map { item in
                            var newItem = item
                            newItem.type = FlexibleValue(value: "exercise")
                            return newItem
                        }
                        
                        self.setActionflow()
                        
                        /*
                        ///------------------
                        if restCircuitSwtch.isSelected{
                            self.insertLocalRestBetweenEachExercises()
                        }else{
                            self.exerciseData = keepOnlyLastRest(from: self.exerciseData ?? [], restDuration: self.restAfterForAllTimeStr)
                            self.exerciseTblView.reloadData()
                        }
                        //---------------------***********
                        self.caloriesCount = 1
                        */
                        
                    }
                }
                
                if let exerciseData = self.exerciseData, !exerciseData.isEmpty {
                    let originalData = self.exerciseData
//                    let exerciseWithoutRestData: [ExercisesDatailsModel] = originalData?.filter { $0.localRest?.value?.lowercased() != "localrest"} ?? []
                                        
                    let exerciseWithoutRestData: [ExercisesDatailsModel] = originalData?.filter {
                        $0.localRest?.value?.lowercased() != "localrest" &&
                        $0.type?.value?.lowercased() != "rest"
                    } ?? []
                    
                    vc.selectedExerciseData?.removeAll()
                    vc.selectedExerciseData = exerciseWithoutRestData
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case WorkoutBtntag.addSupersetExercise.rawValue:
            //MARK: ----------------When came for edit superset
            self.enableContinueBtn(isSelected: false, btn: saveBtn)
            
            let vc:ChooseExerciseViewController = ChooseExerciseViewController.instantiate(appStoryboard: .calendar)
            vc.sentExerciseData = { [weak self] getData in
                
                guard let self = self , let getData = getData else { return }
                
                if getData.count > 0 {
                    self.saveBtn.isHidden = false
                    self.exerciseData?.removeAll()
                    self.exerciseData = getData.map { item in
                        var newItem = item
                        newItem.type = FlexibleValue(value: "exercise")
                        return newItem
                    }
                    
                    self.addSupersetExerciseBtn.isHidden = true
                    self.addRestBtn.isHidden = true
                    self.supersetData?.removeAll()
                    
                    //----------------*****************
                    self.supersetNoteMBV.isHidden = true
                    self.addRestBtnHeightConstrnt.constant = 90.0
                    self.addExerciseBtnHeightConstrnt.constant = 90.0
                    self.addExerciseMBV.layoutIfNeeded()
                    self.saveBtn.layoutIfNeeded()
                    
                    self.exerciseTblView.reloadData()
                   
                    //---------------------***********
                    self.caloriesCount = 1
                    
                    self.addExerciseBtn.setTitle("Add Exercise", for: .normal)
                    self.saveBtn.setTitle("CREATE SUPERSET GROUP", for: .normal)
                  
                }
            }
            
            if let exerciseData = self.exerciseData, !exerciseData.isEmpty {
                let originalData = self.exerciseData
                let exerciseWithoutRestData: [ExercisesDatailsModel] = originalData?.filter {
                    $0.localRest?.value?.lowercased() != "localrest" &&
                    $0.type?.value?.lowercased() != "rest"
                } ?? []
                
                vc.selectedExerciseData?.removeAll()
                vc.selectedExerciseData = exerciseWithoutRestData
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
       
            
            break
            
        case WorkoutBtntag.saveExercises.rawValue:
            print("saveExercises btn clicked.")
            //MARK: ------------------ SAVE EXERCISE
            self.createCircuitWorkoutParam?.name = self.workoutNameTxtField.text
            self.createCircuitWorkoutParam?.category_id = 1
            self.createCircuitWorkoutParam?.type = "circuit"
            self.createCircuitWorkoutParam?.remind_me = self.reminderTime?.id?.value
            self.createCircuitWorkoutParam?.repeat_duration = Int(self.weekDaysFreq ?? "1")
            self.createCircuitWorkoutParam?.repeat_days = self.localDaysFreq?.joined(separator: ",") ?? " "
            self.createCircuitWorkoutParam?.start_date = DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "yyy-MM-dd")
            self.createCircuitWorkoutParam?.end_date = self.endDateStr
            self.createCircuitWorkoutParam?.time = DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "hh:mm a")
            self.createCircuitWorkoutParam?.rest_status = self.restCircuitSwtch.isSelected
            self.createCircuitWorkoutParam?.sets_round = self.circuitRestCountLbl.text
            
            //----------------- Exercises
            addExerciseData?.removeAll()
            
            if let exerciseData = exerciseData {
                for item in exerciseData {
                    var getExerData = ExerciseModel()
                    getExerData.id = Int(item.id?.value ?? "")
                    getExerData.type = item.type?.value
                    getExerData.sets = item.type?.value?.lowercased() == "rest" ? nil : Int(item.sets?.value ?? "3")
                    
//                    getExerData.reps = Int(item.reps?.value ?? "")
                    if let reps = item.reps?.value, !reps.isEmpty {
                        getExerData.reps = Int(item.reps?.value ?? "")
                    }else{
                        getExerData.reps = Int(item.raps?.value ?? "")
                    }
                    
                    getExerData.rest_duration = Int(item.restDuration?.value ?? "1")
                    getExerData.time_type = 2
                    // Append the new object
                    addExerciseData?.append(getExerData)
                }
            }
            
            createCircuitWorkoutParam?.exercises?.removeAll()
            createCircuitWorkoutParam?.exercises = addExerciseData
            
            /*
            if isValid() {
                print("Api circuit called........")
                print("createCircuitWorkoutParam: ", createCircuitWorkoutParam as Any)
                WorkoutLibraryVM.createWorkoutApi(inputWorkout: createCircuitWorkoutParam, completion: {[weak self] gteResultData in
                    guard let self = self else { return }
                    
                    self.navigationController?.popViewController(animated: true)
                })
            }
            */
           
            
//MARK:  ---------------Create workout flow
            switch createWorkoutFlow {
            case .superCreateWorkout:
                print("CREATE SUPERSET GROUP")
                
                if let supersetData = supersetData , let workoutId = getSupsetWorkoutData?.workoutId?.value, !workoutId.isEmpty && supersetData.count > 0 {
                    self.createSupersetRequest()
                    
                }else{
                    
                    if isValid() {
                        if let supersetExerciseData = supersetExerciseData, !supersetExerciseData.isEmpty, supersetExerciseData.count >= 2 {
                            
                            self.localSupersetExerciseData?.removeAll()
                            self.localSupersetExerciseData?.append(contentsOf: self.exerciseData ?? [])
            
                            let vc:WorkoutTypeViewController = WorkoutTypeViewController.instantiate(appStoryboard: .calendar)
                            vc.supersetCout = self.supersetCount
                            vc.createSupersetWorkoutParam = self.createCircuitWorkoutParam
                            vc.supersetExerciseData = supersetExerciseData
                            vc.workoutIdStr = self.getSupsetWorkoutData?.workoutId?.value
                            
                            if let restExerciseData = self.restExerciseData, restExerciseData.count > 0 && !restExerciseData.isEmpty {
                                vc.restTimeData = restExerciseData.first
                            }
                            
                            vc.modalPresentationStyle = .automatic
                            
                            vc.sentBackWorkoutId = {[weak self] getWorkoutId in
                                guard let self = self else { return }
                                self.getCreatedWorkouts(inputWorkId: getWorkoutId)
                            }
                            
                            //------------for Edit exercise
                            vc.editSupersetExercise = {[weak self] editExerciseIdStr in
                                guard let editExerciseIdStr = editExerciseIdStr else { return }
                                
                                let selectedIndx = self?.supersetExerciseData?.firstIndex(where: { $0.id?.value == editExerciseIdStr })
                                
                                if let selectedIndx = selectedIndx {
                                    let vc: EditRegularExerciseViewController = EditRegularExerciseViewController.instantiate(appStoryboard: .calendar)
                                    
                                    vc.createWorkoutFlow = .superCreateWorkout
                                    vc.exerciseName = supersetExerciseData[selectedIndx].name?.value
                                    vc.exerciseImgStr = supersetExerciseData[selectedIndx].image?.value
                                    vc.durationStr = supersetExerciseData[selectedIndx].duration?.value
                                    vc.restTimeStr = supersetExerciseData[selectedIndx].duration?.value
                                    vc.caloriesStr = supersetExerciseData[selectedIndx].calories?.value
                                    vc.inputSetsCont = Int(supersetExerciseData[selectedIndx].sets?.value ?? "3")
                                    if let reps = supersetExerciseData[selectedIndx].reps?.value, !reps.isEmpty {
                                        vc.inputRepsCont = Int(reps)
                                    }else{
                                        vc.inputRepsCont = Int(supersetExerciseData[selectedIndx].raps?.value ?? "1")
                                    }
                                    
                                    vc.sentEditedData = {[weak self] (setsCount, repsCount, restTime, noteDesc) in
                                        if let repsCount = repsCount {
                                            //--------------For Exercise Data
                                            if let exerciseDataIndx = self?.exerciseData?.firstIndex(where: { $0.id?.value == self?.supersetExerciseData?[selectedIndx].id?.value }) {
                                               
                                                if let reps = self?.exerciseData?[exerciseDataIndx].reps?.value, !reps.isEmpty {
                                                    self?.exerciseData?[exerciseDataIndx].reps?.value = "\(repsCount)"
                                                }else{
                                                    self?.exerciseData?[exerciseDataIndx].raps?.value = "\(repsCount)"
                                                }
                                                
                                                self?.exerciseData?[exerciseDataIndx].sets?.value = "\(setsCount ?? 3)"
                                                self?.exerciseData?[exerciseDataIndx].duration?.value = restTime
                                                self?.exerciseTblView.reloadData()
                                                
                                                //--------------FOR SUPERSET SELECTED GROUPS
                                                if let supsetIndx = self?.supersetExerciseData?.firstIndex(where: { $0.id?.value == self?.exerciseData?[exerciseDataIndx].id?.value }) {
                                                    
                                                    if let reps = self?.exerciseData?[exerciseDataIndx].reps?.value, !reps.isEmpty {
                                                        self?.supersetExerciseData?[supsetIndx].reps?.value = "\(repsCount)"
                                                    }else{
                                                        self?.supersetExerciseData?[supsetIndx].raps?.value = "\(repsCount)"
                                                    }
                                                }
                                            }
                                            
                                            /*
                                            //--------------FOR SUPERSET SELECTED GROUPS
                                            if let supsetIndx = self?.supersetExerciseData?.firstIndex(where: { $0.id?.value == self?.exerciseData?[selectedIndx].id?.value }) {
                                                
                                                if let reps = self?.exerciseData?[selectedIndx].reps?.value, !reps.isEmpty {
                                                    self?.supersetExerciseData?[supsetIndx].reps?.value = "\(repsCount)"
                                                }else{
                                                    self?.supersetExerciseData?[supsetIndx].raps?.value = "\(repsCount)"
                                                }
                                            }
                                            */
                                        }
                                    }
                                    self?.navigationController?.pushViewController(vc, animated: true)
                                    
                                }
                            }
                            
                        
                            //--------------**********
                            /*
                             vc.deleteSupersetExercise = {[weak self] deletedIdStr in
                             guard let deletedIdStr = deletedIdStr else { return }
                             
                             let selectedIndx = self?.exerciseData?.firstIndex(where: { $0.id?.value == deletedIdStr })
                             
                             if let selectedIndx = selectedIndx {
                             self?.exerciseData?[selectedIndx].isSupersetDeleted = true
                             self?.exerciseTblView.reloadData()
                             }
                             
                             if let supersetDeleteIndx = self?.supersetExerciseData?.firstIndex(where: { $0.id?.value == deletedIdStr }){
                             self?.supersetExerciseData?.remove(at: supersetDeleteIndx)
                             }
                             }
                             */
                            
                            self.navigationController?.present(vc, animated: true)
                        }else{
                            AlertHelper.shared.showCustomeAlert(message: "Please add at least two exercises to create a superset.")
                        }
                    }
                }
           
                /*
                    if isValid() {
                        if let supersetExerciseData = supersetExerciseData, !supersetExerciseData.isEmpty, supersetExerciseData.count >= 2 {
                            let vc:WorkoutTypeViewController = WorkoutTypeViewController.instantiate(appStoryboard: .calendar)
                            vc.createSupersetWorkoutParam = self.createCircuitWorkoutParam
                            vc.supersetExerciseData = supersetExerciseData
                            vc.modalPresentationStyle = .automatic
                            
                            vc.sentBackWorkoutId = {[weak self] getWorkoutId in
                                guard let self = self else { return }
                                
                                self.getCreatedWorkouts(inputWorkId: getWorkoutId)
                                
        //                        if let isCreateGroup = isCreateGroup {
        //                            self.addRestMBV.isHidden = false
        //                            self.isSupersetCreated = isCreateGroup
        ////                            self.exerciseData = orgnData
        //                            self.exerciseTblView.reloadData()
        //                        }
                            }
                            
                            self.navigationController?.present(vc, animated: true)
                    }

                }else{
                    AlertHelper.shared.showCustomeAlert(message: "Please add at least two exercises to create a superset.")
                }
                 */
                
                break
            case .circuitCreateWorkout:
                
                if isValid() {
                    if let getWorkoutId = self.getSupsetWorkoutData?.workoutId?.value, let inputWorkoutId = Int(getWorkoutId) {
                        createCircuitWorkoutParam?.id = inputWorkoutId
                    }
                    
                    print("createCircuitWorkoutParam: ", createCircuitWorkoutParam as Any)
                    WorkoutLibraryVM.createWorkoutApi(inputWorkout: createCircuitWorkoutParam, completion: {[weak self] gteResultData in
                        guard let self = self else { return }
                        
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                
                break
            case .regularCreateWorkout, .defaultWorkout:
                print("None of theses....")
                break
            }
            
            break
            
        case WorkoutBtntag.addSupersetRest.rawValue:
            print("Add rest superset")
            //MARK: ------------------- ADD SUPERSET REST
            self.restAfterForAllTimeStr = "60"
            
            let supersetOriginalData = self.supersetData
            
            if let last = self.supersetData?.last, last.type?.value?.lowercased() != "rest" {
//                self.supersetData = supersetOnlyLastRest(from: self.supersetData ?? [], restDuration: self.restAfterForAllTimeStr)
                self.supersetData?.removeAll()
                self.supersetData = supersetOnlyLastRest(from: supersetOriginalData ?? [], restDuration: self.restAfterForAllTimeStr)
                
                self.exerciseTblView.reloadData()
                
//                -------------- Rest Add
                if let supersetData = supersetData , let workoutId = getSupsetWorkoutData?.workoutId?.value, !workoutId.isEmpty && supersetData.count > 0 {
                    
                    self.createSupersetRestRequest()
                    
                }
                
                //MARK: -------------- ADD REST TIME
                let restDurationFilterData = self.supersetData?.filter { $0.type?.value?.lowercased() == "rest"}
                
                let restItem = ExercisesDatailsModel(
                    type: FlexibleValue(value: "rest"),
                    localRest: FlexibleValue(value: "localrest"),
                    timeType: FlexibleValue(value: "2"),
                    restDuration: FlexibleValue(value: "60")
                )
                
                self.restExerciseData?.removeAll()
                self.restExerciseData?.append(restItem)
            }
            
//            self.supersetData = supersetOnlyLastRest(from: self.supersetData ?? [], restDuration: self.restAfterForAllTimeStr)
//            print("supersetData: ", self.supersetData as Any)
//            self.exerciseTblView.reloadData()
            
            break
            
        default:
            print("none...")
            break
        }
    }
    
    private func setActionflow(){
        
        self.saveBtn.isHidden = false
        
        switch createWorkoutFlow {
        case .superCreateWorkout:
            self.addRestMBV.isHidden = true
            self.supersetNoteMBV.isHidden = true
            self.addRestBtnHeightConstrnt.constant = 90.0
            self.addExerciseBtnHeightConstrnt.constant = 90.0
            self.addExerciseMBV.layoutIfNeeded()
            self.saveBtn.layoutIfNeeded()
            
            self.exerciseTblView.reloadData()
           
            //---------------------***********
            self.caloriesCount = 1
            
            self.saveBtn.setTitle("CREATE SUPERSET GROUP", for: .normal)
            
            //----------------------
            if let supersetExerciseData = supersetExerciseData, supersetExerciseData.count > 1 {
                self.enableContinueBtn(isSelected: true, btn: saveBtn)
            }else{
                self.enableContinueBtn(isSelected: false, btn: saveBtn)
            }
            
            break
            
        case .circuitCreateWorkout:
            self.addExerciseBtnHeightConstrnt.constant = 90.0
            self.addExerciseMBV.layoutIfNeeded()
            self.saveBtn.layoutIfNeeded()
            
            ///------------------MAKE IT FOR REST
            /*
            if restCircuitSwtch.isSelected{
                self.insertLocalRestBetweenEachExercises()
            }else{
                self.exerciseData = keepOnlyLastRest(from: self.exerciseData ?? [], restDuration: self.restAfterForAllTimeStr)
                self.exerciseTblView.reloadData()
            }
            */
            
            if let workoutId = getSupsetWorkoutData?.workoutId?.value, !workoutId.isEmpty, let type = getSupsetWorkoutData?.type?.value, type.lowercased() == "circuit" {
                if restCircuitSwtch.isSelected{
                    self.insertLocalRestBetweenEachExercises()
                }else{
                    let restDurationFilterData = self.restExerciseData?.filter { $0.type?.value?.lowercased() == "rest" || $0.localRest?.value?.lowercased() == "localrest" }
                    
                    if (restDurationFilterData?.count ?? 0) > 1{
                        self.insertLocalRestBetweenEachExercises()
                    }else{
//                        self.restAfterForAllTimeStr = restDurationFilterData?.first?.restDuration?.value ?? "1"
                        if let restTimeStr = restDurationFilterData?.first?.restDuration?.value {
                            self.restAfterForAllTimeStr = restTimeStr
                        }else{
                            self.restAfterForAllTimeStr = "1"
                        }
                        
                        self.exerciseData = keepOnlyLastRest(from: self.exerciseData ?? [], restDuration: self.restAfterForAllTimeStr)
                        self.exerciseTblView.reloadData()
                    }
                }
                
                //                    self.restAfterForAllTimeStr = restDurationFilterData?.first?.restDuration?.value
                //                    self.exerciseData = keepOnlyLastRest(from: self.exerciseData ?? [], restDuration: self.restAfterForAllTimeStr)
                //                    self.exerciseTblView.reloadData()
                
                self.caloriesCount = 1
                self.saveBtn.setTitle("SAVE", for: .normal)
                self.exerciseTblView.reloadData()
                
                
                
                //---------------------***********
                /*
                let originalData: [ExercisesDatailsModel] = self.exerciseData ?? []
                self.exerciseData?.removeAll()
                let exerciseNonRest = originalData.filter { $0.type?.value != "rest" }
                self.exerciseData = exerciseNonRest
                */
                
            }else{
                if restCircuitSwtch.isSelected{
                    self.insertLocalRestBetweenEachExercises()
                }else{
                    self.exerciseData = keepOnlyLastRest(from: self.exerciseData ?? [], restDuration: self.restAfterForAllTimeStr)
                    self.exerciseTblView.reloadData()
                }
                
                //---------------------***********
                self.caloriesCount = 1
                
                
                self.saveBtn.setTitle("SAVE", for: .normal)
            }
            
//            //---------------------***********
//            self.caloriesCount = 1
//            
//            
//            self.saveBtn.setTitle("SAVE", for: .normal)
            break
        case .regularCreateWorkout, .defaultWorkout:
            print("None of theses....")
            break
        }
        
    }
    
    private func supersetCreated(){
        self.saveBtn.isHidden = false
        self.addRestMBV.isHidden = false
        self.supersetNoteMBV.isHidden = true
        self.addRestBtnHeightConstrnt.constant = 90.0
        self.addExerciseBtnHeightConstrnt.constant = 90.0
        self.addExerciseMBV.layoutIfNeeded()
        self.saveBtn.layoutIfNeeded()
        
//        self.exerciseTblView.reloadData()
        self.saveBtn.setTitle("SAVE", for: .normal)
    }
    
    private func createSupersetRequest(){
        print("supersetData: ", self.supersetData as Any)
        
        let apiModels: [SupersetModelAPI] = self.supersetData ?? []
        
        let supersetGroups: [SupersetModel] = apiModels.map { api in
            SupersetModel(
                type: api.type,
                exercises: api.exercises?.map { exercise in
                    SupersetExerciseModel(
                        id: FlexibleValue(value: exercise.id?.value),
                        type: FlexibleValue(value: "exercise"),
                        sets: FlexibleValue(value: exercise.sets?.value),
                        reps: FlexibleValue(value: exercise.reps?.value),
                        timeType: FlexibleValue(value: "2")
                    )
                },
                duration: api.duration
            )
        }
        
        print("supersetGroups: ", supersetGroups)
        let makeSuperSet = SupersetWorkoutModel(
            id: FlexibleValue(value: self.getSupsetWorkoutData?.workoutId?.value),
            name: FlexibleValue(value:  self.workoutNameTxtField.text),
            description: FlexibleValue(value: self.getSupsetWorkoutData?.description?.value),
            type: FlexibleValue(value: self.getSupsetWorkoutData?.type?.value),
            isSetNew: false,
            categoryID: FlexibleValue(value: self.getSupsetWorkoutData?.categoryID?.value),
            repeatDuration: FlexibleValue(value: self.weekDaysFreq),
            repeatDays: FlexibleValue(value: self.localDaysFreq?.joined(separator: ",") ?? " "),
            startDate: FlexibleValue(value: DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "yyy-MM-dd")),
            endDate: FlexibleValue(value: self.endDateStr),
            time: FlexibleValue(value: DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "hh:mm a")),
            remindMe: FlexibleValue(value: self.reminderTime?.id?.value),
            supersets: supersetGroups
        )
        
        print("Super sets: ", makeSuperSet)
        WorkoutLibraryVM.createSupersetWorkoutApi(inputWorkout: makeSuperSet, completion: {[weak self] getResultData in
            guard let self = self else { return  }
            print("getResultData: ", getResultData?.data?.workout_id?.value as Any)
            self.navigationController?.popViewController(animated: true)
        })
        
        //        var getSuperetExercises: [SupersetExerciseModel]? = []
        //        getSuperetExercises?.removeAll()
        //
        //        let allSuperetExercises: [SupersetExerciseModel] = getSupsetWorkoutData?.supersets?.compactMap{
        //            $0.exercises?.compactMap{
        //                let exerData =  SupersetExerciseModel(
        //                    id: FlexibleValue(value: $0.id?.value),
        //                    type: FlexibleValue(value: "exercise"),
        //                    sets: FlexibleValue(value: $0.sets?.value),
        //                    reps: FlexibleValue(value: $0.reps?.value),
        //                    timeType: FlexibleValue(value: "2")
        //                )
        //                getSuperetExercises?.append(exerData)
        //            }
        //        } as? [SupersetExerciseModel] ?? []
                
                //        let supersetGroup = SupersetModel(
                //            type:  FlexibleValue(value: "superset"),
                //            exercises: getSuperetExercises,
                //            duration: nil
                //        )
                
                
        //        let getSuperetExercises: [SupersetExerciseModel] = getSupsetWorkoutData?.supersets?
        //            .compactMap { $0.exercises }
        //            .flatMap { exercises in
        //                exercises.compactMap { exercise in
        //                    SupersetExerciseModel(
        //                        id: FlexibleValue(value: exercise.id?.value),
        //                        type: FlexibleValue(value: "exercise"),
        //                        sets: FlexibleValue(value: exercise.sets?.value),
        //                        reps: FlexibleValue(value: exercise.reps?.value),
        //                        timeType: FlexibleValue(value: "2")
        //                    )
        //                }
        //            } ?? []
        //        print("getSuperetExercises: ", getSuperetExercises as Any)
    
    }
    
    //MARK: --------------- REST FOR SUPERSET
    private func createSupersetRestRequest(inputIsSetNew: Bool = true){
        print("supersetData: ", self.supersetData as Any)
        
        let apiModels: [SupersetModelAPI] = self.supersetData ?? []
        
    
        let supersetGroups: [SupersetModel] = apiModels.map { api in
            SupersetModel(
                type: api.type,
                exercises: nil,
                duration: api.duration
            )
        }
        
        /*
        let supersetGroups: [SupersetModel] = apiModels.map { api in
            SupersetModel(
                type: api.type,
                exercises: api.exercises?.map { exercise in
                    SupersetExerciseModel(
                        id: FlexibleValue(value: exercise.id?.value),
                        type: FlexibleValue(value: "exercise"),
                        sets: FlexibleValue(value: exercise.sets?.value),
                        reps: FlexibleValue(value: exercise.reps?.value),
                        timeType: FlexibleValue(value: "2")
                    )
                },
                duration: api.duration
            )
        }
         */
        
        print("supersetGroups: ", supersetGroups)
        let makeSuperSet = SupersetWorkoutModel(
            id: FlexibleValue(value: self.getSupsetWorkoutData?.workoutId?.value),
            name: FlexibleValue(value:  self.workoutNameTxtField.text),
            description: FlexibleValue(value: self.getSupsetWorkoutData?.description?.value),
            type: FlexibleValue(value: self.getSupsetWorkoutData?.type?.value),
            isSetNew: inputIsSetNew,
            categoryID: FlexibleValue(value: self.getSupsetWorkoutData?.categoryID?.value),
            repeatDuration: FlexibleValue(value: self.weekDaysFreq),
            repeatDays: FlexibleValue(value: self.localDaysFreq?.joined(separator: ",") ?? " "),
            startDate: FlexibleValue(value: DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "yyy-MM-dd")),
            endDate: FlexibleValue(value: self.endDateStr),
            time: FlexibleValue(value: DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "hh:mm a")),
            remindMe: FlexibleValue(value: self.reminderTime?.id?.value),
            supersets: supersetGroups
        )
        print("Super sets: ", makeSuperSet)
        
        WorkoutLibraryVM.createSupersetWorkoutApi(inputWorkout: makeSuperSet, isShowLoading: false, completion: {[weak self] getResultData in
            guard self != nil else { return  }
            print("getResultData: ", getResultData?.data?.workout_id?.value as Any)
    
        })
    }
    
    //MARK: ------------------- REST TIME OF SUPERSET
    private func deleteSupersetRestTime(inputIsSetNew: Bool = false){
        print("supersetData: ", self.supersetData as Any)
        
        let apiModels: [SupersetModelAPI] = self.supersetData ?? []
        
        let supersetGroups: [SupersetModel] = apiModels.map { api in
            SupersetModel(
                type: api.type,
                exercises: api.exercises?.map { exercise in
                    SupersetExerciseModel(
                        id: FlexibleValue(value: exercise.id?.value),
                        type: FlexibleValue(value: "exercise"),
                        sets: FlexibleValue(value: exercise.sets?.value),
                        reps: FlexibleValue(value: exercise.reps?.value),
                        timeType: FlexibleValue(value: "2")
                    )
                },
                duration: api.duration
            )
        }
        
        print("supersetGroups: ", supersetGroups)
        let makeSuperSet = SupersetWorkoutModel(
            id: FlexibleValue(value: self.getSupsetWorkoutData?.workoutId?.value),
            name: FlexibleValue(value:  self.workoutNameTxtField.text),
            description: FlexibleValue(value: self.getSupsetWorkoutData?.description?.value),
            type: FlexibleValue(value: self.getSupsetWorkoutData?.type?.value),
            isSetNew: inputIsSetNew,
            categoryID: FlexibleValue(value: self.getSupsetWorkoutData?.categoryID?.value),
            repeatDuration: FlexibleValue(value: self.weekDaysFreq),
            repeatDays: FlexibleValue(value: self.localDaysFreq?.joined(separator: ",") ?? " "),
            startDate: FlexibleValue(value: DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "yyy-MM-dd")),
            endDate: FlexibleValue(value: self.endDateStr),
            time: FlexibleValue(value: DateFormatterHelper.shared.getDateFromFormat(fromDate: self.startDateTimeStr ?? "", fromFormat: "dd-MM-yyyy, hh:mm a", toFormat: "hh:mm a")),
            remindMe: FlexibleValue(value: self.reminderTime?.id?.value),
            supersets: supersetGroups
        )
        
        WorkoutLibraryVM.createSupersetWorkoutApi(inputWorkout: makeSuperSet, isShowLoading: false, completion: {[weak self] getResultData in
            guard self != nil else { return  }
            print("getResultData: ", getResultData?.data?.workout_id?.value as Any)
    
        })
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
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if exerciseTblView.contentSize.height != 0 {
            self.exerciseTblViewHeightConstrnt.constant = exerciseTblView.contentSize.height
        }
        
        if self.noteLstTblView.contentSize.height != 0 {
            self.noteLstTblViewHeightConstrnt.constant = noteLstTblView.contentSize.height
        }
        
        view.layoutIfNeeded()
    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false, btn:UIButton){
        if isSelected {
            btn.isUserInteractionEnabled = true
            btn.backgroundColor = UIColor.appWhite
            btn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            btn.isUserInteractionEnabled = false
            btn.backgroundColor = UIColor.appDarkGray
            btn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    private func setTimerUI(){
        restTimePicker.translatesAutoresizingMaskIntoConstraints = false
        restTimeScaleMBV.addSubview(restTimePicker)
              
              NSLayoutConstraint.activate([
                  restTimePicker.topAnchor.constraint(equalTo: restTimeScaleMBV.topAnchor),
                  restTimePicker.bottomAnchor.constraint(equalTo: restTimeScaleMBV.bottomAnchor),
                  restTimePicker.leadingAnchor.constraint(equalTo: restTimeScaleMBV.leadingAnchor),
                  restTimePicker.trailingAnchor.constraint(equalTo: restTimeScaleMBV.trailingAnchor),
              ])
              
              restTimePicker.selectedValue = {[weak self] value in
                  guard self != nil else {
                      return
                  }
                  print("Selected Rest Time: \(value) seconds")
                  self?.restAfterForAllTimeStr = "\(value)"
                  
              }
    }
    
    private func setupFont(){

        self.circuitRestCountLbl.font = AppFont.bold.size(25.0, familyName: familyManrope) //32
        self.showCircuitSettingsBtn.titleLabel?.font = AppFont.regular.size(12.0, familyName: familyManrope)
        
        self.addExerciseBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.addRestBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.saveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.workoutTypeBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.howToTilelbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        [
            circuitRoundsTitleLbl,
            restAfterCircuitLbl,
            restBetweenExerciseTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.medium.size(12.0, familyName: familyManrope)
        })
        
        self.workoutNameTitleLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.workoutNameTxtField.font = AppFont.semibold.size(20.0, familyName: familyManrope)
        self.workoutNameTxtField.setPlaceholder(text: "Eg: Shoulder day", font: AppFont.semibold.size(20.0, familyName: familyManrope), color: UIColor(red: 137.0/255.0, green: 131/255.0, blue: 132/255.0, alpha: 1.0))
        
        self.workoutTimeSlotLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        
        [
            self.repsFrequencyBtn.titleLabel,
            self.notifyBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.bold.size(12.0, familyName: familyManrope)
        })
        //14.0
        
        [
            self.durationTimeLbl,
            self.caloriesCountLbl,
            self.exercisesCountLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.regular.size(20.0, familyName: familyClashDisplay)
        })
       
        [
            self.durationTitleLbl,
            self.caloriesTitleLbl,
            self.exercisesTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        })
    }
    
    private func setupUI(){
        showCircuitSettingsBtn.setTitle(" Hide Circuit Settings", for: .normal)
        showCircuitSettingsBtn.setImage(UIImage(named: "ic_downArrow"), for: .normal)
        
        DispatchQueue.main.async {
            self.restCircuitSwtch.selectedColor = UIColor.appYellow
            self.restCircuitSwtch.deSelectedColor = UIColor.appLightGray
            self.userImgView.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.txtDarkGray, cornerRadious: 8.0)
            self.workoutTypeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.workoutTypeBtn.frame.height/2.0)
           
            self.repsFrequencyBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.notifyBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            
            self.addExerciseBtn.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 16.0, dashPattern: [15,8])
            
            //------------------Gradient
            [self.durationMBV,self.caloriesMBV,self.exerciseMBV].forEach({
                $0.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
            })
            
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            [
                self.circuitRoundsMBV,
                self.restTimeMBV,
                self.restInCircuitMBV
            ].forEach({[weak self] in
                guard self != nil else {
                    return
                }
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            })
            
            self.addSupersetExerciseBtn.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 16.0, dashPattern: [15,8])
            self.addRestBtn.addDashedBorder(UIColor(red: 49/255.0, green: 52/255.0, blue: 58/255.0, alpha: 1), filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 16.0, dashPattern: [15,8])
            self.supersetNoteDescMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
}

extension CreateWorkoutViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return exerciseData?.count ?? 0
        
        if tableView == exerciseTblView {
            if let supersetData = supersetData , let workoutId = getSupsetWorkoutData?.workoutId?.value, !workoutId.isEmpty && supersetData.count > 0 {
                return supersetData.count
                
            }else{
                return exerciseData?.count ?? 0
            }
        }else{
            return noteData?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //--------------------#********************
        switch createWorkoutFlow {
        case .superCreateWorkout:
            
            if tableView == exerciseTblView {
                
                if let supersetData = self.supersetData, let workoutId = getSupsetWorkoutData?.workoutId?.value, !workoutId.isEmpty && supersetData.count > 0 {
                    let supersetGroupCell: SupersetGroupTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "SupersetGroupTableViewCell", for: indexPath) as! SupersetGroupTableViewCell
                    supersetGroupCell.navCtrnl = self.navigationController
                    supersetGroupCell.workoutIdStr = self.getSupsetWorkoutData?.workoutId?.value
                    supersetGroupCell.setsData = self.supersetData?[indexPath.row].exercises
                    
                    supersetGroupCell.delegate = self
                    
                    let supersetItem = supersetData[indexPath.row]
                    
                    if supersetItem.type?.value?.lowercased() == "superset" {
                    
                        let supersetIndex = (self.supersetData?[..<indexPath.row].filter { $0.type?.value?.lowercased() == "superset" }.count ?? 0) + 1
                        supersetGroupCell.supersetCountLbl.text = "Superset " + "\(supersetIndex)"
                        supersetCount = supersetIndex + 1
                        return supersetGroupCell
                        
                    }else{
                        let restCell:RestTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "RestTableViewCell", for: indexPath) as! RestTableViewCell
                        restCell.deleteDelegate = self
                        restCell.lblSeconds.text =  (supersetData[indexPath.row].duration?.value ?? "") + " seconds"
                        
                        return restCell
                    }
                    
                }else{
                    
                    let item = exerciseData?[indexPath.row]
                    
                    if item?.type?.value?.lowercased() == "exercise" {
                        let supersetExerciseCell:SupersetExercisesTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "SupersetExercisesTableViewCell", for: indexPath) as! SupersetExercisesTableViewCell
                        
                        supersetExerciseCell.setCellData(cellData: exerciseData?[indexPath.row])
                        supersetExerciseCell.editMenuBtn.setImage(UIImage(named: "ic_moreSettings"), for: .normal)
                        supersetExerciseCell.setupMenuActn()
                        supersetExerciseCell.onMenuBtnTapped = { [weak self, weak supersetExerciseCell] button in
                            guard let self = self, let cell = supersetExerciseCell else { return }
                            self.editCustomMenuSuperset(for: cell, at: indexPath, from: button)
                        }
                        
                        supersetExerciseCell.selectedWorkoutBtn.accessibilityHint = exerciseData?[indexPath.row].id?.value
                        supersetExerciseCell.selectedWorkoutBtn.addTarget(self, action: #selector(supersetsetSelectionBtnActn(sender: )), for: .touchUpInside)
                        
                        if let supersetCount = supersetCount {
                            supersetExerciseCell.selectedWorkoutBtn.setTitle("Select for Superset \(supersetCount)", for: .normal)
                        }
                       
                        
//                        if let isSupersetDeleted = exerciseData?[indexPath.row].isSupersetDeleted, isSupersetDeleted {
//                            supersetExerciseCell.selectedWorkoutBtn.isSelected = !isSupersetDeleted
//                        }
                        
                        let alreadySelected = supersetExerciseData?.contains(where: { $0.id?.value == exerciseData?[indexPath.row].id?.value}) ?? false
                        supersetExerciseCell.selectedWorkoutBtn.isSelected = alreadySelected
                        
                        return supersetExerciseCell
                        
                    }else{
                        let restCell:RestTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "RestTableViewCell", for: indexPath) as! RestTableViewCell
                        restCell.deleteDelegate = self
                        restCell.lblSeconds.text = (exerciseData?[indexPath.row].restDuration?.value ?? "") + " seconds"
                        return restCell
                    }
                }
                
                
                /*
                let item = exerciseData?[indexPath.row]
                
                if item?.type?.value?.lowercased() == "exercise" {
                    let supersetExerciseCell:SupersetExercisesTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "SupersetExercisesTableViewCell", for: indexPath) as! SupersetExercisesTableViewCell
                    
                    supersetExerciseCell.setCellData(cellData: exerciseData?[indexPath.row])
                    supersetExerciseCell.editMenuBtn.setImage(UIImage(named: "ic_moreSettings"), for: .normal)
                    supersetExerciseCell.setupMenuActn()
                    supersetExerciseCell.onMenuBtnTapped = { [weak self, weak supersetExerciseCell] button in
                        guard let self = self, let cell = supersetExerciseCell else { return }
                        self.editCustomMenuSuperset(for: cell, at: indexPath, from: button)
                    }
                    
                    supersetExerciseCell.selectedWorkoutBtn.accessibilityHint = exerciseData?[indexPath.row].id?.value
                    supersetExerciseCell.selectedWorkoutBtn.addTarget(self, action: #selector(supersetsetSelectionBtnActn(sender: )), for: .touchUpInside)
                    
                    return supersetExerciseCell
                    
                }else{
                    let restCell:RestTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "RestTableViewCell", for: indexPath) as! RestTableViewCell
                    restCell.deleteDelegate = self
                    restCell.lblSeconds.text = (exerciseData?[indexPath.row].restDuration?.value ?? "") + " seconds"
                    return restCell
                }
                */
                
                
            }else{
                let noteCell:NoteDescTableViewCell = noteLstTblView.dequeueReusableCell(withIdentifier: "NoteDescTableViewCell", for: indexPath) as! NoteDescTableViewCell
                
                noteCell.noteNumLbl.text = "\(indexPath.row + 1)."
                noteCell.noteDescLbl.text = noteData?[indexPath.row] as? String
                return noteCell
            }
            
        case .circuitCreateWorkout:
            
            if tableView == exerciseTblView {
                let item = exerciseData?[indexPath.row]
                
                if item?.type?.value?.lowercased() == "exercise" {
                    let exerciseCell:ExerciseTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
                    
                    exerciseCell.setCellData(cellData: exerciseData?[indexPath.row])
                    exerciseCell.checkBtn.setImage(UIImage(named: "ic_moreSettings"), for: .normal)
                    exerciseCell.navCtrl = self.navigationController
                    exerciseCell.setupMenuActn()
                    exerciseCell.onMenuBtnTapped = { [weak self, weak exerciseCell] button in
                        guard let self = self, let cell = exerciseCell else { return }
                        self.presentCustomMenuCircuit(for: cell, at: indexPath, from: button)
                    }
                    
                    return exerciseCell
                }else{
                    let restCell:RestTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "RestTableViewCell", for: indexPath) as! RestTableViewCell
                    restCell.deleteDelegate = self
                    restCell.lblSeconds.text = (exerciseData?[indexPath.row].restDuration?.value ?? "") + " seconds"
                    return restCell
                }
            }else{
                let noteCell:NoteDescTableViewCell = noteLstTblView.dequeueReusableCell(withIdentifier: "NoteDescTableViewCell", for: indexPath) as! NoteDescTableViewCell
                
                noteCell.noteNumLbl.text = "\(indexPath.row + 1)."
                noteCell.noteDescLbl.text = noteData?[indexPath.row] as? String
                return noteCell
            }
            
        case .regularCreateWorkout, .defaultWorkout:
            print("None of these....")
            break
        }
        
        
        return UITableViewCell()
        
        /*
        if tableView == exerciseTblView {
            let item = exerciseData?[indexPath.row]
            
            if item?.type?.value?.lowercased() == "exercise" {
                let exerciseCell:ExerciseTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
                
                exerciseCell.setCellData(cellData: exerciseData?[indexPath.row])
                exerciseCell.checkBtn.setImage(UIImage(named: "ic_moreSettings"), for: .normal)
                exerciseCell.navCtrl = self.navigationController
                exerciseCell.setupMenuActn()
                exerciseCell.onMenuBtnTapped = { [weak self, weak exerciseCell] button in
                    guard let self = self, let cell = exerciseCell else { return }
                    self.presentCustomMenu(for: cell, at: indexPath, from: button)
                }
                
                return exerciseCell
            }else{
                let restCell:RestTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "RestTableViewCell", for: indexPath) as! RestTableViewCell
                restCell.deleteDelegate = self
                restCell.lblSeconds.text = (exerciseData?[indexPath.row].restDuration?.value ?? "") + " seconds"
                return restCell
            }
        }else{
            let noteCell:NoteDescTableViewCell = noteLstTblView.dequeueReusableCell(withIdentifier: "NoteDescTableViewCell", for: indexPath) as! NoteDescTableViewCell
            
            noteCell.noteNumLbl.text = "\(indexPath.row + 1)."
            noteCell.noteDescLbl.text = noteData?[indexPath.row] as? String
            return noteCell
        }
        */
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
        if tableView == exerciseTblView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateViewConstraints()
            }
        }
        
//        if tableView == exerciseTblView {
//            DispatchQueue.main.async {
//                self.updateViewConstraints()
//            }
//        }
        
//        if let isSupersetCreated = isSupersetCreated, isSupersetCreated {
//            if exerciseTblView == exerciseTblView {
//                 guard let outerCell = cell as? SupersetTableViewCell else { return }
//                 // Update the inner table height before the outer cell is displayed
//                 DispatchQueue.main.async {
//                     outerCell.updateInnerTableHeight()
//                     outerCell.setsLstTblView.reloadData()
//                     outerCell.layoutIfNeeded()
////                     outerCell.updateInnerTableHeight()
////                     self.updateViewConstraints()
//                     
//                     // Force the outer table to recalc cell heights
////                     self.updateViewConstraints()
//                 }
//               
//             }
//            
//        }else{
//            if tableView == exerciseTblView {
//                DispatchQueue.main.async {
//                    self.updateViewConstraints()
//                }
//            }
//        }
        
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let supersetGroupCell: SupersetTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "SupersetTableViewCell", for: indexPath) as! SupersetTableViewCell

        
        if let nestedTableViewCell = tableView.cellForRow(at: indexPath) as? SupersetTableViewCell {
            let heightNestedTableView = nestedTableViewCell.setsLstTblView.contentSize.height //nestedTableViewCell.setsLstTblView.contentsize.height
            return heightNestedTableView
        } else {
            return tableView.au //UITableViewAutomaticDimension
        } }
    */
    
    
    //MARK: --------------- MAKE SUPERSET BTN ACTN
    @objc func supersetsetSelectionBtnActn(sender: UIButton){
        sender.isSelected = !sender.isSelected
        
        if let selectedExerciseIdStr = sender.accessibilityHint,
           let selectedIndx = exerciseData?.firstIndex(where: { $0.id?.value == selectedExerciseIdStr }),
           let supersetExercise = exerciseData?[selectedIndx] {
            // Check in supersetExerciseData instead of exerciseData
            let alreadySelected = supersetExerciseData?.contains(where: { $0.id?.value == supersetExercise.id?.value }) ?? false
            
            if !alreadySelected {
                //                self.exerciseData?[selectedIndx].isSupersetDeleted = false
                supersetExerciseData?.append(supersetExercise)
                
            } else {
                if let index = supersetExerciseData?.firstIndex(where: { $0.id?.value == supersetExercise.id?.value }) {
                    //                    self.exerciseData?[index].isSupersetDeleted = false
                    supersetExerciseData?.remove(at: index)
                }
            }
            
            //----------------------
            if let supersetExerciseData = supersetExerciseData, supersetExerciseData.count > 1 {
                self.enableContinueBtn(isSelected: true, btn: saveBtn)
            }else{
                self.enableContinueBtn(isSelected: false, btn: saveBtn)
            }
        }
    }
    
    
    func onTimeTap(_ cell: RestTableViewCell)  {
        if let index = exerciseTblView.indexPath(for: cell) {
            let timeBtn: UIButton = cell.btnRest
            
//            self.showMinutePicker(from: cell, tapBtn: timeBtn) {[weak self] totalSeconds in
//                print("totalSeconds: ", totalSeconds)
//                self?.exerciseData?[index.row].restDuration?.value = "\(totalSeconds)"
//                self?.exerciseTblView.reloadRows(at: [index], with: .automatic)
//                cell.setupUI()
//            }
            
            self.showMinutePicker(from: cell, tapBtn: timeBtn) {[weak self] totalSeconds in
                
                if let workoutId = self?.getSupsetWorkoutData?.workoutId?.value, !workoutId.isEmpty, let supersetData = self?.supersetData, supersetData.count > 0 {
                 self?.supersetData?[index.row].duration?.value = "\(totalSeconds)"
                 self?.exerciseTblView.reloadRows(at: [index], with: .automatic)
                 cell.setupUI()
                 
             }else{
                     print("totalSeconds: ", totalSeconds)
                     self?.exerciseData?[index.row].restDuration?.value = "\(totalSeconds)"
                     self?.exerciseTblView.reloadRows(at: [index], with: .automatic)
                     cell.setupUI()
                 }
             }
        }
    }
    
    func onTapCross(_ cell: RestTableViewCell) {
        print("cross clicked..")
//        let originalData = self.exerciseData
//        let filteredData = originalData?.filter { $0.localRest?.value?.lowercased() != "localrest" }
//        self.exerciseData?.removeAll()
//        self.exerciseData = filteredData
//        self.exerciseTblView.reloadData()
        
        if let workoutId = self.getSupsetWorkoutData?.workoutId?.value, !workoutId.isEmpty{
            if let type = getSupsetWorkoutData?.type?.value, type.lowercased() == "circuit" {
                let originalData = self.exerciseData
                let filteredData = originalData?.filter { $0.type?.value?.lowercased() != "rest" }
                self.restCircuitSwtch.isSelected = false
                self.restExerciseData?.removeAll()
                self.exerciseData?.removeAll()
                self.exerciseData = filteredData
                self.exerciseTblView.reloadData()
                
            }else{
                if let indexPath = exerciseTblView.indexPath(for: cell) {
                    // Check if workoutId exists and supersetData is valid
                    if let workoutId = self.getSupsetWorkoutData?.workoutId?.value,
                       !workoutId.isEmpty,
                       var supersetData = self.supersetData,
                       supersetData.indices.contains(indexPath.row) {
                        
                        // Remove the item
                        supersetData.remove(at: indexPath.row)
                        self.supersetData = supersetData
                        
                        // Update table
                        exerciseTblView.deleteRows(at: [indexPath], with: .automatic)
                        
                        // Call your API/update function
                        self.deleteSupersetRestTime()
                    }
                }
                
                /*
                let supersetOriginalData = self.supersetData
                let supersetWithoutRest = supersetOriginalData?.filter { $0.type?.value?.lowercased() != "rest" }
                self.supersetData?.removeAll()
                self.supersetData = supersetWithoutRest
                self.exerciseTblView.reloadData()
                */
            }
            
            //            let supersetOriginalData = self.supersetData
            //            let supersetWithoutRest = supersetOriginalData?.filter { $0.type?.value?.lowercased() != "rest" }
            //            self.supersetData?.removeAll()
            //            self.supersetData = supersetWithoutRest
            //            self.exerciseTblView.reloadData()
            
        }else{
         let originalData = self.exerciseData
         let filteredData = originalData?.filter { $0.localRest?.value?.lowercased() != "localrest" }
         self.exerciseData?.removeAll()
         self.exerciseData = filteredData
         self.exerciseTblView.reloadData()
         }
    }
    
    // MARK: ----------------- TIME PickerView
    
    func showMinutePicker(from sourceView: UIView, tapBtn: UIButton?,
                          completion: @escaping (_ totalSeconds: Int) -> Void) {
        
        let restVC = TimePickerViewController()
        restVC.sentTime = {[weak self] getTime in
            guard self != nil else {
                return
            }
            //(self.selectedMinute * 60) + self.selectedSecond
            if let getTime = getTime{
                let getMin = getTime.components(separatedBy: ":").first
                let getSec = getTime.components(separatedBy: ":").last
                let minutes = Int(getMin ?? "0") ?? 0
                let seconds = Int(getSec ?? "0") ?? 0
                let totalRestSec = (minutes * 60) + seconds
                completion(totalRestSec)
            }
        }
        restVC.modalPresentationStyle = .popover
        restVC.preferredContentSize = CGSize(width: sourceView.bounds.width, height: 250)
        if let popover = restVC.popoverPresentationController {
            popover.delegate = self
            popover.permittedArrowDirections = [.up, .down] // <--arrow
            popover.backgroundColor = UIColor.clear
            
            if let tapBtn = tapBtn {
                popover.sourceView = tapBtn
                popover.sourceRect = tapBtn.bounds
            } else {
                // fallback: use the cell itself
                popover.sourceView = sourceView
                popover.sourceRect = CGRect(
                    x: sourceView.bounds.midX,   // horizontally center
                    y: sourceView.bounds.maxY,   // bottom edge of the button
                    width: 0,
                    height: 0
                )
            }
        }
        present(restVC, animated: true, completion: nil)
        
    }


    //MARK: ---------------CIRCUIT FLOW EDIT / DELETE
    private func presentCustomMenuCircuit(for cell: ExerciseTableViewCell, at indexPath: IndexPath, from sourceView: UIView) {
        
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
                vc.createWorkoutFlow = self.createWorkoutFlow //.circuitCreateWorkout
            
                vc.exerciseName = exerciseData?[indexPath.row].name?.value
                vc.exerciseImgStr = exerciseData?[indexPath.row].image?.value
                vc.durationStr = exerciseData?[indexPath.row].duration?.value //"60s"
                vc.caloriesStr = exerciseData?[indexPath.row].calories?.value
//                vc.inputSetsCont = Int(exerciseData?[indexPath.row].sets?.value ?? "3")
//                vc.inputRepsCont = Int(exerciseData?[indexPath.row].reps?.value ?? "1")
                
                if let reps = exerciseData?[indexPath.row].reps?.value, !reps.isEmpty {
                    vc.inputRepsCont = Int(reps)
                }else{
                    vc.inputRepsCont = Int(exerciseData?[indexPath.row].raps?.value ?? "1")
                }
                 
                //-----------=--------- WHEN EDIT ALREADY CREATED CIRCUIT EXERCISE
                if let position = exerciseData?[indexPath.row].position?.value, !position.isEmpty {
                    vc.setsPositionStr = exerciseData?[indexPath.row].sets_position?.value
                    vc.workoutIdStr = self.workoutIdStr
                    vc.workoutExerciseId = exerciseData?[indexPath.row].id?.value
                }
                
                
                vc.sentEditedData = {[weak self] (setsCount, repsCount, restTime, noteDesc) in
                    if let repsCount = repsCount {
//                        self.exerciseData?[indexPath.row].reps?.value = "\(repsCount)"
                        
                        if let reps = self?.exerciseData?[indexPath.row].reps?.value, !reps.isEmpty {
                            self?.exerciseData?[indexPath.row].reps?.value = "\(repsCount)"
                        }else{
                            self?.exerciseData?[indexPath.row].raps?.value = "\(repsCount)"
                        }
                        
                        //--------------FOR SUPERSET SELECTED GROUPS
                        if let supsetIndx = self?.supersetExerciseData?.firstIndex(where: { $0.id?.value == self?.exerciseData?[indexPath.row].id?.value }) {
                            
                            if let reps = self?.exerciseData?[indexPath.row].reps?.value, !reps.isEmpty {
                                self?.supersetExerciseData?[supsetIndx].reps?.value = "\(repsCount)"
                            }else{
                                self?.supersetExerciseData?[supsetIndx].raps?.value = "\(repsCount)"
                            }
                        }
                        
                        self?.exerciseTblView.reloadData()
                        
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if actionTitle == "Delete" {
                print("Delete is clicked")
                self.dismiss(animated: true) {   // dismiss popover first
                    let vc: DeletePopupViewController = DeletePopupViewController.instantiate(appStoryboard: .calendar)
                    vc.modalPresentationStyle = .automatic
                    vc.delTilteStr = "Delete Exercise"
                    vc.altMsgStr = "You’re going to delete this exercise. Are you sure?"
                    vc.sentBackData = { isDelete in
                        if let isDelete = isDelete, isDelete,
                         let data = self.exerciseData, data.indices.contains(indexPath.row) {
                            
                            //------------------**************Deleted exercise when edit flow for circuit
                            if let workoutIdStr = self.getSupsetWorkoutData?.workoutId?.value, !workoutIdStr.isEmpty, let type = self.getSupsetWorkoutData?.type?.value, type.lowercased() == "circuit", let exerciseIdStr = self.exerciseData?[indexPath.row].workout_exercise_id?.value {
                                
                                WorkoutLibraryVM.deleteWorkoutExerciseApi(inputWorkoutExerciseId: exerciseIdStr, completion: {[weak self] getResultData in
                                    guard let self = self else { return }
                                    self.getCreatedWorkouts(inputWorkId: workoutIdStr)
                                })
                            }else{
                                // Remove current item
                                self.exerciseData?.remove(at: indexPath.row)
                                // Check next item is "localrest"
                                if self.restCircuitSwtch.isSelected {
                                    if let data = self.exerciseData, data.indices.contains(indexPath.row),
                                       data[indexPath.row].localRest?.value?.lowercased() == "localrest" {
                                        self.exerciseData?.remove(at: indexPath.row)
                                    }
                                }
                                self.exerciseTblView.reloadData()
                                
                                //---------*******
                                self.caloriesCount = 1
                            }
                            
                            /*
                            // Remove current item
                            self.exerciseData?.remove(at: indexPath.row)
                            // Check next item is "localrest"
                            if self.restCircuitSwtch.isSelected {
                                if let data = self.exerciseData, data.indices.contains(indexPath.row),
                                   data[indexPath.row].localRest?.value?.lowercased() == "localrest" {
                                    self.exerciseData?.remove(at: indexPath.row)
                                }
                            }
                            self.exerciseTblView.reloadData()
                            
                            //---------*******
                            self.caloriesCount = 1
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
            popover.sourceView = cell.checkBtn //sourceView
            popover.permittedArrowDirections = [] // <-- Remove arrow
            
            popover.sourceRect = CGRect(
                x: cell.checkBtn.bounds.minX - 50,   // horizontally center ,  cell.checkBtn.bounds.minX - 15, -50
                y: cell.checkBtn.bounds.maxY + 60.0,   // bottom edge of the button ,
                width: 0,
                height: 0
            )
            
            /*
            popover.sourceRect = CGRect(
                x: sourceView.bounds.midX - 10,   // horizontally center
                y: sourceView.bounds.maxY + 15.0,   // bottom edge of the button
                width: 0,
                height: 0
            )
            */
            popover.backgroundColor = UIColor.clear
        }
        present(menuVC, animated: true, completion: nil)
       }
    
    //MARK: ------------------ SUPERSET FLOW
    private func editCustomMenuSuperset(for cell: SupersetExercisesTableViewCell, at indexPath: IndexPath, from sourceView: UIView) {
        
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
                
                vc.createWorkoutFlow = self.createWorkoutFlow //.circuitCreateWorkout
                vc.exerciseName = exerciseData?[indexPath.row].name?.value
                vc.exerciseImgStr = exerciseData?[indexPath.row].image?.value
                vc.durationStr = exerciseData?[indexPath.row].duration?.value  //self.getSupsetWorkoutData?.repeatDuration?.value ?? "60s"
                vc.restTimeStr = exerciseData?[indexPath.row].duration?.value
                vc.caloriesStr = exerciseData?[indexPath.row].calories?.value
                vc.inputSetsCont = Int(exerciseData?[indexPath.row].sets?.value ?? "3")
                if let reps = exerciseData?[indexPath.row].reps?.value, !reps.isEmpty {
                    vc.inputRepsCont = Int(reps)
                }else{
                    vc.inputRepsCont = Int(exerciseData?[indexPath.row].raps?.value ?? "1")
                }
                
                vc.sentEditedData = {[weak self] (setsCount, repsCount, restTime, noteDesc) in
                    if let repsCount = repsCount {
//                        self.exerciseData?[indexPath.row].reps?.value = "\(repsCount)"
                        if let reps = self?.exerciseData?[indexPath.row].reps?.value, !reps.isEmpty {
                            self?.exerciseData?[indexPath.row].reps?.value = "\(repsCount)"
                        }else{
                            self?.exerciseData?[indexPath.row].raps?.value = "\(repsCount)"
                        }
                        
                        self?.exerciseData?[indexPath.row].sets?.value = "\(setsCount ?? 3)"
                        self?.exerciseData?[indexPath.row].duration?.value = restTime
                        self?.exerciseTblView.reloadData()
                        
                        //--------------FOR SUPERSET SELECTED GROUPS
                        if let supsetIndx = self?.supersetExerciseData?.firstIndex(where: { $0.id?.value == self?.exerciseData?[indexPath.row].id?.value }) {
                            
                            if let reps = self?.exerciseData?[indexPath.row].reps?.value, !reps.isEmpty {
                                self?.supersetExerciseData?[supsetIndx].reps?.value = "\(repsCount)"
                            }else{
                                self?.supersetExerciseData?[supsetIndx].raps?.value = "\(repsCount)"
                            }
                        }
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if actionTitle == "Delete" {
                print("Delete is clicked")
                self.dismiss(animated: true) {   // dismiss popover first
                    let vc: DeletePopupViewController = DeletePopupViewController.instantiate(appStoryboard: .calendar)
                    vc.modalPresentationStyle = .automatic
                    vc.delTilteStr = "Delete Exercise"
                    vc.altMsgStr = "You’re going to delete this exercise. Are you sure?"
                    vc.sentBackData = { isDelete in
                        if let isDelete = isDelete, isDelete,
                         let data = self.exerciseData, data.indices.contains(indexPath.row) {
                            // Remove current item
                            self.exerciseData?.remove(at: indexPath.row)
                            // Check next item is "localrest"
                            if self.restCircuitSwtch.isSelected {
                                if let data = self.exerciseData, data.indices.contains(indexPath.row),
                                   data[indexPath.row].localRest?.value?.lowercased() == "localrest" {
                                    self.exerciseData?.remove(at: indexPath.row)
                                }
                            }
                            self.exerciseTblView.reloadData()
                            
                            //---------*******
                            self.caloriesCount = 1
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
                x: sourceView.bounds.minX - 50,   // horizontally center , sourceView.bounds.minX - 15
                y: sourceView.bounds.maxY + 60.0,   // bottom edge of the button, sourceView.bounds.maxY + 15.0
                width: 0,
                height: 0
            )
            
            /*
             x: cell.checkBtn.bounds.minX - 50,   // horizontally center ,  cell.checkBtn.bounds.minX - 15, -50
             y: cell.checkBtn.bounds.maxY + 60.0,
             */
            
            popover.backgroundColor = UIColor.clear
        }
        present(menuVC, animated: true, completion: nil)
       }
    
}

extension CreateWorkoutViewController: MenuActions{
    func deletedWorkoutExercise(_ workoutExerciseId: String?) {
        print("workoutExerciseId: ", workoutExerciseId as Any)
        if let workoutExerciseId = workoutExerciseId, !workoutExerciseId.isEmpty , let workoutIdStr = workoutIdStr, !workoutIdStr.isEmpty {
            self.getCreatedWorkouts(inputWorkId: workoutIdStr)
        }
    }
}

extension CreateWorkoutViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("Started dragging")
        self.view.endEditing(true)
    }
}

//extension CreateWorkoutViewController: UIPickerViewDataSource, UIPickerViewDelegate {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 2 // Minutes + Seconds
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return component == 0 ? 60 : 60 // 0–59 minutes, 0–59 seconds
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return component == 0 ? "\(row) min" : "\(row) sec"
//    }
//}


extension CreateWorkoutViewController: UIPopoverPresentationControllerDelegate, UITextFieldDelegate {
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


// MARK: ----------- EXTENSION FOR API
extension CreateWorkoutViewController{
    
    private func getCreatedWorkouts(inputWorkId: String?){
        WorkoutLibraryVM.setEditWorkoutsApi(inputWorkoutId: inputWorkId, completion: {[weak self] getWorkoutData in
            guard let self = self else { return }
            
            self.getSupsetWorkoutData = nil
            self.getSupsetWorkoutData = getWorkoutData?.data
            print("self.getSupsetWorkoutData: ", self.getSupsetWorkoutData as Any)
            
            if let superSetData = self.getSupsetWorkoutData , let getSuperSets = self.getSupsetWorkoutData?.supersets {
                if let workoutId = superSetData.workoutId?.value, !workoutId.isEmpty {
                    self.supersetCreated()
                }
                
                self.inputApiData()
                self.supersetData?.removeAll()
                self.supersetData?.append(contentsOf: getSuperSets)
                self.exerciseTblView.reloadData()
                
                /*
                let getSupersetExercise: [ExercisesDatailsModel] = getSuperSets.compactMap { $0.exercises }.flatMap { $0 }
                self.exerciseData?.removeAll()
                self.exerciseData?.append(contentsOf: getSupersetExercise)
                self.exerciseTblView.reloadData()
                */
            }else{
                //--------------- For Circuit
                self.inputApiData()
                self.exerciseData?.removeAll()
                self.exerciseData?.append(contentsOf: self.getSupsetWorkoutData?.exercises ?? [])
                self.restExerciseData?.removeAll()
                self.restExerciseData = self.exerciseData
                self.exerciseTblView.reloadData()
                print("restExerciseData: ", self.restExerciseData as Any)
                
                let restDurationFilterData = self.restExerciseData?.filter { $0.type?.value?.lowercased() == "rest" || $0.localRest?.value?.lowercased() == "localrest" }
                if (restDurationFilterData?.count ?? 0) > 1{
                    self.restCircuitSwtch.isSelected = true
                }else{
                    self.restCircuitSwtch.isSelected = false
                    
                    //------------------ MAKE REST TIME SCALE VALUE SETUP
                    if let restTimeStr = restDurationFilterData?.last?.restDuration?.value,
                       var getRepsCountVal = Int(restTimeStr),
                       let collectionView = self.restTimePicker.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
                        
                        let itemCount = collectionView.numberOfItems(inSection: 0)
                        print("Item Count: ", itemCount)
                        
                        getRepsCountVal -= 1 //bcz of start form 0
                        
                        DispatchQueue.main.async {
                            let itemCount = collectionView.numberOfItems(inSection: 0)
                            if getRepsCountVal >= 0 && getRepsCountVal < itemCount {
                                let indexPath = IndexPath(item: getRepsCountVal, section: 0)
                                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                            }
                        }
                        
                    }
                }
            }
        })
    }
}
