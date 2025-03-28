//
//  BookingCalendarViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/11/24.
//

import UIKit
import FSCalendar

enum calendarFlow {
    case bookTrainer
    case createPackage
    case defaultFlow
}

struct AvailParmsModel {
    var type: String?
    var trainer_id: String?
    var studio_id: String?
    var month: String?
    var address_id: String?
    
    func getParams() -> [String: String] {
          var dict: [String: String] = [:]

          if let type = type { dict["type"] = type }
          if let trainer_id = trainer_id { dict["trainer_id"] = trainer_id }
          if let studio_id = studio_id { dict["studio_id"] = studio_id }
          if let month = month { dict["month"] = month }
          if let address_id = address_id { dict["address_id"] = address_id }

          return dict
      }
}

class BookingCalendarViewController: CommonViewController {

    //MARK: -------------- VARIABLE
    var slotBookFlow:calendarFlow = .defaultFlow
    
    var params:AvailParmsModel?
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .indian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let statusColorMap: [String: UIColor] = [
        "CLOSED".uppercased(): UIColor.txtDarkGray,
        "AVAILABLE".uppercased(): UIColor.appGreen,
        "FAST FILLING".uppercased(): UIColor.appLightYellow,
        "FULLY BOOKED".uppercased(): UIColor.appOrangeRed
    ]
    
    let fillSelectionColors = ["2024/11/30": UIColor.clear] // This is used for set selected of multiple date with multiple colors
    
//    let fillSelectionColors = ["2024/10/08": UIColor.green, "2024/10/06": UIColor.purple, "2024/10/17": UIColor.gray, "2024/10/21": UIColor.cyan, "2024/11/08": UIColor.green, "2024/11/06": UIColor.purple, "2024/11/17": UIColor.gray, "2024/11/21": UIColor.cyan, "2024/12/08": UIColor.green, "2024/12/06": UIColor.purple, "2024/12/17": UIColor.gray, "2024/12/21": UIColor.cyan]

    
    let fillDefaultColors = ["2024/11/08": UIColor.clear, "2024/11/15": UIColor.clear, "2024/11/23": UIColor.clear] // This is used for fiil color of given dates
    
    
//    let fillDefaultColors = ["2024/10/08": UIColor.purple, "2024/10/06": UIColor.green, "2024/10/18": UIColor.cyan, "2024/10/22": UIColor.yellow, "2024/11/08": UIColor.purple, "2024/11/06": UIColor.green, "2024/11/18": UIColor.cyan, "2024/11/22": UIColor.yellow, "2024/12/08": UIColor.purple, "2024/12/06": UIColor.green, "2024/12/18": UIColor.cyan, "2024/12/22": UIColor.magenta]
    
    let borderDefaultColors = ["2024/11/08": UIColor.clear]

    
//    let borderDefaultColors = ["2024/10/08": UIColor.brown, "2024/10/17": UIColor.magenta, "2024/10/21": UIColor.cyan, "2024/10/25": UIColor.black, "2024/11/08": UIColor.brown, "2024/11/17": UIColor.magenta, "2024/11/21": UIColor.cyan, "2024/11/25": UIColor.black, "2024/12/08": UIColor.brown, "2024/12/17": UIColor.magenta, "2024/12/21": UIColor.purple, "2024/12/25": UIColor.black]

//    let borderSelectionColors = ["2024/10/08": UIColor.red, "2024/10/17": UIColor.purple, "2024/10/21": UIColor.cyan, "2024/10/25": UIColor.magenta, "2024/11/08": UIColor.red, "2024/11/17": UIColor.purple, "2024/11/21": UIColor.cyan, "2024/11/25": UIColor.purple, "2024/12/08": UIColor.red, "2024/12/17": UIColor.purple, "2024/12/21": UIColor.cyan, "2024/12/25": UIColor.magenta]
    
    //rgba(158, 188, 255, 1)
    let borderSelectionColors = ["01-11.2024":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)] // ["2024/11/08": UIColor.red , "2024/11/12": UIColor.red, "2024/11/25": UIColor.red] //This is used for selected date border setup
    
    var datesWithEvent = ["2024-11-03":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), "2024-11-06":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), "2024-11-12":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), "2024-11-25":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)]
    
    var disabledDates: [String] = [] //Dates to disable "yyyy-MM-dd"
    
    //"yyyy-MM-dd"
    lazy var datesWithMultipleEvents: [String:UIColor]? = [:]

    
