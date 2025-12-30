//
//  RadarGraph.swift
//  MyPT
//
//  Created by techsaga corp on 18/08/25.
//

import UIKit


struct RadarData {
    let label: String
    let value: CGFloat // A value between 0.0 and 1.0, representing the percentage filled.
}

class RadarChartView: UIView {
    
    // This is the data set that creates the star shape for the main chart.
    // The alternating high and low values are the key to this effect.
    var data: [RadarData] = [
        RadarData(label: "Calories", value: 1.0), // High point
        RadarData(label: "Steps ", value: 0.5),    // Low point
        RadarData(label: "Routine adherence ", value: 0.95), // High point
        RadarData(label: "Exercises Completed ", value: 0.5),     // Low point
        RadarData(label: "Duration", value: 0.75),    // High point
        RadarData(label: "Heart zone", value: 0.4) // Low point
    ]
    
    // This ratio controls the roundness of the corners. A smaller number means sharper corners.
    private let cornerRadiusRatio: CGFloat = 0.12
       
    var gridColor: UIColor = UIColor.white.withAlphaComponent(0.15) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var labelColor: UIColor = UIColor.white.withAlphaComponent(0.8) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var centerStarFillColor: UIColor = UIColor.mainBg {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var labelFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .semibold) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var numberOfGridPolygons: Int = 4 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var datasetFillColor: UIColor = UIColor.appGreen.withAlphaComponent(0.3) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var datasetStrokeColor: UIColor = UIColor.appGreen.withAlphaComponent(0.7) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var datasetBorderWidth: CGFloat = 4.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.setupUI()
    }
    
    private func setupUI(){
        guard data.count > 2 else { return }
        // Define the colors and font.
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 * 0.7 //0.96
        let angleStep = (2 * CGFloat.pi) / CGFloat(data.count)
        // --- 1. Draw the concentric grid polygons ---
        for polygonIndex in 1...numberOfGridPolygons {
            let currentRadius = radius / CGFloat(numberOfGridPolygons) * CGFloat(polygonIndex)
            let gridPath = UIBezierPath()
            
            // Step 1: Collect vertices for this polygon
            var points: [CGPoint] = []
            for j in 0..<data.count {
                let angle = CGFloat(j) * angleStep - .pi/2
                let point = CGPoint(
                    x: center.x + cos(angle) * currentRadius,
                    y: center.y + sin(angle) * currentRadius
                )
                points.append(point)
            }

            // Step 2: Construct path with rounded corners
            for j in 0..<points.count {
                let prev = points[(j - 1 + points.count) % points.count]
                let current = points[j]
                let next = points[(j + 1) % points.count]

                // Direction vectors
                let v1 = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
                let v2 = CGPoint(x: next.x - current.x, y: next.y - current.y)
                
                let len1 = sqrt(v1.x * v1.x + v1.y * v1.y)
                let len2 = sqrt(v2.x * v2.x + v2.y * v2.y)
                
                let u1 = CGPoint(x: v1.x / len1, y: v1.y / len1)
                let u2 = CGPoint(x: v2.x / len2, y: v2.y / len2)
                
                // Corner rounding size
                let cornerRadius: CGFloat = currentRadius * 0.2 //0.1

                // Entry and exit points for the rounded corner
                let start = CGPoint(x: current.x + u1.x * cornerRadius,
                                    y: current.y + u1.y * cornerRadius)
                let end = CGPoint(x: current.x + u2.x * cornerRadius,
                                  y: current.y + u2.y * cornerRadius)
                
                if j == 0 {
                    gridPath.move(to: start)
                } else {
                    gridPath.addLine(to: start)
                }
                
                // Rounded corner
                gridPath.addQuadCurve(to: end, controlPoint: current)
            }
            
            gridPath.close()
            
            // Draw stroke
            gridColor.setStroke()
            gridPath.lineWidth = 1.0
            gridPath.stroke()
        }
        
        // --- 2. Draw the radial lines (spokes) ---
        for i in 0..<data.count {
            let angle = CGFloat(i) * angleStep - .pi/2
            let point = CGPoint(x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius)
            
            let spokePath = UIBezierPath()
            spokePath.move(to: center)
            spokePath.addLine(to: point)
            spokePath.lineWidth = 1.0
            gridColor.setStroke()
            spokePath.stroke()
        }
        
        // --- 3. Draw the main data polygon with advanced rounding to create a star shape ---
        // First, generate the raw corner points based on the data values.
        var points: [CGPoint] = []
        for (i, entry) in data.enumerated() {
            let angle = CGFloat(i) * angleStep - .pi/2
            let r = radius * entry.value * 0.8
            let point = CGPoint(x: center.x + cos(angle) * r,
                                y: center.y + sin(angle) * r)
            points.append(point)
        }
        
        // --- 4. Draw a star at the center point with an outline ---
        let starOuterRadius: CGFloat = 20.0 // Increased size
        let starInnerRadius = starOuterRadius * 0.4
        let numberOfStarPoints = 6
        let angleStepForStar = (2 * CGFloat.pi) / CGFloat(numberOfStarPoints * 2)
        
        // Generate star vertices
        var starPoints: [CGPoint] = []
        for i in 0..<(numberOfStarPoints * 2) {
            let currentStarRadius = (i % 2 == 0) ? starOuterRadius : starInnerRadius
            let angle = CGFloat(i) * angleStepForStar - .pi / 2
            let point = CGPoint(x: center.x + cos(angle) * currentStarRadius,
                                y: center.y + sin(angle) * currentStarRadius)
            starPoints.append(point)
        }
        
        let starPath = UIBezierPath()
        let starCornerRadius = starOuterRadius * cornerRadiusRatio
        
        // Build path with rounded corners
        for i in 0..<starPoints.count {
            let prev = starPoints[(i - 1 + starPoints.count) % starPoints.count]
            let current = starPoints[i]
            let next = starPoints[(i + 1) % starPoints.count]
            
            let v1 = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
            let v2 = CGPoint(x: next.x - current.x, y: next.y - current.y)
            let len1 = sqrt(v1.x * v1.x + v1.y * v1.y)
            let len2 = sqrt(v2.x * v2.x + v2.y * v2.y)
            let u1 = CGPoint(x: v1.x / len1, y: v1.y / len1)
            let u2 = CGPoint(x: v2.x / len2, y: v2.y / len2)
            
            let start = CGPoint(x: current.x + u1.x * starCornerRadius, y: current.y + u1.y * starCornerRadius)
            let end = CGPoint(x: current.x + u2.x * starCornerRadius, y: current.y + u2.y * starCornerRadius)
            
            if i == 0 {
                starPath.move(to: start)
            } else {
                starPath.addLine(to: start)
            }
            starPath.addQuadCurve(to: end, controlPoint: current)
        }
        
        starPath.close()
        
        centerStarFillColor.setFill() // Use the new color for the star fill
        starPath.fill()
        
        gridColor.setStroke() // Use the new color for the star outline
        starPath.lineWidth = 1.5
        starPath.stroke()
        
        // --- 5. Draw the labels around the chart ---
        let labelOffset: CGFloat = 2.0 //15.0
        
        for (i, entry) in data.enumerated() {
            let angle = CGFloat(i) * angleStep - .pi/2
            let labelRadius = radius + labelOffset
            
            let labelX = center.x + cos(angle) * labelRadius
            let labelY = center.y + sin(angle) * labelRadius
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: labelFont,
                .foregroundColor: labelColor
            ]
            
            // Use a size that allows for multiple lines.
            let maxLabelWidth: CGFloat = 100.0 // Adjust this value as needed.
            let string = entry.label as NSString
            
            // Calculate the bounding box for the text.
            let boundingBox = string.boundingRect(
                with: CGSize(width: maxLabelWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                attributes: attributes,
                context: nil
            )
            
            // The core change to center the text
            var textRect = CGRect(
                x: labelX - boundingBox.width / 2,
                y: labelY - boundingBox.height / 2,
                width: boundingBox.width,
                height: boundingBox.height
            )
            
            // Apply alignment logic based on angle
            let tolerance: CGFloat = 0.01
            let cosAngle = cos(angle)
            let sinAngle = sin(angle)
            
            if abs(cosAngle) < tolerance { // Top and bottom (vertical alignment)
                textRect.origin.x = labelX - boundingBox.width / 2
                if sinAngle < 0 { // Top pole
                    textRect.origin.y = labelY - boundingBox.height
                } else { // Bottom pole
                    textRect.origin.y = labelY
                }
            } else if cosAngle > 0 { // Right side
                textRect.origin.x = labelX
            } else { // Left side
                textRect.origin.x = labelX - boundingBox.width
            }
            
            // Draw the string with text alignment set to center
            // You'll need to use a paragraph style to set the horizontal alignment.
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            var centeredAttributes = attributes
            centeredAttributes[.paragraphStyle] = paragraphStyle
            
            string.draw(
                with: textRect,
                options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                attributes: centeredAttributes,
                context: nil
            )
        }
                
        makeDataSet(frame: CGRect(x: 0, y: 0, width: min(bounds.width, bounds.height) * 0.75, height: min(bounds.width, bounds.height) * 0.75))
    }
    
    private func makeDataSet(frame: CGRect?){
        guard let frame = frame else { return  }
        let dataSetView = RadarDatasetView()
        dataSetView.frame = frame
        dataSetView.center = self.center
        dataSetView.backgroundColor = UIColor.clear
        dataSetView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dataSetView)
      
        NSLayoutConstraint.activate([
            dataSetView.widthAnchor.constraint(equalToConstant: frame.size.width),
            dataSetView.heightAnchor.constraint(equalToConstant: frame.size.height),
            dataSetView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dataSetView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        //-----------------
        dataSetView.fillColor = datasetFillColor
        dataSetView.strokeColor = datasetStrokeColor
        dataSetView.borderWidth = datasetBorderWidth
        dataSetView.outerFactors.removeAll()
        for i in  data.enumerated() {
            dataSetView.outerFactors.append(i.element.value)
        }
    }
}

