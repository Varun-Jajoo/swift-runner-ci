//
//  CustomProgressBar.swift
//  MyPT
//
//  Created by techsaga corp on 16/08/25.
//

import UIKit

class CustomProgressBar: UIView {
    
    private let tickLayer = CAShapeLayer()
    private let progressLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    
    private var currentProgress: CGFloat = 0
    
    var progress: CGFloat = 0 {
        didSet {
            setProgress(progress, animated: true)
        }
    }
        
    var progersColor: [CGColor] = [ UIColor.black.cgColor, UIColor.orange.cgColor ]
    {
        didSet
        {
            progressLayer.colors = progersColor
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        createTicks()
        createProgress()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        createTicks()
        createProgress()
    }
    
    private func createTicks() {
        let tickPath = UIBezierPath()
        let tickWidth: CGFloat = 2
        let tickSpacing: CGFloat = 6
        
        for x in stride(from: 0, through: bounds.width, by: tickSpacing) {
            tickPath.move(to: CGPoint(x: x, y: 0))
            tickPath.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        
        tickLayer.path = tickPath.cgPath
        tickLayer.strokeColor = UIColor.black.withAlphaComponent(0.5).cgColor
        tickLayer.lineWidth = tickWidth
        layer.addSublayer(tickLayer)
    }
    
    private func createProgress() {
        progressLayer.colors = progersColor
        progressLayer.startPoint = CGPoint(x: 0, y: 0.5)
        progressLayer.endPoint = CGPoint(x: 1, y: 0.5)
        progressLayer.frame = bounds
        
        // Initial mask
        maskLayer.path = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: 0, height: bounds.height),
            cornerRadius: bounds.height / 2
        ).cgPath
        
        progressLayer.mask = maskLayer
        layer.addSublayer(progressLayer)
    }
    
    /// Animate progress change
    func setProgress(_ value: CGFloat, animated: Bool) {
        let clamped = min(max(value, 0), 1) // clamp 0...1
        let newWidth = bounds.width * clamped
        let newPath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: newWidth, height: bounds.height),
            cornerRadius: bounds.height / 2
        ).cgPath
        
        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = maskLayer.path
            animation.toValue = newPath
            animation.duration = 0.35
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            maskLayer.add(animation, forKey: "progressAnim")
        }
        
        // Always update final state
        maskLayer.path = newPath
        currentProgress = clamped
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tickLayer.frame = bounds
        progressLayer.frame = bounds
        // keep current progress on rotation/resizing
        let width = bounds.width * currentProgress
        maskLayer.path = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: width, height: bounds.height),
            cornerRadius: bounds.height / 2
        ).cgPath
    }
}

