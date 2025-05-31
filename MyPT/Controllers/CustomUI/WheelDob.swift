//
//  WheelDob.swift
//  MyPT
//
//  Created by techsaga corp on 25/04/25.
//

import UIKit

//MARK: -------------------- wheel DatePickerContainerView
protocol SelectedDateDelegate: AnyObject {
    func selectAge(age:String?)
    func selectDate(date:(year: String?, month: String?, day: String?)?)
}

class WheelDob: UIView {

    weak var delegate: SelectedDateDelegate?

    private let triangleLayer = CAShapeLayer()
    private let centerView = UIView() // The view you want to center
    private let ageLable = UILabel()

    private let yearPicker = WheelDobPicker()
    private let monthPicker = WheelDobPicker()
    private let dayPicker = WheelDobPicker()
    private var selectedYear : Int?
    private var selectedMonth : String?
    private var selectedDays : Int?
        
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickers()
        layoutPickers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPickers()
        layoutPickers()
        setupCenterView() // New: Setup the center view
        layoutCenterView() // New: Layout the center view
    }

    
    override func draw(_ rect: CGRect) {
            super.draw(rect)

        }
    
    private func setAttributeAgeLbl(age:Int?){
        let mainAttr = [
            .font: AppFont.semibold.size(20.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let ageAttr = [
            .font: AppFont.semibold.size(28.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attrParts: [AttributedStringComponent] = [
            NSAttributedString(string: "Your age is ", attributes: mainAttr),
            NSAttributedString(string: "\(age ?? 0)", attributes: ageAttr)
        ]
            self.ageLable.attributedText = NSAttributedString(from: attrParts, defaultAttributes: mainAttr)
        
    }

    private func setupCenterView() {

        // Add the triangle layer to the center view's layer
        centerView.layer.addSublayer(triangleLayer)
        centerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerView)
        ageLable.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(ageLable)
    }

    private func layoutCenterView() {
        
        NSLayoutConstraint.activate([
            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
            centerView.heightAnchor.constraint(equalToConstant: 100),
            centerView.topAnchor.constraint(equalTo: dayPicker.topAnchor, constant: 90.0),
            ageLable.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            ageLable.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: -10.0),
            ageLable.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.bringSubviewToFront(centerView)
        centerView.bringSubviewToFront(ageLable)
        centerView.backgroundColor = UIColor.clear
        updateTrianglePath() // Initial triangle drawing
    }

        private func updateTrianglePath() {
            let triangleHeight: CGFloat = 25
            let triangleWidth: CGFloat = 35
            let triangleX = centerView.bounds.midX
            let triangleY = CGFloat(3) // Top of the center view

            let trianglePath = UIBezierPath()
            trianglePath.move(to: CGPoint(x: triangleX, y: triangleY))
            trianglePath.addLine(to: CGPoint(x: triangleX - triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.addLine(to: CGPoint(x: triangleX + triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.close()

            triangleLayer.path = trianglePath.cgPath
            triangleLayer.fillColor = UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 27.0/255.0, alpha: 1.0).cgColor
        }


    override func layoutSubviews() {
        super.layoutSubviews()

        yearPicker.topArcShow = false
        setupCenterView() // New: Setup the center view
        layoutCenterView()
        updateTrianglePath()
    }

    private func setupPickers() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startYear = currentYear - 200
        let endYear = currentYear
        
        yearPicker.values = (startYear...endYear).map { "\($0)" }
        monthPicker.values = Calendar.current.shortMonthSymbols
        dayPicker.values = (1...31).map { "\($0)" }

        [yearPicker, monthPicker, dayPicker].forEach { picker in
           
            addSubview(picker)
        }
        
        yearPicker.addTarget(self, action: #selector(getYearChanged(_:)), for: .valueChanged)
        monthPicker.addTarget(self, action: #selector(getMonthChanged(_:)), for: .valueChanged)
        dayPicker.addTarget(self, action: #selector(getDaysChanged(_:)), for: .valueChanged)
        
        /*
            // Get the current date components
                let currentDate = Date()
                let calendar = Calendar.current
                let currentYear = calendar.component(.year, from: currentDate)
                let currentMonth = calendar.component(.month, from: currentDate)
                let currentDay = calendar.component(.day, from: currentDate)

                // Set the year, month, and day pickers
                let startYear = currentYear - 200
                let endYear = currentYear

                yearPicker.values = (startYear...endYear).map { "\($0)" }
                monthPicker.values = Calendar.current.shortMonthSymbols
                dayPicker.values = (1...31).map { "\($0)" }

            // Set the selected index for each picker
               yearPicker.selectedIndex = currentYear - startYear
               monthPicker.selectedIndex = currentMonth - 1 // Month is 1-indexed, but array is 0-indexed
               dayPicker.selectedIndex = currentDay - 1 // Day is 1-indexed, but array is 0-indexed

    //            // Set the initial values in the getcalendarDate
    //            getcalendarDate = (year: "\(currentYear)", month: Calendar.current.shortMonthSymbols[currentMonth - 1], day: "\(currentDay)")

                // Update pickers and label
                [yearPicker, monthPicker, dayPicker].forEach { picker in
                    addSubview(picker)
                }

                yearPicker.addTarget(self, action: #selector(getYearChanged(_:)), for: .valueChanged)
                monthPicker.addTarget(self, action: #selector(getMonthChanged(_:)), for: .valueChanged)
                dayPicker.addTarget(self, action: #selector(getDaysChanged(_:)), for: .valueChanged)
            */
            
        
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
            yearPicker.heightAnchor.constraint(equalToConstant: 450),
            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            monthPicker.topAnchor.constraint(equalTo: yearPicker.topAnchor, constant: 90.0),
            monthPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0),
            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: 90.0),
            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
        ])
    }

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
    private let labelSpacing: CGFloat = 5
    private let labelHeight: CGFloat = 50
    private let labelFixedWidth: CGFloat = 70
    private let centerIndicator = UIView()
    private let topEclipseView = UIView()
    private let topArcLayer = CAShapeLayer()
    
    var topArcShow: Bool = true {
        didSet{
            topArcLayer.isHidden = (topArcShow ? false : true)
        }
    }
    
    public var values: [String] = [] {
        didSet {
            setupItems()
            
            // Scroll to the last item after updating values
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
        topArcLayer.strokeColor = UIColor.appWhite.withAlphaComponent(0.7).cgColor
        topArcLayer.fillColor = UIColor.clear.cgColor
        topArcLayer.lineWidth = 0.2
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
        slayer.strokeColor = UIColor(red: 0/255, green: 5/255, blue: 2/255, alpha: 1.0).cgColor //UIColor(red: 32/255, green: 28/255, blue: 24/255, alpha: 0.2).cgColor
        //rgba(0, 5, 2, 1)
        slayer.fillColor = UIColor.clear.cgColor
        topEclipseView.layer.addSublayer(slayer)
        
        
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
                label.font = AppFont.semibold.size(25, familyName: familyManrope)
                label.numberOfLines = 2
                selectedIndex = index
            } else {
                label.textColor = UIColor.appDarkGray
                label.font = AppFont.regular.size(20, familyName: familyManrope)
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


//-------------------------_******************2222
/*
class WheelDob: UIView {

    weak var delegate: SelectedDateDelegate?

    private let triangleLayer = CAShapeLayer()
    private let centerView = UIView() // The view you want to center
    private let ageLable = UILabel()

    private let yearPicker = WheelDobPicker()
    private let monthPicker = WheelDobPicker()
    private let dayPicker = WheelDobPicker()
    private var selectedYear : Int?
    private var selectedMonth : String?
    private var selectedDays : Int?
        
    private var getcalendarDate: (year: String?, month: String?, day: String?) {
        didSet{
            let year:Int = Int(getcalendarDate.year ?? "") ?? 0
            let day: Int = Int(getcalendarDate.day ?? "") ?? 0
            let age =  calculateAge(birthYear: year, birthMonth: getMonthNumber(for: getcalendarDate.month ?? "") ?? 1, birthDay: day)
//            self.ageLable.text = "Your age is " + "\(age)"
//            self.ageLable.textColor = UIColor.white
            self.setAttributeAgeLbl(age: age)
            delegate?.selectAge(age: "\(age)")
            delegate?.selectDate(date: getcalendarDate)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickers()
        layoutPickers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPickers()
        layoutPickers()
        setupCenterView() // New: Setup the center view
        layoutCenterView() // New: Layout the center view
    }

    
    override func draw(_ rect: CGRect) {
            super.draw(rect)
//        if let topView = self.subviews.last { // subviews is an array, last object is on top
//            print("Top view is: \(topView)")
//            topView.backgroundColor = UIColor.clear
//
//            self.drawTriangle(atView: topView)
//        }

        }
    
    private func setAttributeAgeLbl(age:Int?){
//        self.ageLable.text = "Your age is " + "\(age ?? "")"
        
        let mainAttr = [
            .font: AppFont.semibold.size(20.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let ageAttr = [
            .font: AppFont.semibold.size(28.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attrParts: [AttributedStringComponent] = [
            NSAttributedString(string: "Your age is ", attributes: mainAttr),
            NSAttributedString(string: "\(age ?? 0)", attributes: ageAttr)
        ]
            self.ageLable.attributedText = NSAttributedString(from: attrParts, defaultAttributes: mainAttr)
        
    }

    private func setupCenterView() {

        // Add the triangle layer to the center view's layer
        centerView.layer.addSublayer(triangleLayer)
        centerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerView)

        ageLable.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(ageLable)

//        // Add the triangle layer to the center view's layer
//        centerView.layer.addSublayer(triangleLayer)


    }

    private func layoutCenterView() {
        
        NSLayoutConstraint.activate([
            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
            centerView.heightAnchor.constraint(equalToConstant: 100),
//            centerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            centerView.topAnchor.constraint(equalTo: dayPicker.topAnchor, constant: 90.0),
            ageLable.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
//          ageLable.centerYAnchor.constraint(equalTo: centerView.centerYAnchor, constant: 30.0),
//          ageLable.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 50),
            ageLable.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: -10.0),
            ageLable.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.bringSubviewToFront(centerView)
        centerView.bringSubviewToFront(ageLable)
        centerView.backgroundColor = UIColor.clear
        updateTrianglePath() // Initial triangle drawing
    }

        private func updateTrianglePath() {
            let triangleHeight: CGFloat = 30
            let triangleWidth: CGFloat = 35
            let triangleX = centerView.bounds.midX
            let triangleY = CGFloat(-5) // Top of the center view

            let trianglePath = UIBezierPath()
            trianglePath.move(to: CGPoint(x: triangleX, y: triangleY))
            trianglePath.addLine(to: CGPoint(x: triangleX - triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.addLine(to: CGPoint(x: triangleX + triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.close()

            triangleLayer.path = trianglePath.cgPath
            triangleLayer.fillColor = UIColor(red: 243.0/255.0, green: 141.0/255.0, blue: 27.0/255.0, alpha: 1.0).cgColor
        }


    override func layoutSubviews() {
        super.layoutSubviews()

//        [yearPicker, monthPicker, dayPicker].forEach({
//            $0.roundSideCorners(radius: self.frame.height/3.2, cornerSide: [.topLeft, .topRight])
//        })

        yearPicker.topArcShow = false
        setupCenterView() // New: Setup the center view
        layoutCenterView()
        updateTrianglePath()

//        ageLable.textColor = UIColor.white
//        ageLable.text = "Your age is " + "24"

        //------------getting top view

//        if let topView = self.subviews.last { // subviews is an array, last object is on top
//            print("Top view is: \(topView)")
////            topView.backgroundColor = UIColor.clear
//
//            self.drawTriangle(atView: topView)
//        }

//        if let topLayer = self.layer.sublayers?.last { // subviews is an array, last object is on top
//            print("Top topLayer is: \(topLayer)")
//            topLayer.backgroundColor = UIColor.green.cgColor
//        }
    }

    private func setupPickers() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startYear = currentYear - 200
        let endYear = currentYear
        
        yearPicker.values = (startYear...endYear).map { "\($0)" }
        monthPicker.values = Calendar.current.shortMonthSymbols
        dayPicker.values = (1...31).map { "\($0)" }
        
//        yearPicker.pickerType = .year
//        monthPicker.pickerType = .month
//        dayPicker.pickerType = .day

        // Apply the same theme to all pickers
//        let theme = PickerTheme(
//            backgroundColor: UIColor.clear,
//            textColor: .lightGray,
//            selectedTextColor: .white,
//            centerLabelColor: .clear,
//            gradientColors: [UIColor.gray.withAlphaComponent(0.4), .white, UIColor.gray.withAlphaComponent(0.4)],
//            curveStrokeColor: .red
//        )

        [yearPicker, monthPicker, dayPicker].forEach { picker in
//            picker.theme = theme
//            if picker == yearPicker{
//                yearPicker.theme.gradientColors = [UIColor.clear, UIColor.clear, UIColor.clear]
//            }

//            if picker == dayPicker || picker == monthPicker {
//                dayPicker.theme.backgroundColor = UIColor.clear
//                monthPicker.theme.backgroundColor = UIColor.clear
//            }

//            picker.addTarget(self, action: #selector(pickerValueChanged(_:)), for: .valueChanged)
            addSubview(picker)
        }
        
        yearPicker.addTarget(self, action: #selector(getYearChanged(_:)), for: .valueChanged)
        monthPicker.addTarget(self, action: #selector(getMonthChanged(_:)), for: .valueChanged)
        dayPicker.addTarget(self, action: #selector(getDaysChanged(_:)), for: .valueChanged)
        
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
            yearPicker.heightAnchor.constraint(equalToConstant: 500),
//            yearPicker.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0),
//            yearPicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0),

            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            monthPicker.topAnchor.constraint(equalTo: yearPicker.topAnchor, constant: 90.0),
//            monthPicker.heightAnchor.constraint(equalTo: yearPicker.heightAnchor, multiplier: 0.75),
            monthPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0),

            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: 90.0),
//            dayPicker.heightAnchor.constraint(equalTo: monthPicker.heightAnchor, multiplier: 0.85),
            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
        ])
        
    }

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

class WheelDobPicker: UIControl {
    
    private let scrollView = UIScrollView()
    private var itemLabels: [UILabel] = []
    
    private let labelSpacing: CGFloat = 10
    private let labelHeight: CGFloat = 50
    private let labelFixedWidth: CGFloat = 80
    
    private let centerIndicator = UIView()
    private let topEclipseView = UIView()
    private let topArcLayer = CAShapeLayer()
    
    var topArcShow: Bool = true {
        didSet{
            topArcLayer.isHidden = (topArcShow ? false : true)
        }
    }
    
    
    public var values: [String] = [] {
        didSet {
            setupItems()
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
        scrollView.decelerationRate = .fast
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
        topArcLayer.strokeColor = UIColor.appWhite.cgColor
        topArcLayer.fillColor = UIColor.clear.cgColor
        topArcLayer.lineWidth = 0.6
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
         slayer.lineWidth = 130.0
        slayer.lineCap = .round
        slayer.strokeColor = UIColor(red: 32/255, green: 28/255, blue: 24/255, alpha: 1.0).cgColor
        slayer.fillColor = UIColor.clear.cgColor
        topEclipseView.layer.addSublayer(slayer)
        
        
        //----------------- line paths

        let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: eclipseWidth * 0.25, y: 1))
        arcPath.addQuadCurve(to: CGPoint(x: eclipseWidth * 0.75, y: 1),
                             controlPoint: CGPoint(x: eclipseWidth / 2, y: -30))
        
//        arcPath.move(to: CGPoint(x: eclipseWidth * 0.25, y: 10))
//        arcPath.addQuadCurve(to: CGPoint(x: eclipseWidth * 0.75, y: 10),
//                             controlPoint: CGPoint(x: eclipseWidth / 2, y: -20))
        topArcLayer.path = arcPath.cgPath
        topEclipseView.layer.addSublayer(topArcLayer)
        
        //-------------------
        
    }
    
    private func highlightCenterLabel() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        for (index, label) in itemLabels.enumerated() {
            if abs(label.center.x - centerX) < (labelFixedWidth + labelSpacing) / 2 {
                label.textColor = UIColor.appWhite
                label.font = AppFont.semibold.size(30, familyName: familyManrope)
                label.numberOfLines = 2
                selectedIndex = index
            } else {
                label.textColor = UIColor.appDarkGray
                label.font = AppFont.regular.size(22, familyName: familyManrope)
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
}
*/

//--------------------*****************


/*
class WheelDobPicker: UIControl {
    
    private let scrollView = UIScrollView()
    private var itemLabels: [UILabel] = []
    private var labelWidths: [CGFloat] = []
    
    private let labelSpacing: CGFloat = 25
    private let labelHeight: CGFloat = 40
    
    private let centerIndicator = UIView()
    private let topEclipseView = UIView()
    private let topArcLayer = CAShapeLayer()
    
    public var values: [String] = [] {
        didSet {
            setupItems()
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
        setupCenterIndicator()
        setupTopEclipseView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupCenterIndicator()
        setupTopEclipseView()
    }
    
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.delegate = self
        addSubview(scrollView)
    }
    
    private func setupItems() {
        itemLabels.forEach { $0.removeFromSuperview() }
        itemLabels.removeAll()
        labelWidths.removeAll()
        
        for value in values {
            let label = UILabel()
            label.text = value
            label.font = .systemFont(ofSize: 18)
            label.textAlignment = .center
            label.textColor = .darkGray
            let width = (value as NSString).size(withAttributes: [.font: label.font ?? 18]).width + 20 // Add some padding
            labelWidths.append(width)
            scrollView.addSubview(label)
            itemLabels.append(label)
        }
        
        setNeedsLayout()
    }
    
    private func setupCenterIndicator() {
        centerIndicator.backgroundColor = UIColor.clear.withAlphaComponent(0.2)
        centerIndicator.layer.cornerRadius = 1
        addSubview(centerIndicator)
    }
    
    private func setupTopEclipseView() {
        topArcLayer.strokeColor = UIColor.systemBlue.cgColor
        topArcLayer.fillColor = UIColor.clear.cgColor
        topArcLayer.lineWidth = 1.0
        topEclipseView.layer.addSublayer(topArcLayer)
        
        topEclipseView.backgroundColor = UIColor(red: 32/255, green: 28/255, blue: 24/255, alpha: 1.0)
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
        
        for (index, label) in itemLabels.enumerated() {
            let width = labelWidths[index]
            label.bounds = CGRect(x: 0, y: 0, width: width, height: labelHeight)
            label.center = CGPoint(x: xPosition + width / 2, y: radius * (1 - cos(0)) + 40)
            
            let deltaX = label.center.x - centerX
            let angle = deltaX / radius
            let clampedAngle = angle.clamped(to: -.pi/2 ... .pi/2)
            let arcY = radius * (1 - cos(clampedAngle))
            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)
            
            label.center = CGPoint(x: xPosition + width / 2, y: arcY + 40)
            label.transform = CGAffineTransform(scaleX: scale, y: scale)
            label.alpha = scale
            
            xPosition += width + labelSpacing
        }
        
        scrollView.contentSize = CGSize(width: xPosition - labelSpacing, height: bounds.height)
        
        centerIndicator.frame = CGRect(x: bounds.midX - 1, y: 0, width: 2, height: bounds.height)
        
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
        
        // Optional: draw a top arc stroke
        let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: eclipseWidth * 0.25, y: 10))
        arcPath.addQuadCurve(to: CGPoint(x: eclipseWidth * 0.75, y: 10),
                             controlPoint: CGPoint(x: eclipseWidth / 2, y: -20))
        topArcLayer.path = arcPath.cgPath
    }
    
    private func highlightCenterLabel() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        for (index, label) in itemLabels.enumerated() {
            if abs(label.center.x - centerX) < (labelWidths[index] + labelSpacing) / 2 {
                label.textColor = .white
                label.font = UIFont.boldSystemFont(ofSize: 30)
                selectedIndex = index
            } else {
                label.textColor = .darkGray
                label.font = UIFont.systemFont(ofSize: 22)
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
}
*/





/*
//------------------28 apr
class WheelDobPicker: UIControl {
    private let scrollView = UIScrollView()
    private var itemLabels: [UILabel] = []
    private let labelSpacing: CGFloat = 25
    private let labelHeight: CGFloat = 40
    private let labelWidth: CGFloat = 80
    private let centerIndicator = UIView()
    
    private let topEclipseView = UIView()
    private let topArcLayer = CAShapeLayer()
    
    public var values: [String] = [] {
        didSet {
            setupItems()
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
        setupCenterIndicator()
        setupTopEclipseView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCenterIndicator()
        setupScrollView()
//        setupCenterIndicator()
        setupTopEclipseView()
    }
    
    private func setupTopEclipseView() {
      
        topArcLayer.strokeColor = UIColor.systemBlue.cgColor // or your desired color
        topArcLayer.fillColor = UIColor.clear.cgColor
        topArcLayer.lineWidth = 1.0
        topEclipseView.layer.addSublayer(topArcLayer)
        
        topEclipseView.backgroundColor = UIColor(red: 32.0/255.0, green: 28.0/255.0, blue: 24.0/255.0, alpha: 1.0) // or any custom color
        addSubview(topEclipseView)
        sendSubviewToBack(topEclipseView) // Optional: put behind content
        
    }
    
//    private func applyTopEclipseMask() {
//        let path = UIBezierPath()
//        let width = bounds.width
//        let height = bounds.height
//
//        // Start at bottom left
//        path.move(to: CGPoint(x: 0, y: height))
//
//        // Line to top left
//        path.addLine(to: CGPoint(x: 0, y: 60))
//
//        // Add a curved top (elliptical shape)
//        path.addQuadCurve(to: CGPoint(x: width, y: 60),
//                          controlPoint: CGPoint(x: width / 2, y: -40))
//
//        // Line to bottom right
//        path.addLine(to: CGPoint(x: width, y: height))
//
//        // Close path
//        path.close()
//        
//
//        // Apply shape as mask
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        layer.mask = mask
//    }


    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
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
        centerIndicator.backgroundColor = UIColor.clear.withAlphaComponent(0.2)
        centerIndicator.layer.cornerRadius = 8
//        addSubview(centerIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame = bounds

        let fullLabelWidth = labelWidth + labelSpacing

        // ✅ Left inset = center position for first item
        // ✅ Right inset = center position for last item
        let sideInset = bounds.width / 2 - labelWidth / 2
        scrollView.contentInset = UIEdgeInsets(top: 0, left: sideInset + 20, bottom: 0, right: sideInset - 10)

        scrollView.contentSize = CGSize(width: CGFloat(values.count) * fullLabelWidth, height: bounds.height)

        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let radius: CGFloat = bounds.height

        for (index, label) in itemLabels.enumerated() {
            let x = CGFloat(index) * fullLabelWidth //+ 10
            let deltaX = x - centerX
            let angle = deltaX / radius
            let clampedAngle = angle.clamped(to: -.pi / 2 ... .pi / 2)
            let arcY = radius * (1 - cos(clampedAngle))
            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)

            label.bounds = CGRect(x: 0, y: 0, width: labelWidth, height: 40)
            label.center = CGPoint(x: x, y: arcY + 40)
            label.transform = CGAffineTransform(scaleX: scale, y: scale)
            label.alpha = scale
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear
        }

        centerIndicator.frame = CGRect(x: bounds.midX - labelWidth / 2, y: 0, width: labelWidth, height: bounds.height)
        highlightCenterLabel()
        
//        applyTopEclipseMask()
        //-------------------
        
        // Setup top eclipse arc
           let eclipseHeight: CGFloat = 150
           let eclipseWidth = bounds.width
           topEclipseView.frame = CGRect(x: 0, y: 0, width: eclipseWidth, height: eclipseHeight)

           // Add ellipse arc shape
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
               
        
        let arcWidth = eclipseWidth/2.0 //bounds.width/2.0
//         let arcHeight: CGFloat = 40 //100 // How high the arc goes
        
         let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: arcWidth/2.0, y: 10))
        arcPath.addQuadCurve(to: CGPoint(x: bounds.width * 0.75, y: 10),
                             controlPoint: CGPoint(x: eclipseWidth / 2, y: -20))
        arcPath.addQuadCurve(to: CGPoint(x: bounds.width * 0.75, y: 10),
                             controlPoint:  CGPoint(x: eclipseWidth / 2, y: -20))

         topArcLayer.path = arcPath.cgPath
        
        
        /*
//        // Draw arc line at top
        let arcWidth = eclipseWidth/2.0 //bounds.width/2.0
         let arcHeight: CGFloat = 40 //100 // How high the arc goes
        
         let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: arcWidth/2.0, y: arcHeight - 20))
        arcPath.addQuadCurve(to: CGPoint(x: bounds.width * 0.75, y: arcHeight - 20),
                             controlPoint: CGPoint(x: arcWidth , y: -(arcHeight - 20) / 1.4))
        arcPath.addQuadCurve(to: CGPoint(x: bounds.width * 0.75, y: arcHeight - 20),
                             controlPoint: CGPoint(x: arcWidth , y: -(arcHeight - 20) / 1.4))

         topArcLayer.path = arcPath.cgPath
        
        */
        
        
        //        let arcPath = UIBezierPath()
        //       arcPath.move(to: CGPoint(x: arcWidth/2.0, y: arcHeight))
        //       arcPath.addQuadCurve(to: CGPoint(x: eclipseWidth, y: 45),
        //                            controlPoint: CGPoint(x: eclipseWidth / 2, y: -eclipseHeight / 2))
        //        arcPath.addLine(to: CGPoint(x: eclipseWidth, y: eclipseHeight))
        //        arcPath.addLine(to: CGPoint(x: 0, y: eclipseHeight))
    }


    private func highlightCenterLabel() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        for (index, label) in itemLabels.enumerated() {
            if abs(label.center.x - centerX) < (labelWidth + labelSpacing) / 2 {
                label.textColor = UIColor.appWhite
                label.font = AppFont.semibold.size(30, familyName: familyManrope) //.boldSystemFont(ofSize: 20)
                selectedIndex = index
            } else {
                label.textColor = UIColor.appDarkGray
                label.font = AppFont.regular.size(22, familyName: familyManrope) //.systemFont(ofSize: 18)
            }
        }
    }

    private func snapToNearest() {
        let fullLabelWidth = labelWidth + labelSpacing
        let index = Int(round(scrollView.contentOffset.x / fullLabelWidth))
        let offsetX = CGFloat(index) * fullLabelWidth
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
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
}

//// Clamp extension
private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

//----------------------********
 */


////----------------------_it's working fine
//class WheelDobYearPicker: UIControl {
//    private let scrollView = UIScrollView()
//    private var yearLabels: [UILabel] = []
//    private let labelSpacing: CGFloat = 25 //30
//    private let labelHeight: CGFloat = 40
//    private var totalYears: Int = 250
//    
//    private let labelWidth: CGFloat = 60
//    private let centerIndicator = UIView()
//    private let currentYear = Calendar.current.component(.year, from: Date())
//
//    public var selectedYear: Int = Calendar.current.component(.year, from: Date()) {
//        didSet {
//            sendActions(for: .valueChanged)
//        }
//    }
//    
//    public var month:Int = 12 {
//        didSet{
//            totalYears = 12
//        }
//    }
//    
//    public var days:Int = 30 {
//        didSet{
//            totalYears = 12
//        }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupScrollView()
//        setupYears()
//        setupCenterIndicator()
//        scrollToYear(selectedYear, animated: false)
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupScrollView()
//        setupYears()
//        setupCenterIndicator()
//        scrollToYear(selectedYear, animated: false)
//    }
//
//    private func setupScrollView() {
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.decelerationRate = .fast
//        scrollView.delegate = self
//        scrollView.alwaysBounceHorizontal = true
//        scrollView.alwaysBounceVertical = false
//        scrollView.backgroundColor = UIColor.clear
//        addSubview(scrollView)
//    }
//
//    private func setupYears() {
//        for year in (currentYear - totalYears + 3)...currentYear {
//            let label = UILabel()
//            label.text = "\(year)"
//            label.font = .systemFont(ofSize: 18)
//            label.textAlignment = .center
//            label.textColor = .darkGray
//            label.backgroundColor = .clear
//            scrollView.addSubview(label)
//            yearLabels.append(label)
//        }
//    }
//
//    private func setupCenterIndicator() {
//        centerIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.2) //.systemBlue.withAlphaComponent(0.2)
//        centerIndicator.layer.cornerRadius = 8
//        addSubview(centerIndicator)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        scrollView.frame = bounds
//
//        let fullLabelWidth = labelWidth + labelSpacing
//        scrollView.contentSize = CGSize(width: CGFloat(totalYears) * fullLabelWidth, height: bounds.height)
//
//        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
//        let radius: CGFloat = bounds.height // controls curve depth
//
//        for (index, label) in yearLabels.enumerated() {
//            let x = (CGFloat(index) * fullLabelWidth) + 10
//            let deltaX = x - centerX
//            let angle = deltaX / radius
//
//            // Limit angle range for natural curve (avoids flipping)
//            let clampedAngle = angle.clamped(to: -.pi / 2 ... .pi / 2)
//
//            // Curved vertical position
//            let arcY = radius * (1 - cos(clampedAngle))
//            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)
//            
//            label.bounds = CGRect(x: 0, y: 0, width: labelWidth, height: 40)
//            label.center = CGPoint(x: x, y: arcY + 40) // arcY goes up as you scroll left/right
//            label.transform = CGAffineTransform(scaleX: scale, y: scale)
//            label.alpha = scale
//            label.textAlignment = .center
//            label.backgroundColor = UIColor.clear
//        }
//        
//
//        centerIndicator.frame = CGRect(x: bounds.midX - labelWidth / 2, y: 0, width: labelWidth, height: bounds.height)
//        highlightCenterLabel()
//    }
//    
//    /* curve view is good working
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        scrollView.frame = bounds
//
//        let fullLabelWidth = labelWidth + labelSpacing
//        scrollView.contentSize = CGSize(width: CGFloat(totalYears) * fullLabelWidth, height: bounds.height)
//
//        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
//        let radius: CGFloat = bounds.height // controls curve depth
//
//        for (index, label) in yearLabels.enumerated() {
//            let x = CGFloat(index) * fullLabelWidth
//            let deltaX = x - centerX
//            let angle = deltaX / radius
//
//            // Limit angle range for natural curve (avoids flipping)
////            let clampedAngle = angle.clamped(to: -.pi / 2 ... .pi / 2)
//            let clampedAngle = angle.clamped(to: -.pi / 2 ... .pi / 2)
//
//            // Curved vertical position
//            let arcY = radius * (1 - cos(clampedAngle))
//            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)
//
//            label.bounds = CGRect(x: 0, y: 0, width: labelWidth, height: 40)
//            label.center = CGPoint(x: x, y: bounds.midY + arcY) // arcY goes up as you scroll left/right
//            label.transform = CGAffineTransform(scaleX: scale, y: scale)
//            label.alpha = scale
//        }
//
//        centerIndicator.frame = CGRect(x: bounds.midX - labelWidth / 2, y: 0, width: labelWidth, height: bounds.height)
//        highlightCenterLabel()
//    }
//    */
//    
//    private func scrollToYear(_ year: Int, animated: Bool) {
//        let startYear = currentYear - totalYears + 1
//        let targetIndex = year - startYear
//        let fullLabelWidth = labelWidth + labelSpacing
//        let offsetX = CGFloat(targetIndex) * fullLabelWidth - bounds.width / 2 + labelWidth / 2
//        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
//    }
//
//    private func snapToNearestYear() {
//        let fullLabelWidth = labelWidth + labelSpacing
//        let index = Int(round(scrollView.contentOffset.x / fullLabelWidth))
//        let offsetX = CGFloat(index) * fullLabelWidth
//        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
//    }
//        
//    private func highlightCenterLabel() {
//        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
//        for label in yearLabels {
//            if abs(label.center.x - centerX) < (labelWidth + labelSpacing) / 2 {
//                label.textColor = .systemBlue
//                label.font = .boldSystemFont(ofSize: 20)
//                label.textAlignment = .center
//                selectedYear = Int(label.text ?? "") ?? selectedYear
//            } else {
//                label.textColor = .darkGray
//                label.font = .systemFont(ofSize: 18)
//            }
//        }
//    }
//
////    private func snapToNearestYear() {
////        let fullLabelHeight = labelHeight + labelSpacing
////        let index = Int(round(scrollView.contentOffset.y / fullLabelHeight))
////        let offsetY = CGFloat(index) * fullLabelHeight
////        scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
////    }
//}
//
//extension WheelDobYearPicker: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        setNeedsLayout()
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        snapToNearestYear()
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            snapToNearestYear()
//        }
//    }
//}
//


