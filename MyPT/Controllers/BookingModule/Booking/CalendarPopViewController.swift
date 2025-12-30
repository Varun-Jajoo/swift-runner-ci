//
//  CalendarPopViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/12/24.
//

import UIKit
import FSCalendar

class CalendarPopViewController: UIViewController {
    
    //MARK: ------------ VARIABLE
    var navCtrl:UINavigationController?
    var bookingIdStr: String?
    var availSlot: [AvailabilityStatusModel]?
    var reasonRescheduleStr: String? 
    var selectedDateStr: String? = nil
    
   
    /*
    fileprivate let gregorian: Calendar = Calendar(identifier: .indian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    */
    /*
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    */
    
    let statusColorMap: [String: UIColor] = [
        "CLOSED".uppercased(): UIColor.txtDarkGray,
        "AVAILABLE".uppercased(): UIColor.appGreen,
        "FAST FILLING".uppercased(): UIColor.appLightYellow,
        "FULLY BOOKED".uppercased(): UIColor.appOrangeRed
    ]
    
//    let fillSelectionColors = ["2024/11/30": UIColor.clear]
//    let fillDefaultColors = ["2024/11/08": UIColor.clear, "2024/11/15": UIColor.clear, "2024/11/23": UIColor.clear]
//    let borderDefaultColors = ["2024/11/08": UIColor.clear]
//    let borderSelectionColors = ["01-11.2024":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)]
    
    let fillSelectionColors = ["key_date_string": UIColor.clear]
    let fillDefaultColors = ["key_date_string": UIColor.clear]
    let borderDefaultColors = ["key_date_string": UIColor.clear]
    let borderSelectionColors = ["key_date_string":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)]
    
    var disabledDates: [String] = [] //Dates to disable "yyyy-MM-dd"
    //"yyyy-MM-dd"
    lazy var datesWithMultipleEvents: [String:UIColor]? = [:]

    //MARK: --------------IBOUTLET
    @IBOutlet weak var rescheduleCalendarMBV: UIView!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var selectDateTitleLbl: UILabel!
    @IBOutlet weak var monthTitleLbl: UILabel!
    @IBOutlet weak var calendarMBV: UIView!
    @IBOutlet weak var showCalendarMBV: FSCalendar!
    @IBOutlet weak var availBtn: UIButton!
    @IBOutlet weak var fastFillingBtn: UIButton!
    @IBOutlet weak var fullyBookedBtn: UIButton!
    @IBOutlet weak var closedBtn: UIButton!
    @IBOutlet weak var rescheduleBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFont()
        self.enableContinueBtn(isSelected: false)
        self.setpCalendarUI()
        let currentMonth = Calendar.current.component(.month, from: Date())
        self.calendarSlotAvail(inputMonth: "\(currentMonth)")
                
        self.monthTitleLbl.text = getMonthName(from: showCalendarMBV)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    @IBAction func selectMonthBtnActn(_ sender: UIButton) {
        print("month tag", sender.tag)
        if sender.tag == 401 {
            print("previous month")
            if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: showCalendarMBV.currentPage) {
                showCalendarMBV.setCurrentPage(previousMonth, animated: true)
                calendarCurrentPageDidChange(showCalendarMBV) // Manually call delegate
            }
        }
        else if sender.tag == 402
        {
            print("next month")
            // Go to the next month
            if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: showCalendarMBV.currentPage) {
                showCalendarMBV.setCurrentPage(nextMonth, animated: true)
                calendarCurrentPageDidChange(showCalendarMBV) // Manually call delegate
            }
        }
    }
    
    func getMonthName(from calendar: FSCalendar) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMMM yyyy" // Full month name
        return dateFormatter.string(from: calendar.currentPage)
    }
    
    
    @IBAction func dismissBtnActn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func rescheduleBtnactn(_ sender: Any) {
        print("Reschedule btn actn...")
        
        self.dismiss(animated: true) {
            let vc:SlotPopViewController = SlotPopViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            vc.bookingIdStr = self.bookingIdStr
            vc.dateStr = self.selectedDateStr
            vc.reasonRescheduleStr = self.reasonRescheduleStr
            self.navCtrl?.present(vc, animated: false)
        }
        
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.rescheduleCalendarMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
          
            self.rescheduleCalendarMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.rescheduleBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appDarkGray, cornerRadious: 12.0)
            
            //----------------Gradient view
            self.calendarMBV.backgroundColor = UIColor.clear
            //[UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), UIColor(red: 0, green: 5/255.0, blue: 2/255.0, alpha: 1)]
            self.calendarMBV.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0), UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 0.3)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0.8), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 20.0)
            self.calendarMBV.setGradientBorder(cornerRadious:20.0,width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 0.8),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
        }
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.selectDateTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.monthTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.availBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.fastFillingBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.fullyBookedBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.closedBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.rescheduleBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

    //MARK: ------------SETUP CALENDAR
    func setpCalendarUI(){
        showCalendarMBV.headerHeight = 0.0
        showCalendarMBV.delegate = self
        showCalendarMBV.allowsMultipleSelection = false
        showCalendarMBV.appearance.titleFont = UIFont.boldSystemFont(ofSize: 15.0)
    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.rescheduleBtn.isUserInteractionEnabled = true
            self.rescheduleBtn.backgroundColor = UIColor.appWhite
            self.rescheduleBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.rescheduleBtn.isUserInteractionEnabled = false
            self.rescheduleBtn.backgroundColor = UIColor.appDarkGray
            self.rescheduleBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    //---------------------**********
    func isFutureOrCurrentMonth(year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())

        // Check if the given year is greater OR it's the same year but a future or current month
        return (year > currentYear) || (year == currentYear && month >= currentMonth)
    }
}


