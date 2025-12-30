//
//  RepeatFrequencyPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 30/12/24.
//

import UIKit

class RepeatFrequencyPopupViewController: UIViewController {

    //MARK: -------------- VARIABLE
    var isLoadFirst:Bool? = nil
//    typealias DataFreq = [String: Any]
    var weekDaysFreq: String? = nil
    var dateStr: String? = nil
    var localDaysFreq: [String]? = []
//    private var daysFreq: Set<String> = []
    private var daysFreq: [String] = []
    
    var sentBackData: ((_ weekDays: String?, _ days:[String]?, _ dateStr: String?) -> Void)?
    
    var navCtnl: UINavigationController?
    var selectedDate: String?
    private var getSelectedDate: String?
    
    var countDays: Int = 0 {
        didSet {
            self.countTxtField.text = "\(countDays)"
        }
    }
    
    var btns:[UIButton]?
    enum DaysBtnTag:Int {
        case sun = 4101, mon, tue, wed, thus, fri, sat
    }
    
    lazy var dayIndexMap: [Int: (UIButton, String)] = [
        DaysBtnTag.sun.rawValue: (sunBtn, "1"),
        DaysBtnTag.mon.rawValue: (mBtn, "2"),
        DaysBtnTag.tue.rawValue: (tBtn, "3"),
        DaysBtnTag.wed.rawValue: (wBtn, "4"),
        DaysBtnTag.thus.rawValue: (thBtn, "5"),
        DaysBtnTag.fri.rawValue: (fBtn, "6"),
        DaysBtnTag.sat.rawValue: (sBtn, "7")
//        DaysBtnTag.sun.rawValue: (sunBtn, "1")
    ]
    
    //MARK: --------------- IBOUTLET
    @IBOutlet weak var popupMBV: UIView!
    @IBOutlet weak var topBarBtn: UIButton!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var repeatMBV: UIView!
    @IBOutlet weak var dayMBV: UIView!
    @IBOutlet weak var endsMBV: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var repeatEveryTitleLbl: UILabel!
    @IBOutlet weak var countTxtField: UITextField!
    @IBOutlet weak var repeatDaysStck: UIStackView!
    @IBOutlet weak var weakBtn: UIButton!
    @IBOutlet weak var DaysBtn: UIButton!
    @IBOutlet weak var weeksBtn: UIButton!
    @IBOutlet weak var daysTitleLbl: UILabel!
    @IBOutlet weak var mBtn: UIButton!
    @IBOutlet weak var tBtn: UIButton!
    @IBOutlet weak var wBtn: UIButton!
    @IBOutlet weak var thBtn: UIButton!
    @IBOutlet weak var fBtn: UIButton!
    @IBOutlet weak var sBtn: UIButton!
    @IBOutlet weak var sunBtn: UIButton!
    @IBOutlet weak var endsTitleLbl: UILabel!
    @IBOutlet weak var noEndsDateMBV: UIView!
    @IBOutlet weak var endOnMBV: UIView!
    @IBOutlet weak var noEndsDateBtn: UIButton!
    @IBOutlet weak var EndsonBtn: UIButton!
    @IBOutlet weak var endsDateBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isLoadFirst = true
        self.countTxtField.isUserInteractionEnabled = false
        self.setuiFont()
        
        self.endsDateBtn.setTitle("Select Date", for: .normal)
        
//        btns = [
//            mBtn,
//            tBtn,
//            wBtn,
//            thBtn,
//            fBtn,
//            sBtn,
//            sunBtn
//        ]
        
        btns = [
            sunBtn,
            mBtn,
            tBtn,
            wBtn,
            thBtn,
            fBtn,
            sBtn
        ]
        
