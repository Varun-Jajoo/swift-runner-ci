//
//  FrostedGlassView.swift
//  MyPT
//
//  Created by techsaga corp on 15/02/25.
//

import UIKit


class FrostedGlassView: UIView {

    private let glassLayer = CAShapeLayer()
    private let waterLayer = CAShapeLayer()

    var waterFillColor: UIColor = UIColor.blue.withAlphaComponent(0.4) {
        didSet {
            waterLayer.fillColor = waterFillColor.cgColor
        }
    }

    var glassStrokeColor: UIColor = UIColor.red {
        didSet {
            glassLayer.strokeColor = glassStrokeColor.cgColor
        }
    }
    
    var glassFillColor: UIColor = UIColor.black.withAlphaComponent(0.6) {
        didSet {
            glassLayer.fillColor = glassFillColor.cgColor
        }
    }
    
    var glasslineWidth: CGFloat = 2.0 {
        didSet {
            glassLayer.lineWidth = glasslineWidth
        }
    }
  
    var waterLevel: CGFloat = 0.5 { // Between 0.0 to 1.0
        didSet {
            updateWaterLevel()
        }
    }

    var cornerRadius: CGFloat = 20 { // Set desired corner radius
        didSet {
            setupView()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        drawGlassShape()
        drawWaterShape()
    }

    private func drawGlassShape() {
        let path = UIBezierPath()
        let topWidth: CGFloat = bounds.width * 0.8
        let bottomWidth: CGFloat = bounds.width * 0.5
        let height: CGFloat = bounds.height
        let topOffset: CGFloat = (bounds.width - topWidth) / 2
        let bottomOffset: CGFloat = (bounds.width - bottomWidth) / 2

        // Start at top-left with rounded corner
        path.move(to: CGPoint(x: topOffset + cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: bounds.width - topOffset - cornerRadius, y: 0))
        path.addQuadCurve(to: CGPoint(x: bounds.width - topOffset, y: cornerRadius),
                          controlPoint: CGPoint(x: bounds.width - topOffset - 5, y: 5))

        // Right straight line down
        path.addLine(to: CGPoint(x: bounds.width - bottomOffset, y: height - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: bounds.width - bottomOffset - cornerRadius, y: height),
                          controlPoint: CGPoint(x: bounds.width - bottomOffset, y: height))

        // Bottom straight line
        path.addLine(to: CGPoint(x: bottomOffset + cornerRadius, y: height))
        path.addQuadCurve(to: CGPoint(x: bottomOffset, y: height - cornerRadius),
                          controlPoint: CGPoint(x: bottomOffset, y: height))

        // Left straight line up
        path.addLine(to: CGPoint(x: topOffset, y: cornerRadius))
        path.addQuadCurve(to: CGPoint(x: topOffset + cornerRadius, y: 0),
                          controlPoint: CGPoint(x: topOffset, y: 0))

        path.close()

        glassLayer.path = path.cgPath
        
        glassLayer.strokeColor = glassStrokeColor.cgColor
        glassLayer.fillColor = glassFillColor.cgColor
        glassLayer.lineWidth = glasslineWidth
        
//        glassLayer.strokeColor = UIColor.black.cgColor
//        glassLayer.fillColor = UIColor.black.withAlphaComponent(0.8).cgColor
//        glassLayer.lineWidth = 5
        layer.addSublayer(glassLayer)
    }

    private func drawWaterShape() {
        let waterHeight: CGFloat = bounds.height * (1 - waterLevel)
        
        // Interpolating the top width to match the tapered shape of the glass
        let topWidth = bounds.width * 0.67
        let bottomWidth = bounds.width * 0.44
        let bottomOffset = (bounds.width - bottomWidth) / 2
        let heightB = bounds.height * 0.97
        
        // Calculate the current water width based on the height
        let currentWaterWidth = bottomWidth + ((topWidth - bottomWidth) * waterLevel)
        let currentOffset = (bounds.width - currentWaterWidth) / 2
        
        let waterPath = UIBezierPath()
        
        // **Start from Bottom-Left with rounded corner**
        waterPath.move(to: CGPoint(x: bottomOffset + cornerRadius, y: heightB))
        waterPath.addQuadCurve(to: CGPoint(x: bottomOffset, y: heightB - cornerRadius),
                               controlPoint: CGPoint(x: bottomOffset, y: heightB))
        
        // **Move to Top-Left with rounded corner**
        waterPath.addLine(to: CGPoint(x: currentOffset, y: waterHeight + cornerRadius))
        waterPath.addQuadCurve(to: CGPoint(x: currentOffset + cornerRadius, y: waterHeight),
                               controlPoint: CGPoint(x: currentOffset, y: waterHeight))
        
        // **Move to Top-Right with rounded corner**
        waterPath.addLine(to: CGPoint(x: bounds.width - currentOffset - cornerRadius, y: waterHeight))
        waterPath.addQuadCurve(to: CGPoint(x: bounds.width - currentOffset, y: waterHeight + cornerRadius),
                               controlPoint: CGPoint(x: bounds.width - currentOffset, y: waterHeight))
        
        // **Move to Bottom-Right with rounded corner**
        waterPath.addLine(to: CGPoint(x: bounds.width - bottomOffset, y: heightB - cornerRadius))
        waterPath.addQuadCurve(to: CGPoint(x: bounds.width - bottomOffset - cornerRadius, y: heightB),
                               controlPoint: CGPoint(x: bounds.width - bottomOffset, y: heightB))
        
        waterPath.close()
        
        waterLayer.path = waterPath.cgPath
        waterLayer.fillColor = waterFillColor.cgColor
        layer.addSublayer(waterLayer)
    }

    private func updateWaterLevel() {
        drawWaterShape() // Redraw water when level changes
    }
}

//class FrostedGlassView: UIView {
//
//    private let glassLayer = CAShapeLayer()
//    private let waterLayer = CAShapeLayer()
//
//    var waterFillColor: UIColor = UIColor.blue.withAlphaComponent(0.8) {
//        didSet {
//            waterLayer.fillColor = waterFillColor.cgColor
//        }
//    }
//
//    var waterLevel: CGFloat = 0.5 { // Between 0.0 to 1.0
//        didSet {
//            updateWaterLevel()
//        }
//    }
//
//    var cornerRadius: CGFloat = 20 { // Set desired corner radius
//        didSet {
//            setupView()
//        }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//
//    private func setupView() {
//        backgroundColor = .clear
//        drawGlassShape()
//        drawWaterShape()
//    }
//
//    private func drawGlassShape() {
//        let path = UIBezierPath()
//        let topWidth: CGFloat = bounds.width * 0.8
//        let bottomWidth: CGFloat = bounds.width * 0.5
//        let height: CGFloat = bounds.height
//        let topOffset: CGFloat = (bounds.width - topWidth) / 2
//        let bottomOffset: CGFloat = (bounds.width - bottomWidth) / 2
//
//        // Start at top-left with rounded corner
//        path.move(to: CGPoint(x: topOffset + cornerRadius, y: 0))
//        path.addLine(to: CGPoint(x: bounds.width - topOffset - cornerRadius, y: 0))
//        path.addQuadCurve(to: CGPoint(x: bounds.width - topOffset, y: cornerRadius),
//                          controlPoint: CGPoint(x: bounds.width - topOffset - 5, y: 5))
//
//        // Right straight line down
//        path.addLine(to: CGPoint(x: bounds.width - bottomOffset, y: height - cornerRadius))
//        path.addQuadCurve(to: CGPoint(x: bounds.width - bottomOffset - cornerRadius, y: height),
//                          controlPoint: CGPoint(x: bounds.width - bottomOffset, y: height))
//
//        // Bottom straight line
//        path.addLine(to: CGPoint(x: bottomOffset + cornerRadius, y: height))
//        path.addQuadCurve(to: CGPoint(x: bottomOffset, y: height - cornerRadius),
//                          controlPoint: CGPoint(x: bottomOffset, y: height))
//
//        // Left straight line up
//        path.addLine(to: CGPoint(x: topOffset, y: cornerRadius))
//        path.addQuadCurve(to: CGPoint(x: topOffset + cornerRadius, y: 0),
//                          controlPoint: CGPoint(x: topOffset, y: 0))
//
//        path.close()
//
//        glassLayer.path = path.cgPath
//        glassLayer.strokeColor = UIColor.black.cgColor
//        glassLayer.fillColor = UIColor.black.withAlphaComponent(0.8).cgColor
//        glassLayer.lineWidth = 5
//        layer.addSublayer(glassLayer)
//    }
//
//    private func drawWaterShape() {
//        let waterHeight: CGFloat = bounds.height * (1 - waterLevel)
//        
//        // Interpolating the top width to match the tapered shape of the glass
//        let topWidth = bounds.width * 0.67
//        let bottomWidth = bounds.width * 0.44
//        let bottomOffset = (bounds.width - bottomWidth) / 2
//        let heightB = bounds.height * 0.97
//        
//        // Calculate the current water width based on the height
//        let currentWaterWidth = bottomWidth + ((topWidth - bottomWidth) * waterLevel)
//        let currentOffset = (bounds.width - currentWaterWidth) / 2
//        
//        let waterPath = UIBezierPath()
//        
//        // **Start from Bottom-Left with rounded corner**
//        waterPath.move(to: CGPoint(x: bottomOffset + cornerRadius, y: heightB))
//        waterPath.addQuadCurve(to: CGPoint(x: bottomOffset, y: heightB - cornerRadius),
//                               controlPoint: CGPoint(x: bottomOffset, y: heightB))
//        
//        // **Move to Top-Left with rounded corner**
//        waterPath.addLine(to: CGPoint(x: currentOffset, y: waterHeight + cornerRadius))
//        waterPath.addQuadCurve(to: CGPoint(x: currentOffset + cornerRadius, y: waterHeight),
//                               controlPoint: CGPoint(x: currentOffset, y: waterHeight))
//        
//        // **Move to Top-Right with rounded corner**
//        waterPath.addLine(to: CGPoint(x: bounds.width - currentOffset - cornerRadius, y: waterHeight))
//        waterPath.addQuadCurve(to: CGPoint(x: bounds.width - currentOffset, y: waterHeight + cornerRadius),
//                               controlPoint: CGPoint(x: bounds.width - currentOffset, y: waterHeight))
//        
//        // **Move to Bottom-Right with rounded corner**
//        waterPath.addLine(to: CGPoint(x: bounds.width - bottomOffset, y: heightB - cornerRadius))
//        waterPath.addQuadCurve(to: CGPoint(x: bounds.width - bottomOffset - cornerRadius, y: heightB),
//                               controlPoint: CGPoint(x: bounds.width - bottomOffset, y: heightB))
//        
//        waterPath.close()
//        
//        waterLayer.path = waterPath.cgPath
//        waterLayer.fillColor = waterFillColor.cgColor
//        layer.addSublayer(waterLayer)
//    }
//
//    private func updateWaterLevel() {
//        drawWaterShape() // Redraw water when level changes
//    }
//}