//MARK: ------------- EXTENSION FOR FSCALENDAR
extension CalendarPopViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
       /*
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd" // Customize the format as needed
        let selectedDate = dateFormatter.string(from: date)
        print("Selected date: \(selectedDate)")
        */
        
        let selectedDate = DateFormatterHelper.shared.dateString(from: date, format: "yyyy-MM-dd") ?? ""
        print("Selected date: \(selectedDate)")
        self.selectedDateStr = selectedDate
        self.enableContinueBtn(isSelected: true)
        
        /*
        self.dismiss(animated: true) {
            let vc:SlotPopViewController = SlotPopViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            self.navCtrl?.present(vc, animated: true)
        }
        */
        
        
//        switch slotBookFlow {
//        case .bookTrainer:
//            let vc:SlotDurationViewController = SlotDurationViewController.instantiate(appStoryboard: .booking)
//            vc.slotDurationFlow = .bookTrainer
//            let transition = CATransition()
//            
//            /*
//            transition.duration = 0.8
//            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//            transition.type = CATransitionType.moveIn
//            transition.subtype = CATransitionSubtype.fromTop
//            self.navigationController?.view.layer.add(transition, forKey: nil)
//            */
//            self.navigationController?.pushViewController(vc, animated: true)
//        case .createPackage:
//            print("for create packeg")
//            //            let vc:SlotDurationViewController = SlotDurationViewController.instantiate(appStoryboard: .booking)
//            //            vc.slotDurationFlow = .createPackage
//            //            self.navigationController?.pushViewController(vc, animated: true)
//        case .defaultFlow:
//            print("default is called..")
//        }
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
           let monthName = getMonthName(from: calendar)
           print("Current page changed to: \(monthName)")
        
        self.monthTitleLbl.text = getMonthName(from: showCalendarMBV)
        
        
        //--------------------*************For getting next month Availibility
        let calendarInstance = Calendar.current
        let currentPage = calendar.currentPage // This gets the first day of the visible month
        let year = calendarInstance.component(.year, from: currentPage)
        let month = calendarInstance.component(.month, from: currentPage)
        
        if isFutureOrCurrentMonth(year: year, month: month) {
            //-------------------------Api
            self.calendarSlotAvail(inputMonth: "\(month)")
        }
        
       }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
