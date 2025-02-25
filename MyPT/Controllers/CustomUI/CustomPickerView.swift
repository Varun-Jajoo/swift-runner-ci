//
//  CustomPickerView.swift
//  MyPT
//
//  Created by techsaga corp on 03/12/24.
//

import UIKit

class CustomPickerView: UIView {
    
    // Public property to access the calculated width
       var labelWidth: CGFloat {
           return calculatedWidth
       }
    
    var labelFont:UIFont = AppFont.semibold.size(25.0, familyName: familyClashDisplay) {
        didSet{
            return
        }
    }
    
    var labelColor: UIColor = UIColor.appWhite {
        didSet{
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
     //-------
    }
    
    // Setup the view
    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = true
        
        // Clear existing labels
        itemLabels.forEach { $0.removeFromSuperview() }
        itemLabels = []
            
        // Create labels for items
        for (index, item) in items.enumerated() {
            let label = UILabel()
            label.text = item
            label.font = labelFont //AppFont.semibold.size(25.0, familyName: familyClashDisplay)
            label.textAlignment = .center
            label.textColor = labelColor //UIColor.appWhite
            label.frame = CGRect(x: 0, y: CGFloat(index) * rowHeight, width: calculatedWidth + 5, height: rowHeight)
            addSubview(label)
            
            itemLabels.append(label)
        }
        
        scrollToRow(selectedRow, animated: false)
    }
    
    // Calculate the maximum width required for the labels

    private func calculateMaxLabelWidth(labelStr:String) -> CGFloat {
        let font = labelFont //AppFont.semibold.size(25.0, familyName: familyClashDisplay) // Example font
        let maxWidth = ((labelStr as NSString).boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40),
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil
        ).width)
        
        return maxWidth + 5 // Add padding
    }
        
    // Animate scrolling to a specific row
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
    
    // Update label positions based on the selected row
    private func updateViewForSelectedRow() {
        for (index, label) in itemLabels.enumerated() {
            let newYPosition = CGFloat(index) * rowHeight - contentOffset
            label.frame.origin.y = newYPosition
            
            // Change text color for the selected row
            if index == selectedRow {
                label.textColor = labelColor //UIColor.appWhite
            } else {
                label.textColor = labelColor //UIColor.appWhite
            }
            
            // Hide labels outside visible area
            label.isHidden = !(newYPosition >= 0 && newYPosition <= bounds.height)
        }
    }
}

/*
class CustomPickerView: UIView {
    enum ScrollDirection {
        case upToDown
        case downToUp
    }
    
    var scrollDirection: ScrollDirection = .upToDown
    
    // Public property to access the calculated width
       var labelWidth: CGFloat {
           return calculatedWidth
       }
    
    var labelFont:UIFont = AppFont.semibold.size(25.0, familyName: familyClashDisplay) {
        didSet{
            return
        }
    }
    
    var labelColor: UIColor = UIColor.appWhite {
        didSet{
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
     //-------
    }
    
    // Setup the view
    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = true
        
        // Clear existing labels
        itemLabels.forEach { $0.removeFromSuperview() }
        itemLabels = []
            
        // Create labels for items
        for (index, item) in items.enumerated() {
            let label = UILabel()
            label.text = item
            label.font = labelFont //AppFont.semibold.size(25.0, familyName: familyClashDisplay)
            label.textAlignment = .center
            label.textColor = labelColor //UIColor.appWhite
            label.frame = CGRect(x: 0, y: CGFloat(index) * rowHeight, width: calculatedWidth + 5, height: rowHeight)
            addSubview(label)
            
            itemLabels.append(label)
        }
        
        scrollToRow(selectedRow, animated: false)
    }
    
    // Calculate the maximum width required for the labels

    private func calculateMaxLabelWidth(labelStr:String) -> CGFloat {
        let font = labelFont //AppFont.semibold.size(25.0, familyName: familyClashDisplay) // Example font
        let maxWidth = ((labelStr as NSString).boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 40),
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil
        ).width)
        
        return maxWidth + 5 // Add padding
    }
        
    // Animate scrolling to a specific row
    func scrollToRow(_ row: Int, animated: Bool = true) {
        guard !isAnimating else { return }
        isAnimating = true
        
        calculatedWidth = calculateMaxLabelWidth(labelStr: items[row])
        frame.size.width = calculatedWidth
        itemLabels[row].frame.size.width = calculatedWidth
        
        
        // Prevent scrolling out of bounds
        selectedRow = max(0, min(row, items.count - 1))
        
        switch scrollDirection {
        case .upToDown:
            contentOffset = CGFloat(selectedRow) * rowHeight - (bounds.height / 2) + (rowHeight / 2)
        case .downToUp:
            contentOffset = CGFloat((items.count - 1 - selectedRow)) * rowHeight - (bounds.height / 2) + (rowHeight / 2)
        }
        
        // Animate label positions
        if animated {
            UIView.animate(withDuration: 0.4, animations: {
                self.updateViewForSelectedRow()
            }) { _ in
                self.isAnimating = false
            }
        } else {
            updateViewForSelectedRow()
            isAnimating = false
        }
    }
    
    // Update label positions based on the selected row
    private func updateViewForSelectedRow() {
        for (index, label) in itemLabels.enumerated() {
            var newYPosition: CGFloat
            
            switch scrollDirection {
            case .upToDown:
                newYPosition = CGFloat(index) * rowHeight - contentOffset
            case .downToUp:
                newYPosition = CGFloat((items.count - 1 - index)) * rowHeight - contentOffset
            }
            
            label.frame.origin.y = newYPosition
            // Change text color for the selected row
            label.textColor = (index == selectedRow) ? labelColor : labelColor.withAlphaComponent(0.5)
            // Hide labels outside visible area
            label.isHidden = !(newYPosition >= 0 && newYPosition <= bounds.height)
        }
    }
}
*/
 
