//
//  GaugeView.swift
//  MyPT
//
//  Created by techsaga corp on 27/06/25.
//

import UIKit

//MARK: ----------------- Gauge Container View
class GaugeContainerView: UIView {

    var progressStr: String? = nil{
        didSet{
            if let progressStr = progressStr {
                progrssImg.isHidden = true
                desirableLabel.isHidden = false
                desirableLabel.text = progressStr
                self.setNeedsLayout()
            }
        }
    }
    
    var progressStrFont: UIFont? = UIFont.systemFont(ofSize: 12.0, weight: .semibold){
        didSet{
            if let progressStrFont = progressStrFont {
                desirableLabel.font = progressStrFont
                self.setNeedsLayout()
            }
        }
    }
    
    var progressStrColor: UIColor? = UIColor(red: 0.7, green: 1.0, blue: 0.4, alpha: 1.0){
        didSet{
            if let progressStrColor = progressStrColor {
                desirableLabel.textColor = progressStrColor
                self.setNeedsLayout()
            }
        }
    }
    
    var progressImg: UIImage? = nil{
        didSet{
            if let progressImg = progressImg {
                progrssImg.isHidden = false
                desirableLabel.isHidden = true
                progrssImg.image = progressImg
                self.setNeedsLayout()
            }
        }
    }
    
    //MARK: --------------------- GAUGE VIEW SETUP
    private let gaugeView = GaugeView()
    private let desirableLabel = UILabel()
    private let progrssImg = UIImageView()
    
    var showTicks: Bool = true {
        didSet {
            gaugeView.showTicks = showTicks
            setNeedsLayout()
        }
    }
    
    var gaugeThickness: CGFloat = 15.0 { didSet {
        gaugeView.gaugeThickness = gaugeThickness
        setNeedsLayout()
    }
    }
    
//    var gaugeColorStart: UIColor = UIColor(red: 63/255, green: 216/255, blue: 48/255, alpha: 1) {
//        didSet {
////            gaugeView.gaugeColorStart = gaugeColorStart
//            setNeedsLayout()
//        }
//    }
//    var gaugeColorEnd: UIColor = UIColor(red: 42/255, green: 23/255, blue: 11/255, alpha: 1) {
//        didSet {
////            gaugeView.gaugeColorEnd = gaugeColorEnd
//            setNeedsLayout()
//        }
//    }
    
    var progersColor: [CGColor] =
    [
        UIColor(red: 63.0/255.0, green: 216.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 167.0/255.0, green: 224.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 250.0/255.0, green: 206.0/255.0, blue: 52.0/255.0, alpha: 1.0).cgColor,
        UIColor(red: 255.0/255.0, green: 85.0/255.0, blue: 99.0/255.0, alpha: 1.0).cgColor
    ]
    {
        didSet
        {
            gaugeView.gaugeProgersColor = progersColor
            setNeedsLayout()
        }
    }
    
    var trackColor: UIColor = UIColor(red: 42/255, green: 23/255, blue: 11/255, alpha: 1) {
        didSet {
            gaugeView.trackColor = trackColor
            setNeedsLayout()
        }
    }

    var tickStrokeColor: UIColor = UIColor(red: 71/255, green: 77/255, blue: 96/255, alpha: 0.8) {
        didSet {
            gaugeView.tickStrokeColor = tickStrokeColor
            
            setNeedsLayout()
        }
    }
    
    var tickTrackStrokeColor: UIColor = UIColor(red: 71/255, green: 77/255, blue: 96/255, alpha: 0.7) { didSet {
        gaugeView.tickTrackStrokeColor = tickTrackStrokeColor
        setNeedsLayout()
      }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        layer.masksToBounds = true
        addGaugeView()
        setupLabel()
        setupImge()
    }
    
    private func addGaugeView() {
        gaugeView.translatesAutoresizingMaskIntoConstraints = false
        gaugeView.backgroundColor = UIColor.clear
        addSubview(gaugeView)

        NSLayoutConstraint.activate([
            gaugeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gaugeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gaugeView.heightAnchor.constraint(equalTo: heightAnchor),
            gaugeView.topAnchor.constraint(equalTo: topAnchor, constant: 1)
        ])
    }

