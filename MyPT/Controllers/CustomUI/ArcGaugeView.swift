//
//  ArcGaugeView.swift
//  MyPT
//
//  Created by techsaga corp on 20/09/25.
//

import UIKit


class ArcGaugeView: UIView {
    // MARK: - Properties
    private let arcLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    // MARK: - Layer Setup
    private func setupLayers() {
        // Set up the arc layer properties
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = UIColor.black.cgColor
        arcLayer.lineCap = .round

        // Set up the gradient layer properties
        gradientLayer.colors = [UIColor.brown.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Add layers to the view's hierarchy
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = arcLayer
    }

    // MARK: - Layout and Drawing
    override func layoutSubviews() {
        super.layoutSubviews()

        // Calculate geometry based on the view's current bounds
        let bandWidth: CGFloat = 50
        let radius = bounds.width * 0.8 / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY + 50)
        let startAngle: CGFloat = .pi * 0.7
        let endAngle: CGFloat = .pi * 0.3

        // Create the arc path with the correct bounds
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: false)
        
        // Apply path and line width to the arc layer
        arcLayer.path = path.cgPath
        arcLayer.lineWidth = bandWidth
        
        // Update the gradient layer's frame to match the view's bounds
        gradientLayer.frame = bounds
        
        // Trigger a redraw of the ticks
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Ensure the drawing context is available
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // Use the same geometric constants for ticks
        let bandWidth: CGFloat = 50
        let radius = bounds.width * 0.8 / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY + 50)
        let startAngle: CGFloat = .pi * 0.7
        let endAngle: CGFloat = .pi * 0.3

        // Draw ticks
        let tickCount = 40
        for i in 0...tickCount {
            let fraction = CGFloat(i) / CGFloat(tickCount)
            let angle = startAngle + fraction * (endAngle - startAngle)

            // Calculate tick lengths
            let innerRadius = radius - bandWidth / 2
            let isMajorTick = (i % 5 == 0)
            let tickLength: CGFloat = isMajorTick ? 20 : 10
            let outerRadius = innerRadius + tickLength

            // Calculate start and end points of the tick line
            let inner = CGPoint(x: center.x + innerRadius * cos(angle),
                                y: center.y + innerRadius * sin(angle))
            let outer = CGPoint(x: center.x + outerRadius * cos(angle),
                                y: center.y + outerRadius * sin(angle))
            
            // Set tick color and line width
            let tickColor: UIColor = isMajorTick ? .white : .lightGray
            let tickLineWidth: CGFloat = isMajorTick ? 2 : 1
            ctx.setStrokeColor(tickColor.cgColor)
            ctx.setLineWidth(tickLineWidth)

            // Draw the line for the tick
            ctx.move(to: inner)
            ctx.addLine(to: outer)
            ctx.strokePath()
        }
    }
}


//class ArcGaugeView: UIView {
//    // MARK: - Properties
//    private let arcLayer = CAShapeLayer()
//    private let gradientLayer = CAGradientLayer()
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayers()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupLayers()
//    }
//
//    // MARK: - Layer Setup
//    private func setupLayers() {
//        // Set up the arc layer properties
//        arcLayer.fillColor = UIColor.clear.cgColor
//        arcLayer.strokeColor = UIColor.black.cgColor
//        arcLayer.lineCap = .round
//
//        // Set up the gradient layer properties
//        gradientLayer.colors = [UIColor.brown.cgColor, UIColor.black.cgColor]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        
//        // Add layers to the view's hierarchy
//        layer.addSublayer(gradientLayer)
//        gradientLayer.mask = arcLayer
//    }
//
//    // MARK: - Layout and Drawing
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        // Calculate geometry based on the view's current bounds
//        let bandWidth: CGFloat = 50
//        let radius = bounds.width * 0.8 / 2
//        let center = CGPoint(x: bounds.midX, y: bounds.midY + 50)
//        let startAngle: CGFloat = .pi * 0.7
//        let endAngle: CGFloat = .pi * 0.3
//
//        // Create the arc path with the correct bounds
//        let path = UIBezierPath(arcCenter: center,
//                                radius: radius,
//                                startAngle: startAngle,
//                                endAngle: endAngle,
//                                clockwise: false)
//        
//        // Apply path and line width to the arc layer
//        arcLayer.path = path.cgPath
//        arcLayer.lineWidth = bandWidth
//        
//        // Update the gradient layer's frame to match the view's bounds
//        gradientLayer.frame = bounds
//        
//        // Trigger a redraw of the ticks
//        setNeedsDisplay()
//    }
//
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//        // Ensure the drawing context is available
//        guard let ctx = UIGraphicsGetCurrentContext() else { return }
//
//        // Use the same geometric constants for ticks
//        let bandWidth: CGFloat = 50
//        let radius = bounds.width * 0.8 / 2
//        let center = CGPoint(x: bounds.midX, y: bounds.midY + 50)
//        let startAngle: CGFloat = .pi * 0.7
//        let endAngle: CGFloat = .pi * 0.3
//
//        // Draw ticks
//        let tickCount = 40
//        for i in 0...tickCount {
//            let fraction = CGFloat(i) / CGFloat(tickCount)
//            let angle = startAngle + fraction * (endAngle - startAngle)
//
//            // Calculate tick lengths
//            let innerRadius = radius - bandWidth / 2
//            let isMajorTick = (i % 5 == 0)
//            let tickLength: CGFloat = isMajorTick ? 20 : 10
//            let outerRadius = innerRadius + tickLength
//
//            // Calculate start and end points of the tick line
//            let inner = CGPoint(x: center.x + innerRadius * cos(angle),
//                                y: center.y + innerRadius * sin(angle))
//            let outer = CGPoint(x: center.x + outerRadius * cos(angle),
//                                y: center.y + outerRadius * sin(angle))
//            
//            // Set tick color and line width
//            let tickColor: UIColor = isMajorTick ? .white : .lightGray
//            let tickLineWidth: CGFloat = isMajorTick ? 2 : 1
//            ctx.setStrokeColor(tickColor.cgColor)
//            ctx.setLineWidth(tickLineWidth)
//
//            // Draw the line for the tick
//            ctx.move(to: inner)
//            ctx.addLine(to: outer)
//            ctx.strokePath()
//        }
//    }
//}


