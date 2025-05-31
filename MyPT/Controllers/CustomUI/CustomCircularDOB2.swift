//
//  CustomCircularDOB2.swift
//  MyPT
//
//  Created by techsaga corp on 05/02/25.
//

import UIKit


class DatePickerContainerView2: UIView {

    weak var delegate: DatePickerContainerDelegate?

    private let triangleLayer = CAShapeLayer()
    private let centerView = UIView() // The view you want to center
    private let ageLable = UILabel()

    private let yearPicker = ScrollableYearPicker()
    private let monthPicker = ScrollableYearPicker()
    private let dayPicker = ScrollableYearPicker()
    
//    public var selectedDate: (year: String?, month: String?, day: String?) {
//        return (yearPicker.selectedValue, monthPicker.selectedValue, dayPicker.selectedValue)
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickers()
        layoutPickers()
        monthPicker.month = 15
        dayPicker.days = 25
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

    private func setupCenterView() {

        centerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerView)

        ageLable.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(ageLable)

        // Add the triangle layer to the center view's layer
        centerView.layer.addSublayer(triangleLayer)


    }


    private func layoutCenterView() {

            NSLayoutConstraint.activate([
                centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                centerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
                centerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.48),
                centerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0),
                ageLable.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
                ageLable.centerYAnchor.constraint(equalTo: centerView.centerYAnchor, constant: 1.0),
                ageLable.heightAnchor.constraint(equalToConstant: 50)
            ])

            self.bringSubviewToFront(centerView)
