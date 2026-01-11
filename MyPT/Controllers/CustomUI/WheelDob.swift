//
//  WheelDob.swift
//  MyPT
//
//  Created by techsaga corp on 25/04/25.
//

import UIKit

protocol SelectedDateDelegate: AnyObject {
    func selectAge(age:String?)
    func selectDate(date:(year: String?, month: String?, day: String?)?)
}

class WheelDob: UIView {
    
    weak var delegate: SelectedDateDelegate?
    private var didSetupCenterConstraints = false
    private let centerView = UIView() // The view you want to center
    private let ageLable = UILabel()
    
    private let yearPicker = WheelDobPicker()
    private let monthPicker = WheelDobPicker()
    private let dayPicker = WheelDobPicker()
    private var selectedYear : Int?
    private var selectedMonth : String?
    private var selectedDays : Int?
    private let isSmallDevice = UIScreen.main.bounds.height < 700
    
    private let monthBgIV: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "MonthBg"))
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let dayBgIV: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "DateBg"))
        iv.contentMode = .scaleToFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private var getcalendarDate: (year: String?, month: String?, day: String?) {
        didSet{
            let year:Int = Int(getcalendarDate.year ?? "") ?? 0
            let day: Int = Int(getcalendarDate.day ?? "") ?? 0
            let age =  calculateAge(birthYear: year, birthMonth: getMonthNumber(for: getcalendarDate.month ?? "") ?? 1, birthDay: day)
            self.setAttributeAgeLbl(age: age)
            delegate?.selectAge(age: "\(age)")
            delegate?.selectDate(date: getcalendarDate)
        }
    }
    
    private let triangleImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ageTriangle")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickers()
        layoutPickers()
        setupCenterView()
        setupMonthBackgroundConstraints()
        setupDayBackgroundConstraints()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        // ✅ Ensure view is in hierarchy
        guard superview != nil else { return }

        // ✅ Ensure constraints are added only once
        guard !didSetupCenterConstraints else { return }
        didSetupCenterConstraints = true

        layoutCenterView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPickers()
        layoutPickers()
        setupCenterView() // New: Setup the center view
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    private func setAttributeAgeLbl(age:Int?){
        let mainAttr = [
            .font: AppFont.medium.size(18.0, familyName: familyFunnelSans),
            .foregroundColor: UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.75).cgColor
        ] as [NSAttributedString.Key : Any]
        
        let ageAttr = [
            .font: AppFont.medium.size(24.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.txtSkip
        ] as [NSAttributedString.Key : Any]
        
        let attrParts: [AttributedStringComponent] = [
            NSAttributedString(string: "Your age is ", attributes: mainAttr),
            NSAttributedString(string: "\(age ?? 0)", attributes: ageAttr)
        ]
        self.ageLable.attributedText = NSAttributedString(from: attrParts, defaultAttributes: mainAttr)
    }
    
    private func setupCenterView() {
        centerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerView)

        // ADD triangle image
        centerView.addSubview(triangleImageView)

        ageLable.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(ageLable)
        setAttributeAgeLbl(age: 0)
    }
    
    func default18YearsAgoDate() -> Date {
            Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
        }
    
    private func layoutCenterView() {

        NSLayoutConstraint.activate([
            // Center view
            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerView.centerYAnchor.constraint(equalTo: dayPicker.centerYAnchor),
            centerView.widthAnchor.constraint(equalTo: widthAnchor),
            centerView.heightAnchor.constraint(equalToConstant: isSmallDevice ? 60 : 120),

            // 🔴 Use monthPicker instead of dayPicker (more stable)
            centerView.topAnchor.constraint(equalTo: dayPicker.topAnchor, constant: 90),

            // Triangle image
            triangleImageView.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            triangleImageView.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 0),
            triangleImageView.widthAnchor.constraint(equalToConstant: 64),
            triangleImageView.heightAnchor.constraint(equalToConstant: 64),

            // Age label
            ageLable.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            ageLable.topAnchor.constraint(equalTo: triangleImageView.bottomAnchor, constant: isSmallDevice ? 20 : 48),
            ageLable.heightAnchor.constraint(equalToConstant: 30),
//            ageLable.widthAnchor.constraint(greaterThanOrEqualToConstant: 150) // ✅ IMPORTANT
        ])

        bringSubviewToFront(centerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        yearPicker.topArcShow = false
//        setupCenterView() // New: Setup the center view
//        layoutCenterView()
//        updateTrianglePath()
    }
    
    private func setupPickers() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startYear = currentYear - 200
        let endYear = currentYear

        yearPicker.values = (startYear...endYear).map { "\($0)" }
        monthPicker.values = Calendar.current.shortMonthSymbols
        dayPicker.values = (1...31).map { "\($0)" }

        // ✅ 1️⃣ Month background sabse pehle
        addSubview(monthBgIV)
        sendSubviewToBack(monthBgIV)
        
        // ✅ Day background
           addSubview(dayBgIV)
           sendSubviewToBack(dayBgIV)

        // ✅ 2️⃣ Phir pickers
        [yearPicker, monthPicker, dayPicker].forEach { picker in
            addSubview(picker)
        }
        
        yearPicker.addTarget(self, action: #selector(getYearChanged(_:)), for: .valueChanged)
        monthPicker.addTarget(self, action: #selector(getMonthChanged(_:)), for: .valueChanged)
        dayPicker.addTarget(self, action: #selector(getDaysChanged(_:)), for: .valueChanged)
    }
    
    private func setupMonthBackgroundConstraints() {
        NSLayoutConstraint.activate([
            monthBgIV.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthBgIV.trailingAnchor.constraint(equalTo: trailingAnchor),

            // 👇 month text ke peeche alignment
            monthBgIV.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: -20),
            monthBgIV.heightAnchor.constraint(equalToConstant: isSmallDevice ? 90 : 110)
        ])
    }
    
    private func setupDayBackgroundConstraints() {
        NSLayoutConstraint.activate([
            dayBgIV.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayBgIV.trailingAnchor.constraint(equalTo: trailingAnchor),

            // 👇 day picker ke peeche
            dayBgIV.topAnchor.constraint(equalTo: dayPicker.topAnchor, constant: -20),

            // 👇 DateBg SVG ke size ke hisaab se
            dayBgIV.heightAnchor.constraint(equalToConstant: isSmallDevice ? 90 : 110)
        ])
    }
    
    func selectInitialDate(year: String, month: String, day: String) {

            // 🔴 auto scroll band
            yearPicker.allowAutoScrollToLast = false
            monthPicker.allowAutoScrollToLast = false
            dayPicker.allowAutoScrollToLast = false

            if let y = yearPicker.values.firstIndex(of: year) {
                yearPicker.selectedIndex = y
                yearPicker.scrollToIndex(y)
                selectedYear = Int(year)
            }

            if let m = monthPicker.values.firstIndex(of: month) {
                monthPicker.selectedIndex = m
                monthPicker.scrollToIndex(m)
                selectedMonth = month
            }

            if let d = dayPicker.values.firstIndex(of: day) {
                dayPicker.selectedIndex = d
                dayPicker.scrollToIndex(d)
            }

            getcalendarDate = (year, month, day)
        }
    
    @objc func getYearChanged(_ sender: WheelDobPicker) {
        let selectedValue = sender.values[sender.selectedIndex]
        self.selectedYear = Int(selectedValue)
        let totalDays = daysIn(month: getMonthNumber(for: self.selectedMonth ?? "jan") ?? 1, year: self.selectedYear ?? 0)
        dayPicker.values  = (1...totalDays).map { "\($0)" }
        
        getcalendarDate.year = "\(self.selectedYear ?? 0)"
    }
    
    @objc func getMonthChanged(_ sender: WheelDobPicker) {
        let selectedValue = sender.values[sender.selectedIndex]
        self.selectedMonth = selectedValue
        let totalDays = daysIn(month: getMonthNumber(for: self.selectedMonth ?? "jan") ?? 1, year: self.selectedYear ?? 0)
        dayPicker.values  = (1...totalDays).map { "\($0)" }
        
        getcalendarDate.month = self.selectedMonth
    }
    
    @objc func getDaysChanged(_ sender: WheelDobPicker) {
        let selectedValue = sender.values[sender.selectedIndex]
        getcalendarDate.day = selectedValue
    }
    
    func daysIn(month: Int, year: Int) -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        
        let calendar = Calendar.current
        
        if let date = calendar.date(from: dateComponents),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        
        return 0 // fallback in case of invalid month/year
    }
    
    func monthNumber(from name: String) -> Int? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM" // For full names like "January"
        
        // Try full name first
        if let date = formatter.date(from: name.capitalized) {
            return Calendar.current.component(.month, from: date)
        }
        
        // Try short name like "Jan"
        formatter.dateFormat = "MMM"
        if let date = formatter.date(from: name.capitalized) {
            return Calendar.current.component(.month, from: date)
        }
        
        return nil
    }
    
    private func layoutPickers() {
        // Use Auto Layout for flexibility
        [yearPicker, monthPicker, dayPicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            yearPicker.topAnchor.constraint(equalTo: topAnchor),
            yearPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            yearPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            yearPicker.heightAnchor.constraint(equalToConstant: isSmallDevice ? 300 : 450),
            
            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            monthPicker.topAnchor.constraint(equalTo: yearPicker.topAnchor, constant: isSmallDevice ? 60 : 80.0),
            monthPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0),
            
            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: isSmallDevice ? 60 : 80.0),
            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
        ])
    }

