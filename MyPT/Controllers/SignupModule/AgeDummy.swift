//
//  AgeDummy.swift
//  MyPT
//
//  Created by techsaga corp on 03/02/25.
//


import UIKit

//--------------------**************
struct PickerTheme {
    var backgroundColor: UIColor
    var textColor: UIColor
    var selectedTextColor: UIColor
    var centerLabelColor: UIColor
    var gradientColors: [UIColor]
    var curveStrokeColor: UIColor
}


class CircularPicker: UIControl {

    enum PickerType {
        case day, month, year
    }

    private var values: [String] = []
    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(values.count) }

    private var closestLabel: UILabel?
    private var radiusX: CGFloat = 0 //150 // Radius in x-direction
    private var radiusY: CGFloat = 0 //100  // Radius in y-direction
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
            values = (currentYear - 10...currentYear + 1).map { String($0) }
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
//        gradientLayer.frame.origin.y = -2
        gradientLayer.colors = theme.gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = shapeLayer
        gradientLayer.name = "gradientCurve"
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        /*
        guard bounds.width > 0 && bounds.height > 0 else { return }

        centerLabel.frame.size = CGSize(width: 100, height: 50)
        centerLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)

        let availableWidth = bounds.width - 2 * padding
        let availableHeight = bounds.height - 2 * padding

        // Example Aspect Ratio Calculation (Adjust as needed)
        let aspectRatio = CGFloat(values.count) / 10.0  // Example!
        let maxRadius = min(availableWidth / 2, availableHeight / 2)
        radiusX = maxRadius * aspectRatio
        radiusY = maxRadius / aspectRatio
        */
        
        
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
        selectedValue = values[(selectedIndex + values.count) % values.count]
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
class DatePickerContainerView: UIView {

