//
//  CalendarViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/11/24.
//

import UIKit

class CalendarViewController: CommonViewController {

    //MARK: ------------------VARIABLE
    lazy var datesWithMultipleEvents: [String:UIColor]? = [:] //["date":UIColor.appLightYellow]
    var isFromTab: Bool? = false
    private let customCalendar = CalendarView()
//    var navCtrnl:UINavigationController?
    var myWorkoutsData: [MyWorkoutsDataModel]? = []
    
    var selectedDate: String? = nil {
        didSet{
            self.myWorkoutsApi(dateStr: selectedDate)
        }
    }
    
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var showSlotMBV: UIView!
    @IBOutlet weak var workoutLstMBV: UIView!
    @IBOutlet weak var createPlanTutorialMBV: UIView!
    @IBOutlet weak var createPlanBtnMBV: UIView!
    @IBOutlet weak var createPlanImgView: UIImageView!
    @IBOutlet weak var createPlanTitleLbl: UILabel!
    @IBOutlet weak var createPlanDescLbl: UILabel!
    @IBOutlet weak var createPlanBtn: UIButton!
    @IBOutlet weak var workoutLstTblView: UITableView!
//    @IBOutlet weak var workoutLstTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var myScheduleTitleLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupFont()
        self.setupCalendarView()
        self.workoutLstMBV.isHidden = true
        self.createPlanTutorialMBV.isHidden = false
       
