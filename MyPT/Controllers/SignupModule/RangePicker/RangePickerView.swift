//
//  RangePickerView.swift
//  RangePickerView


import UIKit

/// Methods for managing selections  in a range picker view.
public protocol RangePickerViewDelegate: AnyObject {
    func rangePickerView(_ rangePickerView: RangePickerView, didSelectRow row: Int)
    func rangePickerView(_ rangePickerView: RangePickerView, titleForRowAtIndex row: Int) -> String?
    func rangePickerView(_ rangePickerView: RangePickerView, numberOfIndicesAt row: Int) -> Int?
    func rangePickerView(_ rangePickerView: RangePickerView, headerTitleIndicesAt row: Int) -> String?
}

/// UI Component to display items in UIPickerView based on range selection.
public final class RangePickerView: UIView {
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var unitLabel: UILabel!
    @IBOutlet var valueView: UIView!
    @IBOutlet var seperatorView: UIView!

    var dataSource: DataSource = .init()

    /// Range of the values for the visible items. Default values is 10.
    public var visibilityRange: Int = 10 {
        didSet {
            dataSource.visibilityRange = visibilityRange
            pickerView.reloadAllComponents()
        }
    }
    
    /// The background color of the separator view.
    public var seperatorBackgroundColor: UIColor = .systemGreen {
        didSet {
            seperatorView.backgroundColor = seperatorBackgroundColor
        }
    }
    
    /// The font for the value label's text.
    public var valueFont: UIFont = .systemFont(ofSize: 38, weight: .semibold) {
        didSet {
            valueLabel.font = valueFont
        }
    }
    
    /// The text color for the value label's text.
    public var valueTextColor: UIColor = .black {
        didSet {
            valueLabel.textColor = valueTextColor
        }
    }

    /// The font for the unit label's text.
    public var unitFont: UIFont = .systemFont(ofSize: 18, weight: .regular) {
        didSet {
            unitLabel.font = unitFont
        }
    }
    
    /// The text color for the unit label's text.
    public var unitTextColor: UIColor = .gray {
        didSet {
            unitLabel.textColor = unitTextColor
        }
    }

    /// A zero-indexed number identifying selection of the range picker view.
    public var selectedIndex: Int {
        pickerView.selectedRow(inComponent: .zero)
    }

    /// Selected row of the picker view. Default values is 0.
    public func selectRow(_ row: Int, animated: Bool) {
        pickerView.selectRow(row, inComponent: .zero, animated: animated)
        let selectedValue = delegate?.rangePickerView(self, titleForRowAtIndex: row) ?? ""
        if !selectedValue.isEmpty {
            pickerView.view(forRow: row, forComponent: .zero)?.isHidden = true
            valueLabel.text = delegate?.rangePickerView(self, headerTitleIndicesAt: row)
        }
        pickerView.subviews[1].backgroundColor = .clear
    }

    var mAlignment: Alignment = .vertical
    /// Rotating picker view to specified axis directions. Default values is .vertical.
    public var alignment: Alignment {
        get { mAlignment }
        set {
            guard newValue != mAlignment else { return }
            transform = transform.rotated(by: newValue.angle)
            valueView.transform = CGAffineTransform(rotationAngle: newValue.rotationAngle)
            setRange()
            dataSource.alignment = newValue
            mAlignment = newValue
        }
    }

    /// Rotating picker view to horizontal directions if it's true. Default values is "cm".
    public var valueType: String = "cm" {
        didSet {
            if valueType != "cm" {
                unitLabel.text = valueType
                if alignment == .horizontal {
//                    valueView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                }else{
                    valueView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
                }
            } else {
                unitLabel.text = valueType
                return
            }
        }
    }

    /// The object that acts as delegate of the range picker view.
    public weak var delegate: RangePickerViewDelegate?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        setupNib()
        pickerView.delegate = dataSource
        pickerView.dataSource = dataSource
        dataSource.delegate = self
        setRange()
        configurePickerView()
    }

    private func configurePickerView() {
        if #unavailable(iOS 14), pickerView.subviews.count > 2 {
            pickerView.subviews[1].isHidden = true
            pickerView.subviews[2].isHidden = true
        }
    }

    func setRange() {
        pickerView.reloadAllComponents()
        selectRow(.zero, animated: false)
    }
}

extension RangePickerView: RangePickerViewInternalDelegate {
    func rangePickerView(titleForRowAt row: Int) -> String? {
        delegate?.rangePickerView(self, titleForRowAtIndex: row)
    }

    func rangePickerView(didSelectRow row: Int) {
        delegate?.rangePickerView(self, didSelectRow: row)
        valueLabel.text = delegate?.rangePickerView(self, headerTitleIndicesAt: row)
    }