    private let yearPicker = CircularPicker()
    private let monthPicker = CircularPicker()
    private let dayPicker = CircularPicker()

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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [yearPicker, monthPicker, dayPicker].forEach({
            $0.roundSideCorners(radius: self.frame.height/3.2, cornerSide: [.topLeft, .topRight])
        })
    }

    private func setupPickers() {
        yearPicker.pickerType = .year
        monthPicker.pickerType = .month
        dayPicker.pickerType = .day

        // Apply the same theme to all pickers
        let theme = PickerTheme(
            backgroundColor: UIColor.black,
            textColor: .lightGray,
            selectedTextColor: .white,
            centerLabelColor: .black,
            gradientColors: [UIColor.gray.withAlphaComponent(0.4), .white, UIColor.gray.withAlphaComponent(0.4)],
            curveStrokeColor: .black
        )

        
//        [yearPicker, monthPicker, dayPicker].forEach { picker in
//            picker.theme = theme
//            if picker == dayPicker{
//                dayPicker.theme.backgroundColor = UIColor.cyan
//            }
////            yearPicker.theme.backgroundColor = UIColor.blue
////            monthPicker.theme.backgroundColor = UIColor.yellow
////            dayPicker.theme.backgroundColor = UIColor.cyan
//            picker.addTarget(self, action: #selector(pickerValueChanged(_:)), for: .valueChanged)
//            addSubview(picker)
        
//        [yearPicker, monthPicker, dayPicker].forEach { picker in
//            picker.theme = theme
//            if picker == dayPicker{
//                dayPicker.theme.backgroundColor = UIColor.cyan
//            }
////            yearPicker.theme.backgroundColor = UIColor.blue
////            monthPicker.theme.backgroundColor = UIColor.yellow
////            dayPicker.theme.backgroundColor = UIColor.cyan
//            picker.addTarget(self, action: #selector(pickerValueChanged(_:)), for: .valueChanged)
//            addSubview(picker)
        

        
        [yearPicker, monthPicker, dayPicker].forEach { picker in
            picker.theme = theme
            if picker == yearPicker{
                yearPicker.theme.gradientColors = [UIColor.clear, UIColor.clear, UIColor.clear]
            }
//            yearPicker.theme.backgroundColor = UIColor.blue
//            monthPicker.theme.backgroundColor = UIColor.yellow
//            dayPicker.theme.backgroundColor = UIColor.cyan
            picker.addTarget(self, action: #selector(pickerValueChanged(_:)), for: .valueChanged)
            addSubview(picker)
        }
        
//        yearPicker.theme = theme
//        addSubview(yearPicker)
       
    }

    private func layoutPickers() {
        // Use Auto Layout for flexibility
        
        /*
        yearPicker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            yearPicker.topAnchor.constraint(equalTo: topAnchor),
            yearPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            yearPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            yearPicker.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            yearPicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0)
          
//            monthPicker.leadingAnchor.constraint(equalTo: yearPicker.leadingAnchor),
//            monthPicker.trailingAnchor.constraint(equalTo: yearPicker.trailingAnchor),
//            monthPicker.topAnchor.constraint(equalTo: yearPicker.topAnchor, constant: 90.0),
//            monthPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0),
////            dayPicker.centerYAnchor.constraint(equalTo: monthPicker.centerYAnchor, constant: 45.0),
//            dayPicker.leadingAnchor.constraint(equalTo: yearPicker.leadingAnchor),
//            dayPicker.trailingAnchor.constraint(equalTo: yearPicker.trailingAnchor),
//            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: 50.0),
//            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
//            dayPicker.heightAnchor.constraint(equalTo: yearPicker.heightAnchor, multiplier: 0.80)
           
//            dayPicker.bottomAnchor.constraint(equalTo: bottomAnchor)
            

//            monthPicker.topAnchor.constraint(equalTo: yearPicker.bottomAnchor),
//            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            monthPicker.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
//
//            dayPicker.topAnchor.constraint(equalTo: monthPicker.bottomAnchor),
//            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            dayPicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        */
        
        
        [yearPicker, monthPicker, dayPicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
//            yearPicker.topAnchor.constraint(equalTo: topAnchor),
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
            
////            dayPicker.centerYAnchor.constraint(equalTo: monthPicker.centerYAnchor, constant: 45.0),
//            dayPicker.leadingAnchor.constraint(equalTo: yearPicker.leadingAnchor),
//            dayPicker.trailingAnchor.constraint(equalTo: yearPicker.trailingAnchor),
//            dayPicker.topAnchor.constraint(equalTo: monthPicker.topAnchor, constant: 80.0),
//            dayPicker.bottomAnchor.constraint(equalTo: yearPicker.bottomAnchor, constant: 1.0)
            
//            dayPicker.heightAnchor.constraint(equalTo: yearPicker.heightAnchor, multiplier: 0.80)
           
//            dayPicker.bottomAnchor.constraint(equalTo: bottomAnchor)
            

//            monthPicker.topAnchor.constraint(equalTo: yearPicker.bottomAnchor),
//            monthPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            monthPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            monthPicker.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),
//
//            dayPicker.topAnchor.constraint(equalTo: monthPicker.bottomAnchor),
//            dayPicker.leadingAnchor.constraint(equalTo: leadingAnchor),
//            dayPicker.trailingAnchor.constraint(equalTo: trailingAnchor),
//            dayPicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        
        //-------------------------********************
//        [yearPicker, monthPicker, dayPicker].forEach({
//            $0.roundSideCorners(radius: 30, cornerSide: [.topLeft, .topRight])
//        })
    }

    @objc private func pickerValueChanged(_ picker: CircularPicker) {
        print("Selected Date: \(selectedDate)")
    }
}




/* 1111 - worked
class CircularPicker: UIControl {

    enum PickerType {
        case day, month, year
    }

    private var values: [String] = []
    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(values.count) }

    private var closestLabel: UILabel?
    private var radius: CGFloat = 100
    private var rotationAngle: CGFloat = -90
    let padding: CGFloat = 40

    public let centerLabel = UILabel()
    public var pickerType: PickerType = .month {
        didSet {
            configureForPickerType()
        }
    }

    // Store the selected value
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
//            values = DateFormatter().monthSymbols
            values = DateFormatter().shortMonthSymbols
        case .year:
            let currentYear = Calendar.current.component(.year, from: Date())
            values = (currentYear - 10...currentYear + 1).map { String($0) }
        }
        updateValuePositions()
    }

    private func setupCenterLabel() {
        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        centerLabel.textAlignment = .center
        centerLabel.textColor = .green
        addSubview(centerLabel)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        layer.sublayers?.removeAll(where: { $0.name == "gradientCurve" })

        guard let context = UIGraphicsGetCurrentContext() else { return }

//        let center = CGPoint(x: bounds.midX - 20, y: bounds.midY)
        let center = CGPoint(x: bounds.midX , y: bounds.midY)
        let curveRadius: CGFloat = radius + padding
        let lineWidth: CGFloat = 1.0

        let startAngle: CGFloat = -.pi / 1.40
        let endAngle: CGFloat = -.pi / 3.15

        let curvePath = UIBezierPath(
            arcCenter: center,
            radius: curveRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        context.setLineWidth(lineWidth)
        UIColor.lightGray.setStroke()
        context.addPath(curvePath.cgPath)
        context.strokePath()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = curvePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .butt

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.lightGray.withAlphaComponent(0.5).cgColor,
            UIColor.white.cgColor,
            UIColor.lightGray.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = shapeLayer
        gradientLayer.name = "gradientCurve"
        layer.addSublayer(gradientLayer)
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        guard bounds.width > 0 && bounds.height > 0 else { return }
//        centerLabel.frame = CGRect(x: (bounds.width - 100) / 2, y: (bounds.height - 50) / 2, width: 100, height: 50)
//        updateValuePositions()
//    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        guard bounds.width > 0 && bounds.height > 0 else { return }
//        
//        // Dynamically calculate the radius based on the view size
//        let padding: CGFloat = 40 // Add some padding from edges
//        radius = min(bounds.width, bounds.height) / 2 - padding
//
//        // Center label positioning
//        centerLabel.frame = CGRect(
//            x: (bounds.width - 100) / 2,
//            y: (bounds.height - 50) / 2,
//            width: 100,
//            height: 50
//        )
//        
//        // Update label positions based on the new radius
//        updateValuePositions()
//    }

    
    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.width > 0 && bounds.height > 0 else { return }

        // Center the label perfectly
        centerLabel.frame.size = CGSize(width: 100, height: 50)
        centerLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)

        // Dynamically calculate the radius
        radius = min(bounds.width, bounds.height) / 2 - padding

        updateValuePositions()
    }


    private func updateValuePositions() {
        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }

        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude

        for (index, value) in values.enumerated() {
            let angle = anglePerItem * CGFloat(index) + rotationAngle
            let label = createValueLabel(text: value)

//            let position = CGPoint(
//                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
//                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
//            )
            
            let position = CGPoint(
                x: bounds.midX + (radius * cos(angle) - label.bounds.width / 2) + padding,
                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
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
        closestLabel?.textColor = .darkGray
        closestLabel?.font = UIFont.boldSystemFont(ofSize: 20)

        updateSelectedValue()
    }

    private func createValueLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .red
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 20) // Adjust size as needed
        return label
    }

    private func updateSelectedValue() {
        let normalizedAngle = fmod(rotationAngle + (anglePerItem / 2), 2 * .pi)
        let selectedIndex = Int(round(normalizedAngle / anglePerItem)) % values.count
        selectedValue = values[(selectedIndex + values.count) % values.count]
        print("Selected Value: \(selectedValue ?? "")") // Print or use selectedValue
    }

    // MARK: - Touch Handling

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

        UIView.animate(withDuration: 0.2, animations: {
            self.updateValuePositions()
        })

        sendActions(for: .valueChanged)
    }

    private func angleForPoint(_ point: CGPoint) -> CGFloat {
        let dx = point.x - bounds.midX
        let dy = point.y - bounds.midY
        return atan2(dy, dx)
    }
}

*/


/* This is last final code which is working
 
class CircularPicker: UIControl {

    enum PickerType {
        case day, month, year
    }

    private var values: [String] = []
    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(values.count) }

    private var closestLabel: UILabel?
//    private var radius: CGFloat = 120
    public var radius: CGFloat = 120
    private var rotationAngle: CGFloat = -90

    public let centerLabel = UILabel()
    public var pickerType: PickerType = .month {
        didSet {
            configureForPickerType()
        }
    }

    // Store the selected value
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
//            values = DateFormatter().monthSymbols
            values = DateFormatter().shortMonthSymbols
        case .year:
            let currentYear = Calendar.current.component(.year, from: Date())
            values = (currentYear - 10...currentYear + 1).map { String($0) }
        }
        updateValuePositions()
    }

    private func setupCenterLabel() {
        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        centerLabel.textAlignment = .center
        centerLabel.textColor = .green
        addSubview(centerLabel)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        layer.sublayers?.removeAll(where: { $0.name == "gradientCurve" })

        guard let context = UIGraphicsGetCurrentContext() else { return }

        let center = CGPoint(x: bounds.midX - 20, y: bounds.midY)
        let curveRadius: CGFloat = radius + 40
        let lineWidth: CGFloat = 1.0

        let startAngle: CGFloat = -.pi / 1.40
        let endAngle: CGFloat = -.pi / 3.15

        let curvePath = UIBezierPath(
            arcCenter: center,
            radius: curveRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        context.setLineWidth(lineWidth)
        UIColor.lightGray.setStroke()
        context.addPath(curvePath.cgPath)
        context.strokePath()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = curvePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .butt

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.lightGray.withAlphaComponent(0.5).cgColor,
            UIColor.white.cgColor,
            UIColor.lightGray.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = shapeLayer
        gradientLayer.name = "gradientCurve"
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0 && bounds.height > 0 else { return }
        centerLabel.frame = CGRect(x: (bounds.width - 100) / 2, y: (bounds.height - 50) / 2, width: 100, height: 50)
        updateValuePositions()
    }

    private func updateValuePositions() {
        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }

        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude

        for (index, value) in values.enumerated() {
            let angle = anglePerItem * CGFloat(index) + rotationAngle
            let label = createValueLabel(text: value)

            let position = CGPoint(
                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
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
        closestLabel?.textColor = .darkGray
        closestLabel?.font = UIFont.boldSystemFont(ofSize: 20)

        updateSelectedValue()
    }

    private func createValueLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.textColor = .red
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 20) // Adjust size as needed
        return label
    }

    private func updateSelectedValue() {
        let normalizedAngle = fmod(rotationAngle + (anglePerItem / 2), 2 * .pi)
        let selectedIndex = Int(round(normalizedAngle / anglePerItem)) % values.count
        selectedValue = values[(selectedIndex + values.count) % values.count]
        print("Selected Value: \(selectedValue ?? "")") // Print or use selectedValue
    }

    // MARK: - Touch Handling

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

        UIView.animate(withDuration: 0.2, animations: {
            self.updateValuePositions()
        })

        sendActions(for: .valueChanged)
    }

    private func angleForPoint(_ point: CGPoint) -> CGFloat {
        let dx = point.x - bounds.midX
        let dy = point.y - bounds.midY
        return atan2(dy, dx)
    }
}
*/


//______--------------##############


/*
//MARK: ---------------ITS WORKING FINE

class CircularMonthPicker: UIControl {
    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(months.count) }
    
    var closestLabel: UILabel?
    private var radius: CGFloat = 120
    private var rotationAngle: CGFloat = -90 //0
    
    public let centerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupCenterLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCenterLabel()
    }
    
    private func setupCenterLabel() {
        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        centerLabel.textAlignment = .center
        centerLabel.textColor = .green
        addSubview(centerLabel)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.sublayers?.removeAll(where: { $0.name == "gradientCurve" })
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let curveRadius: CGFloat = radius + 30  // Curve slightly outside the month labels
      
        let curveRadius: CGFloat = radius + 40  // Curve slightly outside the month
        let lineWidth: CGFloat = 1.0
        
        // Define the start and end angles for the curve (top center arc)
//        let startAngle: CGFloat = -.pi / 1.15   // Adjust for desired curve length
//        let endAngle: CGFloat = -.pi / 2.85     // Adjust for desired curve length
        
        let startAngle: CGFloat = -.pi / 1.40   // Adjust for desired curve length
        let endAngle: CGFloat = -.pi / 3.15    // Adjust for desired curve length
        
        // Create the curved path
        let curvePath = UIBezierPath(
            arcCenter: center,
            radius: curveRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        // Set curve properties
        context.setLineWidth(lineWidth)
        UIColor.lightGray.setStroke()  // Curve color
        context.addPath(curvePath.cgPath)
        
        context.strokePath()
        
        // Create shape layer for the curve
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = curvePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .butt //.round
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.lightGray.withAlphaComponent(0.5).cgColor,
            UIColor.white.cgColor,
            UIColor.lightGray.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = shapeLayer
        gradientLayer.name = "gradientCurve" // For cleanup when redrawing

        // Add the gradient layer to the view
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Guard against invalid size
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        // Center label correctly
        centerLabel.frame = CGRect(x: (bounds.width - 100) / 2, y: (bounds.height - 50) / 2, width: 100, height: 50)
        
        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        centerLabel.textAlignment = .center
        centerLabel.textColor = .green
        // Update month positions
        updateMonthPositions()
        
    }
    
    
    private func updateMonthPositions() {
        // Remove all month labels but keep the centerLabel
        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
        
        //        var closestLabel: UILabel?
        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude
        
        for (index, month) in months.enumerated() {
            let angle = anglePerItem * CGFloat(index) + rotationAngle
            let label = createMonthLabel(text: month)
            
            let position = CGPoint(
                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
            )
            label.center = position
            addSubview(label)
            
            // Determine which label is closest to the top (-π/2)
            let angleDifference = abs(angle.truncatingRemainder(dividingBy: 2 * .pi) - (-.pi / 2))
            if angleDifference < smallestAngleDifference {
                smallestAngleDifference = angleDifference
                closestLabel = label
            }
        }
        
        // Highlight the center-top month
        centerLabel.text = closestLabel?.text
        closestLabel?.textColor = .darkGray
        closestLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        updateSelectedMonth()
    }
    
    
    private func createMonthLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .red
        label.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        return label
    }
    
    private func updateSelectedMonth() {
        let normalizedAngle = fmod(rotationAngle + (anglePerItem / 2), 2 * .pi)
        let selectedIndex = Int(round(normalizedAngle / anglePerItem)) % months.count
        //        centerLabel.text = months[(selectedIndex + months.count) % months.count] // Handle negative index
    }
    
    // MARK: - Touch Handling
    
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
        
        updateMonthPositions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestMonth()
    }
    
    private func snapToNearestMonth() {
        let nearestIndex = Int(round(rotationAngle / anglePerItem))
        rotationAngle = CGFloat(nearestIndex) * anglePerItem
        
        UIView.animate(withDuration: 0.2, animations: {
            self.updateMonthPositions()
        })
        
        sendActions(for: .valueChanged)
    }
    
    private func angleForPoint(_ point: CGPoint) -> CGFloat {
        let dx = point.x - bounds.midX
        let dy = point.y - bounds.midY
        return atan2(dy, dx)
    }
}
*/


/*
class CircularMonthPicker: UIControl {
    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(months.count) }
    
    var closestLabel: UILabel?
    private var radius: CGFloat = 120
    private var rotationAngle: CGFloat = -90 //0
    
    public let centerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupCenterLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCenterLabel()
    }
    
    private func setupCenterLabel() {
        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        centerLabel.textAlignment = .center
        centerLabel.textColor = .green
        addSubview(centerLabel)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.sublayers?.removeAll(where: { $0.name == "gradientCurve" })
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let curveRadius: CGFloat = radius + 30  // Curve slightly outside the month labels
      
        let curveRadius: CGFloat = radius + 40  // Curve slightly outside the month
        let lineWidth: CGFloat = 1.0
        
        // Define the start and end angles for the curve (top center arc)
//        let startAngle: CGFloat = -.pi / 1.15   // Adjust for desired curve length
//        let endAngle: CGFloat = -.pi / 2.85     // Adjust for desired curve length
        
        let startAngle: CGFloat = -.pi / 1.50   // Adjust for desired curve length
        let endAngle: CGFloat = -.pi / 3.0    // Adjust for desired curve length
        
        // Create the curved path
        let curvePath = UIBezierPath(
            arcCenter: center,
            radius: curveRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        // Set curve properties
        context.setLineWidth(lineWidth)
        UIColor.lightGray.setStroke()  // Curve color
        context.addPath(curvePath.cgPath)
        
        context.strokePath()
        
        // Create shape layer for the curve
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = curvePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.lightGray.withAlphaComponent(0.5).cgColor,
            UIColor.white.cgColor,
            UIColor.lightGray.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = shapeLayer
        gradientLayer.name = "gradientCurve" // For cleanup when redrawing

        // Add the gradient layer to the view
        layer.addSublayer(gradientLayer)
    }

    
//    private func addGradientCurve() {
//        // Remove existing gradient layers if re-drawing
//        layer.sublayers?.removeAll(where: { $0.name == "gradientCurve" })
//
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let curveRadius: CGFloat = radius + 30  // Slightly outside the month labels
//        
//        // Define the curved path
//        let startAngle: CGFloat = -.pi / 1.50
//        let endAngle: CGFloat = -.pi / 2.85
//        let curvePath = UIBezierPath(
//            arcCenter: center,
//            radius: curveRadius,
//            startAngle: startAngle,
//            endAngle: endAngle,
//            clockwise: true
//        )
//        
//        // Create shape layer for the curve
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = curvePath.cgPath
//        shapeLayer.strokeColor = UIColor.black.cgColor
//        shapeLayer.lineWidth = 5
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineCap = .round
//        
//        // Create gradient layer
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = bounds
//        gradientLayer.colors = [
//            UIColor.systemPink.cgColor,
//            UIColor.systemOrange.cgColor,
//            UIColor.systemYellow.cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
//        gradientLayer.mask = shapeLayer
//        gradientLayer.name = "gradientCurve" // For cleanup when redrawing
//
//        // Add the gradient layer to the view
//        layer.addSublayer(gradientLayer)
//    }

    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()

        // Guard against invalid size
        guard bounds.width > 0 && bounds.height > 0 else { return }

        // Center label correctly
        centerLabel.frame = CGRect(x: (bounds.width - 100) / 2, y: (bounds.height - 50) / 2, width: 100, height: 50)
        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        centerLabel.textAlignment = .center
        centerLabel.textColor = .green
        
        // Ensure rotationAngle starts at the top-center
        rotationAngle = -(.pi / 2)
        
        // Update month positions after setting rotation angle
        updateMonthPositions()
    }
*/
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Guard against invalid size
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        // Center label correctly
        centerLabel.frame = CGRect(x: (bounds.width - 100) / 2, y: (bounds.height - 50) / 2, width: 100, height: 50)
        
        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        centerLabel.textAlignment = .center
        centerLabel.textColor = .green
        // Update month positions
        updateMonthPositions()
        
//        addGradientCurve() // Draw the gradient curve
    }
    
    
    
    //    private func updateMonthPositions() {
    //        // Remove all month labels but keep the centerLabel
    //        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
    //
    //        for (index, month) in months.enumerated() {
    //            let angle = anglePerItem * CGFloat(index) + rotationAngle
    //            let label = createMonthLabel(text: month)
    //
    //            let position = CGPoint(
    //                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
    //                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
    //            )
    //
    //            label.center = position
    //            addSubview(label)
    //        }
    //
    //        updateSelectedMonth()
    //    }
    
    private func updateMonthPositions() {
        // Remove all month labels but keep the centerLabel
        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
        
        //        var closestLabel: UILabel?
        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude
        
        for (index, month) in months.enumerated() {
            let angle = anglePerItem * CGFloat(index) + rotationAngle
            let label = createMonthLabel(text: month)
            
            let position = CGPoint(
                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
            )
            label.center = position
            addSubview(label)
            
            // Determine which label is closest to the top (-π/2)
            let angleDifference = abs(angle.truncatingRemainder(dividingBy: 2 * .pi) - (-.pi / 2))
            if angleDifference < smallestAngleDifference {
                smallestAngleDifference = angleDifference
                closestLabel = label
            }
        }
        
        // Highlight the center-top month
        centerLabel.text = closestLabel?.text
        closestLabel?.textColor = .darkGray
        closestLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        updateSelectedMonth()
    }
    
    
    private func createMonthLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .red
        label.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        return label
    }
    
    private func updateSelectedMonth() {
        let normalizedAngle = fmod(rotationAngle + (anglePerItem / 2), 2 * .pi)
        let selectedIndex = Int(round(normalizedAngle / anglePerItem)) % months.count
        //        centerLabel.text = months[(selectedIndex + months.count) % months.count] // Handle negative index
    }
    
    // MARK: - Touch Handling
    
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
        
        updateMonthPositions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestMonth()
    }
    
    private func snapToNearestMonth() {
        let nearestIndex = Int(round(rotationAngle / anglePerItem))
        rotationAngle = CGFloat(nearestIndex) * anglePerItem
        
        UIView.animate(withDuration: 0.2, animations: {
            self.updateMonthPositions()
        })
        
        sendActions(for: .valueChanged)
    }
    
    private func angleForPoint(_ point: CGPoint) -> CGFloat {
        let dx = point.x - bounds.midX
        let dy = point.y - bounds.midY
        return atan2(dy, dx)
    }
}
*/


