//
//  WeightViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/11/24.
//

import UIKit

class WeightViewController: CommonViewController {
    
    //MARK: -------------VARIABLE
    var selectedWeight: String?
    var rangeStart = Measurement(value: 1.0, unit: UnitMass.kilograms)
    var rangeLength = Measurement(value: Double(100), unit: UnitMass.kilograms)
    var segments = Array<RulerSegmentUnit>()
    var colorOverridesEnabled = false
    private var backgroundGradient: CAGradientLayer?
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var measureTypeSegment: UISegmentedControl!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var scaleMBV: UIView!
    @IBOutlet weak var weightRuler: RulerMultiUnitRuler!
    @IBOutlet var viewBackground: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpFont()
        setUpSegmet()
        setupSegmentedControlStyle()
        self.setupKGRuler()
        setupBackgroundGradient()
        updateContinueButton(isEnabled: true)
        setupContinueButtonIcon(isEnabled: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
    }
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.4)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(setTitle: [AppStrings.skipStr], setTintColor: .black, setTitleColor: UIColor.txtSkip)
        
        //        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        //        self.setProgress(0.4)
        //        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        //        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite) skipe remove need of client
    }
    
    override func rightBtnActn(sender: UIButton) {
        appUserDefaults.setRegistrationSkip(value: true)
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
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
    func setupKGRuler(){
        weightRuler.backgroundColor = UIColor.clear
        segments = self.createSegments()
        weightRuler.delegate = self
        weightRuler.dataSource = self
        weightRuler.direction = .horizontal
        let initialValue = (self.rangeForUnit(UnitMass.kilograms).location + self.rangeForUnit(UnitMass.kilograms).length) / 2
        weightRuler.measurement = NSMeasurement(
            doubleValue: Double(initialValue),
            unit: UnitMass.kilograms)
        
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
        
        weightRuler.refresh()
        if let measurement = weightRuler.measurement {
            weightRuler.delegate?.valueChanged(measurement: measurement)
        }
    }
    
    func setupLbsRuler(){
        weightRuler.backgroundColor = UIColor.clear
        segments = self.createSegmentsLbs()
        weightRuler.delegate = self
        weightRuler.dataSource = self
        weightRuler.direction = .horizontal
        let initialValue = (self.rangeForUnit(UnitMass.pounds).location + self.rangeForUnit(UnitMass.pounds).length) / 2
        weightRuler.measurement = NSMeasurement(
            doubleValue: Double(initialValue),
            unit: UnitMass.pounds)
        self.view.layoutIfNeeded()
        self.view.layoutSubviews()
        weightRuler.refresh()
        if let measurement = weightRuler.measurement {
            weightRuler.delegate?.valueChanged(measurement: measurement)
        }
    }
    
    
    private func createSegments() -> Array<RulerSegmentUnit> {
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .providedUnit
        let kgSegment = RulerSegmentUnit(name: "kg", unit: UnitMass.kilograms, formatter: formatter)
        
        kgSegment.name = "Kilogram"
        kgSegment.unit = UnitMass.kilograms
        
        let kgMarkerTypeMax = RulerRangeMarkerType(color: UIColor.gray, size: CGSize(width: 1.0, height: 55.0), scale: 1.0)
        kgMarkerTypeMax.labelVisible = true
        //35 -> 25
        kgSegment.markerTypes = [
            RulerRangeMarkerType(color: UIColor(red: 57.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 1.0), size: CGSize(width: 1.0, height: 25.0), scale: 0.1),
            RulerRangeMarkerType(color: UIColor(red: 80.0/255.0, green: 83.0/255.0, blue: 91.0/255.0, alpha: 1.0), size: CGSize(width: 1.0, height: 55.0), scale: 1.0)
        ]
        
        kgSegment.markerTypes.last?.labelVisible = true
        return [kgSegment]
    }
    
    private func createSegmentsLbs() -> Array<RulerSegmentUnit> {
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .providedUnit
        let lbsSegment = RulerSegmentUnit(name: "Lbs", unit: UnitVolume.milliliters, formatter: formatter)
        
        lbsSegment.name = "Pounds"
        lbsSegment.unit = UnitMass.pounds
        
        let lbsMarkerTypeMax = RulerRangeMarkerType(color: UIColor.white, size: CGSize(width: 1.0, height: 50.0), scale: 10.0)
        
        lbsSegment.markerTypes = [
            RulerRangeMarkerType(color: UIColor(red: 57.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 1.0), size: CGSize(width: 1.0, height: 25.0), scale: 0.1),
            RulerRangeMarkerType(color: UIColor(red: 80.0/255.0, green: 83.0/255.0, blue: 91.0/255.0, alpha: 1.0), size: CGSize(width: 1.0, height: 50.0), scale: 1.0)
        ]
        
        lbsMarkerTypeMax.labelVisible = true
        lbsSegment.markerTypes.last?.labelVisible = true
        
        return [lbsSegment]
    }
    
    //---------------*****-----------------MAKE RULER FOR WEIGHT END PONIT
    func setUpSegmet() {
        measureTypeSegment.setTitle("kg", forSegmentAt: 0)
        measureTypeSegment.setTitle("lbs", forSegmentAt: 1)
        setUISegmentControlAppearance()
    }
    
    func setUISegmentControlAppearance() {
        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [.foregroundColor: UIColor.txtDarkGray,
                 .font: AppFont.semibold.size(14.0, familyName: familyFunnelSans)
                ], for: .normal)
        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [.foregroundColor: UIColor.appWhite,
                    .font:AppFont.semibold.size(14.0, familyName: familyFunnelSans)
                ], for: .selected)
    }
    
    //------------------************Font
    func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    
    //MARK: ------------setup segmantstyle