    func rangePickerView(numberOfIndexs index: Int) -> Int? {
        delegate?.rangePickerView(self, numberOfIndicesAt: index)
    }
}



/*
public final class RangePickerView: UIView {
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var unitLabel: UILabel!
    @IBOutlet var valueView: UIView!
    @IBOutlet var seperatorView: UIView!

    var dataSource: DataSource = .init()
    
        var cmValues = Array(50...250)  // Heights in cm
        var feetValues = Array(3...12)  // Feet range (3 to 12 feet)
        var inchesValues = Array(0...11)  // Inches range (0 to 11 inches)
    
        var kgValues = Array(1...200)   // Kilograms (1 to 200 kg)
        var gramValues = Array(stride(from: 0, to: 1000, by: 100)) // Grams (0 to 900 in steps of 100g)
        var lbsValues = Array(1...440)  // Pounds (1 to 440 lbs)
    
        var selectedUnit: UnitType = .cm {
            didSet { updatePickerData() }
        }
    
        var selectedWeightUnit: WeightUnit = .kg {
            didSet { updatePickerData() }
        }
    
        enum UnitType {
            case cm
            case feetInches
        }
    
        enum WeightUnit {
            case kg
            case lbs
        }
    
       
//        /// Range of the values for the visible items. Default values is 10.
//        public var visibilityRange: Int = 10 {
//            didSet {
//                dataSource.visibilityRange = visibilityRange
//                pickerView.reloadAllComponents()
//            }
//        }

    /// Range of the values for the visible items. Default values is 10.
    public var visibilityRange: Int = 10 {
        didSet {
            dataSource.visibilityRange = visibilityRange
            pickerView.reloadAllComponents()
        }
    }
    
    /// The background color of the separator view.
    public var seperatorBackgroundColor: UIColor = .systemGreen {
        didSet {
            seperatorView.backgroundColor = seperatorBackgroundColor
        }
    }
    
    /// The font for the value label's text.
    public var valueFont: UIFont = .systemFont(ofSize: 38, weight: .semibold) {
        didSet {
            valueLabel.font = valueFont
        }
    }
    
    /// The text color for the value label's text.
    public var valueTextColor: UIColor = .black {
        didSet {
            valueLabel.textColor = valueTextColor
        }
    }

    /// The font for the unit label's text.
    public var unitFont: UIFont = .systemFont(ofSize: 18, weight: .regular) {
        didSet {
            unitLabel.font = unitFont
        }
    }
    
    /// The text color for the unit label's text.
    public var unitTextColor: UIColor = .gray {
        didSet {
            unitLabel.textColor = unitTextColor
        }
    }

    //---------************
    
        func updatePickerData() {
            pickerView.reloadAllComponents()
            selectRow(0, animated: false)
        }
    
        /// Select a specific row in the picker
//        public func selectRow(_ row: Int, animated: Bool) {
//            pickerView.selectRow(row, inComponent: 0, animated: animated)
//            valueLabel.text = getSelectedValue()
//        }
    
        /// Get selected value as a string
        public func getSelectedValue() -> String {
            let selectedRow = pickerView.selectedRow(inComponent: 0)
    
            switch selectedUnit {
            case .cm:
                return "\(cmValues[selectedRow]) cm"
            case .feetInches:
                let selectedFeet = feetValues[pickerView.selectedRow(inComponent: 0)]
                let selectedInches = inchesValues[pickerView.selectedRow(inComponent: 1)]
                return "\(selectedFeet) ft \(selectedInches) in"
            }
        }
    
    
    /// A zero-indexed number identifying selection of the range picker view.
    public var selectedIndex: Int {
        pickerView.selectedRow(inComponent: .zero)
    }

    /// Selected row of the picker view. Default values is 0.
    public func selectRow(_ row: Int, animated: Bool) {
        pickerView.selectRow(row, inComponent: .zero, animated: animated)
        
//        valueLabel.text = getSelectedValue()
        
        let selectedValue = delegate?.rangePickerView(self, titleForRowAtIndex: row) ?? ""
        if !selectedValue.isEmpty {
            pickerView.view(forRow: row, forComponent: .zero)?.isHidden = true
            valueLabel.text = delegate?.rangePickerView(self, headerTitleIndicesAt: row)
        }
    
        pickerView.subviews[1].backgroundColor = .clear
    }

    var mAlignment: Alignment = .vertical
    /// Rotating picker view to specified axis directions. Default values is .vertical.
    public var alignment: Alignment {
        get { mAlignment }
        set {
            guard newValue != mAlignment else { return }
            transform = transform.rotated(by: newValue.angle)
            valueView.transform = CGAffineTransform(rotationAngle: newValue.rotationAngle)
            setRange()
            dataSource.alignment = newValue
            mAlignment = newValue
        }
    }

    /// Rotating picker view to horizontal directions if it's true. Default values is "cm".
    public var valueType: String = "cm" {
        didSet {
            if valueType != "cm" {
                unitLabel.text = valueType
                if alignment == .horizontal {
//                    valueView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                }else{
                    valueView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
                }
            } else {
                unitLabel.text = valueType
                return
            }
        }
    }

    /// The object that acts as delegate of the range picker view.
    public weak var delegate: RangePickerViewDelegate?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        setupNib()
        pickerView.delegate = dataSource
        pickerView.dataSource = dataSource
        dataSource.delegate = self
//        pickerView.delegate = self
//        pickerView.dataSource = self
        
        setRange()
        configurePickerView()
    }

    private func configurePickerView() {
        if #unavailable(iOS 14), pickerView.subviews.count > 2 {
            pickerView.subviews[1].isHidden = true
            pickerView.subviews[2].isHidden = true
        }
    }

    func setRange() {
        pickerView.reloadAllComponents()
        selectRow(.zero, animated: false)
    }
}


extension RangePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return selectedUnit == .feetInches ? 2 : 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedUnit {
        case .cm:
            return cmValues.count
        case .feetInches:
            return component == 0 ? feetValues.count : inchesValues.count
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedUnit {
        case .cm:
            return "\(cmValues[row]) cm"
        case .feetInches:
            return component == 0 ? "\(feetValues[row]) ft" : "\(inchesValues[row]) in"
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueLabel.text = getSelectedValue()
    }
}


extension RangePickerView: RangePickerViewInternalDelegate {
    func rangePickerView(titleForRowAt row: Int) -> String? {
//        return selectedUnit == .feetInches ? 2 : 1
//        delegate?.rangePickerView(self, titleForRowAtIndex: row)
        
        switch selectedUnit {
        case .cm:
            return "\(cmValues[row]) cm"
        case .feetInches:
            return row == 0 ? "\(feetValues[row]) ft" : "\(inchesValues[row]) in"
        }
    }

    func rangePickerView(didSelectRow row: Int) {
        delegate?.rangePickerView(self, didSelectRow: row)
        valueLabel.text = delegate?.rangePickerView(self, headerTitleIndicesAt: row)
    }

    func rangePickerView(numberOfIndexs index: Int) -> Int? {
        delegate?.rangePickerView(self, numberOfIndicesAt: index)
    }
}
*/