/*
class CircularPicker: UIControl {
    private var items: [String]
    private var radius: CGFloat
    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(items.count) }

    private var closestLabel: UILabel?
    private var rotationAngle: CGFloat = -.pi / 2 // Start from the top
    private let centerLabel = UILabel()

    // MARK: - Styling Properties (New)
    public var itemFont: UIFont = UIFont.systemFont(ofSize: 14)
    public var selectedItemFont: UIFont = UIFont.boldSystemFont(ofSize: 18)
    public var itemColor: UIColor = .gray
    public var selectedItemColor: UIColor = .darkGray
    public var centerLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 20)
    public var centerLabelColor: UIColor = .black
    public var showCenterLabel: Bool = true {
        didSet {
            centerLabel.isHidden = !showCenterLabel
        }
    }

    init(frame: CGRect, items: [String], radius: CGFloat) {
        self.items = items
        self.radius = radius
        super.init(frame: frame)
        backgroundColor = .clear
        setupCenterLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCenterLabel() {
        centerLabel.font = centerLabelFont
        centerLabel.textAlignment = .center
        centerLabel.textColor = centerLabelColor
        centerLabel.isHidden = !showCenterLabel
        addSubview(centerLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        centerLabel.frame = CGRect(x: (bounds.width - 80) / 2, y: (bounds.height - 40) / 2, width: 80, height: 40)
        updateItemPositions()
    }

    private func updateItemPositions() {
        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }

        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude

        for (index, item) in items.enumerated() {
            let angle = anglePerItem * CGFloat(index) + rotationAngle
            let label = createItemLabel(text: item)

            let position = CGPoint(
                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
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

        // Apply Styling
        subviews.filter { $0 != centerLabel }.forEach {
            let label = $0 as! UILabel
            if label == closestLabel {
                label.font = selectedItemFont
                label.textColor = selectedItemColor
            } else {
                label.font = itemFont
                label.textColor = itemColor
            }
        }

        sendActions(for: .valueChanged)
    }

    private func createItemLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = itemFont // Initial font
        label.textAlignment = .center
        label.textColor = itemColor // Initial color
        label.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        return label
    }


    // MARK: - Touch Handling (Modified for smoother scrolling)
    private var lastTouchLocation: CGPoint = .zero

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchLocation = touch.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentLocation = touch.location(in: self)

        let deltaX = currentLocation.x - lastTouchLocation.x
        // Convert deltaX to angle change (adjust sensitivity as needed)
        let angleChange = deltaX / (radius * 2) * 2 * .pi  // Proportional to circumference

        rotationAngle -= angleChange // Subtract for correct direction
        updateItemPositions()

        lastTouchLocation = currentLocation // Update for next move calculation
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestItem()
    }

    private func snapToNearestItem() {
        let offset = (rotationAngle + (.pi / 2)).truncatingRemainder(dividingBy: 2 * .pi)
        let nearestIndex = Int(round(offset / anglePerItem)) % items.count
        rotationAngle = CGFloat(nearestIndex) * anglePerItem - (.pi / 2)

        UIView.animate(withDuration: 0.2) {
            self.updateItemPositions()
        }
    }

    private func angleForPoint(_ point: CGPoint) -> CGFloat {
        let dx = point.x - bounds.midX
        let dy = point.y - bounds.midY
        return atan2(dy, dx)
    }

    func selectedItem() -> String {
        return closestLabel?.text ?? ""
    }
}

*/


