//
//  DemmyAgeViewController.swift
//  MyPT
//
//  Created by techsaga corp on 01/02/25.
//

import UIKit


class DemmyAgeViewController: UIViewController {
    
    @IBOutlet weak var yearsMBV: UIView!
    @IBOutlet weak var monthsMBV: UIView!
    @IBOutlet weak var dayMBV: UIView!
    
    private var years = Array(2020...2030).map { "\($0)" }
    
    private let datePickerContainer = DatePickerContainerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupDatePickerContainer()
        
    }
    
    private func setupDatePickerContainer() {
          view.addSubview(datePickerContainer)
        
        datePickerContainer.translatesAutoresizingMaskIntoConstraints = false

          NSLayoutConstraint.activate([
              datePickerContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              datePickerContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
              datePickerContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
              datePickerContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
          ])
        datePickerContainer.backgroundColor = UIColor.red
        
      }
    
    func customDOB(){
        DispatchQueue.main.async {
            let circularPicker = CircularPicker()
            circularPicker.frame = self.yearsMBV.bounds
            //CircularPicker(frame: CGRect(x: 20, y: 100, width: self.view.frame.size.width-40, height: 300)) // Adjust frame as needed
//                circularPicker.radius = 100
            circularPicker.pickerType = .year // Set the initial picker type
//                circularPicker.backgroundColor = UIColor.black
//                circularPicker.frame.origin.x = 30
            
            circularPicker.theme.backgroundColor = UIColor.mainBg.withAlphaComponent(0.4)
            circularPicker.theme.gradientColors = [UIColor.clear, UIColor.clear, UIColor.clear]
            circularPicker.theme.selectedTextColor = UIColor.appWhite
            circularPicker.theme.textColor = UIColor.txtDarkGray
            circularPicker.roundSideCorners(radius: circularPicker.frame.size.width/2.5, cornerSide: [.topLeft, .topRight])
            circularPicker.theme.centerLabelColor = UIColor.clear
//                circularPicker.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: circularPicker.frame.size.width/2.0)
            self.yearsMBV.addSubview(circularPicker)
            
//                self.yearsMBV.backgroundColor = UIColor.black
            
            
            
            let circularPickerM = CircularPicker()
            circularPickerM.frame = self.monthsMBV.bounds
            //CircularPicker(frame: CGRect(x: 20, y: 100, width: self.view.frame.size.width-40, height: 300)) // Adjust frame as needed
//                circularPickerM.radius = 100
            circularPickerM.pickerType = .month // Set the initial picker type
//                circularPickerM.frame.origin.x = 30
//                circularPickerM.backgroundColor = UIColor.clear
//                circularPickerM.theme.backgroundColor = UIColor.mainBg
            circularPickerM.theme.backgroundColor = UIColor.mainBg.withAlphaComponent(0.1)
            
            circularPickerM.theme.gradientColors = [UIColor.appDarkGray.withAlphaComponent(0.1), UIColor.appWhite, UIColor.appWhite, UIColor.appDarkGray.withAlphaComponent(0.1)]
            circularPickerM.theme.selectedTextColor = UIColor.appWhite
            circularPickerM.theme.textColor = UIColor.txtDarkGray
//                circularPickerM.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: circularPickerM.frame.size.width/2.0)
            
           
            circularPickerM.roundSideCorners(radius: circularPickerM.frame.size.width/2.5, cornerSide: [.topLeft, .topRight])
            circularPickerM.theme.centerLabelColor = .clear
            
            self.monthsMBV.addSubview(circularPickerM)
            
            let circularPickerDay = CircularPicker()
            circularPickerDay.frame = self.dayMBV.bounds
//                circularPickerDay.theme.backgroundColor = UIColor.mainBg
            circularPickerDay.theme.backgroundColor = UIColor.mainBg.withAlphaComponent(0.1)
           
            circularPickerDay.theme.gradientColors = [UIColor.appDarkGray.withAlphaComponent(0.1), UIColor.appWhite, UIColor.appWhite, UIColor.appDarkGray.withAlphaComponent(0.1)]
            
            circularPickerDay.theme.selectedTextColor = UIColor.appWhite
            circularPickerDay.theme.textColor = UIColor.txtDarkGray
//                circularPickerDay.radius = 100
            circularPickerDay.pickerType = .day // Set the initial picker type
//                circularPickerDay.backgroundColor = UIColor.clear
//                circularPickerDay.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: circularPickerDay.frame.size.width/2.0)
//                circularPickerDay.frame.origin.x = 30
           
            circularPickerDay.roundSideCorners(radius: circularPickerDay.frame.size.width/2.5, cornerSide: [.topLeft, .topRight])
            
            self.dayMBV.addSubview(circularPickerDay)
        }
    }
    
   
//    @objc func pickerValueChanged(_ picker: CircularPicker) {
//        print("Selected Value: \(picker.selectedItem())")
//    }
    
    @objc func pickerValueChanged(_ sender: CircularPicker) {
        if let selectedValue = sender.selectedValue {
            print("Selected Value: \(selectedValue)")
        }
    }
    
//    @objc func monthChanged(_ picker: CircularMonthPicker) {
//          print("Selected Month: \(picker.centerLabel.text ?? "")")
//      }
    
    /*
    @objc func rangeChanged(_ sender: CircularRangePicker) {
        // Access the start and end angles (or convert to your desired range values)
//        let startAngle = sender.startAngle
//        let endAngle = sender.endAngle

//        print("Start Angle: \(startAngle), End Angle: \(endAngle)")
//
//        // Convert angles to your desired range (example: 0-100)
//        let startValue = Int( (startAngle / (2 * .pi)) * 100 ) // Assuming full circle
//        let endValue = Int( (endAngle / (2 * .pi)) * 100 )
//
//        print("Start Value: \(startValue), End Value: \(endValue)")

        // Update your UI or perform actions based on the selected range
    }
    */
    
    /*
     let rangePicker = CircularRangePicker() // If you created it programmatically, you already have it.
     // ... (Add to view and set up constraints as in step 2) ...

     rangePicker.addTarget(self, action: #selector(rangeChanged(_:)), for: .valueChanged)


     @objc func rangeChanged(_ sender: CircularRangePicker) {
         // Access the start and end angles (or convert to your desired range values)
         let startAngle = sender.startAngle
         let endAngle = sender.endAngle

         print("Start Angle: \(startAngle), End Angle: \(endAngle)")

         // Convert angles to your desired range (example: 0-100)
         let startValue = Int( (startAngle / (2 * .pi)) * 100 ) // Assuming full circle
         let endValue = Int( (endAngle / (2 * .pi)) * 100 )

         print("Start Value: \(startValue), End Value: \(endValue)")

         // Update your UI or perform actions based on the selected range
     }
     */
    
    
     }

//class DemmyAgeViewController: UIViewController,  UIPickerViewDelegate, UIPickerViewDataSource {
//    
//    let pickerView = UIPickerView()
//     let years = Array(1900...2025)
//     let months = Calendar.current.monthSymbols
//     let days = Array(1...31)
//     
//     let ageLabel = UILabel()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view.
//        view.backgroundColor = .red
//        
//        pickerView.delegate = self
//        pickerView.dataSource = self
//        pickerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(pickerView)
//        
//        // Age Label
//        ageLabel.text = "Your age is 0"
//        ageLabel.textColor = .white
//        ageLabel.textAlignment = .center
//        ageLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(ageLabel)
//        
//        NSLayoutConstraint.activate([
//            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            ageLabel.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
//            ageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//    }
//    
//
//    // MARK: UIPickerView DataSource
//       func numberOfComponents(in pickerView: UIPickerView) -> Int {
//           return 3 // Year, Month, Day
//       }
//       
//       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//           switch component {
//           case 0: return years.count
//           case 1: return months.count
//           case 2: return days.count
//           default: return 0
//           }
//       }
//       
//       // MARK: UIPickerView Delegate
//       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//           switch component {
//           case 0: return "\(years[row])"
//           case 1: return months[row]
//           case 2: return String(format: "%02d", days[row])
//           default: return nil
//           }
//       }
//       
//       func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//           let selectedYear = years[pickerView.selectedRow(inComponent: 0)]
//           let selectedMonth = pickerView.selectedRow(inComponent: 1) + 1
//           let selectedDay = days[pickerView.selectedRow(inComponent: 2)]
//           
//           calculateAge(year: selectedYear, month: selectedMonth, day: selectedDay)
//       }
//       
//       // MARK: Age Calculation
//       func calculateAge(year: Int, month: Int, day: Int) {
//           let calendar = Calendar.current
//           let birthDateComponents = DateComponents(year: year, month: month, day: day)
//           if let birthDate = calendar.date(from: birthDateComponents) {
//               let age = calendar.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
//               ageLabel.text = "Your age is \(age)"
//           }
//       }
//
//}

