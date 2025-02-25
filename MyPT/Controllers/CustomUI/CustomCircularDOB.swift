//
//  CustomCircularDob.swift
//  MyPT
//
//  Created by techsaga corp on 04/02/25.
//

import UIKit

class CustomCircularDOB: UIControl {

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
        backgroundColor = UIColor.yellow
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