/*
class ArcGaugeView: UIView {
    private let arcLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        backgroundColor = UIColor.yellow
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        let bandWidth: CGFloat = 50
        let radius = bounds.width * 0.8 / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY + 50)

        let startAngle: CGFloat = .pi * 0.7
        let endAngle: CGFloat = .pi * 0.3

        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: false)
        arcLayer.path = path.cgPath
        arcLayer.lineWidth = bandWidth
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = UIColor.black.cgColor
        arcLayer.lineCap = .round

        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.brown.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.mask = arcLayer

        layer.addSublayer(gradientLayer)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Draw ticks
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let tickCount = 40
        let radius = bounds.width * 0.8 / 2
        let bandWidth: CGFloat = 50
        let center = CGPoint(x: bounds.midX, y: bounds.midY + 50)
        let startAngle: CGFloat = .pi * 0.7
        let endAngle: CGFloat = .pi * 0.3

        for i in 0...tickCount {
            let fraction = CGFloat(i) / CGFloat(tickCount)
            let angle = startAngle + fraction * (endAngle - startAngle)

            let innerRadius = radius - bandWidth / 2
            let outerRadius = radius - bandWidth / 2 + (i % 5 == 0 ? 20 : 10)

            let inner = CGPoint(x: center.x + innerRadius * cos(angle),
                                y: center.y + innerRadius * sin(angle))
            let outer = CGPoint(x: center.x + outerRadius * cos(angle),
                                y: center.y + outerRadius * sin(angle))

            ctx.setStrokeColor(UIColor.lightGray.cgColor)
            ctx.setLineWidth(2)
            ctx.move(to: inner)
            ctx.addLine(to: outer)
            ctx.strokePath()
        }
    }
}
*/

//class ArcGaugeView: UIView {
//    
//    override func draw(_ rect: CGRect) {
//        guard let ctx = UIGraphicsGetCurrentContext() else { return }
//        
//        let center = CGPoint(x: rect.midX, y: rect.maxY + 50) // center below view
//        let radius: CGFloat = rect.width * 0.8
//        let startAngle: CGFloat = .pi * 0.7
//        let endAngle: CGFloat = .pi * 0.3
//        
//        // --- Background arc band ---
//        let bandWidth: CGFloat = 50
//        let arcPath = UIBezierPath(arcCenter: center,
//                                   radius: radius,
//                                   startAngle: startAngle,
//                                   endAngle: endAngle,
//                                   clockwise: false)
//        ctx.saveGState()
//        ctx.setLineWidth(bandWidth)
//        ctx.addPath(arcPath.cgPath)
//        ctx.replacePathWithStrokedPath()
//        ctx.clip()
//        
//        let colors = [UIColor.brown.cgColor,
//                      UIColor.black.cgColor]
//        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
//                                  colors: colors as CFArray,
//                                  locations: [0, 1])!
//        ctx.drawLinearGradient(gradient,
//                               start: CGPoint(x: rect.minX, y: rect.minY),
//                               end: CGPoint(x: rect.maxX, y: rect.maxY),
//                               options: [])
//        ctx.restoreGState()
//        
//        // --- Ticks ---
//        let tickCount = 40
//        for i in 0...tickCount {
//            let fraction = CGFloat(i) / CGFloat(tickCount)
//            let angle = startAngle + fraction * (endAngle - startAngle)
//            
//            let innerRadius = radius - bandWidth/2
//            let outerRadius = radius - bandWidth/2 + (i % 5 == 0 ? 20 : 10)
//            
//            let inner = CGPoint(x: center.x + innerRadius * cos(angle),
//                                y: center.y + innerRadius * sin(angle))
//            let outer = CGPoint(x: center.x + outerRadius * cos(angle),
//                                y: center.y + outerRadius * sin(angle))
//            
//            ctx.setStrokeColor(UIColor.lightGray.cgColor)
//            ctx.setLineWidth(2)
//            ctx.move(to: inner)
//            ctx.addLine(to: outer)
//            ctx.strokePath()
//        }
//        
//        // --- Indicator Handle ---
//        let handleSize = CGSize(width: 60, height: 40)
//        let handleAngle = (startAngle + endAngle) / 2
//        let handleRadius = radius - bandWidth/2
//        
//        let handleCenter = CGPoint(x: center.x + handleRadius * cos(handleAngle),
//                                   y: center.y + handleRadius * sin(handleAngle))
//        
//        let handleRect = CGRect(x: handleCenter.x - handleSize.width/2,
//                                y: handleCenter.y - handleSize.height/2,
//                                width: handleSize.width,
//                                height: handleSize.height)
//        
//        let handlePath = UIBezierPath(roundedRect: handleRect,
//                                      cornerRadius: 15)
//        
//        let handleGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
//                                        colors: [UIColor.orange.cgColor,
//                                                 UIColor.brown.cgColor] as CFArray,
//                                        locations: [0,1])!
//        
//        ctx.saveGState()
//        ctx.addPath(handlePath.cgPath)
//        ctx.clip()
//        ctx.drawLinearGradient(handleGradient,
//                               start: handleRect.origin,
//                               end: CGPoint(x: handleRect.maxX, y: handleRect.maxY),
//                               options: [])
//        ctx.restoreGState()
//    }
//}