//class CurvedDatePickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
//
//    let years = Array(1900...2025)
//    let months = Calendar.current.monthSymbols
//    let days = Array(1...31)
//
//    let yearPicker = UIPickerView()
//    let monthPicker = UIPickerView()
//    let dayPicker = UIPickerView()
//    
//    let ageLabel = UILabel()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//
//        setupPickers()
//        setupAgeLabel()
//    }
//
//    func setupPickers() {
//        let stackView = UIStackView(arrangedSubviews: [yearPicker, monthPicker, dayPicker])
//        stackView.axis = .vertical
//        stackView.distribution = .fillEqually
//        stackView.spacing = 20
//
//        yearPicker.delegate = self
//        yearPicker.dataSource = self
//        monthPicker.delegate = self
//        monthPicker.dataSource = self
//        dayPicker.delegate = self
//        dayPicker.dataSource = self
//
//        [yearPicker, monthPicker, dayPicker].forEach { picker in
//            picker.backgroundColor = .clear
//            picker.setValue(UIColor.white, forKeyPath: "textColor")
//        }
//
//        view.addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
//            stackView.heightAnchor.constraint(equalToConstant: 300)
//        ])
//    }
//
//    func setupAgeLabel() {
//        ageLabel.textColor = .white
//        ageLabel.textAlignment = .center
//        ageLabel.font = UIFont.boldSystemFont(ofSize: 24)
//        view.addSubview(ageLabel)
//
//        ageLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            ageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
//            ageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//
//        updateAge()
//    }
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if pickerView == yearPicker {
//            return years.count
//        } else if pickerView == monthPicker {
//            return months.count
//        } else {
//            return days.count
//        }
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView == yearPicker {
//            return "\(years[row])"
//        } else if pickerView == monthPicker {
//            return months[row]
//        } else {
//            return "\(days[row])"
//        }
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        updateAge()
//    }
//
//    func updateAge() {
//        let selectedYear = years[yearPicker.selectedRow(inComponent: 0)]
//        let currentYear = Calendar.current.component(.year, from: Date())
//        let age = currentYear - selectedYear
//
//        ageLabel.text = "Your age is \(age)"
//    }
//}


/*
class DemmyAgeViewController: UIViewController {
    
//        let years = Array(1900...2025)
//        let months = Calendar.current.monthSymbols
//        let days = Array(1...31)
//        
//        let yearPicker = UIPickerView()
//        let monthPicker = UIPickerView()
//        let dayPicker = UIPickerView()
//        
//        let ageLabel = UILabel()
//        let indicator = UIView()
    
//    private lazy var circularProgressBarView = CircularProgressBarView()

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .red
//            
//            view.addSubview(circularProgressBarView)
//
//            circularProgressBarView.setProgress(0.75, animated: true)
            
            
//            let pickerView = CircularPicker(frame: CGRect(x: 10, y: 100, width: 300, height: 300))
//            pickerView.items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
//            
//            self.view.addSubview(pickerView)
//            
//            pickerView.scrollToRow(3, animated: true)
            
//            let customLabel = UILabelX()
//            customLabel.frame = CGRect(x: 50, y: 100, width: 200, height: 200)
//            customLabel.text = "Hello World"
//            customLabel.font = UIFont.systemFont(ofSize: 18)
//            customLabel.angle = 2.0  // Adjust angle as needed
//            customLabel.clockwise = true // Set clockwise or counterclockwise
//            view.addSubview(customLabel)
            
//            // Create an instance of CurvedView
//            let curvedView = CurvedView(frame: CGRect(x: 50, y: 100, width: 300, height: 200))
//            
//            // Customize the CurvedView (optional)
//            curvedView.backgroundColor = .yellow
//            
//            // Add CurvedView to the main view
//            view.addSubview(curvedView)
            
            
        
            let circularPicker = CircularPicker()
            circularPicker.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(circularPicker)
            
            circularPicker.items =  ["2","3","4","5","6","7","8","9","10"]
            // Set constraints (using Auto Layout)
            NSLayoutConstraint.activate([
                circularPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                circularPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                circularPicker.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150),
                circularPicker.widthAnchor.constraint(equalToConstant: 350), // Adjust size as needed
                circularPicker.heightAnchor.constraint(equalToConstant: 40) // Adjust size as needed
            ])
            
            circularPicker.scrollToRow(5, animated: true)
            
            circularPicker.backgroundColor = .black
            
        
            
//            let circularPicker = CircularPicker()
//                    circularPicker.translatesAutoresizingMaskIntoConstraints = false
//                    view.addSubview(circularPicker)
//
//                    // Set constraints (using Auto Layout)
//                    NSLayoutConstraint.activate([
//                        circularPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                        circularPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//                        circularPicker.widthAnchor.constraint(equalToConstant: 30)
//                        ])
//            circularPicker.backgroundColor = .black
            
            //            setupPickers()
            //            setupIndicator(
            //            setupAgeLabel()
        }

    
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()

//         circularProgressBarView.frame = CGRect(
//             x: view.bounds.midX - 125,
//             y: view.bounds.midY - 125,
//             width: 250,
//             height: 250
//         )
     }
    
//        func setupPickers() {
//            DispatchQueue.main.async {
//                
////                let pickers = [self.yearPicker, self.monthPicker, self.dayPicker]
//                let pickers = [self.yearPicker, self.monthPicker, self.dayPicker]
////                self.yearPicker.frame = 
//                let stackView = UIStackView(arrangedSubviews: pickers)
////                stackView.frame = CGRect(x: 10, y: 140, width: self.view.frame.size.width-20, height: 150)
//                stackView.axis = .vertical
//                stackView.spacing = 10
//                stackView.backgroundColor = UIColor.yellow
//                stackView.distribution = .fillEqually
//                stackView.translatesAutoresizingMaskIntoConstraints = false
//                self.view.addSubview(stackView)
//                
//                NSLayoutConstraint.activate([
//                    stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
////                    stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
//                    stackView.heightAnchor.constraint(equalToConstant: 250),
//                    stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 140)
//                ])
//                
//                for picker in pickers {
//                    picker.delegate = self
//                    picker.dataSource = self
//                    picker.backgroundColor = .clear
//                    picker.tintColor = .white
//                    picker.transform = CGAffineTransform(rotationAngle: -.pi / 2) // Rotate for curved effect
//                }
//            }
//        }

//        func setupIndicator() {
//            indicator.backgroundColor = .orange
//            indicator.layer.cornerRadius = 5
//            indicator.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(indicator)
//
//            NSLayoutConstraint.activate([
//                indicator.widthAnchor.constraint(equalToConstant: 20),
//                indicator.heightAnchor.constraint(equalToConstant: 10),
//                indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                indicator.bottomAnchor.constraint(equalTo: dayPicker.topAnchor, constant: -5)
//            ])
//            
//            indicator.transform = CGAffineTransform(rotationAngle: .pi) // Triangle shape
//            indicator.layer.mask = triangleMask()
//        }

//        func triangleMask() -> CAShapeLayer {
//            let path = UIBezierPath()
//            path.move(to: CGPoint(x: 10, y: 0))
//            path.addLine(to: CGPoint(x: 0, y: 10))
//            path.addLine(to: CGPoint(x: 20, y: 10))
//            path.close()
//
//            let mask = CAShapeLayer()
//            mask.path = path.cgPath
//            return mask
//        }

//        func setupAgeLabel() {
//            ageLabel.textColor = .white
//            ageLabel.font = UIFont.boldSystemFont(ofSize: 24)
//            ageLabel.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(ageLabel)
//
//            NSLayoutConstraint.activate([
//                ageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                ageLabel.topAnchor.constraint(equalTo: dayPicker.bottomAnchor, constant: 20)
//            ])
//            
//            updateAge()
//        }

//        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

//        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//            if pickerView == yearPicker { return years.count }
//            if pickerView == monthPicker { return months.count }
//            return days.count
//        }

//        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//            if pickerView == yearPicker { return "\(years[row])" }
//            if pickerView == monthPicker { return months[row] }
//            return String(format: "%02d", days[row])
//        }

//        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//            updateAge()
//        }

//        func updateAge() {
//            let selectedYear = years[yearPicker.selectedRow(inComponent: 0)]
//            let currentYear = Calendar.current.component(.year, from: Date())
//            let age = currentYear - selectedYear
//
//            ageLabel.text = "Your age is \(age)"
//        }
    }
*/

//class DemmyAgeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
//    
//    let years = Array(1950...2025)
//    let months = Calendar.current.monthSymbols
//    let days = Array(1...31)
//
//    let yearPicker = UIPickerView()
//    let monthPicker = UIPickerView()
//    let dayPicker = UIPickerView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//
//        setupPicker(yearPicker)
//        setupPicker(monthPicker)
//        setupPicker(dayPicker)
//
//        let stackView = UIStackView(arrangedSubviews: [yearPicker, monthPicker, dayPicker])
//        
//        DispatchQueue.main.async {
////            let stackView = UIStackView(arrangedSubviews: [yearPicker, monthPicker, dayPicker])
//            stackView.axis = .vertical
//            stackView.distribution = .fillEqually
//            stackView.spacing = 20
//            self.view.addSubview(stackView)
//            
//            stackView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//                stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
//                stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
//                stackView.heightAnchor.constraint(equalToConstant: 300)
//            ])
//        }
//    }
//
//    func setupPicker(_ picker: UIPickerView) {
//        picker.delegate = self
//        picker.dataSource = self
//        picker.backgroundColor = .clear
//        picker.setValue(UIColor.white, forKey: "textColor")
//
//        // Apply 3D transform for curved effect
//        picker.layer.transform = CATransform3DMakeRotation(-.pi / 10, 1, 0, 0)
//    }
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if pickerView == yearPicker { return years.count }
//        if pickerView == monthPicker { return months.count }
//        return days.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView == yearPicker { return "\(years[row])" }
//        if pickerView == monthPicker { return months[row] }
//        return String(format: "%02d", days[row])
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let selectedYear = years[yearPicker.selectedRow(inComponent: 0)]
//        let selectedMonth = months[monthPicker.selectedRow(inComponent: 0)]
//        let selectedDay = days[dayPicker.selectedRow(inComponent: 0)]
//
//        let ageLabel = UILabel()
//        ageLabel.textColor = .white
//        ageLabel.textAlignment = .center
//        ageLabel.text = "Your age is \(calculateAge(birthYear: selectedYear))"
//
//        view.addSubview(ageLabel)
//        ageLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            ageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            ageLabel.topAnchor.constraint(equalTo: dayPicker.bottomAnchor, constant: 20)
//        ])
//    }
//
//    func calculateAge(birthYear: Int) -> Int {
//        let currentYear = Calendar.current.component(.year, from: Date())
//        return currentYear - birthYear
//    }
//}

/*
 {
     
     // Public property to access the calculated width
     var labelWidth: CGFloat {
         return calculatedWidth
     }
     
     var labelFont: UIFont = UIFont.systemFont(ofSize: 25.0, weight: .semibold) {
         didSet {
             return
         }
     }
     
     var labelColor: UIColor = .white {
         didSet {
             return
         }
     }
     
     var items: [String] = [] {
         didSet {
             setupView()
         }
     }
     
     private var selectedRow: Int = 0
     private var rowHeight: CGFloat = 40
     private var itemLabels: [UILabel] = []
     private var contentOffset: CGFloat = 0
     private var isAnimating: Bool = false
     private var calculatedWidth: CGFloat = 20
     private var radius: CGFloat = 120  // Radius for the circular layout
     
     override func layoutSubviews() {
         super.layoutSubviews()
         setupView()
     }
     
     // Set up the view
     private func setupView() {
         backgroundColor = .clear
         clipsToBounds = true
         
         // Clear existing labels
         itemLabels.forEach { $0.removeFromSuperview() }
         itemLabels = []
         
         // Create labels for items
         let angleIncrement = 2 * CGFloat.pi / CGFloat(items.count)  // Angle increment per item
         
         for (index, item) in items.enumerated() {
             let label = UILabel()
             label.text = item
             label.font = labelFont
             label.textAlignment = .center
             label.textColor = labelColor
             label.sizeToFit()  // Ensure the label's size fits the text
             
             // Calculate the position of each label on the circle
             let angle = angleIncrement * CGFloat(index)
             let xPosition = radius * cos(angle) + bounds.width / 2
             let yPosition = radius * sin(angle) + bounds.height / 2
             
             // Position the label at calculated coordinates
             label.center = CGPoint(x: xPosition, y: yPosition)
             addSubview(label)
             itemLabels.append(label)
         }
         
         scrollToRow(selectedRow, animated: false)
     }
     
     // Calculate the maximum label width
     private func calculateMaxLabelWidth(labelStr: String) -> CGFloat {
         let font = labelFont
         let maxWidth = ((labelStr as NSString).boundingRect(
             with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40),
             options: .usesLineFragmentOrigin,
             attributes: [.font: font],
             context: nil
         ).width)
         
         return maxWidth + 10  // Add padding
     }
     
     // Scroll to a specific row
     func scrollToRow(_ row: Int, animated: Bool = true) {
         guard !isAnimating else { return }
         isAnimating = true
         
         calculatedWidth = calculateMaxLabelWidth(labelStr: items[row])
         frame.size.width = calculatedWidth
         itemLabels[row].frame.size.width = calculatedWidth
         
         // Prevent scrolling out of bounds
         selectedRow = max(0, min(row, items.count - 1))
         
         // Calculate new content offset
         contentOffset = CGFloat(selectedRow) * rowHeight - (bounds.height / 2) + (rowHeight / 2)
         
         // Animate label positions
         if animated {
             UIView.animate(withDuration: 0.3, animations: {
                 self.updateViewForSelectedRow()
             }) { _ in
                 self.isAnimating = false
             }
         } else {
             updateViewForSelectedRow()
             isAnimating = false
         }
     }
     
     // Apply the circular effect and adjust text visibility
     private func updateViewForSelectedRow() {
         let angleIncrement = 2 * CGFloat.pi / CGFloat(items.count)  // Angle increment per item
         
         for (index, label) in itemLabels.enumerated() {
             // Recalculate the angle and position based on the selected row
             let angle = angleIncrement * CGFloat(index)
             let xPosition = radius * cos(angle) + bounds.width / 2
             let yPosition = radius * sin(angle) + bounds.height / 2
             label.center = CGPoint(x: xPosition, y: yPosition)
             
             // Apply perspective transform for circular effect
             let distanceFromCenter = abs(CGFloat(selectedRow) - CGFloat(index))
             let scaleFactor = max(1 - (distanceFromCenter * 0.1), 0.7) // Adjust this for desired effect
             let angleAdjustment = (distanceFromCenter * 0.05) // Smaller value for subtler curve
             let transform = CGAffineTransform(rotationAngle: angleAdjustment).scaledBy(x: scaleFactor, y: scaleFactor)
             label.transform = transform
             
             // Change text color for the selected row
             if index == selectedRow {
                 label.textColor = labelColor
             } else {
                 label.textColor = labelColor
             }
             
             // Hide labels outside visible area
             label.isHidden = !(label.frame.origin.x >= 0 && label.frame.origin.x <= bounds.width &&
                                label.frame.origin.y >= 0 && label.frame.origin.y <= bounds.height)
         }
     }
 }
 */



final class CircularProgressBarView: UIView {

    // MARK: - Constants

    private struct Appearance {
        static let lineWidth: CGFloat = 10.0
        static let backgroundColor = UIColor.gray
        static let progressColor = UIColor.systemBlue
    }

    // MARK: - Layers

    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = Appearance.lineWidth
        layer.lineCap = .round
        layer.strokeStart = 0
        layer.strokeEnd = 0
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Appearance.progressColor.cgColor

        return layer
    }()

    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = Appearance.lineWidth
        layer.lineCap = .round
        layer.strokeStart = 0
        layer.strokeEnd = 1
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Appearance.backgroundColor.cgColor

        return layer
    }()

    // MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        loadLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func loadLayout() {
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: (bounds.width - Appearance.lineWidth) / 2,
            startAngle: -CGFloat.pi / 2,
            endAngle: CGFloat.pi * 3 / 2,
            clockwise: true
        ).cgPath

        backgroundLayer.path = circlePath
        progressLayer.path = circlePath
    }

    // MARK: - Public

    func setProgress(_ progress: CGFloat, animated: Bool) {
        // Ensure progress is between 0 and 1
        let clampedProgress = max(min(progress, 1), 0)

        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedProgress
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            progressLayer.removeAnimation(forKey: "progress")
            progressLayer.add(animation, forKey: "progress")
        }

        progressLayer.strokeEnd = clampedProgress
    }
}


