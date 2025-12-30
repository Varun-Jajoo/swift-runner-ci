//
//  TimeSlotViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/12/24.
//

import UIKit

enum TimePopupFlow {
    case repsFreq
//    case personalWorkout
    case regularWorkout
    case circuitWorkout
    case superWorkout
    case timepopupDefault
}

class TimeSlotPopupViewController: UIViewController {
    
    //MARK: ------------------VARIABLE
    var isLoadFirst:Bool? = nil
    lazy var datesWithMultipleEvents: [String:UIColor]? = [:]
    var timePopFlow:TimePopupFlow = .timepopupDefault
    var navCtrl:UINavigationController?
    private let customSlotCalendar = CalendarView()
    var isUpdateTime: Bool?
    var sentBackDateTime: ((_ dateTimeSelected: String?) -> Void)?
    
    var selectedDate: Date? = nil {
        didSet{
            if let selectedDate = selectedDate {
                DispatchQueue.main.async {
                    self.selectTimePicker.setDate(selectedDate, animated: true)
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy, hh:mm a"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                selectedTimeStr = dateFormatter.string(from: selectedDate)
            }
        }
    }
    
    private var selectedTimeStr: String?
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var timeSlotPopupMBV: UIView!
    @IBOutlet weak var showAddSlotMBV: UIView!
    @IBOutlet weak var showTimeMBV: UIView!
    @IBOutlet weak var addTimeLbl: UILabel!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var selectTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isLoadFirst = true
        self.setupFont()
        self.setupCalendarView()
        self.setupTimePicker()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = self.isLoadFirst {
            self.isLoadFirst = nil
            self.view.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: {
                print("Animation done.")
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
        self.setupCalendarView()
        
//        self.showTimeMBV.addGradient(colors: [UIColor.red, UIColor.green], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
        //rgba(16, 17, 19, 1)
        //rgba(28, 31, 33, 0.6)
        
//        self.showTimeMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0) , UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 0.4)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
        
//        self.showTimeMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor2), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
        
//        self.selectTimePicker.addGradient(colors: UIColor.appMultiColor(.gradientColor2), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
        
    }
    
    @IBAction func doneBtnActn(_ sender: UIButton) {
        
        /*
         let vc:CreateWorkoutViewController = CreateWorkoutViewController.instantiate(appStoryboard: .calendar)
         self.navCtrnl?.pushViewController(vc, animated: true)
         */
        
        switch timePopFlow {
        case .repsFreq:
            self.dismiss(animated: true, completion: {
                print("done....")
            })
//        case .personalWorkout:
//            if let selectedDate = self.selectedDate {
//                self.dismiss(animated: true, completion: { [weak self] in
//                    let vc:ScheduleWorkoutViewController = ScheduleWorkoutViewController.instantiate(appStoryboard: .calendar)
//                    vc.startDateTimeStr = self?.selectedTimeStr
//                    self?.navCtrl?.pushViewController(vc, animated: true)
//                })
//            }
//            else{
//                AlertHelper.shared.showCustomeAlert(message: "Please select date!")
//            }
            
        case .regularWorkout:
            
            if let isUpdateTime = isUpdateTime, isUpdateTime {
                self.dismiss(animated: true, completion: { [weak self] in
                    
                    let vc:ScheduleWorkoutViewController = ScheduleWorkoutViewController.instantiate(appStoryboard: .calendar)
                    vc.startDateTimeStr = self?.selectedTimeStr
                    self?.sentBackDateTime?(self?.selectedTimeStr)
                    
                })
            }else{
                if let _ = self.selectedDate {
                    self.dismiss(animated: true, completion: { [weak self] in
                        let vc:ScheduleWorkoutViewController = ScheduleWorkoutViewController.instantiate(appStoryboard: .calendar)
                        vc.startDateTimeStr = self?.selectedTimeStr
                        self?.navCtrl?.pushViewController(vc, animated: true)
                    })
                }
                else{
                    AlertHelper.shared.showCustomeAlert(message: "Please select date!")
                }
            }
            
//            if let _ = self.selectedDate {
//                self.dismiss(animated: true, completion: { [weak self] in
//                    let vc:ScheduleWorkoutViewController = ScheduleWorkoutViewController.instantiate(appStoryboard: .calendar)
//                    vc.startDateTimeStr = self?.selectedTimeStr
//                    self?.navCtrl?.pushViewController(vc, animated: true)
//                })
//            }
//            else{
//                AlertHelper.shared.showCustomeAlert(message: "Please select date!")
//            }
            
        case .circuitWorkout:
            
            if let isUpdateTime = isUpdateTime, isUpdateTime {
                self.dismiss(animated: true, completion: { [weak self] in
                    let vc:CreateWorkoutViewController = CreateWorkoutViewController.instantiate(appStoryboard: .calendar)
                    vc.startDateTimeStr = self?.selectedTimeStr
                    vc.createWorkoutFlow = .circuitCreateWorkout
                    self?.sentBackDateTime?(self?.selectedTimeStr)
                })
            }else{
                if let _ = self.selectedDate {
                    self.dismiss(animated: true, completion: { [weak self] in
                        let vc:CreateWorkoutViewController = CreateWorkoutViewController.instantiate(appStoryboard: .calendar)
                        vc.startDateTimeStr = self?.selectedTimeStr
                        vc.createWorkoutFlow = .circuitCreateWorkout
                        self?.navCtrl?.pushViewController(vc, animated: true)
                    })
                }
                else{
                    AlertHelper.shared.showCustomeAlert(message: "Please select date!")
                }
            }
            
//            if let selectedDate = self.selectedDate {
//                self.dismiss(animated: true, completion: { [weak self] in
//                    let vc:CreateWorkoutViewController = CreateWorkoutViewController.instantiate(appStoryboard: .calendar)
//                    vc.startDateTimeStr = self?.selectedTimeStr
//                    vc.createWorkoutFlow = .circuitCreateWorkout
//                    self?.navCtrl?.pushViewController(vc, animated: true)
//                })
//            }
//            else{
//                AlertHelper.shared.showCustomeAlert(message: "Please select date!")
//            }
            
        case .superWorkout:
         
            if let isUpdateTime = isUpdateTime, isUpdateTime {
                self.dismiss(animated: true, completion: { [weak self] in
                    let vc:CreateWorkoutViewController = CreateWorkoutViewController.instantiate(appStoryboard: .calendar)
                    vc.startDateTimeStr = self?.selectedTimeStr
                    vc.createWorkoutFlow = .superCreateWorkout
                    self?.sentBackDateTime?(self?.selectedTimeStr)
                })
                
            }else{
                if let selectedDate = self.selectedDate {
                    self.dismiss(animated: true, completion: { [weak self] in
                        let vc:CreateWorkoutViewController = CreateWorkoutViewController.instantiate(appStoryboard: .calendar)
                        vc.startDateTimeStr = self?.selectedTimeStr
                        vc.createWorkoutFlow = .superCreateWorkout
                        self?.navCtrl?.pushViewController(vc, animated: true)
                    })
                }
                else{
                    AlertHelper.shared.showCustomeAlert(message: "Please select date!")
                }
            }
            
        case .timepopupDefault:
            print("none..")
        }
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.timeSlotPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            
            self.timeSlotPopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.doneBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appDarkGray, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.addTimeLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.timeTitle.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.doneBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    private func setupCalendarView() {
        // Add the calendar view to the view controller
        let currentDate = Date()
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let currentYear = Calendar.current.component(.year, from: currentDate)
        
        customSlotCalendar.delegate = self
        customSlotCalendar.setCurrentMonth(currentMonth, year: currentYear)
        customSlotCalendar.backgroundColor = .clear
        showAddSlotMBV.addSubview(customSlotCalendar)
        customSlotCalendar.isNext30days = true
        
        let allDates = self.getAllDaysOfCurrentMonth(currentMonth, year: currentYear)
        let dateStrings = allDates.map { DateFormatterHelper.shared.dateString(from: $0, format: "yyyy-MM-dd") ?? "" }
        for getDate in dateStrings {
            self.datesWithMultipleEvents?[getDate] = UIColor.appRatingYellow //UIColor(red: 253.0/255.0, green: 186.0/255.0, blue: 116.0/255.0, alpha: 1.0)
        }
        //rgba(253, 186, 116, 1)
        //rgba(243, 141, 26, 1) selected
        customSlotCalendar.datesWithMultipleEvents = self.datesWithMultipleEvents

        
        customSlotCalendar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customSlotCalendar.leadingAnchor.constraint(equalTo: showAddSlotMBV.leadingAnchor, constant: 5),
            customSlotCalendar.trailingAnchor.constraint(equalTo: showAddSlotMBV.trailingAnchor, constant: -5),
            customSlotCalendar.topAnchor.constraint(equalTo: showAddSlotMBV.safeAreaLayoutGuide.topAnchor, constant: 5),
            customSlotCalendar.bottomAnchor.constraint(equalTo: showAddSlotMBV.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
        
        //---------------------*********** For Selected date
        
        //DateFormatterHelper.shared.dateFromString(from: self.startDateTimeStr ?? "", format: "dd-MM-yyyy, hh:mm a")
        
        if let getSelectedDate = self.selectedDate, let getDate = DateFormatterHelper.shared.getFormatDate(fromDate: self.selectedDate ?? Date(), toFormat: "dd-MM-yyyy"), let targetDate = dateFromString(getDate)  {
            self.customSlotCalendar.selectedDate = targetDate
            
            /*
            self.datesWithMultipleEvents?[DateFormatterHelper.shared.getDateFromFormat(fromDate: getDate, fromFormat: "dd-MM-yyyy", toFormat: "yyyy-MM-dd") ?? ""] = UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 26.0/255.0, alpha: 1.0)
            self.customSlotCalendar.datesWithMultipleEvents = self.datesWithMultipleEvents
            */
        }
        
        /*
         let formatter = DateFormatter()
         formatter.dateFormat = "dd-MM-yyyy"
         let todayString = formatter.string(from: Date())
         
         if let targetDate = dateFromString(todayString) {
         self.customSlotCalendar.selectedDate = targetDate
         }
         */
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
                
        /*
         // Get the range of days in the current month
         guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
               let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
             return []
         }
         
        if let isNext30days = isNext30days, isNext30days {
            let dates: [Date] = (0..<31).compactMap {
                calendar.date(byAdding: .day, value: $0, to: today)
            }

            return dates
            
        }else{
            // Get the range of days in the current month
            guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
                  let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
                return []
            }
            
            // Generate all days
            return range.compactMap { day -> Date? in
                var components = DateComponents()
                components.year = calendar.component(.year, from: currentMonth)
                components.month = calendar.component(.month, from: currentMonth)
                components.day = day
                return calendar.date(from: components)
            }
        }
         */
    }
    
    //MARK: -------------------Setup Date
    func setupTimePicker(){
        // UIDatePicker internally contains a UIPickerView
        for subview in self.selectTimePicker.subviews {
            for innerSubview in subview.subviews {
                if innerSubview.bounds.height <= 40 { // Approx height of selection overlay
                    innerSubview.backgroundColor = .clear
                }
            }
        }
        
        // Customize the datePicker
        if #available(iOS 13.4, *) {
            selectTimePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        } // Change style to wheels
        selectTimePicker.datePickerMode = .time //.dateAndTime      // Set mode to date and time
        selectTimePicker.timeZone = TimeZone.current        // Use device's current timezone
        selectTimePicker.locale = Locale(identifier: "en_US") // Set locale to US
        
        // Add a target for value change
        selectTimePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        selectTimePicker.setValue(UIColor.appWhite, forKey: "textColor")
        UIDatePicker.appearance().tintColor = UIColor.appWhite
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy, hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        selectedTimeStr = dateFormatter.string(from: selectTimePicker.date)
        
        
        //        if let separatorLabel = getTimeSeparatorLabel(from: self.selectTimePicker) {
        //            separatorLabel.textColor = .black // Change color
        //            print("Separator label found: \(separatorLabel)")
        //        } else {
        //            print("Separator label not found.")
        //        }
        
        //        // Delay execution to ensure subviews are populated
        //                DispatchQueue.main.async {
        //                    self.updateSeparatorColor(in: self.selectTimePicker)
        //                }
        
        //
        //        selectTimePicker.sendAction("setHighlightsToday:", to: nil, forEvent: nil)
    }
    
    //    func getTimeSeparatorLabel(from datePicker: UIDatePicker) -> UILabel? {
    //        for subview in datePicker.subviews {
    //
    //            for innerSubview in subview.subviews {
    //                print(innerSubview.self)
    //                if let label = innerSubview as? UILabel, label.text == ":" {
    //                    return label
    //                }
    //
    //                for subview1 in innerSubview.subviews {
    //                    if let label = subview1 as? UILabel, label.text == ":" {
    //                        return label
    //                    }
    //                }
    //
    //            }
    //        }
    //        return nil
    //    }
    
    //    func getTimeSeparatorLabel(from datePicker: UIDatePicker) -> UILabel? {
    //        for subview in datePicker.subviews {
    //            for innerSubview in subview.subviews {
    //                for label in innerSubview.subviews where label is UILabel {
    //                    if let separatorLabel = label as? UILabel, separatorLabel.text == ":" {
    //                        return separatorLabel
    //                    }
    //                }
    //            }
    //        }
    //        return nil
    //    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateStyle = .medium
        //        dateFormatter.timeStyle = .short
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd-MM-yyyy, hh:mm a"
        
        let calendar = Calendar.current
        let now = Date()
        if let selectedDate = selectedDate {
            if calendar.isDate(selectedDate, inSameDayAs: now) {
                // Today → restrict from now till 23:59
                sender.minimumDate = now
                if let maxDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) {
                    sender.maximumDate = maxDate
                    print("Today Selected date: \(dateFormatter.string(from: sender.date))")
                    selectedTimeStr = dateFormatter.string(from: sender.date)
                }
            } else {
                // Not today → allow full range (00:00–23:59)
                if let minDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: selectedDate),
                   let maxDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) {
                    sender.minimumDate = minDate
                    sender.maximumDate = maxDate
                    print("Other Selected date: \(dateFormatter.string(from: sender.date))")
                    selectedTimeStr = dateFormatter.string(from: sender.date)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.timeSlotPopupMBV.frame.contains(location) {
                self.dismiss(animated: true, completion: nil)
            }else{
                print("tap at popup view.")
            }
        }
    }
}

extension TimeSlotPopupViewController: CustomCalendarDelegate{
    func didSelecteed(withValue value: String?) {
        print("get selected date = ", value as Any)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter.date(from: value ?? "") {
            selectedDate = date
        } else {
            print("Failed to parse date")
        }
        
        //----------------Making dot color selection and deselection
        /*
        let getCurrentSelectedDate:String = DateFormatterHelper.shared.getDateFromFormat(fromDate: value ?? "", fromFormat: "yyyy-MM-dd HH:mm:ss Z", toFormat: "yyyy-MM-dd") ?? ""
        self.datesWithMultipleEvents = Dictionary(uniqueKeysWithValues:
            self.datesWithMultipleEvents?.map { (key, value) in
                if key == getCurrentSelectedDate {
                    return (key, UIColor(red: 243/255, green: 141/255, blue: 26/255, alpha: 1))
                } else {
                    return (key, UIColor(red: 253.0/255.0, green: 186.0/255.0, blue: 116.0/255.0, alpha: 1.0))
                }
            } ?? []
        )
        self.customSlotCalendar.datesWithMultipleEvents = self.datesWithMultipleEvents
        */
    }
    
    func didDeselecteed(withValue value: String?) {
        print("deselected value= ", value as Any)
    }
    
}