//        centerView.bringSubviewToFront(ageLable)
            centerView.backgroundColor = UIColor.black
            updateTrianglePath() // Initial triangle drawing
        }

        private func updateTrianglePath() {
            let triangleHeight: CGFloat = 20
            let triangleWidth: CGFloat = 24
            let triangleX = centerView.bounds.midX
            let triangleY = CGFloat(-5) // Top of the center view

            let trianglePath = UIBezierPath()
            trianglePath.move(to: CGPoint(x: triangleX, y: triangleY))
            trianglePath.addLine(to: CGPoint(x: triangleX - triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.addLine(to: CGPoint(x: triangleX + triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.close()

            triangleLayer.path = trianglePath.cgPath
            triangleLayer.fillColor = UIColor.orange.cgColor
        }


    override func layoutSubviews() {
        super.layoutSubviews()

//        [yearPicker, monthPicker, dayPicker].forEach({
//            $0.roundSideCorners(radius: self.frame.height/3.2, cornerSide: [.topLeft, .topRight])
//        })

        setupCenterView() // New: Setup the center view
        layoutCenterView()
        updateTrianglePath()

        ageLable.textColor = UIColor.white
//        ageLable.text = "Your age is "

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
        
    }

    private func layoutPickers() {
        // Use Auto Layout for flexibility

        [yearPicker, monthPicker, dayPicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            yearPicker.topAnchor.constraint(equalTo: topAnchor),
            yearPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            yearPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            yearPicker.heightAnchor.constraint(equalToConstant: 400),
//            yearPicker.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0),
//            yearPicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0),

            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            monthPicker.topAnchor.constraint(equalTo: yearPicker.topAnchor, constant: 70.0),
//            monthPicker.heightAnchor.constraint(equalTo: yearPicker.heightAnchor, multiplier: 0.75),
            monthPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0),

            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: 70.0),
//            dayPicker.heightAnchor.constraint(equalTo: monthPicker.heightAnchor, multiplier: 0.85),
            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
        ])
    }

//    @objc private func pickerValueChanged(_ picker: CustomCircularDOB2) {
//        print("Selected Date: \(selectedDate)")
//
//        if let getYears = Int(selectedDate.year ?? "") , let getMonths = selectedDate.month ,let getDays = Int(selectedDate.day ?? ""){
//
//            let age = calculateAge(birthYear: getYears, birthMonth: getMonthNumber(for: getMonths) ?? 1, birthDay: getDays)
//            ageLable.text = "Your age is " + "\(age)"
//            self.delegate?.selectAge(age: "\(age)")
//            self.delegate?.selectDate(date: selectedDate)
//        }
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


//----------------------_it's working fine
class ScrollableYearPicker: UIControl {
    
    private let scrollView = UIScrollView()
    private var yearLabels: [UILabel] = []
    private let labelSpacing: CGFloat = 25 //30
    private let labelHeight: CGFloat = 40
    private var totalYears: Int = 250
    
    private let labelWidth: CGFloat = 60
    private let centerIndicator = UIView()
    private let currentYear = Calendar.current.component(.year, from: Date())

    public var selectedYear: Int = Calendar.current.component(.year, from: Date()) {
        didSet {
            sendActions(for: .valueChanged)
        }
    }
    
    public var month:Int = 12 {
        didSet{
            totalYears = 12
        }
    }
    
    public var days:Int = 30 {
        didSet{
            totalYears = 12
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupYears()
        setupCenterIndicator()
        scrollToYear(selectedYear, animated: false)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupYears()
        setupCenterIndicator()
        scrollToYear(selectedYear, animated: false)
    }

    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.delegate = self
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.backgroundColor = UIColor.clear
        addSubview(scrollView)
    }

    private func setupYears() {
        for year in (currentYear - totalYears + 3)...currentYear {
            let label = UILabel()
            label.text = "\(year)"
            label.font = .systemFont(ofSize: 18)
            label.textAlignment = .center
            label.textColor = .darkGray
            label.backgroundColor = .clear
            scrollView.addSubview(label)
            yearLabels.append(label)
        }
    }

    private func setupCenterIndicator() {
        centerIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.2) //.systemBlue.withAlphaComponent(0.2)
        centerIndicator.layer.cornerRadius = 8
        addSubview(centerIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame = bounds

        let fullLabelWidth = labelWidth + labelSpacing
        scrollView.contentSize = CGSize(width: CGFloat(totalYears) * fullLabelWidth, height: bounds.height)

        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let radius: CGFloat = bounds.height // controls curve depth

        for (index, label) in yearLabels.enumerated() {
            let x = (CGFloat(index) * fullLabelWidth) + 10
            let deltaX = x - centerX
            let angle = deltaX / radius

            // Limit angle range for natural curve (avoids flipping)
            let clampedAngle = angle.clamped(to: -.pi / 2 ... .pi / 2)

            // Curved vertical position
            let arcY = radius * (1 - cos(clampedAngle))
            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)
            
            label.bounds = CGRect(x: 0, y: 0, width: labelWidth, height: 40)
            label.center = CGPoint(x: x, y: arcY + 40) // arcY goes up as you scroll left/right
            label.transform = CGAffineTransform(scaleX: scale, y: scale)
            label.alpha = scale
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear
        }
        

        centerIndicator.frame = CGRect(x: bounds.midX - labelWidth / 2, y: 0, width: labelWidth, height: bounds.height)
        highlightCenterLabel()
    }
    
    /* curve view is good working
    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.frame = bounds

        let fullLabelWidth = labelWidth + labelSpacing
        scrollView.contentSize = CGSize(width: CGFloat(totalYears) * fullLabelWidth, height: bounds.height)

        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let radius: CGFloat = bounds.height // controls curve depth

        for (index, label) in yearLabels.enumerated() {
            let x = CGFloat(index) * fullLabelWidth
            let deltaX = x - centerX
            let angle = deltaX / radius

            // Limit angle range for natural curve (avoids flipping)
//            let clampedAngle = angle.clamped(to: -.pi / 2 ... .pi / 2)
            let clampedAngle = angle.clamped(to: -.pi / 2 ... .pi / 2)

            // Curved vertical position
            let arcY = radius * (1 - cos(clampedAngle))
            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)

            label.bounds = CGRect(x: 0, y: 0, width: labelWidth, height: 40)
            label.center = CGPoint(x: x, y: bounds.midY + arcY) // arcY goes up as you scroll left/right
            label.transform = CGAffineTransform(scaleX: scale, y: scale)
            label.alpha = scale
        }

        centerIndicator.frame = CGRect(x: bounds.midX - labelWidth / 2, y: 0, width: labelWidth, height: bounds.height)
        highlightCenterLabel()
    }
    */
    
    private func scrollToYear(_ year: Int, animated: Bool) {
        let startYear = currentYear - totalYears + 1
        let targetIndex = year - startYear
        let fullLabelWidth = labelWidth + labelSpacing
        let offsetX = CGFloat(targetIndex) * fullLabelWidth - bounds.width / 2 + labelWidth / 2
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }

    private func snapToNearestYear() {
        let fullLabelWidth = labelWidth + labelSpacing
        let index = Int(round(scrollView.contentOffset.x / fullLabelWidth))
        let offsetX = CGFloat(index) * fullLabelWidth
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
        
    private func highlightCenterLabel() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        for label in yearLabels {
            if abs(label.center.x - centerX) < (labelWidth + labelSpacing) / 2 {
                label.textColor = .systemBlue
                label.font = .boldSystemFont(ofSize: 20)
                label.textAlignment = .center
                selectedYear = Int(label.text ?? "") ?? selectedYear
            } else {
                label.textColor = .darkGray
                label.font = .systemFont(ofSize: 18)
            }
        }
    }

//    private func snapToNearestYear() {
//        let fullLabelHeight = labelHeight + labelSpacing
//        let index = Int(round(scrollView.contentOffset.y / fullLabelHeight))
//        let offsetY = CGFloat(index) * fullLabelHeight
//        scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
//    }
}

extension ScrollableYearPicker: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestYear()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearestYear()
        }
    }
}

//------------------------------

