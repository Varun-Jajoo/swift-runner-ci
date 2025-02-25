//
//  CustomCircularDOB2.swift
//  MyPT
//
//  Created by techsaga corp on 05/02/25.
//

import UIKit


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