//class CircularPicker: UIView {
//    
//    // Public property to access the calculated width
//    var labelWidth: CGFloat {
//        return calculatedWidth
//    }
//    
//    var labelFont: UIFont = UIFont.systemFont(ofSize: 25.0, weight: .semibold) {
//        didSet {
//            return
//        }
//    }
//    
//    var labelColor: UIColor = .white {
//        didSet {
//            return
//        }
//    }
//    
//    var items: [String] = [] {
//        didSet {
//            setupView()
//        }
//    }
//    
//    private var selectedRow: Int = 0
//    private var rowHeight: CGFloat = 40
//    private var itemLabels: [UILabel] = []
//    private var contentOffset: CGFloat = 0
//    private var isAnimating: Bool = false
//    private var calculatedWidth: CGFloat = 20
//    private var radius: CGFloat = 120  // Radius for the circular layout
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setupView()
//    }
//    
//    // Set up the view
//    private func setupView() {
//        backgroundColor = .clear
//        clipsToBounds = true
//        
//        // Clear existing labels
//        itemLabels.forEach { $0.removeFromSuperview() }
//        itemLabels = []
//        
//        // Create labels for items
//        let angleIncrement = 2 * CGFloat.pi / CGFloat(items.count)  // Angle increment per item
//        
//        for (index, item) in items.enumerated() {
//            let label = UILabel()
//            label.text = item
//            label.font = labelFont
//            label.textAlignment = .center
//            label.textColor = labelColor
//            label.sizeToFit()  // Ensure the label's size fits the text
//            
//            // Calculate the position of each label on the circle
//            let angle = angleIncrement * CGFloat(index)
//            let xPosition = radius * cos(angle) + bounds.width / 2
//            let yPosition = radius * sin(angle) + bounds.height / 2
//            
//            // Position the label at calculated coordinates
//            label.center = CGPoint(x: xPosition, y: yPosition)
//            addSubview(label)
//            itemLabels.append(label)
//        }
//        
//        scrollToRow(selectedRow, animated: false)
//    }
//    
//    // Calculate the maximum label width
//    private func calculateMaxLabelWidth(labelStr: String) -> CGFloat {
//        let font = labelFont
//        let maxWidth = ((labelStr as NSString).boundingRect(
//            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40),
//            options: .usesLineFragmentOrigin,
//            attributes: [.font: font],
//            context: nil
//        ).width)
//        
//        return maxWidth + 10  // Add padding
//    }
//    
//    // Scroll to a specific row
//    func scrollToRow(_ row: Int, animated: Bool = true) {
//        guard !isAnimating else { return }
//        isAnimating = true
//        
//        calculatedWidth = calculateMaxLabelWidth(labelStr: items[row])
//        frame.size.width = calculatedWidth
//        itemLabels[row].frame.size.width = calculatedWidth
//        
//        // Prevent scrolling out of bounds
//        selectedRow = max(0, min(row, items.count - 1))
//        
//        // Calculate new content offset
//        contentOffset = CGFloat(selectedRow) * rowHeight - (bounds.height / 2) + (rowHeight / 2)
//        
//        // Animate label positions
//        if animated {
//            UIView.animate(withDuration: 0.3, animations: {
//                self.updateViewForSelectedRow()
//            }) { _ in
//                self.isAnimating = false
//            }
//        } else {
//            updateViewForSelectedRow()
//            isAnimating = false
//        }
//    }
//    
//    // Apply the curve effect and adjust text visibility
//    private func updateViewForSelectedRow() {
//        let angleIncrement = 2 * CGFloat.pi / CGFloat(items.count)  // Angle increment per item
//        
//        for (index, label) in itemLabels.enumerated() {
//            // Recalculate the angle and position based on the selected row
//            let angle = angleIncrement * CGFloat(index)
//            let xPosition = radius * cos(angle) + bounds.width / 2
//            let yPosition = radius * sin(angle) + bounds.height / 2
//            label.center = CGPoint(x: xPosition, y: yPosition)
//            
//            // Apply perspective transform for circular effect
//            let distanceFromCenter = abs(CGFloat(selectedRow) - CGFloat(index))
//            let scaleFactor = max(1 - (distanceFromCenter * 0.1), 0.7) // Adjust this for desired effect
//            let angleAdjustment = (distanceFromCenter * 0.05) // Smaller value for subtler curve
//            let transform = CGAffineTransform(rotationAngle: angleAdjustment).scaledBy(x: scaleFactor, y: scaleFactor)
//            label.transform = transform
//            
//            // Change text color for the selected row
//            if index == selectedRow {
//                label.textColor = labelColor
//            } else {
//                label.textColor = labelColor
//            }
//            
//            // Hide labels outside visible area
//            label.isHidden = !(label.frame.origin.x >= 0 && label.frame.origin.x <= bounds.width &&
//                               label.frame.origin.y >= 0 && label.frame.origin.y <= bounds.height)
//        }
//    }
//}



//class CircularPicker: UIView {
//    
//    // Public property to access the calculated width
//    var labelWidth: CGFloat {
//        return calculatedWidth
//    }
//    
//    var labelFont: UIFont = UIFont.systemFont(ofSize: 25.0, weight: .semibold) {
//        didSet {
//            return
//        }
//    }
//    
//    var labelColor: UIColor = .white {
//        didSet {
//            return
//        }
//    }
//    
//    var items: [String] = [] {
//        didSet {
//            setupView()
//        }
//    }
//    
//    private var selectedRow: Int = 0
//    private var rowHeight: CGFloat = 40
//    private var itemLabels: [UILabel] = []
//    private var contentOffset: CGFloat = 0
//    private var isAnimating: Bool = false
//    private var calculatedWidth: CGFloat = 20
//    private var radius: CGFloat = 120  // Radius for the circular layout
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setupView()
//    }
//    
//    // Set up the view
//    private func setupView() {
//        backgroundColor = .clear
//        clipsToBounds = true
//        
//        // Clear existing labels
//        itemLabels.forEach { $0.removeFromSuperview() }
//        itemLabels = []
//        
//        // Create labels for items
//        let angleIncrement = 2 * CGFloat.pi / CGFloat(items.count)  // Angle increment per item
//        
//        for (index, item) in items.enumerated() {
//            let label = UILabel()
//            label.text = item
//            label.font = labelFont
//            label.textAlignment = .center
//            label.textColor = labelColor
//            label.sizeToFit()  // Ensure the label's size fits the text
//            
//            // Calculate the position of each label on the circle
//            let angle = angleIncrement * CGFloat(index)
//            let xPosition = radius * cos(angle) + bounds.width / 2
//            let yPosition = radius * sin(angle) + bounds.height / 2
//            
//            // Position the label at calculated coordinates
//            label.center = CGPoint(x: xPosition, y: yPosition)
//            addSubview(label)
//            itemLabels.append(label)
//        }
//        
//        scrollToRow(selectedRow, animated: false)
//    }
//    
//    // Calculate the maximum label width
//    private func calculateMaxLabelWidth(labelStr: String) -> CGFloat {
//        let font = labelFont
//        let maxWidth = ((labelStr as NSString).boundingRect(
//            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40),
//            options: .usesLineFragmentOrigin,
//            attributes: [.font: font],
//            context: nil
//        ).width)
//        
//        return maxWidth + 10  // Add padding
//    }
//    
//    // Scroll to a specific row
//    func scrollToRow(_ row: Int, animated: Bool = true) {
//        guard !isAnimating else { return }
//        isAnimating = true
//        
//        calculatedWidth = calculateMaxLabelWidth(labelStr: items[row])
//        frame.size.width = calculatedWidth
//        itemLabels[row].frame.size.width = calculatedWidth
//        
//        // Prevent scrolling out of bounds
//        selectedRow = max(0, min(row, items.count - 1))
//        
//        // Calculate new content offset
//        contentOffset = CGFloat(selectedRow) * rowHeight - (bounds.height / 2) + (rowHeight / 2)
//        
//        // Animate label positions
//        if animated {
//            UIView.animate(withDuration: 0.3, animations: {
//                self.updateViewForSelectedRow()
//            }) { _ in
//                self.isAnimating = false
//            }
//        } else {
//            updateViewForSelectedRow()
//            isAnimating = false
//        }
//    }
//    
//    // Apply the curve effect and adjust text visibility
//    private func updateViewForSelectedRow() {
//        let angleIncrement = 2 * CGFloat.pi / CGFloat(items.count)  // Angle increment per item
//        
//        for (index, label) in itemLabels.enumerated() {
//            // Recalculate the angle and position based on the selected row
//            let angle = angleIncrement * CGFloat(index)
//            let xPosition = radius * cos(angle) + bounds.width / 2
//            let yPosition = radius * sin(angle) + bounds.height / 2
//            label.center = CGPoint(x: xPosition, y: yPosition)
//            
//            // Apply perspective transform for circular effect
//            let distanceFromCenter = abs(CGFloat(selectedRow) - CGFloat(index))
//            let scaleFactor = max(1 - (distanceFromCenter * 0.1), 0.7) // Adjust this for desired effect
//            let angleAdjustment = (distanceFromCenter * 0.05) // Smaller value for subtler curve
//            let transform = CGAffineTransform(rotationAngle: angleAdjustment).scaledBy(x: scaleFactor, y: scaleFactor)
//            label.transform = transform
//            
//            // Change text color for the selected row
//            if index == selectedRow {
//                label.textColor = labelColor
//            } else {
//                label.textColor = labelColor
//            }
//            
//            // Hide labels outside visible area
//            label.isHidden = !(label.frame.origin.x >= 0 && label.frame.origin.x <= bounds.width &&
//                               label.frame.origin.y >= 0 && label.frame.origin.y <= bounds.height)
//        }
//    }
//}


//class CircularPicker: UIView {
//    
//    // Public property to access the calculated width
//    var labelWidth: CGFloat {
//        return calculatedWidth
//    }
//    
//    var labelFont: UIFont = UIFont.systemFont(ofSize: 25.0, weight: .semibold) {
//        didSet {
//            return
//        }
//    }
//    
//    var labelColor: UIColor = .white {
//        didSet {
//            return
//        }
//    }
//    
//    var items: [String] = [] {
//        didSet {
//            setupView()
//        }
//    }
//    
//    private var selectedRow: Int = 0
//    private var rowHeight: CGFloat = 40
//    private var itemLabels: [UILabel] = []
//    private var contentOffset: CGFloat = 0
//    private var isAnimating: Bool = false
//    private var calculatedWidth: CGFloat = 20
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setupView()
//    }
//    
//    // Set up the view
//    private func setupView() {
//        backgroundColor = .clear
//        clipsToBounds = true
//        
//        // Clear existing labels
//        itemLabels.forEach { $0.removeFromSuperview() }
//        itemLabels = []
//        
//        // Create labels for items
//        for (index, item) in items.enumerated() {
//            let label = UILabel()
//            label.text = item
//            label.font = labelFont
//            label.textAlignment = .center
//            label.textColor = labelColor
//            label.sizeToFit()  // Ensure the label's size fits the text
//            
//            // Set a default width
//            var labelFrame = CGRect(x: 0, y: CGFloat(index) * rowHeight, width: label.frame.width + 10, height: rowHeight)
//            label.frame = labelFrame
//            
//            addSubview(label)
//            itemLabels.append(label)
//        }
//        
//        scrollToRow(selectedRow, animated: false)
//    }
//    
//    // Calculate the maximum label width
//    private func calculateMaxLabelWidth(labelStr: String) -> CGFloat {
//        let font = labelFont
//        let maxWidth = ((labelStr as NSString).boundingRect(
//            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40),
//            options: .usesLineFragmentOrigin,
//            attributes: [.font: font],
//            context: nil
//        ).width)
//        
//        return maxWidth + 10  // Add padding
//    }
//    
//    // Scroll to a specific row
//    func scrollToRow(_ row: Int, animated: Bool = true) {
//        guard !isAnimating else { return }
//        isAnimating = true
//        
//        guard row != 0 else {
//            return
//        }
//        calculatedWidth = calculateMaxLabelWidth(labelStr: items[row])
//        frame.size.width = calculatedWidth
//        itemLabels[row].frame.size.width = calculatedWidth
//        
//        // Prevent scrolling out of bounds
//        selectedRow = max(0, min(row, items.count - 1))
//        
//        // Calculate new content offset
//        contentOffset = CGFloat(selectedRow) * rowHeight - (bounds.height / 2) + (rowHeight / 2)
//        
//        // Animate label positions
//        if animated {
//            UIView.animate(withDuration: 0.3, animations: {
//                self.updateViewForSelectedRow()
//            }) { _ in
//                self.isAnimating = false
//            }
//        } else {
//            updateViewForSelectedRow()
//            isAnimating = false
//        }
//    }
//    
//    // Apply the curve effect and adjust text visibility
//    private func updateViewForSelectedRow() {
//        for (index, label) in itemLabels.enumerated() {
//            let newYPosition = CGFloat(index) * rowHeight - contentOffset
//            label.frame.origin.y = newYPosition
//            
//            // Change text color for the selected row
//            if index == selectedRow {
//                label.textColor = labelColor
//            } else {
//                label.textColor = labelColor
//            }
//            
//            // Apply perspective transform for curve effect
//            let distanceFromCenter = abs(CGFloat(selectedRow) - CGFloat(index))
//            let scaleFactor = max(1 - (distanceFromCenter * 0.1), 0.7) // Adjust this for desired effect
//            let angle = (distanceFromCenter * 0.05) // Smaller value for subtler curve
//            let transform = CGAffineTransform(rotationAngle: angle).scaledBy(x: scaleFactor, y: scaleFactor)
//            label.transform = transform
//            
//            // Hide labels outside visible area
//            label.isHidden = !(newYPosition >= 0 && newYPosition <= bounds.height)
//        }
//    }
//}



