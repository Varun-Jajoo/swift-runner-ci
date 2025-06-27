//
//  GaugeView.swift
//  MyPT
//
//  Created by techsaga corp on 27/06/25.
//

import UIKit

class GaugeView: UIView {

    // MARK: - Properties
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let desirableLabel = UILabel()
    private var tickMarkLayers: [CAShapeLayer] = []

    private let gaugeWidth: CGFloat = 20.0
    private let gaugeRadiusMultiplier: CGFloat = 0.8 //0.75
//    private let startAngle: CGFloat = 0
//    private let endAngle: CGFloat = .pi
    
    private let startAngle: CGFloat = -.pi
    private let endAngle: CGFloat = 0  
    private let numberOfMajorTicks: Int = 12
    private let numberOfMinorTicksPerMajor: Int = 2
    private let majorTickLength: CGFloat = 8.0
    private let minorTickLength: CGFloat = 4.0
    private let tickColor: UIColor = .white.withAlphaComponent(0.3)

    var progress: CGFloat = 0.0 {
        didSet {
            let clamped = max(0.0, min(1.0, progress))
            if clamped != oldValue {
                animateProgress(from: oldValue, to: clamped)
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        setupGaugeLayers()
        setupLabel()
    }

    // MARK: - Elliptical Arc Path

    private func ellipticalArcPath(center: CGPoint, size: CGSize, startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let steps = 100
        let angleRange = endAngle - startAngle

        for i in 0...steps {
            let angle = startAngle + CGFloat(i) / CGFloat(steps) * angleRange
            let x = center.x + size.width * cos(angle)
            let y = center.y + size.height * sin(angle)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }

    // MARK: - Setup Layers

    private func setupGaugeLayers() {
        trackLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
        gradientLayer.removeFromSuperlayer()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let size = CGSize(width: bounds.width / 2 * gaugeRadiusMultiplier,
                          height: bounds.height / 2 * gaugeRadiusMultiplier * 0.6)

        // Track Layer
        let trackPath = ellipticalArcPath(center: center, size: size, startAngle: startAngle, endAngle: endAngle)
        trackLayer.path = trackPath
        trackLayer.strokeColor = UIColor(red: 0.1, green: 0.05, blue: 0.05, alpha: 1).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = gaugeWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        // Progress Layer
        let progressPath = ellipticalArcPath(center: center, size: size, startAngle: startAngle, endAngle: endAngle)
        progressLayer.path = progressPath
        progressLayer.strokeColor = UIColor.green.cgColor // temporary
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = gaugeWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress

        // Gradient Layer
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.green.cgColor,
            UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = progressLayer
        layer.addSublayer(gradientLayer)
    }

    // MARK: - Label

    private func setupLabel() {
        desirableLabel.text = "DESIRABLE"
        desirableLabel.textColor = UIColor(red: 0.7, green: 1.0, blue: 0.4, alpha: 1.0)
        desirableLabel.font = UIFont.systemFont(ofSize: bounds.height * 0.1, weight: .bold)
        desirableLabel.textAlignment = .center
        desirableLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(desirableLabel)

        NSLayoutConstraint.activate([
            desirableLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            desirableLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height * 0.35)
        ])
    }


    // MARK: - Animation
    private func animateProgress(from: CGFloat, to: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = to
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGaugeLayers()
        desirableLabel.font = UIFont.systemFont(ofSize: bounds.height * 0.1, weight: .bold)
        desirableLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height * 0.35).isActive = true
        progressLayer.strokeEnd = progress
    }
}

/*  it's wrking but from bottom
class GaugeView: UIView {

    // MARK: - Properties

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let desirableLabel = UILabel()
    private var tickMarkLayers: [CAShapeLayer] = []

    private let gaugeWidth: CGFloat = 20.0
    private let gaugeRadiusMultiplier: CGFloat = 0.75
    private let startAngle: CGFloat = 0            // Left
    private let endAngle: CGFloat = .pi            // Right
    private let numberOfMajorTicks: Int = 12
    private let numberOfMinorTicksPerMajor: Int = 2
    private let majorTickLength: CGFloat = 8.0
    private let minorTickLength: CGFloat = 4.0
    private let tickColor: UIColor = .white.withAlphaComponent(0.3)

    var progress: CGFloat = 0.0 {
        didSet {
            let clamped = max(0.0, min(1.0, progress))
            if clamped != oldValue {
                animateProgress(from: oldValue, to: clamped)
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        setupGaugeLayers()
        setupLabel()
        drawTickMarks()
    }

    // MARK: - Elliptical Arc Path

    private func ellipticalArcPath(center: CGPoint, size: CGSize, startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let steps = 100
        let angleRange = endAngle - startAngle

        for i in 0...steps {
            let angle = startAngle + CGFloat(i) / CGFloat(steps) * angleRange
            let x = center.x + size.width * cos(angle)
            let y = center.y + size.height * sin(angle)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }

    // MARK: - Setup Layers

    private func setupGaugeLayers() {
        trackLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
        gradientLayer.removeFromSuperlayer()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let size = CGSize(width: bounds.width / 2 * gaugeRadiusMultiplier,
                          height: bounds.height / 2 * gaugeRadiusMultiplier * 0.6)

        // Track Layer
        let trackPath = ellipticalArcPath(center: center, size: size, startAngle: startAngle, endAngle: endAngle)
        trackLayer.path = trackPath
        trackLayer.strokeColor = UIColor(red: 0.1, green: 0.05, blue: 0.05, alpha: 1).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = gaugeWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        // Progress Layer
        let progressPath = ellipticalArcPath(center: center, size: size, startAngle: startAngle, endAngle: endAngle)
        progressLayer.path = progressPath
        progressLayer.strokeColor = UIColor.green.cgColor // temporary
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = gaugeWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress

        // Gradient Layer
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.green.cgColor,
            UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = progressLayer
        layer.addSublayer(gradientLayer)
    }

    // MARK: - Label

    private func setupLabel() {
        desirableLabel.text = "DESIRABLE"
        desirableLabel.textColor = UIColor(red: 0.7, green: 1.0, blue: 0.4, alpha: 1.0)
        desirableLabel.font = UIFont.systemFont(ofSize: bounds.height * 0.1, weight: .bold)
        desirableLabel.textAlignment = .center
        desirableLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(desirableLabel)

        NSLayoutConstraint.activate([
            desirableLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            desirableLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height * 0.35)
        ])
    }

    // MARK: - Tick Marks

    private func drawTickMarks() {
        tickMarkLayers.forEach { $0.removeFromSuperlayer() }
        tickMarkLayers.removeAll()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let size = CGSize(width: bounds.width / 2 * gaugeRadiusMultiplier,
                          height: bounds.height / 2 * gaugeRadiusMultiplier * 0.6)
        let tickRadius = min(size.width, size.height)

        let totalTicks = numberOfMajorTicks + (numberOfMajorTicks - 1) * numberOfMinorTicksPerMajor
        let angleIncrement = (endAngle - startAngle) / CGFloat(totalTicks - 1)

        for i in 0..<totalTicks {
            let angle = startAngle + CGFloat(i) * angleIncrement
            let isMajor = i % (numberOfMinorTicksPerMajor + 1) == 0
            let length = isMajor ? majorTickLength : minorTickLength

            let inner = CGPoint(
                x: center.x + (tickRadius - length) * cos(angle),
                y: center.y + (tickRadius - length) * sin(angle)
            )
            let outer = CGPoint(
                x: center.x + tickRadius * cos(angle),
                y: center.y + tickRadius * sin(angle)
            )

            let tickPath = UIBezierPath()
            tickPath.move(to: inner)
            tickPath.addLine(to: outer)

            let tickLayer = CAShapeLayer()
            tickLayer.path = tickPath.cgPath
            tickLayer.strokeColor = tickColor.cgColor
            tickLayer.lineWidth = isMajor ? 1.5 : 0.8
            tickLayer.lineCap = .round
            layer.addSublayer(tickLayer)
            tickMarkLayers.append(tickLayer)
        }
    }

    // MARK: - Animation

    private func animateProgress(from: CGFloat, to: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = to
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        setupGaugeLayers()
        drawTickMarks()
        desirableLabel.font = UIFont.systemFont(ofSize: bounds.height * 0.1, weight: .bold)
        desirableLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height * 0.35).isActive = true
        progressLayer.strokeEnd = progress
    }
}

*/


/* it's near about

class GaugeView: UIView {

    // MARK: - Properties

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let desirableLabel = UILabel()
    private var tickMarkLayers: [CAShapeLayer] = []

    private let gaugeWidth: CGFloat = 20.0
    private let gaugeRadiusMultiplier: CGFloat = 0.75
    private let startAngle: CGFloat = .pi // 180°
    private let endAngle: CGFloat = 0     // 0°
    private let numberOfMajorTicks: Int = 5
    private let numberOfMinorTicksPerMajor: Int = 4
    private let majorTickLength: CGFloat = 10.0
    private let minorTickLength: CGFloat = 5.0
    private let tickColor: UIColor = .white.withAlphaComponent(0.8)

    var progress: CGFloat = 0.0 {
        didSet {
            let clampedProgress = max(0.0, min(1.0, progress))
            if clampedProgress != oldValue {
                animateProgress(from: oldValue, to: clampedProgress)
            }
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        setupGaugeLayers()
        setupLabel()
        drawTickMarks()
    }

    // MARK: - Elliptical Arc Path

    private func ellipticalArcPath(center: CGPoint, size: CGSize, startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let steps = 100
        let angleRange = endAngle - startAngle

        for i in 0...steps {
            let angle = startAngle + CGFloat(i) / CGFloat(steps) * angleRange
            let x = center.x + size.width * cos(angle)
            let y = center.y + size.height * sin(angle)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }

    // MARK: - Setup Layers

    private func setupGaugeLayers() {
        trackLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let size = CGSize(
            width: bounds.width / 2 * gaugeRadiusMultiplier,
            height: bounds.height / 2 * gaugeRadiusMultiplier * 0.6
        )

        // Track Layer
        let trackPath = ellipticalArcPath(center: center, size: size, startAngle: startAngle, endAngle: endAngle)
        trackLayer.path = trackPath
        trackLayer.strokeColor = UIColor(red: 0.2, green: 0.15, blue: 0.15, alpha: 1.0).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = gaugeWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        // Progress Layer
        let progressPath = ellipticalArcPath(center: center, size: size, startAngle: startAngle, endAngle: endAngle)
        progressLayer.path = progressPath
        progressLayer.strokeColor = UIColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 1.0).cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = gaugeWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
    }

    // MARK: - Label

    private func setupLabel() {
        desirableLabel.text = "DESIRABLE"
        desirableLabel.textColor = .white
        desirableLabel.font = UIFont.systemFont(ofSize: bounds.height * 0.1, weight: .bold)
        desirableLabel.textAlignment = .center
        desirableLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(desirableLabel)

        NSLayoutConstraint.activate([
            desirableLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            desirableLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height * 0.35)
        ])
    }

    // MARK: - Tick Marks

    private func drawTickMarks() {
        tickMarkLayers.forEach { $0.removeFromSuperlayer() }
        tickMarkLayers.removeAll()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let size = CGSize(
            width: bounds.width / 2 * gaugeRadiusMultiplier,
            height: bounds.height / 2 * gaugeRadiusMultiplier * 0.6
        )
        let tickRadius = min(size.width, size.height)

        let totalTicks = numberOfMajorTicks + (numberOfMajorTicks - 1) * numberOfMinorTicksPerMajor
        let angleIncrement = (endAngle - startAngle) / CGFloat(totalTicks - 1)

        for i in 0..<totalTicks {
            let angle = startAngle + CGFloat(i) * angleIncrement
            let isMajorTick = (i % (numberOfMinorTicksPerMajor + 1) == 0)
            let tickLength = isMajorTick ? majorTickLength : minorTickLength

            let innerX = center.x + (tickRadius - tickLength) * cos(angle)
            let innerY = center.y + (tickRadius - tickLength) * sin(angle)
            let outerX = center.x + tickRadius * cos(angle)
            let outerY = center.y + tickRadius * sin(angle)

            let tickPath = UIBezierPath()
            tickPath.move(to: CGPoint(x: innerX, y: innerY))
            tickPath.addLine(to: CGPoint(x: outerX, y: outerY))

            let tickLayer = CAShapeLayer()
            tickLayer.path = tickPath.cgPath
            tickLayer.strokeColor = tickColor.cgColor
            tickLayer.lineWidth = isMajorTick ? 2.0 : 1.0
            tickLayer.lineCap = .round
            layer.addSublayer(tickLayer)
            tickMarkLayers.append(tickLayer)
        }
    }

    // MARK: - Animation

    private func animateProgress(from: CGFloat, to: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = to
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        setupGaugeLayers()
        drawTickMarks()
        desirableLabel.font = UIFont.systemFont(ofSize: bounds.height * 0.1, weight: .bold)
        desirableLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height * 0.35).isActive = true
        progressLayer.strokeEnd = progress
    }
}

*/

/*
 class GaugeView: UIView {

     // MARK: - Properties

     private let trackLayer = CAShapeLayer()
     private let progressLayer = CAShapeLayer()
     private let desirableLabel = UILabel()
     private var tickMarkLayers: [CAShapeLayer] = [] // To hold all individual tick layers

     // Configuration properties
     private let gaugeWidth: CGFloat = 20.0
     private let gaugeRadiusMultiplier: CGFloat = 0.75 // How much of the view's min dimension the gauge fills
     private let startAngle: CGFloat = .pi * 0.75 // Starting angle (approx 225 degrees)
     private let endAngle: CGFloat = .pi * 2.25  // Ending angle (approx 405 degrees, or 45 degrees past a full circle from start)
     private let numberOfMajorTicks: Int = 5 // Example: for 0%, 25%, 50%, 75%, 100%
     private let numberOfMinorTicksPerMajor: Int = 4 // Minor ticks between major ticks
     private let majorTickLength: CGFloat = 10.0
     private let minorTickLength: CGFloat = 5.0
     private let tickColor: UIColor = .white.withAlphaComponent(0.8) // White ticks

     // Public property to set progress (0.0 to 1.0)
     var progress: CGFloat = 0.0 {
         didSet {
             // Ensure progress is clamped between 0 and 1
             let clampedProgress = max(0.0, min(1.0, progress))
             if clampedProgress != oldValue { // Only animate if value changed
                 animateProgress(from: oldValue, to: clampedProgress)
             }
         }
     }

     // MARK: - Initialization

     override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }

     required init?(coder: NSCoder) {
         super.init(coder: coder)
         commonInit()
     }

     private func commonInit() {
         backgroundColor = .clear // Or your desired background if any
         setupGaugeLayers()
         setupLabel()
         drawTickMarks() // Initial drawing of ticks
     }

     // MARK: - Setup Layers

     private func setupGaugeLayers() {
         // Remove existing layers before re-adding (important for layoutSubviews)
         trackLayer.removeFromSuperlayer()
         progressLayer.removeFromSuperlayer()

         let center = CGPoint(x: bounds.midX, y: bounds.midY)
         let radius = min(bounds.width, bounds.height) / 2 * gaugeRadiusMultiplier

         // MARK: Track Layer (Dark Brown/Gray)
         let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
         trackLayer.path = trackPath.cgPath
         trackLayer.strokeColor = UIColor(red: 0.2, green: 0.15, blue: 0.15, alpha: 1.0).cgColor // Dark brown/gray
         trackLayer.fillColor = UIColor.clear.cgColor
         trackLayer.lineWidth = gaugeWidth
         trackLayer.lineCap = .round // Rounded ends for the arc
         layer.addSublayer(trackLayer)

         // MARK: Progress Layer (Green)
         let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
         progressLayer.path = progressPath.cgPath
         progressLayer.strokeColor = UIColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 1.0).cgColor // Green color
         progressLayer.fillColor = UIColor.clear.cgColor
         progressLayer.lineWidth = gaugeWidth
         progressLayer.lineCap = .round
         progressLayer.strokeEnd = progress // Set initial strokeEnd based on current progress
         layer.addSublayer(progressLayer)
     }

     // MARK: - Setup Label

     private func setupLabel() {
         desirableLabel.text = "DESIRABLE"
         desirableLabel.textColor = .white
         desirableLabel.font = UIFont.systemFont(ofSize: bounds.height * 0.1, weight: .bold) // Responsive font size
         desirableLabel.textAlignment = .center
         desirableLabel.translatesAutoresizingMaskIntoConstraints = false
         addSubview(desirableLabel)

         // Center the label (adjust Y position to be below center of the arc)
         NSLayoutConstraint.activate([
             desirableLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             desirableLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height * 0.15) // Adjust position relative to view height
         ])
     }

     // MARK: - Tick Mark Drawing

     private func drawTickMarks() {
         // Clear existing tick layers
         tickMarkLayers.forEach { $0.removeFromSuperlayer() }
         tickMarkLayers.removeAll()

         let center = CGPoint(x: bounds.midX, y: bounds.midY)
         let radius = min(bounds.width, bounds.height) / 2 * gaugeRadiusMultiplier
         let tickRadius = radius - gaugeWidth / 2 // Position ticks at the center of the gauge line

         let totalTicks = numberOfMajorTicks + (numberOfMajorTicks - 1) * numberOfMinorTicksPerMajor
         let angleIncrement = (endAngle - startAngle) / CGFloat(totalTicks - 1) // Angle between each tick

         for i in 0..<totalTicks {
             let currentAngle = startAngle + CGFloat(i) * angleIncrement
             let isMajorTick = (i % (numberOfMinorTicksPerMajor + 1) == 0)
             let tickLength = isMajorTick ? majorTickLength : minorTickLength

             // Calculate start and end points for the tick line
             let innerPointX = center.x + (tickRadius - tickLength) * cos(currentAngle)
             let innerPointY = center.y + (tickRadius - tickLength) * sin(currentAngle)
             let outerPointX = center.x + tickRadius * cos(currentAngle)
             let outerPointY = center.y + tickRadius * sin(currentAngle)

             let tickPath = UIBezierPath()
             tickPath.move(to: CGPoint(x: innerPointX, y: innerPointY))
             tickPath.addLine(to: CGPoint(x: outerPointX, y: outerPointY))

             let tickLayer = CAShapeLayer()
             tickLayer.path = tickPath.cgPath
             tickLayer.strokeColor = tickColor.cgColor
             tickLayer.lineWidth = isMajorTick ? 2.0 : 1.0 // Major ticks slightly thicker
             tickLayer.lineCap = .round
             layer.addSublayer(tickLayer)
             tickMarkLayers.append(tickLayer)
         }
     }

     // MARK: - Animation

     private func animateProgress(from: CGFloat, to: CGFloat) {
         let animation = CABasicAnimation(keyPath: "strokeEnd")
         animation.fromValue = from // Start from the current visual state
         animation.toValue = to
         animation.duration = 0.8 // Animation duration
         animation.timingFunction = CAMediaTimingFunction(name: .easeOut) // Smooth deceleration
         animation.fillMode = .forwards
         animation.isRemovedOnCompletion = false // Keep the final state

         progressLayer.add(animation, forKey: "progressAnimation")

         // Immediately update the model layer's property to avoid flickering
         // after the animation finishes and is removed (if it were removed)
         progressLayer.strokeEnd = to
     }

     // MARK: - Layout Subviews

     override func layoutSubviews() {
         super.layoutSubviews()
         // This is crucial for resizing or initial layout
         setupGaugeLayers() // Recalculate paths based on new bounds
         drawTickMarks()    // Recalculate tick positions
         desirableLabel.font = UIFont.systemFont(ofSize: bounds.height * 0.1, weight: .bold) // Adjust font size
         // Update label constraints if needed, but current ones are relative to center
         desirableLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: bounds.height * 0.15).isActive = true
         // Ensure progress is reapplied after re-laying out layers
         progressLayer.strokeEnd = progress
     }
 }
*/

 

//class ProgressRingView: UIView {
//    
//    private let shapeLayer = CAShapeLayer()
//    private let gradientLayer = CAGradientLayer()
//    private let pointerImageView = UIImageView()
//    private let scoreLabel = UILabel()
//    private let statusLabel = UILabel()
//    
//    private var progress: Float = 0.3
//    private var degree: CGFloat = -110
//    
//    private var timer: Timer?
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//        startTimer()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//        startTimer()
//    }
//    
//    private func setupView() {
//        self.backgroundColor = .clear
//        setupProgressCircle()
//        setupPointer()
//        setupLabels()
//    }
//    
//    private func setupProgressCircle() {
//        let radius: CGFloat = 100
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        
//        let circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: .pi * 0.6, endAngle: .pi * 2.4, clockwise: true)
//        
//        // Background
//        let backgroundCircle = CAShapeLayer()
//        backgroundCircle.path = circularPath.cgPath
//        backgroundCircle.strokeColor = UIColor.gray.withAlphaComponent(0.3).cgColor
//        backgroundCircle.lineWidth = 12
//        backgroundCircle.fillColor = UIColor.clear.cgColor
//        backgroundCircle.lineCap = .round
//        backgroundCircle.position = center
//        layer.addSublayer(backgroundCircle)
//        
//        // Progress Shape
//        shapeLayer.path = circularPath.cgPath
//        shapeLayer.strokeColor = UIColor.black.cgColor // Placeholder
//        shapeLayer.lineWidth = 12
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.lineCap = .round
//        shapeLayer.strokeEnd = CGFloat(progress)
//        shapeLayer.position = center
//        
//        // Gradient
//        gradientLayer.frame = bounds
//        gradientLayer.colors = [
//            UIColor(hex: "ED4D4D").cgColor,
//            UIColor(hex: "E59148").cgColor,
//            UIColor(hex: "EFBF39").cgColor,
//            UIColor(hex: "EEED56").cgColor,
//            UIColor(hex: "32E1A0").cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        gradientLayer.mask = shapeLayer
//        layer.addSublayer(gradientLayer)
//    }
//    
//    private func setupPointer() {
//        pointerImageView.image = UIImage(named: "triangle")
//        pointerImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
//        pointerImageView.center = CGPoint(x: bounds.midX, y: bounds.midY - 120)
//        pointerImageView.layer.anchorPoint = CGPoint(x: 0.5, y: 2.5)
//        addSubview(pointerImageView)
//        pointerImageView.transform = CGAffineTransform(rotationAngle: degree * .pi / 180)
//    }
//    
//    private func setupLabels() {
//        scoreLabel.text = "824"
//        scoreLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
//        scoreLabel.textColor = UIColor(hex: "314058")
//        scoreLabel.textAlignment = .center
//        
//        statusLabel.text = "Great Score!"
//        statusLabel.font = UIFont.boldSystemFont(ofSize: 14)
//        statusLabel.textColor = UIColor(hex: "32E1A0")
//        statusLabel.textAlignment = .center
//        
//        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
//        statusLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(scoreLabel)
//        addSubview(statusLabel)
//        
//        NSLayoutConstraint.activate([
//            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
//            statusLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 2),
//            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
//        ])
//    }
//    
//    private func startTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            if self.progress < 0.9 {
//                self.progress += 0.0275
//                self.shapeLayer.strokeEnd = CGFloat(self.progress)
//            }
//            if self.degree < 110 {
//                self.degree += 10
//                UIView.animate(withDuration: 0.01) {
//                    self.pointerImageView.transform = CGAffineTransform(rotationAngle: self.degree * .pi / 180)
//                }
//            } else {
//                self.timer?.invalidate()
//            }
//        }
//    }
//    
//    deinit {
//        timer?.invalidate()
//    }
//}




/*
 class GaugeView: UIView {

     private let trackLayer = CAShapeLayer()
     private let progressLayer = CAShapeLayer()
     private let desirableLabel = UILabel()

     // Public property to set progress
     var progress: CGFloat = 0.0 {
         didSet {
             // Animate strokeEnd when progress changes
             let animation = CABasicAnimation(keyPath: "strokeEnd")
             animation.fromValue = oldValue // Or current presentationLayer's strokeEnd
             animation.toValue = progress
             animation.duration = 0.5 // Adjust as needed
             animation.fillMode = .forwards
             animation.isRemovedOnCompletion = false
             progressLayer.add(animation, forKey: "progressAnimation")
             // Update the model layer's property immediately
             progressLayer.strokeEnd = progress
         }
     }

     override init(frame: CGRect) {
         super.init(frame: frame)
         setupLayers()
         setupLabel()
     }

     required init?(coder: NSCoder) {
         super.init(coder: coder)
         setupLayers()
         setupLabel()
     }

     private func setupLayers() {
         // Define common arc properties
         let center = CGPoint(x: bounds.midX, y: bounds.midY)
         let radius = min(bounds.width, bounds.height) / 2 * 0.8 // Adjust radius as needed
         let startAngle: CGFloat = .pi * 0.75 // Example start angle
         let endAngle: CGFloat = .pi * 2.25 // Example end angle (3/4 of a circle for a larger gauge)

         // Track Layer
         let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
         trackLayer.path = trackPath.cgPath
         trackLayer.strokeColor = UIColor(white: 0.2, alpha: 1.0).cgColor // Dark brown/gray
         trackLayer.fillColor = UIColor.clear.cgColor
         trackLayer.lineWidth = 20 // Adjust thickness
         trackLayer.lineCap = .round
         layer.addSublayer(trackLayer)

         // Progress Layer
         let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
         progressLayer.path = progressPath.cgPath
         progressLayer.strokeColor = UIColor.green.cgColor // Green progress
         progressLayer.fillColor = UIColor.clear.cgColor
         progressLayer.lineWidth = 20 // Same thickness as track
         progressLayer.lineCap = .round
         progressLayer.strokeEnd = 0.0 // Initial state
         layer.addSublayer(progressLayer)

         // Add tick marks (more complex, consider a loop or separate function)
         // For example, iterate from startAngle to endAngle, draw small lines
         // For each tick:
         // let tickPath = UIBezierPath()
         // tickPath.move(to: innerPoint)
         // tickPath.addLine(to: outerPoint)
         // let tickLayer = CAShapeLayer()
         // tickLayer.path = tickPath.cgPath
         // tickLayer.strokeColor = UIColor.white.cgColor
         // tickLayer.lineWidth = 2
         // layer.addSublayer(tickLayer)
     }

     private func setupLabel() {
         desirableLabel.text = "DESIRABLE"
         desirableLabel.textColor = .white
         desirableLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold) // Adjust font
         desirableLabel.textAlignment = .center
         desirableLabel.translatesAutoresizingMaskIntoConstraints = false
         addSubview(desirableLabel)

         NSLayoutConstraint.activate([
             desirableLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             desirableLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 40) // Adjust position
         ])
     }

     override func layoutSubviews() {
         super.layoutSubviews()
         // Re-layout layers if bounds change (e.g., device rotation)
         // Recalculate paths based on new bounds
         setupLayers() // This will recreate the paths based on the new bounds
         // Ensure progress is reapplied after re-laying out layers
         progressLayer.strokeEnd = progress
     }
 }
 */