//    func setupSegmentedControlStyle(){
//        let unselectedBackgroundImage = UIImage(color: UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1))
//        let selectedBacgroundImage = UIImage(color:UIColor.appYellow)
//        
//        measureTypeSegment.setBackgroundImage(unselectedBackgroundImage, for: .normal, barMetrics: .default)
//        measureTypeSegment.setBackgroundImage(unselectedBackgroundImage, for: .highlighted, barMetrics: .default)
//        measureTypeSegment.setBackgroundImage(selectedBacgroundImage, for: .selected, barMetrics: .default)
//        
//        measureTypeSegment.setDividerImage(selectedBacgroundImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
//        
//        measureTypeSegment.layer.borderWidth = 0
//        measureTypeSegment.layer.borderColor = UIColor.clear.cgColor
//    }
    
    func setupSegmentedControlStyle() {

        let unselectedBackgroundImage = UIImage(color: UIColor(red: 16/255, green: 17/255, blue: 19/255, alpha: 1))?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))

        let selectedBackgroundImage = UIImage(color: .appWhite)?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))

        measureTypeSegment.setBackgroundImage(unselectedBackgroundImage, for: .normal, barMetrics: .default)
        measureTypeSegment.setBackgroundImage(selectedBackgroundImage, for: .selected, barMetrics: .default)
        measureTypeSegment.setBackgroundImage(unselectedBackgroundImage, for: .highlighted, barMetrics: .default)

        let clearDivider = UIImage(color: .clear)
        measureTypeSegment.setDividerImage(clearDivider,
                                           forLeftSegmentState: .normal,
                                           rightSegmentState: .normal,
                                           barMetrics: .default)

        measureTypeSegment.layer.borderWidth = 0
        measureTypeSegment.layer.borderColor = UIColor.clear.cgColor
    }

    private func setupBackgroundGradient() {
        // Remove old gradient if any
        backgroundGradient?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.colors = UIColor.appMultiColor(.greenBgGradient).map { $0.cgColor }
        
        // VERY IMPORTANT – match first UI direction
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint   = CGPoint(x: 1.0, y: 1.0)
        
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.cornerRadius = 0
        
        viewBackground.layer.insertSublayer(gradient, at: 0)
        backgroundGradient = gradient
    }
    
    func updateContinueButton(isEnabled: Bool) {
        continueBtn.isEnabled = isEnabled
        continueBtn.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0.2) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.continueBtn.tintColor = .mainBg   // arrow color
                self.continueBtn.backgroundColor = .appWhite
                self.continueBtn.setTitleColor(.mainBg, for: .normal)
            } else {
                self.continueBtn.tintColor = .appWhite
                self.continueBtn.backgroundColor = .appDarkGray
                self.continueBtn.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        let arrowImage = UIImage(named: isEnabled ? "blackRightArrow" : "whiteRightArrow")?
            .withRenderingMode(.alwaysTemplate)
        
        continueBtn.setImage(arrowImage, for: .normal)
        
        // Force image on right side
        continueBtn.semanticContentAttribute = .forceRightToLeft
        
        // Space between text and image
        continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -12)
        continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 12)
        
        continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    
    @IBAction func measureTypeSegmentActn(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        
        if sender.selectedSegmentIndex == 0 {
            rangeStart = Measurement(value: 1.0, unit: UnitMass.kilograms)
            rangeLength = Measurement(value: Double(100), unit: UnitMass.kilograms)
            self.setupKGRuler()
            //            weightRuler.refresh()
            
        }else{
            rangeStart = Measurement(value: 1.0, unit: UnitMass.pounds)
            rangeLength = Measurement(value: Double(100), unit: UnitMass.pounds)
            
            self.setupLbsRuler()
            //            weightRuler.refresh()
        }
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        if let selectedWeight = selectedWeight, !selectedWeight.isEmpty {
            RegistrationVM.addWeightApi(viewController: self, inputWeight: selectedWeight, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                if getResultData.status == true {
                    
                    appUserDefaults.setRegistrationSkip(value: false)
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
}

//MARK: --------------------- RULER DELEGATE
extension WeightViewController: RulerMultiUnitRulerDelegate, RulerMultiUnitRulerDataSource{
    func valueChanged(measurement: NSMeasurement) {
        print("value changed to \(measurement.doubleValue)")
        self.selectedWeight = nil
        if let selectedTitle = measureTypeSegment.titleForSegment(at: measureTypeSegment.selectedSegmentIndex) {
            print("Selected segment title: \(selectedTitle)")
            let msValue = String(format: "%.2f", measurement.doubleValue)
            self.selectedWeight = msValue + selectedTitle
        }
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
        style.scrollViewBackgroundColor = UIColor.clear //It is used for background of scroll scale UIColor(red: 0.22, green: 0.74, blue: 0.86, alpha: 1.0)
        style.TopTextFieldFont = AppFont.bold.size(40, familyName: familyManrope)
        let range = self.rangeForUnit(unit)
        if unit == UnitMass.pounds {
            
            style.textFieldBackgroundColor = UIColor.red
            //              color override location:location+40% red , location+60%:location.100% green
        } else {
            style.textFieldBackgroundColor = UIColor.black
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
