//
//  DummyRulerViewController.swift
//  MyPT
//
//  Created by techsaga corp on 19/02/25.
//

import UIKit

class DummyRulerViewController: UIViewController {

    let massUnits: [(String, UnitMass)] = [ // Array of tuples
           ("kg", .kilograms),
           ("g", .grams)
       ]
    
    var rangeStart = Measurement(value: 1.0, unit: UnitMass.kilograms)
    var rangeLength = Measurement(value: Double(230), unit: UnitMass.kilograms)
    var segments = Array<RulerSegmentUnit>()
    var colorOverridesEnabled = false
    var moreMarkers = false
    
    //MARK: -------
    @IBOutlet weak var rulerMBV: RulerMultiUnitRuler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRuler()
    }
    
    //MARK: -----------------MAKE RULER FOR WEIGHT
    func setupRuler(){
        rulerMBV.backgroundColor = UIColor.cyan
        segments = self.createSegments()
        rulerMBV.delegate = self
        rulerMBV.dataSource = self
        rulerMBV.direction = .vertical
        let initialValue = (self.rangeForUnit(UnitMass.kilograms).location + self.rangeForUnit(UnitMass.kilograms).length) / 2
        rulerMBV.measurement = NSMeasurement(
            doubleValue: Double(initialValue),
            unit: UnitMass.kilograms)
        self.view.layoutSubviews()
        rulerMBV.refresh()
        
    }
    
    /*
    private func createSegments() -> Array<RulerSegmentUnit> {
       
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .providedUnit
        let kgSegment = RulerSegmentUnit(name: "kg", unit: UnitMass.kilograms, formatter: formatter)

        kgSegment.name = "Kilogram"
        kgSegment.unit = UnitMass.kilograms
        
        
        
//        let formatter = MeasurementFormatter()
//        formatter.unitStyle = .medium
//        formatter.unitOptions = .providedUnit
//        let kgSegment = RulerSegmentUnit(name: "Centimeters", unit: UnitLength.centimeters, formatter: formatter)
//
//        kgSegment.name = "Centimeter"
//        kgSegment.unit = UnitLength.centimeters
        
        
//        // Define the segment for Centimeters
//        let cmSegment = NMSegmentUnit(name: "Centimeters", unit: UnitLength.centimeters, formatter: formatter)
//
//        // Define the segment for Feet
//        let feetSegment = NMSegmentUnit(name: "Feet", unit: UnitLength.feet, formatter: formatter)
//
//        // Customize segment names (optional)
//        cmSegment.name = "Centimeter"
//        feetSegment.name = "Feet"
        
        
        /*
         let feetUnit = NMUnit(name: "ft", abbreviation: "ft", coefficient: 12.0, maxValue: 7, minValue: 2, majorMarkInterval: 1)
         let inchUnit = NMUnit(name: "in", abbreviation: "in", coefficient: 1.0, maxValue: 11, minValue: 0, majorMarkInterval: 1)

         ruler.addUnit(feetUnit)
         ruler.addUnit(inchUnit)
         */
        
        let kgMarkerTypeMax = RulerRangeMarkerType(color: UIColor.gray, size: CGSize(width: 1.0, height: 50.0), scale: 5.0)
        kgMarkerTypeMax.labelVisible = true
        kgSegment.markerTypes = [
            RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 35.0), scale: 0.5),
            RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 50.0), scale: 1.0)]

        let lbsSegment = RulerSegmentUnit(name: "lbs", unit: UnitMass.pounds, formatter: formatter)
        let lbsMarkerTypeMax = RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 50.0), scale: 10.0)

        lbsSegment.markerTypes = [
            RulerRangeMarkerType(color: UIColor.gray, size: CGSize(width: 1.0, height: 35.0), scale: 1.0)]
        
//        let gramsSegment = RulerSegmentUnit(name: "grams", unit: UnitMass.grams, formatter: formatter)
////
////        let lbsSegment = RulerSegmentUnit(name: "ft", unit: UnitLength.centimeters, formatter: formatter)
//
//        let gramsSegmentTypeMax = RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 50.0), scale: 10.0)
//
//        gramsSegment.markerTypes = [
//            RulerRangeMarkerType(color: UIColor.yellow, size: CGSize(width: 1.0, height: 35.0), scale: 1.0)]