//class UILabelX: UILabel {
//
//    var angle: CGFloat = 1.6 // No longer IBInspectable
//    var clockwise: Bool = true // No longer IBInspectable
//
//    override func draw(_ rect: CGRect) {
//        centreArcPerpendicular()
//    }
//
//    /**
//     This draws the self.text around an arc of radius r,
//     with the text centred at polar angle theta
//     */
//    func centreArcPerpendicular() {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        let str = self.text ?? ""
//        let size = self.bounds.size
//        context.translateBy(x: size.width / 2, y: size.height / 2)
//
//        let radius = getRadiusForLabel()
//        let l = str.count
//        let attributes: [NSAttributedString.Key : Any] = [.font : self.font]
//
//        let characters: [String] = str.map { String($0) }
//        var arcs: [CGFloat] = []
//        var totalArc: CGFloat = 0
//
//        // Calculate the arc subtended by each letter and their total
//        for i in 0 ..< l {
//            arcs += [chordToArc(characters[i].size(withAttributes: attributes).width, radius: radius)]
//            totalArc += arcs[i]
//        }
//
//        // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
//        // or anti-clockwise (right way up at 6 o'clock)?
//        let direction: CGFloat = clockwise ? -1 : 1
//        let slantCorrection = clockwise ? -CGFloat(Double.pi/2) : CGFloat(Double.pi/2)
//
//        var thetaI = angle - direction * totalArc / 2
//
//        for i in 0 ..< l {
//            thetaI += direction * arcs[i] / 2
//            centre(text: characters[i], context: context, radius: radius, angle: thetaI, slantAngle: thetaI + slantCorrection)
//            thetaI += direction * arcs[i] / 2
//        }
//    }
//
//    func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
//        return 2 * asin(chord / (2 * radius))
//    }
//
//    func centre(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, slantAngle: CGFloat) {
//        let attributes = [NSAttributedString.Key.font: self.font!] as [NSAttributedString.Key : Any]
//        context.saveGState()
//        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
//        context.rotate(by: -slantAngle)
//        let offset = str.size(withAttributes: attributes)
//        context.translateBy(x: -offset.width / 2, y: -offset.height / 2)
//        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
//        context.restoreGState()
//    }
//
//    func getRadiusForLabel() -> CGFloat {
//        let smallestWidthOrHeight = min(self.bounds.size.height, self.bounds.size.width)
//        let heightOfFont = self.text?.size(withAttributes: [NSAttributedString.Key.font: self.font]).height ?? 0
//        return (smallestWidthOrHeight / 2) - heightOfFont + 5
//    }
//}



//class CurvedView: UIView {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupView()
//    }
//
//    private func setupView() {
//        // 1. Apply a Transform (Example: circular arc)
//        let radius: CGFloat = 150 // Adjust radius for curve
//        let angle: CGFloat = .pi / 4 // Adjust angle for arc length
//
//        let transform = CGAffineTransform(translationX: -radius, y: 0)
//            .rotated(by: -angle / 2)
//            .concatenating(CGAffineTransform(scaleX: 1, y: radius / bounds.height)) // Use bounds.height
//
//        self.transform = transform
//
//        // 2. Create a Mask (Crucial for clipping)
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = UIBezierPath(arcCenter: CGPoint(x: 0, y: bounds.midY), radius: radius, startAngle: -angle / 2, endAngle: angle / 2, clockwise: true).cgPath
//        maskLayer.fillColor = UIColor.black.cgColor
//        layer.mask = maskLayer
//
//        // 3. Position the View (Important!)
//        layer.anchorPoint = CGPoint(x: 0, y: 0.5) // Anchor to the left edge
//        frame.origin.x = radius // Shift to the right
//
//        clipsToBounds = true // Clip anything that extends beyond the view
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        // Ensure the mask and transform are updated if the view's bounds change
//        setupView()
//    }
//}


/*
class CircularPicker: UIView {
    var years = Array(1900...2100)
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var days = Array(1...31)

    var selectedYear = 2000
    var selectedMonth = "Jan"
    var selectedDay = 1

    private let labelFont = UIFont.systemFont(ofSize: 14)
    private let labelColor = UIColor.white
    private let selectionColor = UIColor.gray
    private let indicatorColor = UIColor.orange

    private var touchStartAngle: CGFloat?
    private var selectedRing: Int?

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.5
        
        drawRing(data: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
//        drawRing(data: months, selectedValue: selectedMonth, center: center, radius: radius * 0.75, context: context)
//        drawRing(data: days, selectedValue: selectedDay, center: center, radius: radius * 0.5, context: context)

        drawIndicator(at: center, context: context)
        displayAge(in: rect)
    }

    private func drawRing<T: Equatable>(data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
        guard let selectedIndex = data.firstIndex(of: selectedValue) else { return }
        let angleStep = 2 * .pi / CGFloat(data.count)

        for (index, value) in data.enumerated() {
            let angle = angleStep * CGFloat(index) - .pi / 2
            let labelCenter = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            drawLabel(text: "\(value)", at: labelCenter)

            if index == selectedIndex {
                context.setStrokeColor(selectionColor.cgColor)
                context.setLineWidth(3)
                context.addArc(center: center, radius: radius, startAngle: angle - 0.1, endAngle: angle + 0.1, clockwise: false)
                context.strokePath()
            }
        }
    }

    private func drawLabel(text: String, at point: CGPoint) {
        let attributes: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: labelColor]
        let textSize = text.size(withAttributes: attributes)
        let labelRect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
        text.draw(in: labelRect, withAttributes: attributes)
    }

    private func drawIndicator(at point: CGPoint, context: CGContext) {
        context.setFillColor(indicatorColor.cgColor)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: point.x, y: point.y - 10))
        path.addLine(to: CGPoint(x: point.x - 5, y: point.y - 20))
        path.addLine(to: CGPoint(x: point.x + 5, y: point.y - 20))
        path.close()
        context.addPath(path.cgPath)
        context.fillPath()
    }

    private func displayAge(in rect: CGRect) {
        let age = calculateAge()
        let ageLabel = UILabel(frame: CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 20))
        ageLabel.text = "Your age is \(age)"
        ageLabel.textAlignment = .center
        ageLabel.textColor = labelColor
        ageLabel.font = labelFont
        addSubview(ageLabel)
    }

    private func calculateAge() -> Int {
        let calendar = Calendar.current
        let monthIndex = months.firstIndex(of: selectedMonth) ?? 0
        let birthDate = calendar.date(from: DateComponents(year: selectedYear, month: monthIndex + 1, day: selectedDay)) ?? Date()
        return calendar.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) * 0.4

        let distance = hypot(location.x - center.x, location.y - center.y)
        selectedRing = distance <= radius * 0.6 ? 0 : (distance <= radius * 0.8 ? 1 : 2)
        touchStartAngle = atan2(location.y - center.y, location.x - center.x)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let ring = selectedRing, let startAngle = touchStartAngle else { return }

        let location = touch.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let currentAngle = atan2(location.y - center.y, location.x - center.x)
        let angleDiff = currentAngle - startAngle

        switch ring {
        case 0: updateSelection(&selectedYear, from: years, by: angleDiff)
        case 1: updateSelection(&selectedMonth, from: months, by: angleDiff)
        case 2: updateSelection(&selectedDay, from: days, by: angleDiff)
        default: break
        }

        touchStartAngle = currentAngle
        setNeedsDisplay()
    }
    
    private func updateSelection<T: Equatable>(_ selected: inout T, from data: [T], by angle: CGFloat) {
        guard let currentIndex = data.firstIndex(of: selected) else { return }
        let angleStep = 2 * .pi / CGFloat(data.count)
        let steps = angle / angleStep
        let newIndex = (currentIndex + Int(steps)).modulo(data.count)
        selected = data[newIndex]
    }
}

extension Int {
    func modulo(_ n: Int) -> Int {
        return (self % n + n) % n
    }
}
*/



/*
class CircularPicker: UIView {
    var years = Array(1900...2100)
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var days = Array(1...31)

    var selectedYear = 2000
    var selectedMonth = "Jan"
    var selectedDay = 1

    private let labelFont = UIFont.systemFont(ofSize: 14)
    private let labelColor = UIColor.white
    private let selectionColor = UIColor.gray
    private let indicatorColor = UIColor.orange

    private var touchStartAngle: CGFloat?
    private var selectedRing: Int?

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.5
        
        drawRing(data: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
        drawRing(data: months, selectedValue: selectedMonth, center: center, radius: radius * 0.75, context: context)
//        drawRing(data: days, selectedValue: selectedDay, center: center, radius: radius * 0.5, context: context)

        drawIndicator(at: center, context: context)
        displayAge(in: rect)
    }

    private func drawRing<T: Equatable>(data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
        guard let selectedIndex = data.firstIndex(of: selectedValue) else { return }
        let angleStep = 2 * .pi / CGFloat(data.count)

        for (index, value) in data.enumerated() {
            let angle = angleStep * CGFloat(index) - .pi / 2
            let labelCenter = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            drawLabel(text: "\(value)", at: labelCenter)

            if index == selectedIndex {
                context.setStrokeColor(selectionColor.cgColor)
                context.setLineWidth(3)
                context.addArc(center: center, radius: radius, startAngle: angle - 0.1, endAngle: angle + 0.1, clockwise: false)
                context.strokePath()
            }
        }
    }

    private func drawLabel(text: String, at point: CGPoint) {
        let attributes: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: labelColor]
        let textSize = text.size(withAttributes: attributes)
        let labelRect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
        text.draw(in: labelRect, withAttributes: attributes)
    }

    private func drawIndicator(at point: CGPoint, context: CGContext) {
        context.setFillColor(indicatorColor.cgColor)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: point.x, y: point.y - 10))
        path.addLine(to: CGPoint(x: point.x - 5, y: point.y - 20))
        path.addLine(to: CGPoint(x: point.x + 5, y: point.y - 20))
        path.close()
        context.addPath(path.cgPath)
        context.fillPath()
    }

    private func displayAge(in rect: CGRect) {
        let age = calculateAge()
        let ageLabel = UILabel(frame: CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 20))
        ageLabel.text = "Your age is \(age)"
        ageLabel.textAlignment = .center
        ageLabel.textColor = labelColor
        ageLabel.font = labelFont
        addSubview(ageLabel)
    }

    private func calculateAge() -> Int {
        let calendar = Calendar.current
        let monthIndex = months.firstIndex(of: selectedMonth) ?? 0
        let birthDate = calendar.date(from: DateComponents(year: selectedYear, month: monthIndex + 1, day: selectedDay)) ?? Date()
        return calendar.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) * 0.4

        let distance = hypot(location.x - center.x, location.y - center.y)
        selectedRing = distance <= radius * 0.6 ? 0 : (distance <= radius * 0.8 ? 1 : 2)
        touchStartAngle = atan2(location.y - center.y, location.x - center.x)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let ring = selectedRing, let startAngle = touchStartAngle else { return }

        let location = touch.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let currentAngle = atan2(location.y - center.y, location.x - center.x)
        let angleDiff = currentAngle - startAngle

//        switch ring {
//        case 0: updateSelection(&selectedYear, from: years, by: angleDiff)
//        case 1: updateSelection(&selectedMonth, from: months, by: angleDiff)
//        case 2: updateSelection(&selectedDay, from: days, by: angleDiff)
//        default: break
//        }

        touchStartAngle = currentAngle
        setNeedsDisplay()
    }
    
//    private func updateSelection<T: Equatable>(_ selected: inout T, from data: [T], by angle: CGFloat) {
//        guard let currentIndex = data.firstIndex(of: selected) else { return }
//        let angleStep = 2 * .pi / CGFloat(data.count)
//        let steps = angle / angleStep
//        let newIndex = (currentIndex + Int(steps)).modulo(data.count)
//        selected = data[newIndex]
//    }

//    private func updateSelection<T>(_ selected: inout T, from data: [T], by angle: CGFloat) {
//        guard let currentIndex = data.firstIndex(of: selected) else { return }
//        let angleStep = 2 * .pi / CGFloat(data.count)
//        let steps = angle / angleStep
//        let newIndex = (currentIndex + Int(steps)).modulo(data.count)
//        selected = data[newIndex]
//    }
}
*/

