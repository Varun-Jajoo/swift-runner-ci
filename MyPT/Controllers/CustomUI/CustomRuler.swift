//
//  CustomRuler.swift
//  MyPT
//
//  Created by techsaga corp on 10/01/25.
//

import UIKit

class RulerView: UIView {
    var numberOfTicks: Int = 100           // Total number of ticks
    var majorTickHeight: CGFloat = 20      // Height of major ticks
    var minorTickHeight: CGFloat = 10      // Height of minor ticks
    var majorTickColor: UIColor = .black   // Color for major ticks
    var minorTickColor: UIColor = .gray    // Color for minor ticks
    var labelColor: UIColor = .blue        // Color for labels
    var labelFontNormal: UIFont = UIFont.systemFont(ofSize: 10.0)
    var labelFontSelected: UIFont = UIFont.boldSystemFont(ofSize: 12.0)
    var selectedTickColor: UIColor = .red  // Color for selected tick
    var selectedIndex: Int = 50            // Index of the selected tick
    var tickSpacing: CGFloat = 0           // Dynamic spacing between ticks
    
    private var labels: [UILabel] = []     // Array to hold labels
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Dynamically calculate the spacing between ticks
        tickSpacing = bounds.width / CGFloat(numberOfTicks)
        
        // Only redraw if necessary (e.g., when the view's bounds change)
        updateLabels()
        setNeedsDisplay() // Trigger redraw to update tick positions
    }
    
    // Create or update labels as needed
    func updateLabels() {
        // Remove any old labels if necessary
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        // Add new labels based on current state
        for i in 0...numberOfTicks {
            if i % 10 == 0 {
                let xPosition = CGFloat(i) * tickSpacing
                let label = UILabel(frame: CGRect(x: xPosition - 15, y: 0, width: 30, height: 20))
                label.text = "\(i)"
                label.font = (i == selectedIndex) ? labelFontSelected : labelFontNormal
                label.textAlignment = .center
                label.textColor = (i == selectedIndex) ? selectedTickColor : labelColor
                addSubview(label)
                labels.append(label) // Keep track of labels for cleanup
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw the ticks
        for i in 0...numberOfTicks {
            let xPosition = CGFloat(i) * tickSpacing
            let tickHeight = (i % 10 == 0) ? majorTickHeight : minorTickHeight
            let tickColor = (i == selectedIndex) ? selectedTickColor : (i % 10 == 0 ? majorTickColor : minorTickColor)
            
            // Set tick color
            context.setStrokeColor(tickColor.cgColor)
            context.setLineWidth(1.0)
            
            // Draw the tick
            context.move(to: CGPoint(x: xPosition, y: rect.height - tickHeight))
            context.addLine(to: CGPoint(x: xPosition, y: rect.height))
            context.strokePath()
        }
    }
}

/*
class RulerControl: UIControl, UIScrollViewDelegate {
    
    // MARK: - Configurable Properties
    var numberOfTicks: Int = 10000 {
        didSet { setupContent() }
    }
    var tickSpacing: CGFloat = 20
    var majorTickHeight: CGFloat = 20
    var minorTickHeight: CGFloat = 10
    var majorTickColor: UIColor = .black
    var minorTickColor: UIColor = .gray
    var labelColor: UIColor = .blue
    var selectedTickColor: UIColor = .red
    
    private(set) var selectedIndex: Int = 0 {
        didSet {
            if selectedIndex != oldValue {
                sendActions(for: .valueChanged)
            }
        }
    }
    
    // MARK: - Subviews
    private let scrollView = UIScrollView()
    private var contentView: RulerCustomView!
    
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
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        setupContent()
    }
    
    private func setupContent() {
        contentView?.removeFromSuperview()
        let width = CGFloat(numberOfTicks) * tickSpacing
        contentView = RulerCustomView(frame: CGRect(x: 0, y: 0, width: width, height: bounds.height))
        contentView.configure(
            numberOfTicks: numberOfTicks,
            tickSpacing: tickSpacing,
            majorTickHeight: majorTickHeight,
            minorTickHeight: minorTickHeight,
            majorTickColor: majorTickColor,
            minorTickColor: minorTickColor,
            labelColor: labelColor,
            selectedTickColor: selectedTickColor
        )
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.bounds.size
        setSelectedIndex(selectedIndex, animated: false)
    }
    
    // MARK: - Selection
    private func updateSelection() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let index = Int(round(centerX / tickSpacing))
        
        if index != selectedIndex, index >= 0, index <= numberOfTicks {
            selectedIndex = index
            contentView.selectedIndex = index
            contentView.setNeedsDisplay()
        }
    }
    
    private func snapToNearestTick() {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let index = Int(round(centerX / tickSpacing))
        let targetOffsetX = CGFloat(index) * tickSpacing - scrollView.bounds.width / 2
        let clampedOffsetX = max(0, min(targetOffsetX, scrollView.contentSize.width - scrollView.bounds.width))
        scrollView.setContentOffset(CGPoint(x: clampedOffsetX, y: 0), animated: true)
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool) {
        let targetOffsetX = CGFloat(index) * tickSpacing - scrollView.bounds.width / 2
        let clampedOffsetX = max(0, min(targetOffsetX, scrollView.contentSize.width - scrollView.bounds.width))
        scrollView.setContentOffset(CGPoint(x: clampedOffsetX, y: 0), animated: animated)
        updateSelection()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelection()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestTick()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { snapToNearestTick() }
    }
}

// MARK: - Content View
private class RulerCustomView: UIView {
    private var numberOfTicks: Int = 100
    private var tickSpacing: CGFloat = 20
    private var majorTickHeight: CGFloat = 20
    private var minorTickHeight: CGFloat = 10
    private var majorTickColor: UIColor = .black
    private var minorTickColor: UIColor = .gray
    private var labelColor: UIColor = .blue
    private var selectedTickColor: UIColor = .red
    var selectedIndex: Int = 0
    
    func configure(numberOfTicks: Int,
                   tickSpacing: CGFloat,
                   majorTickHeight: CGFloat,
                   minorTickHeight: CGFloat,
                   majorTickColor: UIColor,
                   minorTickColor: UIColor,
                   labelColor: UIColor,
                   selectedTickColor: UIColor) {
        self.numberOfTicks = numberOfTicks
        self.tickSpacing = tickSpacing
        self.majorTickHeight = majorTickHeight
        self.minorTickHeight = minorTickHeight
        self.majorTickColor = majorTickColor
        self.minorTickColor = minorTickColor
        self.labelColor = labelColor
        self.selectedTickColor = selectedTickColor
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let visibleMinIndex = max(0, Int(floor(rect.minX / tickSpacing)))
        let visibleMaxIndex = min(numberOfTicks, Int(ceil(rect.maxX / tickSpacing)))
        
        for i in visibleMinIndex...visibleMaxIndex {
            let x = CGFloat(i) * tickSpacing
            let tickHeight = (i % 10 == 0) ? majorTickHeight : minorTickHeight
            let tickColor: UIColor = (i == selectedIndex) ? selectedTickColor : (i % 10 == 0 ? majorTickColor : minorTickColor)
            
            ctx.setStrokeColor(tickColor.cgColor)
            ctx.setLineWidth(1.0)
            ctx.move(to: CGPoint(x: x, y: rect.height - tickHeight))
            ctx.addLine(to: CGPoint(x: x, y: rect.height))
            ctx.strokePath()
            
            if i % 10 == 0 {
                let text = "\(i)" as NSString
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: (i == selectedIndex) ? UIFont.boldSystemFont(ofSize: 12) : UIFont.systemFont(ofSize: 10),
                    .foregroundColor: (i == selectedIndex) ? selectedTickColor : labelColor
                ]
                let size = text.size(withAttributes: attrs)
                text.draw(at: CGPoint(x: x - size.width/2, y: rect.height - tickHeight - size.height - 2),
                          withAttributes: attrs)
            }
        }
    }
}
*/


//class RulerControl: UIControl, UIScrollViewDelegate {
//    
//    // MARK: - Configurable Properties
//    var numberOfTicks: Int = 10000 {
//        didSet { setupContent() }
//    }
//    var tickSpacing: CGFloat = 20
//    var majorTickHeight: CGFloat = 20
//    var minorTickHeight: CGFloat = 10
//    var majorTickColor: UIColor = .black
//    var minorTickColor: UIColor = .gray
//    var labelColor: UIColor = .blue
//    var selectedTickColor: UIColor = .red
//    
//    private(set) var selectedIndex: Int = 0 {
//        didSet {
//            if selectedIndex != oldValue {
//                sendActions(for: .valueChanged)
//            }
//        }
//    }
//    
//    // MARK: - Subviews
//    private let scrollView = UIScrollView()
//    private var contentView: RulerViewContent!
//    
//    // MARK: - Init
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        commonInit()
//    }
//    
//    private func commonInit() {
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.delegate = self
//        addSubview(scrollView)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        scrollView.frame = bounds
//        setupContent()
//    }
//    
//    private func setupContent() {
//        contentView?.removeFromSuperview()
//        let width = CGFloat(numberOfTicks) * tickSpacing
//        contentView = RulerViewContent(frame: CGRect(x: 0, y: 0, width: width, height: bounds.height))
//        contentView.configure(
//            numberOfTicks: numberOfTicks,
//            tickSpacing: tickSpacing,
//            majorTickHeight: majorTickHeight,
//            minorTickHeight: minorTickHeight,
//            majorTickColor: majorTickColor,
//            minorTickColor: minorTickColor,
//            labelColor: labelColor,
//            selectedTickColor: selectedTickColor
//        )
//        scrollView.addSubview(contentView)
//        scrollView.contentSize = contentView.bounds.size
//        setSelectedIndex(selectedIndex, animated: false)
//    }
//    
//    // MARK: - Selection
//    private func updateSelection() {
//        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
//        let index = Int(round(centerX / tickSpacing))
//        
//        if index != selectedIndex, index >= 0, index <= numberOfTicks {
//            selectedIndex = index
//            contentView.selectedIndex = index
//            contentView.setNeedsDisplay()
//        }
//    }
//    
//    private func snapToNearestTick() {
//        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
//        let index = Int(round(centerX / tickSpacing))
//        let targetOffsetX = CGFloat(index) * tickSpacing - scrollView.bounds.width / 2
//        let clampedOffsetX = max(0, min(targetOffsetX, scrollView.contentSize.width - scrollView.bounds.width))
//        scrollView.setContentOffset(CGPoint(x: clampedOffsetX, y: 0), animated: true)
//    }
//    
//    func setSelectedIndex(_ index: Int, animated: Bool) {
//        let targetOffsetX = CGFloat(index) * tickSpacing - scrollView.bounds.width / 2
//        let clampedOffsetX = max(0, min(targetOffsetX, scrollView.contentSize.width - scrollView.bounds.width))
//        scrollView.setContentOffset(CGPoint(x: clampedOffsetX, y: 0), animated: animated)
//        updateSelection()
//    }
//    
//    // MARK: - UIScrollViewDelegate
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        updateSelection()
//    }
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        snapToNearestTick()
//    }
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate { snapToNearestTick() }
//    }
//}
//
//// MARK: - RulerView Content View
//private class RulerViewContent: UIView {
//    private var numberOfTicks: Int = 100
//    private var tickSpacing: CGFloat = 20
//    private var majorTickHeight: CGFloat = 20
//    private var minorTickHeight: CGFloat = 10
//    private var majorTickColor: UIColor = .black
//    private var minorTickColor: UIColor = .gray
//    private var labelColor: UIColor = .blue
//    private var selectedTickColor: UIColor = .red
//    var selectedIndex: Int = 0
//    
//    func configure(numberOfTicks: Int,
//                   tickSpacing: CGFloat,
//                   majorTickHeight: CGFloat,
//                   minorTickHeight: CGFloat,
//                   majorTickColor: UIColor,
//                   minorTickColor: UIColor,
//                   labelColor: UIColor,
//                   selectedTickColor: UIColor) {
//        self.numberOfTicks = numberOfTicks
//        self.tickSpacing = tickSpacing
//        self.majorTickHeight = majorTickHeight
//        self.minorTickHeight = minorTickHeight
//        self.majorTickColor = majorTickColor
//        self.minorTickColor = minorTickColor
//        self.labelColor = labelColor
//        self.selectedTickColor = selectedTickColor
//    }
//    
//    override func draw(_ rect: CGRect) {
//        guard let ctx = UIGraphicsGetCurrentContext() else { return }
//        
//        let visibleMinIndex = max(0, Int(floor(rect.minX / tickSpacing)))
//        let visibleMaxIndex = min(numberOfTicks, Int(ceil(rect.maxX / tickSpacing)))
//        
//        for i in visibleMinIndex...visibleMaxIndex {
//            let x = CGFloat(i) * tickSpacing
//            let tickHeight = (i % 10 == 0) ? majorTickHeight : minorTickHeight
//            let tickColor: UIColor = (i == selectedIndex) ? selectedTickColor : (i % 10 == 0 ? majorTickColor : minorTickColor)
//            
//            ctx.setStrokeColor(tickColor.cgColor)
//            ctx.setLineWidth(1.0)
//            ctx.move(to: CGPoint(x: x, y: rect.height - tickHeight))
//            ctx.addLine(to: CGPoint(x: x, y: rect.height))
//            ctx.strokePath()
//            
//            if i % 10 == 0 {
//                let text = "\(i)" as NSString
//                let attrs: [NSAttributedString.Key: Any] = [
//                    .font: (i == selectedIndex) ? UIFont.boldSystemFont(ofSize: 12) : UIFont.systemFont(ofSize: 10),
//                    .foregroundColor: (i == selectedIndex) ? selectedTickColor : labelColor
//                ]
//                let size = text.size(withAttributes: attrs)
//                text.draw(at: CGPoint(x: x - size.width/2, y: rect.height - tickHeight - size.height - 2),
//                          withAttributes: attrs)
//            }
//        }
//    }
//}




//class RulerView: UIView {
//    var numberOfTicks: Int = 100           // Total number of ticks
//    var majorTickHeight: CGFloat = 20      // Height of major ticks
//    var minorTickHeight: CGFloat = 10      // Height of minor ticks
//    var majorTickColor: UIColor = .black   // Color for major ticks
//    var minorTickColor: UIColor = .gray    // Color for minor ticks
//    var labelColor: UIColor = .blue        // Color for labels
//    var labelFontNormal: UIFont = UIFont.systemFont(ofSize: 10.0)
//    var labelFontSelected: UIFont = UIFont.boldSystemFont(ofSize: 12.0)
//    var selectedTickColor: UIColor = .red  // Color for selected tick
//    var selectedIndex: Int = 50            // Index of the selected tick
//    var tickSpacing: CGFloat = 0           // Dynamic spacing between ticks
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        // Dynamically calculate the spacing between ticks
//        tickSpacing = bounds.width / CGFloat(numberOfTicks)
//        setNeedsDisplay() // Redraw the view with updated spacing
//    }
//
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        // Remove all subviews (labels) to avoid duplicates
//        self.subviews.forEach { $0.removeFromSuperview() }
//
//        for i in 0...numberOfTicks {
//            let xPosition = CGFloat(i) * tickSpacing
//            let tickHeight = (i % 10 == 0) ? majorTickHeight : minorTickHeight
//            let tickColor = (i == selectedIndex) ? selectedTickColor : (i % 10 == 0 ? majorTickColor : minorTickColor)
//
//            // Set tick color
//            context.setStrokeColor(tickColor.cgColor)
//            context.setLineWidth(1.0)
//
//            // Draw the tick
//            context.move(to: CGPoint(x: xPosition, y: rect.height - tickHeight))
//            context.addLine(to: CGPoint(x: xPosition, y: rect.height))
//            context.strokePath()
//
//            // Add label for major ticks at the top
//            if i % 10 == 0 {
//                let label = UILabel(frame: CGRect(x: xPosition - 15, y: 0, width: 30, height: 20))
//                label.text = "\(i)"
//                label.font = (i == selectedIndex) ? labelFontSelected : labelFontNormal
//                label.textAlignment = .center
//                label.textColor = (i == selectedIndex) ? selectedTickColor : labelColor
//                self.addSubview(label)
//            }
//        }
//    }
//}


//class RulerView: UIView {
//    var numberOfTicks: Int = 100           // Total number of ticks
//    var majorTickHeight: CGFloat = 20      // Height of major ticks
//    var minorTickHeight: CGFloat = 10      // Height of minor ticks
//    var majorTickColor: UIColor = .black   // Color for major ticks
//    var minorTickColor: UIColor = .gray    // Color for minor ticks
//    var labelColor: UIColor = .blue        // Color for labels
//    var labelFontNormal: UIFont = UIFont.systemFont(ofSize: 10.0)
//    var labelFontSelected: UIFont = UIFont.boldSystemFont(ofSize: 12.0)
//
//
//    var selectedTickColor: UIColor = .red  // Color for selected tick
//    var selectedIndex: Int = 50            // Index of the selected tick
//    var tickSpacing: CGFloat = 0   // Dynamic spacing between ticks
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        // Dynamically calculate the spacing between ticks
//        tickSpacing = bounds.width / CGFloat(numberOfTicks)
//        setNeedsDisplay() // Redraw the view with updated spacing
//    }
//
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        for i in 0...numberOfTicks {
//            let xPosition = CGFloat(i) * tickSpacing
//            let tickHeight = (i % 10 == 0) ? majorTickHeight : minorTickHeight
//            let tickColor = (i == selectedIndex) ? selectedTickColor : (i % 10 == 0 ? majorTickColor : minorTickColor)
//
//            // Set tick color
//            context.setStrokeColor(tickColor.cgColor)
//            context.setLineWidth(1.0)
//
//            // Draw the tick
//            context.move(to: CGPoint(x: xPosition, y: rect.height - tickHeight))
//            context.addLine(to: CGPoint(x: xPosition, y: rect.height))
//            context.strokePath()
//
//            // Add label for major ticks at the top
//            if i % 10 == 0 {
//                let label = UILabel(frame: CGRect(x: xPosition - 15, y: 0, width: 30, height: 20))
//                label.text = "\(i)"
//                label.font = (i == selectedIndex) ? labelFontSelected : labelFontNormal //UIFont.systemFont(ofSize: 10)
//                label.textAlignment = .center
//                label.textColor = (i == selectedIndex) ? selectedTickColor : labelColor
//                self.addSubview(label)
//            }
//        }
//    }
//}

//class RulerView: UIView {
//    var numberOfTicks: Int = 100           // Total number of ticks
//    var tickSpacing: CGFloat = 10          // Spacing between ticks
//    var majorTickHeight: CGFloat = 20      // Height of major ticks
//    var minorTickHeight: CGFloat = 10      // Height of minor ticks
//    var majorTickColor: UIColor = .black   // Color for major ticks
//    var minorTickColor: UIColor = .gray    // Color for minor ticks
//    var labelColor: UIColor = .blue        // Color for labels
//    var selectedTickColor: UIColor = .red  // Color for selected tick
//    var selectedIndex: Int = 50            // Index of the selected tick
//
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        for i in 0...numberOfTicks {
//            let xPosition = CGFloat(i) * tickSpacing
//            let tickHeight = (i % 10 == 0) ? majorTickHeight : minorTickHeight
//            let tickColor = (i == selectedIndex) ? selectedTickColor : (i % 10 == 0 ? majorTickColor : minorTickColor)
//
//            // Set tick color
//            context.setStrokeColor(tickColor.cgColor)
//            context.setLineWidth(1.0)
//
//            // Draw the tick
//            context.move(to: CGPoint(x: xPosition, y: rect.height - tickHeight))
//            context.addLine(to: CGPoint(x: xPosition, y: rect.height))
//            context.strokePath()
//
//            // Add label for major ticks at the top
//            if i % 10 == 0 {
//                let label = UILabel(frame: CGRect(x: xPosition - 15, y: 0, width: 30, height: 20))
//                label.text = "\(i)"
//                label.font = UIFont.systemFont(ofSize: 10)
//                label.textAlignment = .center
//                label.textColor = (i == selectedIndex) ? selectedTickColor : labelColor
//                self.addSubview(label)
//            }
//        }
//    }
//}