//        if moreMarkers {
//            kgSegment.markerTypes.append(kgMarkerTypeMax)
//            lbsSegment.markerTypes.append(lbsMarkerTypeMax)
//        }
        
        kgSegment.markerTypes.last?.labelVisible = true
        lbsSegment.markerTypes.last?.labelVisible = true
        return [kgSegment, lbsSegment]
        
    }
    */

    private func createSegments() -> Array<RulerSegmentUnit> {
       
         let formatter = MeasurementFormatter()
         formatter.unitStyle = .medium
         formatter.unitOptions = .providedUnit
         let kgSegment = RulerSegmentUnit(name: "Kilograms", unit: UnitMass.kilograms, formatter: formatter)

         kgSegment.name = "Kilogram"
         kgSegment.unit = UnitMass.kilograms
//        let kgMarkerTypeMax = RulerRangeMarkerType(color: UIColor.green, size: CGSize(width: 1.0, height: 50.0), scale: 5.0)
//         kgMarkerTypeMax.labelVisible = true
        
        kgSegment.markerTypes = [
            RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 2.0, height: 15.0), scale: 0.1),
            RulerRangeMarkerType(color: UIColor.gray, size: CGSize(width: 2.0, height: 35.0), scale: 1.0)
         ]
        

//         let lbsSegment = RulerSegmentUnit(name: "Pounds", unit: UnitMass.pounds, formatter: formatter)
//         let lbsMarkerTypeMax = RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 50.0), scale: 10.0)

//         lbsSegment.markerTypes = [
//             RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 35.0), scale: 1.0)]

//         if moreMarkers {
//             kgSegment.markerTypes.append(kgMarkerTypeMax)
//             lbsSegment.markerTypes.append(lbsMarkerTypeMax)
//         }
        
         kgSegment.markerTypes.last?.labelVisible = true
//         lbsSegment.markerTypes.last?.labelVisible = true
//         return [kgSegment, lbsSegment]
        return [kgSegment]
    }
}


extension DummyRulerViewController: RulerMultiUnitRulerDelegate, RulerMultiUnitRulerDataSource{
    func valueChanged(measurement: NSMeasurement) {
        print("value changed to \(measurement.doubleValue)")
        
    }
    
    func unitForSegmentAtIndex(index: Int) -> RulerSegmentUnit {
        //
        return segments[0]
    }
    
    func rangeForUnit(_ unit: Dimension) -> RulerRange<Float> {
        
        if let massUnit = unit as? UnitMass {
            let locationConverted = rangeStart.converted(to: massUnit)
            let lengthConverted = rangeLength.converted(to: massUnit)
            
            return RulerRange<Float>(location: ceilf(Float(locationConverted.value)),
                                  length: ceilf(Float(lengthConverted.value)))
        }
        else {
            fatalError("Unsupported unit type: \(unit)")
        }
    }
    
    var numberOfSegments: Int {
        get {
            return segments.count
        }
        set {
            //
        }
    }
    
    func styleForUnit(_ unit: Dimension) -> RulerSegmentUnitControlStyle {
        let style: RulerSegmentUnitControlStyle = RulerSegmentUnitControlStyle()
        style.scrollViewBackgroundColor = UIColor.clear
        
        //UIColor(red: 0.22, green: 0.74, blue: 0.86, alpha: 1.0)
        let range = self.rangeForUnit(unit)
        if unit == UnitMass.pounds {

            style.textFieldBackgroundColor = UIColor.clear
//             color override location:location+40% red , location+60%:location.100% green
        } else {
            style.textFieldBackgroundColor = UIColor.red
        }
        if (colorOverridesEnabled) {
            style.colorOverrides = [
                RulerRange<Float>(location: range.location, length: 0.1 * (range.length)): UIColor.red,
                RulerRange<Float>(location: range.location + 0.4 * (range.length), length: 0.2 * (range.length)): UIColor.green]
        }
        style.textFieldBackgroundColor = UIColor.clear
        style.textFieldTextColor = UIColor.white
        
        return style
    }
}