/*  it's working fine but swipe issue lft to right
class ScrollableYearPicker: UIControl {

    private let scrollView = UIScrollView()
    private var yearLabels: [UILabel] = []
    private let labelSpacing: CGFloat = 40 //15
    private let labelHeight: CGFloat = 40
    private let totalYears: Int = 250
    private let centerIndicator = UIView()
    private let currentYear = Calendar.current.component(.year, from: Date())

    public var selectedYear: Int = Calendar.current.component(.year, from: Date()) {
        didSet {
            sendActions(for: .valueChanged)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupYears()
        setupCenterIndicator()
        scrollToYear(selectedYear, animated: false)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupYears()
        setupCenterIndicator()
        scrollToYear(selectedYear, animated: false)
    }

    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.delegate = self
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        addSubview(scrollView)
    }

    private func setupYears() {
        for year in (currentYear - totalYears + 1)...currentYear {
            let label = UILabel()
            label.text = "\(year)"
            label.font = .systemFont(ofSize: 18)
            label.textAlignment = .center
            label.textColor = .darkGray
            label.backgroundColor = .clear
            scrollView.addSubview(label)
            yearLabels.append(label)
        }
    }

    private func setupCenterIndicator() {
        centerIndicator.backgroundColor = UIColor.clear //.systemBlue.withAlphaComponent(0.2)
        centerIndicator.layer.cornerRadius = 8
        addSubview(centerIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.height > 0 else { return }

        scrollView.frame = bounds

        let fullLabelHeight = labelHeight + labelSpacing
        scrollView.contentSize = CGSize(width: bounds.width, height: CGFloat(totalYears) * fullLabelHeight)

        let centerY = scrollView.contentOffset.y + scrollView.bounds.height / 2
        let radius: CGFloat = bounds.height * 0.9

        for (index, label) in yearLabels.enumerated() {
            let y = CGFloat(index) * fullLabelHeight
            let deltaY = y - centerY
            let angle = deltaY / radius
            let clampedAngle = angle.clamped(to: -.pi/2 ... .pi/2)

            let arcX = radius * sin(clampedAngle)
            let arcY = centerY + radius * (1 - cos(clampedAngle))

            label.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: labelHeight)
            label.center = CGPoint(x: bounds.midX + arcX, y: arcY)
            label.transform = CGAffineTransform(rotationAngle: clampedAngle)

            let scale = cos(clampedAngle).clamped(to: 0.6...1.0)
            label.alpha = scale
        }

        centerIndicator.frame = CGRect(x: 0, y: bounds.midY - labelHeight / 2, width: bounds.width, height: labelHeight)
        highlightCenterLabel()
    }

    private func scrollToYear(_ year: Int, animated: Bool) {
        let startYear = currentYear - totalYears + 1
        let targetIndex = year - startYear
        let fullLabelHeight = labelHeight + labelSpacing
        let offsetY = CGFloat(targetIndex) * fullLabelHeight - bounds.height / 2 + labelHeight / 2
        scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: animated)
    }

    private func highlightCenterLabel() {
        let centerY = scrollView.contentOffset.y + scrollView.bounds.height / 2
        for label in yearLabels {
            if abs(label.center.y - centerY) < (labelHeight + labelSpacing) / 2 {
                label.textColor = .systemBlue
                label.font = .boldSystemFont(ofSize: 20)
                selectedYear = Int(label.text ?? "") ?? selectedYear
            } else {
                label.textColor = .darkGray
                label.font = .systemFont(ofSize: 18)
            }
        }
    }

    private func snapToNearestYear() {
        let fullLabelHeight = labelHeight + labelSpacing
        let index = Int(round(scrollView.contentOffset.y / fullLabelHeight))
        let offsetY = CGFloat(index) * fullLabelHeight
        scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }
}

extension ScrollableYearPicker: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNeedsLayout()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestYear()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearestYear()
        }
    }
}
*/

//// Clamp extension
//private extension Comparable {
//    func clamped(to limits: ClosedRange<Self>) -> Self {
//        return min(max(self, limits.lowerBound), limits.upperBound)
//    }
//}