        //----------------_************
        self.setInputData()
        //        self.countDays = 1
        //        self.weakBtn.accessibilityHint = "Days"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        if let _ = self.isLoadFirst {
            self.isLoadFirst = nil
            self.view.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: {
                print("Animation done.")
            })
            self.setupUI()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.setupUI()
        
        if let localDaysFreq = localDaysFreq, !localDaysFreq.isEmpty {
            self.preselectDays(localDaysFreq)
        }
    }
    
    private func setInputData(){
        
        self.weakBtn.isUserInteractionEnabled = false
        self.countDays = 1
        self.weakBtn.accessibilityHint = "Weeks"
        self.weakBtn.setTitle("Weeks", for: .normal)
        self.daysPopupShow(isShow: false)
        
        if let weekDaysFreq = weekDaysFreq, let weekDaysCount = Int(weekDaysFreq) {
            self.countDays = weekDaysCount
        }
        
        if let dateStr = dateStr, dateStr != "No" {
            self.getSelectedDate = dateStr
            self.endsDateBtn.setTitle(self.getSelectedDate, for: .normal)
            endDateBtnSelection(select: self.EndsonBtn)
        }else{
            self.getSelectedDate = "No" //"No End Date"
        }
        
        if let localDaysFreq = localDaysFreq, !localDaysFreq.isEmpty {
            self.preselectDays(localDaysFreq)
        }
    }
    
    private func preselectDays(_ localDaysFreq: [String]) {
        daysFreq.removeAll()
        for ( _ , (button, str)) in dayIndexMap {
            if localDaysFreq.contains(str) {
                button.isSelected = true
                daysFreq.append(str)
                
                DispatchQueue.main.async {
                    button.setCornerRadius(
                        borderWidth: 1.0,
                        borderColor: UIColor(red: 158/255, green: 188/255, blue: 255/255, alpha: 1.0),
                        cornerRadious: 12.0
                    )
                }
            } else {
                button.isSelected = false
                if let idx = daysFreq.firstIndex(of: str) {
                    daysFreq.remove(at: idx)
                }
                
                DispatchQueue.main.async {
                    button.setCornerRadius(
                        borderWidth: 0,
                        borderColor: nil,
                        cornerRadious: 12.0
                    )
                }
            }
        }
    }

    @IBAction func doneBtnActn(_ sender:UIButton) {
        print("clicked at done......")
//        let daysData = Array(self.daysFreq)
        self.dismiss(animated: true, completion: { [self] in
            print("Animation is done.")
            self.sentBackData?(self.countTxtField.text, self.daysFreq, self.getSelectedDate)
        })
        
//        self.dismiss(animated: true, completion: {
//            let vc:TimeSlotPopupViewController = TimeSlotPopupViewController.instantiate(appStoryboard: .calendar)
//            vc.modalPresentationStyle = .automatic
//            vc.navCtrl = self.navCtnl
//            vc.timePopFlow = .repsFreq
//            self.navCtnl?.present(vc, animated: false)
//        })
    }
    
    //MARK: ----------END DATE ACTN
    enum EndDateTags: Int {
    case noEndDate = 501, endOn, showDateBtn
    }
    
    @IBAction func endDateCommonBtnActn(_ sender: UIButton) {
        switch sender.tag {
        case EndDateTags.noEndDate.rawValue:
            print("No EndDate clicked....")
            getSelectedDate = nil
            self.endsDateBtn.setTitle("Select Date", for: .normal)
            endDateBtnSelection(select: self.noEndsDateBtn)
            break
        case EndDateTags.endOn.rawValue:
            print("EndDate clicked....")
            endDateBtnSelection(select: self.EndsonBtn)
            self.showDatePicker()
            break
            
//        case EndDateTags.showDateBtn.rawValue:
//            print("showDateBtn clicked....")
//            break
        default:
            print("None of these.......")
            break
        }
    }
    
    private func endDateBtnSelection(select:UIButton){
        for btn in [self.noEndsDateBtn, self.EndsonBtn] {
            
            if btn == select {
                btn?.setImage(AppImages.filterChecked, for: .normal)
            }else{
                btn?.setImage(AppImages.filterUncheck, for: .normal)
            }
        }
    }
    
    //MARK: -----------COMMON BTN TAG
    enum btnTag:Int {
        case countIncrease = 401, countDecrease, weekBtn, daysBtn, weeksBtn
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        print("common btn clicked..")
        
        switch sender.tag {
        case btnTag.countIncrease.rawValue:
            print("countIncrease clicked..")
  
            guard self.countDays < (self.weakBtn.accessibilityHint == "Days" ? 6 : 4) else {
                return
            }
            
            self.countDays += 1
        case btnTag.countDecrease.rawValue:
            print("countDecrease clicked..")
            guard self.countDays > 1 else {
                return
            }
            self.countDays -= 1
        case btnTag.weekBtn.rawValue:
            print("weeks clicked..")
            weakBtn.isSelected = !weakBtn.isSelected
            if weakBtn.isSelected {
                weakBtn.isSelected = !weakBtn.isSelected
                daysPopupShow(isShow: true)
            }else{
                daysPopupShow(isShow: false)
            }
            
        case btnTag.daysBtn.rawValue:
            print("daysBtn clicked..")
            self.dayMBV.isHidden = false
//            self.dayMBV.isHidden = true
            daysPopupShow(isShow: false)
            self.countDays = 1
            self.weakBtn.accessibilityHint = "Days"
            self.weakBtn.setTitle("Days", for: .normal)
        case btnTag.weeksBtn.rawValue:
            print("weeksBtn clicked..")
            self.dayMBV.isHidden = true
//            self.dayMBV.isHidden = false
            self.countDays = 1
            self.weakBtn.accessibilityHint = "Weeks"
            self.weakBtn.setTitle("Weeks", for: .normal)
            daysPopupShow(isShow: false)
            
        default:
          print("default...... none of these")
        }
    }
    
    func daysPopupShow(isShow: Bool){
        
        if isShow {
            self.DaysBtn.isHidden = false
            self.weeksBtn.isHidden = false
        }else{
            self.DaysBtn.isHidden = true
            self.weeksBtn.isHidden = true
        }
    }
    
    //MARK: -------------DAYS BTNS
    
    //MARK: -----------COMMON BTN TAG
  
    @IBAction func daysBtnActn(_ sender: UIButton) {
        guard let (button, dayValue) = dayIndexMap[sender.tag] else { return }
        button.isSelected.toggle()
        
        if button.isSelected {
            //                daysFreq.insert(dayValue)
            
            if !daysFreq.contains(dayValue) {   // prevent duplicates
                daysFreq.append(dayValue)
            }
            
            button.setCornerRadius(
                borderWidth: 1.0,
                borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0),
                cornerRadious: 12.0
            )
        } else {
            //                daysFreq.remove(dayValue)
            if let idx = daysFreq.firstIndex(of: dayValue) {
                daysFreq.remove(at: idx)
            }
            button.setCornerRadius(
                borderWidth: 0,
                borderColor: nil,
                cornerRadious: 12.0
            )
        }
        
        print("clicked at tag \(sender.tag), daysFreq = \(daysFreq)")
        
        
        //        self.updateUI(selectedView: [mBtn,
        //                                     tBtn,
        //                                     wBtn,
        //                                     thBtn,
        //                                     fBtn,
        //                                     sBtn,
        //                                     sunBtn], selectedTag: sender.tag)
        
        /*
         switch sender.tag {
         case daysbtnTag.mon.rawValue:
         print("cliecked at mon")
         mBtn.isSelected = !mBtn.isSelected
         if mBtn.isSelected {
         daysFreq.insert("2")
         mBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
         }else{
         daysFreq.remove("2")
         mBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
         }
         
         case daysbtnTag.tue.rawValue:
         tBtn.isSelected = !tBtn.isSelected
         
         if tBtn.isSelected {
         daysFreq.insert("3")
         tBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
         }else{
         daysFreq.remove("3")
         tBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
         }
         
         print("cliecked at tue")
         case daysbtnTag.wed.rawValue:
         wBtn.isSelected = !wBtn.isSelected
         
         if wBtn.isSelected {
         daysFreq.insert("4")
         wBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
         }else{
         daysFreq.remove("4")
         wBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
         }
         
         print("cliecked at wed")
         case daysbtnTag.thus.rawValue:
         thBtn.isSelected = !thBtn.isSelected
         
         if thBtn.isSelected {
         daysFreq.insert("5")
         thBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
         }else{
         daysFreq.remove("5")
         thBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
         }
         
         print("cliecked at thus")
         case daysbtnTag.fri.rawValue:
         fBtn.isSelected = !fBtn.isSelected
         
         if fBtn.isSelected {
         daysFreq.insert("6")
         fBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
         }else{
         daysFreq.remove("6")
         fBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
         }
         
         print("cliecked at fri")
         case daysbtnTag.sat.rawValue:
         sBtn.isSelected = !sBtn.isSelected
         
         if sBtn.isSelected {
         daysFreq.insert("7")
         sBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
         }else{
         daysFreq.remove("7")
         sBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
         }
         
         print("cliecked at sat")
         case daysbtnTag.sun.rawValue:
         sunBtn.isSelected = !sunBtn.isSelected
         
         if sunBtn.isSelected {
         daysFreq.insert("1")
         sunBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
         }else{
         daysFreq.remove("1")
         sunBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
         }
         
         print("cliecked at sun")
         
         default:
         print("none of these...")
         }
         */
    }
    
    //MARK: -------------- CREATE DATE PICKER
    func showDatePicker() {
            // Create Alert
            let alert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
            
            // Create DatePicker
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
       if #available(iOS 13.4, *) {
           datePicker.preferredDatePickerStyle = .wheels
       } else {
           // Fallback on earlier versions
       }

        if let selectedDate = selectedDate,  let getDate = DateFormatterHelper.shared.dateFromString(from: selectedDate, format: "dd-MM-yyyy, hh:mm a") {
           //"dd-MM-yyyy, hh:mm a"
            let calendar = Calendar.current
            let getYear = calendar.component(.year, from: getDate)
            let getMonth = calendar.component(.month, from: getDate)
            let getDay = calendar.component(.day, from: getDate)
            datePicker.minimumDate = calendar.date(from: DateComponents(year: getYear, month: getMonth, day: getDay))
        }
                
            // Add DatePicker to alert
            alert.view.addSubview(datePicker)
            
            // Add constraints
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 50).isActive = true
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor).isActive = true
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor).isActive = true
            datePicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
            
            // Add actions
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                self.getSelectedDate = DateFormatterHelper.shared.dateString(from: datePicker.date, format: "dd MMM yyyy")
                print("getSelectedDate: ", self.getSelectedDate as Any)
                self.endsDateBtn.setTitle(self.getSelectedDate, for: .normal)
            }))
            
            // Increase height of alert
            alert.view.translatesAutoresizingMaskIntoConstraints = false
            alert.view.heightAnchor.constraint(equalToConstant: 350).isActive = true
            
            present(alert, animated: true, completion: nil)
        }
    
    
    //MARK: ------------SHOW DATE START/END
    func updateUI(selectedView:[UIButton], selectedTag:Int){
            
            for i in selectedView{
                if i.tag == selectedTag {
                    i.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
                }else{
                    i.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
                }
            }
        }
    
    //MARK: -----------MAKE SELECTED
    func makeSelected(selectedView:[UIButton], selectedTag:Int){
            
            for i in selectedView{
                if i.tag == selectedTag {
                    i.isSelected = true
                }
            }
        }
    
    func setupUI(){
        DispatchQueue.main.async {
          
            self.popupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.popupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.countTxtField.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.repeatDaysStck.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.mBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.tBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.wBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.thBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.fBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.sBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.sunBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.endsDateBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.doneBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.repeatDaysStck.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 8.0)
        }
    }
    
    func setuiFont(){
        self.topTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.doneBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.repeatEveryTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.countTxtField.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.weakBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.DaysBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.weeksBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.daysTitleLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.mBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.tBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.wBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.thBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.fBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.sBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.sunBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.endsTitleLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.noEndsDateBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.EndsonBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.endsDateBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
                  if !self.popupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      self.daysPopupShow(isShow: false)
                      print("tap at popup view.")
                  }
        }
    }
}