    private func setupLabel() {
        desirableLabel.textAlignment = .center
        desirableLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(desirableLabel)

        NSLayoutConstraint.activate([
            desirableLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            desirableLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
    
    private func setupImge() {
        progrssImg.backgroundColor = UIColor.clear
        progrssImg.translatesAutoresizingMaskIntoConstraints = false
        progrssImg.contentMode = .scaleToFill
        addSubview(progrssImg)
        
        NSLayoutConstraint.activate([
            progrssImg.centerXAnchor.constraint(equalTo: centerXAnchor),
            progrssImg.widthAnchor.constraint(equalToConstant: 25),
            progrssImg.heightAnchor.constraint(equalToConstant: 25),
            progrssImg.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }

    func setGaugeProgress(_ value: CGFloat) {
        gaugeView.progress = value
    }
}

//MARK: ----------------------- MAIN Gauge View
class GaugeView: UIView {

    // MARK: - Layers
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private var tickMarkLayers: [CAShapeLayer] = []
    private let tickTrackLayer = CAShapeLayer()
    private var previousBounds: CGRect = .zero

    // MARK: - Public Configurable Properties
    var gaugeThickness: CGFloat = 15.0 { didSet { setNeedsLayout() } }
    var gaugeRadiusMultiplier: CGFloat = 1.0 { didSet { setNeedsLayout() } }
    
    var gaugeProgersColor: [CGColor] =
    [UIColor(red: 63.0/255.0, green: 216.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor, UIColor(red: 167.0/255.0, green: 224.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor, UIColor(red: 250.0/255.0, green: 206.0/255.0, blue: 52.0/255.0, alpha: 1.0).cgColor, UIColor(red: 255.0/255.0, green: 85.0/255.0, blue: 99.0/255.0, alpha: 1.0).cgColor]
    { didSet { setNeedsLayout() } }
        
    var trackColor: UIColor = UIColor(red: 42/255, green: 23/255, blue: 11/255, alpha: 1) { didSet { setNeedsLayout() } }

    var tickStrokeColor: UIColor = UIColor(red: 71/255, green: 77/255, blue: 96/255, alpha: 0.8) { didSet { setNeedsLayout() } }
    var tickTrackStrokeColor: UIColor = UIColor(red: 71/255, green: 77/255, blue: 96/255, alpha: 0.7) { didSet { setNeedsLayout() } }
    
    var showTicks: Bool = true {
        didSet { setNeedsLayout() }
    }
    
    var numberOfMajorTicks: Int = 12 { didSet { setNeedsLayout() } }
    var numberOfMinorTicksPerMajor: Int = 2 { didSet { setNeedsLayout() } }
    var majorTickLength: CGFloat = 5.0 { didSet { setNeedsLayout() } }
    var minorTickLength: CGFloat = 5.0 { didSet { setNeedsLayout() } }

    private let startAngle: CGFloat = -.pi
    private let endAngle: CGFloat = 0

    // MARK: - Progress
    var progress: CGFloat = 0.0 {
        didSet {
            let clamped = max(0.0, min(1.0, progress))
            animateProgress(from: oldValue, to: clamped)
        }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds != previousBounds else {
            progressLayer.strokeEnd = progress
            return
        }
        previousBounds = bounds
        
        if showTicks {
            drawTickMarks()
        } else {
            removeLayers(named: "tickMark")
            tickTrackLayer.removeFromSuperlayer()
        }
        
        setupGaugeLayers()
        progressLayer.strokeEnd = progress
    }
        
    private func removeLayers(named name: String) {
        layer.sublayers?.removeAll(where: { $0.name == name })
    }

    // MARK: - Elliptical Arc Path
    private func ellipticalArcPath(center: CGPoint, size: CGSize, startAngle: CGFloat, endAngle: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let steps = 100
        let angleRange = endAngle - startAngle

        for i in 0...steps {
            let angle = startAngle + CGFloat(i) / CGFloat(steps) * angleRange
            let x = center.x + size.width * cos(angle)
            let y = center.y + size.height * sin(angle)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
    

    // MARK: - Gauge Layers
    private func setupGaugeLayers() {
        if trackLayer.superlayer == nil {
            layer.insertSublayer(trackLayer, at: 0)
        }
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, above: trackLayer)
        }

        let center = CGPoint(x: bounds.midX, y: bounds.maxY)
        let size = CGSize(
            width: bounds.width / 2 * gaugeRadiusMultiplier * 0.75,
            height: bounds.height / 2 * gaugeRadiusMultiplier * 1.3
        )
        
        /*
         let size = CGSize(
             width: bounds.width / 2 * gaugeRadiusMultiplier * 0.7,
             height: bounds.height / 2 * gaugeRadiusMultiplier * 1.3
         )

         */

        let arcPath = ellipticalArcPath(center: center, size: size, startAngle: startAngle, endAngle: endAngle)

        // Track Layer
        trackLayer.path = arcPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = gaugeThickness
        trackLayer.lineCap = .round

        // Progress Layer
        progressLayer.path = arcPath
        progressLayer.strokeColor = UIColor.green.cgColor // Will be masked by gradient
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = gaugeThickness
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress

        // Gradient Layer
        gradientLayer.frame = bounds
        gradientLayer.colors = gaugeProgersColor
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.mask = progressLayer
    }

    // MARK: - Tick Marks
    private func drawTickMarks() {
        tickMarkLayers.forEach { $0.removeFromSuperlayer() }
        tickMarkLayers.removeAll()

        if tickTrackLayer.superlayer == nil {
            layer.insertSublayer(tickTrackLayer, at: 0)
        }

        let center = CGPoint(x: bounds.midX, y: bounds.maxY)
        let size = CGSize(
            width: bounds.width / 2 * gaugeRadiusMultiplier * 0.83,
            height: bounds.height / 2 * gaugeRadiusMultiplier * 1.4
        )
        let tickArcSize = CGSize(
            width: bounds.width / 2 * gaugeRadiusMultiplier * 0.95,
            height: bounds.height / 2 * gaugeRadiusMultiplier * 1.63
        )
        
        /*
         let size = CGSize(
             width: bounds.width / 2 * gaugeRadiusMultiplier * 0.8,
             height: bounds.height / 2 * gaugeRadiusMultiplier * 1.4
         )
         let tickArcSize = CGSize(
             width: bounds.width / 2 * gaugeRadiusMultiplier * 0.95,
             height: bounds.height / 2 * gaugeRadiusMultiplier * 1.69
         )
         */

        let arcPath = ellipticalArcPath(center: center, size: tickArcSize, startAngle: startAngle, endAngle: endAngle)
        tickTrackLayer.path = arcPath
        tickTrackLayer.strokeColor = tickTrackStrokeColor.cgColor
        tickTrackLayer.fillColor = UIColor.clear.cgColor
        tickTrackLayer.lineWidth = 1.0
        tickTrackLayer.lineCap = .round

        let tickRadius = size.height + gaugeThickness / 2 + majorTickLength
        let tickWRadius = size.width + gaugeThickness / 2 + majorTickLength
        let totalTicks = numberOfMajorTicks + (numberOfMajorTicks - 1) * numberOfMinorTicksPerMajor
        let angleIncrement = (endAngle - startAngle) / CGFloat(totalTicks - 1)

        for i in 0..<totalTicks {
            let angle = startAngle + CGFloat(i) * angleIncrement
            let isMajor = i % (numberOfMinorTicksPerMajor + 1) == 0
            let length = isMajor ? majorTickLength : minorTickLength

            let outer = CGPoint(
                x: center.x + tickWRadius * cos(angle),
                y: center.y + tickRadius * sin(angle)
            )
            let inner = CGPoint(
                x: center.x + (tickWRadius - length) * cos(angle),
                y: center.y + (tickRadius - length) * sin(angle)
            )

            let tickPath = UIBezierPath()
            tickPath.move(to: inner)
            tickPath.addLine(to: outer)

            let tickLayer = CAShapeLayer()
            tickLayer.path = tickPath.cgPath
            tickLayer.strokeColor = tickStrokeColor.cgColor
            tickLayer.lineWidth = 1.5
            tickLayer.lineCap = .round
            tickLayer.name = "tickMark"
            layer.addSublayer(tickLayer)
            tickMarkLayers.append(tickLayer)
        }
    }

    // MARK: - Animation
    private func animateProgress(from: CGFloat, to: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
        progressLayer.strokeEnd = to
    }
}