        self.workoutLstTblView.register(UINib(nibName: "MyScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "MyScheduleTableViewCell")
       
        //------------------upcoming
//        self.view.setComingSoon(bgColor: UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 1.0),centerImgName: "ic_upcomingStripe", lockImgName: "ic_upcomingLock" ,title: AppStrings.coming_soon, desc: "Your personal fitness planner is almost here. Soon you’ll be able to schedule workouts and stay on track with ease.") only for testing
        
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
//        self.setupCalendarView()
        self.myWorkoutsApi(dateStr: self.selectedDate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //------------------upcoming
//        self.view.setComingSoon(bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_upcomingStripe", lockImgName: "ic_upcomingLock" ,title: "Locked for Now", desc: "Your personal fitness planner is almost here. Soon you’ll be able to schedule workouts and stay on track with ease.")
    }
    
    private func setNavUI(){
        var navBckBtn: UIImage? = nil
        if let isFromTab = isFromTab {
            navBckBtn = (isFromTab ? nil : AppImages.backarrow)
        }
        
        self.setLeftMenu(leftImgs: [navBckBtn], setTitle: [AppStrings.calendarStr], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            
            self.createPlanImgView.backgroundColor = .clear
            self.createPlanImgView.loadGif(name: "Calender")
            
            self.createPlanBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.createPlanTitleLbl.font = AppFont.medium.size(24.0, familyName: familyClashDisplay)
        self.createPlanDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.createPlanBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.myScheduleTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
    }
    
    @IBAction func createPlanBtnActn(_ sender: Any) {
        print("createPlanBtn clicked...")
        
        let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
        vc.modalPresentationStyle = .automatic
        vc.navCtrnl = self.navigationController
        vc.planFlowSetup = .createWorkout //.planpopupDefault 
        self.navigationController?.present(vc, animated: true)
       
        
        /*
//        //-------only for testing
        let vc:CreateWorkoutViewController = CreateWorkoutViewController.instantiate(appStoryboard: .calendar)
        vc.createWorkoutFlow = .superCreateWorkout
        self.navigationController?.pushViewController(vc, animated: true)
        */
        
       
        //                let vc:DeletePopupViewController = DeletePopupViewController.instantiate(appStoryboard: .calendar)
        //                        vc.modalPresentationStyle = .automatic
        //                        self.navigationController?.present(vc, animated: true)
        
        //        let vc:ScheduleWorkoutViewController = ScheduleWorkoutViewController.instantiate(appStoryboard: .calendar)
        //        self.navigationController?.pushViewController(vc, animated: true)
        
        
        //                let vc:TimeSlotPopupViewController = TimeSlotPopupViewController.instantiate(appStoryboard: .calendar)
        
        //        let vc:RepeatFrequencyPopupViewController = RepeatFrequencyPopupViewController.instantiate(appStoryboard: .calendar)
        //                vc.modalPresentationStyle = .automatic
        //                self.navigationController?.present(vc, animated: true)
        
        //        let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
        //        vc.modalPresentationStyle = .automatic
        ////        vc.planFlowSetup = .planselect
        //        self.navigationController?.present(vc, animated: true)
        
        //        let vc:ChooseExerciseViewController = ChooseExerciseViewController.instantiate(appStoryboard: .calendar)
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func setupCalendarView() {
        // Add the calendar view to the view controller
        let currentDate = Date()
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let currentYear = Calendar.current.component(.year, from: currentDate)
        
        customCalendar.isSelectionAll = false
        customCalendar.delegate = self
        customCalendar.setCurrentMonth(currentMonth, year: currentYear)
        showSlotMBV.backgroundColor = .clear
        showSlotMBV.addSubview(customCalendar)
        customCalendar.isNext30days = true
                
        let allDates = self.getAllDaysOfCurrentMonth(currentMonth, year: currentYear)
        let dateStrings = allDates.map { DateFormatterHelper.shared.dateString(from: $0, format: "yyyy-MM-dd") ?? "" }
        for getDate in dateStrings {
            self.datesWithMultipleEvents?[getDate] = UIColor.appRatingYellow //UIColor(red: 253.0/255.0, green: 186.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        }
       
        customCalendar.datesWithMultipleEvents = self.datesWithMultipleEvents
//        customCalendar.isCellSelected = true
        
        customCalendar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customCalendar.leadingAnchor.constraint(equalTo: showSlotMBV.leadingAnchor, constant: 5),
            customCalendar.trailingAnchor.constraint(equalTo: showSlotMBV.trailingAnchor, constant: -5),
            customCalendar.topAnchor.constraint(equalTo: showSlotMBV.safeAreaLayoutGuide.topAnchor, constant: 5),
            customCalendar.bottomAnchor.constraint(equalTo: showSlotMBV.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            //            showCalView.heightAnchor.constraint(equalToConstant: 300) // Adjust height as needed
        ])
        
        //---------------------*********** For Selected date
        let todayDate = Date()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let todayString = formatter.string(from: todayDate)
        
        let month = calendar.component(.month, from: todayDate)
        let year = calendar.component(.year, from: todayDate)
            customCalendar.setCurrentMonth(month, year: year)
                
        if let targetDate = dateFromString(todayString) {
            self.customCalendar.selectedDate = targetDate
            
            /*
            self.datesWithMultipleEvents?[DateFormatterHelper.shared.getDateFromFormat(fromDate: todayString, fromFormat: "dd-MM-yyyy", toFormat: "yyyy-MM-dd") ?? ""] = UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 26.0/255.0, alpha: 1.0)
            self.customCalendar.datesWithMultipleEvents = self.datesWithMultipleEvents
            */
        }
        
        let todayStrApi = DateFormatterHelper.shared.getDateFromFormat(fromDate: todayString, fromFormat: "dd-MM-yyyy", toFormat: "yyyy-MM-dd")
//        self.myWorkoutsApi(dateStr: todayStrApi)
        self.selectedDate = todayStrApi
        
//        if let targetDate = dateFromString("25-12-2024") {
//            self.customCalendar.selectedDate = targetDate
//        }
    }
    
    // Helper function to convert string to Date
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"  // Specify the format of your input string
        return dateFormatter.date(from: dateString)
    }
    
    private func getAllDaysOfCurrentMonth(_ month: Int, year: Int) -> [Date] {
        
        let calendar = Calendar.current
        let today = Date()
        
        var components = DateComponents()
        components.month = month
        components.year = year
        let currentMonth = Calendar.current.date(from: components) ?? Date()
        
        let dates: [Date] = (0..<31).compactMap {
            calendar.date(byAdding: .day, value: $0, to: today)
        }
        
        return dates
    }
    
    /*
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if workoutLstTblView.contentSize.height != 0{
            self.workoutLstTblViewHeightConstrnt.constant = workoutLstTblView.contentSize.height
        }
        view.layoutIfNeeded()
    }
    */

}

//MARK: ---------- EXTENSION FOR CustomCalendarDelegate
extension CalendarViewController: CustomCalendarDelegate{
    
    func didSelecteed(withValue value: String?) {
        print("selected value= ", value as Any)
        let selectedDate:String = DateFormatterHelper.shared.getDateFromFormat(fromDate: value ?? "", fromFormat: "yyyy-MM-dd HH:mm:ss Z", toFormat: "yyyy-MM-dd") ?? ""
        self.selectedDate = selectedDate
        
        //----------------Making dot color selection and deselection
        /*
        self.datesWithMultipleEvents = Dictionary(uniqueKeysWithValues:
            self.datesWithMultipleEvents?.map { (key, value) in
                if key == selectedDate {
                    return (key, UIColor(red: 243/255, green: 141/255, blue: 26/255, alpha: 1))
                } else {
                    return (key, UIColor(red: 253.0/255.0, green: 186.0/255.0, blue: 116.0/255.0, alpha: 1.0))
                }
            } ?? []
        )
        self.customCalendar.datesWithMultipleEvents = self.datesWithMultipleEvents
        */
        
//        self.myWorkoutsApi(dateStr: selectedDate)
        
//        let todayStrApi = DateFormatterHelper.shared.getDateFromFormat(fromDate: todayString, fromFormat: "dd-MM-yyyy", toFormat: "yyyy-MM-dd")
       
        
//        let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
//        vc.modalPresentationStyle = .automatic
//        vc.planFlowSetup = .remind
//        self.navigationController?.present(vc, animated: true)
        
    }
    
    func didDeselecteed(withValue value: String?) {
        print("deselected value= ", value as Any)
    }
}

//MARK: ------------------- UITABLEVIEW DELEGATE/DATASOURCE
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myWorkoutsData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyScheduleTableViewCell = workoutLstTblView.dequeueReusableCell(withIdentifier: "MyScheduleTableViewCell", for: indexPath) as! MyScheduleTableViewCell
        
        cell.setCellData(cellData: myWorkoutsData?[indexPath.row])
        cell.editBtn.accessibilityHint = myWorkoutsData?[indexPath.row].id?.value
        cell.delBtn.accessibilityHint = myWorkoutsData?[indexPath.row].id?.value
        cell.editBtn.addTarget(self, action: #selector(editBtnActn(sender: )), for: .touchUpInside)
        cell.delBtn.addTarget(self, action: #selector(deleteBtnActn(sender: )), for: .touchUpInside)
        
        cell.delBtn.setImage(UIImage(named: "ic_delOrange")?.resized(to: CGSize(width: 20, height: 20)), for: .normal)
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//    }
    
    @objc func editBtnActn(sender: UIButton){
        if let idStr = sender.accessibilityHint, let indx = self.myWorkoutsData?.firstIndex(where: { $0.id?.value == idStr }){
            
            let workoutDetails = myWorkoutsData?[indx]
             // "type": "superset",
             if let getType = workoutDetails?.type?.value, getType.lowercased() == "superset" || getType.lowercased() == "circuit" {
                 let vc: CreateWorkoutViewController = CreateWorkoutViewController.instantiate(appStoryboard: .calendar)
                 vc.workoutIdStr = workoutDetails?.id?.value
                 vc.createWorkoutFlow = (getType.lowercased() == "superset" ? .superCreateWorkout : .circuitCreateWorkout) //.superCreateWorkout
                 self.navigationController?.pushViewController(vc, animated: true)
             }else{
                 let vc:ScheduleWorkoutViewController = ScheduleWorkoutViewController.instantiate(appStoryboard: .calendar)
//                 vc.startDateTimeStr = self?.selectedTimeStr
                 vc.workoutIdStr = workoutDetails?.id?.value
                 self.navigationController?.pushViewController(vc, animated: true)
             }
            
        }
    }
    
    @objc func deleteBtnActn(sender: UIButton){
         let vc: DeletePopupViewController = DeletePopupViewController.instantiate(appStoryboard: .calendar)
         vc.modalPresentationStyle = .automatic
         vc.delTilteStr = "Delete Workout"
         vc.altMsgStr = "You’re going to delete this Workout. Are you sure?"
        vc.sentBackData = {[weak self] isDelete in
             guard self != nil else {
                 return
             }
            
            if let idStr = sender.accessibilityHint, let indx = self?.myWorkoutsData?.firstIndex(where: { $0.id?.value == idStr }){
                let workoutDetails = self?.myWorkoutsData?[indx]
                WorkoutLibraryVM.workoutDeleteApi(inputId: workoutDetails?.id?.value, completion: {[weak self] getResultData in
                    guard self != nil else {
                        return
                    }
                    self?.myWorkoutsApi(dateStr: self?.selectedDate)
                })
            }
         }
         self.present(vc, animated: true)
        
    }
    
}

//MARK: --------------------- API
extension CalendarViewController{
   //myWorkoutsApi(dateStr: String?, displayDate: String?
    
    private func myWorkoutsApi(dateStr: String?){
//        date=2025-08-21
        WorkoutLibraryVM.myWorkoutsApi(inputDateStr: dateStr, inputStatus: "1", completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            self.myWorkoutsData?.removeAll()
            self.myWorkoutsData?.append(contentsOf: getResultData.data ?? [])
            print("Count: ",self.myWorkoutsData?.count as Any)
            if let myWorkoutsData = self.myWorkoutsData, (myWorkoutsData.count > 0 && !myWorkoutsData.isEmpty){
                self.workoutLstMBV.isHidden = false
                self.createPlanTutorialMBV.isHidden = true
                self.view.layoutIfNeeded()
            }else{
                self.workoutLstMBV.isHidden = true
                self.createPlanTutorialMBV.isHidden = false
            }
            
            self.workoutLstTblView.reloadData()
            
            //            self.myWorkoutsData = (getResultData.data ?? []).map { item in
            //                var newItem = item
            //                newItem.displayDate = displayDate
            //                return newItem
            //            }
        })
    }
}
