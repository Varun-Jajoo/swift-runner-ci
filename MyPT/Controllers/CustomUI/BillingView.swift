//
//  BillingView.swift
//  MyPT
//
//  Created by techsaga corp on 07/12/24.
//

import UIKit

//class ShapeView: UIView {
//    
//    var topPath: UIBezierPath = UIBezierPath()
//    var bottomPath: UIBezierPath = UIBezierPath()
//    
//    // Circle Y-position for bottom section
//    var circleYPosition: CGFloat = 50 {
//        didSet {
//            self.setNeedsDisplay()
//        }
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.backgroundColor = UIColor.clear
//    }
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        
//        let totalHeight = rect.height
//        let topSectionHeight = totalHeight * 0.5 // 50% of the total height
//        let bottomSectionHeight = totalHeight - topSectionHeight
//        
//        // ---- TOP SECTION ----
//        topPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: rect.width, height: topSectionHeight),
//                               byRoundingCorners: .allCorners,
//                               cornerRadii: CGSize(width: 10, height: 10))
//        UIColor.systemBlue.setFill() // Example color for the top section
//        topPath.fill()
//        
//        // ---- BOTTOM SECTION ----
//        bottomPath.move(to: CGPoint(x: 0, y: totalHeight)) // Start at bottom-left
//        
//        // Left arc
//        bottomPath.addArc(withCenter: CGPoint(x: 0, y: circleYPosition - 15),
//                          radius: 10,
//                          startAngle: CGFloat((90 * Double.pi) / 180),
//                          endAngle: CGFloat((270 * Double.pi) / 180),
//                          clockwise: false)
//        
//        bottomPath.addLine(to: CGPoint(x: 0, y: topSectionHeight)) // Line to top of bottom section
//        bottomPath.addLine(to: CGPoint(x: rect.width, y: topSectionHeight)) // Line to top-right of bottom section
//        bottomPath.addLine(to: CGPoint(x: rect.width, y: totalHeight)) // Line to bottom-right
//        
//        // Right arc
//        bottomPath.addArc(withCenter: CGPoint(x: rect.width, y: circleYPosition - 15),
//                          radius: 10,
//                          startAngle: CGFloat((270 * Double.pi) / 180),
//                          endAngle: CGFloat((90 * Double.pi) / 180),
//                          clockwise: false)
//        
//        bottomPath.close()
//        UIColor.white.setFill() // Example color for the bottom section
//        bottomPath.fill()
//        
//        // ---- DASHED LINE IN CENTER ----
//        let dashPath = UIBezierPath()
//        dashPath.move(to: CGPoint(x: rect.minX + 12, y: circleYPosition - 15))
//        dashPath.addLine(to: CGPoint(x: rect.maxX - 12, y: circleYPosition - 15))
//        dashPath.setLineDash([5, 5], count: 2, phase: 0.0)
//        dashPath.lineWidth = 1.0
//        dashPath.lineCapStyle = .butt
//        UIColor.lightGray.set()
//        dashPath.stroke()
//    }
//}

class BillingView: UIView {
    
    let topView = UIView() // Top section as a plain subview
    let bottomView = CustomBottomView() // Bottom section as a custom-drawn subview
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            print("View added to a superview.")
//            anim()
            startAnimation()
        }
    }
    
    private func setupSubviews() {
        self.backgroundColor = .clear // Parent view's background
        
        // Configure the top view
        topView.backgroundColor = UIColor.systemBlue // Example color
        topView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topView)
        
        // Configure the bottom custom view
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomView)
        
        
        // Auto Layout for subviews
        NSLayoutConstraint.activate([
            // Top view constraints
            topView.topAnchor.constraint(equalTo: self.topAnchor),
            topView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3), // 50% height
            
            // Bottom view constraints
//            bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            bottomView.topAnchor.constraint(equalTo: self.topAnchor),
            bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        bottomView.alpha = 0
    }
    

    
//    func anim(){
       
        //        // Animation Method
    func startAnimation(duration: TimeInterval = 2.5, delay: TimeInterval = 1.0, imageYOffset: CGFloat = -100, completion: (() -> Void)? = nil ) {
        
//                self.topView.animShow(duration: 1.0, delay: 0.3) {
        //            self.topViewHeightConstraint = self.topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
        //        }
                
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
        
//                self.bottomView.isHidden = false
        var offsetY:CGFloat = 0.0
        
        //curveEaseInOut
        UIView.animate(withDuration: duration, delay: delay, options: .transitionFlipFromTop, animations: {
                    if let superview = self.superview {
                        
                        
//                        self.bottomView.center.y += self.bottomView.bounds.height
//                        self.bottomView.layoutIfNeeded()
                       offsetY += superview.bounds.height - 120
                        
                        self.bottomView.transform = CGAffineTransform(translationX: 0, y: offsetY / 2 )
                        
//                        self.bottomView.transform = CGAffineTransform(translationX: 0, y: superview.bounds.height / 2 )
                        self.bottomView.alpha = 1
                        
                        // Move the top view up
//                        self.bottomView.transform = CGAffineTransform(translationX: 0, y: superview.bounds.height / 2 + self.bottomView.bounds.height / 2 + 20)
        
                    }
                }) { _ in
                    
                    
                    
                    // After the animation completes, animate the appearance of the labels
//                    UIView.animate(withDuration: duration, animations: {
//        
//                        self.topViewHeightConstraint = self.topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
//                        self.topViewHeightConstraint?.isActive = true
//        
//                        self.topLbl()
//                    })
                    completion?()
                }
            }
        
//        bottomView.animTopBottom(duration: 1.0, delay: 0.4) {
//            print("animtation is done")
//        }
        
//    }
}


class CustomBottomView: UIView {
    
    var circleYPosition: CGFloat = 50 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath()
        
        circleYPosition = self.frame.size.height/2.0
        
        // Left - right circle
        path.move(to: CGPoint(x: 0, y: self.frame.size.height))
        
        // Left side arc
        path.addArc(withCenter: CGPoint(x: 0, y: self.circleYPosition - 15),
                    radius: 10,
                    startAngle: CGFloat((90 * Double.pi) / 180),
                    endAngle: CGFloat((270 * Double.pi) / 180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        path.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        // Right side arc
        path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: self.circleYPosition - 15),
                    radius: 10,
                    startAngle: CGFloat((270 * Double.pi) / 180),
                    endAngle: CGFloat((90 * Double.pi) / 180),
                    clockwise: false)
        
        path.close()
        UIColor.white.setFill()
        path.fill()
        
        // Dashed line in the center
        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: self.bounds.minX + 12, y: self.circleYPosition - 15))
        dashPath.addLine(to: CGPoint(x: self.bounds.maxX - 12, y: self.circleYPosition - 15))
        dashPath.setLineDash([5, 5], count: 2, phase: 0.0)
        dashPath.lineWidth = 1.0
        dashPath.lineCapStyle = .butt
        UIColor.lightGray.set()
        dashPath.stroke()
    }
}



