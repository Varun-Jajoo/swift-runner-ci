//
//  GradientView.swift
//  MyPT
//
//  Created by techsaga corp on 12/11/24.
//

import UIKit
import QuartzCore

public enum CAGradientPoint {
    case topLeft
    case centerLeft
    case bottomLeft
    case topCenter
    case center
    case bottomCenter
    case topRight
    case centerRight
    case bottomRight
    var point: CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: 0, y: 0)
        case .centerLeft:
            return CGPoint(x: 0, y: 0.5)
        case .bottomLeft:
            return CGPoint(x: 0, y: 1.0)
        case .topCenter:
            return CGPoint(x: 0.5, y: 0)
        case .center:
            return CGPoint(x: 0.5, y: 0.5)
        case .bottomCenter:
            return CGPoint(x: 0.5, y: 1.0)
        case .topRight:
            return CGPoint(x: 1.0, y: 0.0)
        case .centerRight:
            return CGPoint(x: 1.0, y: 0.5)
        case .bottomRight:
            return CGPoint(x: 1.0, y: 1.0)
        }
    }
}

extension CAGradientLayer {

    convenience init(start: CAGradientPoint, end: CAGradientPoint, colors: [CGColor], type: CAGradientLayerType) {
        self.init()
        self.frame.origin = CGPoint.zero
        self.startPoint = start.point
        self.endPoint = end.point
        self.colors = colors
//        self.locations = (0..<colors.count).map(NSNumber.init)
//        self.locations = [0.0, 0.5, 1.0]
        
        // Calculate locations based on the number of colors
        if colors.count > 1 {
            self.locations = (0..<colors.count).map { NSNumber(value: Float($0) / Float(colors.count - 1)) }
            print("points := ",(0..<colors.count).map { NSNumber(value: Float($0) / Float(colors.count - 1)) })
        } else {
            // If only one color, default to a single location at 0.0
            self.locations = [0.0]
        }
        self.type = type
    }
}

//extension UIView {
//
//    func layerGradient(startPoint:CAGradientPoint, endPoint:CAGradientPoint ,colorArray:[CGColor], type:CAGradientLayerType ) {
//        let gradient = CAGradientLayer(start: .topLeft, end: .topRight, colors: colorArray, type: type)
//        gradient.frame.size = self.frame.size
//        self.layer.insertSublayer(gradient, at: 0)
//    }
//    
//    //MARK: ===================LINE VIEW
//    func drawLineProgress(progressfill:CGFloat = 0.0, fillLineColor:UIColor?,cornerRadius:CGFloat) {
//        self.layer.sublayers?.removeAll()
//        let shapeLayer = CAShapeLayer()
//        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
//        shapeLayer.path = path.cgPath
//        layer.mask = shapeLayer
//        let progressRect = CGRect(origin: .zero, size: CGSize(width: self.frame.size.width*progressfill, height: self.frame.size.height))
//        let prLayer = CALayer()
//        prLayer.frame = progressRect
//        prLayer.cornerRadius = cornerRadius
//        self.layer.addSublayer(prLayer)
//        guard let fillLineColor = fillLineColor else { return }
//        prLayer.backgroundColor = fillLineColor.cgColor
//    }
//}





