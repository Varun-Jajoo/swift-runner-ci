//
//  RulerMultiUnitRuler.swift
//  MyPT
//
//  Created by techsaga corp on 06/02/25.
//

import UIKit


/*
public class NMSegmentUnitFormatter {
    open var unit : Dimension?
    open var markerTypes: Array<RulerRangeMarkerType> = Array()
    open func string(from measurement: Measurement<Unit>) -> String {
    }
}
*/

public enum RulerLayerDirection: Int {
    case vertical = 0, horizontal
}

public class RulerSegmentUnit: NSObject, NSCopying {
    public var unit: Dimension?
    public var name: String = String()
    public var image: UIImage?
    public var markerTypes: Array<RulerRangeMarkerType> = Array()


    public var formatter: MeasurementFormatter? {
        didSet {
            if let formatter = self.formatter {
                if formatter.numberFormatter.numberStyle == .decimal {
                    let numberFormatter: NumberFormatter = NumberFormatter()
                    numberFormatter.paddingPosition = .afterSuffix
                    numberFormatter.maximumFractionDigits = 2
                    formatter.numberFormatter = numberFormatter
                }
            }
        }
    }

    public convenience init(name: String, unit: Dimension, formatter: MeasurementFormatter) {
        self.init()
        self.name = name
        self.unit = unit
        self.formatter = formatter
    }


    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = RulerSegmentUnit()
        copy.image = self.image
        copy.name = self.name
        copy.markerTypes = self.markerTypes
        copy.formatter = self.formatter
        return copy
    }
}

public class RulerSegmentUnitControlStyle: NSObject {
    public var textFieldBackgroundColor: UIColor = UIColor.clear
    public var textFieldFont: UIFont = kDefaultTextFieldFont
    public var textFieldTextColor: UIColor = UIColor.white
    public var scrollViewBackgroundColor: UIColor = UIColor.clear
    public var colorOverrides: Dictionary<RulerRange<Float>, UIColor>?
}


public protocol RulerMultiUnitRulerDataSource {

    func unitForSegmentAtIndex(index: Int) -> RulerSegmentUnit

    func rangeForUnit(_ unit: Dimension) -> RulerRange<Float>

    var numberOfSegments: Int { get set }

    func styleForUnit(_ unit: Dimension) -> RulerSegmentUnitControlStyle

}


public protocol RulerMultiUnitRulerDelegate {
    func valueChanged(measurement: NSMeasurement)
}

public class RulerMultiUnitRuler: UIView {
    public var dataSource: RulerMultiUnitRulerDataSource? {
        didSet {
            setupViews()
        }
    }
    public var delegate: RulerMultiUnitRulerDelegate?
    public var measurement: NSMeasurement?
    private var segmentedViews: [UIView]?
    private var pointerViews: [RulerRangePointerView]?
    private var scrollViews: [RulerRangeScrollView]?
    private var textViews: [RulerRangeTextView]?
    public var direction: RulerLayerDirection = .horizontal
    private var selectedSegmentIndex: Int = 0 // Keep track of the selected segment
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    open func refresh() {
        setupViews()
    }
    