/*
 class RadarChartView: UIView {
     
     // This is the data set that creates the star shape for the main chart.
     // The alternating high and low values are the key to this effect.
     var data: [RadarData] = [
         RadarData(label: "Calories", value: 1.0), // High point
         RadarData(label: "Steps ", value: 0.5),    // Low point
         RadarData(label: "Routine adherence ", value: 0.95), // High point
         RadarData(label: "Exercises Completed ", value: 0.5),     // Low point
         RadarData(label: "Duration", value: 0.75),    // High point
         RadarData(label: "Heart zone", value: 0.4) // Low point
     ]
     
     // This ratio controls the roundness of the corners. A smaller number means sharper corners.
     private let cornerRadiusRatio: CGFloat = 0.12
    
     let gridColor = UIColor.white.withAlphaComponent(0.15)
     let labelColor = UIColor.white.withAlphaComponent(0.8)
     let labelFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
     let numberOfGridPolygons = 4
     var starColor: UIColor = UIColor.mainBg

     override func draw(_ rect: CGRect) {
         self.setupUI()
     }
     
     private func setupUI(){
         guard data.count > 2 else { return }
         // Define the colors and font.
 //        let gridColor = UIColor.white.withAlphaComponent(0.15)
 //        let dataFillColor = UIColor(red: 0.54, green: 0.65, blue: 0.51, alpha: 0.3)
 //        let dataStrokeColor = UIColor(red: 0.54, green: 0.65, blue: 0.51, alpha: 1.0)
 //        let starColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Color for the central star
         
 //        let labelColor = UIColor.white.withAlphaComponent(0.8)
 //        let labelFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
                 
         let center = CGPoint(x: bounds.midX, y: bounds.midY)
         let radius = min(bounds.width, bounds.height) / 2 * 0.7 //0.96
         let angleStep = (2 * CGFloat.pi) / CGFloat(data.count)
 //        let numberOfGridPolygons = 4
                 
         // --- 1. Draw the concentric grid polygons ---
         for polygonIndex in 1...numberOfGridPolygons {
             let currentRadius = radius / CGFloat(numberOfGridPolygons) * CGFloat(polygonIndex)
             let gridPath = UIBezierPath()
             
             // Step 1: Collect vertices for this polygon
             var points: [CGPoint] = []
             for j in 0..<data.count {
                 let angle = CGFloat(j) * angleStep - .pi/2
                 let point = CGPoint(
                     x: center.x + cos(angle) * currentRadius,
                     y: center.y + sin(angle) * currentRadius
                 )
                 points.append(point)
             }

             // Step 2: Construct path with rounded corners
             for j in 0..<points.count {
                 let prev = points[(j - 1 + points.count) % points.count]
                 let current = points[j]
                 let next = points[(j + 1) % points.count]

                 // Direction vectors
                 let v1 = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
                 let v2 = CGPoint(x: next.x - current.x, y: next.y - current.y)
                 
                 let len1 = sqrt(v1.x * v1.x + v1.y * v1.y)
                 let len2 = sqrt(v2.x * v2.x + v2.y * v2.y)
                 
                 let u1 = CGPoint(x: v1.x / len1, y: v1.y / len1)
                 let u2 = CGPoint(x: v2.x / len2, y: v2.y / len2)
                 
                 // Corner rounding size
                 let cornerRadius: CGFloat = currentRadius * 0.2 //0.1

                 // Entry and exit points for the rounded corner
                 let start = CGPoint(x: current.x + u1.x * cornerRadius,
                                     y: current.y + u1.y * cornerRadius)
                 let end = CGPoint(x: current.x + u2.x * cornerRadius,
                                   y: current.y + u2.y * cornerRadius)
                 
                 if j == 0 {
                     gridPath.move(to: start)
                 } else {
                     gridPath.addLine(to: start)
                 }
                 
                 // Rounded corner
                 gridPath.addQuadCurve(to: end, controlPoint: current)
             }
             
             gridPath.close()
             
             // Draw stroke
             gridColor.setStroke()
             gridPath.lineWidth = 1.0
             gridPath.stroke()
         }
         
         // --- 2. Draw the radial lines (spokes) ---
         for i in 0..<data.count {
             let angle = CGFloat(i) * angleStep - .pi/2
             let point = CGPoint(x: center.x + cos(angle) * radius,
                                 y: center.y + sin(angle) * radius)
             
             let spokePath = UIBezierPath()
             spokePath.move(to: center)
             spokePath.addLine(to: point)
             spokePath.lineWidth = 1.0
             gridColor.setStroke()
             spokePath.stroke()
         }
         
         // --- 3. Draw the main data polygon with advanced rounding to create a star shape ---
         // First, generate the raw corner points based on the data values.
         var points: [CGPoint] = []
         for (i, entry) in data.enumerated() {
             let angle = CGFloat(i) * angleStep - .pi/2
             let r = radius * entry.value * 0.8
             let point = CGPoint(x: center.x + cos(angle) * r,
                                 y: center.y + sin(angle) * r)
             points.append(point)
         }
         
         // --- 4. Draw a star at the center point with an outline ---
         let starOuterRadius: CGFloat = 20.0 // Increased size
         let starInnerRadius = starOuterRadius * 0.4
         let numberOfStarPoints = 6
         let angleStepForStar = (2 * CGFloat.pi) / CGFloat(numberOfStarPoints * 2)
         
         // Generate star vertices
         var starPoints: [CGPoint] = []
         for i in 0..<(numberOfStarPoints * 2) {
             let currentStarRadius = (i % 2 == 0) ? starOuterRadius : starInnerRadius
             let angle = CGFloat(i) * angleStepForStar - .pi / 2
             let point = CGPoint(x: center.x + cos(angle) * currentStarRadius,
                                 y: center.y + sin(angle) * currentStarRadius)
             starPoints.append(point)
         }
         
         let starPath = UIBezierPath()
         let starCornerRadius = starOuterRadius * cornerRadiusRatio
         
         // Build path with rounded corners
         for i in 0..<starPoints.count {
             let prev = starPoints[(i - 1 + starPoints.count) % starPoints.count]
             let current = starPoints[i]
             let next = starPoints[(i + 1) % starPoints.count]
             
             let v1 = CGPoint(x: prev.x - current.x, y: prev.y - current.y)
             let v2 = CGPoint(x: next.x - current.x, y: next.y - current.y)
             let len1 = sqrt(v1.x * v1.x + v1.y * v1.y)
             let len2 = sqrt(v2.x * v2.x + v2.y * v2.y)
             let u1 = CGPoint(x: v1.x / len1, y: v1.y / len1)
             let u2 = CGPoint(x: v2.x / len2, y: v2.y / len2)
             
             let start = CGPoint(x: current.x + u1.x * starCornerRadius, y: current.y + u1.y * starCornerRadius)
             let end = CGPoint(x: current.x + u2.x * starCornerRadius, y: current.y + u2.y * starCornerRadius)
             
             if i == 0 {
                 starPath.move(to: start)
             } else {
                 starPath.addLine(to: start)
             }
             starPath.addQuadCurve(to: end, controlPoint: current)
         }
         
         starPath.close()
         
         starColor.setFill() // Use the new color for the star fill
 //        UIColor.mainBg.setFill()
         starPath.fill()
         
 //        starColor.setStroke() // Use the new color for the star outline
         gridColor.setStroke()
         starPath.lineWidth = 1.5
         starPath.stroke()
         
         // --- 5. Draw the labels around the chart ---
         let labelOffset: CGFloat = 2.0 //15.0
         
         for (i, entry) in data.enumerated() {
             let angle = CGFloat(i) * angleStep - .pi/2
             let labelRadius = radius + labelOffset
             
             let labelX = center.x + cos(angle) * labelRadius
             let labelY = center.y + sin(angle) * labelRadius
             
             let attributes: [NSAttributedString.Key: Any] = [
                 .font: labelFont,
                 .foregroundColor: labelColor
             ]
             
             // Use a size that allows for multiple lines.
             let maxLabelWidth: CGFloat = 100.0 // Adjust this value as needed.
             let string = entry.label as NSString
             
             // Calculate the bounding box for the text.
             let boundingBox = string.boundingRect(
                 with: CGSize(width: maxLabelWidth, height: .greatestFiniteMagnitude),
                 options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                 attributes: attributes,
                 context: nil
             )
             
             // The core change to center the text
             var textRect = CGRect(
                 x: labelX - boundingBox.width / 2,
                 y: labelY - boundingBox.height / 2,
                 width: boundingBox.width,
                 height: boundingBox.height
             )
             
             // Apply alignment logic based on angle
             let tolerance: CGFloat = 0.01
             let cosAngle = cos(angle)
             let sinAngle = sin(angle)
             
             if abs(cosAngle) < tolerance { // Top and bottom (vertical alignment)
                 textRect.origin.x = labelX - boundingBox.width / 2
                 if sinAngle < 0 { // Top pole
                     textRect.origin.y = labelY - boundingBox.height
                 } else { // Bottom pole
                     textRect.origin.y = labelY
                 }
             } else if cosAngle > 0 { // Right side
                 textRect.origin.x = labelX
             } else { // Left side
                 textRect.origin.x = labelX - boundingBox.width
             }
             
             // Draw the string with text alignment set to center
             // You'll need to use a paragraph style to set the horizontal alignment.
             let paragraphStyle = NSMutableParagraphStyle()
             paragraphStyle.alignment = .center
             
             var centeredAttributes = attributes
             centeredAttributes[.paragraphStyle] = paragraphStyle
             
             string.draw(
                 with: textRect,
                 options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                 attributes: centeredAttributes,
                 context: nil
             )
         }
                 
         /*
         for (i, entry) in data.enumerated() {
             let angle = CGFloat(i) * angleStep - .pi/2
             let labelRadius = radius + labelOffset
             
             let labelX = center.x + cos(angle) * labelRadius
             let labelY = center.y + sin(angle) * labelRadius
             
             let attributes: [NSAttributedString.Key: Any] = [
                 .font: labelFont,
                 .foregroundColor: labelColor
             ]
             
             let labelSize = entry.label.size(withAttributes: attributes)
             
             var textRect = CGRect(x: labelX - labelSize.width / 2,
                                   y: labelY - labelSize.height / 2,
                                   width: labelSize.width,
                                   height: labelSize.height)
             
             let tolerance: CGFloat = 0.01
             if abs(cos(angle)) < tolerance {
                 textRect.origin.x = labelX - labelSize.width / 2
                 if sin(angle) < 0 {
                     textRect.origin.y = labelY - labelSize.height
                 } else {
                     textRect.origin.y = labelY
                 }
             } else if cos(angle) > 0 {
                 textRect.origin.x = labelX
             } else {
                 textRect.origin.x = labelX - labelSize.width
             }
             
             entry.label.draw(in: textRect, withAttributes: attributes)
         }
         */
         
         makeDataSet(frame: CGRect(x: 0, y: 0, width: min(bounds.width, bounds.height) * 0.75, height: min(bounds.width, bounds.height) * 0.75))
     }
     
     private func makeDataSet(frame: CGRect?){
         guard let frame = frame else { return  }
         let dataSetView = RadarDatasetView()
         dataSetView.frame = frame
         dataSetView.center = self.center
         dataSetView.backgroundColor = UIColor.clear
         dataSetView.translatesAutoresizingMaskIntoConstraints = false
         self.addSubview(dataSetView)
       
         NSLayoutConstraint.activate([
             dataSetView.widthAnchor.constraint(equalToConstant: frame.size.width),
             dataSetView.heightAnchor.constraint(equalToConstant: frame.size.height),
             dataSetView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
             dataSetView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
         ])
         
         //-----------------
         dataSetView.fillColor = UIColor.appGreen.withAlphaComponent(0.3)
         dataSetView.strokeColor = UIColor.appGreen.withAlphaComponent(0.7)
         dataSetView.borderWidth = 4.0
         dataSetView.outerFactors.removeAll()
         for i in  data.enumerated() {
             dataSetView.outerFactors.append(i.element.value)
         }
     }
 }
 */
