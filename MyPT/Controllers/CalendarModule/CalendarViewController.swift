//
//  CalendarViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/11/24.
//

import UIKit

class CalendarViewController: CommonViewController {

    //MARK: ------------------VARIABLE
    var isFromTab: Bool? = false
    private let customCalendar = CalendarView()
//    var navCtrnl:UINavigationController?
    
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var showSlotMBV: UIView!
    @IBOutlet weak var createPlanImgView: UIImageView!
    @IBOutlet weak var createPlanTitleLbl: UILabel!
    @IBOutlet weak var createPlanDescLbl: UILabel!
    @IBOutlet weak var createPlanBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupFont()
        self.setupCalendarView()
        
        //------------------upcoming
        self.view.setComingSoon(bgColor: UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 1.0),centerImgName: "ic_upcomingStripe", lockImgName: "ic_upcomingLock" ,title: "Locked for Now", desc: "Your personal fitness planner is almost here. Soon you’ll be able to schedule workouts and stay on track with ease.")
        
//        self.setTopBackgroundImage(named: "ic_calendar_upcoming")
//        self.view.setComingSoon(bgColor: UIColor.mainBg.withAlphaComponent(0.9),centerImgName: "ic_upcomingStripe", lockImgName: "ic_upcomingLock" ,title: "Locked for Now", desc: "Profiles are in progress. Soon you'll be able to track your journey and customize your experience.")
//        self.view.addTopNavigationButton(title: "Profile", image: AppImages.backarrow, target: self.view)
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        self.setupCalendarView()
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
    }
    
    @IBAction func createPlanBtnActn(_ sender: Any) {
        print("createPlanBtn clicked...")
        
        let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
        vc.modalPresentationStyle = .automatic
        vc.navCtrnl = self.navigationController
        //        vc.planFlowSetup = .planselect
        self.navigationController?.present(vc, animated: true)
        
        //        let vc:CalendarSecondaryViewController = CalendarSecondaryViewController.instantiate(appStoryboard: .calendar)
        //        self.navigationController?.pushViewController(vc, animated: true)
        
        
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
        
        customCalendar.delegate = self
        customCalendar.setCurrentMonth(currentMonth, year: currentYear)
        showSlotMBV.backgroundColor = .clear
        showSlotMBV.addSubview(customCalendar)
        
        customCalendar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customCalendar.leadingAnchor.constraint(equalTo: showSlotMBV.leadingAnchor, constant: 5),
            customCalendar.trailingAnchor.constraint(equalTo: showSlotMBV.trailingAnchor, constant: -5),
            customCalendar.topAnchor.constraint(equalTo: showSlotMBV.safeAreaLayoutGuide.topAnchor, constant: 5),
            customCalendar.bottomAnchor.constraint(equalTo: showSlotMBV.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            //            showCalView.heightAnchor.constraint(equalToConstant: 300) // Adjust height as needed
        ])
        
        //---------------------*********** For Selected date
        if let targetDate = dateFromString("25-12-2024") {
            self.customCalendar.selectedDate = targetDate
        }
    }
    
    // Helper function to convert string to Date
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"  // Specify the format of your input string
        return dateFormatter.date(from: dateString)
    }

}

//MARK: ---------- EXTENSION FOR CustomCalendarDelegate
extension CalendarViewController: CustomCalendarDelegate{
    
    func didSelecteed(withValue value: String?) {
        print("selected value= ", value as Any)
        
//        let vc:PlanPopupViewController = PlanPopupViewController.instantiate(appStoryboard: .calendar)
//        vc.modalPresentationStyle = .automatic
//        vc.planFlowSetup = .remind
//        self.navigationController?.present(vc, animated: true)
        
    }
    
    func didDeselecteed(withValue value: String?) {
        print("deselected value= ", value as Any)
    }
}
