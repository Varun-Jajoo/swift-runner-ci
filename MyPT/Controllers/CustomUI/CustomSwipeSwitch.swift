//
//  CustomSwipeSwitch.swift
//  MyPT
//
//  Created by techsaga corp on 29/04/25.
//

import UIKit

class CustomSwipeSwitch: UIView {
    
    private let knob = UIView()
    private var isOn = false
    
    /// Public property to access or set selected state
    var isSelected: Bool {
        get { isOn }
        set { setOn(newValue, animated: true) }
    }
    
    // Callback when state changes (like button action)
    var onToggle: ((Bool) -> Void)?
    
    //    var selectedColor: UIColor? = UIColor.appYellow
    //    var deSelectedColor: UIColor? = UIColor.appYellow
    
    var selectedColor: UIColor? = UIColor.appYellow{
        didSet{
            toggle(to: isSelected, notify: false, animated: true)
        }
    }
    
    var deSelectedColor: UIColor? = UIColor.appYellow{
        didSet{
            toggle(to: isSelected, notify: false, animated: true)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        addGestureRecognizers()
    }
    
    private func setupView() {
        self.backgroundColor = deSelectedColor
        self.layer.cornerRadius = 10.0
        
        // Knob
        let knobSize = self.frame.height - 8
        knob.frame = CGRect(x: 4, y: 4, width: knobSize, height: knobSize)
        knob.backgroundColor = .white
        knob.layer.cornerRadius = 8.0
        knob.layer.shadowColor = UIColor.black.cgColor
        knob.layer.shadowOpacity = 0.4
        knob.layer.shadowOffset = CGSize(width: 0, height: 2)
        knob.layer.shadowRadius = 4
        self.addSubview(knob)
    }
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSwitch))
        self.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        knob.addGestureRecognizer(pan)
        knob.isUserInteractionEnabled = true
    }
    
    @objc private func toggleSwitch() {
        toggle(to: !isOn, notify: true)  // notify only on user action
    }
    
    /// Programmatic control (no callback by default)
    func setOn(_ state: Bool, animated: Bool) {
        toggle(to: state, notify: false, animated: animated)
    }
    
    private func toggle(to state: Bool, notify: Bool, animated: Bool = true) {
        isOn = state
        let knobX = isOn ? frame.width - knob.frame.width - 4 : 4
        
        let animations = {
            self.knob.frame.origin.x = knobX
            self.backgroundColor = self.isOn ? self.selectedColor : self.deSelectedColor
        }
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseInOut],
                           animations: animations,
                           completion: { _ in
                if notify { self.onToggle?(self.isOn) }
            })
        } else {
            animations()
            if notify { self.onToggle?(self.isOn) }
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let minX: CGFloat = 4
        let maxX = self.frame.width - knob.frame.width - 4
        var newX = knob.frame.origin.x + translation.x
        newX = max(minX, min(newX, maxX))
        
        switch gesture.state {
        case .changed:
            knob.frame.origin.x = newX
            gesture.setTranslation(.zero, in: self)
        case .ended:
            let velocity = gesture.velocity(in: self)
            if velocity.x > 0 {
                toggle(to: true, notify: true)
            } else if velocity.x < 0 {
                toggle(to: false, notify: true)
            } else {
                let midpoint = self.frame.width / 2
                toggle(to: knob.center.x > midpoint, notify: true)
            }
        default:
            break
        }
    }
}