//class CustomCircularDOB2: UIControl {
//
//    enum PickerType {
//        case day, month, year
//    }
//
//    private var values: [String] = []
//    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(values.count) }
//
//    private var closestLabel: UILabel?
//    private var radiusX: CGFloat = 0
//    private var radiusY: CGFloat = 0
//    let padding: CGFloat = 40
//    private var rotationAngle: CGFloat = -90
//
//    public let centerLabel = UILabel()
//    public var pickerType: PickerType = .month {
//        didSet {
//            configureForPickerType()
//        }
//    }
//
//    public var theme: PickerTheme = PickerTheme(
//        backgroundColor: .clear,
//        textColor: .red,
//        selectedTextColor: .darkGray,
//        centerLabelColor: .green,
//        gradientColors: [UIColor.lightGray.withAlphaComponent(0.5), .white, UIColor.lightGray.withAlphaComponent(0.5)],
//        curveStrokeColor: .white
//    ) {
//        didSet {
//            applyTheme()
//        }
//    }
//
//    private(set) var selectedValue: String?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .clear
//        setupCenterLabel()
//        configureForPickerType()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupCenterLabel()
//        configureForPickerType()
//    }
//
//    private func configureForPickerType() {
//        switch pickerType {
//        case .day:
//            values = (1...31).map { String($0) }
//        case .month:
//            values = DateFormatter().shortMonthSymbols
//        case .year:
//            let currentYear = Calendar.current.component(.year, from: Date())
//            values = (currentYear - 20...currentYear).map { String($0) }
//        }
//        updateValuePositions()
//    }
//
//    private func setupCenterLabel() {
//        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
//        centerLabel.textAlignment = .center
//        centerLabel.textColor = theme.centerLabelColor
//        addSubview(centerLabel)
//    }
//
//    private func applyTheme() {
//        backgroundColor = theme.backgroundColor
//        centerLabel.textColor = theme.centerLabelColor
//        updateValuePositions()
//        setNeedsDisplay()
//    }
//
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        layer.sublayers?.removeAll(where: { $0.name == "gradientCurve" })
//
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let curveRadiusX: CGFloat = radiusX
//        let curveRadiusY: CGFloat = radiusY
//        let lineWidth: CGFloat = 1.5
//
//        let startAngle: CGFloat = -.pi / 1.40
//        let endAngle: CGFloat = -.pi / 3.15
//
//        let curvePath = UIBezierPath(
//            arcCenter: center,
//            radius: curveRadiusX,
//            startAngle: startAngle,
//            endAngle: endAngle,
//            clockwise: true
//        )
//        curvePath.apply(CGAffineTransform(scaleX: 1, y: curveRadiusY / curveRadiusX))
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = curvePath.cgPath
//        shapeLayer.strokeColor = theme.curveStrokeColor.cgColor
//        shapeLayer.lineWidth = lineWidth
//        shapeLayer.fillColor = UIColor.clear.cgColor
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = bounds
//        gradientLayer.colors = theme.gradientColors.map { $0.cgColor }
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
//        gradientLayer.mask = shapeLayer
//        gradientLayer.name = "gradientCurve"
//        layer.addSublayer(gradientLayer)
//
//        let backgroundEllipsePath = UIBezierPath(
//            arcCenter: center,
//            radius: radiusX,
//            startAngle: 0,
//            endAngle: 2 * .pi,
//            clockwise: true
//        )
//        backgroundEllipsePath.apply(CGAffineTransform(scaleX: 1, y: radiusY / radiusX))
//        UIColor.black.withAlphaComponent(0.4).setFill()
//        backgroundEllipsePath.fill()
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        guard bounds.width > 0 && bounds.height > 0 else { return }
//
//        centerLabel.frame.size = CGSize(width: 100, height: 50)
//        centerLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
//
//        let availableWidth = bounds.width - 2 * padding
//        let availableHeight = bounds.height - 2 * padding
//        let desiredAspectRatio: CGFloat = 1.3
//
//        let maxRadiusHorizontal = availableWidth / 2
//        let maxRadiusVertical = availableHeight / 2
//
//        if maxRadiusHorizontal / maxRadiusVertical > desiredAspectRatio {
//            radiusY = maxRadiusVertical
//            radiusX = radiusY * desiredAspectRatio
//        } else {
//            radiusX = maxRadiusHorizontal
//            radiusY = radiusX / desiredAspectRatio
//        }
//
//        updateValuePositions()
//    }
//
//    private func updateValuePositions() {
//        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
//
//        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude
//
//        for (index, value) in values.enumerated() {
//            let angle = anglePerItem * CGFloat(index) + rotationAngle
//            let label = createValueLabel(text: value)
//
//            let position = CGPoint(
//                x: bounds.midX + (radiusX * cos(angle) - label.bounds.width / 2) + padding,
//                y: bounds.midY + radiusY * sin(angle) - label.bounds.height / 2
//            )
//
//            label.center = position
//            addSubview(label)
//
//            let angleDifference = abs(angle.truncatingRemainder(dividingBy: 2 * .pi) - (-.pi / 2))
//            if angleDifference < smallestAngleDifference {
//                smallestAngleDifference = angleDifference
//                closestLabel = label
//            }
//        }
//
//        centerLabel.text = closestLabel?.text
//        closestLabel?.textColor = theme.selectedTextColor
//        closestLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//
//        selectedValue = closestLabel?.text
//        updateSelectedValue()
//    }
//
//    private func createValueLabel(text: String) -> UILabel {
//        let label = UILabel()
//        label.text = text
//        label.font = UIFont.boldSystemFont(ofSize: 10)
//        label.textAlignment = .center
//        label.textColor = theme.textColor
//        label.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
//        return label
//    }
//
//    private func updateSelectedValue() {
//        let normalizedAngle = fmod(rotationAngle + (anglePerItem / 2), 2 * .pi)
//        let selectedIndex = Int(round(normalizedAngle / anglePerItem)) % values.count
//    }
//
//    private var lastTouchAngle: CGFloat = 0
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        lastTouchAngle = angleForPoint(touch.location(in: self))
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let currentAngle = angleForPoint(touch.location(in: self))
//        let angleDifference = currentAngle - lastTouchAngle
//
//        rotationAngle += angleDifference
//        lastTouchAngle = currentAngle
//
//        updateValuePositions()
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        snapToNearestValue()
//    }
//
//    private func snapToNearestValue() {
//        let nearestIndex = Int(round(rotationAngle / anglePerItem))
//        rotationAngle = CGFloat(nearestIndex) * anglePerItem
//
//        UIView.animate(withDuration: 0.2) {
//            self.updateValuePositions()
//        }
//
//        sendActions(for: .valueChanged)
//    }
//
//    private func angleForPoint(_ point: CGPoint) -> CGFloat {
//        let dx = point.x - bounds.midX
//        let dy = point.y - bounds.midY
//        return atan2(dy, dx)
//    }
//}



//MARK: -------------------- DatePickerContainerView