/*
 {
     @IBOutlet var pickerView: UIPickerView!
     @IBOutlet var valueLabel: UILabel!
     @IBOutlet var unitLabel: UILabel!
     @IBOutlet var valueView: UIView!
     @IBOutlet var seperatorView: UIView!

     var cmValues = Array(50...250)  // Heights in cm
     var feetValues = Array(3...12)  // Feet range (3 to 12 feet)
     var inchesValues = Array(0...11)  // Inches range (0 to 11 inches)
     
     var kgValues = Array(1...200)   // Kilograms (1 to 200 kg)
     var gramValues = Array(stride(from: 0, to: 1000, by: 100)) // Grams (0 to 900 in steps of 100g)
     var lbsValues = Array(1...440)  // Pounds (1 to 440 lbs)

     var selectedUnit: UnitType = .cm {
         didSet { updatePickerData() }
     }
     
     var selectedWeightUnit: WeightUnit = .kg {
         didSet { updatePickerData() }
     }

     enum UnitType {
         case cm
         case feetInches
     }
     
     enum WeightUnit {
         case kg
         case lbs
     }

     var dataSource: DataSource = .init()
     /// The object that acts as delegate of the range picker view.
     public weak var delegate: RangePickerViewDelegate?
     
     override public init(frame: CGRect) {
         super.init(frame: frame)
         setup()
     }

     public required init?(coder: NSCoder) {
         super.init(coder: coder)
         setup()
     }

     func setup() {
         setupNib()
         pickerView.delegate = self
         pickerView.dataSource = self
         updatePickerData()
     }

     func updatePickerData() {
         pickerView.reloadAllComponents()
         selectRow(0, animated: false)
     }

     /// Select a specific row in the picker
     public func selectRow(_ row: Int, animated: Bool) {
         pickerView.selectRow(row, inComponent: 0, animated: animated)
         valueLabel.text = getSelectedValue()
     }

     /// Get selected value as a string
     public func getSelectedValue() -> String {
         let selectedRow = pickerView.selectedRow(inComponent: 0)
         
         switch selectedUnit {
         case .cm:
             return "\(cmValues[selectedRow]) cm"
         case .feetInches:
             let selectedFeet = feetValues[pickerView.selectedRow(inComponent: 0)]
             let selectedInches = inchesValues[pickerView.selectedRow(inComponent: 1)]
             return "\(selectedFeet) ft \(selectedInches) in"
         }
     }
 }
 */