//private extension Int {
//    func modulo(_ n: Int) -> Int { return (self % n + n) % n }
//}


//class CurvedDatePickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
//    
//    let pickerView = UIPickerView()
//    let years = Array(1900...2025)
//    let months = Calendar.current.monthSymbols
//    let days = Array(1...31)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//        
//        pickerView.delegate = self
//        pickerView.dataSource = self
//        pickerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(pickerView)
//        
//        NSLayoutConstraint.activate([
//            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor),
//            pickerView.heightAnchor.constraint(equalToConstant: 250)
//        ])
//        
//        applyCurvedEffect()
//    }
//    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 3
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        switch component {
//        case 0: return years.count
//        case 1: return months.count
//        case 2: return days.count
//        default: return 0
//        }
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        switch component {
//        case 0: return "\(years[row])"
//        case 1: return months[row]
//        case 2: return String(format: "%02d", days[row])
//        default: return nil
//        }
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        calculateAge()
//    }
//    
//    private func calculateAge() {
//        let selectedYear = years[pickerView.selectedRow(inComponent: 0)]
//        let currentYear = Calendar.current.component(.year, from: Date())
//        let age = currentYear - selectedYear
//        
//        print("Your age is \(age)")
//    }
//}


//class CircularPicker: UIView {
//    var years = Array(1900...2100)
//    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//    var days = Array(1...31)
//
//    var selectedYear = 2000
//    var selectedMonth = "Jan"
//    var selectedDay = 1
//
//    private let labelFont = UIFont.systemFont(ofSize: 14)
//    private let labelColor = UIColor.white
//    private let selectionColor = UIColor.gray
//    private let indicatorColor = UIColor.orange
//
//    private var touchStartAngle: CGFloat?
//    private var selectedRing: Int?
//
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) * 0.4
//
//        drawRing(data: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
//        drawRing(data: months, selectedValue: selectedMonth, center: center, radius: radius * 0.75, context: context)
//        drawRing(data: days, selectedValue: selectedDay, center: center, radius: radius * 0.5, context: context)
//
//        drawIndicator(at: center, context: context)
//        displayAge(in: rect)
//    }
//
//    private func drawRing<T: Equatable>(data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
//        guard let selectedIndex = data.firstIndex(of: selectedValue) else { return }
//        let angleStep = 2 * .pi / CGFloat(data.count)
//
//        for (index, value) in data.enumerated() {
//            let angle = angleStep * CGFloat(index) - .pi / 2
//            let labelCenter = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
//            drawLabel(text: "\(value)", at: labelCenter)
//
//            if index == selectedIndex {
//                context.setStrokeColor(selectionColor.cgColor)
//                context.setLineWidth(3)
//                context.addArc(center: center, radius: radius, startAngle: angle - 0.1, endAngle: angle + 0.1, clockwise: false)
//                context.strokePath()
//            }
//        }
//    }
//
//    private func drawLabel(text: String, at point: CGPoint) {
//        let attributes: [NSAttributedString.Key: Any] = [.font: labelFont, .foregroundColor: labelColor]
//        let textSize = text.size(withAttributes: attributes)
//        let labelRect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
//        text.draw(in: labelRect, withAttributes: attributes)
//    }
//
//    private func drawIndicator(at point: CGPoint, context: CGContext) {
//        context.setFillColor(indicatorColor.cgColor)
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: point.x, y: point.y - 10))
//        path.addLine(to: CGPoint(x: point.x - 5, y: point.y - 20))
//        path.addLine(to: CGPoint(x: point.x + 5, y: point.y - 20))
//        path.close()
//        context.addPath(path.cgPath)
//        context.fillPath()
//    }
//
//    private func displayAge(in rect: CGRect) {
//        let age = calculateAge()
//        let ageLabel = UILabel(frame: CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 20))
//        ageLabel.text = "Your age is \(age)"
//        ageLabel.textAlignment = .center
//        ageLabel.textColor = labelColor
//        ageLabel.font = labelFont
//        addSubview(ageLabel)
//    }
//
//    private func calculateAge() -> Int {
//        let calendar = Calendar.current
//        let birthDate = calendar.date(from: DateComponents(year: selectedYear, month: months.firstIndex(of: selectedMonth)! + 1, day: selectedDay)) ?? Date()
//        return calendar.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = min(bounds.width, bounds.height) * 0.4
//
//        let distance = hypot(location.x - center.x, location.y - center.y)
//        selectedRing = distance <= radius * 0.6 ? 0 : (distance <= radius * 0.8 ? 1 : 2)
//        touchStartAngle = atan2(location.y - center.y, location.x - center.x)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let ring = selectedRing, let startAngle = touchStartAngle else { return }
//
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let currentAngle = atan2(location.y - center.y, location.x - center.x)
//        let angleDiff = currentAngle - startAngle
//
//        switch ring {
//        case 0: updateSelection(&selectedYear, from: years, by: angleDiff)
//        case 1: updateSelection(&selectedMonth, from: months, by: angleDiff)
//        case 2: updateSelection(&selectedDay, from: days, by: angleDiff)
//        default: break
//        }
//
//        touchStartAngle = currentAngle
//        setNeedsDisplay()
//    }
//
//    private func updateSelection<T>(_ selected: inout T, from data: [T], by angle: CGFloat) {
//        guard let currentIndex = data.firstIndex(of: selected) else { return }
//        let newIndex = (currentIndex + Int(angle * 10)).modulo(data.count)
//        selected = data[newIndex]
//    }
//}

//private extension Int {
//    func modulo(_ n: Int) -> Int { return (self % n + n) % n }
//}


//class CircularPicker: UIView {
//
//    var years: [Int] = Array(1900...2100)
//    var months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//    var days: [Int] = Array(1...31)
//
//    var selectedYear: Int = 1998
//    var selectedMonth: String = "Nov"
//    var selectedDay: Int = 5
//
//    private let labelFont = UIFont.systemFont(ofSize: 14)
//
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius: CGFloat = min(rect.width, rect.height) * 0.4
//
//        drawRing(data: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
//        drawRing(data: months, selectedValue: selectedMonth, center: center, radius: radius * 0.75, context: context)
//        drawRing(data: days, selectedValue: selectedDay, center: center, radius: radius * 0.5, context: context)
//
//        drawIndicator(at: center, context: context)
//        displayAge(at: rect)
//    }
//
//    private func drawRing<T: Equatable>(data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
//        let angleRange: CGFloat = 2 * .pi  // Full circle
//        guard let selectedIndex = data.firstIndex(of: selectedValue) else { return } // Handle potential nil
//        let selectedAngle = CGFloat(selectedIndex) / CGFloat(data.count) * angleRange - .pi / 2
//
//        // Draw selection arc
//        context.setStrokeColor(UIColor.gray.cgColor)
//        context.setLineWidth(3)
//        context.addArc(center: center, radius: radius, startAngle: selectedAngle - 0.1, endAngle: selectedAngle + 0.1, clockwise: false)
//        context.strokePath()
//
//        // Draw labels evenly around the ring
//        for (index, value) in data.enumerated() {
//            let angle = CGFloat(index) / CGFloat(data.count) * angleRange - .pi / 2
//            let labelCenter = CGPoint(
//                x: center.x + radius * cos(angle),
//                y: center.y + radius * sin(angle)
//            )
//            drawLabel(text: String(describing: value), at: labelCenter, context: context)
//        }
//    }
//
//    private func drawLabel(text: String, at point: CGPoint, context: CGContext) {
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: labelFont,
//            .foregroundColor: UIColor.white
//        ]
//        let attributedText = NSAttributedString(string: text, attributes: attributes)
//        let textSize = attributedText.size()
//        let labelRect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
//        attributedText.draw(in: labelRect)
//    }
//
//    private func drawIndicator(at point: CGPoint, context: CGContext) {
//        context.setFillColor(UIColor.orange.cgColor)
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: point.x, y: point.y - 10))
//        path.addLine(to: CGPoint(x: point.x - 5, y: point.y - 20))
//        path.addLine(to: CGPoint(x: point.x + 5, y: point.y - 20))
//        path.close()
//        context.addPath(path.cgPath)
//        context.fillPath()
//    }
//
//    private func displayAge(at rect: CGRect) {
//        let age = calculateAge()
//        let ageLabel = UILabel(frame: CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 20))
//        ageLabel.textAlignment = .center
//        ageLabel.textColor = .white
//        ageLabel.font = labelFont
//        ageLabel.text = "Your age is \(age)"
//        addSubview(ageLabel)
//    }
//
//    private func calculateAge() -> Int {
//        let calendar = Calendar.current
//        let birthDateComponents = DateComponents(year: 1998, month: 11, day: 5) // Replace with actual birthdate
//        guard let birthDate = calendar.date(from: birthDateComponents) else { return 0 }
//
//        let currentDate = Date()
//        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
//        return ageComponents.year ?? 0
//    }
//
//    private var touchStartAngle: CGFloat?
//    private var selectedRing: Int?
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = min(bounds.width, bounds.height) * 0.4
//
//        let distanceFromCenter = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
//        selectedRing = distanceFromCenter <= radius * 0.6 ? 0 : (distanceFromCenter <= radius * 0.8 ? 1 : 2)
//        touchStartAngle = calculateAngle(for: location, center: center)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let selectedRing = selectedRing, let startAngle = touchStartAngle else { return }
//
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let currentAngle = calculateAngle(for: location, center: center)
//
//        let angleDifference = currentAngle - startAngle
//        updateSelectedValue(for: selectedRing, with: angleDifference)
//
//        touchStartAngle = currentAngle
//        setNeedsDisplay()
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        selectedRing = nil
//        touchStartAngle = nil
//    }
//
//    private func calculateAngle(for point: CGPoint, center: CGPoint) -> CGFloat {
//        let deltaX = point.x - center.x
//        let deltaY = point.y - center.y
//        return atan2(deltaY, deltaX)
//    }
//
//
//    private func updateSelectedValue(for ring: Int, with angleDifference: CGFloat) {
//        let angleRange: CGFloat = 2 * .pi  // Full circle
//        switch ring {
//        case 0: // Years
//            updateValue(for: &selectedYear, in: years, with: angleDifference, angleRange: angleRange)
//        case 1: // Months
//            updateValue(for: &selectedMonth, in: months, with: angleDifference, angleRange: angleRange)
//        case 2: // Days
//            updateValue(for: &selectedDay, in: days, with: angleDifference, angleRange: angleRange)
//        default:
//            break
//        }
//    }
//
//    private func updateValue<T: Equatable & Comparable>(for currentValue: inout T, in data: [T], with angleDifference: CGFloat, angleRange: CGFloat) {
//        guard let currentIndex = data.firstIndex(of: currentValue) else { return }
//        let dataCount = CGFloat(data.count)
//        let currentAngle = CGFloat(currentIndex) / dataCount * angleRange - .pi / 2
//        let newAngle = currentAngle + angleDifference
//
//        var newIndex = Int(round((newAngle + .pi / 2) / angleRange * dataCount))
//        newIndex = max(0, min(newIndex, data.count - 1))
//
//        currentValue = data[newIndex]
//    }
//}



