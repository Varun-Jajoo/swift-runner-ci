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

