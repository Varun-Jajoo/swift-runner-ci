//
//  CustomGradientSlider.swift
//  MyPT
//
//  Created by techsaga corp on 24/07/25.
//

import UIKit

class CustomGradientSlider: UIView {
    
    private let slider = UISlider()
    private let tickContainer = UIView()

    var minimumValue: Float = 0 {
        didSet { slider.minimumValue = minimumValue }
    }

    var maximumValue: Float = 10 {
        didSet { slider.maximumValue = maximumValue }
    }

    var tickCount: Int = 11 {
        didSet {
            tickContainer.subviews.forEach { $0.removeFromSuperview() }
            setupTicks(count: tickCount)
        }
    }

    var onValueChanged: ((Float) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tickContainer.subviews.forEach { $0.removeFromSuperview() }
        setupTicks(count: tickCount)
    }
    
    private func setup() {
        backgroundColor = .clear
        setupSlider()
        setupTicks(count: tickCount)
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    @objc private func valueChanged() {
        onValueChanged?(slider.value)
    }

    private func setupSlider() {
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)

        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: topAnchor),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor),
            slider.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Thumb
        let thumbSize: CGFloat = 40
        let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize))
        thumbView.backgroundColor = .white
        thumbView.layer.cornerRadius = thumbSize / 2
        thumbView.layer.borderWidth = 6
        thumbView.layer.borderColor = UIColor.gray.cgColor

        let glow = CALayer()
        glow.backgroundColor = UIColor.green.cgColor
        glow.frame = CGRect(x: thumbSize / 2 - 1, y: -20, width: 2, height: thumbSize + 40)
        thumbView.layer.addSublayer(glow)

        let thumbImage = UIGraphicsImageRenderer(size: thumbView.bounds.size).image { ctx in
            thumbView.layer.render(in: ctx.cgContext)
        }
        slider.setThumbImage(thumbImage, for: .normal)

        // Track
        let gradientTrack = CAGradientLayer()
        gradientTrack.colors = [UIColor.systemGreen.cgColor, UIColor.lightGray.cgColor]
        gradientTrack.startPoint = CGPoint(x: 0, y: 0.5)
        gradientTrack.endPoint = CGPoint(x: 1, y: 0.5)
        gradientTrack.cornerRadius = 4
        let trackImage = image(from: gradientTrack, size: CGSize(width: 300, height: 8))
        slider.setMinimumTrackImage(trackImage, for: .normal)
        slider.setMaximumTrackImage(trackImage, for: .normal)
    }

    private func setupTicks(count: Int) {
        tickContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tickContainer)

        NSLayoutConstraint.activate([
            tickContainer.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 8),
            tickContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            tickContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            tickContainer.heightAnchor.constraint(equalToConstant: 10),
            tickContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        for i in 0..<count {
            let tick = UIView()
            tick.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            tick.translatesAutoresizingMaskIntoConstraints = false
            tickContainer.addSubview(tick)

            let xPos = CGFloat(i) / CGFloat(count - 1)
            NSLayoutConstraint.activate([
                tick.widthAnchor.constraint(equalToConstant: 1),
                tick.heightAnchor.constraint(equalToConstant: 8),
                tick.bottomAnchor.constraint(equalTo: tickContainer.bottomAnchor),
                tick.leadingAnchor.constraint(equalTo: tickContainer.leadingAnchor, constant: xPos * bounds.width)
            ])
        }
    }

    private func image(from layer: CALayer, size: CGSize) -> UIImage {
        layer.frame = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image.resizableImage(withCapInsets: .zero)
    }
}