//class BillingView: UIView {
//    let billingSection = UIView()
//    var circleYPosition: CGFloat = 50
//    var cornerSide: UIRectCorner = .allCorners
//    var cornerSize: CGSize = CGSize(width: 24, height: 24)
//    var billBackgroundColor: UIColor? = .white
//    var lineBgColor: UIColor? = .black
//
//    private var shapeLayer: CAShapeLayer?
//    private var dashLayer: CAShapeLayer?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupBillingSection()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupBillingSection()
//    }
//
//    private func setupBillingSection() {
//        billingSection.translatesAutoresizingMaskIntoConstraints = false
//        billingSection.backgroundColor = .clear // Transparent to show the path
//        addSubview(billingSection)
//
//        NSLayoutConstraint.activate([
//            billingSection.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
//            billingSection.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            billingSection.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//            billingSection.heightAnchor.constraint(equalToConstant: 200)
//        ])
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // Remove old layers to avoid duplicates
//        shapeLayer?.removeFromSuperlayer()
//        dashLayer?.removeFromSuperlayer()
//
//        // Add the updated path to the billingSection
//        addPathToBillingSection()
//    }
//
//    private func addPathToBillingSection() {
//        // Create the shape layer
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.fillColor = billBackgroundColor?.cgColor
//        shapeLayer.strokeColor = lineBgColor?.cgColor
//        shapeLayer.lineWidth = 1.0
//
//        // Define the custom path
//        let path = UIBezierPath(roundedRect: billingSection.bounds,
//                                byRoundingCorners: cornerSide,
//                                cornerRadii: cornerSize)
//
//        // Custom arcs (example left and right circles)
//        path.move(to: CGPoint(x: 0, y: billingSection.bounds.height))
//        path.addArc(withCenter: CGPoint(x: 0, y: circleYPosition - 15),
//                    radius: 34,
//                    startAngle: CGFloat((90 * Double.pi) / 180),
//                    endAngle: CGFloat((270 * Double.pi) / 180),
//                    clockwise: false)
//        path.addLine(to: CGPoint(x: billingSection.bounds.width, y: 0))
//        path.addArc(withCenter: CGPoint(x: billingSection.bounds.width, y: circleYPosition - 15),
//                    radius: 34,
//                    startAngle: CGFloat((270 * Double.pi) / 180),
//                    endAngle: CGFloat((90 * Double.pi) / 180),
//                    clockwise: false)
//        path.close()
//
//        // Assign path to the shape layer
//        shapeLayer.path = path.cgPath
//        self.shapeLayer = shapeLayer
//
//        // Add dashed line in the center
//        let dashLayer = CAShapeLayer()
//        let dashPath = UIBezierPath()
//        dashPath.move(to: CGPoint(x: billingSection.bounds.minX + 34, y: circleYPosition - 15))
//        dashPath.addLine(to: CGPoint(x: billingSection.bounds.maxX - 34, y: circleYPosition - 15))
//        dashLayer.path = dashPath.cgPath
//        dashLayer.strokeColor = lineBgColor?.cgColor
//        dashLayer.lineWidth = 1.0
//        dashLayer.lineDashPattern = [5, 5] as [NSNumber]
//        self.dashLayer = dashLayer
//
//        // Add shape layers to billingSection
//        billingSection.layer.addSublayer(shapeLayer)
//        billingSection.layer.addSublayer(dashLayer)
//    }
//}