//    var datesWithEvent = ["2024-11-03", "2024-11-06", "2024-11-12", "2024-11-25"]
//    var datesWithMultipleEvents = ["2024-11-08", "2024-11-16", "2024-11-20", "2024-11-28"]

    
    //MARK: --------------- IBOUTLET
    @IBOutlet weak var topTitleMBV: UIView!
    @IBOutlet weak var monthMBV: UIView!
    @IBOutlet weak var startEndsMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var startTitleLbl: UILabel!
    @IBOutlet weak var endTitleLbl: UILabel!
    @IBOutlet weak var startDateBtn: UIButton!
    @IBOutlet weak var monthBWImgView: UIImageView!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var calendarMBV: UIView!
    @IBOutlet weak var bookingCalendar: FSCalendar!
    @IBOutlet weak var statu1sMBV: UIStackView!
    @IBOutlet weak var statu2sMBV: UIStackView!
    @IBOutlet weak var availableStatus: UIButton!
    @IBOutlet weak var fastFillingStatus: UIButton!
    @IBOutlet weak var fullyBookedStatus: UIButton!
    @IBOutlet weak var closedStatus: UIButton!
    @IBOutlet weak var monthTitleLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpFont()
        
        bookingCalendar.headerHeight = 0.0
        bookingCalendar.delegate = self
        bookingCalendar.appearance.titleFont = UIFont.boldSystemFont(ofSize: 15.0)
        self.enableContinueBtn(isSelected: false)
        
        self.flowSetup()
    }
    
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        bookingCalendar.headerHeight = 0.0
        
        //-------------------------Api
        self.getAvailableSlots(inputParams: self.params?.getParams() ?? ["":""])
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.book_a_Slot], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        
        //---------------------**************UI
        DispatchQueue.main.async {
            
            self.bookingCalendar.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 0.0)
            self.calendarMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 20.0)
            
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            //----------------Gradient view
            
            self.bookingCalendar.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor,UIColor.mainBg.cgColor], type: .conic)
            self.calendarMBV.layerGradient(startPoint: .topLeft, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor, UIColor.mainBg.cgColor], type: .conic)
            
            self.calendarMBV.setGradientBorder(cornerRadious:20.0,width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            
//            self.bookingCalendar.setGradientBorder(cornerRadious:20.0,width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
        }
    }
    
    
    //MARK: ------------FONT SETUP
    func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.monthTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.startTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.endTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.startDateBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.endBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
       
        self.availableStatus.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.fastFillingStatus.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.fullyBookedStatus.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.closedStatus.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyManrope)
        
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    
    //MARK: -------------FLOW SETUP
    func flowSetup(){
        switch slotBookFlow {
        case .bookTrainer:
            self.topTitleMBV.isHidden = true
            self.startEndsMBV.isHidden = true
            self.continueBtn.isHidden = true
            self.statu1sMBV.isHidden = false
            self.statu2sMBV.isHidden = false
            self.monthTitleLbl.text = getMonthName(from: bookingCalendar)
            self.enableContinueBtn(isSelected: false)
                       
        case .createPackage:
            self.topTitleMBV.isHidden = false
            self.startEndsMBV.isHidden = false
            self.continueBtn.isHidden = false
            self.statu1sMBV.isHidden = true
            self.statu2sMBV.isHidden = true
            
            self.startDateBtn.isSelected = true
            self.endBtn.isSelected = false
            self.startDateBtn.isUserInteractionEnabled = false
            self.endBtn.isUserInteractionEnabled = false
            updateUI(selectedView: [startDateBtn, endBtn])
            
        case .defaultFlow:
            print("default is called..")
        }
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("continue btn actn.....")
        let vc:SlotDurationViewController = SlotDurationViewController.instantiate(appStoryboard: .booking)
        vc.slotDurationFlow = .createPackage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showDateBtnActn(_ sender: UIButton) {
        
        if sender.tag == 6101 {
            self.startDateBtn.isSelected = true
            self.endBtn.isSelected = false
        }else{
            self.startDateBtn.isSelected = false
            self.endBtn.isSelected = true
        }
        
        updateUI(selectedView: [startDateBtn, endBtn])
    }
    
    //MARK: ------------SHOW DATE START/END
        func updateUI(selectedView:[UIButton]){
            
            for i in selectedView{
                if i.isSelected {
                    i.backgroundColor = UIColor.clear
                    i.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
                }else{
                    i.backgroundColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1)
                    i.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
                }
            }
        }
    
    
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    
    @IBAction func scrollMonthBtnActn(_ sender: UIButton) {
        if sender.tag == 601 {
            print("left arrow clicked of month")
            // Go to the previous month
            if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: bookingCalendar.currentPage) {
                bookingCalendar.setCurrentPage(previousMonth, animated: true)
                calendarCurrentPageDidChange(bookingCalendar) // Manually call delegate
            }
        }else{
            print("rigth arrow clicked of month")
            
            // Go to the next month
            if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: bookingCalendar.currentPage) {
                bookingCalendar.setCurrentPage(nextMonth, animated: true)
                calendarCurrentPageDidChange(bookingCalendar) // Manually call delegate
            }
        }
    }
    
    
    func getMonthName(from calendar: FSCalendar) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMMM yyyy" // Full month name
        return dateFormatter.string(from: calendar.currentPage)
    }

}