    private func setupViews() {
//        guard let dataSource = self.dataSource else { return }
        guard self.dataSource != nil else { return }
        
        subviews.forEach { $0.removeFromSuperview() } // Clear existing views
        
        let (segmentedViews, scrollViews, textViews, pointerViews) = setupSegmentViews()
        self.segmentedViews = segmentedViews
        self.scrollViews = scrollViews
        self.textViews = textViews
        self.pointerViews = pointerViews
        
        var constraints = [NSLayoutConstraint]()
        
        switch direction {
        case .horizontal:
            for segmentView in segmentedViews {
                constraints += NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-5-[segmentView]-5-|",
                    options: .directionLeadingToTrailing,
                    metrics: nil,
                    views: ["segmentView": segmentView])
                constraints += NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-5-[segmentView]-5-|", // Simplified vertical constraints
                    options: .directionLeadingToTrailing,
                    metrics: nil,
                    views: ["segmentView": segmentView])
            }
        case .vertical:
            for segmentView in segmentedViews {
                constraints += NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-5-[segmentView]-5-|",
                    options: .directionLeadingToTrailing,
                    metrics: nil,
                    views: ["segmentView": segmentView])
                constraints += NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-5-[segmentView]-5-|", // Simplified vertical constraints
                    options: .directionLeadingToTrailing,
                    metrics: nil,
                    views: ["segmentView": segmentView])
            }
        }
        
        addConstraints(constraints)
        showSegmentAtIndex(0) // Show the first segment initially
    }
    
    private func setupPointerView(inSegmentView parent: UIView,
                                  unit segmentUnit: RulerSegmentUnit,
                                  segmentStyle style: RulerSegmentUnitControlStyle) -> RulerRangePointerView {
        let pointerView = RulerRangePointerView(frame: self.bounds)
        pointerView.translatesAutoresizingMaskIntoConstraints = false
        pointerView.direction = self.direction
        pointerView.backgroundColor = style.scrollViewBackgroundColor
        parent.addSubview(pointerView)
        return pointerView
    }
    
    private func setupSegmentScrollView(inSegmentView parent: UIView,
                                        unit segmentUnit: RulerSegmentUnit,
                                        segmentStyle style: RulerSegmentUnitControlStyle,
                                        range floatRange: RulerRange<Float>) -> RulerRangeScrollView {
        let scrollView = RulerRangeScrollView(frame: self.bounds)
        scrollView.markerTypes = segmentUnit.markerTypes
        scrollView.backgroundColor = style.scrollViewBackgroundColor
        scrollView.range = floatRange
        
        scrollView.colorOverrides = style.colorOverrides
        scrollView.direction = self.direction
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addTarget(self,
                action: #selector(RulerMultiUnitRuler.scrollViewCurrentValueChanged(_:)),
                for: .valueChanged)
        parent.addSubview(scrollView)
        return scrollView
    }
    
    private func setupSegmentViews() -> ([UIView], [RulerRangeScrollView], [RulerRangeTextView], [RulerRangePointerView]) {
        var segmentViews: [UIView] = []
        var pointerViews: [RulerRangePointerView] = []
        var scrollViews: [RulerRangeScrollView] = []
        var textViews: [RulerRangeTextView] = []
        let pointV = UIView()
        
        guard let dataSource = self.dataSource else {
            return (segmentViews, scrollViews, textViews, pointerViews)
        }
        
        for index in 0..<dataSource.numberOfSegments {
            let segmentView = UIView()
            segmentView.translatesAutoresizingMaskIntoConstraints = false
            
            let segmentUnit = dataSource.unitForSegmentAtIndex(index: index)
            if let unit = segmentUnit.unit {
                let style = dataSource.styleForUnit(unit)
                let range = dataSource.rangeForUnit(unit)
                
                let pointerView = setupPointerView(inSegmentView: segmentView, unit: segmentUnit, segmentStyle: style)
                let scrollView = setupSegmentScrollView(inSegmentView: segmentView, unit: segmentUnit, segmentStyle: style, range: range)
                let textView = setupSegmentBottomView(inSegmentView: segmentView, unit: segmentUnit, style: style)
                let underlineView = setupSegmentLineUnderBottomView(inSegmentView: segmentView)
                
                let segmentSubViews = ["scrollView": scrollView, "textView": textView, "underlineView": underlineView, "pointerView": pointerView]
                underlineView.isHidden = true
                
                var constraints = [NSLayoutConstraint]()
                
                switch direction {
                case .vertical:
                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[textView(25)]-1-[underlineView(2)]-5-[scrollView]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
//                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[scrollView]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[pointerView(10)]-0-[scrollView]-5-[textView]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pointerView]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[pointerView(10)]-0-[scrollView]-5-[underlineView]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
//                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textView(25)]-1-[underlineView(2)]", options: .alignAllCenterX, metrics: nil, views: segmentSubViews)
                    
                case .horizontal:
                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[scrollView]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[textView]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[pointerView]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[underlineView]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[textView(25)]-1-[underlineView(2)]-5-[scrollView]-5-[pointerView(10)]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
//                    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pointerView(10)]-0-[scrollView]-5-[textView(25)]-1-[underlineView(2)]-5-|", options: .directionLeadingToTrailing, metrics: nil, views: segmentSubViews)
                }
                
                segmentView.backgroundColor = style.scrollViewBackgroundColor
                segmentView.addConstraints(constraints)
                segmentViews.append(segmentView)
                scrollViews.append(scrollView)
                textViews.append(textView)
                pointerViews.append(pointerView)
                pointerView.isHidden = true
                addSubview(segmentView)
                
                textView.isUserInteractionEnabled = false
                
                // Apply 90-degree (π/2) counterclockwise rotation
//                segmentView.transform = CGAffineTransform(rotationAngle: (.pi))

//                textView.transform = CGAffineTransform(rotationAngle: (.pi))
//                segmentView.transform = CGAffineTransform(rotationAngle: (.pi))
                
                // Set initial visibility
                segmentView.isHidden = (index != selectedSegmentIndex)
                if index == selectedSegmentIndex, let unit = segmentUnit.unit {
                    let style = dataSource.styleForUnit(unit)
                    textView.backgroundColor = style.textFieldBackgroundColor
                    textView.textField.backgroundColor = style.textFieldBackgroundColor
                    textView.textField.textColor = style.textFieldTextColor
                }
            }
        }
        
        if let segmentV = segmentViews.last {
            pointV.backgroundColor = UIColor.clear
            pointV.translatesAutoresizingMaskIntoConstraints = false
            segmentV.addSubview(pointV)

            // Create ImageView
            let imageView = UIImageView()
            imageView.image = UIImage(named: "ic_polygon_ruler") // Replace with your image name
            
            
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            pointV.addSubview(imageView)

            NSLayoutConstraint.activate([
                pointV.centerXAnchor.constraint(equalTo: segmentV.centerXAnchor),
                pointV.centerYAnchor.constraint(equalTo: segmentV.centerYAnchor, constant: 5),
                pointV.widthAnchor.constraint(equalToConstant: 40),
                pointV.heightAnchor.constraint(equalToConstant: 40),

                // Center the image inside pointV
                imageView.centerXAnchor.constraint(equalTo: pointV.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: pointV.centerYAnchor),
                imageView.widthAnchor.constraint(equalTo: pointV.widthAnchor, multiplier: 1.0),  // Adjust image size
                imageView.heightAnchor.constraint(equalTo: pointV.heightAnchor, multiplier: 1.0)
            ])
        }

        return (segmentViews, scrollViews, textViews, pointerViews)
    }
    
    
    private func showSegmentAtIndex(_ index: Int) {
        guard let segmentedViews = self.segmentedViews, index < segmentedViews.count else { return }
        
        selectedSegmentIndex = index
        
        for i in 0..<segmentedViews.count {
            segmentedViews[i].isHidden = (i != index)
//            textViews?[i].resignFirstResponder()
            if i == index, let unit = dataSource?.unitForSegmentAtIndex(index: i).unit {
                let style = dataSource?.styleForUnit(unit)
                textViews?[i].backgroundColor = style?.textFieldBackgroundColor ?? .clear
                textViews?[i].textField.backgroundColor = style?.textFieldBackgroundColor ?? .clear
                textViews?[i].textField.textColor = style?.textFieldTextColor ?? .white
            }
        }
        updateScrollViews()
        updateTextFields()
    }
    
    @objc func scrollViewCurrentValueChanged(_ sender: RulerRangeScrollView) {
        if let dataSource = self.dataSource {
            let activeSegmentUnit = dataSource.unitForSegmentAtIndex(
                    index: 0)
            if let unit = activeSegmentUnit.unit,
               let scrollViewOfSelectedSegment = self.scrollViews?[0] {
                self.measurement = NSMeasurement(doubleValue: Double(scrollViewOfSelectedSegment.currentValue),
                        unit: unit)
                self.delegate?.valueChanged(measurement: self.measurement!)
                updateTextFields()
            }
        }
    }
    
    private func setupSegmentBottomView(inSegmentView parent: UIView,
                                        unit segmentUnit: RulerSegmentUnit,
                                        style: RulerSegmentUnitControlStyle) -> RulerRangeTextView {
        let textView = RulerRangeTextView(frame: self.bounds)
        textView.backgroundColor = style.textFieldBackgroundColor
        textView.textField.backgroundColor = style.textFieldBackgroundColor
        textView.textField.textColor = style.textFieldTextColor
        textView.unit = segmentUnit.unit
        textView.formatter = segmentUnit.formatter
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.addTarget(self,
                action: #selector(RulerMultiUnitRuler.textViewValueChanged(_:)),
                for: .valueChanged)
        parent.addSubview(textView)
        return textView
    }
    
    @objc func textViewValueChanged(_ sender: RulerRangeTextView) {
        if let dataSource = self.dataSource {
            let activeSegmentUnit = dataSource.unitForSegmentAtIndex(
                    index: 0)
            if let textViews = self.textViews, let unit = activeSegmentUnit.unit {
                self.measurement = NSMeasurement(doubleValue: Double(textViews[0].currentValue),
                        unit: unit)
                self.delegate?.valueChanged(measurement: self.measurement!)
            }
            self.updateScrollViews()
        }
    }
    
    func updateScrollViews() {
        if let dataSource = self.dataSource {
            if let scrollViews = self.scrollViews {
                for index in 0 ... scrollViews.count - 1 {
                    let segmentUnit = dataSource.unitForSegmentAtIndex(index: index)
                    if let measurement = self.measurement, let unit = segmentUnit.unit {
                        let value = Float(measurement.converting(to: unit).value)
                        scrollViews[index].currentValue = value
                    }
                    scrollViews[index].scrollToCurrentValueOffset()
                }
            }
        }
    }
    
    private func setupSegmentLineUnderBottomView(inSegmentView parent: UIView) -> UIView {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(view)
        return view
    }
    
    func updateTextFields() {
        if let dataSource = self.dataSource {
            if let scrollViews = self.scrollViews {
                for index in 0 ... scrollViews.count - 1 {
                    let segmentUnit = dataSource.unitForSegmentAtIndex(index: index)
                    if let measurement = self.measurement, let unit = segmentUnit.unit {
                        var value = Float(measurement.converting(to: unit).value)
                        
                        let minScale = RulerRangeMarkerType.minScale(types: segmentUnit.markerTypes)
                        value = Float(lroundf(value / minScale)) * minScale
                            self.textViews?[index].currentValue = value
                            DispatchQueue.main.async {
                                let _ = self.textViews?[index].resignFirstResponder()
                                self.textViews?[index].currentValue = value
                            }
                    }
                }
            }
        }
    }
}
