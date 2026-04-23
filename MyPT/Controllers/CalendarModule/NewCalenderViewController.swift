//
//  NewCalenderViewController.swift
//  MyPT
//
//  Created by Manik Goel on 06/03/26.
//

import UIKit
import FSCalendar

class NewCalenderViewController: CommonViewController {

    // MARK: -------------- VARIABLE
    var slotBookFlow: calendarFlow = .defaultFlow
    var params: AvailParmsModel?
    var totalDays: Int?
    var priceStr: String?
    var packageTypeStr: String?
    var sessionsStr: String?
    var startDateStr: String?
    var endDateStr: String?
    var trainerIdStr: String?
    var studioIdStr: String?
    var inputType: String?
    var package_type: String?
    var inputParam: DetailsParam?
    var selectedMonthInNumber: String?
    
    private var monthName: String? {
        didSet{
            self.monthTitleLbl.text = monthName
        }
    }

    /// Set to `true` if you want the user to be able to pick several dates.
    var allowsMultipleSelection: Bool = false

    /// Dates (yyyy-MM-dd) that should show the event dot beneath the number.
    var datesWithEvents: [String: UIColor] = [:]

    /// Dates (yyyy-MM-dd) that are explicitly disabled (greyed out / locked).
    var disabledDates: [String] = []

    // ── Private state ──────────────────────────────────────────────────────
    private var selectedDates: Set<Date> = []

    // ── Date formatter (reused) ────────────────────────────────────────────
    private let ymdFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale     = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    let statusColorMap: [String: UIColor] = [
        "CLOSED".uppercased(): UIColor.txtDarkGray,
        "AVAILABLE".uppercased(): UIColor.appGreen,
        "FAST FILLING".uppercased(): UIColor.appLightYellow,
        "FULLY BOOKED".uppercased(): UIColor.appOrangeRed
    ]
    
    let fillSelectionColors = ["2024/11/30": UIColor.clear] // This is used for set selected of multiple date with multiple colors
    
    let fillDefaultColors = ["2024/11/08": UIColor.clear, "2024/11/15": UIColor.clear, "2024/11/23": UIColor.clear] // This is used for fiil color of given dates
    
    let borderDefaultColors = ["2024/11/08": UIColor.clear]
    
    //rgba(158, 188, 255, 1)
    let borderSelectionColors = ["01-11.2024":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)] // ["2024/11/08": UIColor.red , "2024/11/12": UIColor.red, "2024/11/25": UIColor.red] //This is used for selected date border setup
    
    var datesWithEvent = ["2024-11-03":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), "2024-11-06":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), "2024-11-12":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), "2024-11-25":UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)]
    
