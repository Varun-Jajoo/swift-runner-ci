//
//  HorizontalRulerView.swift
//  MyPT
//
//  Created by Radha on 02/01/26.
//

import Foundation
import UIKit

final class HorizontalRulerView: UIView {
    
    // MARK: - Unit Selection
    var isKgSelected: Bool = true {
        didSet {
            maxValue = isKgSelected ? 600 : 1500
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    // MARK: - Configuration
    var minValue = 0
    private(set) var maxValue = 600
    var step = 1
    var majorStep = 5
    
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
    var edgePaddingUnits: Int = 1
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
            
            let x = CGFloat(value - minValue) * lineSpacing + edgePadding
            let isMajor = value % majorStep == 0
            let lineHeight: CGFloat = isMajor ? 28 : 14
            
            let colors = isMajor
            ? [majorLineStartColor.cgColor, majorLineEndColor.cgColor]
            : [minorLineStartColor.cgColor, minorLineEndColor.cgColor]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
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
                .foregroundColor: isSelected ? UIColor.clear : numberColor
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
    
    func scrollToValue(
        rulerView: HorizontalRulerView,
        scrollView: UIScrollView,
        _ value: Int,
        animated: Bool = true
    ) {
        let clampedValue = max(
            rulerView.minValue,
            min(value, rulerView.maxValue)
        )
        
        let rulerX =
        CGFloat(clampedValue - rulerView.minValue) * rulerView.lineSpacing
        + CGFloat(rulerView.edgePaddingUnits) * rulerView.lineSpacing
        
        let targetOffsetX =
        rulerX - scrollView.bounds.width / 2
        
        
        let maxOffsetX =
        scrollView.contentSize.width - scrollView.bounds.width
        
        let finalOffsetX = max(0, min(targetOffsetX, maxOffsetX))
        
        scrollView.setContentOffset(
            CGPoint(x: finalOffsetX, y: 0),
            animated: animated
        )
        rulerView.selectedValue = clampedValue
    }
}
