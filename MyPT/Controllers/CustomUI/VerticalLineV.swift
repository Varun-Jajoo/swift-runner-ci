//
//  VerticalLineV.swift
//  MyPT
//
//  Created by techsaga corp on 03/09/25.
//

import UIKit

class VerticalLineV: UIView {
    
    var majorInterval: Int = 1           // every 10th tick is longer
    var tickSpacing: CGFloat = 10         // space between ticks
    var majorTickColor: UIColor = UIColor(red: 15/255, green: 20/255, blue: 17/255, alpha: 0.8)
    var minorTickColor: UIColor = .clear
    var lineWidth: CGFloat = 5            // thinner line so spacing shows
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let totalTicks = Int(rect.width / tickSpacing)
        
        for i in 0...totalTicks {
            let x = CGFloat(i) * tickSpacing
            let isMajor = i % majorInterval == 0
            
            // ✅ tick height depends on view height
//            let tickLength: CGFloat = isMajor ? rect.height * 0.9 : rect.height * 0.6
            
            let tickLength: CGFloat = rect.height
            let tickColor = isMajor ? majorTickColor : minorTickColor
            
            context.setStrokeColor(tickColor.cgColor)
            context.setLineWidth(lineWidth)
            
            let centerY = rect.height / 2
            context.move(to: CGPoint(x: x, y: centerY - tickLength / 2))
            context.addLine(to: CGPoint(x: x, y: centerY + tickLength / 2))
            context.strokePath()
        }
    }
}