//class CircularPicker: UIControl {
//    private var items: [String]
//    public var radius: CGFloat
//    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(items.count) }
//
//    private var closestLabel: UILabel?
//    private var rotationAngle: CGFloat = -90 // Start from the top
//    private let centerLabel = UILabel()
//
//    // MARK: - Styling Properties
//    public var itemFont: UIFont = UIFont.systemFont(ofSize: 14)
//    public var selectedItemFont: UIFont = UIFont.boldSystemFont(ofSize: 18)
//    public var itemColor: UIColor = .gray
//    public var selectedItemColor: UIColor = .darkGray
//    public var centerLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 20)
//    public var centerLabelColor: UIColor = .black
//    public var showCenterLabel: Bool = true {
//        didSet {
//            centerLabel.isHidden = !showCenterLabel
//        }
//    }
//    public var curveColor: UIColor = .lightGray
//    public var gradientColors: [CGColor] = [
//        UIColor.lightGray.cgColor,
//        UIColor.white.cgColor,
//        UIColor.lightGray.cgColor
//    ]
//
//    init(frame: CGRect, items: [String], radius: CGFloat) {
//        self.items = items
//        self.radius = radius
//        super.init(frame: frame)
//        backgroundColor = .clear
//        setupCenterLabel()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//        layer.sublayers?.filter { $0.name == "gradientCurve" }.forEach { $0.removeFromSuperlayer() }
//
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let curveRadius: CGFloat = radius + 40
//        let lineWidth: CGFloat = 1.0
//
//        let startAngle: CGFloat = -.pi / 1.50
//        let endAngle: CGFloat = -.pi / 3.0
//
//        let curvePath = UIBezierPath(
//            arcCenter: center,
//            radius: curveRadius,
//            startAngle: startAngle,
//            endAngle: endAngle,
//            clockwise: true
//        )
//
//        context.setLineWidth(lineWidth)
//        curveColor.setStroke()
//        context.addPath(curvePath.cgPath)
//        context.strokePath()
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = curvePath.cgPath
//        shapeLayer.strokeColor = UIColor.white.cgColor
//        shapeLayer.lineWidth = 1.5
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineCap = .round
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = bounds
//        gradientLayer.colors = gradientColors
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        gradientLayer.mask = shapeLayer
//        gradientLayer.name = "gradientCurve"
//
//        layer.addSublayer(gradientLayer)
//    }
//
//    private func setupCenterLabel() {
//        centerLabel.font = centerLabelFont
//        centerLabel.textAlignment = .center
//        centerLabel.textColor = centerLabelColor
//        centerLabel.isHidden = !showCenterLabel
//        addSubview(centerLabel)
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        centerLabel.frame = CGRect(x: (bounds.width - 80) / 2, y: (bounds.height - 40) / 2, width: 80, height: 40)
//        updateItemPositions()
//    }
//
//    private func updateItemPositions() {
//        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
//
//        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude
//
//        for (index, item) in items.enumerated() {
//            let angle = anglePerItem * CGFloat(index) + rotationAngle
//            let label = createItemLabel(text: item)
//
//            let position = CGPoint(
//                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
//                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
//            )
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
//
//        subviews.filter { $0 != centerLabel }.forEach {
//            let label = $0 as! UILabel
//            if label == closestLabel {
//                label.font = selectedItemFont
//                label.textColor = selectedItemColor
//            } else {
//                label.font = itemFont
//                label.textColor = itemColor
//            }
//        }
//
//        sendActions(for: .valueChanged)
//    }
//
//    private func createItemLabel(text: String) -> UILabel {
//        let label = UILabel()
//        label.text = text
//        label.font = itemFont
//        label.textAlignment = .center
//        label.textColor = itemColor
//        label.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
//        return label
//    }
//
//    // MARK: - Touch Handling (Smoother Scrolling)
//    private var lastTouchLocation: CGPoint = .zero
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        lastTouchLocation = touch.location(in: self)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let currentLocation = touch.location(in: self)
//
//        let deltaX = currentLocation.x - lastTouchLocation.x
//        let angleChange = deltaX / (radius * 2) * 2 * .pi
//
//        rotationAngle -= angleChange
//        updateItemPositions()
//
//        lastTouchLocation = currentLocation
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        snapToNearestItem()
//    }
//
//    private func snapToNearestItem() {
//        let offset = (rotationAngle + (.pi / 2)).truncatingRemainder(dividingBy: 2 * .pi)
//        let nearestIndex = Int(round(offset / anglePerItem)) % items.count
//        rotationAngle = CGFloat(nearestIndex) * anglePerItem - (.pi / 2)
//
//        UIView.animate(withDuration: 0.2) {
//            self.updateItemPositions()
//        }
//    }
//
//    private func angleForPoint(_ point: CGPoint) -> CGFloat {
//        let dx = point.x - bounds.midX
//        let dy = point.y - bounds.midY
//        return atan2(dy, dx)
//    }
//
//    func selectedItem() -> String {
//        return closestLabel?.text ?? ""
//    }
//}