//class BillingView: UIView {
//    
//    
//    let billingSection = UIView()
//      var circleYPosition: CGFloat = 50
////      var cornerSide: UIRectCorner = .allCorners
////      var cornerSize: CGSize = CGSize(width: 24, height: 24)
//      var billBackgroundColor: UIColor? = .white
//      var lineBgColor: UIColor? = .black
//    
//    
//    //------------------------
//        let topView = UIView()
////        let billingSection = UIView()
//        var topViewHeightConstraint: NSLayoutConstraint?
//    
//        private let centerImageView = UIImageView()
//        private let titleLabel = UILabel()
//        private let descriptionLabel = UILabel()
//    
//        //-------------------
//        let packageTitleLabel = UILabel()
//        let packageLabel = UILabel()
//        let trainerDetailTitleLabel = UILabel()
//        let trainerNameLabel = UILabel()
//        let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
//        let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
//        let qrCodeImageView = UIImageView()
//        let locBtn = UIButton(type: .custom)
//        let footerLabel = UILabel()
//    
//        var trainerTags:[String]? {
//            didSet{
//                self.setNeedsDisplay()
//            }
//        }
//    
//        var startDate:(title:String,value:String)? {
//            didSet{
//                self.setNeedsDisplay()
//            }
//        }
//    
//        var timingTxt:(title:String,value:String)? {
//            didSet{
//                self.setNeedsDisplay()
//            }
//        }
//    
//        var locationTxt:(title:String,value:String)? {
//            didSet{
//                self.setNeedsDisplay()
//            }
//        }
//    
//        var validUptoDate:(title:String,value:String)? {
//            didSet{
//                self.setNeedsDisplay()
//            }
//        }
//    
//        var cornerSide:UIRectCorner? = .allCorners {
//            didSet {
//                self.setNeedsDisplay()
//            }
//        }
//    
//        var cornerSize:CGSize = CGSize(width: 12, height: 12) {
//            didSet{
//                self.setNeedsDisplay()
//            }
//        }
//    
//    
//    
//        //-------------------------
//        var path: UIBezierPath = UIBezierPath()
//        var billBackgroundColor:UIColor? = UIColor.white {
//            didSet{
//                self.setNeedsDisplay()
//            }
//        }
//    
//        var lineBgColor:UIColor? = UIColor.darkGray {
//            didSet{
//                self.setNeedsDisplay()
//            }
//        }
//    
//    
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            self.setupUI()
//            // Update layout of subviews or other properties here
//            print("layoutSubviews is called")
//            self.setupTopUI()
//    
//    //        self.topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), shadowRadius: 3, opacity: 0.3, offset: CGSize(width: 0, height: 15), cornerRadius: 12)
//            self.topView.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), offSet: CGSize(width: 0, height: 15), opacity: 0.3, shadowRadius: 3, cornerRadious: 12)
//    
//        }
//    
//        // Set you circle position for verticle.
//        var circleYPosition: CGFloat = 50 {
//            didSet {
//                self.setNeedsDisplay()
//            }
//        }
//    
//        override func awakeFromNib() {
//            super.awakeFromNib()
//            self.backgroundColor = UIColor.clear
//            // Here apply shadow
//            //        setupUI()
//        }
//    
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//            self.backgroundColor = .clear
//            setupUI()
//            setupInitialState()
//        }
//    
//        required init?(coder: NSCoder) {
//            super.init(coder: coder)
//            self.backgroundColor = .clear
//            setupUI()
//            setupInitialState()
//        }
//    
//    
//        override func draw(_ rect: CGRect) {
//            super.draw(rect)
//    
//            //        setupUI()
//    
//            // 4 corners radious
//            //        UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 24, height: 24)).addClip()
//    
//            UIBezierPath(roundedRect: rect, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize).addClip()
//    
//            // Left - right circle
//            path.move(to: CGPoint(x: 0, y: self.frame.size.height))
//    
//            //left side
//            path.addArc(withCenter: CGPoint(x: 0, y: self.circleYPosition - 15),
//                        radius: 34,
//                        startAngle: CGFloat((90 * Double.pi) / 180),
//                        endAngle: CGFloat((270 * Double.pi) / 180),
//                        clockwise: false)
//    
//            path.addLine(to: CGPoint(x: 0, y: 0))
//            path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
//            path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
//    
//            path.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
//    
//            //right side
//            path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: self.circleYPosition - 15),
//                        radius: 34,
//                        startAngle: CGFloat((270 * Double.pi) / 180),
//                        endAngle: CGFloat((90 * Double.pi) / 180),
//                        clockwise: false)
//    
//    
//            path.close()
//            //        UIColor.white.setFill()
//            billBackgroundColor?.setFill()
//            path.fill()
//            
//    
//            // Center Dash path
//            let dashPath = UIBezierPath()
//            dashPath.move(to: CGPoint(x: self.bounds.minX + 34, y: self.circleYPosition - 15))
//            dashPath.addLine(to: CGPoint(x: self.bounds.maxX - 34, y: self.circleYPosition - 15))
//            dashPath.setLineDash([5,5], count: 2, phase: 0.0)
//            dashPath.lineWidth = 1.0
//            dashPath.lineCapStyle = .butt
//            //        UIColor.green.set()
//    
//            if let lineBgColor = lineBgColor  {
//                lineBgColor.set()
//            }
//    
//            dashPath.stroke()
//    
//        }
//    
//        //---------------------------
//    
//        private func setupInitialState() {
//            // Set initial states for animation
//            billingSection.alpha = 0 // Initially hidden
//        }
//    
//    
//        private func setupUI() {
//    
//    
//            // MARK: - Labels and UI Elements
//            // Package Title Label
//            //     packageTitleLabel = UILabel()
//            packageTitleLabel.text = "Package"
//            packageTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
//            packageTitleLabel.textColor = .darkGray
//            packageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//    
//            // Package Label
//            //        let packageLabel = UILabel()
//            packageLabel.text = "12 months, Elite Gym Membership"
//            packageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//            packageLabel.textColor = .black
//            packageLabel.translatesAutoresizingMaskIntoConstraints = false
//            packageLabel.numberOfLines = 2
//    
//            // Start Date Label
//            //startDate
//            let startDateLabel = createDetailLabel(title: startDate?.title ?? "", value: startDate?.value ?? "")  //createDetailLabel(title: "Start Date", value: "06/24")
//            let validUptoLabel = createDetailLabel(title: validUptoDate?.title ?? "", value: validUptoDate?.value ?? "") //createDetailLabel(title: "Valid Upto", value: "06/25")
//    
//            // Trainer Section
//            let trainerImageView = UIImageView(image: UIImage(named: "ic_trainer"))
//            trainerImageView.contentMode = .scaleAspectFill
//            trainerImageView.layer.cornerRadius = 25
//            trainerImageView.clipsToBounds = true
//            trainerImageView.translatesAutoresizingMaskIntoConstraints = false
//    
//            // Trainer detail Title Label
//            //        let trainerDetailTitleLabel = UILabel()
//            trainerDetailTitleLabel.text = "Trainer Details"
//            trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
//            trainerDetailTitleLabel.textColor = .darkGray
//            trainerDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//    
//            //        let trainerNameLabel = UILabel()
//            trainerNameLabel.text = "Christene De Koning"
//            trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//            trainerNameLabel.textColor = .black
//            trainerNameLabel.numberOfLines = 2
//            trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
//    
//            //        let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
//            trainerBadgeImageView.contentMode = .scaleAspectFill
//            trainerBadgeImageView.layer.cornerRadius = 10
//            trainerBadgeImageView.clipsToBounds = true
//            trainerBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
//    
//    
//            //        let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
//            nextImageView.contentMode = .scaleAspectFill
//            nextImageView.layer.cornerRadius = 15
//            nextImageView.clipsToBounds = true
//            nextImageView.translatesAutoresizingMaskIntoConstraints = false
//    
//            //trainerTags
//            //["Cardio", "Pilates", "+3"]
//            let trainerTagsLabel = createTagView(tags: trainerTags ?? [])
//    
//            // Timing and Location
//            let timingLabel = createDetailLabel(title: timingTxt?.title ?? "", value: timingTxt?.value ?? "") //createDetailLabel(title: "Timing", value: "10:00 to 11:00")
//            let locationLabel = createDetailLabel(title: locationTxt?.title ?? "", value: locationTxt?.value ?? "") //createDetailLabel(title: "Location", value: "MyPT Dubai")
//    
//    
//            // QR Code
//            //        let qrCodeImageView = UIImageView()
//            qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
//            qrCodeImageView.contentMode = .scaleAspectFit
//            qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
//    
//            //Get Direction
//            //        let locBtn = UIButton(type: .custom)
//            locBtn.backgroundColor = UIColor.clear
//            locBtn.setTitle("Get Direction", for: .normal)
//            locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
//            //        locBtn.tintColor = UIColor.blue //rgba(73, 129, 242, 1)
//            locBtn.setTitleColor(UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1), for: .normal)
//            locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//            locBtn.translatesAutoresizingMaskIntoConstraints = false
//            // Set semanticContentAttribute to force right-to-left layout
//            locBtn.semanticContentAttribute = .forceRightToLeft
//    
//            // Optional: Adjust spacing between image and title
//            locBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
//            locBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -8)
//    
//            // Footer Note
//            //        let footerLabel = UILabel()
//            footerLabel.text = "Scan the QR code to access the gym premises."
//            footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//            footerLabel.textColor = .gray
//            footerLabel.textAlignment = .center
//            footerLabel.translatesAutoresizingMaskIntoConstraints = false
//    
//            // Add Subviews to Ticket Container
//            self.addSubview(packageTitleLabel)
//            self.addSubview(packageLabel)
//            self.addSubview(startDateLabel)
//            self.addSubview(validUptoLabel)
//            self.addSubview(trainerImageView)
//            self.addSubview(trainerBadgeImageView)
//            self.addSubview(nextImageView)
//            self.addSubview(trainerDetailTitleLabel)
//            self.addSubview(trainerNameLabel)
//            self.addSubview(trainerTagsLabel)
//            self.addSubview(timingLabel)
//            self.addSubview(locationLabel)
//            self.addSubview(locBtn)
//            self.addSubview(qrCodeImageView)
//            self.addSubview(footerLabel)
//    
//            // MARK: - Layout Constraints
//            NSLayoutConstraint.activate([
//    
//                packageTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
//                packageTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
//                packageTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
//    
//                // Package Label
//                packageLabel.topAnchor.constraint(equalTo: packageTitleLabel.bottomAnchor, constant: 10),
//                packageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
//                packageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
//                //            packageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//    
//                // Start Date and Valid Upto
//                startDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//                startDateLabel.topAnchor.constraint(equalTo: packageLabel.bottomAnchor, constant: 20),
//    
//                validUptoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//                validUptoLabel.topAnchor.constraint(equalTo: packageLabel.bottomAnchor, constant: 20),
//    
//                // Trainer Section
//                trainerDetailTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//                trainerDetailTitleLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 20),
//    
//                trainerImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//                trainerImageView.topAnchor.constraint(equalTo: trainerDetailTitleLabel.bottomAnchor, constant: 12),
//                trainerImageView.widthAnchor.constraint(equalToConstant: 50),
//                trainerImageView.heightAnchor.constraint(equalToConstant: 50),
//    
//                trainerNameLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
//                trainerNameLabel.topAnchor.constraint(equalTo: trainerImageView.topAnchor),
//    
//                trainerBadgeImageView.leadingAnchor.constraint(equalTo: trainerNameLabel.trailingAnchor, constant: 2),
//                trainerBadgeImageView.topAnchor.constraint(equalTo: trainerNameLabel.topAnchor, constant: 2),
//                trainerBadgeImageView.widthAnchor.constraint(equalToConstant: 20),
//                trainerBadgeImageView.heightAnchor.constraint(equalToConstant: 20),
//                trainerBadgeImageView.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -10),
//    
//                nextImageView.widthAnchor.constraint(equalToConstant: 30),
//                nextImageView.heightAnchor.constraint(equalToConstant: 30),
//                nextImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
//                nextImageView.centerYAnchor.constraint(equalTo: trainerImageView.centerYAnchor),
//    
//                trainerTagsLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
//                trainerTagsLabel.topAnchor.constraint(equalTo: trainerNameLabel.bottomAnchor, constant: 5),
//    
//                // Timing and Location
//                timingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//                timingLabel.topAnchor.constraint(equalTo: qrCodeImageView.topAnchor, constant: 2),
//    
//                locationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//    
//                locationLabel.topAnchor.constraint(equalTo: timingLabel.bottomAnchor, constant: 10),
//                locationLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
//    
//                // QR Code
//                qrCodeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//                qrCodeImageView.topAnchor.constraint(equalTo: self.centerYAnchor, constant: self.circleYPosition + 10),
//                qrCodeImageView.widthAnchor.constraint(equalToConstant: 100),
//                qrCodeImageView.heightAnchor.constraint(equalToConstant: 100),
//    
//    
//                // Footer Note
//                footerLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
//                footerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
//                footerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
//                locBtn.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
//                locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: footerLabel.topAnchor, multiplier: -12),
//                locBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
//                locBtn.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: self.trailingAnchor, multiplier: -12),
//                locBtn.heightAnchor.constraint(equalToConstant: 35),
//    
//            ])
//    
//            topView.translatesAutoresizingMaskIntoConstraints = false
//            topView.backgroundColor = .black // Adjust color as needed
//            addSubview(topView)
//    
//    
//            // Add height constraint for the topView
//            topViewHeightConstraint = self.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
//            topViewHeightConstraint?.isActive = true
//    
//            NSLayoutConstraint.activate([
//                topView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//                topView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//                topView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
//                topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
//            ])
//    
//    
//            /*
//    
//             topView.translatesAutoresizingMaskIntoConstraints = false
//             topView.backgroundColor = .black // Adjust color as needed
//             addSubview(topView)
//    
//             //        // Billing Section
//             //        billingSection.translatesAutoresizingMaskIntoConstraints = false
//             //        billingSection.backgroundColor = .lightGray // Adjust color as needed
//             //        addSubview(billingSection)
//    
//             // Add constraints for `topView` and `billingSection`
//             NSLayoutConstraint.activate([
//             // Top View initially centered
//             topView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//             topView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//             topView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
//             topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0),
//    
//             //                    // Billing Section initially off-screen
//             //                    billingSection.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//             //                    billingSection.topAnchor.constraint(equalTo: self.bottomAnchor),
//             //                    billingSection.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
//             //                    billingSection.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.6)
//             ])
//             */
//        }
//    
//        //-----------Top view setup
//    
//    
//        // Animation Method
//    func startAnimation(duration: TimeInterval = 0.5, delay: TimeInterval = 1, imageYOffset: CGFloat = -100, completion: (() -> Void)? = nil ) {
//        
////        self.topView.animShow(duration: 1.0, delay: 0.3) {
////            self.topViewHeightConstraint = self.topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
////        }
//        
//        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
//            if let superview = self.superview {
//                // Move the top view up
//                self.topView.transform = CGAffineTransform(translationX: 0, y: -superview.bounds.height / 2 + self.topView.bounds.height / 2 + 20)
//
//            }
//        }) { _ in
//            // After the animation completes, animate the appearance of the labels
//            UIView.animate(withDuration: duration, animations: {
//
//                self.topViewHeightConstraint = self.topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
//                self.topViewHeightConstraint?.isActive = true
//
//                self.topLbl()
//            })
//            completion?()
//        }
//    }
//    
////        func startAnimation(duration: TimeInterval = 0.5, delay: TimeInterval = 1, imageYOffset: CGFloat = -100, completion: (() -> Void)? = nil ) {
////            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
////                if let superview = self.superview {
////                    // Move the top view up
////                    self.topView.transform = CGAffineTransform(translationX: 0, y: -superview.bounds.height / 2 + self.topView.bounds.height / 2 + 20)
////    
////                }
////            }) { _ in
////                // After the animation completes, animate the appearance of the labels
////                UIView.animate(withDuration: duration, animations: {
////    
////                    self.topViewHeightConstraint = self.topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
////                    self.topViewHeightConstraint?.isActive = true
////    
////                    self.topLbl()
////                })
////                completion?()
////            }
////        }
//    
//    
//        // setupTopUI
//        private func setupTopUI() {
//            topView.backgroundColor = UIColor.mainBg
//            centerImageView.backgroundColor = .clear
//    
//            // Add shadow for depth
//    //        topView.layer.shadowColor = UIColor.red.cgColor
//    //        topView.layer.shadowOpacity = 1.0
//    //        topView.layer.shadowOffset = CGSize(width: 0, height: 15)
//    //        topView.layer.shadowRadius = 10
//    
//    //        topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor.red, shadowRadius: 0, opacity: 1.0, offset: CGSize(width: 0, height: 10), cornerRadius: 12)
//    
//    
//    
//            // Center Image
//            centerImageView.contentMode = .scaleAspectFit
//            centerImageView.translatesAutoresizingMaskIntoConstraints = false
//            topView.addSubview(centerImageView)
//    
//            //        // Title Label
//            //        titleLabel.textAlignment = .center
//            //        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//            //        titleLabel.textColor = .white
//            //        titleLabel.alpha = 0 // Hidden initially
//            //        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//            //        topView.addSubview(titleLabel)
//            //
//            //        // Description Label
//            //        descriptionLabel.textAlignment = .center
//            //        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//            //        descriptionLabel.textColor = UIColor.txtDarkGray
//            //        descriptionLabel.numberOfLines = 0
//            //        descriptionLabel.alpha = 0 // Hidden initially
//            //        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//            //        topView.addSubview(descriptionLabel)
//    
//            // Add Constraints
//            NSLayoutConstraint.activate([
//                centerImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
//    //            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
//                centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 50.0),
//                centerImageView.widthAnchor.constraint(equalToConstant: 80),
//                centerImageView.heightAnchor.constraint(equalToConstant: 80),
//    
//                //            titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
//                //            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
//                //            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
//                //
//                //            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
//                //            descriptionLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
//                //            descriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
//                //            // Add bottom constraint to description label (it will automatically adjust after topView height is changed)
//                //            descriptionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -20)
//            ])
//    
//        }
//    
//        private func topLbl(){
//            // Title Label
//            titleLabel.textAlignment = .center
//            titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//            titleLabel.textColor = .white
//            titleLabel.alpha = 1 // Hidden initially
//            titleLabel.translatesAutoresizingMaskIntoConstraints = false
//            topView.addSubview(titleLabel)
//    
//            // Description Label
//            descriptionLabel.textAlignment = .center
//            descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//            descriptionLabel.textColor = UIColor.txtDarkGray
//            descriptionLabel.numberOfLines = 0
//            descriptionLabel.alpha = 1 // Hidden initially
//            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//            topView.addSubview(descriptionLabel)
//            // Add Constraints
//            NSLayoutConstraint.activate([
//                centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: -30.0),
//                titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
//                titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
//                titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
//    
//                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
//                descriptionLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
//                descriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
//                // Add bottom constraint to description label (it will automatically adjust after topView height is changed)
//                descriptionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -20)
//            ])
//    
//        }
//    
//    
//        // Configuration Method
//        func configure(title: String, description: String, imageName: String) {
//            titleLabel.text = title
//            descriptionLabel.text = description
//            centerImageView.image = UIImage(named: imageName)
//        }
//    
//    
//        //---------------------_****************
//        // MARK: - Helper Functions
//        private func createDetailLabel(title: String, value: String) -> UILabel {
//            let label = UILabel()
//            let attributedText = NSMutableAttributedString(
//                string: "\(title)\n",
//                attributes: [
//                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
//                    .foregroundColor: UIColor.gray
//                ]
//            )
//            attributedText.append(
//                NSAttributedString(
//                    string: "\n",
//                    attributes: [
//                        .font: UIFont.systemFont(ofSize: 10, weight: .regular),
//                        .foregroundColor: UIColor.black
//                    ]
//                )
//            )
//            attributedText.append(
//                NSAttributedString(
//                    string: value,
//                    attributes: [
//                        .font: UIFont.systemFont(ofSize: 18, weight: .bold),
//                        .foregroundColor: UIColor.black
//                    ]
//                )
//            )
//            label.attributedText = attributedText
//            label.numberOfLines = 3
//            label.textAlignment = .left
//            label.translatesAutoresizingMaskIntoConstraints = false
//            return label
//        }
//    
//        private func createTagView(tags: [String]) -> UIView {
//            let tagStackView = UIStackView()
//            tagStackView.axis = .horizontal
//            tagStackView.spacing = 5
//            tagStackView.translatesAutoresizingMaskIntoConstraints = false
//    
//            for tag in tags {
//                // Create the background view
//                let tagBackgroundView = UIView()
//                tagBackgroundView.backgroundColor = UIColor.black
//                tagBackgroundView.layer.cornerRadius = 6
//                tagBackgroundView.layer.masksToBounds = true
//                tagBackgroundView.translatesAutoresizingMaskIntoConstraints = false
//    
//                // Create the label
//                let tagLabel = UILabel()
//                tagLabel.text = tag
//                tagLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
//                tagLabel.textColor = .white
//                tagLabel.textAlignment = .center
//                tagLabel.translatesAutoresizingMaskIntoConstraints = false
//    
//                // Add the label to the background view
//                tagBackgroundView.addSubview(tagLabel)
//    
//                // Set constraints for the label to center it within the background view
//                NSLayoutConstraint.activate([
//                    tagLabel.leadingAnchor.constraint(equalTo: tagBackgroundView.leadingAnchor, constant: 8),
//                    tagLabel.trailingAnchor.constraint(equalTo: tagBackgroundView.trailingAnchor, constant: -8),
//                    tagLabel.topAnchor.constraint(equalTo: tagBackgroundView.topAnchor, constant: 4),
//                    tagLabel.bottomAnchor.constraint(equalTo: tagBackgroundView.bottomAnchor, constant: -4)
//                ])
//    
//    
//                // Add the background view to the stack view
//                tagStackView.addArrangedSubview(tagBackgroundView)
//            }
//    
//    
//            return tagStackView
//        }
//    
//    
//        private func generateQRCode(from string: String) -> UIImage? {
//            let data = string.data(using: String.Encoding.ascii)
//            if let filter = CIFilter(name: "CIQRCodeGenerator") {
//                filter.setValue(data, forKey: "inputMessage")
//                let transform = CGAffineTransform(scaleX: 10, y: 10)
//                if let output = filter.outputImage?.transformed(by: transform) {
//                    return UIImage(ciImage: output)
//                }
//            }
//            return nil
//        }
//    
//    }