extension BookingCalendarViewController:FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd-MM-yyyy" // "yyyy-MM-dd" // Customize the format as needed
        let selectedDate = dateFormatter.string(from: date)
        print("Selected date: \(selectedDate)")
        
        self.enableContinueBtn(isSelected: true)
        
        switch slotBookFlow {
        case .bookTrainer:
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let getSlotDate = dateFormatter.string(from: date)
            
            let vc:SlotDurationViewController = SlotDurationViewController.instantiate(appStoryboard: .booking)
            vc.slotDurationFlow = .bookTrainer
            vc.selectedDate = "\(selectedDate)"
            vc.showCalView.datesWithMultipleEvents = self.datesWithMultipleEvents
            vc.showCalView.disabledDates = self.disabledDates
            vc.showCalView.isCellSelected = false
            vc.inputGetSlotParams = GetSlotParamsModel(trainer_id: self.params?.trainer_id, type: self.params?.type, date: "\(getSlotDate)", timing: "morning", studio_id: self.params?.studio_id, address_id: self.params?.address_id)
            
            self.navigationController?.pushViewController(vc, animated: true)
        case .createPackage:
            print("for create packeg")
            //            let vc:SlotDurationViewController = SlotDurationViewController.instantiate(appStoryboard: .booking)
            //            vc.slotDurationFlow = .createPackage
            //            self.navigationController?.pushViewController(vc, animated: true)
        case .defaultFlow:
            print("default is called..")
        }
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
           let monthName = getMonthName(from: calendar)
           print("Current page changed to: \(monthName)")
        
        self.monthTitleLbl.text = getMonthName(from: bookingCalendar)
       }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter2.string(from: date)
//        if self.datesWithEvent.contains(dateString) {
//            return 1
//        }
//        if self.datesWithMultipleEvents.contains(dateString) {
//            return 3
//        }
        
        if (self.datesWithMultipleEvents?[dateString] != nil){
            return 1
        }
        if (self.datesWithMultipleEvents?[dateString] != nil) {
            return 3
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        let key = self.dateFormatter2.string(from: date)
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
        let key = self.dateFormatter1.string(from: date)
        if let color = self.fillSelectionColors[key] {
            return color
        }
        return appearance.selectionColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.fillDefaultColors[key] {
            return color
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.borderDefaultColors[key] {
            return color
        }
        return appearance.borderDefaultColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
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
    
    
    // MARK: - FSCalendarDelegate
       func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
           let dateString =  self.dateFormatter2.string(from: date) //formatDate(date)
          
           return disabledDates.contains(dateString) // Return false to disable selection
       }
}


//MARK: -------------------------EXTENSION FOR API
extension BookingCalendarViewController {
    
    /*
     let params:[String:String] = [
     "type": "",
     "trainer_id": "",
     "studio_id": "",
     "month": ""
     "address_id: ""
     ]
     */

    private func getAvailableSlots(inputParams: [String : String]){
        print(inputParams)
        TrainerVM.calendarAvailabilityApi(viewController: self, inputParms: inputParams, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            if let getData = getResultData.data {
                
                getData.forEach({[weak self] in
                    guard let self = self else { return  }
                    if let getDate = $0.date, let status = $0.status?.uppercased(), let color = self.statusColorMap[status] {
                        self.datesWithMultipleEvents?[getDate] = color
                        
//                        if status.uppercased() == "CLOSED".uppercased() || status.uppercased() == "FULLY BOOKED".uppercased() {
//                            self.disabledDates.append(getDate)
//                        }
                        
                        if status.uppercased() == "AVAILABLE".uppercased() || status.uppercased() == "FAST FILLING".uppercased() {
                            self.disabledDates.append(getDate)
                        }
                      
                    }
                })
            }
            
            self.bookingCalendar.reloadData()
        })
    }
}
