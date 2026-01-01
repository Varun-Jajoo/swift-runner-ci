//
//  VerticalRulerView.swift
//  MyPT
//
//  Created by Radha on 01/01/26.
//

import Foundation
import UIKit


final class VerticalRulerView: UIView {
    
    // MARK: - Configuration
    var minValue = 0
    var maxValue = 200
    var step = 1
    var majorStep = 5
    
    let lineSpacing: CGFloat = 13
    
    // MARK: - Colors
    var majorLineColor: UIColor = .lightGray
    var minorLineColor: UIColor = .lightGray
    var numberColor: UIColor = .white.withAlphaComponent(0.5)
    var backgroundRulerColor: UIColor = .clear
    
    var majorLineStartColor: UIColor = .white.withAlphaComponent(0.5)
    var majorLineEndColor: UIColor = UIColor.white.withAlphaComponent(0)
    
    var minorLineStartColor: UIColor = .white.withAlphaComponent(0.2)
    var minorLineEndColor: UIColor = UIColor.white.withAlphaComponent(0)
    
    /// Y position of center indicator (in ruler coordinate space)
    var indicatorY: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    /// Distance threshold to consider selected
    let selectionTolerance: CGFloat = 6
    
    /// Final snapped value
    var selectedValue: Int? {
        didSet { setNeedsDisplay() }
    }
    
    /// Padding in ruler units (cm or inches)
    var edgePaddingUnits: Int = 1
    
    private var edgePadding: CGFloat {
        CGFloat(edgePaddingUnits) * lineSpacing
    }
    
    
    enum HeightUnit {
        case feet
        case centimeters
    }
    
    var heightUnit: HeightUnit = .centimeters {
        didSet {
            configureScale()
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: 60,
            height: CGFloat(maxValue - minValue) * lineSpacing
            + edgePadding * 2
        )
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        configureScale()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for value in stride(from: minValue, through: maxValue, by: step) {
            //            let y = CGFloat(value - minValue) * lineSpacing
            let y = CGFloat(value - minValue) * lineSpacing + edgePadding
            let isMajor = value % majorStep == 0
            
            let lineLength: CGFloat = isMajor ? 30 : 15
            let startX = rect.width - lineLength
            let endX = rect.width
            
            let colors = isMajor
            ? [majorLineStartColor.cgColor, majorLineEndColor.cgColor]
            : [minorLineStartColor.cgColor, minorLineEndColor.cgColor]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            )!
            
            context.saveGState()
            
            context.move(to: CGPoint(x: startX, y: y))
            context.addLine(to: CGPoint(x: endX, y: y))
            context.setLineWidth(1)
            context.replacePathWithStrokedPath()
            context.clip()
            
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: startX, y: y),
                end: CGPoint(x: endX, y: y),
                options: []
            )
            
            context.restoreGState()
            
            if isMajor {
                if (value % (heightUnit == .feet ? 12 : 10)) == 0 {
                    let text = displayText(for: value)
                    //                    let isSelected = abs(y - indicatorY) < selectionTolerance
                    let isSelected: Bool
                    
                    if let selectedValue {
                        //                        let selectedY = CGFloat(selectedValue - minValue) * lineSpacing
                        let selectedY = CGFloat(selectedValue - minValue) * lineSpacing + edgePadding
                        
                        isSelected = abs(y - selectedY) < selectionTolerance
                    } else {
                        isSelected = abs(y - indicatorY) < selectionTolerance
                    }
                    
                    //                    let isSelected = abs(y - indicatorY) < selectionTolerance
                    
                    
                    
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: isSelected ? 14 : 12),
                        .foregroundColor: isSelected
                        ? UIColor.clear
                        : numberColor
                    ]
                    
                    //                    text.draw(at: CGPoint(x: 20 , y: y - 7), withAttributes: attrs)
                    let textX: CGFloat = heightUnit == .centimeters ? 10 : 20
                    text.draw(at: CGPoint(x: textX, y: y - 7), withAttributes: attrs)
                    
                }
            }
        }
    }
    
    
    private func configureScale() {
        switch heightUnit {
        case .feet:
            // Total inches: 0 ft – 10 ft → 0 – 120 inches
            minValue = 0
            maxValue = 120
            step = 1               // 1 inch
            majorStep = 6         // 1 foot
            
        case .centimeters:
            minValue = 0
            maxValue = 312
            step = 1               // 1 cm
            majorStep = 5         // every 10 cm
        }
    }
    
    func displayText(for value: Int) -> String {
        switch heightUnit {
        case .feet:
            let feet = value / 12
            let inches = value % 12
            
            // Show only full feet labels
            if inches == 0 {
                return "\(feet) ft"
            } else {
                return "\(feet)ft \(inches)in"
            }
            
        case .centimeters:
            return "\(value) cm"
        }
    }
    
    func scrollToValue(
        rulerView : VerticalRulerView,
        scrollView : UIScrollView,
        _ value: Int,
        animated: Bool = true
    ) {
        let clampedValue = max(
            rulerView.minValue,
            min(value, rulerView.maxValue)
        )
        
        // Convert value → ruler Y (same math as draw(_:))
        let rulerY =
        CGFloat(clampedValue - rulerView.minValue) * rulerView.lineSpacing
        
        // Center that Y inside the scrollView
        let targetOffsetY =
        rulerY
        - (scrollView.bounds.height / 2)
        + (rulerView.lineSpacing / 2)
        
        // Clamp scroll offset
        let maxOffsetY =
        scrollView.contentSize.height - scrollView.bounds.height
        
        let finalOffsetY = max(0, min(targetOffsetY, maxOffsetY))
        
        scrollView.setContentOffset(
            CGPoint(x: 0, y: finalOffsetY),
            animated: animated
        )
        // Sync selection
        rulerView.selectedValue = clampedValue
    }
    
    func scrollToCentimeter(
        _ cm: Int,
        scrollView: UIScrollView,
        animated: Bool = true
    ) {
        // Ensure ruler is in CM mode
        heightUnit = .centimeters
        
        // Clamp CM value
        let clampedValue = max(minValue, min(cm, maxValue))
        
        // SAME math as draw(_:)
        let rulerY =
        CGFloat(clampedValue - minValue) * lineSpacing
        
        // Center inside scrollView
        let targetOffsetY =
        rulerY
        - (scrollView.bounds.height / 2)
        + (lineSpacing / 2)
        
        // Clamp scroll offset
        let maxOffsetY =
        scrollView.contentSize.height - scrollView.bounds.height
        
        let finalOffsetY = max(0, min(targetOffsetY, maxOffsetY))
        
        scrollView.setContentOffset(
            CGPoint(x: 0, y: finalOffsetY),
            animated: animated
        )
        
        // Sync selection
        selectedValue = clampedValue
    }
}