//class DatePickerView: UIView {
//    private var monthPicker: CircularPicker!
//
//    private var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupPickers()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupPickers()
//    }
//
//    override var intrinsicContentSize: CGSize {
//        let diameter = monthPicker.radius * 2 + 80 // Padding for curve
//        return CGSize(width: diameter, height: diameter)
//    }
//
//
//    private func setupPickers() {
//        let monthRadius: CGFloat = 100
//
//        monthPicker = CircularPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 250), items: months, radius: monthRadius)
//
//        monthPicker.center = CGPoint(x: bounds.midX, y: bounds.midY)
//        addSubview(monthPicker)
//
//        monthPicker.addTarget(self, action: #selector(monthChanged), for: .valueChanged)
//    }
//
//    @objc private func monthChanged() {
//        print("Month selected: \(monthPicker.selectedItem())")
//    }
//}


/*
class CircularPicker: UIControl {
    private var items: [String]
    private var radius: CGFloat
    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(items.count) }
    
    private var closestLabel: UILabel?
    private var rotationAngle: CGFloat = -90 //-.pi / 2  // Start from the top
    private let centerLabel = UILabel()
    
    init(frame: CGRect, items: [String], radius: CGFloat) {
        self.items = items
        self.radius = radius
        super.init(frame: frame)
        backgroundColor = .clear
        setupCenterLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.sublayers?.removeAll(where: { $0.name == "gradientCurve" })
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let curveRadius: CGFloat = radius + 30  // Curve slightly outside the month labels
      
        let curveRadius: CGFloat = radius + 40  // Curve slightly outside the month
        let lineWidth: CGFloat = 1.0
        
        // Define the start and end angles for the curve (top center arc)
//        let startAngle: CGFloat = -.pi / 1.15   // Adjust for desired curve length
//        let endAngle: CGFloat = -.pi / 2.85     // Adjust for desired curve length
        
        let startAngle: CGFloat = -.pi / 1.50   // Adjust for desired curve length
        let endAngle: CGFloat = -.pi / 3.0    // Adjust for desired curve length
        
        // Create the curved path
        let curvePath = UIBezierPath(
            arcCenter: center,
            radius: curveRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        // Set curve properties
        context.setLineWidth(lineWidth)
        UIColor.lightGray.setStroke()  // Curve color
        context.addPath(curvePath.cgPath)
        
        context.strokePath()
        
        // Create shape layer for the curve
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = curvePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.lightGray.withAlphaComponent(0.5).cgColor,
            UIColor.white.cgColor,
            UIColor.lightGray.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = shapeLayer
        gradientLayer.name = "gradientCurve" // For cleanup when redrawing

        // Add the gradient layer to the view
        layer.addSublayer(gradientLayer)
    }
    
    private func setupCenterLabel() {
        centerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        centerLabel.textAlignment = .center
        centerLabel.textColor = .black
        centerLabel.isHidden = true
        addSubview(centerLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerLabel.frame = CGRect(x: (bounds.width - 80) / 2, y: (bounds.height - 40) / 2, width: 80, height: 40)
        updateItemPositions()
    }
    
    private func updateItemPositions() {
        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
        
        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude
        
        for (index, item) in items.enumerated() {
            let angle = anglePerItem * CGFloat(index) + rotationAngle
            let label = createItemLabel(text: item)
            
            let position = CGPoint(
                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
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
        closestLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closestLabel?.textColor = .darkGray
        
        sendActions(for: .valueChanged)
    }
    
    private func createItemLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .gray
        label.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        return label
    }
    
    // MARK: - Touch Handling
    private var lastTouchAngle: CGFloat = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchAngle = angleForPoint(touch.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentAngle = angleForPoint(touch.location(in: self))
        rotationAngle += currentAngle - lastTouchAngle
        lastTouchAngle = currentAngle
        updateItemPositions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestItem()
    }
    
    private func snapToNearestItem() {
        let offset = (rotationAngle + (.pi / 2)).truncatingRemainder(dividingBy: 2 * .pi)
        let nearestIndex = Int(round(offset / anglePerItem)) % items.count
        rotationAngle = CGFloat(nearestIndex) * anglePerItem - (.pi / 2)
        
        UIView.animate(withDuration: 0.2) {
            self.updateItemPositions()
        }
    }
    
    private func angleForPoint(_ point: CGPoint) -> CGFloat {
        let dx = point.x - bounds.midX
        let dy = point.y - bounds.midY
        return atan2(dy, dx)
    }
    
    func selectedItem() -> String {
        return closestLabel?.text ?? ""
    }
}


class DatePickerView: UIView {
    private var monthPicker: CircularPicker!
//    private var dayPicker: CircularPicker!
//    private var yearPicker: CircularPicker!

    private var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    private var days = Array(1...31).map { "\($0)" }
    private var years = Array(2020...2030).map { "\($0)" }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPickers()
    }

    private func setupPickers() {
        let monthRadius: CGFloat = 100
        let dayRadius: CGFloat = 120
        let yearRadius: CGFloat = 160

        monthPicker = CircularPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 250), items: days, radius: monthRadius)
        
//        dayPicker = CircularPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300), items: days, radius: dayRadius)
//        yearPicker = CircularPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300), items: years, radius: yearRadius)

        // Center the pickers but position them on different radii
        monthPicker.center = CGPoint(x: bounds.midX, y: bounds.midY)
//        dayPicker.center = CGPoint(x: bounds.midX, y: bounds.midY)
//        yearPicker.center = CGPoint(x: bounds.midX, y: bounds.midY)

        // Add each picker as a subview
        addSubview(monthPicker)
//        addSubview(dayPicker)
//        addSubview(yearPicker)

        // Add targets to observe value changes
        monthPicker.addTarget(self, action: #selector(monthChanged), for: .valueChanged)
//        dayPicker.addTarget(self, action: #selector(dayChanged), for: .valueChanged)
//        yearPicker.addTarget(self, action: #selector(yearChanged), for: .valueChanged)
    }

    @objc private func monthChanged() {
        print("Month selected: \(monthPicker.selectedItem())")
    }

//    @objc private func dayChanged() {
//        print("Day selected: \(dayPicker.selectedItem())")
//    }
//
//    @objc private func yearChanged() {
//        print("Year selected: \(yearPicker.selectedItem())")
//    }
}

*/