//        let dateString = self.dateFormatter2.string(from: date)
        
        let dateString = DateFormatterHelper.shared.dateString(from: date, format: "yyyy-MM-dd") ?? ""
        
//        if self.datesWithEvent.contains(dateString) {
//            return 1
//        }
//        if self.datesWithMultipleEvents.contains(dateString) {
//            return 3
//        }
        
        /*
        if (self.datesWithMultipleEvents[dateString] != nil){
            return 1
        }
        if (self.datesWithMultipleEvents[dateString] != nil) {
            return 3
        }
        */
        
        if (self.datesWithMultipleEvents?[dateString] != nil){
            return 1
        }
        if (self.datesWithMultipleEvents?[dateString] != nil) {
            return 3
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
//        let key = self.dateFormatter2.string(from: date)
        
        let key = DateFormatterHelper.shared.dateString(from: date, format: "yyyy-MM-dd") ?? ""
        
//        if let colors = self.datesWithMultipleEvents[key] {
//            return [colors]
//        }
        
        if let colors = self.datesWithMultipleEvents?[key] as? UIColor {
            return [colors]
        }
        return nil
        
//        let key = self.dateFormatter2.string(from: date)
//        if self.datesWithMultipleEvents.contains(key) {
//            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
//        }
//        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
//        let key = self.dateFormatter1.string(from: date)
        
        let key = DateFormatterHelper.shared.dateString(from: date, format: "yyyy/MM/dd") ?? ""
        if let color = self.fillSelectionColors[key] {
            return color
        }
        return appearance.selectionColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
//        let key = self.dateFormatter1.string(from: date)
        
        let key = DateFormatterHelper.shared.dateString(from: date, format: "yyyy/MM/dd") ?? ""
        if let color = self.fillDefaultColors[key] {
            return color
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
//        let key = self.dateFormatter1.string(from: date)
        
        let key = DateFormatterHelper.shared.dateString(from: date, format: "yyyy/MM/dd") ?? ""
        if let color = self.borderDefaultColors[key] {
            return color
        }
        return appearance.borderDefaultColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
//        let key = self.dateFormatter1.string(from: date)
        
        let key = DateFormatterHelper.shared.dateString(from: date, format: "yyyy/MM/dd") ?? ""
        if let color = self.borderSelectionColors[key] {
            return color
        }
        return appearance.borderSelectionColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
//        if [8, 17, 21, 25].contains((self.gregorian.component(.day, from: date))) {
//            return 0.4
//        }
        return 0.4
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        let dateString = DateFormatterHelper.shared.dateString(from: date, format: "yyyy-MM-dd") ?? ""
       
        return disabledDates.contains(dateString) // Return false to disable selection
    }
}

//MARK: ---------------------EXTENSION FOR API
extension CalendarPopViewController{
    
    private func calendarSlotAvail(inputMonth: String?){
         let params:[String:String] = [
            "id": self.bookingIdStr ?? "",
            "month": inputMonth ?? "",
         ]
        
        BookingVM.trainerSlotApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
           
            if let getData = getResultData.data {
                
                getData.forEach({[weak self] in
                    guard let self = self else { return  }
                    if let getDate = $0.date, let status = $0.status?.uppercased(), let color = self.statusColorMap[status] {
                        self.datesWithMultipleEvents?[getDate] = color
                                                
                        if status.uppercased() == "AVAILABLE".uppercased() || status.uppercased() == "FAST FILLING".uppercased() {
                            self.disabledDates.append(getDate)
                        }
                      
                    }
                })
            }
            self.showCalendarMBV.reloadData()
        })
    }
}