//    var disabledDates: [String] = [] //Dates to disable "yyyy-MM-dd"
    
    //"yyyy-MM-dd"
    lazy var datesWithMultipleEvents: [String:UIColor]? = [:]

    
    // MARK: --------------- IBOUTLET
    @IBOutlet weak var monthMBV: UIView!
    @IBOutlet weak var monthSubBckView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var calendarMBV: UIView!
    @IBOutlet weak var bookingCalendar: FSCalendar!
    @IBOutlet weak var monthTitleLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFont()
        configureCalendar()
        applyContainerStyling()
        updateMonthLabel()
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
        setCurrentMonth()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMonthLabel()
        setNavUI()
        bookingCalendar.reloadData()
    }
    
    func setCurrentMonth() {
        let currentMonth = Calendar.current.component(.month, from: Date())
        selectedMonthInNumber = String(format: "%02d", currentMonth)
        params = AvailParmsModel(type: inputParam?.type, trainer_id: inputParam?.trainer_id, month: selectedMonthInNumber)
//        params = AvailParmsModel(type: "gym", trainer_id: "53", month: "03")
        self.getAvailableSlots(inputParams: self.params?.getParams() ?? ["":""])
    }
    
    //MARK: ------------FONT SETUP
    func setUpFont() {
        DispatchQueue.main.async {
            self.titleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
            self.monthTitleLbl.font = AppFont.medium.size(16.0, familyName: familyFunnelSans)
            self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.continueBtn.cornersWithBorder(radius: 8, corners: .allCorners)
        }

    }
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
    }
    
    // ── MARK: Pure-code calendar builder (optional) ────────────────────────
    /// Call this in viewDidLoad if you are NOT using a storyboard.
    private func buildCalendarUI() {

        // ── Container ──────────────────────────────────────────────────────
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        calendarMBV = container

        // ── Background image ───────────────────────────────────────────────
        let bgImageView = UIImageView(image: UIImage(named: "CalendarBackground"))
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        bgImageView.contentMode  = .scaleAspectFill
        bgImageView.clipsToBounds = true
        container.addSubview(bgImageView)
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: container.topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        // ── Month navigation row ───────────────────────────────────────────
        let navRow = UIStackView()
        navRow.translatesAutoresizingMaskIntoConstraints = false
        navRow.axis      = .horizontal
        navRow.alignment = .center
        container.addSubview(navRow)

        let prevBtn = makeChevronButton(tag: 601, systemName: "chevron.left")
        let nextBtn = makeChevronButton(tag: 602, systemName: "chevron.right")

        let titleLbl = UILabel()
        titleLbl.textColor = .white
        titleLbl.font      = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLbl.textAlignment = .center
        monthTitleLbl = titleLbl

        navRow.addArrangedSubview(prevBtn)
        navRow.addArrangedSubview(titleLbl)
        navRow.addArrangedSubview(nextBtn)

        NSLayoutConstraint.activate([
            navRow.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            navRow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            navRow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            navRow.heightAnchor.constraint(equalToConstant: 44),
            prevBtn.widthAnchor.constraint(equalToConstant: 36),
            prevBtn.heightAnchor.constraint(equalToConstant: 36),
            nextBtn.widthAnchor.constraint(equalToConstant: 36),
            nextBtn.heightAnchor.constraint(equalToConstant: 36)
        ])

        // ── FSCalendar ─────────────────────────────────────────────────────
        let cal = FSCalendar()
        cal.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(cal)
        NSLayoutConstraint.activate([
            cal.topAnchor.constraint(equalTo: navRow.bottomAnchor, constant: 8),
            cal.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            cal.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            cal.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            cal.heightAnchor.constraint(equalToConstant: 320)
        ])
        bookingCalendar = cal
    }

    private func makeChevronButton(tag: Int, systemName: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.tag = tag
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: systemName, withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        btn.layer.cornerRadius = 18
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(scrollMonthBtnActn(_:)), for: .touchUpInside)
        return btn
    }

    // MARK: Calendar configuration
    private func configureCalendar() {
        bookingCalendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
        bookingCalendar.delegate   = self
        bookingCalendar.dataSource = self

        // ── Hide FSCalendar's own header (we draw our own month label) ─────
        bookingCalendar.headerHeight   = 0
        bookingCalendar.placeholderType = .none
        bookingCalendar.scrollEnabled  = false
        bookingCalendar.backgroundColor = .clear

        // ── Allow single or multiple selection ─────────────────────────────
        bookingCalendar.allowsMultipleSelection = allowsMultipleSelection

        // ── Appearance – keep FSCalendar's own colours invisible so our
        //    custom cell images do all the visual work. ─────────────────────
        bookingCalendar.appearance.headerMinimumDissolvedAlpha = 0
        bookingCalendar.appearance.todayColor       = .clear
        bookingCalendar.appearance.selectionColor   = .clear
        bookingCalendar.appearance.titleDefaultColor   = .white
        bookingCalendar.appearance.titleSelectionColor = .white
        bookingCalendar.appearance.weekdayTextColor    = UIColor.lightGray
        bookingCalendar.appearance.weekdayFont =
            UIFont.systemFont(ofSize: 13, weight: .medium)
        bookingCalendar.appearance.borderRadius = 0.3
        bookingCalendar.rowHeight = 42
    }

    // MARK: Container styling
    private func applyContainerStyling() {
        // If you have a dedicated background image asset named "CalendarBackground"
        // add it as the lowest sub-layer of calendarContainerView:
        if let bgImage = UIImage(named: "CalendarBackground") {
            let bgView = UIImageView(image: bgImage)
            bgView.frame = calendarMBV.bounds
            bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bgView.contentMode = .scaleAspectFill
            bgView.clipsToBounds = true
            calendarMBV.insertSubview(bgView, at: 0)
        } else {
            // Fallback: dark card colour matching your screenshot
            calendarMBV.backgroundColor =
                UIColor(red: 0.07, green: 0.08, blue: 0.1, alpha: 1)
        }
        calendarMBV.layer.cornerRadius = 25
        calendarMBV.clipsToBounds = true
    }

    // MARK: Helpers
    private func updateMonthLabel() {
        guard bookingCalendar != nil else { return }
        let f = DateFormatter()
        f.locale     = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MMMM yyyy"
        monthTitleLbl.text = f.string(from: bookingCalendar.currentPage)
    }

    private func isDateInPast(_ date: Date) -> Bool {
        date < Calendar.current.startOfDay(for: Date())
    }

    private func isDateDisabled(_ date: Date) -> Bool {
        let key = ymdFormatter.string(from: date)
        return disabledDates.contains(key)
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("continue btn actn.....")
        if let date = selectedDates.first {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone.current
            
            let dateString = formatter.string(from: date)
            print(dateString)
            let vc: PreferredTimeVC = PreferredTimeVC.instantiate(appStoryboard: .homepage)
            vc.inputParam = inputParam
            vc.params = SlotsParmsModel(type: inputParam?.type, trainer_id: inputParam?.trainer_id, date: dateString, studio_id: params?.studio_id, month: selectedMonthInNumber, address_id: params?.address_id, preferred_start_time: "08:00", preferred_end_time: "09:00", lat: inputParam?.lat, long: inputParam?.long)
            
//            vc.params = SlotsParmsModel(type: "home", trainer_id: "46", date: dateString, studio_id: params?.studio_id, month: selectedMonthInNumber, address_id: params?.address_id, preferred_start_time: "01:00", preferred_end_time: "02:00", lat: inputParam?.lat, long: inputParam?.long)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: ------------SHOW DATE START/END
    func updateUI(selectedView:[UIButton]) {
        for i in selectedView {
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
    func updateContinueButton(isEnabled: Bool) {
        continueBtn.isEnabled = isEnabled
        continueBtn.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.continueBtn.tintColor = .mainBg   // arrow color
                self.continueBtn.backgroundColor = .appWhite
                self.continueBtn.setTitleColor(.mainBg, for: .normal)
            } else {
                self.continueBtn.tintColor = .appWhite
                self.continueBtn.backgroundColor = .appDarkGray
                self.continueBtn.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        if isEnabled {
            // 🟢 ENABLED → IMAGE ONLY
            let image = UIImage(named: "ic_ConfirmDays")?
                .withRenderingMode(.alwaysOriginal)

            continueBtn.setImage(image, for: .normal)
            continueBtn.setTitle("", for: .normal)

            continueBtn.backgroundColor = .clear
            continueBtn.tintColor = .clear

            continueBtn.imageEdgeInsets = .zero
            continueBtn.titleEdgeInsets = .zero
            continueBtn.contentEdgeInsets = .zero
            continueBtn.semanticContentAttribute = .forceLeftToRight
            continueBtn.adjustsImageWhenHighlighted = false
            continueBtn.adjustsImageWhenDisabled = false

        } else {
            // 🔴 DISABLED → TEXT + ARROW
            continueBtn.setTitle("CONFIRM DAYS", for: .normal)
            continueBtn.setTitleColor(.appWhite, for: .normal)

            let arrowImage = UIImage(named: "whiteRightArrow")?
                .withRenderingMode(.alwaysOriginal)
            continueBtn.setImage(arrowImage, for: .normal)

            continueBtn.semanticContentAttribute = .forceRightToLeft

            // spacing between text & arrow
            continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    @IBAction func scrollMonthBtnActn(_ sender: UIButton) {
        let delta = sender.tag == 601 ? -1 : 1
        
        // Prevent navigating before the current month
        if delta == -1 {
            let today = Calendar.current.startOfDay(for: Date())
            guard bookingCalendar.currentPage >= today else { return }
        }
        
        if let newPage = Calendar.current.date(
            byAdding: .month, value: delta, to: bookingCalendar.currentPage
        ) {
            bookingCalendar.setCurrentPage(newPage, animated: true)
        }
    }
    
    // ── Month change ───────────────────────────────────────────────────────
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            updateMonthLabel()
     
            // Get the new month as a 2-digit string e.g. "03", "12"
            let newMonth = Calendar.current.component(.month, from: calendar.currentPage)
            let monthStr = String(format: "%02d", newMonth)
     
            // Update selectedMonthInNumber for month navigation
            selectedMonthInNumber = monthStr
     
            // Clear old data so stale dots/colours don't show for the new month
            datesWithMultipleEvents = [:]
            disabledDates = []
     
            // Hit the API for the new month
            params?.month = monthStr
            self.getAvailableSlots(inputParams: self.params?.getParams() ?? ["": ""])
        }
    
    func getMonthName(from calendar: FSCalendar) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMMM yyyy" // Full month name
        return dateFormatter.string(from: calendar.currentPage)
    }

    // ---------------------**********
    func isFutureOrCurrentMonth(year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())

        // Check if the given year is greater OR it's the same year but a future or current month
        return (year > currentYear) || (year == currentYear && month >= currentMonth)
    }
    
    /// Called every time a valid date is tapped. Wire up your navigation here.
    private func handleDateSelected(_ date: Date) {

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")

        switch slotBookFlow {

        case .bookTrainerHomeWorkout, .bookTrainerGymWorkout,
             .withTrainerMembership, .gymMembership:

            df.dateFormat = "dd-MM-yyyy"
            let selectedDateStr = df.string(from: date)

            df.dateFormat = "yyyy-MM-dd"
            let slotDateStr = df.string(from: date)

            print("Slot selected: \(selectedDateStr)")
            // Push SlotDurationViewController here …

        case .createPackage, .withoutTrainerMembership:
            print("Package start date selected: \(date)")
            // Compute end date, update UI …

        case .defaultFlow:
            print("Date tapped: \(date)")
        }
    }
}


// MARK: - FSCalendar DataSource & Delegate
extension NewCalenderViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {

    // ── Date bounds ────────────────────────────────────────────────────────
    func minimumDate(for calendar: FSCalendar) -> Date {
        // Allow the calendar to display from start of current month
        var comps = Calendar.current.dateComponents([.year, .month], from: Date())
        comps.day = 1
        return Calendar.current.date(from: comps)!
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        // Show up to 12 months ahead (adjust as needed)
        return Calendar.current.date(byAdding: .month, value: 12,
                                     to: minimumDate(for: calendar))!
    }

    // ── Custom cell ────────────────────────────────────────────────────────
    func calendar(_ calendar: FSCalendar,
                  cellFor date: Date,
                  at position: FSCalendarMonthPosition) -> FSCalendarCell {

        let cell = calendar.dequeueReusableCell(
            withIdentifier: "cell", for: date, at: position
        ) as! CustomCalendarCell

        configureCell(cell, for: date)
        return cell
    }

    func calendar(_ calendar: FSCalendar,
                  willDisplay cell: FSCalendarCell,
                  for date: Date,
                  at position: FSCalendarMonthPosition) {
        guard let c = cell as? CustomCalendarCell else { return }
        configureCell(c, for: date)
    }

    /// Applies the correct state (locked / normal / selected) to a cell.
    private func configureCell(_ cell: CustomCalendarCell, for date: Date) {
        let isSelected = selectedDates.contains(Calendar.current.startOfDay(for: date))

        if isSelected {
            cell.cellState = .selected
        } else if isDateInPast(date) || isDateDisabled(date) {
            cell.cellState = .locked
        } else {
            cell.cellState = .normal
        }

        // Event dot
        let key = ymdFormatter.string(from: date)
        cell.showEventDot = datesWithEvents[key] != nil
    }

    // ── Selection guard ────────────────────────────────────────────────────
    func calendar(_ calendar: FSCalendar,
                  shouldSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) -> Bool {
        // Disallow past dates and explicitly disabled dates
        return !isDateInPast(date) && !isDateDisabled(date)
    }

    func calendar(_ calendar: FSCalendar,
                  shouldDeselect date: Date,
                  at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true // Always allow deselection
    }

    // ── Selection callbacks ────────────────────────────────────────────────
        func calendar(_ calendar: FSCalendar,
                      didSelect date: Date,
                      at monthPosition: FSCalendarMonthPosition) {

            let day = Calendar.current.startOfDay(for: date)

            if allowsMultipleSelection {
                selectedDates.insert(day)
            } else {
                selectedDates = [day]
            }
            updateContinueButton(isEnabled: true)
            // Store selected month as 2-digit string e.g. "03", "12"
            let monthNumber = Calendar.current.component(.month, from: date)
            selectedMonthInNumber = String(format: "%02d", monthNumber)

            calendar.reloadData()
            handleDateSelected(date)
        }

        func calendar(_ calendar: FSCalendar,
                      didDeselect date: Date,
                      at monthPosition: FSCalendarMonthPosition) {

            let day = Calendar.current.startOfDay(for: date)
            selectedDates.remove(day)

            // Clear month if no dates remain selected
            if selectedDates.isEmpty {
                selectedMonthInNumber = nil
            }
            updateContinueButton(isEnabled: false)
            calendar.reloadData()
        }

    // ── Hide FSCalendar's default fill / border so our images take over ────
    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  fillDefaultColorFor date: Date) -> UIColor? {
        return .clear    // our bgImageView handles the fill
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  fillSelectionColorFor date: Date) -> UIColor? {
        return .clear
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  borderDefaultColorFor date: Date) -> UIColor? {
        return .clear
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  borderSelectionColorFor date: Date) -> UIColor? {
        return .clear
    }

    // ── Cell size & spacing (matches your screenshot) ──────────────────────
    func calendar(_ calendar: FSCalendar,
                  layout calendarLayout: FSCalendarAppearance,
                  sizeForItemAt date: Date) -> CGSize {
        let colWidth = calendar.bounds.width / 7
           return CGSize(width: colWidth, height: colWidth)
    }

    // ── Event dots – driven by datesWithEvents dict ────────────────────────
    func calendar(_ calendar: FSCalendar,
                  numberOfEventsFor date: Date) -> Int {
        let key = ymdFormatter.string(from: date)
        return datesWithEvents[key] != nil ? 1 : 0
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  eventDefaultColorsFor date: Date) -> [UIColor]? {
        let key = ymdFormatter.string(from: date)
        if let color = datesWithEvents[key] { return [color] }
        return nil
    }
}

//MARK: -------------------------EXTENSION FOR API
extension NewCalenderViewController {
    
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
                                                
                        if status.uppercased() == "CLOSED".uppercased() || status.uppercased() == "FAST FILLING".uppercased() {
                            self.disabledDates.append(getDate)
                        }
                      
                    }
                })
            }
            
            self.bookingCalendar.reloadData()
        })
    }
}