//    private func layoutPickers() {
//
//        [yearPicker, monthPicker, dayPicker].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//        }
//        let pickerHeight: CGFloat = 100   // 👈 thickness control
//        let spacing: CGFloat = 4          // 👈 gap control
//
//        NSLayoutConstraint.activate([
//            // YEAR
//            yearPicker.topAnchor.constraint(equalTo: topAnchor),
//            yearPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            yearPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            yearPicker.heightAnchor.constraint(equalToConstant: pickerHeight),
//
//            // MONTH
//            monthPicker.topAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: spacing),
//            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            monthPicker.heightAnchor.constraint(equalToConstant: pickerHeight),
//
//            // DAY
//            dayPicker.topAnchor.constraint(equalTo: monthPicker.bottomAnchor, constant: spacing),
//            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            dayPicker.heightAnchor.constraint(equalToConstant: pickerHeight),
//        ])
//    }

    
    func getMonthNumber(for monthAbbreviation: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent behavior
        let shortMonthSymbols = dateFormatter.shortMonthSymbols.map { $0.lowercased() } // Lowercased for case-insensitivity
        
        // Find the index of the month abbreviation
        if let index = shortMonthSymbols.firstIndex(of: monthAbbreviation.lowercased()) {
            return index + 1 // Adding 1 because months are 1-indexed
        } else {
            return nil // Invalid abbreviation
        }
    }
    
    private func calculateAge(birthYear: Int, birthMonth: Int, birthDay: Int, currentYear: Int? = nil, currentMonth: Int? = nil, currentDay: Int? = nil) -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        // Use current date components if not provided
        let currentYearProvided = currentYear ?? calendar.component(.year, from: now)
        let currentMonthProvided = currentMonth ?? calendar.component(.month, from: now)
        let currentDayProvided = currentDay ?? calendar.component(.day, from: now)
        
        // Create birth date
        guard let birthDate = calendar.date(from: DateComponents(year: birthYear, month: birthMonth, day: birthDay)) else {
            print("Invalid birth date")
            return 0
        }
        
        // Create current date
        guard let currentDate = calendar.date(from: DateComponents(year: currentYearProvided, month: currentMonthProvided, day: currentDayProvided)) else {
            print("Invalid current date")
            return 0
        }
        
        // Calculate age
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
        return ageComponents.year ?? 0
    }
    
}