//class CircularPicker: UIView {
//    
//    var years: [Int] = Array(1900...2100)
//    var months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//    var days: [Int] = Array(1...31)
//    
//    var selectedYear: Int = 1998
//    var selectedMonth: String = "Nov"
//    var selectedDay: Int = 5
//    
//    private let labelFont = UIFont.systemFont(ofSize: 14)
//    
//    
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius: CGFloat = min(rect.width, rect.height) * 0.4
//
//        drawRing(data: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
//        drawRing(data: months, selectedValue: selectedMonth, center: center, radius: radius * 0.75, context: context)
//        drawRing(data: days, selectedValue: selectedDay, center: center, radius: radius * 0.5, context: context)
//
//        drawIndicator(at: center, context: context)
//        displayAge(at: rect)
//    }
//
//    private func drawRing<T: Equatable>(data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
//        let angleRange: CGFloat = 2 * .pi  // Full circle
//        let selectedIndex = data.firstIndex(of: selectedValue)!
//        let selectedAngle = CGFloat(selectedIndex) / CGFloat(data.count) * angleRange - .pi / 2
//
//        // Draw selection arc
//        context.setStrokeColor(UIColor.gray.cgColor)
//        context.setLineWidth(3)
//        context.addArc(center: center, radius: radius, startAngle: selectedAngle - 0.1, endAngle: selectedAngle + 0.1, clockwise: false)
//        context.strokePath()
//
//        // Draw labels evenly around the ring
//        for (index, value) in data.enumerated() {
//            let angle = CGFloat(index) / CGFloat(data.count) * angleRange - .pi / 2
//            let labelCenter = CGPoint(
//                x: center.x + radius * cos(angle),
//                y: center.y + radius * sin(angle)
//            )
//            drawLabel(text: String(describing: value), at: labelCenter, context: context)
//        }
//    }
//
//    
//    
//    /*
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius: CGFloat = min(rect.width, rect.height) * 0.4
//        
//        drawRing(data: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
//        drawRing(data: months, selectedValue: selectedMonth, center: center, radius: radius * 0.8, context: context)
//        drawRing(data: days, selectedValue: selectedDay, center: center, radius: radius * 0.6, context: context)
//        
//        drawIndicator(at: center, context: context)
//        displayAge(at: rect)
//    }
//    
//    private func drawRing<T: Equatable>(data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
//        let angleRange: CGFloat = .pi * 0.6
//        let selectedIndex = data.firstIndex(of: selectedValue)!
//        let selectedAngle = CGFloat(selectedIndex) / CGFloat(data.count) * angleRange - angleRange / 2
//        
//        context.setStrokeColor(UIColor.gray.cgColor)
//        context.setLineWidth(2)
//        context.addArc(center: center, radius: radius, startAngle: -CGFloat.pi / 2 + selectedAngle - 0.1, endAngle: -CGFloat.pi / 2 + selectedAngle + 0.1, clockwise: false)
//        context.strokePath()
//        
//        let labelRadius = radius * 0.8
//        for (index, value) in data.enumerated() {
//            let angle = CGFloat(index) / CGFloat(data.count) * angleRange - angleRange / 2
//            let labelCenter = CGPoint(x: center.x + labelRadius * cos(-CGFloat.pi / 2 + angle), y: center.y + labelRadius * sin(-CGFloat.pi / 2 + angle))
//            drawLabel(text: String(describing: value), at: labelCenter, context: context)
//        }
//    }
//    */
//    
//    private func drawLabel(text: String, at point: CGPoint, context: CGContext) {
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: labelFont,
//            .foregroundColor: UIColor.white
//        ]
//        let attributedText = NSAttributedString(string: text, attributes: attributes)
//        let textSize = attributedText.size()
//        let labelRect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
//        attributedText.draw(in: labelRect)
//    }
//    
//    private func drawIndicator(at point: CGPoint, context: CGContext) {
//        context.setFillColor(UIColor.orange.cgColor)
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: point.x, y: point.y - 10))
//        path.addLine(to: CGPoint(x: point.x - 5, y: point.y - 20))
//        path.addLine(to: CGPoint(x: point.x + 5, y: point.y - 20))
//        path.close()
//        context.addPath(path.cgPath)
//        context.fillPath()
//    }
//    
//    private func displayAge(at rect: CGRect) {
//        let age = calculateAge()
//        let ageLabel = UILabel(frame: CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 20))
//        ageLabel.textAlignment = .center
//        ageLabel.textColor = .white
//        ageLabel.font = labelFont
//        ageLabel.text = "Your age is \(age)"
//        addSubview(ageLabel)
//    }
//    
//    private func calculateAge() -> Int {
//        let calendar = Calendar.current
//        let birthDateComponents = DateComponents(year: 1998, month: 11, day: 5)
//        guard let birthDate = calendar.date(from: birthDateComponents) else { return 0 }
//
//        let currentDate = Date()
//        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
//        return ageComponents.year ?? 0
//    }
//    
//    private var touchStartAngle: CGFloat?
//    private var selectedRing: Int?
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = min(bounds.width, bounds.height) * 0.4
//
//        let distanceFromCenter = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
//        selectedRing = distanceFromCenter <= radius * 0.6 ? 0 : (distanceFromCenter <= radius * 0.8 ? 1 : 2)
//        touchStartAngle = calculateAngle(for: location, center: center)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let selectedRing = selectedRing, let startAngle = touchStartAngle else { return }
//
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let currentAngle = calculateAngle(for: location, center: center)
//
//        let angleDifference = currentAngle - startAngle
//        updateSelectedValue(for: selectedRing, with: angleDifference)
//        touchStartAngle = currentAngle
//        setNeedsDisplay()
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        selectedRing = nil
//        touchStartAngle = nil
//    }
//
//    private func calculateAngle(for point: CGPoint, center: CGPoint) -> CGFloat {
//        let deltaX = point.x - center.x
//        let deltaY = point.y - center.y
//        return atan2(deltaY, deltaX)
//    }
//
//    private func updateSelectedValue(for ring: Int, with angleDifference: CGFloat) {
//        let angleRange: CGFloat = .pi * 0.6
//        var data: [Any]
//        var currentValue: Any
//
//        switch ring {
//        case 0:
//            data = years
//            currentValue = selectedYear
//        case 1:
//            data = months
//            currentValue = selectedMonth
//        case 2:
//            data = days
//            currentValue = selectedDay
//        default: return
//        }
//
//        let dataCount = CGFloat(data.count)
//        var currentAngle: CGFloat
//
//        if let year = currentValue as? Int, ring == 0 {
//            currentAngle = calculateCurrentAngle(for: year, in: years, angleRange: angleRange)
//        } else if let month = currentValue as? String, ring == 1 {
//            currentAngle = calculateCurrentAngle(for: month, in: months, angleRange: angleRange)
//        } else if let day = currentValue as? Int, ring == 2 {
//            currentAngle = calculateCurrentAngle(for: day, in: days, angleRange: angleRange)
//        } else {
//            return
//        }
//
//        let newAngle = currentAngle + angleDifference
//        var newIndex = Int(round((newAngle + angleRange / 2) / angleRange * dataCount))
//        newIndex = max(0, min(newIndex, data.count - 1))
//
//        switch ring {
//        case 0: selectedYear = years[newIndex]
//        case 1: selectedMonth = months[newIndex]
//        case 2: selectedDay = days[newIndex]
//        default: break
//        }
//    }
//
//    private func calculateCurrentAngle<T: Equatable>(for value: T, in data: [T], angleRange: CGFloat) -> CGFloat {
//        guard let index = data.firstIndex(of: value) else { return 0 }
//        return CGFloat(index) / CGFloat(data.count) * angleRange - angleRange / 2
//    }
//}