//  Three-state calendar cell:
//   • Past dates   → "LockBtn"     image
//   • Normal dates → "NormalBtn"   image
//   • Selected     → "SelectedBtn" image
//
//  KEY FIX: bgImageView has inset padding inside the cell so that even though
//  FSCalendar stretches cells to fill the full column width, the *visible*
//  rounded square is smaller — giving the appearance of gaps between cells.

import UIKit
import FSCalendar

// MARK: - Cell State
enum CalendarCellState {
    case locked     // past date  → LockBtn
    case normal     // future / today → NormalBtn
    case selected   // tapped → SelectedBtn
}

// MARK: - Custom Cell
class CustomCalendarCell: FSCalendarCell {

    // ── Tweak this to control the gap size between cells ──────────────────
    // 4 pt on each side → 8 pt total gap between adjacent cells
    private let cellInset: CGFloat = 4

    // ── Background image (one of the three asset images) ──────────────────
    private let bgImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()

    // ── Event dot ─────────────────────────────────────────────────────────
    private let eventDot: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 158/255, green: 188/255, blue: 255/255, alpha: 1)
        v.layer.cornerRadius = 3
        v.isHidden = true
        return v
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        // Tile is inset from the full cell
        let tileRect = bounds.insetBy(dx: cellInset, dy: cellInset)
        bgImageView.frame = tileRect

        // Force titleLabel to center of the inset tile (not the full cell)
        let labelSize = titleLabel.sizeThatFits(tileRect.size)
        titleLabel.frame = CGRect(
            x: tileRect.midX - labelSize.width / 2,
            y: tileRect.midY - labelSize.height / 2,
            width: labelSize.width,
            height: labelSize.height
        )
    }
    
    // ── Current state ──────────────────────────────────────────────────────
    var cellState: CalendarCellState = .normal {
        didSet { applyState() }
    }

    var showEventDot: Bool = false {
        didSet { eventDot.isHidden = !showEventDot }
    }

    // MARK: Init
    override init!(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Layout
    private func setup() {

        // ── Hide FSCalendar's own selection shape ──────────────────────────
        shapeLayer.isHidden = true

        // ── bgImageView sits BEHIND FSCalendar's titleLabel ────────────────
        // It is inset on all sides so the visible tile is smaller than the
        // actual cell frame — this creates the gap effect between cells.
        contentView.insertSubview(bgImageView, at: 0)
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: contentView.topAnchor,       constant:  cellInset),
            bgImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -cellInset),
            bgImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,   constant:  cellInset),
            bgImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -cellInset)
        ])

        // ── Event dot near the bottom of the visible tile ─────────────────
        contentView.addSubview(eventDot)
        NSLayoutConstraint.activate([
            eventDot.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            eventDot.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(cellInset + 3)),
            eventDot.widthAnchor.constraint(equalToConstant: 6),
            eventDot.heightAnchor.constraint(equalToConstant: 6)
        ])

        applyState()
    }

    // MARK: Apply image for current state
    private func applyState() {
        switch cellState {
        case .locked:
            bgImageView.image    = UIImage(named: "LockBtn")
            titleLabel.alpha     = 0.45
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.4)

        case .normal:
            bgImageView.image    = UIImage(named: "NormalBtn")
            titleLabel.alpha     = 1.0
            titleLabel.textColor = .white

        case .selected:
            bgImageView.image    = UIImage(named: "highlightBlueImg")
            titleLabel.alpha     = 1.0
            titleLabel.textColor = .white
        }
    }

    // MARK: Prevent FSCalendar from overriding our visuals
    override var isSelected: Bool {
        didSet { /* driven externally via cellState */ }
    }

    override var isPlaceholder: Bool {
        didSet { alpha = isPlaceholder ? 0 : 1 }
    }

    // MARK: Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        cellState    = .normal
        showEventDot = false
    }
}
