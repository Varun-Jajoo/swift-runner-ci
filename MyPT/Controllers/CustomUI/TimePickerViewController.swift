//
//  CustomDatePickerViewController.swift
//  MyPT
//
//  Created by techsaga corp on 06/09/25.
//

import UIKit


class TimePickerViewController: UIViewController {

    var sentTime: ((_ selectedTime: String?) -> Void)?
    
    private var selectedTime: String?
    //----------
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
        
    private let selectedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Selected Time"
        label.textColor = UIColor.lightGray.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorLine: UIView = {
        let linV = UIView()
        linV.backgroundColor = UIColor.gray
        return linV
    }()
    
    private let doneBtn: UIButton = {
        let doneB = UIButton()
        doneB.setTitle("Done", for: .normal)
        doneB.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        doneB.setTitleColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
        doneB.backgroundColor = UIColor.clear
        return doneB
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        pickerView.dataSource = self
        pickerView.delegate = self
        setupUI()
        
        // Add target to detect time change
//        timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)
        doneBtn.addTarget(self, action: #selector(doneBtnAtcn(_: )), for: .touchUpInside)
    }
    
    private func setupUI() {
        // 1. Add subviews to the hierarchy first
        view.addSubview(selectedTimeLabel)
        view.addSubview(pickerView)
        view.addSubview(separatorLine)
        view.addSubview(doneBtn)

        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        selectedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        // 2. Now apply constraints
        NSLayoutConstraint.activate([
            selectedTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            selectedTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectedTimeLabel.heightAnchor.constraint(equalToConstant: 30),
            pickerView.topAnchor.constraint(equalTo: selectedTimeLabel.bottomAnchor, constant: 12),
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 130),
            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            separatorLine.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor, constant: 20),
            separatorLine.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor, constant: -20),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            doneBtn.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            doneBtn.leadingAnchor.constraint(equalTo: separatorLine.leadingAnchor, constant: 20),
            doneBtn.trailingAnchor.constraint(equalTo: separatorLine.trailingAnchor, constant: -20),
            doneBtn.heightAnchor.constraint(equalToConstant: 40),
            doneBtn.centerXAnchor.constraint(equalTo: separatorLine.centerXAnchor),
            doneBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    @objc private func doneBtnAtcn(_ sender: UIButton){
        if let selectedTime = self.selectedTime {
            self.dismiss(animated: true, completion: {
                    self.sentTime?(selectedTime)
            })
        }else{
            AlertHelper.shared.showCustomeAlert(message: "Please select time.")
        }
    }
    
//    @objc private func timeChanged(_ sender: UIDatePicker) {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short // e.g. "3:45 PM"
////        selectedTimeLabel.text = "Selected Time: \(formatter.string(from: sender.date))"
//    }
}

// MARK: - UIPickerViewDataSource
extension TimePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // Minutes + Seconds
    }
    
    func TimePickerViewController(in pickerView: UIPickerView) -> Int {
        return 2 // minutes + seconds
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 60 : 60 // 0–59 minutes, 0–59 seconds
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? "\(row) min" : "\(row) sec"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let minutes = pickerView.selectedRow(inComponent: 0)
        let seconds = pickerView.selectedRow(inComponent: 1)
        self.selectedTime = "\(minutes):\(seconds)"
    }
}
