//
//  VerticalProgressBar.swift
//  MyPT
//
//  Created by techsaga corp on 20/08/25.
//

import UIKit

class VerticalProgressBar: UIView {
    var unitTxt: String = "Kcal"
    
    private let trackLayer = UIView()
    private let progressLayer = UIView()
    private let gradientLayer = CAGradientLayer()
    private let progressLabel = UILabel()
    
    /// Progress value between 0.0 and 1.0
    var progress: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }
    
    /// Gradient colors
    var gradientColors: [UIColor] = [UIColor.systemPurple, UIColor.systemBlue] {
        didSet {
            gradientLayer.colors = gradientColors.map { $0.cgColor }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        clipsToBounds = false
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        // Track background (dark striped)
        trackLayer.backgroundColor = UIColor(white: 0.15, alpha: 1)
        trackLayer.clipsToBounds = true
        addSubview(trackLayer)
        
        // Progress layer container
        progressLayer.clipsToBounds = true
        addSubview(progressLayer)
        
        // Gradient fill
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        progressLayer.layer.addSublayer(gradientLayer)
        
        // Label
        progressLabel.textAlignment = .center
        progressLabel.textColor = UIColor.appWhite
        progressLabel.font = UIFont.boldSystemFont(ofSize: 18)
        progressLayer.addSubview(progressLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackLayer.frame = bounds
        updateProgress()
        self.gradientImg()
    }
    
    private func updateProgress() {
        // Ensure progress is never less than 0.2
        let effectiveProgress = max(progress, 0.2)

        let height = bounds.height * effectiveProgress
        
        progressLayer.frame = CGRect(
            x: 0,
            y: bounds.height - height,
            width: bounds.width,
            height: height
        )
        
        gradientLayer.frame = progressLayer.bounds
        
        // Rounded top corners only
        progressLayer.layer.cornerRadius = 16
        progressLayer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Update label position and text
        progressLabel.text = "\(Int(progress * 100)) \(unitTxt)"
        progressLabel.frame = progressLayer.bounds
    }
    
    private func gradientImg(){
        
        let bottomImageView = UIImageView()
        bottomImageView.image = UIImage(named: "ic_horizontalBarLine")
        bottomImageView.contentMode = .scaleAspectFill
        bottomImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add imageView to main view
        self.trackLayer.addSubview(bottomImageView)
        
        // Add constraints
        NSLayoutConstraint.activate([
            bottomImageView.leadingAnchor.constraint(equalTo: self.trackLayer.leadingAnchor),
            bottomImageView.trailingAnchor.constraint(equalTo: self.trackLayer.trailingAnchor),
            bottomImageView.bottomAnchor.constraint(equalTo: self.trackLayer.safeAreaLayoutGuide.bottomAnchor),
            bottomImageView.heightAnchor.constraint(equalTo: self.trackLayer.heightAnchor, multiplier: 1.0)
        ])
    }
    
//    private func updateProgress() {
//        let height = bounds.height * progress
//
//        progressLayer.frame = CGRect(
//            x: 0,
//            y: bounds.height - height,
//            width: bounds.width,
//            height: height
//        )
//        
//        gradientLayer.frame = progressLayer.bounds
//        // Rounded top corners only
//        progressLayer.layer.cornerRadius = 16
//        progressLayer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        
//        // Update label position and text
//        progressLabel.text = "\(Int(progress * 100))" + " " + unitTxt
//        progressLabel.frame = progressLayer.bounds
//    }
}



