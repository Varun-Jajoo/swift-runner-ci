//
//  CustomTimePickerView.swift
//  MyPT
//
//  Created by Pratham Gupta on 14/03/26.
//

import Foundation
import UIKit

class CustomTimePickerView: UIView {

    private let picker = UIPickerView()
    
    private let selectedColor = UIColor(hex: "#E0FE08")
    private let unselectedColor = UIColor.white.withAlphaComponent(0.35)
    
    private let hours = Array(0...23)
//    private let minutes = Array(0...59)
//    private let minutes = Array(0...30)
    private let minutes = [0, 30]
    
    private let leftHighlight = UIView()
    private let rightHighlight = UIView()
    
    var onTimeChange: ((String) -> Void)?
    
    private let colonLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
//        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        label.textColor = UIColor(red: 255/250, green: 255/250, blue: 255/250, alpha: 0.2)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPicker()
        setupHighlightView()
        setupInitialSelection()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPicker()
        setupHighlightView()
        setupInitialSelection()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionHighlightViews()
    }
}

// MARK: Setup
extension CustomTimePickerView {
    
    private func setupPicker() {
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(picker)
        addSubview(colonLabel)
        
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: topAnchor),
            picker.bottomAnchor.constraint(equalTo: bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        picker.subviews.forEach { $0.isHidden = true }
    }
    
//    private func setupHighlightView() {
//        
//        [leftHighlight, rightHighlight].forEach {
//            $0.layer.cornerRadius = 16
//            $0.layer.borderWidth = 0.3
//            $0.layer.borderColor = selectedColor.cgColor
//            $0.backgroundColor = selectedColor.withAlphaComponent(0.08)
//            addSubview($0)
//        }
//    }
    
    private func setupHighlightView() {
            [leftHighlight, rightHighlight].forEach {
                $0.layer.cornerRadius = 16
                $0.layer.borderWidth = 0.3
                $0.layer.borderColor = selectedColor.cgColor
                $0.backgroundColor = selectedColor.withAlphaComponent(0.08)
                $0.isUserInteractionEnabled = false   // ✅ IMPORTANT FIX
                addSubview($0)
            }
        }
    
    private func positionHighlightViews() {
        
        let rowHeight: CGFloat = 48
        let boxWidth: CGFloat = 80
        let spacing: CGFloat = 12
        
        colonLabel.sizeToFit()
        
        let totalWidth = boxWidth + spacing + colonLabel.bounds.width + spacing + boxWidth
        let startX = bounds.midX - totalWidth / 2
        
        let centerY = bounds.midY
        
        leftHighlight.frame = CGRect(
            x: startX,
            y: centerY - rowHeight / 2,
            width: boxWidth,
            height: rowHeight
        )
        
        colonLabel.frame = CGRect(
            x: leftHighlight.frame.maxX + spacing,
            y: centerY - colonLabel.bounds.height / 2,
            width: colonLabel.bounds.width,
            height: colonLabel.bounds.height
        )
        
        rightHighlight.frame = CGRect(
            x: colonLabel.frame.maxX + spacing,
            y: centerY - rowHeight / 2,
            width: boxWidth,
            height: rowHeight
        )
    }
    
    private func setupInitialSelection() {
        picker.selectRow(9, inComponent: 0, animated: false)
        picker.selectRow(0, inComponent: 1, animated: false)
        updateTime()
    }
    
    private func updateTime() {
        let hour = hours[picker.selectedRow(inComponent: 0)]
        let minute = minutes[picker.selectedRow(inComponent: 1)]
        
        let time = String(format: "%02d:%02d", hour, minute)
        onTimeChange?(time)
    }
}

extension CustomTimePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? hours.count : minutes.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    rowHeightForComponent component: Int) -> CGFloat {
        48
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    widthForComponent component: Int) -> CGFloat {
        100
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = AppFont.medium.size(22.0, familyName: familyFunnelSans)
        
        if component == 0 {
            label.text = String(format: "%02d", hours[row])
        } else {
            label.text = String(format: "%02d", minutes[row])
        }
        
        let selectedRow = pickerView.selectedRow(inComponent: component)
        
        label.textColor = (row == selectedRow)
        ? selectedColor
        : unselectedColor
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        pickerView.reloadAllComponents()
        updateTime()
    }
    
    func setTime(_ time: String) {
        
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else { return }
        
        // Find index in arrays
        if let hourIndex = hours.firstIndex(of: hour),
           let minuteIndex = minutes.firstIndex(of: minute) {
            
            picker.selectRow(hourIndex, inComponent: 0, animated: true)
            picker.selectRow(minuteIndex, inComponent: 1, animated: true)
            
            // update UI
            picker.reloadAllComponents()
            updateTime()
        }
    }
}