// MARK: - CircularPicker Class
//class CircularPicker: UIControl {
//    private var items: [String]
//    private var radius: CGFloat
//    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(items.count) }
//
//    private var closestLabel: UILabel?
//    private var rotationAngle: CGFloat = -.pi / 2  // Start from the top
//    private let centerLabel = UILabel()
//
//    init(frame: CGRect, items: [String], radius: CGFloat) {
//        self.items = items
//        self.radius = radius
//        super.init(frame: frame)
//        backgroundColor = .clear
//        setupCenterLabel()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupCenterLabel() {
//        centerLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        centerLabel.textAlignment = .center
//        centerLabel.textColor = .black
//        centerLabel.isHidden = true
//        addSubview(centerLabel)
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        centerLabel.frame = CGRect(x: (bounds.width - 80) / 2, y: (bounds.height - 40) / 2, width: 80, height: 40)
//        updateItemPositions()
//    }
//
//    private func updateItemPositions() {
//        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
//
//        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude
//
//        for (index, item) in items.enumerated() {
//            let angle = anglePerItem * CGFloat(index) + rotationAngle
//            let label = createItemLabel(text: item)
//
//            let position = CGPoint(
//                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
//                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
//            )
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
//        closestLabel?.font = UIFont.boldSystemFont(ofSize: 18)
//        closestLabel?.textColor = .darkGray
//
//        sendActions(for: .valueChanged)
//    }
//
//    private func createItemLabel(text: String) -> UILabel {
//        let label = UILabel()
//        label.text = text
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textAlignment = .center
//        label.textColor = .gray
//        label.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
//        return label
//    }
//
//    // MARK: - Touch Handling
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
//        rotationAngle += currentAngle - lastTouchAngle
//        lastTouchAngle = currentAngle
//        updateItemPositions()
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        snapToNearestItem()
//    }
//
//    private func snapToNearestItem() {
//        let offset = (rotationAngle + (.pi / 2)).truncatingRemainder(dividingBy: 2 * .pi)
//        let nearestIndex = Int(round(offset / anglePerItem)) % items.count
//        rotationAngle = CGFloat(nearestIndex) * anglePerItem - (.pi / 2)
//
//        UIView.animate(withDuration: 0.2) {
//            self.updateItemPositions()
//        }
//    }
//
//    private func angleForPoint(_ point: CGPoint) -> CGFloat {
//        let dx = point.x - bounds.midX
//        let dy = point.y - bounds.midY
//        return atan2(dy, dx)
//    }
//}

//class DatePickerView: UIView {
//    private var monthPicker: CircularPicker!
//    private var dayPicker: CircularPicker!
//    private var yearPicker: CircularPicker!
//
//    private var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
//    private var days = Array(1...31).map { "\($0)" }
//    private var years = Array(2020...2030).map { "\($0)" }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupPickers()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupPickers()
//    }
//
//    private func setupPickers() {
//        // Adjust radii to create spacing between the pickers
//        let monthRadius: CGFloat = 80
//        let dayRadius: CGFloat = 120
//        let yearRadius: CGFloat = 160
//
//        // Create CircularPicker instances for each
//        dayPicker = CircularPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 200), items: days, radius: dayRadius)
//        monthPicker = CircularPicker(frame: CGRect(x: 0, y: dayPicker.frame.origin.y + dayPicker.frame.size.height, width: 300, height: 80), items: months, radius: monthRadius)
////        dayPicker = CircularPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 250), items: days, radius: dayRadius)
//        yearPicker = CircularPicker(frame: CGRect(x: 0, y: monthPicker.frame.origin.y + monthPicker.frame.size.height, width: 300, height: 80), items: years, radius: yearRadius)
//
//        // Center all pickers on the same point but with different radii for spacing
//        monthPicker.center = CGPoint(x: bounds.midX, y: bounds.midY)
//        dayPicker.center = CGPoint(x: bounds.midX, y: bounds.midY)
//        yearPicker.center = CGPoint(x: bounds.midX, y: bounds.midY)
//
//        // Add each picker as a subview
//        addSubview(yearPicker)
//        addSubview(monthPicker)
//        addSubview(dayPicker)
////        addSubview(yearPicker)
//
//        // Optional: Add observers to update the values when a selection is made
//        monthPicker.addTarget(self, action: #selector(monthChanged), for: .valueChanged)
//        dayPicker.addTarget(self, action: #selector(dayChanged), for: .valueChanged)
//        yearPicker.addTarget(self, action: #selector(yearChanged), for: .valueChanged)
//    }
//
//    @objc private func monthChanged() {
//        print("Month selected: \(monthPicker)")
//    }
//
//    @objc private func dayChanged() {
//        print("Day selected: \(dayPicker)")
//    }
//
//    @objc private func yearChanged() {
//        print("Year selected: \(yearPicker)")
//    }
//}



//class DatePickerView: UIView {
//    private var monthPicker: CircularPicker!
//    private var dayPicker: CircularPicker!
//    private var yearPicker: CircularPicker!
//
//    private var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
//    private var days = Array(1...31).map { "\($0)" }
//    private var years = Array(2020...2030).map { "\($0)" }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupPickers()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupPickers()
//    }
//
//    private func setupPickers() {
//        let pickerRadius: CGFloat = 100
//
//        monthPicker = CircularPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 200), items: months, radius: pickerRadius)
//        dayPicker = CircularPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 300), items: days, radius: pickerRadius)
//        yearPicker = CircularPicker(frame: CGRect(x: 0, y: 0, width: 300, height: 380), items: years, radius: pickerRadius)
//
////        monthPicker.center = CGPoint(x: bounds.midX, y: bounds.midY - 120)
////        dayPicker.center = CGPoint(x: bounds.midX, y: bounds.midY)
////        yearPicker.center = CGPoint(x: bounds.midX, y: bounds.midY + 120)
//
//        addSubview(monthPicker)
//        addSubview(dayPicker)
//        addSubview(yearPicker)
//
//        // Optional: Add observers to update the values when a selection is made
//        monthPicker.addTarget(self, action: #selector(monthChanged), for: .valueChanged)
//        dayPicker.addTarget(self, action: #selector(dayChanged), for: .valueChanged)
//        yearPicker.addTarget(self, action: #selector(yearChanged), for: .valueChanged)
//    }
//
//    @objc private func monthChanged() {
//        print("Month selected: \(monthPicker)")
//    }
//
//    @objc private func dayChanged() {
//        print("Day selected: \(dayPicker)")
//    }
//
//    @objc private func yearChanged() {
//        print("Year selected: \(yearPicker)")
//    }
//}


// MARK: - DatePickerView with Month, Day, Year
//class DatePickerView: UIView {
//    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//    private let days = (1...31).map { "\($0)" }
//    private let years = (1900...2100).map { "\($0)" }
//
//    private let monthPicker: CircularPicker
//    private let dayPicker: CircularPicker
////    private let yearPicker: CircularPicker
//
//    override init(frame: CGRect) {
//        monthPicker = CircularPicker(frame: frame, items: months, radius: 80)
//        dayPicker = CircularPicker(frame: frame, items: days, radius: 120)
////        yearPicker = CircularPicker(frame: frame, items: years, radius: 160)
//
//        super.init(frame: frame)
//
//        // Add in correct z-order: year (bottom), day (middle), month (top)
////        addSubview(yearPicker)
//        addSubview(dayPicker)
//        addSubview(monthPicker)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        monthPicker.frame = bounds
//        dayPicker.frame = bounds
////        yearPicker.frame = bounds
//    }
//}