//MARK: ------------- PICKER CONTROLLER
class WheelDobPicker: UIControl {
    
    private var isScrolling = false
    private let scrollView = UIScrollView()
    private var itemLabels: [UILabel] = []
    private let labelSpacing: CGFloat = 15
    private let labelHeight: CGFloat = 50
    private let labelFixedWidth: CGFloat = 70
    private let centerIndicator = UIView()
    private let topEclipseView = UIView()
    private let topArcLayer = CAShapeLayer()
    var allowAutoScrollToLast = true
    
    var topArcShow: Bool = true {
        didSet{
            topArcLayer.isHidden = (topArcShow ? false : true)
        }
    }
    
    public var values: [String] = [] {
            didSet {
                setupItems()

                guard allowAutoScrollToLast else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.scrollToLastItem(animated: true)
                }
            }
        }
    
    public var selectedIndex: Int = 0 {
        didSet {
            sendActions(for: .valueChanged)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        //        setupCenterIndicator()
        setupTopEclipseView()
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupCenterIndicator()
        setupTopEclipseView()
        setupShadow()
    }
    
    private func setupShadow() {
        // Set up shadow for the top of the control
        layer.shadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.4 // Adjust opacity
        layer.shadowOffset = CGSize(width: 0, height: -1) // Shadow offset to the top
        layer.shadowRadius = 0 // Blur radius
        // Optional: Add corner radius if needed
        layer.cornerRadius = 0
        layer.masksToBounds = false // Allow shadow outside bounds
    }
    
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .normal //.fast
        scrollView.delegate = self
        addSubview(scrollView)
    }
    
    private func setupItems() {
        itemLabels.forEach { $0.removeFromSuperview() }
        itemLabels.removeAll()
        
        for value in values {
            let label = UILabel()
            label.text = value
            label.font = .systemFont(ofSize: 18)
            label.textAlignment = .center
            label.textColor = .darkGray
            scrollView.addSubview(label)
            itemLabels.append(label)
        }
        setNeedsLayout()
    }
    
    private func setupCenterIndicator() {
        centerIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        centerIndicator.layer.cornerRadius = 1
        addSubview(centerIndicator)
    }
    
    private func setupTopEclipseView() {
        topArcLayer.strokeColor = UIColor.otpGlow.withAlphaComponent(0.7).cgColor
        topArcLayer.fillColor = UIColor.clear.cgColor
        topArcLayer.lineWidth = 0
        topEclipseView.layer.addSublayer(topArcLayer)
        
        topEclipseView.backgroundColor = UIColor.clear //UIColor(red: 32/255, green: 28/255, blue: 24/255, alpha: 1.0)
        addSubview(topEclipseView)
        sendSubviewToBack(topEclipseView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        
        let sideInset = bounds.width / 2
        scrollView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        
        var xPosition: CGFloat = 0
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let radius: CGFloat = bounds.height
        
        for label in itemLabels {
            label.bounds = CGRect(x: 0, y: 0, width: labelFixedWidth, height: labelHeight)
            label.center = CGPoint(x: xPosition + labelFixedWidth / 2, y: radius * (1 - cos(0)) + 40)
            
            let deltaX = label.center.x - centerX
            let angle = deltaX / radius
            let clampedAngle = angle.clamped(to: -.pi/2 ... .pi/2)
            let arcY = radius * (1 - cos(clampedAngle))
            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)
            
            label.center = CGPoint(x: xPosition + labelFixedWidth / 2, y: arcY + 40)
            label.transform = CGAffineTransform(scaleX: scale, y: scale)
            label.alpha = scale
            
            xPosition += labelFixedWidth + labelSpacing
        }
        
        scrollView.contentSize = CGSize(width: xPosition - labelSpacing, height: bounds.height)
        //        centerIndicator.frame = CGRect(x: bounds.midX - (labelFixedWidth + 10), y: 0, width: labelFixedWidth + 10, height: bounds.height)
        setupTopEclipseArc()
        highlightCenterLabel()
    }
    
    private func setupTopEclipseArc() {
        let eclipseHeight: CGFloat = 150
        let eclipseWidth = bounds.width
        topEclipseView.frame = CGRect(x: 0, y: 0, width: eclipseWidth, height: eclipseHeight)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 45))
        path.addQuadCurve(to: CGPoint(x: eclipseWidth, y: 45),
                          controlPoint: CGPoint(x: eclipseWidth / 2, y: -eclipseHeight / 2))
        path.addLine(to: CGPoint(x: eclipseWidth, y: eclipseHeight))
        path.addLine(to: CGPoint(x: 0, y: eclipseHeight))
        path.close()
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        topEclipseView.layer.mask = mask
        
        //--------------
        let slayer = CAShapeLayer()
        let center = CGPoint(x: (topEclipseView.bounds.width / 2), y: topEclipseView.bounds.height + 10)
        let radius: CGFloat = topEclipseView.bounds.height
        let startAngle: CGFloat = 4 * .pi / 4
        let endAngle: CGFloat = 0.0
        slayer.path = UIBezierPath(arcCenter: center,
                                   radius: radius,
                                   startAngle: startAngle,
                                   endAngle: endAngle,
                                   clockwise: true).cgPath
        slayer.lineWidth = 150.0
        slayer.lineCap = .round
        slayer.strokeColor = UIColor(red: 0/255, green: 15/255, blue: 6/255, alpha: 1.0).cgColor //UIColor(red: 32/255, green: 28/255, blue: 24/255, alpha: 0.2).cgColor
        //rgba(0, 5, 2, 1)
        slayer.fillColor = UIColor.clear.cgColor
