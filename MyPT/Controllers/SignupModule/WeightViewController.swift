//
//  WeightViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/11/24.
//

import UIKit

class WeightViewController: CommonViewController {

    //MARK: -------------VARIABLE
    let rengeView = RangePickerView()
    var values = Array(1 ... 100)
    var selectedWeight: String?
    
    
//    var massMeasurements: [Measurement<UnitMass>]  = (1...350).map { value in
//        Measurement(value: Double(value), unit: UnitMass.kilograms)
//    }
    
    let massUnits: [(String, UnitMass)] = [ // Array of tuples
           ("kg", .kilograms),
           ("g", .grams)
       ]
    
    var rangeStart = Measurement(value: 1.0, unit: UnitMass.kilograms)
    var rangeLength = Measurement(value: Double(230), unit: UnitMass.kilograms)
//    var segments = Array<RulerSegmentUnit>()
    var colorOverridesEnabled = false
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var measureTypeSegment: UISegmentedControl!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var scaleMBV: UIView!
        
    @IBOutlet weak var weightRuler: RulerMultiUnitRuler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpFont()
        setLayout()
        setUpSegmet()
        setupSegmentedControlStyle()
        enableContinueBtn(isSelected: true)
        
//        self.setupRuler()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.4)
//        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        //-----------*************
        DispatchQueue.main.async {
            self.measureTypeSegment.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 6.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //MARK: -----------------MAKE RULER FOR WEIGHT
//    func setupRuler(){
//        segments = self.createSegments()
//        weightRuler.delegate = self
//        weightRuler.dataSource = self
//        weightRuler.direction = .horizontal
//        let initialValue = (self.rangeForUnit(UnitMass.kilograms).location + self.rangeForUnit(UnitMass.kilograms).length) / 2
//        weightRuler.measurement = NSMeasurement(
//            doubleValue: Double(initialValue),
//            unit: UnitMass.kilograms)
//        
//        self.view.layoutSubviews()
//    }
    
//    private func createSegments() -> Array<RulerSegmentUnit> {
//       
//        let formatter = MeasurementFormatter()
//        formatter.unitStyle = .medium
//        formatter.unitOptions = .providedUnit
//        let kgSegment = RulerSegmentUnit(name: "kg", unit: UnitMass.kilograms, formatter: formatter)
//
//        kgSegment.name = "Kilogram"
//        kgSegment.unit = UnitMass.kilograms
//        
//        
//        
////        let formatter = MeasurementFormatter()
////        formatter.unitStyle = .medium
////        formatter.unitOptions = .providedUnit
////        let kgSegment = RulerSegmentUnit(name: "Centimeters", unit: UnitLength.centimeters, formatter: formatter)
////
////        kgSegment.name = "Centimeter"
////        kgSegment.unit = UnitLength.centimeters
//        
//        
////        // Define the segment for Centimeters
////        let cmSegment = NMSegmentUnit(name: "Centimeters", unit: UnitLength.centimeters, formatter: formatter)
////
////        // Define the segment for Feet
////        let feetSegment = NMSegmentUnit(name: "Feet", unit: UnitLength.feet, formatter: formatter)
////
////        // Customize segment names (optional)
////        cmSegment.name = "Centimeter"
////        feetSegment.name = "Feet"
//        
//        
//        /*
//         let feetUnit = NMUnit(name: "ft", abbreviation: "ft", coefficient: 12.0, maxValue: 7, minValue: 2, majorMarkInterval: 1)
//         let inchUnit = NMUnit(name: "in", abbreviation: "in", coefficient: 1.0, maxValue: 11, minValue: 0, majorMarkInterval: 1)
//
//         ruler.addUnit(feetUnit)
//         ruler.addUnit(inchUnit)
//         */
//        
//        let kgMarkerTypeMax = RulerRangeMarkerType(color: UIColor.gray, size: CGSize(width: 1.0, height: 50.0), scale: 5.0)
//        kgMarkerTypeMax.labelVisible = true
//        kgSegment.markerTypes = [
//            RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 35.0), scale: 0.5),
//            RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 50.0), scale: 1.0)]
//
//        let lbsSegment = RulerSegmentUnit(name: "lbs", unit: UnitMass.pounds, formatter: formatter)
//        let lbsMarkerTypeMax = RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 50.0), scale: 10.0)
//
//        lbsSegment.markerTypes = [
//            RulerRangeMarkerType(color: UIColor.gray, size: CGSize(width: 1.0, height: 35.0), scale: 1.0)]
//        
////        let gramsSegment = RulerSegmentUnit(name: "grams", unit: UnitMass.grams, formatter: formatter)
//////
//////        let lbsSegment = RulerSegmentUnit(name: "ft", unit: UnitLength.centimeters, formatter: formatter)
////        
////        let gramsSegmentTypeMax = RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 50.0), scale: 10.0)
////
////        gramsSegment.markerTypes = [
////            RulerRangeMarkerType(color: UIColor.yellow, size: CGSize(width: 1.0, height: 35.0), scale: 1.0)]
//
////        if moreMarkers {
////            kgSegment.markerTypes.append(kgMarkerTypeMax)
////            lbsSegment.markerTypes.append(lbsMarkerTypeMax)
////        }
//        
//        kgSegment.markerTypes.last?.labelVisible = true
//        lbsSegment.markerTypes.last?.labelVisible = true
//        return [kgSegment, lbsSegment]
//    }
    
    //---------------*****-----------------MAKE RULER FOR WEIGHT END PONIT
    
    func setUpSegmet(){
        measureTypeSegment.setTitle("kg", forSegmentAt: 0)
        measureTypeSegment.setTitle("lbs", forSegmentAt: 1)
        setUISegmentControlAppearance()
    }
    
    func setUISegmentControlAppearance() {
//        UISegmentedControl.appearance().selectedSegmentTintColor = .white
//        UISegmentedControl.appearance().backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.txtDarkGray, .font:AppFont.semibold.size(14.0, familyName: familyManrope)], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.appWhite, .font:AppFont.semibold.size(14.0, familyName: familyManrope)], for: .selected)
    }
    
    //------------------************Font
    func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    func setLayout(){
        // Add constraints to the view
//        rengeView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(rengeView)
//
//        NSLayoutConstraint.activate([
//            rengeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
//            rengeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
////            rengeView.widthAnchor.constraint(equalToConstant: 250),
//            rengeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
////            rengeView.heightAnchor.constraint(equalToConstant: 250)
//        ])
//        
//        rengeView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(rengeView)
//
//        NSLayoutConstraint.activate([
//            rengeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            rengeView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            rengeView.widthAnchor.constraint(equalTo: rengeView.heightAnchor, multiplier: 1.0) // 1:1 aspect ratio
//        ])
        
        DispatchQueue.main.async {
            self.rengeView.frame = self.scaleMBV.bounds
            self.scaleMBV.addSubview(self.rengeView)
        }
        
        rengeView.delegate = self
        rengeView.alignment = .horizontal
        rengeView.valueType = "kg" //"CM" //"kg"
        rengeView.backgroundColor = UIColor.clear
        
//        if rengeView.alignment == .vertical {
//            rengeView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
//        }
    }
    
    //MARK: ------------setup segmantstyle
    func setupSegmentedControlStyle(){
        let unselectedBackgroundImage = UIImage(color: UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1))
        let selectedBacgroundImage = UIImage(color:UIColor.appYellow)

        measureTypeSegment.setBackgroundImage(unselectedBackgroundImage, for: .normal, barMetrics: .default)
        measureTypeSegment.setBackgroundImage(unselectedBackgroundImage, for: .highlighted, barMetrics: .default)
        measureTypeSegment.setBackgroundImage(selectedBacgroundImage, for: .selected, barMetrics: .default)

        measureTypeSegment.setDividerImage(selectedBacgroundImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        measureTypeSegment.layer.borderWidth = 0
        measureTypeSegment.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    @IBAction func measureTypeSegmentActn(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        if sender.selectedSegmentIndex == 0 {
            rengeView.valueType = "kg"
        }else{
            rengeView.valueType = "lbs"
        }
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        if let selectedWeight = selectedWeight, !selectedWeight.isEmpty {
            RegistrationVM.addWeightApi(viewController: self, inputWeight: selectedWeight, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                if getResultData.status == true {
                    
                    if let detailsData = getResultData.data?.first {
                        appUserDefaults.saveUserToUserDefaults(detailsData)
                    }
                    let vc:HeightViewController = HeightViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.select_Weight)
        }
    }
    
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }

}

//MARK: --------------------Extension for RangePickerViewDelegate
extension WeightViewController: RangePickerViewDelegate{
    func rangePickerView(_ rangePickerView: RangePickerView, titleForRowAtIndex row: Int) -> String? {
        String(values[row])
//        String(massMeasurements[row].value)
    }

    func rangePickerView(_ rangePickerView: RangePickerView, didSelectRow row: Int) {
    }

    func rangePickerView(_ rangePickerView: RangePickerView, numberOfIndicesAt row: Int) -> Int? {
        
//        massMeasurements.count
        values.count
    }

    func rangePickerView(_ rangePickerView: RangePickerView, headerTitleIndicesAt row: Int) -> String? {
//        String(massMeasurements[row].value)
        print("selected title = ", String(values[row]))
        self.selectedWeight = nil
        self.selectedWeight = String(values[row])
       return String(values[row])
    }
}

/*
 extension WeightViewController: RulerMultiUnitRulerDelegate, RulerMultiUnitRulerDataSource{
 func valueChanged(measurement: NSMeasurement) {
 print("value changed to \(measurement.doubleValue)")
 }
 
 func unitForSegmentAtIndex(index: Int) -> RulerSegmentUnit {
 //
 return segments[index]
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
 style.scrollViewBackgroundColor = UIColor(red: 0.22, green: 0.74, blue: 0.86, alpha: 1.0)
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
 */