protocol DatePickerContainerDelegate: AnyObject {
    func selectAge(age:String?)
    func selectDate(date:(year: String?, month: String?, day: String?)?)
}

//class DatePickerContainerView2: UIView {
//
//    weak var delegate: DatePickerContainerDelegate?
//    
//    private let triangleLayer = CAShapeLayer()
//    private let centerView = UIView() // The view you want to center
//    private let ageLable = UILabel()
//    
//    private let yearPicker = CustomCircularDOB2()
//    private let monthPicker = CustomCircularDOB2()
//    private let dayPicker = CustomCircularDOB2()
//
//    public var selectedDate: (year: String?, month: String?, day: String?) {
//        return (yearPicker.selectedValue, monthPicker.selectedValue, dayPicker.selectedValue)
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupPickers()
//        layoutPickers()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupPickers()
//        layoutPickers()
//        setupCenterView() // New: Setup the center view
//        layoutCenterView() // New: Layout the center view
//    }
//    
//    override func draw(_ rect: CGRect) {
//            super.draw(rect)
////        if let topView = self.subviews.last { // subviews is an array, last object is on top
////            print("Top view is: \(topView)")
////            topView.backgroundColor = UIColor.clear
////
////            self.drawTriangle(atView: topView)
////        }
//        
//        }
//    
//    private func setupCenterView() {
//   
//        centerView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(centerView)
//       
//        ageLable.translatesAutoresizingMaskIntoConstraints = false
//        centerView.addSubview(ageLable)
//
//        // Add the triangle layer to the center view's layer
//        centerView.layer.addSublayer(triangleLayer)
//        
//
//    }
//
//    
//    private func layoutCenterView() {
//        
//            NSLayoutConstraint.activate([
//                centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
//                centerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
//                centerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.48),
//                centerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0),
//                ageLable.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
//                ageLable.centerYAnchor.constraint(equalTo: centerView.centerYAnchor, constant: 1.0),
//                ageLable.heightAnchor.constraint(equalToConstant: 50)
//            ])
//
//            self.bringSubviewToFront(centerView)
////        centerView.bringSubviewToFront(ageLable)
//            centerView.backgroundColor = UIColor.black
//            updateTrianglePath() // Initial triangle drawing
//        }
//
//        private func updateTrianglePath() {
//            let triangleHeight: CGFloat = 20
//            let triangleWidth: CGFloat = 24
//            let triangleX = centerView.bounds.midX
//            let triangleY = CGFloat(-5) // Top of the center view
//
//            let trianglePath = UIBezierPath()
//            trianglePath.move(to: CGPoint(x: triangleX, y: triangleY))
//            trianglePath.addLine(to: CGPoint(x: triangleX - triangleWidth / 2, y: triangleY + triangleHeight))
//            trianglePath.addLine(to: CGPoint(x: triangleX + triangleWidth / 2, y: triangleY + triangleHeight))
//            trianglePath.close()
//
//            triangleLayer.path = trianglePath.cgPath
//            triangleLayer.fillColor = UIColor.orange.cgColor
//        }
//        
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        [yearPicker, monthPicker, dayPicker].forEach({
//            $0.roundSideCorners(radius: self.frame.height/3.2, cornerSide: [.topLeft, .topRight])
//        })
//                
//        setupCenterView() // New: Setup the center view
//        layoutCenterView()
//        updateTrianglePath()
//        
//        ageLable.textColor = UIColor.white
////        ageLable.text = "Your age is "
//       
//        //------------getting top view
//        
////        if let topView = self.subviews.last { // subviews is an array, last object is on top
////            print("Top view is: \(topView)")
//////            topView.backgroundColor = UIColor.clear
////
////            self.drawTriangle(atView: topView)
////        }
//        
////        if let topLayer = self.layer.sublayers?.last { // subviews is an array, last object is on top
////            print("Top topLayer is: \(topLayer)")
////            topLayer.backgroundColor = UIColor.green.cgColor
////        }
//    }
//
//    private func setupPickers() {
//        yearPicker.pickerType = .year
//        monthPicker.pickerType = .month
//        dayPicker.pickerType = .day
//
//        // Apply the same theme to all pickers
//        let theme = PickerTheme(
//            backgroundColor: UIColor.clear,
//            textColor: .lightGray,
//            selectedTextColor: .white,
//            centerLabelColor: .clear,
//            gradientColors: [UIColor.gray.withAlphaComponent(0.4), .white, UIColor.gray.withAlphaComponent(0.4)],
//            curveStrokeColor: .red
//        )
//
//        [yearPicker, monthPicker, dayPicker].forEach { picker in
//            picker.theme = theme
//            if picker == yearPicker{
//                yearPicker.theme.gradientColors = [UIColor.clear, UIColor.clear, UIColor.clear]
//            }
//            
////            if picker == dayPicker || picker == monthPicker {
////                dayPicker.theme.backgroundColor = UIColor.clear
////                monthPicker.theme.backgroundColor = UIColor.clear
////            }
//
//            picker.addTarget(self, action: #selector(pickerValueChanged(_:)), for: .valueChanged)
//            addSubview(picker)
//        }
//    }
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
//            yearPicker.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0),
//            yearPicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0),
//          
//            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
////            monthPicker.topAnchor.constraint(equalTo: yearPicker.topAnchor, constant: 95.0),
//            monthPicker.heightAnchor.constraint(equalTo: yearPicker.heightAnchor, multiplier: 0.75),
//            monthPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0),
//
//            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
////            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: 70.0),
//            dayPicker.heightAnchor.constraint(equalTo: monthPicker.heightAnchor, multiplier: 0.85),
//            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
//        ])
//    }
//
//    @objc private func pickerValueChanged(_ picker: CustomCircularDOB2) {
//        print("Selected Date: \(selectedDate)")
//        
//        if let getYears = Int(selectedDate.year ?? "") , let getMonths = selectedDate.month ,let getDays = Int(selectedDate.day ?? ""){
//            
//            let age = calculateAge(birthYear: getYears, birthMonth: getMonthNumber(for: getMonths) ?? 1, birthDay: getDays)
//            ageLable.text = "Your age is " + "\(age)"
//            self.delegate?.selectAge(age: "\(age)")
//            self.delegate?.selectDate(date: selectedDate)
//        }
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



//------------------------------

/*
class CustomCircularDOB2: UIControl {

    enum PickerType {
        case day, month, year
    }

    private var values: [String] = []
    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(values.count) }

    private var closestLabel: UILabel?
    private var radiusX: CGFloat = 0  // Radius in x-direction
    private var radiusY: CGFloat = 0  // Radius in y-direction
    let padding: CGFloat = 40
    private var rotationAngle: CGFloat = -90

    public let centerLabel = UILabel()
    public var pickerType: PickerType = .month {
        didSet {
            configureForPickerType()
        }
    }

    public var theme: PickerTheme = PickerTheme(
        backgroundColor: .clear,
        textColor: .red,
        selectedTextColor: .darkGray,
        centerLabelColor: .green,
        gradientColors: [UIColor.lightGray.withAlphaComponent(0.5), .white, UIColor.lightGray.withAlphaComponent(0.5)],
        curveStrokeColor: .white
    ) {
        didSet {
            applyTheme()
        }
    }

    private(set) var selectedValue: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupCenterLabel()
        configureForPickerType()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCenterLabel()
        configureForPickerType()
    }

    private func configureForPickerType() {
        switch pickerType {
        case .day:
            values = (1...31).map { String($0) }
        case .month:
            values = DateFormatter().shortMonthSymbols
        case .year:
            let currentYear = Calendar.current.component(.year, from: Date())
            values = (currentYear - 20...currentYear).map { String($0) }
//            values = (currentYear - 50...currentYear + 1).map { String($0) }
        }
        updateValuePositions()
    }

    private func setupCenterLabel() {
        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        centerLabel.textAlignment = .center
        centerLabel.textColor = theme.centerLabelColor
        addSubview(centerLabel)
    }

    private func applyTheme() {
        backgroundColor = theme.backgroundColor
        centerLabel.textColor = theme.centerLabelColor
        updateValuePositions()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        layer.sublayers?.removeAll(where: { $0.name == "gradientCurve" })

//        guard let context = UIGraphicsGetCurrentContext() else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let curveRadiusX: CGFloat = radiusX //+ 10  // + padding
        let curveRadiusY: CGFloat = radiusY // + 10  //+ padding
        let lineWidth: CGFloat = 1.5

        let startAngle: CGFloat = -.pi / 1.40
        let endAngle: CGFloat = -.pi / 3.15

        let curvePath = UIBezierPath(
            arcCenter: center,
            radius: curveRadiusX,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        curvePath.apply(CGAffineTransform(scaleX: 1, y: curveRadiusY / curveRadiusX))

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = curvePath.cgPath
        shapeLayer.strokeColor = theme.curveStrokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = theme.gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = shapeLayer
        gradientLayer.name = "gradientCurve"
        layer.addSublayer(gradientLayer)
        
        
        //-------------------
           let backgroundEllipsePath = UIBezierPath(
               arcCenter: center,
               radius: radiusX, // Use radiusX for the full ellipse
               startAngle: 0,      // Start at 0 radians
               endAngle: 2 * .pi, // End at 2*pi radians (full circle)
               clockwise: true
           )
           backgroundEllipsePath.apply(CGAffineTransform(scaleX: 1, y: radiusY / radiusX)) // Scale for ellipse

           // 2. Set the fill color and fill the path:
        let backgroundColor = UIColor.black.withAlphaComponent(0.4) // Your desired color
           backgroundColor.setFill()
           backgroundEllipsePath.fill()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.width > 0 && bounds.height > 0 else { return }

         centerLabel.frame.size = CGSize(width: 100, height: 50)
         centerLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)

         let availableWidth = bounds.width - 2 * padding
         let availableHeight = bounds.height - 2 * padding

         // 1. Calculate Radii Based on Aspect Ratio (Recommended):
        /*
         1.0: Circle
         1.5: Ellipse wider than tall
         0.75: Ellipse taller than wide
         2.0: Ellipse much wider than tall
         0.5: Ellipse much taller than wide
         */
        
        let desiredAspectRatio: CGFloat = 1.3 //1.26 // Example:  x:y = 1.5:1. Adjust as needed!

         let maxRadiusHorizontal = availableWidth / 2
         let maxRadiusVertical = availableHeight / 2

         if maxRadiusHorizontal / maxRadiusVertical > desiredAspectRatio {
             // Height is the limiting factor
             radiusY = maxRadiusVertical
             radiusX = radiusY * desiredAspectRatio
         } else {
             // Width is the limiting factor
             radiusX = maxRadiusHorizontal
             radiusY = radiusX / desiredAspectRatio
         }


        updateValuePositions()
    }

    private func updateValuePositions() {
        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }

        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude

        for (index, value) in values.enumerated() {
            let angle = anglePerItem * CGFloat(index) + rotationAngle
            let label = createValueLabel(text: value)

            let position = CGPoint(
                x: bounds.midX + (radiusX * cos(angle) - label.bounds.width / 2) + padding,
                y: bounds.midY + radiusY * sin(angle) - label.bounds.height / 2
            )
           
            label.center = position
            addSubview(label)

            let angleDifference = abs(angle.truncatingRemainder(dividingBy: 2 * .pi) - (-.pi / 2))
            if angleDifference < smallestAngleDifference {
                smallestAngleDifference = angleDifference
                closestLabel = label
            }
        }

        
        centerLabel.text = closestLabel?.text
        closestLabel?.textColor = theme.selectedTextColor
        closestLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        selectedValue = closestLabel?.text
        updateSelectedValue()
    }

    private func createValueLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = theme.textColor
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
        return label
    }

    private func updateSelectedValue() {
        let normalizedAngle = fmod(rotationAngle + (anglePerItem / 2), 2 * .pi)
        let selectedIndex = Int(round(normalizedAngle / anglePerItem)) % values.count
//        selectedValue = values[(selectedIndex + values.count) % values.count]
    }

    private var lastTouchAngle: CGFloat = 0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchAngle = angleForPoint(touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentAngle = angleForPoint(touch.location(in: self))
        let angleDifference = currentAngle - lastTouchAngle

        rotationAngle += angleDifference
        lastTouchAngle = currentAngle

        updateValuePositions()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestValue()
    }

    private func snapToNearestValue() {
        let nearestIndex = Int(round(rotationAngle / anglePerItem))
        rotationAngle = CGFloat(nearestIndex) * anglePerItem

        UIView.animate(withDuration: 0.2) {
            self.updateValuePositions()
        }

        sendActions(for: .valueChanged)
    }

    private func angleForPoint(_ point: CGPoint) -> CGFloat {
        let dx = point.x - bounds.midX
        let dy = point.y - bounds.midY
        return atan2(dy, dx)
    }
}



