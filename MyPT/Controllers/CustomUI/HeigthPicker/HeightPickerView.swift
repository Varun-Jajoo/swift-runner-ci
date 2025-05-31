//
//  HeightPickerView.swift
//  MyPT
//
//  Created by techsaga corp on 23/04/25.
//

import UIKit

enum HeightUnit {
    case feetInches
    case centimeters
}

class HeightPickerControl: UIControl, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private var rulerView = RulerContentView()
    private let triangleImg = UIImageView()
    private let rulerWidth: CGFloat = 100

    var rulerViewBgColor: UIColor = .clear {
        didSet {
            rulerView.backgroundColor = rulerViewBgColor
        }
    }
    
    var maxFeet: Int = 8 {
        didSet {
            if unit == .feetInches { updateRuler() }
        }
    }

    var maxCM: Double = 600.0 {
        didSet {
            if unit == .centimeters { updateRuler() }
        }
    }

    var unit: HeightUnit = .feetInches {
        didSet {
            updateRuler()
        }
    }
    

    private(set) var selectedFeet: Int = 0
    private(set) var selectedInches: Int = 0
    private(set) var selectedCM: Double = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        rulerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(rulerView)

        triangleImg.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(triangleImg)
        triangleImg.image = UIImage(named: "ic_polygon_ruler") // Add your image
        triangleImg.contentMode = .scaleAspectFit
        triangleImg.transform = CGAffineTransform(rotationAngle: -.pi / 2)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            rulerView.widthAnchor.constraint(equalToConstant: rulerWidth),
            rulerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: rulerWidth - 30),
            rulerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            rulerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            triangleImg.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 60),
            triangleImg.centerYAnchor.constraint(equalTo: centerYAnchor),
            triangleImg.widthAnchor.constraint(equalToConstant: 40),
            triangleImg.heightAnchor.constraint(equalToConstant: 40)
        ])

        updateRuler()
    }

    private func updateRuler() {
        
        let midOffset: CGFloat
        switch unit {
        case .feetInches:
            let totalInches = maxFeet * 12
            rulerView.setFeetMode(maxInches: totalInches)
            scrollView.contentSize = rulerView.intrinsicContentSize
            midOffset = CGFloat(totalInches / 2) * 10
        case .centimeters:
            let maxSteps = Int(maxCM * 10)
            rulerView.setCentimeterMode(maxCMSteps: maxSteps)
            scrollView.contentSize = rulerView.intrinsicContentSize
            midOffset = CGFloat(maxSteps / 2) * 10
        }

        scrollView.contentOffset = CGPoint(x: 0, y: midOffset)
        
        rulerView.invalidateIntrinsicContentSize()
        rulerView.setNeedsLayout()
        rulerView.layoutIfNeeded()
        scrollView.invalidateIntrinsicContentSize()
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        updateSelectedHeight()
        
        //        switch unit {
        //        case .feetInches:
        //            let totalInches = maxFeet * 12
        //            rulerView.setFeetMode(maxInches: totalInches)
        //            scrollView.contentSize = CGSize(width: rulerWidth, height: CGFloat(totalInches) * 10)
        //            scrollView.contentOffset = CGPoint(x: 0, y: CGFloat(totalInches * 5) - bounds.height / 2)
        //        case .centimeters:
        //            let maxSteps = Int(maxCM * 10) // 0.1 cm per step
        //            rulerView.setCentimeterMode(maxCMSteps: maxSteps)
        //            scrollView.contentSize = CGSize(width: rulerWidth, height: CGFloat(maxSteps) * 10)
        //            scrollView.contentOffset = CGPoint(x: 0, y: CGFloat(maxSteps / 2) * 10 - bounds.height / 2)
        //        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectedHeight()
    }

    private func updateSelectedHeight() {
        let centerOffsetY = scrollView.contentOffset.y + bounds.height / 2
        let padding = bounds.height / 2 // same as verticalPadding

        let effectiveOffsetY = centerOffsetY - padding

        switch unit {
        case .feetInches:
            let totalInches = max(0, Int(round(effectiveOffsetY / 10)))
            selectedFeet = totalInches / 12
            selectedInches = totalInches % 12
        case .centimeters:
            let totalSteps = max(0, Int(round(effectiveOffsetY / 10)))
            selectedCM = Double(totalSteps) / 10.0
        }

        sendActions(for: .valueChanged)
    }

    
//    private func updateSelectedHeight() {
//        let centerOffsetY = scrollView.contentOffset.y + bounds.height / 2
//        switch unit {
//        case .feetInches:
//            let totalInches = max(0, Int(round(centerOffsetY / 10)))
//            selectedFeet = totalInches / 12
//            selectedInches = totalInches % 12
//        case .centimeters:
//            let totalSteps = max(0, Int(round(centerOffsetY / 10))) // each 10px = 0.1cm
//            selectedCM = Double(totalSteps) / 10.0
//        }
//        sendActions(for: .valueChanged)
//    }
}

class RulerContentView: UIView {

    private var useFeet = true
    var maxInches: Int = 96
    var maxCMSteps: Int = 600 // 250.0 cm with 0.1 cm steps

    func setFeetMode(maxInches: Int) {
        self.maxInches = maxInches
        self.useFeet = true
        setNeedsDisplay()
    }

