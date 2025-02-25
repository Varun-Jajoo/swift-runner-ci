//
//  RoundProgressView.swift
//  MyPT
//
//  Created by techsaga corp on 15/01/25.
//

import UIKit


/*  usese of dual progress bar
 let dualProgressView = DualRoundProgressView()
 dualProgressView.frame = CGRect(x: 50, y: 300, width: 250, height: 250)
 dualProgressView.outerLineWidth = 10
 dualProgressView.outerSpace = 10.0
 dualProgressView.innerLineWidth = 8
 dualProgressView.outerCornerRadius = 51.94
 dualProgressView.innerCornerRadius = 51.94
 dualProgressView.outerColor = .red
 dualProgressView.innerColor = .blue
 dualProgressView.centerImage = UIImage(named: "ic_activeChallanges") // Replace with your image name
 dualProgressView.centerImageSize = CGSize(width: 160, height: 160)
 dualProgressView.imageCornerRadius = 37.61
 // Set initial progress
 dualProgressView.outerProgress = 0.8
 dualProgressView.innerProgress = 0.4
 dualProgressView.outerTrackColor = UIColor.gray
 dualProgressView.innerTrackColor = UIColor.gray
 
 view.addSubview(dualProgressView)
 
 // Animate progress after a delay
 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
     dualProgressView.outerProgress = 0.9
     dualProgressView.innerProgress = 0.7
 }
 */

class DualRoundProgressView: UIView {
    private let outerProgressView = RoundProgressView()
    private let innerProgressView = RoundProgressView()
    private let centerImageView = UIImageView()
    
    // MARK: - Properties
    var outerProgress: CGFloat = 0 {
        didSet {
            outerProgressView.setProgress(outerProgress, animated: true)
        }
    }
    
    var innerProgress: CGFloat = 0 {
        didSet {
            innerProgressView.setProgress(innerProgress, animated: true)
        }
    }
    
    var outerSpace: CGFloat = 4 {
        didSet {
            return
        }
    }
    
    var outerLineWidth: CGFloat = 10 {
        didSet {
            outerProgressView.lineWidth = outerLineWidth
            setNeedsLayout()
        }
    }
    
    var innerLineWidth: CGFloat = 6 {
        didSet {
            innerProgressView.lineWidth = innerLineWidth
            setNeedsLayout()
        }
    }
    
    var outerCornerRadius: CGFloat = 20 {
        didSet {
            outerProgressView.cornerRadius = outerCornerRadius
            setNeedsLayout()
        }
    }
    
    var imageCornerRadius: CGFloat = 20 {
        didSet {
            centerImageView.layer.cornerRadius = imageCornerRadius
            centerImageView.layer.masksToBounds = true
            setNeedsLayout()
        }
    }
    
    var innerCornerRadius: CGFloat = 20 {
        didSet {
            innerProgressView.cornerRadius = innerCornerRadius
            setNeedsLayout()
        }
    }
    
    var outerColor: UIColor = .blue {
        didSet {
            outerProgressView.setStrokeColor = outerColor
        }
    }
    
    var innerColor: UIColor = .green {
        didSet {
            innerProgressView.setStrokeColor = innerColor
        }
    }
    
    var outerTrackColor: UIColor = .gray {
        didSet {
            outerProgressView.trackColor = outerTrackColor
        }
    }
    
    var innerTrackColor: UIColor = .gray {
        didSet {
            innerProgressView.trackColor = innerTrackColor
        }
    }
    
    var centerImage: UIImage? {
        didSet {
            centerImageView.image = centerImage
        }
    }
    
    var centerImageSize: CGSize = CGSize(width: 50, height: 50) {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        // Add outer progress view
        outerProgressView.trackColor = .lightGray
        outerProgressView.setFillColor = .clear
        addSubview(outerProgressView)
        
        // Add inner progress view
        innerProgressView.trackColor = .lightGray
        innerProgressView.setFillColor = .clear
        addSubview(innerProgressView)
        
        // Add center image view
        centerImageView.contentMode = .scaleAspectFit
        addSubview(centerImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Layout outer and inner progress views
        let outerInset: CGFloat = 0 // No inset for outer
        outerProgressView.frame = bounds.insetBy(dx: outerInset, dy: outerInset)
        
        let innerInset: CGFloat = outerLineWidth + outerSpace //10 // Space between outer and inner
        innerProgressView.frame = bounds.insetBy(dx: innerInset, dy: innerInset)
        
        // Layout center image view
        centerImageView.frame = CGRect(
            x: (bounds.width - centerImageSize.width) / 2,
            y: (bounds.height - centerImageSize.height) / 2,
            width: centerImageSize.width,
            height: centerImageSize.height
        )
    }
}


/* uses for single progress bar --------
 
 let progressView = RoundProgressView()
 progressView.frame = CGRect(x: 50, y: 100, width: 200, height: 200)
 progressView.trackColor = .lightGray
 progressView.setStrokeColor = .blue
 progressView.setFillColor = .clear
 progressView.lineWidth = 15
 progressView.progress = 0 // Initial progress
 progressView.cornerRadius = 20.0
 
 view.addSubview(progressView)
 
 // Animate to 80% progress after 2 seconds
 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
     progressView.setProgress(0.8, animated: false)
 }
 */

//MARK: ------------------FINALE SETUP
class RoundProgressView: UIView {
    // MARK: - Properties
    var cornerRadius: CGFloat = 20 {
        didSet {
            return
        }
    }
    
    var lineWidth: CGFloat = 6 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }
    var setFillColor: UIColor = .clear {
        didSet {
            trackLayer.fillColor = setFillColor.cgColor
            progressLayer.fillColor = setFillColor.cgColor
        }
    }
    var setStrokeColor: UIColor = .green {
        didSet {
            progressLayer.strokeColor = setStrokeColor.cgColor
        }
    }
    
    var trackColor: UIColor = .lightGray {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            let clampedValue = max(0, min(1, progress))
            progressLayer.strokeEnd = clampedValue
        }
    }
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    // MARK: - Setup Layers
    private func setupLayers() {
        trackLayer.lineCap = .round
        trackLayer.lineWidth = lineWidth
        trackLayer.fillColor = setFillColor.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.strokeEnd = 1
        layer.addSublayer(trackLayer)
        
        progressLayer.lineCap = .round
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = setFillColor.cgColor
        progressLayer.strokeColor = setStrokeColor.cgColor
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
        
        trackLayer.path = path
        trackLayer.frame = bounds
        
        progressLayer.path = path
        progressLayer.frame = bounds
    }
    
    // MARK: - Helper Functions
    func setProgress(_ value: CGFloat, animated: Bool) {
        let clampedValue = max(0, min(1, value))
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = clampedValue
            animation.duration = 0.5
            progressLayer.add(animation, forKey: "progressAnimation")
        }
        progressLayer.strokeEnd = clampedValue
        progress = clampedValue
    }
}