//class BillingView: UIView {
//    
//    let topView = UIView()
//    let billingSection = UIView()
//    var topViewHeightConstraint: NSLayoutConstraint?
//    
//    private let centerImageView = UIImageView()
//    private let titleLabel = UILabel()
//    private let descriptionLabel = UILabel()
//    
//    //-------------------
//    let packageTitleLabel = UILabel()
//    let packageLabel = UILabel()
//    let trainerDetailTitleLabel = UILabel()
//    let trainerNameLabel = UILabel()
//    let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
//    let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
//    let qrCodeImageView = UIImageView()
//    let locBtn = UIButton(type: .custom)
//    let footerLabel = UILabel()
//    
//    var trainerTags:[String]? {
//        didSet{
//            self.setNeedsDisplay()
//        }
//    }
//    
//    var startDate:(title:String,value:String)? {
//        didSet{
//            self.setNeedsDisplay()
//        }
//    }
//    
//    var timingTxt:(title:String,value:String)? {
//        didSet{
//            self.setNeedsDisplay()
//        }
//    }
//    
//    var locationTxt:(title:String,value:String)? {
//        didSet{
//            self.setNeedsDisplay()
//        }
//    }
//    
//    var validUptoDate:(title:String,value:String)? {
//        didSet{
//            self.setNeedsDisplay()
//        }
//    }
//    
//    var cornerSide:UIRectCorner? = .allCorners {
//        didSet {
//            self.setNeedsDisplay()
//        }
//    }
//    
//    var cornerSize:CGSize = CGSize(width: 12, height: 12) {
//        didSet{
//            self.setNeedsDisplay()
//        }
//    }
//    
//    
//    
//    //-------------------------
//    var path: UIBezierPath = UIBezierPath()
//    var billBackgroundColor:UIColor? = UIColor.white {
//        didSet{
//            self.setNeedsDisplay()
//        }
//    }
//    
//    var lineBgColor:UIColor? = UIColor.darkGray {
//        didSet{
//            self.setNeedsDisplay()
//        }
//    }
//    
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.setupUI()
//        // Update layout of subviews or other properties here
//        print("layoutSubviews is called")
//        self.setupTopUI()
//       
////        self.topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), shadowRadius: 3, opacity: 0.3, offset: CGSize(width: 0, height: 15), cornerRadius: 12)
//        self.topView.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), offSet: CGSize(width: 0, height: 15), opacity: 0.3, shadowRadius: 3, cornerRadious: 12)
//        
//    }
//    
//    // Set you circle position for verticle.
//    var circleYPosition: CGFloat = 50 {
//        didSet {
//            self.setNeedsDisplay()
//        }
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.backgroundColor = UIColor.clear
//        // Here apply shadow
//        //        setupUI()
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = .clear
//        setupUI()
//        setupInitialState()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        self.backgroundColor = .clear
//        setupUI()
//        setupInitialState()
//    }
//    
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        
//        //        setupUI()
//        
//        // 4 corners radious
//        //        UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 24, height: 24)).addClip()
//        
//        UIBezierPath(roundedRect: rect, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize).addClip()
//        
//        // Left - right circle
//        path.move(to: CGPoint(x: 0, y: self.frame.size.height))
//        
//        //left side
//        path.addArc(withCenter: CGPoint(x: 0, y: self.circleYPosition - 15),
//                    radius: 34,
//                    startAngle: CGFloat((90 * Double.pi) / 180),
//                    endAngle: CGFloat((270 * Double.pi) / 180),
//                    clockwise: false)
//        
//        path.addLine(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
//        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
//        
//        path.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
//        
//        //right side
//        path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: self.circleYPosition - 15),
//                    radius: 34,
//                    startAngle: CGFloat((270 * Double.pi) / 180),
//                    endAngle: CGFloat((90 * Double.pi) / 180),
//                    clockwise: false)
//        
//        
//        path.close()
//        //        UIColor.white.setFill()
//        billBackgroundColor?.setFill()
//        path.fill()
//        
//        // Center Dash path
//        let dashPath = UIBezierPath()
//        dashPath.move(to: CGPoint(x: self.bounds.minX + 34, y: self.circleYPosition - 15))
//        dashPath.addLine(to: CGPoint(x: self.bounds.maxX - 34, y: self.circleYPosition - 15))
//        dashPath.setLineDash([5,5], count: 2, phase: 0.0)
//        dashPath.lineWidth = 1.0
//        dashPath.lineCapStyle = .butt
//        //        UIColor.green.set()
//        
//        if let lineBgColor = lineBgColor  {
//            lineBgColor.set()
//        }
//        
//        dashPath.stroke()
//        
//    }
//    
//    //---------------------------
//    
//    private func setupInitialState() {
//        // Set initial states for animation
//        billingSection.alpha = 0 // Initially hidden
//    }
//    
//    
//    private func setupUI() {
//        
//        
//        // MARK: - Labels and UI Elements
//        // Package Title Label
//        //     packageTitleLabel = UILabel()
//        packageTitleLabel.text = "Package"
//        packageTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
//        packageTitleLabel.textColor = .darkGray
//        packageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Package Label
//        //        let packageLabel = UILabel()
//        packageLabel.text = "12 months, Elite Gym Membership"
//        packageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//        packageLabel.textColor = .black
//        packageLabel.translatesAutoresizingMaskIntoConstraints = false
//        packageLabel.numberOfLines = 2
//        
//        // Start Date Label
//        //startDate
//        let startDateLabel = createDetailLabel(title: startDate?.title ?? "", value: startDate?.value ?? "")  //createDetailLabel(title: "Start Date", value: "06/24")
//        let validUptoLabel = createDetailLabel(title: validUptoDate?.title ?? "", value: validUptoDate?.value ?? "") //createDetailLabel(title: "Valid Upto", value: "06/25")
//        
//        // Trainer Section
//        let trainerImageView = UIImageView(image: UIImage(named: "ic_trainer"))
//        trainerImageView.contentMode = .scaleAspectFill
//        trainerImageView.layer.cornerRadius = 25
//        trainerImageView.clipsToBounds = true
//        trainerImageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Trainer detail Title Label
//        //        let trainerDetailTitleLabel = UILabel()
//        trainerDetailTitleLabel.text = "Trainer Details"
//        trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
//        trainerDetailTitleLabel.textColor = .darkGray
//        trainerDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        //        let trainerNameLabel = UILabel()
//        trainerNameLabel.text = "Christene De Koning"
//        trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        trainerNameLabel.textColor = .black
//        trainerNameLabel.numberOfLines = 2
//        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        //        let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
//        trainerBadgeImageView.contentMode = .scaleAspectFill
//        trainerBadgeImageView.layer.cornerRadius = 10
//        trainerBadgeImageView.clipsToBounds = true
//        trainerBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        
//        //        let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
//        nextImageView.contentMode = .scaleAspectFill
//        nextImageView.layer.cornerRadius = 15
//        nextImageView.clipsToBounds = true
//        nextImageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        //trainerTags
//        //["Cardio", "Pilates", "+3"]
//        let trainerTagsLabel = createTagView(tags: trainerTags ?? [])
//        
//        // Timing and Location
//        let timingLabel = createDetailLabel(title: timingTxt?.title ?? "", value: timingTxt?.value ?? "") //createDetailLabel(title: "Timing", value: "10:00 to 11:00")
//        let locationLabel = createDetailLabel(title: locationTxt?.title ?? "", value: locationTxt?.value ?? "") //createDetailLabel(title: "Location", value: "MyPT Dubai")
//        
//        
//        // QR Code
//        //        let qrCodeImageView = UIImageView()
//        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
//        qrCodeImageView.contentMode = .scaleAspectFit
//        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        //Get Direction
//        //        let locBtn = UIButton(type: .custom)
//        locBtn.backgroundColor = UIColor.clear
//        locBtn.setTitle("Get Direction", for: .normal)
//        locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
//        //        locBtn.tintColor = UIColor.blue //rgba(73, 129, 242, 1)
//        locBtn.setTitleColor(UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1), for: .normal)
//        locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        locBtn.translatesAutoresizingMaskIntoConstraints = false
//        // Set semanticContentAttribute to force right-to-left layout
//        locBtn.semanticContentAttribute = .forceRightToLeft
//        
//        // Optional: Adjust spacing between image and title
//        locBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
//        locBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -8)
//        
//        // Footer Note
//        //        let footerLabel = UILabel()
//        footerLabel.text = "Scan the QR code to access the gym premises."
//        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        footerLabel.textColor = .gray
//        footerLabel.textAlignment = .center
//        footerLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Add Subviews to Ticket Container
//        self.addSubview(packageTitleLabel)
//        self.addSubview(packageLabel)
//        self.addSubview(startDateLabel)
//        self.addSubview(validUptoLabel)
//        self.addSubview(trainerImageView)
//        self.addSubview(trainerBadgeImageView)
//        self.addSubview(nextImageView)
//        self.addSubview(trainerDetailTitleLabel)
//        self.addSubview(trainerNameLabel)
//        self.addSubview(trainerTagsLabel)
//        self.addSubview(timingLabel)
//        self.addSubview(locationLabel)
//        self.addSubview(locBtn)
//        self.addSubview(qrCodeImageView)
//        self.addSubview(footerLabel)
//        
//        // MARK: - Layout Constraints
//        NSLayoutConstraint.activate([
//            
//            packageTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
//            packageTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
//            packageTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
//            
//            // Package Label
//            packageLabel.topAnchor.constraint(equalTo: packageTitleLabel.bottomAnchor, constant: 10),
//            packageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
//            packageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
//            //            packageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            
//            // Start Date and Valid Upto
//            startDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            startDateLabel.topAnchor.constraint(equalTo: packageLabel.bottomAnchor, constant: 20),
//            
//            validUptoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//            validUptoLabel.topAnchor.constraint(equalTo: packageLabel.bottomAnchor, constant: 20),
//            
//            // Trainer Section
//            trainerDetailTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            trainerDetailTitleLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 20),
//            
//            trainerImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            trainerImageView.topAnchor.constraint(equalTo: trainerDetailTitleLabel.bottomAnchor, constant: 12),
//            trainerImageView.widthAnchor.constraint(equalToConstant: 50),
//            trainerImageView.heightAnchor.constraint(equalToConstant: 50),
//            
//            trainerNameLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
//            trainerNameLabel.topAnchor.constraint(equalTo: trainerImageView.topAnchor),
//            
//            trainerBadgeImageView.leadingAnchor.constraint(equalTo: trainerNameLabel.trailingAnchor, constant: 2),
//            trainerBadgeImageView.topAnchor.constraint(equalTo: trainerNameLabel.topAnchor, constant: 2),
//            trainerBadgeImageView.widthAnchor.constraint(equalToConstant: 20),
//            trainerBadgeImageView.heightAnchor.constraint(equalToConstant: 20),
//            trainerBadgeImageView.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -10),
//            
//            nextImageView.widthAnchor.constraint(equalToConstant: 30),
//            nextImageView.heightAnchor.constraint(equalToConstant: 30),
//            nextImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
//            nextImageView.centerYAnchor.constraint(equalTo: trainerImageView.centerYAnchor),
//            
//            trainerTagsLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
//            trainerTagsLabel.topAnchor.constraint(equalTo: trainerNameLabel.bottomAnchor, constant: 5),
//            
//            // Timing and Location
//            timingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            timingLabel.topAnchor.constraint(equalTo: qrCodeImageView.topAnchor, constant: 2),
//            
//            locationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            
//            locationLabel.topAnchor.constraint(equalTo: timingLabel.bottomAnchor, constant: 10),
//            locationLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
//            
//            // QR Code
//            qrCodeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//            qrCodeImageView.topAnchor.constraint(equalTo: self.centerYAnchor, constant: self.circleYPosition + 10),
//            qrCodeImageView.widthAnchor.constraint(equalToConstant: 100),
//            qrCodeImageView.heightAnchor.constraint(equalToConstant: 100),
//            
//            
//            // Footer Note
//            footerLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
//            footerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
//            footerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
//            locBtn.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
//            locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: footerLabel.topAnchor, multiplier: -12),
//            locBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
//            locBtn.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: self.trailingAnchor, multiplier: -12),
//            locBtn.heightAnchor.constraint(equalToConstant: 35),
//            
//        ])
//        
//        topView.translatesAutoresizingMaskIntoConstraints = false
//        topView.backgroundColor = .black // Adjust color as needed
//        addSubview(topView)
//        
//    
//        // Add height constraint for the topView
//        topViewHeightConstraint = self.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
//        topViewHeightConstraint?.isActive = true
//        
//        NSLayoutConstraint.activate([
//            topView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            topView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            topView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
//            topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
//        ])
//        
//    
//        /*
//         
//         topView.translatesAutoresizingMaskIntoConstraints = false
//         topView.backgroundColor = .black // Adjust color as needed
//         addSubview(topView)
//         
//         //        // Billing Section
//         //        billingSection.translatesAutoresizingMaskIntoConstraints = false
//         //        billingSection.backgroundColor = .lightGray // Adjust color as needed
//         //        addSubview(billingSection)
//         
//         // Add constraints for `topView` and `billingSection`
//         NSLayoutConstraint.activate([
//         // Top View initially centered
//         topView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//         topView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//         topView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
//         topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0),
//         
//         //                    // Billing Section initially off-screen
//         //                    billingSection.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//         //                    billingSection.topAnchor.constraint(equalTo: self.bottomAnchor),
//         //                    billingSection.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
//         //                    billingSection.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.6)
//         ])
//         */
//    }
//    
//    //-----------Top view setup
//
//    
//    // Animation Method
//    func startAnimation(duration: TimeInterval = 0.5, delay: TimeInterval = 1, imageYOffset: CGFloat = -100, completion: (() -> Void)? = nil ) {
//        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
//            if let superview = self.superview {
//                // Move the top view up
//                self.topView.transform = CGAffineTransform(translationX: 0, y: -superview.bounds.height / 2 + self.topView.bounds.height / 2 + 20)
//                
//            }
//        }) { _ in
//            // After the animation completes, animate the appearance of the labels
//            UIView.animate(withDuration: duration, animations: {
//                
//                self.topViewHeightConstraint = self.topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
//                self.topViewHeightConstraint?.isActive = true
//                
//                self.topLbl()
//            })
//            completion?()
//        }
//    }
//    
//    
//    // setupTopUI
//    private func setupTopUI() {
//        topView.backgroundColor = UIColor.mainBg
//        centerImageView.backgroundColor = .clear
//        
//        // Add shadow for depth
////        topView.layer.shadowColor = UIColor.red.cgColor
////        topView.layer.shadowOpacity = 1.0
////        topView.layer.shadowOffset = CGSize(width: 0, height: 15)
////        topView.layer.shadowRadius = 10
//        
////        topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor.red, shadowRadius: 0, opacity: 1.0, offset: CGSize(width: 0, height: 10), cornerRadius: 12)
//        
//       
//        
//        // Center Image
//        centerImageView.contentMode = .scaleAspectFit
//        centerImageView.translatesAutoresizingMaskIntoConstraints = false
//        topView.addSubview(centerImageView)
//        
//        //        // Title Label
//        //        titleLabel.textAlignment = .center
//        //        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        //        titleLabel.textColor = .white
//        //        titleLabel.alpha = 0 // Hidden initially
//        //        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        //        topView.addSubview(titleLabel)
//        //
//        //        // Description Label
//        //        descriptionLabel.textAlignment = .center
//        //        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        //        descriptionLabel.textColor = UIColor.txtDarkGray
//        //        descriptionLabel.numberOfLines = 0
//        //        descriptionLabel.alpha = 0 // Hidden initially
//        //        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        //        topView.addSubview(descriptionLabel)
//        
//        // Add Constraints
//        NSLayoutConstraint.activate([
//            centerImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
////            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
//            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 50.0),
//            centerImageView.widthAnchor.constraint(equalToConstant: 80),
//            centerImageView.heightAnchor.constraint(equalToConstant: 80),
//            
//            //            titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
//            //            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
//            //            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
//            //
//            //            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
//            //            descriptionLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
//            //            descriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
//            //            // Add bottom constraint to description label (it will automatically adjust after topView height is changed)
//            //            descriptionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -20)
//        ])
//        
//    }
//    
//    private func topLbl(){
//        // Title Label
//        titleLabel.textAlignment = .center
//        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        titleLabel.textColor = .white
//        titleLabel.alpha = 1 // Hidden initially
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        topView.addSubview(titleLabel)
//        
//        // Description Label
//        descriptionLabel.textAlignment = .center
//        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        descriptionLabel.textColor = UIColor.txtDarkGray
//        descriptionLabel.numberOfLines = 0
//        descriptionLabel.alpha = 1 // Hidden initially
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        topView.addSubview(descriptionLabel)
//        // Add Constraints
//        NSLayoutConstraint.activate([
//            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: -30.0),
//            titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
//            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
//            
//            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
//            descriptionLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
//            descriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
//            // Add bottom constraint to description label (it will automatically adjust after topView height is changed)
//            descriptionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -20)
//        ])
//        
//    }
//    
//    
//    // Configuration Method
//    func configure(title: String, description: String, imageName: String) {
//        titleLabel.text = title
//        descriptionLabel.text = description
//        centerImageView.image = UIImage(named: imageName)
//    }
//    
//    
//    //---------------------_****************
//    // MARK: - Helper Functions
//    private func createDetailLabel(title: String, value: String) -> UILabel {
//        let label = UILabel()
//        let attributedText = NSMutableAttributedString(
//            string: "\(title)\n",
//            attributes: [
//                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
//                .foregroundColor: UIColor.gray
//            ]
//        )
//        attributedText.append(
//            NSAttributedString(
//                string: "\n",
//                attributes: [
//                    .font: UIFont.systemFont(ofSize: 10, weight: .regular),
//                    .foregroundColor: UIColor.black
//                ]
//            )
//        )
//        attributedText.append(
//            NSAttributedString(
//                string: value,
//                attributes: [
//                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
//                    .foregroundColor: UIColor.black
//                ]
//            )
//        )
//        label.attributedText = attributedText
//        label.numberOfLines = 3
//        label.textAlignment = .left
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }
//    
//    private func createTagView(tags: [String]) -> UIView {
//        let tagStackView = UIStackView()
//        tagStackView.axis = .horizontal
//        tagStackView.spacing = 5
//        tagStackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        for tag in tags {
//            // Create the background view
//            let tagBackgroundView = UIView()
//            tagBackgroundView.backgroundColor = UIColor.black
//            tagBackgroundView.layer.cornerRadius = 6
//            tagBackgroundView.layer.masksToBounds = true
//            tagBackgroundView.translatesAutoresizingMaskIntoConstraints = false
//            
//            // Create the label
//            let tagLabel = UILabel()
//            tagLabel.text = tag
//            tagLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
//            tagLabel.textColor = .white
//            tagLabel.textAlignment = .center
//            tagLabel.translatesAutoresizingMaskIntoConstraints = false
//            
//            // Add the label to the background view
//            tagBackgroundView.addSubview(tagLabel)
//            
//            // Set constraints for the label to center it within the background view
//            NSLayoutConstraint.activate([
//                tagLabel.leadingAnchor.constraint(equalTo: tagBackgroundView.leadingAnchor, constant: 8),
//                tagLabel.trailingAnchor.constraint(equalTo: tagBackgroundView.trailingAnchor, constant: -8),
//                tagLabel.topAnchor.constraint(equalTo: tagBackgroundView.topAnchor, constant: 4),
//                tagLabel.bottomAnchor.constraint(equalTo: tagBackgroundView.bottomAnchor, constant: -4)
//            ])
//            
//            
//            // Add the background view to the stack view
//            tagStackView.addArrangedSubview(tagBackgroundView)
//        }
//        
//        
//        return tagStackView
//    }
//    
//    
//    private func generateQRCode(from string: String) -> UIImage? {
//        let data = string.data(using: String.Encoding.ascii)
//        if let filter = CIFilter(name: "CIQRCodeGenerator") {
//            filter.setValue(data, forKey: "inputMessage")
//            let transform = CGAffineTransform(scaleX: 10, y: 10)
//            if let output = filter.outputImage?.transformed(by: transform) {
//                return UIImage(ciImage: output)
//            }
//        }
//        return nil
//    }
//    
//}
