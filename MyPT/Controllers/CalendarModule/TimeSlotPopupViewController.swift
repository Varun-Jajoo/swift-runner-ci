//
//  TimeSlotViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/12/24.
//

import UIKit

enum TimePopupFlow {
    case repsFreq
    case personalWorkout
    case timepopupDefault
}

class TimeSlotPopupViewController: UIViewController {

    //MARK: ------------------VARIABLE
    var timePopFlow:TimePopupFlow = .timepopupDefault
    var navCtrl:UINavigationController?
    private let customSlotCalendar = CalendarView()
    
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
        
        // Do any additional setup after loading the view.
        self.setupFont()
        self.setupCalendarView()
        self.setupTimePicker()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.view.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: {
            print("Animation done.")
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
        self.setupCalendarView()
    }
    
    @IBAction func doneBtnActn(_ sender: UIButton) {
        
        switch timePopFlow {
        case .repsFreq:
            self.dismiss(animated: true, completion: {
              print("done....")
            })
        case .personalWorkout:
            self.dismiss(animated: true, completion: {
                let vc:ScheduleWorkoutViewController = ScheduleWorkoutViewController.instantiate(appStoryboard: .calendar)
                self.navCtrl?.pushViewController(vc, animated: true)
            })
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
        
        customSlotCalendar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customSlotCalendar.leadingAnchor.constraint(equalTo: showAddSlotMBV.leadingAnchor, constant: 5),
            customSlotCalendar.trailingAnchor.constraint(equalTo: showAddSlotMBV.trailingAnchor, constant: -5),
            customSlotCalendar.topAnchor.constraint(equalTo: showAddSlotMBV.safeAreaLayoutGuide.topAnchor, constant: 5),
            customSlotCalendar.bottomAnchor.constraint(equalTo: showAddSlotMBV.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
        
        //---------------------*********** For Selected date
        if let targetDate = dateFromString("25-01-2025") {
            self.customSlotCalendar.selectedDate = targetDate
        }
    }
    
    // Helper function to convert string to Date
    func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"  // Specify the format of your input string
        return dateFormatter.date(from: dateString)
    }
    
    //MARK: -------------------Setup Date
    func setupTimePicker(){
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
           let dateFormatter = DateFormatter()
           dateFormatter.dateStyle = .medium
           dateFormatter.timeStyle = .short
           print("Selected date: \(dateFormatter.string(from: sender.date))")
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
        print("selected value= ", value as Any)
    }
    
    func didDeselecteed(withValue value: String?) {
        print("deselected value= ", value as Any)
    }
    
}
