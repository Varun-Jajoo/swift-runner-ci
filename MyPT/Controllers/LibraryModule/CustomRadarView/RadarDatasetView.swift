//
//  RadarChartView.swift
//  MyPT
//
//  Created by techsaga corp on 16/08/25.
//

import UIKit

class RadarDatasetView: UIView {
    
    var fillColor: UIColor = UIColor(red: 161/255, green: 221/255, blue: 112/255, alpha: 0.3) {
        didSet { setNeedsDisplay() }
    }
    
    var strokeColor: UIColor = UIColor(red: 0.54, green: 0.65, blue: 0.51, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    
    var borderWidth: CGFloat = 3.0 {
        didSet { setNeedsDisplay() }
    }
    
    /// Input values expected in 0.0 ... 1.0
    var outerFactors: [CGFloat] = [1.0, 0.7, 0.4, 0.5, 1.0, 0.6] {
        didSet {
            recomputeFactors()
            setNeedsDisplay()
        }
    }
    
    private var mappedOuterFactors: [CGFloat] = []
    private var innerFactors: [CGFloat] = []
    private var outerCornerRatios: [CGFloat] = []
    private var innerCornerRatios: [CGFloat] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        recomputeFactors()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        recomputeFactors()
    }
    
    /// Recompute ratios based on current outerFactors
    private func recomputeFactors() {
        // Map input [0.0 ... 1.0] → [0.4 ... 1.0]
        mappedOuterFactors = outerFactors.map { factor in
            return 0.4 + factor * 0.6
        }
        
        innerFactors = mappedOuterFactors.map { outer in
            let depthScale: CGFloat = 0.35
            return max(0.05, outer * depthScale)
        }
        
        outerCornerRatios = mappedOuterFactors.map { factor in
            0.1 + (factor * 0.15) // between 0.1 ... 0.25
        }
        
        innerCornerRatios = mappedOuterFactors.map { factor in
            0.04 + (factor * 0.05) // between 0.04 ... 0.09
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor = .clear
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2 - borderWidth
        let numberOfPoints = mappedOuterFactors.count
        let angleStep = (2 * CGFloat.pi) / CGFloat(numberOfPoints * 2)
        
        // Build star vertices (outer + inner alternating)
        var points: [CGPoint] = []
        for i in 0..<(numberOfPoints * 2) {
            let isOuter = (i % 2 == 0)
            let index = i / 2
            let radius: CGFloat = isOuter
                ? maxRadius * mappedOuterFactors[index]
                : maxRadius * innerFactors[index]
            
            let angle = CGFloat(i) * angleStep - .pi/2
            let point = CGPoint(x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius)
            points.append(point)
        }
        
        let path = UIBezierPath()
        
        // Build path with per-corner rounding
        for i in 0..<points.count {
            let prev = points[(i - 1 + points.count) % points.count]
            let current = points[i]
            let next = points[(i + 1) % points.count]
            
            let v1 = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
            let v2 = CGPoint(x: next.x - current.x, y: next.y - current.y)
            
            let len1 = sqrt(v1.x * v1.x + v1.y * v1.y)
            let len2 = sqrt(v2.x * v2.x + v2.y * v2.y)
            
            let u1 = CGPoint(x: v1.x / len1, y: v1.y / len1)
            let u2 = CGPoint(x: v2.x / len2, y: v2.y / len2)
            
            let index = i / 2
            let cornerRadius: CGFloat
            if i % 2 == 0 {
                cornerRadius = maxRadius * outerCornerRatios[index]
            } else {
                cornerRadius = maxRadius * innerCornerRatios[index]
            }
            
            let start = CGPoint(x: current.x + u1.x * cornerRadius,
                                y: current.y + u1.y * cornerRadius)
            let end = CGPoint(x: current.x + u2.x * cornerRadius,
                              y: current.y + u2.y * cornerRadius)
            
            if i == 0 {
                path.move(to: start)
            } else {
                path.addLine(to: start)
            }
            
            path.addQuadCurve(to: end, controlPoint: current)
        }
        
        path.close()
        
        fillColor.setFill()
        path.fill()
        
        strokeColor.setStroke()
        path.lineWidth = borderWidth
        path.stroke()
    }
}


/*
class RadarDatasetView: UIView {
        
    var fillColor: UIColor = UIColor(red: 161/255, green: 221/255, blue: 112/255, alpha: 0.3) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var strokeColor: UIColor = UIColor(red: 0.54, green: 0.65, blue: 0.51, alpha: 1.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var borderWidth: CGFloat = 3.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Dynamic outer factors
    var outerFactors: [CGFloat] = [1.0, 0.7, 0.4, 0.5, 1.0, 0.6] {
        didSet {
            recomputeFactors()
            setNeedsDisplay()
        }
    }
    
    private var innerFactors: [CGFloat] = []
    private var outerCornerRatios: [CGFloat] = []
    private var innerCornerRatios: [CGFloat] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        recomputeFactors()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        recomputeFactors()
    }
    
    /// Recompute inner/outer ratios based on current outerFactors
    private func recomputeFactors() {
        innerFactors = outerFactors.map { outer in
            let depthScale: CGFloat = 0.35
            return max(0.05, outer * depthScale)
        }
        
        outerCornerRatios = outerFactors.map { factor in
            0.1 + (factor * 0.15) // between 0.1 ... 0.25
        }
        
        innerCornerRatios = outerFactors.map { factor in
            0.04 + (factor * 0.05) // between 0.04 ... 0.09
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor = .clear
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2 - borderWidth
        let numberOfPoints = outerFactors.count
        let angleStep = (2 * CGFloat.pi) / CGFloat(numberOfPoints * 2)
        
        // Build star vertices (outer + inner alternating)
        var points: [CGPoint] = []
        for i in 0..<(numberOfPoints * 2) {
            let isOuter = (i % 2 == 0)
            let index = i / 2
            let radius: CGFloat = isOuter
                ? maxRadius * outerFactors[index]
                : maxRadius * innerFactors[index]
            
            let angle = CGFloat(i) * angleStep - .pi/2
            let point = CGPoint(x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius)
            points.append(point)
        }
        
        let path = UIBezierPath()
        
        // Build path with per-corner rounding
        for i in 0..<points.count {
            let prev = points[(i - 1 + points.count) % points.count]
            let current = points[i]
            let next = points[(i + 1) % points.count]
            
            let v1 = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
            let v2 = CGPoint(x: next.x - current.x, y: next.y - current.y)
            
            let len1 = sqrt(v1.x * v1.x + v1.y * v1.y)
            let len2 = sqrt(v2.x * v2.x + v2.y * v2.y)
            
            let u1 = CGPoint(x: v1.x / len1, y: v1.y / len1)
            let u2 = CGPoint(x: v2.x / len2, y: v2.y / len2)
            
            let index = i / 2
            let cornerRadius: CGFloat
            if i % 2 == 0 {
                cornerRadius = maxRadius * outerCornerRatios[index]
            } else {
                cornerRadius = maxRadius * innerCornerRatios[index]
            }
            
            let start = CGPoint(x: current.x + u1.x * cornerRadius,
                                y: current.y + u1.y * cornerRadius)
            let end = CGPoint(x: current.x + u2.x * cornerRadius,
                              y: current.y + u2.y * cornerRadius)
            
            if i == 0 {
                path.move(to: start)
            } else {
                path.addLine(to: start)
            }
            
            path.addQuadCurve(to: end, controlPoint: current)
        }
        
        path.close()
        
        fillColor.setFill()
        path.fill()
        
        strokeColor.setStroke()
        path.lineWidth = borderWidth
        path.stroke()
    }
}

*/


/*  fine but some ratio
class StarShapeViewWithRoundedCorners: UIView {
    
    let fillColor = UIColor(red: 161/255, green: 221/255, blue: 112/255, alpha: 0.3)
    let strokeColor = UIColor(red: 0.54, green: 0.65, blue: 0.51, alpha: 1.0)
    let borderWidth: CGFloat = 3.0
    
    // Per-corner customization
    // 6 outer tips → define their relative lengths (1.0 = full outer radius)
//    let outerFactors: [CGFloat] = [1.0, 0.9, 1.1, 0.8, 1.05, 0.95]
    
    let outerFactors: [CGFloat] = [1.0, 0.7, 0.8, 0.5, 1.0, 0.6]
    
    // 6 inner valleys → define their relative depths (smaller = deeper valley)
    let innerFactors: [CGFloat] = [0.25, 0.3, 0.2, 0.28, 0.22, 0.27]
    
    // Corner roundness (outer vs inner) – each corner unique
    let outerCornerRatios: [CGFloat] = [0.15, 0.20, 0.1, 0.18, 0.22, 0.12]
    let innerCornerRatios: [CGFloat] = [0.05, 0.08, 0.04, 0.07, 0.06, 0.05]
    
    override func draw(_ rect: CGRect) {
        backgroundColor = .clear
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2 - borderWidth
        let numberOfPoints = 6
        let angleStep = (2 * CGFloat.pi) / CGFloat(numberOfPoints * 2)
        
        // Build star vertices (outer + inner alternating)
        var points: [CGPoint] = []
        for i in 0..<(numberOfPoints * 2) {
            let isOuter = (i % 2 == 0)
            let index = i / 2  // maps 0,2,4,... → 0..5 for outer; 1,3,5... → 0..5 for inner
            
            var radius: CGFloat
            if isOuter {
                radius = maxRadius * outerFactors[index % outerFactors.count]
            } else {
                radius = maxRadius * innerFactors[index % innerFactors.count]
            }
            
            let angle = CGFloat(i) * angleStep - .pi/2
            let point = CGPoint(x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius)
            points.append(point)
        }
        
        let path = UIBezierPath()
        
        // Build path with per-corner rounding
        for i in 0..<points.count {
            let prev = points[(i - 1 + points.count) % points.count]
            let current = points[i]
            let next = points[(i + 1) % points.count]
            
            let v1 = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
            let v2 = CGPoint(x: next.x - current.x, y: next.y - current.y)
            
            let len1 = sqrt(v1.x * v1.x + v1.y * v1.y)
            let len2 = sqrt(v2.x * v2.x + v2.y * v2.y)
            
            let u1 = CGPoint(x: v1.x / len1, y: v1.y / len1)
            let u2 = CGPoint(x: v2.x / len2, y: v2.y / len2)
            
            // Decide corner radius depending on outer/inner and index
            let index = i / 2
            let cornerRadius: CGFloat
            if i % 2 == 0 { // outer tip
                cornerRadius = maxRadius * outerCornerRatios[index % outerCornerRatios.count]
            } else {        // inner valley
                cornerRadius = maxRadius * innerCornerRatios[index % innerCornerRatios.count]
            }
            
            let start = CGPoint(x: current.x + u1.x * cornerRadius,
                                y: current.y + u1.y * cornerRadius)
            let end = CGPoint(x: current.x + u2.x * cornerRadius,
                              y: current.y + u2.y * cornerRadius)
            
            if i == 0 {
                path.move(to: start)
            } else {
                path.addLine(to: start)
            }
            
            path.addQuadCurve(to: end, controlPoint: current)
        }
        
        path.close()
        
        fillColor.setFill()
        path.fill()
        
        strokeColor.setStroke()
        path.lineWidth = borderWidth
        path.stroke()
    }
}
*/