//class CircularPicker: UIView {
//
////    var years: [Int] = Array(1900...2100)
////    var months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
////    var days: [Int] = Array(1...31)
////
////    var selectedYear: Int = 1998
////    var selectedMonth: String = "Nov"
////    var selectedDay: Int = 5
////
////    private let labelFont = UIFont.systemFont(ofSize: 14)
//    
//    // Data arrays for years, months, and days
//       var years: [Int] = Array(1900...2100)
//       var months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//       var days: [Int] = Array(1...31)
//       
//       // Selected values
//       var selectedYear: Int = 1998
//       var selectedMonth: String = "Nov"
//       var selectedDay: Int = 5
//       
//       // Font for displaying labels
//       private let labelFont = UIFont.systemFont(ofSize: 14)
//    
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius: CGFloat = min(rect.width, rect.height) * 0.4
//        
//        // Draw all rings (years, months, days)
//        drawRing(data: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
//        drawRing(data: months, selectedValue: selectedMonth, center: center, radius: radius * 0.8, context: context)
//        drawRing(data: days, selectedValue: selectedDay, center: center, radius: radius * 0.6, context: context)
//        
//        drawIndicator(at: center, context: context)
//        
//        // Display the age at the bottom
//        displayAge(at: rect)
//    }
//
//    private func drawRing<T: Equatable>(data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
//        let angleRange: CGFloat = .pi * 0.6
//        let selectedIndex = data.firstIndex(of: selectedValue)!
//        let selectedAngle = CGFloat(selectedIndex) / CGFloat(data.count) * angleRange - angleRange / 2
//
//        // Draw the selected arc for the current value
//        context.setStrokeColor(UIColor.gray.cgColor)
//        context.setLineWidth(2)
//        context.addArc(center: center, radius: radius, startAngle: -CGFloat.pi / 2 + selectedAngle - 0.1, endAngle: -CGFloat.pi / 2 + selectedAngle + 0.1, clockwise: false)
//        context.strokePath()
//
//        // Draw labels around the ring
//        let labelRadius = radius * 0.8
//        for (index, value) in data.enumerated() {
//            let angle = CGFloat(index) / CGFloat(data.count) * angleRange - angleRange / 2
//            let labelCenter = CGPoint(x: center.x + labelRadius * cos(-CGFloat.pi / 2 + angle), y: center.y + labelRadius * sin(-CGFloat.pi / 2 + angle))
//            drawLabel(text: String(describing: value), at: labelCenter, context: context)
//        }
//    }
//
//    private func drawLabel(text: String, at point: CGPoint, context: CGContext) {
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: labelFont,
//            .foregroundColor: UIColor.white
//        ]
//        let attributedText = NSAttributedString(string: text, attributes: attributes)
//        let textSize = attributedText.size()
//        let labelRect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
//        attributedText.draw(in: labelRect)
//    }
//    
//    private func drawIndicator(at point: CGPoint, context: CGContext) {
//        context.setFillColor(UIColor.orange.cgColor)
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: point.x, y: point.y - 10))
//        path.addLine(to: CGPoint(x: point.x - 5, y: point.y - 20))
//        path.addLine(to: CGPoint(x: point.x + 5, y: point.y - 20))
//        path.close()
//        context.addPath(path.cgPath)
//        context.fillPath()
//    }
//
//    private func displayAge(at rect: CGRect) {
//        let age = calculateAge()
//        let ageLabel = UILabel(frame: CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 20))
//        ageLabel.textAlignment = .center
//        ageLabel.textColor = .white
//        ageLabel.font = labelFont
//        ageLabel.text = "Your age is \(age)"
//        addSubview(ageLabel)
//    }
//
//    private func calculateAge() -> Int {
//        let calendar = Calendar.current
//        let birthDateComponents = DateComponents(year: 1998, month: 11, day: 5)
//        guard let birthDate = calendar.date(from: birthDateComponents) else { return 0 }
//
//        let currentDate = Date()
//        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
//        return ageComponents.year ?? 0
//    }
//
//
//
////    override func draw(_ rect: CGRect) {
////        guard let context = UIGraphicsGetCurrentContext() else { return }
////
////        let center = CGPoint(x: rect.midX, y: rect.midY)
////        let radius: CGFloat = min(rect.width, rect.height) * 0.4
////
////        // Draw all rings with a single function
////        drawRing(data: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
////        drawRing(data: months, selectedValue: selectedMonth, center: center, radius: radius * 0.7, context: context)
////        drawRing(data: days, selectedValue: selectedDay, center: center, radius: radius * 0.5, context: context)
////
////        drawIndicator(at: center, context: context)
////
////        // Display Age
////        displayAge(at: rect)
////    }
//
////    private func drawRing<T: Equatable>(data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
////        let angleRange: CGFloat = .pi * 0.8 // increased to fit all elements in the circle
////        let selectedIndex = data.firstIndex(of: selectedValue)!
////        let selectedAngle = CGFloat(selectedIndex) / CGFloat(data.count) * angleRange - angleRange / 2
////
////        // Draw Arc
////        context.setStrokeColor(UIColor.gray.cgColor)
////        context.setLineWidth(2)
////        context.addArc(center: center, radius: radius, startAngle: -CGFloat.pi / 2 + selectedAngle - 0.1, endAngle: -CGFloat.pi / 2 + selectedAngle + 0.1, clockwise: false)
////        context.strokePath()
////
////        // Draw Labels
////        let labelRadius = radius * 0.8 // Make sure labels don't overlap
////        for (index, value) in data.enumerated() {
////            let angle = CGFloat(index) / CGFloat(data.count) * angleRange - angleRange / 2
////            let labelCenter = CGPoint(x: center.x + labelRadius * cos(-CGFloat.pi / 2 + angle), y: center.y + labelRadius * sin(-CGFloat.pi / 2 + angle))
////            drawLabel(text: String(describing: value), at: labelCenter, context: context)
////        }
////    }
//
////    private func drawLabel(text: String, at point: CGPoint, context: CGContext) {
////        let attributes: [NSAttributedString.Key: Any] = [
////            .font: labelFont,
////            .foregroundColor: UIColor.white
////        ]
////        let attributedText = NSAttributedString(string: text, attributes: attributes)
////        let textSize = attributedText.size()
////        let labelRect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
////        attributedText.draw(in: labelRect)
////    }
//
////    private func drawIndicator(at point: CGPoint, context: CGContext) {
////        context.setFillColor(UIColor.orange.cgColor)
////        let path = UIBezierPath()
////        path.move(to: CGPoint(x: point.x, y: point.y - 10))
////        path.addLine(to: CGPoint(x: point.x - 5, y: point.y - 20))
////        path.addLine(to: CGPoint(x: point.x + 5, y: point.y - 20))
////        path.close()
////        context.addPath(path.cgPath)
////        context.fillPath()
////    }
//
////    private func displayAge(at rect: CGRect) {
////        let age = calculateAge()
////        let ageLabel = UILabel(frame: CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 20))
////        ageLabel.textAlignment = .center
////        ageLabel.textColor = .white
////        ageLabel.font = labelFont
////        ageLabel.text = "Your age is \(age)"
////        addSubview(ageLabel)
////    }
//
////    private func calculateAge() -> Int {
////        let calendar = Calendar.current
////        let birthDateComponents = DateComponents(year: 1998, month: 11, day: 5)
////        guard let birthDate = calendar.date(from: birthDateComponents) else { return 0 }
////
////        let currentDate = Date()
////        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
////        return ageComponents.year ?? 0
////    }
//
//    // MARK: - Touch Handling
//
////    private var touchStartAngle: CGFloat?
////    private var selectedRing: Int?
////
////    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        guard let touch = touches.first else { return }
////        let location = touch.location(in: self)
////        let center = CGPoint(x: bounds.midX, y: bounds.midY)
////        let radius = min(bounds.width, bounds.height) * 0.4
////
////        let distanceFromCenter = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
////        selectedRing = distanceFromCenter <= radius * 0.6 ? 0 : (distanceFromCenter <= radius * 0.8 ? 1 : 2)
////        touchStartAngle = calculateAngle(for: location, center: center)
////    }
////
////    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
////        guard let touch = touches.first, let selectedRing = selectedRing, let startAngle = touchStartAngle else { return }
////
////        let location = touch.location(in: self)
////        let center = CGPoint(x: bounds.midX, y: bounds.midY)
////        let currentAngle = calculateAngle(for: location, center: center)
////
////        let angleDifference = currentAngle - startAngle
////        updateSelectedValue(for: selectedRing, with: angleDifference)
////        touchStartAngle = currentAngle
////        setNeedsDisplay()
////    }
////
////    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
////        selectedRing = nil
////        touchStartAngle = nil
////    }
//
//    private var touchStartAngle: CGFloat?
//    private var selectedRing: Int?
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = min(bounds.width, bounds.height) * 0.4
//
//        let distanceFromCenter = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
//        selectedRing = distanceFromCenter <= radius * 0.6 ? 0 : (distanceFromCenter <= radius * 0.8 ? 1 : 2)
//        touchStartAngle = calculateAngle(for: location, center: center)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let selectedRing = selectedRing, let startAngle = touchStartAngle else { return }
//
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let currentAngle = calculateAngle(for: location, center: center)
//
//        let angleDifference = currentAngle - startAngle
//        updateSelectedValue(for: selectedRing, with: angleDifference)
//        touchStartAngle = currentAngle
//        setNeedsDisplay()
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        selectedRing = nil
//        touchStartAngle = nil
//    }
//
//    private func calculateAngle(for point: CGPoint, center: CGPoint) -> CGFloat {
//        let deltaX = point.x - center.x
//        let deltaY = point.y - center.y
//        return atan2(deltaY, deltaX)
//    }
//
//    private func updateSelectedValue(for ring: Int, with angleDifference: CGFloat) {
//        let angleRange: CGFloat = .pi * 0.6
//        var data: [Any]
//        var currentValue: Any
//        
//        switch ring {
//        case 0:
//            data = years // [Int]
//            currentValue = selectedYear
//        case 1:
//            data = months // [String]
//            currentValue = selectedMonth
//        case 2:
//            data = days // [Int]
//            currentValue = selectedDay
//        default: return
//        }
//        
//        let dataCount = CGFloat(data.count)
//        var currentAngle: CGFloat
//        
//        // Handle each case where the data is of a specific type
//        if let year = currentValue as? Int, ring == 0 {
//            currentAngle = calculateCurrentAngle(for: year, in: years, angleRange: angleRange)
//        } else if let month = currentValue as? String, ring == 1 {
//            currentAngle = calculateCurrentAngle(for: month, in: months)
//            
//        }
//    }
//    
////    private func calculateAngle(for point: CGPoint, center: CGPoint) -> CGFloat {
////        let deltaX = point.x - center.x
////        let deltaY = point.y - center.y
////        return atan2(deltaY, deltaX)
////    }
//    
////    private func updateSelectedValue(for ring: Int, with angleDifference: CGFloat) {
////        let angleRange: CGFloat = .pi * 0.8 // increased to fit all elements in the circle
////        var data: [Any]
////        var currentValue: Any
////
////        switch ring {
////        case 0:
////            data = years // [Int]
////            currentValue = selectedYear
////        case 1:
////            data = months // [String]
////            currentValue = selectedMonth
////        case 2:
////            data = days // [Int]
////            currentValue = selectedDay
////        default: return
////        }
////
////        let dataCount = CGFloat(data.count)
////        var currentAngle: CGFloat
////
////        // Handle each case where the data is of a specific type
////        if let year = currentValue as? Int, ring == 0 {
////            currentAngle = calculateCurrentAngle(for: year, in: years, angleRange: angleRange)
////        } else if let month = currentValue as? String, ring == 1 {
////            currentAngle = calculateCurrentAngle(for: month, in: months, angleRange: angleRange)
////        } else if let day = currentValue as? Int, ring == 2 {
////            currentAngle = calculateCurrentAngle(for: day, in: days, angleRange: angleRange)
////        } else {
////            return // Exit if the value doesn't match the expected type
////        }
////
////        let newAngle = currentAngle + angleDifference
////        var newIndex = Int(round((newAngle + angleRange / 2) / angleRange * dataCount))
////        newIndex = max(0, min(newIndex, data.count - 1))
////
////        // Update the selected value based on the new index
////        switch ring {
////        case 0: selectedYear = years[newIndex]
////        case 1: selectedMonth = months[newIndex]
////        case 2: selectedDay = days[newIndex]
////        default: break
////        }
////    }
//    
////    private func calculateCurrentAngle<T: Equatable>(for value: T, in data: [T], angleRange: CGFloat) -> CGFloat {
////        guard let index = data.firstIndex(of: value) else { return 0 }
////        return CGFloat(index) / CGFloat(data.count) * angleRange - angleRange / 2
////    }
//
//}


//class CircularPicker: UIView {
//
//    var years: [Int] = Array(1900...2100)
//    var months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//    var days: [Int] = Array(1...31)
//
//    var selectedYear: Int = 1998
//    var selectedMonth: String = "Nov"
//    var selectedDay: Int = 5
//
//    private let labelFont = UIFont.systemFont(ofSize: 14)
//
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius: CGFloat = min(rect.width, rect.height) * 0.4
//
//        // Draw all rings with a single function
//        drawRing(data: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
//        drawRing(data: months, selectedValue: selectedMonth, center: center, radius: radius * 0.8, context: context)
//        drawRing(data: days, selectedValue: selectedDay, center: center, radius: radius * 0.6, context: context)
//
//        drawIndicator(at: center, context: context)
//
//        // Display Age
//        displayAge(at: rect)
//    }
//
//    private func drawRing<T: Equatable>(data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
//        let angleRange: CGFloat = .pi * 0.6
//        let selectedIndex = data.firstIndex(of: selectedValue)!
//        let selectedAngle = CGFloat(selectedIndex) / CGFloat(data.count) * angleRange - angleRange / 2
//
//        // Draw Arc
//        context.setStrokeColor(UIColor.gray.cgColor)
//        context.setLineWidth(2)
//        context.addArc(center: center, radius: radius, startAngle: -CGFloat.pi / 2 + selectedAngle - 0.1, endAngle: -CGFloat.pi / 2 + selectedAngle + 0.1, clockwise: false)
//        context.strokePath()
//
//        // Draw Labels
//        let labelRadius = radius * 0.8
//        for (index, value) in data.enumerated() {
//            let angle = CGFloat(index) / CGFloat(data.count) * angleRange - angleRange / 2
//            let labelCenter = CGPoint(x: center.x + labelRadius * cos(-CGFloat.pi / 2 + angle), y: center.y + labelRadius * sin(-CGFloat.pi / 2 + angle))
//            drawLabel(text: String(describing: value), at: labelCenter, context: context)
//        }
//    }
//
//    private func drawLabel(text: String, at point: CGPoint, context: CGContext) {
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: labelFont,
//            .foregroundColor: UIColor.white
//        ]
//        let attributedText = NSAttributedString(string: text, attributes: attributes)
//        let textSize = attributedText.size()
//        let labelRect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
//        attributedText.draw(in: labelRect)
//    }
//
//    private func drawIndicator(at point: CGPoint, context: CGContext) {
//        context.setFillColor(UIColor.orange.cgColor)
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: point.x, y: point.y - 10))
//        path.addLine(to: CGPoint(x: point.x - 5, y: point.y - 20))
//        path.addLine(to: CGPoint(x: point.x + 5, y: point.y - 20))
//        path.close()
//        context.addPath(path.cgPath)
//        context.fillPath()
//    }
//
//    private func displayAge(at rect: CGRect) {
//        let age = calculateAge()
//        let ageLabel = UILabel(frame: CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 20))
//        ageLabel.textAlignment = .center
//        ageLabel.textColor = .white
//        ageLabel.font = labelFont
//        ageLabel.text = "Your age is \(age)"
//        addSubview(ageLabel)
//    }
//
//    private func calculateAge() -> Int {
//        let calendar = Calendar.current
//        let birthDateComponents = DateComponents(year: 1998, month: 11, day: 5)
//        guard let birthDate = calendar.date(from: birthDateComponents) else { return 0 }
//
//        let currentDate = Date()
//        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
//        return ageComponents.year ?? 0
//    }
//
//    // MARK: - Touch Handling
//
//    private var touchStartAngle: CGFloat?
//    private var selectedRing: Int?
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = min(bounds.width, bounds.height) * 0.4
//
//        let distanceFromCenter = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
//        selectedRing = distanceFromCenter <= radius * 0.6 ? 0 : (distanceFromCenter <= radius * 0.8 ? 1 : 2)
//        touchStartAngle = calculateAngle(for: location, center: center)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let selectedRing = selectedRing, let startAngle = touchStartAngle else { return }
//
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let currentAngle = calculateAngle(for: location, center: center)
//
//        let angleDifference = currentAngle - startAngle
//        updateSelectedValue(for: selectedRing, with: angleDifference)
//        touchStartAngle = currentAngle
//        setNeedsDisplay()
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        selectedRing = nil
//        touchStartAngle = nil
//    }
//
//    private func calculateAngle(for point: CGPoint, center: CGPoint) -> CGFloat {
//        let deltaX = point.x - center.x
//        let deltaY = point.y - center.y
//        return atan2(deltaY, deltaX)
//    }
//
////    private func updateSelectedValue(for ring: Int, with angleDifference: CGFloat) {
////        let angleRange: CGFloat = .pi * 0.6
////        let data: [Any]
////        var currentValue: Any
////
////        switch ring {
////        case 0: data = years; currentValue = selectedYear
////        case 1: data = months; currentValue = selectedMonth
////        case 2: data = days; currentValue = selectedDay
////        default: return
////        }
////
////        let dataCount = CGFloat(data.count)
////        let currentAngle = calculateCurrentAngle(for: currentValue, in: data, angleRange: angleRange)
////
////        var newIndex = Int(round((currentAngle + angleDifference + angleRange / 2) / angleRange * dataCount))
////        newIndex = max(0, min(newIndex, data.count - 1))
////
////        switch ring {
////        case 0: selectedYear = years[newIndex]
////        case 1: selectedMonth = months[newIndex]
////        case 2: selectedDay = days[newIndex]
////        default: break
////        }
////    }
//    
//    private func updateSelectedValue(for ring: Int, with angleDifference: CGFloat) {
//        let angleRange: CGFloat = .pi * 0.6
//        var data: [Any]
//        var currentValue: Any
//
//        switch ring {
//        case 0:
//            data = years // [Int]
//            currentValue = selectedYear
//        case 1:
//            data = months // [String]
//            currentValue = selectedMonth
//        case 2:
//            data = days // [Int]
//            currentValue = selectedDay
//        default: return
//        }
//
//        let dataCount = CGFloat(data.count)
//        var currentAngle: CGFloat
//
//        // Handle each case where the data is of a specific type
//        if let year = currentValue as? Int, ring == 0 {
//            currentAngle = calculateCurrentAngle(for: year, in: years, angleRange: angleRange)
//        } else if let month = currentValue as? String, ring == 1 {
//            currentAngle = calculateCurrentAngle(for: month, in: months, angleRange: angleRange)
//        } else if let day = currentValue as? Int, ring == 2 {
//            currentAngle = calculateCurrentAngle(for: day, in: days, angleRange: angleRange)
//        } else {
//            return // Exit if the value doesn't match the expected type
//        }
//
//        let newAngle = currentAngle + angleDifference
//        var newIndex = Int(round((newAngle + angleRange / 2) / angleRange * dataCount))
//        newIndex = max(0, min(newIndex, data.count - 1))
//
//        // Update the selected value based on the new index
//        switch ring {
//        case 0: selectedYear = years[newIndex]
//        case 1: selectedMonth = months[newIndex]
//        case 2: selectedDay = days[newIndex]
//        default: break
//        }
//    }
//
//
//    private func calculateCurrentAngle<T: Equatable>(for value: T, in data: [T], angleRange: CGFloat) -> CGFloat {
//        guard let index = data.firstIndex(of: value) else { return 0 }
//        return CGFloat(index) / CGFloat(data.count) * angleRange - angleRange / 2
//    }
//    
////    private func calculateCurrentAngle<T: Equatable>(for value: T, in data: [T], angleRange: CGFloat) -> CGFloat {
////        guard let index = data.firstIndex(of: value) else { return 0 }
////        return CGFloat(index) / CGFloat(data.count) * angleRange - angleRange / 2
////    }
//}