//MARK: -------------------- DatePickerContainerView

protocol DatePickerContainerDelegate: AnyObject {
    func selectAge(age:String?)
    func selectDate(date:(year: String?, month: String?, day: String?)?)
}

class DatePickerContainerView2: UIView {

    weak var delegate: DatePickerContainerDelegate?
    
    private let triangleLayer = CAShapeLayer()
    private let centerView = UIView() // The view you want to center
    private let ageLable = UILabel()
    
    private let yearPicker = CustomCircularDOB2()
    private let monthPicker = CustomCircularDOB2()
    private let dayPicker = CustomCircularDOB2()

    public var selectedDate: (year: String?, month: String?, day: String?) {
        return (yearPicker.selectedValue, monthPicker.selectedValue, dayPicker.selectedValue)
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
    
    private func setupCenterView() {
   
        centerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerView)
       
        ageLable.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(ageLable)

        // Add the triangle layer to the center view's layer
        centerView.layer.addSublayer(triangleLayer)
        

    }
    
//    private func layoutCenterView() {
//        NSLayoutConstraint.activate([
//            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            centerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
//            centerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.47),
//            centerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0)
//        ])
//        
//        // Optional:  If you want the center view to be *above* the pickers:
//        self.bringSubviewToFront(centerView)
//        
//        centerView.backgroundColor = UIColor.yellow
//        
//        self.drawTriangle(atView: self.centerView)
//    }
    
