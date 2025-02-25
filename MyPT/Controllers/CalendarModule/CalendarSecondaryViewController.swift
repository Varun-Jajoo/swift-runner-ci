//
//  CalendarSecondaryViewController.swift
//  MyPT
//
//  Created by techsaga corp on 02/01/25.
//

import UIKit

class CalendarSecondaryViewController: CommonViewController {

    //MARK: ------------------VARIABLE
    private let customSlotCalendar = CalendarView()
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var customCalendarMBV: UIView!
    @IBOutlet weak var myScheduleTitleLbl: UILabel!
    @IBOutlet weak var scheduleTblView: UITableView!
    @IBOutlet weak var scheduleTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var addEventBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupFont()
        self.setupInputData()
        self.setupCalendarView()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.calendarStr], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func addEventBtnActn(_ sender: Any) {
        print("addEventBtn clicked...")
        
        self.navigationController?.popToViewController(ofClass: CalendarViewController.self, animated: true)
        
//        self.navigationController?.popViewController(animated: true)
    }
    
    func setupInputData(){
        self.scheduleTblView.register(UINib(nibName: "MyScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "MyScheduleTableViewCell")
    }
    
    
    private func setupCalendarView() {
        // Add the calendar view to the view controller
        let currentDate = Date()
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        let currentYear = Calendar.current.component(.year, from: currentDate)
        
        customSlotCalendar.delegate = self
        customSlotCalendar.setCurrentMonth(currentMonth, year: currentYear)
        customSlotCalendar.backgroundColor = .clear
        customCalendarMBV.addSubview(customSlotCalendar)
        
        customSlotCalendar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customSlotCalendar.leadingAnchor.constraint(equalTo: customCalendarMBV.leadingAnchor, constant: 5),
            customSlotCalendar.trailingAnchor.constraint(equalTo: customCalendarMBV.trailingAnchor, constant: -5),
            customSlotCalendar.topAnchor.constraint(equalTo: customCalendarMBV.safeAreaLayoutGuide.topAnchor, constant: 5),
            customSlotCalendar.bottomAnchor.constraint(equalTo: customCalendarMBV.safeAreaLayoutGuide.bottomAnchor, constant: -5)
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
    
    func setupUI(){
        DispatchQueue.main.async {
            self.addEventBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.myScheduleTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.addEventBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
       
        if scheduleTblView.contentSize.height != 0 {
            self.scheduleTblViewHeightConstrnt.constant = self.scheduleTblView.contentSize.height
        }
        self.view.layoutIfNeeded()
    }

}

extension CalendarSecondaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyScheduleTableViewCell = scheduleTblView.dequeueReusableCell(withIdentifier: "MyScheduleTableViewCell", for: indexPath) as! MyScheduleTableViewCell
        
        cell.editBtn.addTarget(self, action: #selector(editBtnActn(sender: )), for: .touchUpInside)
        cell.delBtn.addTarget(self, action: #selector(deleteBtnActn(sender: )), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? MyScheduleTableViewCell
        
        let vc:WorkoutDetailsViewController = WorkoutDetailsViewController.instantiate(appStoryboard: .library)
        vc.workoutNameStr = cell?.nameLbl.text
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    @objc func editBtnActn(sender:UIButton){
        print("edit btn actn")
        let vc:ScheduleWorkoutViewController = ScheduleWorkoutViewController.instantiate(appStoryboard: .calendar)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func deleteBtnActn(sender:UIButton){
        print("delete btn actn")
        let vc:DeletePopupViewController = DeletePopupViewController.instantiate(appStoryboard: .calendar)
        vc.modalPresentationStyle = .automatic
        self.navigationController?.present(vc, animated: true)
    }

    
}


extension CalendarSecondaryViewController: CustomCalendarDelegate{
    func didSelecteed(withValue value: String?) {
        print("selected value= ", value as Any)
    }
    
    func didDeselecteed(withValue value: String?) {
        print("deselected value= ", value as Any)
    }
    
}
