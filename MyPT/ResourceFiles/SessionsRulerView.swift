//
//  SessionsRulerView.swift
//  MyPT
//
//  Created by Radha on 02/01/26.
//
import UIKit

enum SessionRulerType {
    case session
    case days
}

final class SessionsRulerView: UIView {
    
    // MARK: - Configuration
    var sessionType: SessionRulerType = .session {
            didSet {
                maxValue = sessionType == .session ? 115 : 380
                invalidateIntrinsicContentSize()
                setNeedsDisplay()
            }
        }
    var minValue = -14
    var maxValue = 115
    var step = 1
    var majorStep = 5
    var flowGymwork:calendarFlow = .defaultFlow
    let lineSpacing: CGFloat = 13
    
    // MARK: - Colors
    var numberColor: UIColor = .white.withAlphaComponent(0.5)
    
    var majorLineStartColor: UIColor = .white.withAlphaComponent(0.5)
    var majorLineEndColor: UIColor = .clear
    
    var minorLineStartColor: UIColor = .white.withAlphaComponent(0.2)
    var minorLineEndColor: UIColor = .clear
    
    // MARK: - Selection
    var indicatorX: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    var selectedValue: Int? {
        didSet { setNeedsDisplay() }
    }
    
    let selectionTolerance: CGFloat = 6
    
    // MARK: - Padding
    var edgePaddingUnits: Int = 0
    private var edgePadding: CGFloat {
        CGFloat(edgePaddingUnits) * lineSpacing
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Size
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: CGFloat(maxValue - minValue) * lineSpacing + edgePadding * 2,
            height: 60
        )
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for value in stride(from: minValue, through: maxValue, by: step) {
            
//            let shouldHide = (value < 0 || value > 100)
            let shouldHide = (value < 0 || value > (sessionType == .session ? 100 : 365))
            
            let x = CGFloat(value - minValue) * lineSpacing + edgePadding
            let isMajor = value % majorStep == 0
            let lineHeight: CGFloat = isMajor ? 28 : 14
            
//            let colors = isMajor
//            ? [majorLineStartColor.cgColor, majorLineEndColor.cgColor]
//            : [minorLineStartColor.cgColor, minorLineEndColor.cgColor]
            
            let startColor: UIColor
            let endColor: UIColor
            
            if shouldHide {
                startColor = .clear
                endColor = .clear
            } else if isMajor {
                startColor = majorLineStartColor
                endColor = majorLineEndColor
            } else {
                startColor = minorLineStartColor
                endColor = minorLineEndColor
            }
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [startColor.cgColor, endColor.cgColor] as CFArray,
                locations: [0, 1]
            )!
            
            context.saveGState()
            context.move(to: CGPoint(x: x, y: rect.height - lineHeight))
            context.addLine(to: CGPoint(x: x, y: rect.height))
            context.setLineWidth(1)
            context.replacePathWithStrokedPath()
            context.clip()
            
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: x, y: rect.height - lineHeight),
                end: CGPoint(x: x, y: rect.height),
                options: []
            )
            context.restoreGState()
            
            guard isMajor, value % 5 == 0 else { continue }
            
            let isSelected = (value == selectedValue)
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: isSelected ? 14 : 12),
                .foregroundColor: isSelected ? UIColor.clear : shouldHide ? UIColor.clear : numberColor
            ]
            
            let text = "\(value)"
            let size = text.size(withAttributes: attrs)
            
            text.draw(
                at: CGPoint(x: x - size.width / 2,
                            y: rect.height - lineHeight - 20),
                withAttributes: attrs
            )
        }
    }
    
//    func scrollToValue(
//        rulerView: SessionsRulerView,
//        scrollView: UIScrollView,
//        _ value: Int,
//        animated: Bool = true
//    ) {
//        let clampedValue = max(
//            rulerView.minValue,
//            min(value, rulerView.maxValue)
//        )
//        
//        let rulerX =
//        CGFloat(clampedValue - rulerView.minValue) * rulerView.lineSpacing
//        + CGFloat(rulerView.edgePaddingUnits) * rulerView.lineSpacing
//        
//        let targetOffsetX =
//        rulerX - scrollView.bounds.width / 2
//        
//        
//        let maxOffsetX =
//        scrollView.contentSize.width - scrollView.bounds.width
//        
//        let finalOffsetX = max(0, min(targetOffsetX, maxOffsetX))
//        
//        scrollView.setContentOffset(
//            CGPoint(x: finalOffsetX, y: 0),
//            animated: animated
//        )
//        rulerView.selectedValue = clampedValue
//    }
    
    func scrollToValue(rulerView : SessionsRulerView, scrollView : UIScrollView , _ value: Int, animated: Bool = true) {

        let clampedValue = max(rulerView.minValue, min(value, rulerView.maxValue))
        scrollView.layoutIfNeeded()

        let valueX =
            CGFloat(clampedValue - rulerView.minValue) * rulerView.lineSpacing

        let offsetX =
            valueX
            - scrollView.bounds.width / 2
            + scrollView.contentInset.left

        let maxOffsetX =
            max(0, scrollView.contentSize.width - scrollView.bounds.width)

        scrollView.setContentOffset(
            CGPoint(x: min(max(offsetX, 0), maxOffsetX), y: 0),
            animated: animated
        )
    }

    
    
}