    private func layoutCenterView() {
        
            NSLayoutConstraint.activate([
                centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                centerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
                centerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.48),
                centerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0),
                ageLable.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
                ageLable.centerYAnchor.constraint(equalTo: centerView.centerYAnchor, constant: 1.0),
                ageLable.heightAnchor.constraint(equalToConstant: 50)
            ])

            self.bringSubviewToFront(centerView)
//        centerView.bringSubviewToFront(ageLable)
            centerView.backgroundColor = UIColor.black
            updateTrianglePath() // Initial triangle drawing
        }

        private func updateTrianglePath() {
            let triangleHeight: CGFloat = 20
            let triangleWidth: CGFloat = 24
            let triangleX = centerView.bounds.midX
            let triangleY = CGFloat(-5) // Top of the center view

            let trianglePath = UIBezierPath()
            trianglePath.move(to: CGPoint(x: triangleX, y: triangleY))
            trianglePath.addLine(to: CGPoint(x: triangleX - triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.addLine(to: CGPoint(x: triangleX + triangleWidth / 2, y: triangleY + triangleHeight))
            trianglePath.close()

            triangleLayer.path = trianglePath.cgPath
            triangleLayer.fillColor = UIColor.orange.cgColor
        }
        

    override func layoutSubviews() {
        super.layoutSubviews()
        
        [yearPicker, monthPicker, dayPicker].forEach({
            $0.roundSideCorners(radius: self.frame.height/3.2, cornerSide: [.topLeft, .topRight])
        })
                
        setupCenterView() // New: Setup the center view
        layoutCenterView()
        updateTrianglePath()
        
        ageLable.textColor = UIColor.white
//        ageLable.text = "Your age is "
       
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
        yearPicker.pickerType = .year
        monthPicker.pickerType = .month
        dayPicker.pickerType = .day

        // Apply the same theme to all pickers
        let theme = PickerTheme(
            backgroundColor: UIColor.clear,
            textColor: .lightGray,
            selectedTextColor: .white,
            centerLabelColor: .clear,
            gradientColors: [UIColor.gray.withAlphaComponent(0.4), .white, UIColor.gray.withAlphaComponent(0.4)],
            curveStrokeColor: .red
        )

        [yearPicker, monthPicker, dayPicker].forEach { picker in
            picker.theme = theme
            if picker == yearPicker{
                yearPicker.theme.gradientColors = [UIColor.clear, UIColor.clear, UIColor.clear]
            }
            
//            if picker == dayPicker || picker == monthPicker {
//                dayPicker.theme.backgroundColor = UIColor.clear
//                monthPicker.theme.backgroundColor = UIColor.clear
//            }

            picker.addTarget(self, action: #selector(pickerValueChanged(_:)), for: .valueChanged)
            addSubview(picker)
        }
    }

    private func layoutPickers() {
        // Use Auto Layout for flexibility
        
        [yearPicker, monthPicker, dayPicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            yearPicker.topAnchor.constraint(equalTo: topAnchor),
            yearPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            yearPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            yearPicker.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0),
            yearPicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0),
          
            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            monthPicker.topAnchor.constraint(equalTo: yearPicker.topAnchor, constant: 95.0),
            monthPicker.heightAnchor.constraint(equalTo: yearPicker.heightAnchor, multiplier: 0.75),
            monthPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0),

            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: 70.0),
            dayPicker.heightAnchor.constraint(equalTo: monthPicker.heightAnchor, multiplier: 0.85),
            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
        ])
    }

