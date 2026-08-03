//
//  GradientProgressBar.swift
//  MyPT
//
//  Created by Pratham Gupta on 17/02/26.
//

import Foundation

import UIKit

final class GradientProgressBar: UIView {
    
    private let backgroundView = UIView()
    private let progressView = UIView()
    private let gradientLayer = CAGradientLayer()
    
    var total: CGFloat = 100
    private var currentProgress: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        
        // Unfilled background
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        addSubview(backgroundView)
        
        // Progress view
        backgroundView.addSubview(progressView)
        
        // Gradient
        gradientLayer.colors = [
            UIColor(red: 181/255, green: 140/255, blue: 70/255, alpha: 1).cgColor,
            UIColor(red: 243/255, green: 215/255, blue: 149/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        progressView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Shadow
        progressView.layer.shadowColor = UIColor(red: 237/255, green: 208/255, blue: 142/255, alpha: 1).cgColor
        progressView.layer.shadowOpacity = 0.8
        progressView.layer.shadowRadius = 4
        progressView.layer.shadowOffset = .zero
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = bounds.height / 2
        
        let width = total > 0 ? (currentProgress / total) * bounds.width : 0
        progressView.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        
        progressView.layer.cornerRadius = bounds.height / 2
        gradientLayer.frame = progressView.bounds
        gradientLayer.cornerRadius = bounds.height / 2
    }
    
    func setProgress(_ value: CGFloat) {
        currentProgress = min(max(value, 0), total)
        setNeedsLayout()
    }
}