    func setCentimeterMode(maxCMSteps: Int) {
        self.maxCMSteps = maxCMSteps
        self.useFeet = false
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
        layoutIfNeeded()
    }

    private var verticalPadding: CGFloat {
        return (superview?.bounds.height ?? 0) / 2
    }
    
    override var intrinsicContentSize: CGSize {
        let baseHeight = useFeet ? CGFloat(maxInches) * 10 : CGFloat(maxCMSteps) * 10
        return CGSize(width: 80, height: baseHeight + 2 * verticalPadding)
    }
    
    override func draw(_ rect: CGRect) {
        subviews.forEach { $0.removeFromSuperview() }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setStrokeColor(UIColor(white: 1, alpha: 0.2).cgColor)
        let yOffset = verticalPadding

        if useFeet {
            for i in 0...maxInches {
                let y = CGFloat(i) * 10 + yOffset
                let isFoot = i % 12 == 0
                let lineLength: CGFloat = isFoot ? 75 : 55
                let midXLine: CGFloat = isFoot ? 5 : 25
                let lineWidth: CGFloat = isFoot ? 4 : 2
                context.setLineWidth(lineWidth)
                context.move(to: CGPoint(x: midXLine, y: y))
                context.addLine(to: CGPoint(x: lineLength, y: y))
                context.strokePath()

                if isFoot {
                    let label = UILabel()
                    label.text = "\(i / 12) ft"
                    label.font = AppFont.semibold.size(14.0, familyName: familyManrope)
                    label.textColor = UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)
                    label.sizeToFit()
                    label.center = CGPoint(x: -20, y: y)
                    addSubview(label)
                }
            }
        } else {
            for i in 0...maxCMSteps {
                let y = CGFloat(i) * 10 + yOffset
                let isMajorTick = i % 10 == 0
                let isHalfTick = i % 5 == 0
                let lineLength: CGFloat = isMajorTick ? 75 : 55
                let midXLine: CGFloat = isMajorTick ? 5 : 25
                let lineWidth: CGFloat = isMajorTick ? 4 : 2
                context.setLineWidth(lineWidth)
                context.move(to: CGPoint(x: midXLine, y: y))
                context.addLine(to: CGPoint(x: lineLength, y: y))
                context.strokePath()

                if isMajorTick {
                    let label = UILabel()
                    label.text = "\(Int(Double(i) / 10.0)) cm"
                    label.font = AppFont.semibold.size(14.0, familyName: familyManrope)
                    label.textColor = UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)
                    label.sizeToFit()
                    label.center = CGPoint(x: -30, y: y)
                    addSubview(label)
                }
            }
        }
    }

    
//    override var intrinsicContentSize: CGSize {
//        if useFeet {
//            return CGSize(width: 80, height: maxInches * 10)
//        } else {
//            return CGSize(width: 80, height: maxCMSteps * 10)
//        }
//    }

//    override func draw(_ rect: CGRect) {
//        subviews.forEach { $0.removeFromSuperview() }
//
//        let context = UIGraphicsGetCurrentContext()
//        context?.setStrokeColor(UIColor(white: 1, alpha: 0.2).cgColor)
//
//        if useFeet {
//            for i in 0...maxInches {
//                let y = CGFloat(i) * 10
//                let isFoot = i % 12 == 0
////                let isHalfFoot = i % 6 == 0
//                let lineLength: CGFloat = isFoot ? 75 : 55
//                let midXLine: CGFloat = isFoot ? 5 : 25
//                let lineWidth: CGFloat = isFoot ? 4 : 2
//                context?.setLineWidth(lineWidth)
//                context?.move(to: CGPoint(x: midXLine, y: y))
//                context?.addLine(to: CGPoint(x: lineLength, y: y))
//                context?.strokePath()
//
//                if isFoot {
//                    let label = UILabel()
//                    label.text = "\(i / 12) ft"
//                    label.font =  AppFont.semibold.size(14.0, familyName: familyManrope)
//                    label.textColor = UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)
//                    label.sizeToFit()
//                    label.center = CGPoint(x: -20, y: y)
//                    addSubview(label)
//                }
//            }
//        } else {
//            for i in 0...maxCMSteps {
//                let y = CGFloat(i) * 10
//                let isMajorTick = i % 10 == 0  // full cm
//                let isHalfTick = i % 5 == 0    // half cm
//
//                let lineLength: CGFloat = isMajorTick ? 75 : (isHalfTick ? 55 : 55)
//                let midXLine: CGFloat = isMajorTick ? 5 : 25
//                let lineWidth: CGFloat = isMajorTick ? 4 : 2
//                context?.setLineWidth(lineWidth)
//                context?.move(to: CGPoint(x: midXLine, y: y))
//                context?.addLine(to: CGPoint(x: lineLength, y: y))
//                context?.strokePath()
//
//                if isMajorTick {
//                    let label = UILabel()
//                    label.text = "\(Int(Double(i) / 10.0)) cm"
//                    label.font = AppFont.semibold.size(14.0, familyName: familyManrope)
//                    label.textColor = UIColor(red: 158/255, green: 160/255, blue: 165/255, alpha: 1.0)
//                    label.sizeToFit()
//                    label.center = CGPoint(x: -30, y: y)
//                    addSubview(label)
//                }
//            }
//        }
//    }
}