//class CustomSwipeSwitch: UIView {
//    
//    private let knob = UIView()
////    private var isOn = false
//    
//    private var isOn = false {
//        didSet {
////            updateUI(animated: true)
//            onToggle?(isOn)
//        }
//    }
//    /// Public property to access or set selected state
//    var isSelected: Bool {
//        get { isOn }
//        set { toggle(to: newValue) }
//    }
//    
//    
//    var isStateChanged: Bool = false {
//        didSet{
//            stateChanged(to: isStateChanged)
//        }
//    }
//    
//    // Callback when state changes
//    var onToggle: ((Bool) -> Void)?
//    
//    var selectedColor: UIColor? = UIColor.appYellow{
//        didSet{
////            if let isSelected = isSelected {
//                toggle(to: isSelected)
////            }
//        }
//    }
//    
//    var deSelectedColor: UIColor? = UIColor.appYellow{
//        didSet{
////            if let isSelected = isSelected {
//                toggle(to: isSelected)
////            }
//        }
//    }
//    
////    var isSelected: Bool? = false{
////        didSet{
////            if let isSelected = isSelected {
////                toggle(to: isSelected)
////            }
////        }
////    }
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//        addGestureRecognizers()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//        addGestureRecognizers()
//    }
//    
//    private func setupView() {
//        self.backgroundColor = selectedColor
//        self.layer.cornerRadius = 10.0 //self.frame.height / 2
//        self.clipsToBounds = false
//        
//        // Knob
//        let knobSize = self.frame.height - 8
//        knob.frame = CGRect(x: 4, y: 4, width: knobSize, height: knobSize)
//        knob.backgroundColor = .white
//        knob.layer.cornerRadius = 8.0
//        knob.layer.shadowColor = UIColor.black.cgColor
//        knob.layer.shadowOpacity = 0.4
//        knob.layer.shadowOffset = CGSize(width: 0, height: 2)
//        knob.layer.shadowRadius = 4
//        knob.layer.masksToBounds = false
//        self.addSubview(knob)
//    }
//    
//    private func addGestureRecognizers() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSwitch))
//        self.addGestureRecognizer(tap)
//        
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        knob.addGestureRecognizer(pan)
//        knob.isUserInteractionEnabled = true
//    }
//    
//    @objc private func toggleSwitch() {
//        toggle(to: !isOn)
//    }
//    
//    private func stateChanged(to state: Bool) {
//        let knobX = state ? self.frame.width - knob.frame.width - 4 : 4
//        UIView.animate(withDuration: 0.25,
//                       delay: 0,
//                       usingSpringWithDamping: 0.7,
//                       initialSpringVelocity: 0.5,
//                       options: [.curveEaseInOut],
//                       animations: {
//            self.knob.frame.origin.x = knobX
//            self.backgroundColor = state ? self.selectedColor : self.deSelectedColor
//        }, completion: nil)
//    }
//    
////    private func toggle(to state: Bool) {
////        isOn = state
////        let knobX = isOn ? self.frame.width - knob.frame.width - 4 : 4
////        UIView.animate(withDuration: 0.25,
////                       delay: 0,
////                       usingSpringWithDamping: 0.7,
////                       initialSpringVelocity: 0.5,
////                       options: [.curveEaseInOut],
////                       animations: {
////            self.knob.frame.origin.x = knobX
////            self.backgroundColor = self.isOn ? self.selectedColor : self.deSelectedColor
////        }, completion: nil)
////        onToggle?(isOn)
////    }
//    
//    private func toggle(to state: Bool, notify: Bool = true) {
//        isOn = state
//        let knobX = isOn ? frame.width - knob.frame.width - 4 : 4
//        
//        UIView.animate(withDuration: 0.25,
//                       delay: 0,
//                       usingSpringWithDamping: 0.7,
//                       initialSpringVelocity: 0.5,
//                       options: [.curveEaseInOut],
//                       animations: {
//            self.knob.frame.origin.x = knobX
//            self.backgroundColor = self.isOn ? self.selectedColor : self.deSelectedColor
//        }, completion: { _ in
//            if notify { self.onToggle?(self.isOn) }
//        })
//    }
//
//    
//    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self)
//        let minX: CGFloat = 4
//        let maxX = self.frame.width - knob.frame.width - 4
//        var newX = knob.frame.origin.x + translation.x
//        newX = max(minX, min(newX, maxX))
//        
//        switch gesture.state {
//        case .changed:
//            knob.frame.origin.x = newX
//            gesture.setTranslation(.zero, in: self)
//        case .ended:
//            // Decide direction
//            let velocity = gesture.velocity(in: self)
//            if velocity.x > 0 {
//                toggle(to: true)  // Swiped right → ON
//            } else if velocity.x < 0 {
//                toggle(to: false) // Swiped left → OFF
//            } else {
//                // Snap based on midpoint
//                let midpoint = self.frame.width / 2
//                toggle(to: knob.center.x > midpoint)
//            }
//        default:
//            break
//        }
//    }
//}