//        topEclipseView.layer.addSublayer(slayer)
        
        
        //----------------- line paths
        let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: eclipseWidth * 0.25, y: 1))
        arcPath.addQuadCurve(to: CGPoint(x: eclipseWidth * 0.75, y: 1),
                             controlPoint: CGPoint(x: eclipseWidth / 2, y: -30))
        topArcLayer.path = arcPath.cgPath
        topEclipseView.layer.addSublayer(topArcLayer)
        
        //-------------------
        //ic_dobCurve
        
        
    }
    
    private func highlightCenterLabel() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        for (index, label) in itemLabels.enumerated() {
            if abs(label.center.x - centerX) < (labelFixedWidth + labelSpacing) / 2 {
                label.textColor = UIColor.appWhite
                label.font = AppFont.bold.size(30, familyName: familyFunnelSans)
                label.numberOfLines = 2
                selectedIndex = index
            } else {
                label.textColor = UIColor.appDarkGray
                label.font = AppFont.medium.size(22, familyName: familyFunnelSans)
                label.numberOfLines = 2
            }
        }
    }
    
    private func snapToNearest() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        var closestIndex = 0
        var closestDistance = CGFloat.greatestFiniteMagnitude
        
        for (index, label) in itemLabels.enumerated() {
            let distance = abs(label.center.x - centerX)
            if distance < closestDistance {
                closestDistance = distance
                closestIndex = index
            }
        }
        
        let targetLabel = itemLabels[closestIndex]
        let targetOffsetX = targetLabel.center.x - scrollView.bounds.width / 2
        scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
    }
}

extension WheelDobPicker: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearest()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearest()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
    }
    
    func scrollToIndex(_ index: Int, animated: Bool = false) {
            guard index >= 0, index < itemLabels.count else { return }

            let label = itemLabels[index]
            let offsetX = label.center.x - scrollView.bounds.width / 2
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
        }
}

extension WheelDobPicker {
    
    // Method to forcefully scroll to the last item
    func scrollToLastItem(animated: Bool = true) {
        // Prevent continuous scrolling by checking if already scrolling
        guard !isScrolling else { return }
        isScrolling = true
        // Ensure the values array is not empty
        guard !values.isEmpty else { return }
        // Calculate the position of the last label
        let lastLabelIndex = values.count - 1
        let lastLabel = itemLabels[lastLabelIndex]
        // Calculate the target offset to scroll to the last label
        let targetOffsetX = lastLabel.center.x - scrollView.bounds.width / 2
        // Ensure the offset is within the content bounds
        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
        let clampedOffsetX = min(max(targetOffsetX, 0), maxOffsetX)
        
        self.scrollView.setContentOffset(CGPoint(x: clampedOffsetX, y: 0), animated: animated)
        //        // Reset scrolling flag after animation completes
        //           if !animated {
        //               isScrolling = false
        //           }
        //
    }
}