/*
// Generic Circular Picker Class
class CircularPicker: UIControl {
    private var items: [String]
    private var radius: CGFloat
    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(items.count) }
    
    private var closestLabel: UILabel?
    private var rotationAngle: CGFloat = -90
    private let centerLabel = UILabel()
    
    init(frame: CGRect, items: [String], radius: CGFloat) {
        self.items = items
        self.radius = radius
        super.init(frame: frame)
        backgroundColor = .clear
        setupCenterLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCenterLabel() {
        centerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        centerLabel.textAlignment = .center
        centerLabel.textColor = .black
        addSubview(centerLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerLabel.frame = CGRect(x: (bounds.width - 80) / 2, y: (bounds.height - 40) / 2, width: 80, height: 40)
        updateItemPositions()
    }
    
    private func updateItemPositions() {
        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
        
        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude
        
        for (index, item) in items.enumerated() {
            let angle = anglePerItem * CGFloat(index) + rotationAngle
            let label = createItemLabel(text: item)
            
            let position = CGPoint(
                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
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
        closestLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closestLabel?.textColor = .darkGray
        
        sendActions(for: .valueChanged)
    }
    
    private func createItemLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .gray
        label.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        return label
    }
    
    // MARK: - Touch Handling
    private var lastTouchAngle: CGFloat = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastTouchAngle = angleForPoint(touch.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentAngle = angleForPoint(touch.location(in: self))
        rotationAngle += currentAngle - lastTouchAngle
        lastTouchAngle = currentAngle
        updateItemPositions()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        snapToNearestItem()
    }
    
    private func snapToNearestItem() {
        let nearestIndex = Int(round(rotationAngle / anglePerItem)) % items.count
        rotationAngle = CGFloat(nearestIndex) * anglePerItem
        
        UIView.animate(withDuration: 0.2) {
            self.updateItemPositions()
        }
    }
    
    private func angleForPoint(_ point: CGPoint) -> CGFloat {
        let dx = point.x - bounds.midX
        let dy = point.y - bounds.midY
        return atan2(dy, dx)
    }
}


class DatePickerView: UIView {
    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private let days = (1...31).map { "\($0)" }
    private let years = (1900...2100).map { "\($0)" }

    // Adjusted Radii
    private let monthPicker: CircularPicker
    private let dayPicker: CircularPicker
    private let yearPicker: CircularPicker

    override init(frame: CGRect) {
        // Adjust the radii to create spacing between layers
        monthPicker = CircularPicker(frame: frame, items: months, radius: 80)
        dayPicker = CircularPicker(frame: frame, items: days, radius: 120)
        yearPicker = CircularPicker(frame: frame, items: years, radius: 190)

        super.init(frame: frame)

        // Add layers in the correct order: year (bottom), day (middle), month (top)
        addSubview(yearPicker)
        addSubview(dayPicker)
        addSubview(monthPicker)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        monthPicker.frame = bounds
        dayPicker.frame = bounds
        yearPicker.frame = bounds
    }
}

*/


/*
// DatePickerView with Month, Day, Year
class DatePickerView: UIView {
    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private let days = (1...31).map { "\($0)" }
    private let years = (1900...2100).map { "\($0)" }

    private let monthPicker: CircularPicker
    private let dayPicker: CircularPicker
    private let yearPicker: CircularPicker

    override init(frame: CGRect) {
        monthPicker = CircularPicker(frame: frame, items: months, radius: 80)
        dayPicker = CircularPicker(frame: frame, items: days, radius: 120) //140
        yearPicker = CircularPicker(frame: frame, items: years, radius: 160)

        super.init(frame: frame)

        addSubview(yearPicker)
        addSubview(dayPicker)
        addSubview(monthPicker)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        monthPicker.frame = bounds
        dayPicker.frame = bounds
        yearPicker.frame = bounds
    }
}

*/



//class CircularMonthPicker: UIControl {
//    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//    private var anglePerItem: CGFloat { return (2 * .pi) / CGFloat(months.count) }
//
//    var closestLabel: UILabel?
//    private var radius: CGFloat = 120
//    private var rotationAngle: CGFloat = -(.pi / 2) // 0
//
//    public let centerLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .clear
//        setupCenterLabel()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupCenterLabel()
//    }
//
//    private func setupCenterLabel() {
//        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
//        centerLabel.textAlignment = .center
//        centerLabel.textColor = .green
//        addSubview(centerLabel)
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        // Guard against invalid size
//        guard bounds.width > 0 && bounds.height > 0 else { return }
//
//        // Center label correctly
//        centerLabel.frame = CGRect(x: (bounds.width - 100) / 2, y: (bounds.height - 50) / 2, width: 100, height: 50)
//        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
//        centerLabel.textAlignment = .center
//        centerLabel.textColor = .green
//
//        // Ensure rotationAngle starts at the top-center
////        rotationAngle = -(.pi / 2)
//
//        // Update month positions after setting rotation angle
//        updateMonthPositions()
//    }
//
//
//    private func updateMonthPositions() {
//        // Remove all month labels but keep the centerLabel
//        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
//
//        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude
//        closestLabel = nil
//
//        for (index, month) in months.enumerated() {
//            let angle = anglePerItem * CGFloat(index) + rotationAngle
//            let label = createMonthLabel(text: month)
//
//            let position = CGPoint(
//                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
//                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
//            )
//            label.center = position
//            addSubview(label)
//
//            // Determine which label is closest to the top (-π/2)
//            let angleDifference = abs(angle.truncatingRemainder(dividingBy: 2 * .pi) - (-.pi / 2))
//            if angleDifference < smallestAngleDifference {
//                smallestAngleDifference = angleDifference
//                closestLabel = label
//            }
//        }
//
//        // Update the center label and highlight the selected month
//        if let closestLabel = closestLabel {
//            centerLabel.text = closestLabel.text
//            closestLabel.textColor = .darkGray
//            closestLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        }
//
//        updateSelectedMonth()
//    }
//
//
////    private func updateMonthPositions() {
////        // Remove all month labels but keep the centerLabel
////        subviews.filter { $0 != centerLabel }.forEach { $0.removeFromSuperview() }
////
////        var smallestAngleDifference: CGFloat = .greatestFiniteMagnitude
////
////        for (index, month) in months.enumerated() {
////            let angle = anglePerItem * CGFloat(index) + rotationAngle
////            let label = createMonthLabel(text: month)
////
////            let position = CGPoint(
////                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
////                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
////            )
////            label.center = position
////            addSubview(label)
////
////            // Determine which label is closest to the top (-π/2)
////            let angleDifference = abs(angle.truncatingRemainder(dividingBy: 2 * .pi) - (-.pi / 2))
////            if angleDifference < smallestAngleDifference {
////                smallestAngleDifference = angleDifference
////                closestLabel = label
////            }
////        }
////
////        // Update the center label and highlight the selected month
////        centerLabel.text = closestLabel?.text
////        closestLabel?.textColor = .darkGray
////        closestLabel?.font = UIFont.boldSystemFont(ofSize: 20)
////
////        updateSelectedMonth()
////    }
//
//    private func createMonthLabel(text: String) -> UILabel {
//        let label = UILabel()
//        label.text = text
//        label.font = UIFont.boldSystemFont(ofSize: 15)
//        label.textAlignment = .center
//        label.textColor = .red
//        label.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
//        return label
//    }
//
//    private func updateSelectedMonth() {
//        let normalizedAngle = fmod(rotationAngle + (anglePerItem / 2), 2 * .pi)
//        let selectedIndex = Int(round(normalizedAngle / anglePerItem)) % months.count
//    }
//
//    // MARK: - Touch Handling
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
//        // Normalize the angle difference to handle both clockwise and counterclockwise smoothly
//        rotationAngle += angleDifference
//        rotationAngle = normalizeAngle(rotationAngle)
//
//        lastTouchAngle = currentAngle
//
//        updateMonthPositions()
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        snapToNearestMonth()
//    }
//
//    private func snapToNearestMonth() {
//        let nearestIndex = Int(round(rotationAngle / anglePerItem)) % months.count
//        rotationAngle = CGFloat(nearestIndex) * anglePerItem
//
//        UIView.animate(withDuration: 0.2, animations: {
//            self.updateMonthPositions()
//        })
//
//        sendActions(for: .valueChanged)
//    }
//
//    private func angleForPoint(_ point: CGPoint) -> CGFloat {
//        let dx = point.x - bounds.midX
//        let dy = point.y - bounds.midY
//        return atan2(dy, dx)
//    }
//
//    private func normalizeAngle(_ angle: CGFloat) -> CGFloat {
//        // Normalize the angle to stay within the range of 0 to 2π
//        var normalizedAngle = fmod(angle, 2 * .pi)
//        if normalizedAngle < 0 {
//            normalizedAngle += 2 * .pi
//        }
//        return normalizedAngle
//    }
//}