//import UIKit

//final class SessionsRulerView: UIView {
//
//    // MARK: - Configuration
//    var minValue = -14
//    var maxValue = 1014
//    var step = 1
//    var majorStep = 5
//
//    let lineSpacing: CGFloat = 13
//
//    // MARK: - Colors
//    var numberColor: UIColor = .white.withAlphaComponent(0.5)
//
//    var majorLineStartColor: UIColor = .white.withAlphaComponent(0.5)
//    var majorLineEndColor: UIColor = .clear
//
//    var minorLineStartColor: UIColor = .white.withAlphaComponent(0.2)
//    var minorLineEndColor: UIColor = .clear
//
//    // MARK: - Selection
//    var indicatorX: CGFloat = 0 {
//        didSet { setNeedsDisplay() }
//    }
//
//    var selectedValue: Int? {
//        didSet { setNeedsDisplay() }
//    }
//
//    let selectionTolerance: CGFloat = 6
//
//    // MARK: - Padding
//    var edgePaddingUnits: Int = 1
//    private var edgePadding: CGFloat {
//        CGFloat(edgePaddingUnits) * lineSpacing
//    }
//
//    // MARK: - Init
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .clear
//        isOpaque = false
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Size
//    override var intrinsicContentSize: CGSize {
//        CGSize(
//            width: CGFloat(maxValue - minValue) * lineSpacing + edgePadding * 2,
//            height: 60
//        )
//    }
//
//    // MARK: - Drawing
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        for value in stride(from: minValue, through: maxValue, by: step) {
//
//            // Hide visually but keep spacing
//            let shouldHide = (value < 0 || value > 1000)
//
//            let x = CGFloat(value - minValue) * lineSpacing + edgePadding
//            let isMajor = value % majorStep == 0
//            let lineHeight: CGFloat = isMajor ? 28 : 14
//
//            let startColor: UIColor
//            let endColor: UIColor
//
//            if shouldHide {
//                startColor = .clear
//                endColor = .clear
//            } else if isMajor {
//                startColor = majorLineStartColor
//                endColor = majorLineEndColor
//            } else {
//                startColor = minorLineStartColor
//                endColor = minorLineEndColor
//            }
//
//            let gradient = CGGradient(
//                colorsSpace: CGColorSpaceCreateDeviceRGB(),
//                colors: [startColor.cgColor, endColor.cgColor] as CFArray,
//                locations: [0, 1]
//            )!
//
//            context.saveGState()
//            context.move(to: CGPoint(x: x, y: rect.height - lineHeight))
//            context.addLine(to: CGPoint(x: x, y: rect.height))
//            context.setLineWidth(1)
//            context.replacePathWithStrokedPath()
//            context.clip()
//
//            context.drawLinearGradient(
//                gradient,
//                start: CGPoint(x: x, y: rect.height - lineHeight),
//                end: CGPoint(x: x, y: rect.height),
//                options: []
//            )
//            context.restoreGState()
//
//            // Draw text only for major steps
//            guard isMajor else { continue }
//
//            let attrs: [NSAttributedString.Key: Any] = [
//                .font: UIFont.systemFont(ofSize: 12),
//                .foregroundColor: shouldHide ? UIColor.clear : numberColor
//            ]
//
//            let text = "\(value)"
//            let size = text.size(withAttributes: attrs)
//
//            text.draw(
//                at: CGPoint(
//                    x: x - size.width / 2,
//                    y: rect.height - lineHeight - 20
//                ),
//                withAttributes: attrs
//            )
//        }
//    }
//
//    // MARK: - Scroll to Value
//    func scrollToValue(
//        rulerView: SessionsRulerView,
//        scrollView: UIScrollView,
//        _ value: Int,
//        animated: Bool = true
//    ) {
//        let clampedValue = max(
//            rulerView.minValue,
//            min(value, rulerView.maxValue)
//        )
//
//        let rulerX =
//            CGFloat(clampedValue - rulerView.minValue) * rulerView.lineSpacing
//            + CGFloat(rulerView.edgePaddingUnits) * rulerView.lineSpacing
//
//        let targetOffsetX =
//            rulerX - scrollView.bounds.width / 2
//
//        let maxOffsetX =
//            scrollView.contentSize.width - scrollView.bounds.width
//
//        let finalOffsetX =
//            max(0, min(targetOffsetX, maxOffsetX))
//
//        scrollView.setContentOffset(
//            CGPoint(x: finalOffsetX, y: 0),
//            animated: animated
//        )
//
//        rulerView.selectedValue = clampedValue
//    }
//}
