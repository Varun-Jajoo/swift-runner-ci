//
//  GlassSizeViewController.swift
//  MyPT
//
//  Created by techsaga corp on 17/02/25.
//

import UIKit

class GlassSizeViewController: CommonViewController {

    //MARK: ------------VARIABLE
    var sendGlassGoals:((Double?) -> Void)?
    
    let massUnits: [(String, UnitVolume)] = [ // Array of tuples
        ("l", .liters),
        ("ml", .milliliters)
       ]
    
    var rangeStart = Measurement(value: 100.0, unit: UnitVolume.milliliters)
    var rangeLength = Measurement(value: Double(2), unit: UnitVolume.liters)
    var colorOverridesEnabled = false
    var segments = Array<RulerSegmentUnit>()
    
    let glassView = FrostedGlassView()

    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var glassMBV: UIView!
    @IBOutlet weak var scaleMBV: RulerMultiUnitRuler!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.frostedView()
        self.setupUI()
        self.setupRuler()
    }
    
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.glass_Size], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @IBAction func saveBtnActn(_ sender: UIButton) {
        print(Double(sender.accessibilityHint ?? "0.0") as Any)
        self.sendGlassGoals?(Double(sender.accessibilityHint ?? "0.0"))
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -----------------MAKE RULER FOR WEIGHT
    func setupRuler(){
        scaleMBV.backgroundColor = UIColor.clear
        segments = self.createSegments()
        scaleMBV.delegate = self
        scaleMBV.dataSource = self
        scaleMBV.direction = .vertical
        let initialValue = (self.rangeForUnit(UnitVolume.liters).location + self.rangeForUnit(UnitVolume.liters).length) / 2
        scaleMBV.measurement = NSMeasurement(
            doubleValue: Double(initialValue),
            unit: UnitVolume.liters)
        
        self.view.layoutSubviews()
    }
    
    private func createSegments() -> Array<RulerSegmentUnit> {
       
         let formatter = MeasurementFormatter()
         formatter.unitStyle = .medium
         formatter.unitOptions = .providedUnit
        let kgSegment = RulerSegmentUnit(name: "Liters", unit: UnitVolume.milliliters, formatter: formatter)

         kgSegment.name = "liters"
        kgSegment.unit = UnitVolume.milliliters
           
        kgSegment.markerTypes = [
            RulerRangeMarkerType(color: UIColor(red: 57.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 1.0), size: CGSize(width: 2.0, height: 15.0), scale: 20.0),
            RulerRangeMarkerType(color: UIColor(red: 80.0/255.0, green: 83.0/255.0, blue: 91.0/255.0, alpha: 1.0), size: CGSize(width: 2.0, height: 35.0), scale: 100.0)
         ]
        
         kgSegment.markerTypes.last?.labelVisible = true
        return [kgSegment]
    }
    
    func frostedView(){
        DispatchQueue.main.async {
//            let glassView = FrostedGlassView(frame: self.glassMBV.bounds)
            self.glassView.frame = self.glassMBV.bounds
            self.glassView.cornerRadius = 20
            self.glassView.glassFillColor = UIColor.txtDarkGray.withAlphaComponent(0.7) //glass bg color
            self.glassView.waterFillColor = UIColor.appOuterProgress
            self.glassView.glassStrokeColor = UIColor.appDarkGray.withAlphaComponent(1.0) //glass border color
            self.glassView.waterLevel = 0.1  // Set water level (0.0 to 1.0)
            self.glassMBV.addSubview(self.glassView)
        }
    }
    
    func setupUI(){
        self.saveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        DispatchQueue.main.async {
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
}

extension GlassSizeViewController: RulerMultiUnitRulerDelegate, RulerMultiUnitRulerDataSource{
    func valueChanged(measurement: NSMeasurement) {
        print("value changed to \(measurement.doubleValue)")
        self.saveBtn.accessibilityHint = "\(measurement.doubleValue)"
        self.glassView.waterLevel = normalizeMl(measurement.doubleValue)
    }
    
    func unitForSegmentAtIndex(index: Int) -> RulerSegmentUnit {
        //
        return segments[0]
    }
    
    func rangeForUnit(_ unit: Dimension) -> RulerRange<Float> {
        
        if let massUnit = unit as? UnitVolume {
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
        
//        let range = self.rangeForUnit(unit)
//        if (colorOverridesEnabled) {
//            style.colorOverrides = [
//                RulerRange<Float>(location: range.location, length: 0.1 * (range.length)): UIColor.red,
//                RulerRange<Float>(location: range.location + 0.4 * (range.length), length: 0.2 * (range.length)): UIColor.green]
//        }
        
        style.textFieldBackgroundColor = UIColor.clear
        style.textFieldTextColor = UIColor.white
        
        return style
    }
    
    func normalizeMl(_ ml: Double) -> Double {
        let lengthConverted = rangeLength.converted(to: UnitVolume.milliliters)
        
        let maxMl = ceilf(Float(lengthConverted.value)) //2000.0 // 2L in mL
        return ml / Double(maxMl)
    }
    
}