/*
 //    override func layoutSubviews() {
 //        super.layoutSubviews()
 //        centerLabel.frame = CGRect(x: bounds.midX - 50, y: bounds.midY - 25, width: 100, height: 50)
 //        updateMonthPositions()
 //    }
     
 //    private func updateMonthPositions() {
 //        layer.sublayers?.forEach { $0.removeFromSuperlayer() } // Clear previous
 //
 //        for (index, month) in months.enumerated() {
 //            let angle = anglePerItem * CGFloat(index) + rotationAngle
 //            let label = createMonthLabel(text: month)
 //            let position = CGPoint(
 //                x: bounds.midX + radius * cos(angle) - label.bounds.width / 2,
 //                y: bounds.midY + radius * sin(angle) - label.bounds.height / 2
 //            )
 //            label.center = position
 //            addSubview(label)
 //        }
 //
 //        updateSelectedMonth()
 //    }
 */

/*
class CircularRangePicker: UIControl {
    private var trackLayer = CAShapeLayer()
      var startThumbLayer = CALayer()
    private var endThumbLayer = CALayer()
    private var highlightedLayer = CAShapeLayer()

    private var radius: CGFloat = 100
    public var startAngle: CGFloat = 0
    public var endAngle: CGFloat = .pi / 2

    private let thumbSize: CGFloat = 50

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
    }

    private func setupLayers() {
        // Track Layer
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 20
        trackLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(trackLayer)

        // Highlighted Range Layer
        highlightedLayer.strokeColor = UIColor.blue.cgColor
        highlightedLayer.lineWidth = 30
        highlightedLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(highlightedLayer)

        // Thumb Layers
        configureThumbLayer(startThumbLayer)
        configureThumbLayer(endThumbLayer)

        updateLayers()
    }

    private func configureThumbLayer(_ layer: CALayer) {
        layer.bounds = CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize)
        layer.cornerRadius = thumbSize / 2
        layer.backgroundColor = UIColor.white.cgColor
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        self.layer.addSublayer(layer)
    }

    private func updateLayers() {
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)

        // Track Path
        let trackPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        trackLayer.path = trackPath.cgPath

        // Highlighted Range Path
        let highlightedPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        highlightedLayer.path = highlightedPath.cgPath

        // Thumb Positions
        startThumbLayer.position = thumbPosition(for: startAngle, center: centerPoint)
        endThumbLayer.position = thumbPosition(for: endAngle, center: centerPoint)
    }

    private func thumbPosition(for angle: CGFloat, center: CGPoint) -> CGPoint {
        return CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 2 * radius + thumbSize * 2, height: 2 * radius + thumbSize * 2)
    }

    // Touch Handling
    private var trackingStartThumb = false
    private var trackingEndThumb = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if startThumbLayer.frame.insetBy(dx: -10, dy: -10).contains(location) {
            trackingStartThumb = true
        } else if endThumbLayer.frame.insetBy(dx: -10, dy: -10).contains(location) {
            trackingEndThumb = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if trackingStartThumb {
            startAngle = angleForPoint(location)
            sendActions(for: .valueChanged)
        } else if trackingEndThumb {
            endAngle = angleForPoint(location)
            sendActions(for: .valueChanged)
        }
        updateLayers()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        trackingStartThumb = false
        trackingEndThumb = false
    }

    private func angleForPoint(_ point: CGPoint) -> CGFloat {
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let deltaX = point.x - centerPoint.x
        let deltaY = point.y - centerPoint.y
        return atan2(deltaY, deltaX)
    }
}
*/



//class CircularRangePicker: UIControl { // Inherit from UIControl for target-action
//
//    private var trackLayer = CAShapeLayer()
//    private var startThumbLayer = CALayer()
//    private var endThumbLayer = CALayer()
//    private var highlightedLayer = CAShapeLayer()
//
//    private var radius: CGFloat = 100 // Adjust as needed
//    private var startAngle: CGFloat = 0 // In radians
//    private var endAngle: CGFloat = .pi / 2 // In radians
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayers()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupLayers()
//    }
//
//    private func setupLayers() {
//        // Track Layer
//        trackLayer.fillColor = UIColor.lightGray.cgColor
//        layer.addSublayer(trackLayer)
//
//        // Highlighted Range Layer
//        highlightedLayer.fillColor = UIColor.blue.cgColor
//        layer.addSublayer(highlightedLayer)
//
//        // Thumb Layers
//        startThumbLayer.backgroundColor = UIColor.white.cgColor
//        startThumbLayer.cornerRadius = 10 // Adjust size
//        layer.addSublayer(startThumbLayer)
//
//        endThumbLayer.backgroundColor = UIColor.white.cgColor
//        endThumbLayer.cornerRadius = 10 // Adjust size
//        layer.addSublayer(endThumbLayer)
//
//        updateLayers() // Initial positioning
//    }
//
//    private func updateLayers() {
//        // Track Path
//        let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
//        trackLayer.path = trackPath.cgPath
//
//        // Highlighted Range Path
//        let highlightedPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//        highlightedLayer.path = highlightedPath.cgPath
//
//        // Thumb Positions (using polar to cartesian conversion)
//        startThumbLayer.position = CGPoint(x: center.x + radius * cos(startAngle) - 10, y: center.y + radius * sin(startAngle) - 10)
//        endThumbLayer.position = CGPoint(x: center.x + radius * cos(endAngle) - 10, y: center.y + radius * sin(endAngle) - 10)
//    }
//
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: 2 * radius + 40, height: 2 * radius + 40) // Adjust for thumb size
//    }
//
//    // Touch Handling (Simplified)
//    private var trackingStartThumb = false
//    private var trackingEndThumb = false
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//
//        if startThumbLayer.frame.contains(location) {
//            trackingStartThumb = true
//        } else if endThumbLayer.frame.contains(location) {
//            trackingEndThumb = true
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//
//        if trackingStartThumb {
//            startAngle = angleForPoint(location)
//            updateLayers()
//        } else if trackingEndThumb {
//            endAngle = angleForPoint(location)
//            updateLayers()
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        trackingStartThumb = false
//        trackingEndThumb = false
//    }
//
//    private func angleForPoint(_ point: CGPoint) -> CGFloat {
//        let deltaX = point.x - center.x
//        let deltaY = point.y - center.y
//        return atan2(deltaY, deltaX)
//    }
//
//    private var center: CGPoint {
//        return CGPoint(x: bounds.midX, y: bounds.midY)
//    }
//}