//class CircularPicker: UIView {
//
////    // ... (Data arrays, selected values, font as before) ...
////
////    override func draw(_ rect: CGRect) {
////        // ... (Drawing code as before) ...
////    }
////
////    // ... (drawArcAndLabels, drawLabel, drawIndicator functions as before) ...
////
////    private func calculateAge() -> Int {
////        // ... (Age calculation as before)
////    }
//
//    var years: [Int] = Array(1900...2100) // Example: Years from 1900 to 2100
//       var months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
//       var days: [Int] = Array(1...31) // Days 1 to 31
//
//       var selectedYear: Int = 1998
//       var selectedMonth: String = "Nov"
//       var selectedDay: Int = 5
//
//       private let labelFont = UIFont.systemFont(ofSize: 14) // Adjust font size
//
//       override func draw(_ rect: CGRect) {
//           guard let context = UIGraphicsGetCurrentContext() else { return }
//
//           let center = CGPoint(x: rect.midX, y: rect.midY)
//           let radius: CGFloat = min(rect.width, rect.height) * 0.4 // Adjust radius
//
//           drawArcAndLabels(for: years, selectedValue: selectedYear, center: center, radius: radius, context: context)
//           drawArcAndLabels(for: months, selectedValue: selectedMonth, center: center, radius: radius * 0.8, context: context) // Smaller radius for months
//           drawArcAndLabels(for: days, selectedValue: selectedDay, center: center, radius: radius * 0.6, context: context) // Even smaller for days
//
//
//           drawIndicator(at: center, context: context)
//
//           // Calculate Age (Example)
//           let age = calculateAge()
//           let ageLabel = UILabel(frame: CGRect(x: 0, y: rect.height - 30, width: rect.width, height: 20)) // Position at bottom
//           ageLabel.textAlignment = .center
//           ageLabel.textColor = .white // Set color as needed
//           ageLabel.font = labelFont
//           ageLabel.text = "Your age is \(age)"
//           addSubview(ageLabel) // Add as subview so it's not redrawn in draw(_:)
//       }
//
//       private func drawArcAndLabels<T: Equatable>(for data: [T], selectedValue: T, center: CGPoint, radius: CGFloat, context: CGContext) {
//
//           let angleRange: CGFloat = .pi * 0.6 // Adjust the arc length (e.g., .pi for a full circle)
//
//           let selectedIndex = data.firstIndex(of: selectedValue)!
//           let selectedAngle = CGFloat(selectedIndex) / CGFloat(data.count) * angleRange - angleRange/2
//
//           // Draw Arc
//           context.setStrokeColor(UIColor.gray.cgColor)
//           context.setLineWidth(2)
//           context.addArc(center: center, radius: radius, startAngle: -CGFloat.pi/2 + selectedAngle - 0.1, endAngle: -CGFloat.pi/2 + selectedAngle + 0.1, clockwise: false)
//           context.strokePath()
//
//           // Draw Labels
//           let labelRadius = radius * 0.8
//           for (index, value) in data.enumerated() {
//               let angle = CGFloat(index) / CGFloat(data.count) * angleRange - angleRange/2
//               let labelCenter = CGPoint(x: center.x + labelRadius * cos(-CGFloat.pi/2 + angle), y: center.y + labelRadius * sin(-CGFloat.pi/2 + angle))
//               drawLabel(text: String(describing: value), at: labelCenter, context: context)
//           }
//       }
//
//       private func drawLabel(text: String, at point: CGPoint, context: CGContext) {
//           let attributes: [NSAttributedString.Key: Any] = [
//               .font: labelFont,
//               .foregroundColor: UIColor.white // Set color as needed
//           ]
//           let attributedText = NSAttributedString(string: text, attributes: attributes)
//
//           let textSize = attributedText.size()
//           let labelRect = CGRect(x: point.x - textSize.width / 2, y: point.y - textSize.height / 2, width: textSize.width, height: textSize.height)
//
//           attributedText.draw(in: labelRect)
//       }
//
//
//       private func drawIndicator(at point: CGPoint, context: CGContext) {
//           context.setFillColor(UIColor.orange.cgColor) // Customize color
//           let path = UIBezierPath()
//           path.move(to: CGPoint(x: point.x, y: point.y - 10)) // Adjust size/position
//           path.addLine(to: CGPoint(x: point.x - 5, y: point.y - 20))
//           path.addLine(to: CGPoint(x: point.x + 5, y: point.y - 20))
//           path.close()
//           context.addPath(path.cgPath)
//           context.fillPath()
//       }
//
//       private func calculateAge() -> Int {
//           let calendar = Calendar.current
//           let birthDateComponents = DateComponents(year: 1998, month: 11, day: 5) // Replace with actual birthdate
//           guard let birthDate = calendar.date(from: birthDateComponents) else { return 0 }
//
//           let currentDate = Date()
//           let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
//           return ageComponents.year ?? 0
//       }
//    
//    // MARK: - Touch Handling
//
//    private var touchStartAngle: CGFloat?
//    private var selectedRing: Int? // 0: years, 1: months, 2: days
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let radius = min(bounds.width, bounds.height) * 0.4
//
//        // Determine which ring was touched
//        let distanceFromCenter = sqrt(pow(location.x - center.x, 2) + pow(location.y - center.y, 2))
//        if distanceFromCenter <= radius {
//            if distanceFromCenter > radius * 0.6 { // Days
//                selectedRing = 2
//            } else if distanceFromCenter > radius * 0.8 { // Months
//                selectedRing = 1
//            } else { // Years
//                selectedRing = 0
//            }
//
//            // Store the starting angle for tracking changes
//            touchStartAngle = calculateAngle(for: location, center: center)
//        } else {
//            selectedRing = nil // Touched outside the rings
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let selectedRing = selectedRing, let startAngle = touchStartAngle else { return }
//
//        let location = touch.location(in: self)
//        let center = CGPoint(x: bounds.midX, y: bounds.midY)
//        let currentAngle = calculateAngle(for: location, center: center)
//
//        let angleDifference = currentAngle - startAngle
//
//        updateSelectedValue(for: selectedRing, with: angleDifference)
//        touchStartAngle = currentAngle // Update start for next movement
//        setNeedsDisplay()
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        selectedRing = nil
//        touchStartAngle = nil
//    }
//
//    private func calculateAngle(for point: CGPoint, center: CGPoint) -> CGFloat {
//        let deltaX = point.x - center.x
//        let deltaY = point.y - center.y
//        return atan2(deltaY, deltaX)
//    }
//
//    private func updateSelectedValue(for ring: Int, with angleDifference: CGFloat) {
//        let angleRange: CGFloat = .pi * 0.6 // The same range used for drawing
//
//        switch ring {
//        case 0: // Years
//            let dataCount = CGFloat(years.count)
//            let currentAngle = calculateCurrentAngle(for: selectedYear, in: years, angleRange: angleRange)
//
//            let newAngle = currentAngle + angleDifference
//
//            var newIndex = Int(round((newAngle + angleRange/2) / angleRange * dataCount))
//            newIndex = max(0, min(newIndex, years.count - 1))
//
//            selectedYear = years[newIndex]
//        case 1: // Months
//            let dataCount = CGFloat(months.count)
//            let currentAngle = calculateCurrentAngle(for: selectedMonth, in: months, angleRange: angleRange)
//
//            let newAngle = currentAngle + angleDifference
//
//            var newIndex = Int(round((newAngle + angleRange/2) / angleRange * dataCount))
//            newIndex = max(0, min(newIndex, months.count - 1))
//            selectedMonth = months[newIndex]
//
//        case 2: // Days
//            let dataCount = CGFloat(days.count)
//            let currentAngle = calculateCurrentAngle(for: selectedDay, in: days, angleRange: angleRange)
//
//            let newAngle = currentAngle + angleDifference
//
//            var newIndex = Int(round((newAngle + angleRange/2) / angleRange * dataCount))
//            newIndex = max(0, min(newIndex, days.count - 1))
//            selectedDay = days[newIndex]
//
//        default:
//            break
//        }
//    }
//
//
//    private func calculateCurrentAngle<T: Equatable>(for value: T, in data: [T], angleRange: CGFloat) -> CGFloat {
//        guard let index = data.firstIndex(of: value) else { return 0 }
//        return CGFloat(index) / CGFloat(data.count) * angleRange - angleRange/2
//    }
//}



//// How to use in a UIViewController:
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let circularPicker = CircularPicker()
//        circularPicker.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(circularPicker)
//
//        // Set constraints (using Auto Layout)
//        NSLayoutConstraint.activate([
//            circularPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            circularPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            circularPicker.widthAnchor.constraint(equalToConstant: 300), // Adjust size as needed
//            circularPicker.heightAnchor.constraint(equalToConstant: 300) // Adjust size as needed
//        ])
//
//        circularPicker.backgroundColor = .black // Or any other background color
//    }
//}


//class CurvedPicker: UIView {
//
//    let pickerView: UIPickerView = {
//        let picker = UIPickerView()
//        picker.translatesAutoresizingMaskIntoConstraints = false
//        return picker
//    }()
//
//    private var data: [[String]] = [[]] // Placeholder for your data
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupView()
//    }
//
//    private func setupView() {
//        addSubview(pickerView)
//
//        // Set up constraints (using Auto Layout)
//        pickerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        pickerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        pickerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        pickerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//
//        pickerView.delegate = self
//        pickerView.dataSource = self
//
//        // Sample Data (Replace with your actual data)
//        data = [
//            ["1996", "1997", "1998", "1999", "2000"],
//            ["Sep", "Oct", "Nov", "Dec", "Jan"],
//            ["03", "04", "05", "06", "07"]
//        ]
//
//        applyCurve()
//    }
//
//    private func applyCurve() {
//        let radius: CGFloat = bounds.width * 0.75 // Adjust radius (using bounds for dynamic sizing)
//        let angle: CGFloat = .pi / 3  // Adjust angle (wider arc)
//
//        // 1. Apply Transform
//        let transform = CGAffineTransform(translationX: -radius, y: 0)
//            .rotated(by: -angle / 2)
//            .concatenating(CGAffineTransform(scaleX: 1, y: radius / pickerView.frame.height))
//
////        pickerView.transform = transform
//
//        // 2. Create Mask
//        let maskLayer = CAShapeLayer()
//        let path = UIBezierPath(arcCenter: CGPoint(x: 0, y: pickerView.frame.midY), radius: radius, startAngle: -angle / 2, endAngle: angle / 2, clockwise: true)
//        maskLayer.path = path.cgPath
//        maskLayer.fillColor = UIColor.black.cgColor
//        pickerView.layer.mask = maskLayer
//
//        // 3. Adjust Picker View Position
////        pickerView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
//        pickerView.frame.origin.x = radius
//        
//        
//        pickerView.layer.anchorPoint = CGPoint(x: 0, y: 0.5) // Anchor to the left edge (or center)
//        pickerView.frame.origin.x = radius
//        pickerView.transform = transform
//
//        clipsToBounds = true // Important: Clip the container
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        applyCurve() // Reapply curve on layout changes (e.g., rotation)
//    }
//}

// MARK: - UIPickerView Delegate and DataSource
//extension CurvedPicker: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return data.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return data[component].count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return data[component][row]
//    }
//
//    // ... (Optional: Implement pickerView:didSelectRow:forComponent: if needed)
//}