/*
 class CustomGradientSlider: UIView {
     
     private let slider = UISlider()
     private let tickContainer = UIView()
     
     var value: Float {
         get { slider.value }
         set { slider.value = newValue }
     }
     
     var minimumValue: Float {
         get { slider.minimumValue }
         set { slider.minimumValue = newValue }
     }
     
     var maximumValue: Float {
         get { slider.maximumValue }
         set { slider.maximumValue = newValue }
     }
     
     var onValueChanged: ((Float) -> Void)?
     
     init(min: Float = 0, max: Float = 10, ticks: Int = 11) {
         super.init(frame: .zero)
         slider.minimumValue = min
         slider.maximumValue = max
         setupSlider()
         setupTicks(count: ticks)
         slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         setupSlider()
         setupTicks(count: 11)
         slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
     }

     @objc private func valueChanged() {
         onValueChanged?(slider.value)
     }
     
     private func setupSlider() {
         let thumbSize: CGFloat = 40
         let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize))
         thumbView.backgroundColor = .white
         thumbView.layer.cornerRadius = thumbSize / 2
         thumbView.layer.borderWidth = 6
         thumbView.layer.borderColor = UIColor.gray.cgColor
         
         let glow = CALayer()
         glow.backgroundColor = UIColor.green.cgColor
         glow.frame = CGRect(x: thumbSize / 2 - 1, y: -20, width: 2, height: thumbSize + 40)
         thumbView.layer.addSublayer(glow)
         
         let thumbImage = UIGraphicsImageRenderer(size: thumbView.bounds.size).image { ctx in
             thumbView.layer.render(in: ctx.cgContext)
         }
         slider.setThumbImage(thumbImage, for: .normal)

         let gradientTrack = CAGradientLayer()
         gradientTrack.colors = [UIColor.systemGreen.cgColor, UIColor.lightGray.cgColor]
         gradientTrack.startPoint = CGPoint(x: 0, y: 0.5)
         gradientTrack.endPoint = CGPoint(x: 1, y: 0.5)
         gradientTrack.cornerRadius = 4
         let trackImage = image(from: gradientTrack, size: CGSize(width: 300, height: 8))
         
         slider.setMinimumTrackImage(trackImage, for: .normal)
         slider.setMaximumTrackImage(trackImage, for: .normal)
         
         slider.translatesAutoresizingMaskIntoConstraints = false
         addSubview(slider)
         NSLayoutConstraint.activate([
             slider.topAnchor.constraint(equalTo: topAnchor),
             slider.leadingAnchor.constraint(equalTo: leadingAnchor),
             slider.trailingAnchor.constraint(equalTo: trailingAnchor),
             slider.heightAnchor.constraint(equalToConstant: 40)
         ])
     }
     
     private func setupTicks(count: Int) {
         tickContainer.translatesAutoresizingMaskIntoConstraints = false
         addSubview(tickContainer)
         NSLayoutConstraint.activate([
             tickContainer.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 8),
             tickContainer.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
             tickContainer.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
             tickContainer.heightAnchor.constraint(equalToConstant: 10),
             tickContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
         ])
         
         for i in 0..<count {
             let tick = UIView()
             tick.backgroundColor = UIColor.white.withAlphaComponent(0.2)
             tick.translatesAutoresizingMaskIntoConstraints = false
             tickContainer.addSubview(tick)
             
             let xPos = CGFloat(i) / CGFloat(count - 1)
             NSLayoutConstraint.activate([
                 tick.widthAnchor.constraint(equalToConstant: 1),
                 tick.heightAnchor.constraint(equalToConstant: 8),
                 tick.bottomAnchor.constraint(equalTo: tickContainer.bottomAnchor),
                 tick.leadingAnchor.constraint(equalTo: tickContainer.leadingAnchor, constant: xPos * 300)
             ])
         }
     }
     
     private func image(from layer: CALayer, size: CGSize) -> UIImage {
         layer.frame = CGRect(origin: .zero, size: size)
         UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
         layer.render(in: UIGraphicsGetCurrentContext()!)
         let image = UIGraphicsGetImageFromCurrentImageContext()!
         UIGraphicsEndImageContext()
         return image.resizableImage(withCapInsets: .zero)
     }
 }
 */