//    @objc private func pickerValueChanged(_ picker: CircularPicker) {
//        print("Selected Date: \(selectedDate)")
//        
////        let age = calculateAge(birthYear: selectedDate.year, birthMonth: months.firstIndex(of: selectedDate.month) + 1, birthDay: selectedDate.day, monthSymbols: months)
//
//        // let getMonths = Int(selectedDate.month ?? "2")
//        if let getYears = Int(selectedDate.year ?? "") , let getDays = Int(selectedDate.day ?? ""){
////            ageLable.text = "Your age is " +  getYears
//            
//            let age = calculateAge(birthYear: getYears, birthMonth: 2, birthDay: getDays, monthSymbols: (1...12).map { String($0) })
//            
//            ageLable.text = "Your age is " + "\(age)"
//        }
////        ageLable.text = "Your age is " +  (selectedDate.year ?? "")
//    }
    
    @objc private func pickerValueChanged(_ picker: CustomCircularDOB2) {
        print("Selected Date: \(selectedDate)")
        
        if let getYears = Int(selectedDate.year ?? "") , let getMonths = selectedDate.month ,let getDays = Int(selectedDate.day ?? ""){
            
            let age = calculateAge(birthYear: getYears, birthMonth: getMonthNumber(for: getMonths) ?? 1, birthDay: getDays)
            ageLable.text = "Your age is " + "\(age)"
            self.delegate?.selectAge(age: "\(age)")
            self.delegate?.selectDate(date: selectedDate)
        }
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
  
//    private func calculateAge<T: Comparable>(birthYear: Int, birthMonth: Int, birthDay: Int, currentYear: Int? = nil, currentMonth: Int? = nil, currentDay: Int? = nil, monthSymbols: [T]) -> Int {
//
//        let calendar = Calendar.current
//
//        // Use current date components if not provided
//        let now = Date()
//        let currentYearProvided = currentYear ?? calendar.component(.year, from: now)
//        let currentMonthProvided = currentMonth ?? calendar.component(.month, from: now)
//        let currentDayProvided = currentDay ?? calendar.component(.day, from: now)
//
//
//        // Validate birth month
//        guard birthMonth >= 1 && birthMonth <= monthSymbols.count else {
//            print("Invalid birth month")
//            return 0 // Or throw an error if you prefer
//        }
//
//        let birthDate = calendar.date(from: DateComponents(year: birthYear, month: birthMonth, day: birthDay))
//
//        guard let birthDate = birthDate else {
//            print("Invalid birth date")
//            return 0 // Or throw an error
//        }
//
//        let currentDate = calendar.date(from: DateComponents(year: currentYearProvided, month: currentMonthProvided, day: currentDayProvided)) ?? now // Use now if current date components aren't valid
//
//        return calendar.dateComponents([.year], from: birthDate, to: currentDate).year ?? 0
//    }
}
*/

//-------------------------------------