// MARK: - Helper Extension
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}




////MARK: -------------------- wheel DatePickerContainerView
//protocol SelectedDateDelegate: AnyObject {
//    func selectAge(age:String?)
//    func selectDate(date:(year: String?, month: String?, day: String?)?)
//}
//
//class WheelDob: UIView {
//    
//    weak var delegate: SelectedDateDelegate?
//    private var didSetupCenterConstraints = false
//
////    private let triangleLayer = CAShapeLayer()
//    private let centerView = UIView() // The view you want to center
//    private let ageLable = UILabel()
//    
//    private let yearPicker = WheelDobPicker()
//    private let monthPicker = WheelDobPicker()
//    private let dayPicker = WheelDobPicker()
//    private var selectedYear : Int?
//    private var selectedMonth : String?
//    private var selectedDays : Int?
//    
//    private var getcalendarDate: (year: String?, month: String?, day: String?) {
//        didSet{
//            let year:Int = Int(getcalendarDate.year ?? "") ?? 0
//            let day: Int = Int(getcalendarDate.day ?? "") ?? 0
//            let age =  calculateAge(birthYear: year, birthMonth: getMonthNumber(for: getcalendarDate.month ?? "") ?? 1, birthDay: day)
//            self.setAttributeAgeLbl(age: age)
//            delegate?.selectAge(age: "\(age)")
//            delegate?.selectDate(date: getcalendarDate)
//        }
//    }
//    
//    private let triangleImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(named: "ageTriangle")
//        iv.contentMode = .scaleAspectFit
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        return iv
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupPickers()
//        layoutPickers()
//        setupCenterView()
//    }
//    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//
//        // ✅ Ensure view is in hierarchy
//        guard superview != nil else { return }
//
//        // ✅ Ensure constraints are added only once
//        guard !didSetupCenterConstraints else { return }
//        didSetupCenterConstraints = true
//
//        layoutCenterView()
//    }
//
//
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupPickers()
//        layoutPickers()
//        setupCenterView() // New: Setup the center view
////        layoutCenterView() // New: Layout the center view
//    }
//    
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        
//    }
//    
//    private func setAttributeAgeLbl(age:Int?){
//        let mainAttr = [
//            .font: AppFont.medium.size(18.0, familyName: familyFunnelSans),
//            .foregroundColor: UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.75).cgColor
//        ] as [NSAttributedString.Key : Any]
//        
//        let ageAttr = [
//            .font: AppFont.medium.size(25.0, familyName: familyFunnelSans),
//            .foregroundColor: UIColor.txtSkip
//        ] as [NSAttributedString.Key : Any]
//        
//        let attrParts: [AttributedStringComponent] = [
//            NSAttributedString(string: "Your age is ", attributes: mainAttr),
//            NSAttributedString(string: "\(age ?? 0)", attributes: ageAttr)
//        ]
//        self.ageLable.attributedText = NSAttributedString(from: attrParts, defaultAttributes: mainAttr)
//    }
//    
//    private func setupCenterView() {
//        centerView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(centerView)
//
//        // ADD triangle image
//        centerView.addSubview(triangleImageView)
//
//        ageLable.translatesAutoresizingMaskIntoConstraints = false
//        centerView.addSubview(ageLable)
//        setAttributeAgeLbl(age: 0)
//    }
//    
//    private func layoutCenterView() {
//
//        NSLayoutConstraint.activate([
//            // Center view
//            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            centerView.widthAnchor.constraint(equalTo: widthAnchor),
//            centerView.heightAnchor.constraint(equalToConstant: 120),
//
//            // 🔴 Use monthPicker instead of dayPicker (more stable)
//            centerView.topAnchor.constraint(equalTo: dayPicker.topAnchor, constant: 90),
//
//            // Triangle image
//            triangleImageView.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
//            triangleImageView.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 0),
//            triangleImageView.widthAnchor.constraint(equalToConstant: 64),
//            triangleImageView.heightAnchor.constraint(equalToConstant: 64),
//
//            // Age label
//            ageLable.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
//            ageLable.topAnchor.constraint(equalTo: triangleImageView.bottomAnchor, constant: 49),
//            ageLable.heightAnchor.constraint(equalToConstant: 40),
////            ageLable.widthAnchor.constraint(greaterThanOrEqualToConstant: 150) // ✅ IMPORTANT
//        ])
//
//        bringSubviewToFront(centerView)
//    }
//
//
//    
////    private func layoutCenterView() {
////        
////        NSLayoutConstraint.activate([
////            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
////            centerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
////            centerView.heightAnchor.constraint(equalToConstant: 100),
////            centerView.topAnchor.constraint(equalTo: dayPicker.topAnchor, constant: 90.0),
////            ageLable.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
////            ageLable.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: -10.0),
////            ageLable.heightAnchor.constraint(equalToConstant: 50)
////        ])
////        
////        self.bringSubviewToFront(centerView)
////        centerView.bringSubviewToFront(ageLable)
////        centerView.backgroundColor = UIColor.clear
//////        updateTrianglePath() // Initial triangle drawing
////    }
//    
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        yearPicker.topArcShow = false
////        setupCenterView() // New: Setup the center view
////        layoutCenterView()
////        updateTrianglePath()
//    }
//    
//    private func setupPickers() {
//        let currentYear = Calendar.current.component(.year, from: Date())
//        let startYear = currentYear - 200
//        let endYear = currentYear
//        
//        yearPicker.values = (startYear...endYear).map { "\($0)" }
//        monthPicker.values = Calendar.current.shortMonthSymbols
//        dayPicker.values = (1...31).map { "\($0)" }
//        
//        [yearPicker, monthPicker, dayPicker].forEach { picker in
//            
//            addSubview(picker)
//        }
//        
//        yearPicker.addTarget(self, action: #selector(getYearChanged(_:)), for: .valueChanged)
//        monthPicker.addTarget(self, action: #selector(getMonthChanged(_:)), for: .valueChanged)
//        dayPicker.addTarget(self, action: #selector(getDaysChanged(_:)), for: .valueChanged)
//    }
//    
//    
//    @objc func getYearChanged(_ sender: WheelDobPicker) {
//        let selectedValue = sender.values[sender.selectedIndex]
//        self.selectedYear = Int(selectedValue)
//        let totalDays = daysIn(month: getMonthNumber(for: self.selectedMonth ?? "jan") ?? 1, year: self.selectedYear ?? 0)
//        dayPicker.values  = (1...totalDays).map { "\($0)" }
//        
//        getcalendarDate.year = "\(self.selectedYear ?? 0)"
//    }
//    
//    @objc func getMonthChanged(_ sender: WheelDobPicker) {
//        let selectedValue = sender.values[sender.selectedIndex]
//        self.selectedMonth = selectedValue
//        let totalDays = daysIn(month: getMonthNumber(for: self.selectedMonth ?? "jan") ?? 1, year: self.selectedYear ?? 0)
//        dayPicker.values  = (1...totalDays).map { "\($0)" }
//        
//        getcalendarDate.month = self.selectedMonth
//    }
//    
//    @objc func getDaysChanged(_ sender: WheelDobPicker) {
//        let selectedValue = sender.values[sender.selectedIndex]
//        getcalendarDate.day = selectedValue
//    }
//    
//    
//    func daysIn(month: Int, year: Int) -> Int {
//        var dateComponents = DateComponents()
//        dateComponents.year = year
//        dateComponents.month = month
//        
//        let calendar = Calendar.current
//        
//        if let date = calendar.date(from: dateComponents),
//           let range = calendar.range(of: .day, in: .month, for: date) {
//            return range.count
//        }
//        
//        return 0 // fallback in case of invalid month/year
//    }
//    
//    func monthNumber(from name: String) -> Int? {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.dateFormat = "MMMM" // For full names like "January"
//        
//        // Try full name first
//        if let date = formatter.date(from: name.capitalized) {
//            return Calendar.current.component(.month, from: date)
//        }
//        
//        // Try short name like "Jan"
//        formatter.dateFormat = "MMM"
//        if let date = formatter.date(from: name.capitalized) {
//            return Calendar.current.component(.month, from: date)
//        }
//        
//        return nil
//    }
//    
//    
//    private func layoutPickers() {
//        // Use Auto Layout for flexibility
//        
//        [yearPicker, monthPicker, dayPicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
//        
//        NSLayoutConstraint.activate([
//            yearPicker.topAnchor.constraint(equalTo: topAnchor),
//            yearPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            yearPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            yearPicker.heightAnchor.constraint(equalToConstant: 450),
//            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            monthPicker.topAnchor.constraint(equalTo: yearPicker.topAnchor, constant: 90.0),
//            monthPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0),
//            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: 90.0),
//            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
//        ])
//    }
//    
//    func getMonthNumber(for monthAbbreviation: String) -> Int? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent behavior
//        let shortMonthSymbols = dateFormatter.shortMonthSymbols.map { $0.lowercased() } // Lowercased for case-insensitivity
//        
//        // Find the index of the month abbreviation
//        if let index = shortMonthSymbols.firstIndex(of: monthAbbreviation.lowercased()) {
//            return index + 1 // Adding 1 because months are 1-indexed
//        } else {
//            return nil // Invalid abbreviation
//        }
//    }
//    
//    private func calculateAge(birthYear: Int, birthMonth: Int, birthDay: Int, currentYear: Int? = nil, currentMonth: Int? = nil, currentDay: Int? = nil) -> Int {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        // Use current date components if not provided
//        let currentYearProvided = currentYear ?? calendar.component(.year, from: now)
//        let currentMonthProvided = currentMonth ?? calendar.component(.month, from: now)
//        let currentDayProvided = currentDay ?? calendar.component(.day, from: now)
//        
//        // Create birth date
//        guard let birthDate = calendar.date(from: DateComponents(year: birthYear, month: birthMonth, day: birthDay)) else {
//            print("Invalid birth date")
//            return 0
//        }
//        
//        // Create current date
//        guard let currentDate = calendar.date(from: DateComponents(year: currentYearProvided, month: currentMonthProvided, day: currentDayProvided)) else {
//            print("Invalid current date")
//            return 0
//        }
//        
//        // Calculate age
//        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
//        return ageComponents.year ?? 0
//    }
//    
//}
//
////MARK: ------------- PICKER CONTROLLER
//class WheelDobPicker: UIControl {
//    
//    private var isScrolling = false
//    private let scrollView = UIScrollView()
//    private var itemLabels: [UILabel] = []
//    private let labelSpacing: CGFloat = 5
//    private let labelHeight: CGFloat = 50
//    private let labelFixedWidth: CGFloat = 70
//    private let centerIndicator = UIView()
//    private let topEclipseView = UIView()
//    private let topArcLayer = CAShapeLayer()
//    
//    var topArcShow: Bool = true {
//        didSet{
//            topArcLayer.isHidden = (topArcShow ? false : true)
//        }
//    }
//    
//    public var values: [String] = [] {
//        didSet {
//            setupItems()
//            
//            // Scroll to the last item after updating values
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                self.scrollToLastItem(animated: true)
//            }
//            
//        }
//    }
//    
//    public var selectedIndex: Int = 0 {
//        didSet {
//            sendActions(for: .valueChanged)
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupScrollView()
//        //        setupCenterIndicator()
//        setupTopEclipseView()
//        setupShadow()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupScrollView()
//        setupCenterIndicator()
//        setupTopEclipseView()
//        setupShadow()
//    }
//    
//    private func setupShadow() {
//        // Set up shadow for the top of the control
//        layer.shadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
//        layer.shadowOpacity = 0.4 // Adjust opacity
//        layer.shadowOffset = CGSize(width: 0, height: -1) // Shadow offset to the top
//        layer.shadowRadius = 0 // Blur radius
//        // Optional: Add corner radius if needed
//        layer.cornerRadius = 0
//        layer.masksToBounds = false // Allow shadow outside bounds
//    }
//    
//    private func setupScrollView() {
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.decelerationRate = .normal //.fast
//        scrollView.delegate = self
//        addSubview(scrollView)
//    }
//    
//    private func setupItems() {
//        itemLabels.forEach { $0.removeFromSuperview() }
//        itemLabels.removeAll()
//        
//        for value in values {
//            let label = UILabel()
//            label.text = value
//            label.font = .systemFont(ofSize: 18)
//            label.textAlignment = .center
//            label.textColor = .darkGray
//            scrollView.addSubview(label)
//            itemLabels.append(label)
//        }
//        setNeedsLayout()
//    }
//    
//    private func setupCenterIndicator() {
//        centerIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
//        centerIndicator.layer.cornerRadius = 1
//        addSubview(centerIndicator)
//    }
//    
//    private func setupTopEclipseView() {
//        topArcLayer.strokeColor = UIColor.otpGlow.withAlphaComponent(0.7).cgColor
//        topArcLayer.fillColor = UIColor.clear.cgColor
//        topArcLayer.lineWidth = 0.5
//        topEclipseView.layer.addSublayer(topArcLayer)
//        
//        topEclipseView.backgroundColor = UIColor.clear //UIColor(red: 32/255, green: 28/255, blue: 24/255, alpha: 1.0)
//        addSubview(topEclipseView)
//        sendSubviewToBack(topEclipseView)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        scrollView.frame = bounds
//        
//        let sideInset = bounds.width / 2
//        scrollView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
//        
//        var xPosition: CGFloat = 0
//        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
//        let radius: CGFloat = bounds.height
//        
//        for label in itemLabels {
//            label.bounds = CGRect(x: 0, y: 0, width: labelFixedWidth, height: labelHeight)
//            label.center = CGPoint(x: xPosition + labelFixedWidth / 2, y: radius * (1 - cos(0)) + 40)
//            
//            let deltaX = label.center.x - centerX
//            let angle = deltaX / radius
//            let clampedAngle = angle.clamped(to: -.pi/2 ... .pi/2)
//            let arcY = radius * (1 - cos(clampedAngle))
//            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)
//            
//            label.center = CGPoint(x: xPosition + labelFixedWidth / 2, y: arcY + 40)
//            label.transform = CGAffineTransform(scaleX: scale, y: scale)
//            label.alpha = scale
//            
//            xPosition += labelFixedWidth + labelSpacing
//        }
//        
//        scrollView.contentSize = CGSize(width: xPosition - labelSpacing, height: bounds.height)
//        
//        //        centerIndicator.frame = CGRect(x: bounds.midX - (labelFixedWidth + 10), y: 0, width: labelFixedWidth + 10, height: bounds.height)
//        
//        setupTopEclipseArc()
//        highlightCenterLabel()
//    }
//    
//    private func setupTopEclipseArc() {
//        let eclipseHeight: CGFloat = 150
//        let eclipseWidth = bounds.width
//        topEclipseView.frame = CGRect(x: 0, y: 0, width: eclipseWidth, height: eclipseHeight)
//        
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 0, y: 45))
//        path.addQuadCurve(to: CGPoint(x: eclipseWidth, y: 45),
//                          controlPoint: CGPoint(x: eclipseWidth / 2, y: -eclipseHeight / 2))
//        path.addLine(to: CGPoint(x: eclipseWidth, y: eclipseHeight))
//        path.addLine(to: CGPoint(x: 0, y: eclipseHeight))
//        path.close()
//        
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        topEclipseView.layer.mask = mask
//        
//        //--------------
//        let slayer = CAShapeLayer()
//        let center = CGPoint(x: (topEclipseView.bounds.width / 2), y: topEclipseView.bounds.height + 10)
//        let radius: CGFloat = topEclipseView.bounds.height
//        let startAngle: CGFloat = 4 * .pi / 4
//        let endAngle: CGFloat = 0.0
//        slayer.path = UIBezierPath(arcCenter: center,
//                                   radius: radius,
//                                   startAngle: startAngle,
//                                   endAngle: endAngle,
//                                   clockwise: true).cgPath
//        slayer.lineWidth = 150.0
//        slayer.lineCap = .round
//        slayer.strokeColor = UIColor(red: 0/255, green: 15/255, blue: 6/255, alpha: 1.0).cgColor //UIColor(red: 32/255, green: 28/255, blue: 24/255, alpha: 0.2).cgColor
//        //rgba(0, 5, 2, 1)
//        slayer.fillColor = UIColor.clear.cgColor
//        topEclipseView.layer.addSublayer(slayer)
//        
//        
//        //----------------- line paths
//        let arcPath = UIBezierPath()
//        arcPath.move(to: CGPoint(x: eclipseWidth * 0.25, y: 1))
//        arcPath.addQuadCurve(to: CGPoint(x: eclipseWidth * 0.75, y: 1),
//                             controlPoint: CGPoint(x: eclipseWidth / 2, y: -30))
//        topArcLayer.path = arcPath.cgPath
//        topEclipseView.layer.addSublayer(topArcLayer)
//        
//        //-------------------
//        //ic_dobCurve
//        
//        
//    }
//    
//    private func highlightCenterLabel() {
//        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
//        for (index, label) in itemLabels.enumerated() {
//            if abs(label.center.x - centerX) < (labelFixedWidth + labelSpacing) / 2 {
//                label.textColor = UIColor.appWhite
//                label.font = AppFont.bold.size(30, familyName: familyFunnelSans)
//                label.numberOfLines = 2
//                selectedIndex = index
//            } else {
//                label.textColor = UIColor.appDarkGray
//                label.font = AppFont.medium.size(22, familyName: familyFunnelSans)
//                label.numberOfLines = 2
//            }
//        }
//    }
//    
//    private func snapToNearest() {
//        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
//        var closestIndex = 0
//        var closestDistance = CGFloat.greatestFiniteMagnitude
//        
//        for (index, label) in itemLabels.enumerated() {
//            let distance = abs(label.center.x - centerX)
//            if distance < closestDistance {
//                closestDistance = distance
//                closestIndex = index
//            }
//        }
//        
//        let targetLabel = itemLabels[closestIndex]
//        let targetOffsetX = targetLabel.center.x - scrollView.bounds.width / 2
//        scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
//    }
//}
//
//extension WheelDobPicker: UIScrollViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        snapToNearest()
//    }
//    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            snapToNearest()
//        }
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        setNeedsLayout()
//    }
//    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        isScrolling = false
//    }
//}
//
//extension WheelDobPicker {
//    
//    // Method to forcefully scroll to the last item
//    func scrollToLastItem(animated: Bool = true) {
//        // Prevent continuous scrolling by checking if already scrolling
//        guard !isScrolling else { return }
//        isScrolling = true
//        // Ensure the values array is not empty
//        guard !values.isEmpty else { return }
//        // Calculate the position of the last label
//        let lastLabelIndex = values.count - 1
//        let lastLabel = itemLabels[lastLabelIndex]
//        // Calculate the target offset to scroll to the last label
//        let targetOffsetX = lastLabel.center.x - scrollView.bounds.width / 2
//        // Ensure the offset is within the content bounds
//        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
//        let clampedOffsetX = min(max(targetOffsetX, 0), maxOffsetX)
//        
//        self.scrollView.setContentOffset(CGPoint(x: clampedOffsetX, y: 0), animated: animated)
//        //        // Reset scrolling flag after animation completes
//        //           if !animated {
//        //               isScrolling = false
//        //           }
//        //
//    }
//}
//
//// MARK: - Helper Extension
//extension Comparable {
//    func clamped(to limits: ClosedRange<Self>) -> Self {
//        return min(max(self, limits.lowerBound), limits.upperBound)
//    }
//}
