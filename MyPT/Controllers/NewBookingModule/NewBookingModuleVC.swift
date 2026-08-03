//
//  NewBookingModuleVC.swift
//  MyPT
//
//  Created by Manik Goel on 13/05/26.
//

import UIKit
import FSCalendar

class NewBookingModuleVC: CommonViewController {
    
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
    var selectedTag = 0 // 0 -> All Dates, 1 -> Mon, 2 -> Tue
    var newBookingSlotsData: NewBookingSlotsData?
    
    private var monthName: String? {
        didSet{
            self.monthTitleLbl.text = monthName
        }
    }
    
    /// Set to `true` if you want the user to be able to pick several dates.
    var allowsMultipleSelection: Bool = true
    
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
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnAllDates: UIButton!
    @IBOutlet weak var btnMon: UIButton!
    @IBOutlet weak var btnTue: UIButton!
    @IBOutlet weak var lblSession: UILabel!
    
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
        self.getNewBookingCheckClientApi()
    }
    
    func setCurrentMonth() {
        let currentMonth = Calendar.current.component(.month, from: Date())
        selectedMonthInNumber = String(format: "%02d", currentMonth)
        params = AvailParmsModel(type: inputParam?.type, trainer_id: inputParam?.trainer_id, month: selectedMonthInNumber)
        //        params = AvailParmsModel(type: "gym", trainer_id: "53", month: "03")
        self.getNewBookingCheckClientApi()
    }
    
    //MARK: ------------FONT SETUP
    func setUpFont() {
        DispatchQueue.main.async {
            self.titleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
            self.monthTitleLbl.font = AppFont.medium.size(16.0, familyName: familyFunnelSans)
            self.btnAllDates.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.btnMon.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.btnTue.titleLabel?.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.continueBtn.cornersWithBorder(radius: 8, corners: .allCorners)
            self.updateHeaderUI()
        }
    }
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        viewMain.layer.cornerRadius = 12
        viewMain.clipsToBounds = true
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
    
    /// Returns `true` when the date falls outside the allowed 30-day window.
    private func isDateBeyond30Days(_ date: Date) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        guard let last = Calendar.current.date(byAdding: .day, value: 29, to: today) else { return false }
        return Calendar.current.startOfDay(for: date) > last
    }
    
    private func isDateDisabled(_ date: Date) -> Bool {
        let key = ymdFormatter.string(from: date)
        return disabledDates.contains(key)
    }
    
    /// Returns `true` when the date's weekday does NOT match the active filter.
    /// - tag 0 (All Dates): every day is allowed
    /// - tag 1 (Mon):       only Monday(2), Wednesday(4), Friday(6)
    /// - tag 2 (Tue):       only Tuesday(3), Thursday(5), Saturday(7)
    private func isDateFilteredOut(_ date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date) // Sun=1 … Sat=7
        switch selectedTag {
        case 1:  return ![2, 4, 6].contains(weekday)   // Mon, Wed, Fri
        case 2:  return ![3, 5, 7].contains(weekday)   // Tue, Thu, Sat
        default: return false                           // All Dates
        }
    }
    
    @IBAction func onTapDaysTypes(_ sender: UIButton) {
        selectedTag = sender.tag
        updateHeaderUI()
        
        // Clear any existing selection when the filter changes
        selectedDates.removeAll()
        updateSessionLabel()
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
        bookingCalendar.reloadData()
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("continue btn actn.....")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        let dateStrings: [String] = selectedDates
            .sorted()
            .map { formatter.string(from: $0) }
        print(dateStrings)
        let vc: PickTimeForBooking = PickTimeForBooking.instantiate(appStoryboard: .newBookingModule)
        let groupId = newBookingSlotsData?.group?.id?.value
        vc.params = NewBookingParmsModel(
            type: newBookingSlotsData?.determined_type,
            group_id: groupId,
            dates: dateStrings,
            trainer_id: groupId == nil ? newBookingSlotsData?.trainers?.first?.id?.value : nil,
            preferred_time: "08:00",
            lat: inputParam?.lat,
            long: inputParam?.long
        )
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: ------------SHOW DATE START/END
    func updateUI(selectedView: [UIButton]) {
        for i in selectedView {
            if i.isSelected {
                i.backgroundColor = UIColor.clear
                i.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
            } else {
                i.backgroundColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1)
                i.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
        }
    }
    
    private func updateHeaderUI() {
        let buttons = [btnAllDates, btnMon, btnTue]
        
        buttons.forEach { button in
            
            let isSelected = button?.tag == selectedTag
            button?.layer.borderWidth = 2
            
            button?.backgroundColor = isSelected
            ? UIColor(red: 224.0/255.0, green: 254/255.0, blue: 8/255.0, alpha: 0.05)
            : .clear
            
            button?.setTitleColor(
                isSelected ? .white : .white,
                for: .normal
            )
            
            button?.setCornerRadius(
                borderWidth: 2,
                borderColor:
                    isSelected
                ? UIColor(red: 224.0/255.0, green: 254/255.0, blue: 8/255.0, alpha: 0.4)
                : UIColor(red: 255.0/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.1),
                cornerRadious: 8.0
            )
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
        //            self.getAvailableSlots(inputParams: self.params?.getParams() ?? ["": ""])
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
extension NewBookingModuleVC: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    // ── Date bounds ────────────────────────────────────────────────────────
    func minimumDate(for calendar: FSCalendar) -> Date {
        // Start from today
        return Calendar.current.startOfDay(for: Date())
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        // Allow only the next 30 days (today + 29 days)
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: 29, to: today)!
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
        } else if isDateInPast(date) || isDateBeyond30Days(date) || isDateDisabled(date) || isDateFilteredOut(date) {
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
        // Disallow past dates, dates beyond 30 days, explicitly disabled dates, and filtered-out weekdays
        return !isDateInPast(date) && !isDateBeyond30Days(date) && !isDateDisabled(date) && !isDateFilteredOut(date)
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
            TapticEngine.selection.feedback()
            
            let totalAvailable = newBookingSlotsData?.total_available ?? 0
            let maxSelectable = max(1, min(10, totalAvailable)) // Ensure at least 1 day can be selected if data is missing/invalid
            
            // Enforce selection cap
            if selectedDates.count >= maxSelectable {
                calendar.deselect(date)
                showMaxSelectionAlert(max: maxSelectable)
                return
            }
            selectedDates.insert(day)
        } else {
            selectedDates = [day]
        }
        updateContinueButton(isEnabled: !selectedDates.isEmpty)
        // Store selected month as 2-digit string e.g. "03", "12"
        let monthNumber = Calendar.current.component(.month, from: date)
        selectedMonthInNumber = String(format: "%02d", monthNumber)
        
        updateSessionLabel()
        calendar.reloadData()
        handleDateSelected(date)
    }
    
    /// Shows an alert when the user tries to select more than the allowed limit.
    private func showMaxSelectionAlert(max: Int) {
        let alert = UIAlertController(
            title: "Limit Reached",
            message: "You can select a maximum of \(max) days.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func calendar(_ calendar: FSCalendar,
                  didDeselect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        
        let day = Calendar.current.startOfDay(for: date)
        selectedDates.remove(day)
        
        // Clear month if no dates remain selected
        if selectedDates.isEmpty {
            selectedMonthInNumber = nil
            updateContinueButton(isEnabled: false)
        }
        updateSessionLabel()
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

// MARK: -------------------------EXTENSION FOR API
extension NewBookingModuleVC {
    private func getNewBookingCheckClientApi() {
        
        NewBookingVM.getNewBookingCheckClientApi(viewController: self, inputParms: nil, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            if let getData = getResultData.data {
                self.newBookingSlotsData = getData
            }
            DispatchQueue.main.async {
                self.updateSessionLabel()
            }
            self.bookingCalendar.reloadData()
        })
    }
    
    private func updateSessionLabel() {
        let totalAvailable = self.newBookingSlotsData?.total_available ?? 0
        let totalSession = self.newBookingSlotsData?.total_session ?? 0
        let remaining = max(0, totalAvailable - selectedDates.count)
        self.lblSession.text = "SESSION REMAINING: \(remaining) of \(totalSession)"
    }
}
