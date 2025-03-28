//
//  BillShape.swift
//  MyPT
//
//  Created by techsaga corp on 27/11/24.
//

import UIKit

class BillShape: UIView {
    
     let scrollView = UIScrollView()
     let contentView = UIView()
    private let lineSubView = UIView()

    let packageTitleLabel = UILabel()
    let packageLabel = UILabel()
    let trainerDetailTitleLabel = UILabel()
    let trainerNameLabel = UILabel()
    let trainerImageView = UIImageView()
    let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
    let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
    let qrCodeImageView = UIImageView()
    let locBtn = UIButton(type: .custom)
    let footerLabel = UILabel()
    
    private var startDateLabl = UILabel()
    private var validUptoLabel = UILabel()
    private var timingLabel = UILabel()
    private var locationLabel = UILabel()

    private var trainerTagsLabel: UIStackView = TagViewHelper.createTagView(tags: []) as! UIStackView

    var trainerTags: [String]? {
        didSet {
            updateTagView()
            self.setNeedsLayout()
        }
    }
    
    private func updateTagView() {
        guard let tags = trainerTags else { return }
        
        // Remove existing arranged subviews
        trainerTagsLabel.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add new tags
        for tag in tags {
            let tagView = TagViewHelper.createTagView(tags: [tag])
            trainerTagsLabel.addArrangedSubview(tagView)
        }
    }
    
    var startDate:(title:String,value:String)? {
        didSet {
            startDateLabl.numberOfLines = 0
            startDateLabl.attributedText = createDetailAttributedString(title: (startDate?.title ?? ""), value: (startDate?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
    
    var validUptoDate:(title:String,value:String)? {
        didSet {
            validUptoLabel.numberOfLines = 0
            validUptoLabel.attributedText = createDetailAttributedString(title: (validUptoDate?.title ?? ""), value: (validUptoDate?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
   
    var timingTxt:(title:String,value:String)? {
        didSet {
            timingLabel.numberOfLines = 0
            timingLabel.attributedText = createDetailAttributedString(title: (timingTxt?.title ?? ""), value: (timingTxt?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
    
    var locationTxt:(title:String,value:String)? {
        didSet {
            locationLabel.numberOfLines = 0
            locationLabel.attributedText = createDetailAttributedString(title: (locationTxt?.title ?? ""), value: (locationTxt?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
    
    
    var cornerSide:UIRectCorner? = .allCorners {
        didSet { self.setNeedsLayout() }
    }
    
    var isDirection:Bool? = false {
        didSet { self.setNeedsLayout() }
    }
    
    var cornerSize:CGSize = CGSize(width: 12, height: 12) {
        didSet { self.setNeedsLayout() }
    }
    
    var path: UIBezierPath = UIBezierPath()
    var billBackgroundColor:UIColor? = UIColor.white {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var lineBgColor:UIColor? = UIColor.darkGray {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    // Set you circle position for verticle.
    var circleYPosition: CGFloat = 100 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
        setupUI()
    }
    
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        setupContent()
        
    }
    
    private func setupContent() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        let topTitleView = UIView()
        topTitleView.backgroundColor = UIColor.clear
        topTitleView.addSubview(packageTitleLabel)
        topTitleView.addSubview(packageLabel)
        stackView.addArrangedSubview(topTitleView)
        packageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        packageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            packageTitleLabel.topAnchor.constraint(equalTo: topTitleView.topAnchor, constant: 10),
            packageTitleLabel.leadingAnchor.constraint(equalTo: topTitleView.leadingAnchor, constant: 1),
            packageTitleLabel.trailingAnchor.constraint(equalTo: topTitleView.trailingAnchor, constant: -1),
            packageLabel.topAnchor.constraint(equalTo: packageTitleLabel.bottomAnchor, constant: 1),
            packageLabel.leadingAnchor.constraint(equalTo: topTitleView.leadingAnchor, constant: 1),
            packageLabel.trailingAnchor.constraint(equalTo: topTitleView.trailingAnchor, constant: -1),
            packageLabel.bottomAnchor.constraint(equalTo: topTitleView.bottomAnchor, constant: -10)
        ])
      
        // Start Date Label
        startDateLabl.backgroundColor = UIColor.clear
        startDateLabl.textAlignment = .left
        validUptoLabel.textAlignment = .right
        validUptoLabel.backgroundColor = UIColor.clear
        
        let startView = UIView()
        startView.backgroundColor = UIColor.clear
        startView.addSubview(startDateLabl)
        startView.addSubview(validUptoLabel)
        stackView.addArrangedSubview(startView)
        startDateLabl.translatesAutoresizingMaskIntoConstraints = false
        validUptoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startDateLabl.topAnchor.constraint(equalTo: startView.topAnchor, constant: 10),
            startDateLabl.leadingAnchor.constraint(equalTo: startView.leadingAnchor, constant: 1),
            startDateLabl.widthAnchor.constraint(equalTo: startView.widthAnchor, multiplier: 0.5),
            startDateLabl.bottomAnchor.constraint(equalTo: startView.bottomAnchor, constant: -10),
            validUptoLabel.topAnchor.constraint(equalTo: startDateLabl.topAnchor, constant: 0),
            validUptoLabel.leadingAnchor.constraint(equalTo: startDateLabl.trailingAnchor, constant: 1),
            validUptoLabel.trailingAnchor.constraint(equalTo: startView.trailingAnchor, constant: -1),
            validUptoLabel.bottomAnchor.constraint(equalTo: startDateLabl.bottomAnchor, constant: 0)
        ])
        
        //-----------------------------------------***********************
        
        // Trainer Section
        trainerImageView.contentMode = .scaleAspectFill
        trainerImageView.layer.cornerRadius = 25
        trainerImageView.clipsToBounds = true
        trainerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Trainer detail Title Label
        trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        trainerDetailTitleLabel.textColor = .darkGray
        trainerDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    
        trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        trainerNameLabel.textColor = .black
        trainerNameLabel.numberOfLines = 2
        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        trainerBadgeImageView.contentMode = .scaleAspectFill
        trainerBadgeImageView.layer.cornerRadius = 10
        trainerBadgeImageView.clipsToBounds = true
        trainerBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nextImageView.contentMode = .scaleAspectFill
        nextImageView.layer.cornerRadius = 15
        nextImageView.clipsToBounds = true
        nextImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //trainerTags
        //["Cardio", "Pilates", "+3"]
//        let trainerTagsLabel = createTagView(tags: trainerTags ?? [])
        
        trainerTagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let customerDatailsView = UIView()
        customerDatailsView.backgroundColor = UIColor.clear
        
        customerDatailsView.addSubview(trainerDetailTitleLabel)
        customerDatailsView.addSubview(trainerImageView)
        customerDatailsView.addSubview(trainerNameLabel)
        customerDatailsView.addSubview(trainerBadgeImageView)
        customerDatailsView.addSubview(nextImageView)
        customerDatailsView.addSubview(trainerTagsLabel)
        stackView.addArrangedSubview(customerDatailsView)
        
        // Trainer Section
        NSLayoutConstraint.activate([
            // Trainer Section
            trainerDetailTitleLabel.leadingAnchor.constraint(equalTo: customerDatailsView.leadingAnchor, constant: 0),
            trainerDetailTitleLabel.topAnchor.constraint(equalTo: customerDatailsView.topAnchor, constant: 2),
            
            trainerImageView.leadingAnchor.constraint(equalTo: customerDatailsView.leadingAnchor, constant: 0),
            trainerImageView.topAnchor.constraint(equalTo: trainerDetailTitleLabel.bottomAnchor, constant: 12),
            trainerImageView.widthAnchor.constraint(equalToConstant: 50),
            trainerImageView.heightAnchor.constraint(equalToConstant: 50),
            
            trainerNameLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerNameLabel.topAnchor.constraint(equalTo: trainerImageView.topAnchor),
            
            trainerBadgeImageView.leadingAnchor.constraint(equalTo: trainerNameLabel.trailingAnchor, constant: 2),
            trainerBadgeImageView.topAnchor.constraint(equalTo: trainerNameLabel.topAnchor, constant: 2),
            trainerBadgeImageView.widthAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.heightAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -10),
            
            nextImageView.widthAnchor.constraint(equalToConstant: 30),
            nextImageView.heightAnchor.constraint(equalToConstant: 30),
            nextImageView.trailingAnchor.constraint(equalTo: customerDatailsView.trailingAnchor, constant: -12),
            nextImageView.centerYAnchor.constraint(equalTo: trainerImageView.centerYAnchor),
            
            trainerTagsLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerTagsLabel.topAnchor.constraint(equalTo: trainerNameLabel.bottomAnchor, constant: 5),
            trainerTagsLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -5),
            trainerTagsLabel.bottomAnchor.constraint(equalTo: customerDatailsView.bottomAnchor, constant: -10),
        ])
        
    
        //-----------------Middle line view ----------------************************
        
        let lineMView = UIView()
        lineMView.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(lineMView)
        lineSubView.tag = 101
        
//        let lineSubView = UIView()
        lineSubView.backgroundColor = UIColor.clear
        lineMView.addSubview(lineSubView)
        
        lineSubView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineSubView.leadingAnchor.constraint(equalTo: lineMView.leadingAnchor, constant: 2),
            lineSubView.trailingAnchor.constraint(equalTo: lineMView.trailingAnchor, constant: -1),
            lineSubView.heightAnchor.constraint(equalToConstant: 30.0),
            lineSubView.topAnchor.constraint(equalTo: lineMView.topAnchor, constant: 2),
            lineSubView.bottomAnchor.constraint(equalTo: lineMView.bottomAnchor, constant: -2)
        ])
        
        //-----------------address bottom view ----------------************************
        
        let addressMView = UIView()
        addressMView.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(addressMView)
        
        
        // QR Code
//        let qrCodeImageView = UIImageView()
//        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
        qrCodeImageView.contentMode = .scaleAspectFit

        //Get Direction
        locBtn.backgroundColor = UIColor.clear
        locBtn.setTitleColor(UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1), for: .normal)
        locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        locBtn.translatesAutoresizingMaskIntoConstraints = false
        // Set semanticContentAttribute to force right-to-left layout
        locBtn.semanticContentAttribute = .forceRightToLeft
        
        // Optional: Adjust spacing between image and title
        locBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        locBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -8)
        
        timingLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        locBtn.translatesAutoresizingMaskIntoConstraints = false
        
        addressMView.addSubview(timingLabel)
        addressMView.addSubview(locationLabel)
        addressMView.addSubview(locBtn)
        addressMView.addSubview(qrCodeImageView)
        
        if let isDirection = isDirection {
            locBtn.isHidden = !isDirection
        }
        
        // MARK: - Layout Constraints
        NSLayoutConstraint.activate([
            
            // QR Code
            qrCodeImageView.trailingAnchor.constraint(equalTo: addressMView.trailingAnchor, constant: 0),
            qrCodeImageView.topAnchor.constraint(equalTo: addressMView.topAnchor, constant: 10),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 145),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 145),
            
            // Timing and Location
            timingLabel.leadingAnchor.constraint(equalTo: addressMView.leadingAnchor, constant: 1),
            timingLabel.topAnchor.constraint(equalTo: qrCodeImageView.topAnchor, constant: 2),
            timingLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
            
            locationLabel.leadingAnchor.constraint(equalTo: addressMView.leadingAnchor, constant: 1),
            
            locationLabel.topAnchor.constraint(equalTo: timingLabel.bottomAnchor, constant: 10),
            locationLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
            
            locBtn.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 1),
//            locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: addressMView.bottomAnchor, multiplier: -12),
            locBtn.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor, constant: 0),
            locBtn.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: qrCodeImageView.leadingAnchor, multiplier: -12),
            locBtn.heightAnchor.constraint(equalToConstant: 25),
            locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: addressMView.bottomAnchor, multiplier: -12)
//            locBtn.bottomAnchor.constraint(equalTo: addressMView.bottomAnchor, constant: -30)
            
        ])
        
        
        //---------------################
       
        packageTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        packageTitleLabel.textColor = .darkGray
        
        packageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        packageLabel.textColor = .black
        packageLabel.numberOfLines = 0
        
        trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        trainerDetailTitleLabel.textColor = .darkGray
        
        trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        trainerNameLabel.textColor = .black
        trainerNameLabel.numberOfLines = 2
        
//        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        qrCodeImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        locBtn.setTitleColor(UIColor.blue, for: .normal)
        locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        footerLabel.textColor = .gray
        footerLabel.textAlignment = .center
        
        stackView.addArrangedSubview(footerLabel)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
//        print("lineSubView frame: \(lineSubView.frame)")
//        if let lineMView = lineSubView.superview {
//            print("lineMView frame: \(lineMView.frame)")
//            print("lineMView.frame.origin.y: \(lineMView.frame.origin.y)")
//
//            self.circleYPosition = lineMView.frame.origin.y
//        }
        
        print("qrCodeImageView frame: \(qrCodeImageView.frame)")
        if let qrView = qrCodeImageView.superview {
            print("qrView frame: \(qrView.frame)")
            print("qrView.frame.origin.y: \(qrView.frame.origin.y)")
            
            self.circleYPosition = qrView.frame.origin.y
        }

        /*
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize)
        path.addClip()
        UIColor.white.setFill()
        path.fill()
        */
        
        //        setupUI()
        
        // 4 corners radious
        //        UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 24, height: 24)).addClip()
        
        UIBezierPath(roundedRect: rect, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize).addClip()
        
        // Left - right circle
        path.move(to: CGPoint(x: 0, y: self.frame.size.height))
        
        

        
        //left side
        path.addArc(withCenter: CGPoint(x: 0, y: self.circleYPosition - 15),
                    radius: 34,
                    startAngle: CGFloat((90 * Double.pi) / 180),
                    endAngle: CGFloat((270 * Double.pi) / 180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        path.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        //right side
        path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: self.circleYPosition - 15),
                    radius: 34,
                    startAngle: CGFloat((270 * Double.pi) / 180),
                    endAngle: CGFloat((90 * Double.pi) / 180),
                    clockwise: false)
        
        
        path.close()
        //        UIColor.white.setFill()
        billBackgroundColor?.setFill()
        path.fill()
        
        // Center Dash path
        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: self.bounds.minX + 34, y: self.circleYPosition - 15))
        dashPath.addLine(to: CGPoint(x: self.bounds.maxX - 34, y: self.circleYPosition - 15))
        dashPath.setLineDash([5,5], count: 2, phase: 0.0)
        dashPath.lineWidth = 1.0
        dashPath.lineCapStyle = .butt
        //        UIColor.green.set()
        
        if let lineBgColor = lineBgColor  {
            lineBgColor.set()
        }
        
        dashPath.stroke()

        
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    //---------------------_****************
    // MARK: - Helper Functions
    private func createDetailAttributedString(title: String, value: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: "\(title)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
        )
        
        attributedText.append(
            NSAttributedString(
                string: "\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                    .foregroundColor: UIColor.black
                ]
            )
        )
        
        attributedText.append(
            NSAttributedString(
                string: value,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor.black
                ]
            )
        )
        
        return attributedText
    }
    
}





//------------------------------_*************************

class TopAnimatedView: UIView {

    // MARK: - UI Components
    private let topView = UIView()
    private let centerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private var topViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTopView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTopView()
    }

    // MARK: - Setup UI
    private func setupTopView() {
        // Setup topView
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = .red // Change color as needed
        addSubview(topView)

        // Constraints for topView
        topViewHeightConstraint = topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
        topViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            topView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            topView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            topView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
            topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
        ])

        setupTopUI()
    }
    
    private func setupTopUI() {
        topView.backgroundColor = UIColor.white
        centerImageView.backgroundColor = .clear
        centerImageView.contentMode = .scaleAspectFit
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(centerImageView)
        
        // Constraints for Image
        NSLayoutConstraint.activate([
            centerImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 50),
            centerImageView.widthAnchor.constraint(equalToConstant: 80),
            centerImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        self.showLabels()
    }

    // MARK: - Animation
    func startAnimation(duration: TimeInterval = 0.5, delay: TimeInterval = 1, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            if let superview = self.superview {
                self.topView.transform = CGAffineTransform(translationX: 0, y: -superview.bounds.height / 2 + self.topView.bounds.height / 2 + 20)
            }
        }) { _ in
            UIView.animate(withDuration: duration, animations: {
//                self.topViewHeightConstraint?.isActive = false
                self.topViewHeightConstraint = self.topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3)
                self.topViewHeightConstraint?.isActive = true
                self.layoutIfNeeded()
                self.showLabels()
            })
            completion?()
        }
    }
    
    private func showLabels() {
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.alpha = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(titleLabel)

        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.alpha = 1
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(descriptionLabel)
        
        topView.addSubview(centerImageView)
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints for Image
        NSLayoutConstraint.activate([
            centerImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 50),
            centerImageView.widthAnchor.constraint(equalToConstant: 80),
            centerImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        

        // Constraints for labels
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: topView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Configuration Method
    func configure(title: String, description: String, imageName: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        centerImageView.image = UIImage(named: imageName)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.topView.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor.black, offSet: CGSize(width: 0, height: 15), opacity: 0.3, shadowRadius: 3, cornerRadious: 12)
    }
    
}

/*
class BillShape: UIView {
   
    let topView = UIView()
    var topViewHeightConstraint: NSLayoutConstraint?
    
    private let centerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    
    //--------------------
     let scrollView = UIScrollView()
     let contentView = UIView()
    private let lineSubView = UIView()

    let packageTitleLabel = UILabel()
    let packageLabel = UILabel()
    let trainerDetailTitleLabel = UILabel()
    let trainerNameLabel = UILabel()
    let trainerImageView = UIImageView()
    let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
    let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
    let qrCodeImageView = UIImageView()
    let locBtn = UIButton(type: .custom)
    let footerLabel = UILabel()
    
    private var startDateLabl = UILabel()
    private var validUptoLabel = UILabel()
    private var timingLabel = UILabel()
    private var locationLabel = UILabel()

    private var trainerTagsLabel: UIStackView = TagViewHelper.createTagView(tags: []) as! UIStackView

    var trainerTags: [String]? {
        didSet {
            updateTagView()
            self.setNeedsLayout()
        }
    }
    
    private func updateTagView() {
        guard let tags = trainerTags else { return }
        
        // Remove existing arranged subviews
        trainerTagsLabel.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add new tags
        for tag in tags {
            let tagView = TagViewHelper.createTagView(tags: [tag])
            trainerTagsLabel.addArrangedSubview(tagView)
        }
    }
    
    var startDate:(title:String,value:String)? {
        didSet {
            startDateLabl.numberOfLines = 0
            startDateLabl.attributedText = createDetailAttributedString(title: (startDate?.title ?? ""), value: (startDate?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
    
    var validUptoDate:(title:String,value:String)? {
        didSet {
            validUptoLabel.numberOfLines = 0
            validUptoLabel.attributedText = createDetailAttributedString(title: (validUptoDate?.title ?? ""), value: (validUptoDate?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
   
    var timingTxt:(title:String,value:String)? {
        didSet {
            timingLabel.numberOfLines = 0
            timingLabel.attributedText = createDetailAttributedString(title: (timingTxt?.title ?? ""), value: (timingTxt?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
    
    var locationTxt:(title:String,value:String)? {
        didSet {
            locationLabel.numberOfLines = 0
            locationLabel.attributedText = createDetailAttributedString(title: (locationTxt?.title ?? ""), value: (locationTxt?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
    
    
    var cornerSide:UIRectCorner? = .allCorners {
        didSet { self.setNeedsLayout() }
    }
    
    var isDirection:Bool? = false {
        didSet { self.setNeedsLayout() }
    }
    
    var cornerSize:CGSize = CGSize(width: 12, height: 12) {
        didSet { self.setNeedsLayout() }
    }
    
    var path: UIBezierPath = UIBezierPath()
    var billBackgroundColor:UIColor? = UIColor.white {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var lineBgColor:UIColor? = UIColor.darkGray {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    // Set you circle position for verticle.
    var circleYPosition: CGFloat = 100 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupUI()
        setupTopView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
        setupUI()
        setupTopView()
    }
    
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.delegate = self // Set the delegate
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        setupContent()
        
    }
    
    private func setupContent() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        let topTitleView = UIView()
        topTitleView.backgroundColor = UIColor.clear
        topTitleView.addSubview(packageTitleLabel)
        topTitleView.addSubview(packageLabel)
        stackView.addArrangedSubview(topTitleView)
        packageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        packageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            packageTitleLabel.topAnchor.constraint(equalTo: topTitleView.topAnchor, constant: 20),
            packageTitleLabel.leadingAnchor.constraint(equalTo: topTitleView.leadingAnchor, constant: 1),
            packageTitleLabel.trailingAnchor.constraint(equalTo: topTitleView.trailingAnchor, constant: -1),
            packageLabel.topAnchor.constraint(equalTo: packageTitleLabel.bottomAnchor, constant: 1),
            packageLabel.leadingAnchor.constraint(equalTo: topTitleView.leadingAnchor, constant: 1),
            packageLabel.trailingAnchor.constraint(equalTo: topTitleView.trailingAnchor, constant: -1),
            packageLabel.bottomAnchor.constraint(equalTo: topTitleView.bottomAnchor, constant: -10)
        ])
      
        // Start Date Label
        startDateLabl.backgroundColor = UIColor.clear
        startDateLabl.textAlignment = .left
        validUptoLabel.textAlignment = .right
        validUptoLabel.backgroundColor = UIColor.clear
        
        let startView = UIView()
        startView.backgroundColor = UIColor.clear
        startView.addSubview(startDateLabl)
        startView.addSubview(validUptoLabel)
        stackView.addArrangedSubview(startView)
        startDateLabl.translatesAutoresizingMaskIntoConstraints = false
        validUptoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startDateLabl.topAnchor.constraint(equalTo: startView.topAnchor, constant: 10),
            startDateLabl.leadingAnchor.constraint(equalTo: startView.leadingAnchor, constant: 1),
            startDateLabl.widthAnchor.constraint(equalTo: startView.widthAnchor, multiplier: 0.5),
            startDateLabl.bottomAnchor.constraint(equalTo: startView.bottomAnchor, constant: -10),
            validUptoLabel.topAnchor.constraint(equalTo: startDateLabl.topAnchor, constant: 0),
            validUptoLabel.leadingAnchor.constraint(equalTo: startDateLabl.trailingAnchor, constant: 1),
            validUptoLabel.trailingAnchor.constraint(equalTo: startView.trailingAnchor, constant: -1),
            validUptoLabel.bottomAnchor.constraint(equalTo: startDateLabl.bottomAnchor, constant: 0)
        ])
        
        //-----------------------------------------***********************
        
        // Trainer Section
        trainerImageView.contentMode = .scaleAspectFill
        trainerImageView.layer.cornerRadius = 25
        trainerImageView.clipsToBounds = true
        trainerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Trainer detail Title Label
        trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        trainerDetailTitleLabel.textColor = .darkGray
        trainerDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    
        trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        trainerNameLabel.textColor = .black
        trainerNameLabel.numberOfLines = 2
        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        trainerBadgeImageView.contentMode = .scaleAspectFill
        trainerBadgeImageView.layer.cornerRadius = 10
        trainerBadgeImageView.clipsToBounds = true
        trainerBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nextImageView.contentMode = .scaleAspectFill
        nextImageView.layer.cornerRadius = 15
        nextImageView.clipsToBounds = true
        nextImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //trainerTags
        //["Cardio", "Pilates", "+3"]
//        let trainerTagsLabel = createTagView(tags: trainerTags ?? [])
        
        trainerTagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let customerDatailsView = UIView()
        customerDatailsView.backgroundColor = UIColor.clear
        
        customerDatailsView.addSubview(trainerDetailTitleLabel)
        customerDatailsView.addSubview(trainerImageView)
        customerDatailsView.addSubview(trainerNameLabel)
        customerDatailsView.addSubview(trainerBadgeImageView)
        customerDatailsView.addSubview(nextImageView)
        customerDatailsView.addSubview(trainerTagsLabel)
        stackView.addArrangedSubview(customerDatailsView)
        
        // Trainer Section
        NSLayoutConstraint.activate([
            // Trainer Section
            trainerDetailTitleLabel.leadingAnchor.constraint(equalTo: customerDatailsView.leadingAnchor, constant: 0),
            trainerDetailTitleLabel.topAnchor.constraint(equalTo: customerDatailsView.topAnchor, constant: 2),
            
            trainerImageView.leadingAnchor.constraint(equalTo: customerDatailsView.leadingAnchor, constant: 0),
            trainerImageView.topAnchor.constraint(equalTo: trainerDetailTitleLabel.bottomAnchor, constant: 12),
            trainerImageView.widthAnchor.constraint(equalToConstant: 50),
            trainerImageView.heightAnchor.constraint(equalToConstant: 50),
            
            trainerNameLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerNameLabel.topAnchor.constraint(equalTo: trainerImageView.topAnchor),
            
            trainerBadgeImageView.leadingAnchor.constraint(equalTo: trainerNameLabel.trailingAnchor, constant: 2),
            trainerBadgeImageView.topAnchor.constraint(equalTo: trainerNameLabel.topAnchor, constant: 2),
            trainerBadgeImageView.widthAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.heightAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -10),
            
            nextImageView.widthAnchor.constraint(equalToConstant: 30),
            nextImageView.heightAnchor.constraint(equalToConstant: 30),
            nextImageView.trailingAnchor.constraint(equalTo: customerDatailsView.trailingAnchor, constant: -12),
            nextImageView.centerYAnchor.constraint(equalTo: trainerImageView.centerYAnchor),
            
            trainerTagsLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerTagsLabel.topAnchor.constraint(equalTo: trainerNameLabel.bottomAnchor, constant: 5),
            trainerTagsLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -5),
            trainerTagsLabel.bottomAnchor.constraint(equalTo: customerDatailsView.bottomAnchor, constant: -10),
        ])
        
    
        //-----------------Middle line view ----------------************************
        
        let lineMView = UIView()
        lineMView.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(lineMView)
        lineSubView.tag = 101
        
//        let lineSubView = UIView()
        lineSubView.backgroundColor = UIColor.clear
        lineMView.addSubview(lineSubView)
        
        lineSubView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineSubView.leadingAnchor.constraint(equalTo: lineMView.leadingAnchor, constant: 2),
            lineSubView.trailingAnchor.constraint(equalTo: lineMView.trailingAnchor, constant: -1),
            lineSubView.heightAnchor.constraint(equalToConstant: 30.0),
            lineSubView.topAnchor.constraint(equalTo: lineMView.topAnchor, constant: 2),
            lineSubView.bottomAnchor.constraint(equalTo: lineMView.bottomAnchor, constant: -2)
        ])
                
        //-----------------address bottom view ----------------************************
        
        let addressMView = UIView()
        addressMView.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(addressMView)
        
        
        // QR Code
//        let qrCodeImageView = UIImageView()
//        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
        qrCodeImageView.contentMode = .scaleAspectFit

        //Get Direction
        locBtn.backgroundColor = UIColor.clear
        locBtn.setTitleColor(UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1), for: .normal)
        locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        locBtn.translatesAutoresizingMaskIntoConstraints = false
        // Set semanticContentAttribute to force right-to-left layout
        locBtn.semanticContentAttribute = .forceRightToLeft
        
        // Optional: Adjust spacing between image and title
        locBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        locBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -8)
        
        timingLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        locBtn.translatesAutoresizingMaskIntoConstraints = false
        
        addressMView.addSubview(timingLabel)
        addressMView.addSubview(locationLabel)
        addressMView.addSubview(locBtn)
        addressMView.addSubview(qrCodeImageView)
        
        if let isDirection = isDirection {
            locBtn.isHidden = !isDirection
        }
        
        // MARK: - Layout Constraints
        NSLayoutConstraint.activate([
            
            // QR Code
            qrCodeImageView.trailingAnchor.constraint(equalTo: addressMView.trailingAnchor, constant: 0),
            qrCodeImageView.topAnchor.constraint(equalTo: addressMView.topAnchor, constant: 10),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 145),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 145),
            
            // Timing and Location
            timingLabel.leadingAnchor.constraint(equalTo: addressMView.leadingAnchor, constant: 1),
            timingLabel.topAnchor.constraint(equalTo: qrCodeImageView.topAnchor, constant: 2),
            timingLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
            
            locationLabel.leadingAnchor.constraint(equalTo: addressMView.leadingAnchor, constant: 1),
            
            locationLabel.topAnchor.constraint(equalTo: timingLabel.bottomAnchor, constant: 10),
            locationLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
            
            locBtn.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 1),
//            locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: addressMView.bottomAnchor, multiplier: -12),
            locBtn.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor, constant: 0),
            locBtn.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: qrCodeImageView.leadingAnchor, multiplier: -12),
            locBtn.heightAnchor.constraint(equalToConstant: 25),
            locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: addressMView.bottomAnchor, multiplier: -12)
//            locBtn.bottomAnchor.constraint(equalTo: addressMView.bottomAnchor, constant: -30)
            
        ])
        
        
        //---------------################
       
        packageTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        packageTitleLabel.textColor = .darkGray
        
        packageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        packageLabel.textColor = .black
        packageLabel.numberOfLines = 0
        
        trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        trainerDetailTitleLabel.textColor = .darkGray
        
        trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        trainerNameLabel.textColor = .black
        trainerNameLabel.numberOfLines = 2
        
//        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        qrCodeImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        locBtn.setTitleColor(UIColor.blue, for: .normal)
        locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        footerLabel.textColor = .gray
        footerLabel.textAlignment = .center
        
        stackView.addArrangedSubview(footerLabel)
        
//        //--------------Make Top View
//        setupTopView()
    }
    
    func setupTopView(){
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = .black // Adjust color as needed
        addSubview(topView)
        
    
        // Add height constraint for the topView
        topViewHeightConstraint = self.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
        topViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            topView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            topView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            topView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
            topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
        ])
        
        
        self.setupTopUI()
//        self.setupUI()
    }
    
    private func setupTopUI() {
        topView.backgroundColor = UIColor.mainBg
        centerImageView.backgroundColor = .clear
        
        // Add shadow for depth
//        topView.layer.shadowColor = UIColor.red.cgColor
//        topView.layer.shadowOpacity = 1.0
//        topView.layer.shadowOffset = CGSize(width: 0, height: 15)
//        topView.layer.shadowRadius = 10
        
//        topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor.red, shadowRadius: 0, opacity: 1.0, offset: CGSize(width: 0, height: 10), cornerRadius: 12)
        
       
        
        // Center Image
        centerImageView.contentMode = .scaleAspectFit
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(centerImageView)
        
        //        // Title Label
        //        titleLabel.textAlignment = .center
        //        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        //        titleLabel.textColor = .white
        //        titleLabel.alpha = 0 // Hidden initially
        //        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //        topView.addSubview(titleLabel)
        //
        //        // Description Label
        //        descriptionLabel.textAlignment = .center
        //        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        //        descriptionLabel.textColor = UIColor.txtDarkGray
        //        descriptionLabel.numberOfLines = 0
        //        descriptionLabel.alpha = 0 // Hidden initially
        //        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        //        topView.addSubview(descriptionLabel)
        
        // Add Constraints
        NSLayoutConstraint.activate([
            centerImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
//            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 50.0),
            centerImageView.widthAnchor.constraint(equalToConstant: 80),
            centerImageView.heightAnchor.constraint(equalToConstant: 80),
            
            //            titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
            //            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            //            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            //
            //            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            //            descriptionLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            //            descriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            //            // Add bottom constraint to description label (it will automatically adjust after topView height is changed)
            //            descriptionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -20)
        ])
        
    }
    

    //-----------Top view setup

    
    // Animation Method
    func startAnimation(duration: TimeInterval = 0.5, delay: TimeInterval = 1, imageYOffset: CGFloat = -100, completion: (() -> Void)? = nil ) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            if let superview = self.superview {
                // Move the top view up
                self.topView.transform = CGAffineTransform(translationX: 0, y: -superview.bounds.height / 2 + self.topView.bounds.height / 2 + 20)
                
            }
        }) { _ in
            // After the animation completes, animate the appearance of the labels
            UIView.animate(withDuration: duration, animations: {
                
                self.topViewHeightConstraint = self.topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3)
//                self.topViewHeightConstraint?.isActive = true
                
                self.topLbl()
            })
            completion?()
        }
    }
    
    
    
    private func topLbl(){
        // Title Label
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.alpha = 1 // Hidden initially
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(titleLabel)
        
        // Description Label
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.textColor = UIColor.txtDarkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.alpha = 1 // Hidden initially
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(descriptionLabel)
        // Add Constraints
        NSLayoutConstraint.activate([
            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 30.0),
            titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            // Add bottom constraint to description label (it will automatically adjust after topView height is changed)
//            descriptionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -20)
            
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: topView.bottomAnchor, constant: -20)
        ])
        
    }
    
    
    // Configuration Method
    func configure(title: String, description: String, imageName: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        centerImageView.image = UIImage(named: imageName)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        self.setupUI()
        // Update layout of subviews or other properties here
        print("layoutSubviews is called")
//        self.setupTopUI()
       
//        self.topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), shadowRadius: 3, opacity: 0.3, offset: CGSize(width: 0, height: 15), cornerRadius: 12)
        self.topView.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), offSet: CGSize(width: 0, height: 15), opacity: 0.3, shadowRadius: 3, cornerRadious: 12)
        
    }
    
    
    //------------------------************************
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
                
        print("qrCodeImageView frame: \(qrCodeImageView.frame)")
        if let qrView = qrCodeImageView.superview {
            print("qrView frame: \(qrView.frame)")
            print("qrView.frame.origin.y: \(qrView.frame.origin.y)")
            
            self.circleYPosition = qrView.frame.origin.y
        }

        UIBezierPath(roundedRect: rect, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize).addClip()
        
        // Left - right circle
        path.move(to: CGPoint(x: 0, y: self.frame.size.height))
        
        //left side
        path.addArc(withCenter: CGPoint(x: 0, y: self.circleYPosition - 15),
                    radius: 34,
                    startAngle: CGFloat((90 * Double.pi) / 180),
                    endAngle: CGFloat((270 * Double.pi) / 180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        path.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        //right side
        path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: self.circleYPosition - 15),
                    radius: 34,
                    startAngle: CGFloat((270 * Double.pi) / 180),
                    endAngle: CGFloat((90 * Double.pi) / 180),
                    clockwise: false)
        
        
        path.close()
        //        UIColor.white.setFill()
        billBackgroundColor?.setFill()
        path.fill()
        
        // Center Dash path
        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: self.bounds.minX + 34, y: self.circleYPosition - 15))
        dashPath.addLine(to: CGPoint(x: self.bounds.maxX - 34, y: self.circleYPosition - 15))
        dashPath.setLineDash([5,5], count: 2, phase: 0.0)
        dashPath.lineWidth = 1.0
        dashPath.lineCapStyle = .butt
        //        UIColor.green.set()
        
        if let lineBgColor = lineBgColor  {
            lineBgColor.set()
        }
        
        dashPath.stroke()
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    //---------------------_****************
    // MARK: - Helper Functions
    private func createDetailAttributedString(title: String, value: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: "\(title)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
        )
        
        attributedText.append(
            NSAttributedString(
                string: "\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                    .foregroundColor: UIColor.black
                ]
            )
        )
        
        attributedText.append(
            NSAttributedString(
                string: value,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor.black
                ]
            )
        )
        
        return attributedText
    }
}
*/




/*
class BillShape: UIView {
    
     let scrollView = UIScrollView()
     let contentView = UIView()
    private let lineSubView = UIView()

    let packageTitleLabel = UILabel()
    let packageLabel = UILabel()
    let trainerDetailTitleLabel = UILabel()
    let trainerNameLabel = UILabel()
    let trainerImageView = UIImageView()
    let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
    let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
    let qrCodeImageView = UIImageView()
    let locBtn = UIButton(type: .custom)
    let footerLabel = UILabel()
    
    private var startDateLabl = UILabel()
    private var validUptoLabel = UILabel()
    private var timingLabel = UILabel()
    private var locationLabel = UILabel()

    private var trainerTagsLabel: UIStackView = TagViewHelper.createTagView(tags: []) as! UIStackView

    var trainerTags: [String]? {
        didSet {
            updateTagView()
            self.setNeedsLayout()
        }
    }
    
    private func updateTagView() {
        guard let tags = trainerTags else { return }
        
        // Remove existing arranged subviews
        trainerTagsLabel.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add new tags
        for tag in tags {
            let tagView = TagViewHelper.createTagView(tags: [tag])
            trainerTagsLabel.addArrangedSubview(tagView)
        }
    }
    
    var startDate:(title:String,value:String)? {
        didSet {
            startDateLabl.numberOfLines = 0
            startDateLabl.attributedText = createDetailAttributedString(title: (startDate?.title ?? ""), value: (startDate?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
    
    var validUptoDate:(title:String,value:String)? {
        didSet {
            validUptoLabel.numberOfLines = 0
            validUptoLabel.attributedText = createDetailAttributedString(title: (validUptoDate?.title ?? ""), value: (validUptoDate?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
   
    var timingTxt:(title:String,value:String)? {
        didSet {
            timingLabel.numberOfLines = 0
            timingLabel.attributedText = createDetailAttributedString(title: (timingTxt?.title ?? ""), value: (timingTxt?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
    
    var locationTxt:(title:String,value:String)? {
        didSet {
            locationLabel.numberOfLines = 0
            locationLabel.attributedText = createDetailAttributedString(title: (locationTxt?.title ?? ""), value: (locationTxt?.value ?? "" ))
            self.setNeedsLayout()
        }
    }
    
    
    var cornerSide:UIRectCorner? = .allCorners {
        didSet { self.setNeedsLayout() }
    }
    
    var isDirection:Bool? = false {
        didSet { self.setNeedsLayout() }
    }
    
    var cornerSize:CGSize = CGSize(width: 12, height: 12) {
        didSet { self.setNeedsLayout() }
    }
    
    var path: UIBezierPath = UIBezierPath()
    var billBackgroundColor:UIColor? = UIColor.white {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var lineBgColor:UIColor? = UIColor.darkGray {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    // Set you circle position for verticle.
    var circleYPosition: CGFloat = 100 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
        setupUI()
    }
    
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        setupContent()
        
    }
    
    private func setupContent() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        let topTitleView = UIView()
        topTitleView.backgroundColor = UIColor.clear
        topTitleView.addSubview(packageTitleLabel)
        topTitleView.addSubview(packageLabel)
        stackView.addArrangedSubview(topTitleView)
        packageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        packageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            packageTitleLabel.topAnchor.constraint(equalTo: topTitleView.topAnchor, constant: 10),
            packageTitleLabel.leadingAnchor.constraint(equalTo: topTitleView.leadingAnchor, constant: 1),
            packageTitleLabel.trailingAnchor.constraint(equalTo: topTitleView.trailingAnchor, constant: -1),
            packageLabel.topAnchor.constraint(equalTo: packageTitleLabel.bottomAnchor, constant: 1),
            packageLabel.leadingAnchor.constraint(equalTo: topTitleView.leadingAnchor, constant: 1),
            packageLabel.trailingAnchor.constraint(equalTo: topTitleView.trailingAnchor, constant: -1),
            packageLabel.bottomAnchor.constraint(equalTo: topTitleView.bottomAnchor, constant: -10)
        ])
      
        // Start Date Label
        startDateLabl.backgroundColor = UIColor.clear
        startDateLabl.textAlignment = .left
        validUptoLabel.textAlignment = .right
        validUptoLabel.backgroundColor = UIColor.clear
        
        let startView = UIView()
        startView.backgroundColor = UIColor.clear
        startView.addSubview(startDateLabl)
        startView.addSubview(validUptoLabel)
        stackView.addArrangedSubview(startView)
        startDateLabl.translatesAutoresizingMaskIntoConstraints = false
        validUptoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startDateLabl.topAnchor.constraint(equalTo: startView.topAnchor, constant: 10),
            startDateLabl.leadingAnchor.constraint(equalTo: startView.leadingAnchor, constant: 1),
            startDateLabl.widthAnchor.constraint(equalTo: startView.widthAnchor, multiplier: 0.5),
            startDateLabl.bottomAnchor.constraint(equalTo: startView.bottomAnchor, constant: -10),
            validUptoLabel.topAnchor.constraint(equalTo: startDateLabl.topAnchor, constant: 0),
            validUptoLabel.leadingAnchor.constraint(equalTo: startDateLabl.trailingAnchor, constant: 1),
            validUptoLabel.trailingAnchor.constraint(equalTo: startView.trailingAnchor, constant: -1),
            validUptoLabel.bottomAnchor.constraint(equalTo: startDateLabl.bottomAnchor, constant: 0)
        ])
        
        //-----------------------------------------***********************
        
        // Trainer Section
        trainerImageView.contentMode = .scaleAspectFill
        trainerImageView.layer.cornerRadius = 25
        trainerImageView.clipsToBounds = true
        trainerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Trainer detail Title Label
        trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        trainerDetailTitleLabel.textColor = .darkGray
        trainerDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    
        trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        trainerNameLabel.textColor = .black
        trainerNameLabel.numberOfLines = 2
        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        trainerBadgeImageView.contentMode = .scaleAspectFill
        trainerBadgeImageView.layer.cornerRadius = 10
        trainerBadgeImageView.clipsToBounds = true
        trainerBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nextImageView.contentMode = .scaleAspectFill
        nextImageView.layer.cornerRadius = 15
        nextImageView.clipsToBounds = true
        nextImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //trainerTags
        //["Cardio", "Pilates", "+3"]
//        let trainerTagsLabel = createTagView(tags: trainerTags ?? [])
        
        trainerTagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let customerDatailsView = UIView()
        customerDatailsView.backgroundColor = UIColor.clear
        
        customerDatailsView.addSubview(trainerDetailTitleLabel)
        customerDatailsView.addSubview(trainerImageView)
        customerDatailsView.addSubview(trainerNameLabel)
        customerDatailsView.addSubview(trainerBadgeImageView)
        customerDatailsView.addSubview(nextImageView)
        customerDatailsView.addSubview(trainerTagsLabel)
        stackView.addArrangedSubview(customerDatailsView)
        
        // Trainer Section
        NSLayoutConstraint.activate([
            // Trainer Section
            trainerDetailTitleLabel.leadingAnchor.constraint(equalTo: customerDatailsView.leadingAnchor, constant: 0),
            trainerDetailTitleLabel.topAnchor.constraint(equalTo: customerDatailsView.topAnchor, constant: 2),
            
            trainerImageView.leadingAnchor.constraint(equalTo: customerDatailsView.leadingAnchor, constant: 0),
            trainerImageView.topAnchor.constraint(equalTo: trainerDetailTitleLabel.bottomAnchor, constant: 12),
            trainerImageView.widthAnchor.constraint(equalToConstant: 50),
            trainerImageView.heightAnchor.constraint(equalToConstant: 50),
            
            trainerNameLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerNameLabel.topAnchor.constraint(equalTo: trainerImageView.topAnchor),
            
            trainerBadgeImageView.leadingAnchor.constraint(equalTo: trainerNameLabel.trailingAnchor, constant: 2),
            trainerBadgeImageView.topAnchor.constraint(equalTo: trainerNameLabel.topAnchor, constant: 2),
            trainerBadgeImageView.widthAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.heightAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -10),
            
            nextImageView.widthAnchor.constraint(equalToConstant: 30),
            nextImageView.heightAnchor.constraint(equalToConstant: 30),
            nextImageView.trailingAnchor.constraint(equalTo: customerDatailsView.trailingAnchor, constant: -12),
            nextImageView.centerYAnchor.constraint(equalTo: trainerImageView.centerYAnchor),
            
            trainerTagsLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerTagsLabel.topAnchor.constraint(equalTo: trainerNameLabel.bottomAnchor, constant: 5),
            trainerTagsLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -5),
            trainerTagsLabel.bottomAnchor.constraint(equalTo: customerDatailsView.bottomAnchor, constant: -10),
        ])
        
    
        //-----------------Middle line view ----------------************************
        
        let lineMView = UIView()
        lineMView.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(lineMView)
        lineSubView.tag = 101
        
//        let lineSubView = UIView()
        lineSubView.backgroundColor = UIColor.clear
        lineMView.addSubview(lineSubView)
        
        lineSubView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineSubView.leadingAnchor.constraint(equalTo: lineMView.leadingAnchor, constant: 2),
            lineSubView.trailingAnchor.constraint(equalTo: lineMView.trailingAnchor, constant: -1),
            lineSubView.heightAnchor.constraint(equalToConstant: 30.0),
            lineSubView.topAnchor.constraint(equalTo: lineMView.topAnchor, constant: 2),
            lineSubView.bottomAnchor.constraint(equalTo: lineMView.bottomAnchor, constant: -2)
        ])
        
//        circleYPosition = lineSubView.bounds.maxY
//        
//        print("lineSubView.bounds.maxY= ",lineSubView.bounds.maxY)
        
        //-----------------address bottom view ----------------************************
        
        let addressMView = UIView()
        addressMView.backgroundColor = UIColor.clear
        stackView.addArrangedSubview(addressMView)
        
        
        // QR Code
//        let qrCodeImageView = UIImageView()
//        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
        qrCodeImageView.contentMode = .scaleAspectFit

        //Get Direction
        locBtn.backgroundColor = UIColor.clear
        locBtn.setTitleColor(UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1), for: .normal)
        locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        locBtn.translatesAutoresizingMaskIntoConstraints = false
        // Set semanticContentAttribute to force right-to-left layout
        locBtn.semanticContentAttribute = .forceRightToLeft
        
        // Optional: Adjust spacing between image and title
        locBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        locBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -8)
        
        timingLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        locBtn.translatesAutoresizingMaskIntoConstraints = false
        
        addressMView.addSubview(timingLabel)
        addressMView.addSubview(locationLabel)
        addressMView.addSubview(locBtn)
        addressMView.addSubview(qrCodeImageView)
        
        if let isDirection = isDirection {
            locBtn.isHidden = !isDirection
        }
        
        // MARK: - Layout Constraints
        NSLayoutConstraint.activate([
            
            // QR Code
            qrCodeImageView.trailingAnchor.constraint(equalTo: addressMView.trailingAnchor, constant: 0),
            qrCodeImageView.topAnchor.constraint(equalTo: addressMView.topAnchor, constant: 10),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 145),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 145),
            
            // Timing and Location
            timingLabel.leadingAnchor.constraint(equalTo: addressMView.leadingAnchor, constant: 1),
            timingLabel.topAnchor.constraint(equalTo: qrCodeImageView.topAnchor, constant: 2),
            timingLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
            
            locationLabel.leadingAnchor.constraint(equalTo: addressMView.leadingAnchor, constant: 1),
            
            locationLabel.topAnchor.constraint(equalTo: timingLabel.bottomAnchor, constant: 10),
            locationLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
            
            locBtn.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 1),
//            locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: addressMView.bottomAnchor, multiplier: -12),
            locBtn.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor, constant: 0),
            locBtn.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: qrCodeImageView.leadingAnchor, multiplier: -12),
            locBtn.heightAnchor.constraint(equalToConstant: 25),
            locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: addressMView.bottomAnchor, multiplier: -12)
//            locBtn.bottomAnchor.constraint(equalTo: addressMView.bottomAnchor, constant: -30)
            
        ])
        
        
        //---------------################
       
        packageTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        packageTitleLabel.textColor = .darkGray
        
        packageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        packageLabel.textColor = .black
        packageLabel.numberOfLines = 0
        
        trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        trainerDetailTitleLabel.textColor = .darkGray
        
        trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        trainerNameLabel.textColor = .black
        trainerNameLabel.numberOfLines = 2
        
//        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        qrCodeImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        locBtn.setTitleColor(UIColor.blue, for: .normal)
        locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        footerLabel.textColor = .gray
        footerLabel.textAlignment = .center
        
        stackView.addArrangedSubview(footerLabel)
        
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        
////        guard let scrollView = self.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView else {
////            print("No UIScrollView found in the view hierarchy")
////            return
////        }
////        
////        // Convert target view’s position relative to UIScrollView
////        let targetY = scrollView.convert(lineSubView.frame.origin, from: lineSubView.superview).y
////
////        // Ensure we don't scroll beyond the allowed range
////        let maxOffsetY = max(0, min(targetY, scrollView.contentSize.height - scrollView.bounds.height))
////        
////        self.circleYPosition = maxOffsetY
////        
////        print("maxOffsetY", maxOffsetY)
//        
//        // Scroll to the calculated position
////        scrollView.setContentOffset(CGPoint(x: 0, y: maxOffsetY), animated: true)
//       
//        // Update layout of subviews or other properties here
////        print("layoutSubviews is called")
////        contentView.layoutIfNeeded()
////        DispatchQueue.main.async {
////            let lineYPosition = self.lineSubView.frame.midY
////            print("lineSubView Y Position: \(lineYPosition)")
////            self.circleYPosition = lineYPosition
////        }
//        
////        contentView.layoutIfNeeded()
////        
////        let lineYPosition = lineSubView.convert(lineSubView.bounds, to: self).maxY
////        print(lineSubView.convert(lineSubView.bounds, to: self).maxY)
//        
////        DispatchQueue.main.async {
////            self.contentView.layoutIfNeeded()
////            let lineYPosition = self.lineSubView.convert(self.lineSubView.bounds, to: self.contentView).maxY
////            print("lineSubView Y Position: \(lineYPosition)")
////        }
//
//       
////        self.topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), shadowRadius: 3, opacity: 0.3, offset: CGSize(width: 0, height: 15), cornerRadius: 12)
////        self.topView.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), offSet: CGSize(width: 0, height: 15), opacity: 0.3, shadowRadius: 3, cornerRadious: 12)
//        
//    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
//        print("lineSubView frame: \(lineSubView.frame)")
//        if let lineMView = lineSubView.superview {
//            print("lineMView frame: \(lineMView.frame)")
//            print("lineMView.frame.origin.y: \(lineMView.frame.origin.y)")
//            
//            self.circleYPosition = lineMView.frame.origin.y
//        }
        
        print("qrCodeImageView frame: \(qrCodeImageView.frame)")
        if let qrView = qrCodeImageView.superview {
            print("qrView frame: \(qrView.frame)")
            print("qrView.frame.origin.y: \(qrView.frame.origin.y)")
            
            self.circleYPosition = qrView.frame.origin.y
        }

        /*
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize)
        path.addClip()
        UIColor.white.setFill()
        path.fill()
        */
        
        //        setupUI()
        
        // 4 corners radious
        //        UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 24, height: 24)).addClip()
        
        UIBezierPath(roundedRect: rect, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize).addClip()
        
        // Left - right circle
        path.move(to: CGPoint(x: 0, y: self.frame.size.height))
        
        

        
        //left side
        path.addArc(withCenter: CGPoint(x: 0, y: self.circleYPosition - 15),
                    radius: 34,
                    startAngle: CGFloat((90 * Double.pi) / 180),
                    endAngle: CGFloat((270 * Double.pi) / 180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        path.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        //right side
        path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: self.circleYPosition - 15),
                    radius: 34,
                    startAngle: CGFloat((270 * Double.pi) / 180),
                    endAngle: CGFloat((90 * Double.pi) / 180),
                    clockwise: false)
        
        
        path.close()
        //        UIColor.white.setFill()
        billBackgroundColor?.setFill()
        path.fill()
        
        // Center Dash path
        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: self.bounds.minX + 34, y: self.circleYPosition - 15))
        dashPath.addLine(to: CGPoint(x: self.bounds.maxX - 34, y: self.circleYPosition - 15))
        dashPath.setLineDash([5,5], count: 2, phase: 0.0)
        dashPath.lineWidth = 1.0
        dashPath.lineCapStyle = .butt
        //        UIColor.green.set()
        
        if let lineBgColor = lineBgColor  {
            lineBgColor.set()
        }
        
        dashPath.stroke()

        
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    //---------------------_****************
    // MARK: - Helper Functions
    private func createDetailAttributedString(title: String, value: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: "\(title)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
        )
        
        attributedText.append(
            NSAttributedString(
                string: "\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                    .foregroundColor: UIColor.black
                ]
            )
        )
        
        attributedText.append(
            NSAttributedString(
                string: value,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor.black
                ]
            )
        )
        
        return attributedText
    }
    
    
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
}

*/



class TagViewHelper {
    static func createTagView(tags: [String]) -> UIView {
        let tagStackView = UIStackView()
        tagStackView.axis = .horizontal
        tagStackView.spacing = 5
        tagStackView.translatesAutoresizingMaskIntoConstraints = false

        for tag in tags {
            let tagBackgroundView = UIView()
            tagBackgroundView.backgroundColor = UIColor.black
            tagBackgroundView.layer.cornerRadius = 6
            tagBackgroundView.layer.masksToBounds = true
            tagBackgroundView.translatesAutoresizingMaskIntoConstraints = false

            let tagLabel = UILabel()
            tagLabel.text = tag
            tagLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            tagLabel.textColor = .white
            tagLabel.textAlignment = .center
            tagLabel.translatesAutoresizingMaskIntoConstraints = false

            tagBackgroundView.addSubview(tagLabel)

            NSLayoutConstraint.activate([
                tagLabel.leadingAnchor.constraint(equalTo: tagBackgroundView.leadingAnchor, constant: 8),
                tagLabel.trailingAnchor.constraint(equalTo: tagBackgroundView.trailingAnchor, constant: -8),
                tagLabel.topAnchor.constraint(equalTo: tagBackgroundView.topAnchor, constant: 4),
                tagLabel.bottomAnchor.constraint(equalTo: tagBackgroundView.bottomAnchor, constant: -4)
            ])

            tagStackView.addArrangedSubview(tagBackgroundView)
        }

        return tagStackView
    }
}


/*
class BillShape: UIView {
    
    let topView = UIView()
    let billingSection = UIView()
    var topViewHeightConstraint: NSLayoutConstraint?
    
    
    private let centerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    //-------------------
    let packageTitleLabel = UILabel()
    let packageLabel = UILabel()
    let trainerDetailTitleLabel = UILabel()
    let trainerNameLabel = UILabel()
    let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
    let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
    let qrCodeImageView = UIImageView()
    let locBtn = UIButton(type: .custom)
    let footerLabel = UILabel()
    
    var trainerTags:[String]? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var startDate:(title:String,value:String)? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var timingTxt:(title:String,value:String)? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var locationTxt:(title:String,value:String)? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var validUptoDate:(title:String,value:String)? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var cornerSide:UIRectCorner? = .allCorners {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var cornerSize:CGSize = CGSize(width: 12, height: 12) {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    
    
    //-------------------------
    var path: UIBezierPath = UIBezierPath()
    var billBackgroundColor:UIColor? = UIColor.white {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var lineBgColor:UIColor? = UIColor.darkGray {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupUI()
        // Update layout of subviews or other properties here
        print("layoutSubviews is called")
        self.setupTopUI()
       
//        self.topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), shadowRadius: 3, opacity: 0.3, offset: CGSize(width: 0, height: 15), cornerRadius: 12)
        self.topView.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), offSet: CGSize(width: 0, height: 15), opacity: 0.3, shadowRadius: 3, cornerRadious: 12)
        
    }
    
    // Set you circle position for verticle.
    var circleYPosition: CGFloat = 50 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        // Here apply shadow
        //        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupUI()
        setupInitialState()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
        setupUI()
        setupInitialState()
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //        setupUI()
        
        // 4 corners radious
        //        UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 24, height: 24)).addClip()
        
        UIBezierPath(roundedRect: rect, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize).addClip()
        
        // Left - right circle
        path.move(to: CGPoint(x: 0, y: self.frame.size.height))
        
        //left side
        path.addArc(withCenter: CGPoint(x: 0, y: self.circleYPosition - 15),
                    radius: 34,
                    startAngle: CGFloat((90 * Double.pi) / 180),
                    endAngle: CGFloat((270 * Double.pi) / 180),
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        path.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        //right side
        path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: self.circleYPosition - 15),
                    radius: 34,
                    startAngle: CGFloat((270 * Double.pi) / 180),
                    endAngle: CGFloat((90 * Double.pi) / 180),
                    clockwise: false)
        
        
        path.close()
        //        UIColor.white.setFill()
        billBackgroundColor?.setFill()
        path.fill()
        
        // Center Dash path
        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: self.bounds.minX + 34, y: self.circleYPosition - 15))
        dashPath.addLine(to: CGPoint(x: self.bounds.maxX - 34, y: self.circleYPosition - 15))
        dashPath.setLineDash([5,5], count: 2, phase: 0.0)
        dashPath.lineWidth = 1.0
        dashPath.lineCapStyle = .butt
        //        UIColor.green.set()
        
        if let lineBgColor = lineBgColor  {
            lineBgColor.set()
        }
        
        dashPath.stroke()
        
    }
    
    //---------------------------
    
    private func setupInitialState() {
        // Set initial states for animation
        billingSection.alpha = 0 // Initially hidden
    }
    
    
    private func setupUI() {
        
        
        // MARK: - Labels and UI Elements
        // Package Title Label
        //     packageTitleLabel = UILabel()
        packageTitleLabel.text = "Package"
        packageTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        packageTitleLabel.textColor = .darkGray
        packageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Package Label
        //        let packageLabel = UILabel()
        packageLabel.text = "12 months, Elite Gym Membership"
        packageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        packageLabel.textColor = .black
        packageLabel.translatesAutoresizingMaskIntoConstraints = false
        packageLabel.numberOfLines = 2
        
        // Start Date Label
        //startDate
        let startDateLabel = createDetailLabel(title: startDate?.title ?? "", value: startDate?.value ?? "")  //createDetailLabel(title: "Start Date", value: "06/24")
        let validUptoLabel = createDetailLabel(title: validUptoDate?.title ?? "", value: validUptoDate?.value ?? "") //createDetailLabel(title: "Valid Upto", value: "06/25")
        
        // Trainer Section
        let trainerImageView = UIImageView(image: UIImage(named: "ic_trainer"))
        trainerImageView.contentMode = .scaleAspectFill
        trainerImageView.layer.cornerRadius = 25
        trainerImageView.clipsToBounds = true
        trainerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Trainer detail Title Label
        //        let trainerDetailTitleLabel = UILabel()
        trainerDetailTitleLabel.text = "Trainer Details"
        trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        trainerDetailTitleLabel.textColor = .darkGray
        trainerDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //        let trainerNameLabel = UILabel()
        trainerNameLabel.text = "Christene De Koning"
        trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        trainerNameLabel.textColor = .black
        trainerNameLabel.numberOfLines = 2
        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //        let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
        trainerBadgeImageView.contentMode = .scaleAspectFill
        trainerBadgeImageView.layer.cornerRadius = 10
        trainerBadgeImageView.clipsToBounds = true
        trainerBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        //        let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
        nextImageView.contentMode = .scaleAspectFill
        nextImageView.layer.cornerRadius = 15
        nextImageView.clipsToBounds = true
        nextImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //trainerTags
        //["Cardio", "Pilates", "+3"]
        let trainerTagsLabel = createTagView(tags: trainerTags ?? [])
        
        // Timing and Location
        let timingLabel = createDetailLabel(title: timingTxt?.title ?? "", value: timingTxt?.value ?? "") //createDetailLabel(title: "Timing", value: "10:00 to 11:00")
        let locationLabel = createDetailLabel(title: locationTxt?.title ?? "", value: locationTxt?.value ?? "") //createDetailLabel(title: "Location", value: "MyPT Dubai")
        
        
        // QR Code
        //        let qrCodeImageView = UIImageView()
        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //Get Direction
        //        let locBtn = UIButton(type: .custom)
        locBtn.backgroundColor = UIColor.clear
        locBtn.setTitle("Get Direction", for: .normal)
        locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
        //        locBtn.tintColor = UIColor.blue //rgba(73, 129, 242, 1)
        locBtn.setTitleColor(UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1), for: .normal)
        locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        locBtn.translatesAutoresizingMaskIntoConstraints = false
        // Set semanticContentAttribute to force right-to-left layout
        locBtn.semanticContentAttribute = .forceRightToLeft
        
        // Optional: Adjust spacing between image and title
        locBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        locBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -8)
        
        // Footer Note
        //        let footerLabel = UILabel()
        footerLabel.text = "Scan the QR code to access the gym premises."
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        footerLabel.textColor = .gray
        footerLabel.textAlignment = .center
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Subviews to Ticket Container
        self.addSubview(packageTitleLabel)
        self.addSubview(packageLabel)
        self.addSubview(startDateLabel)
        self.addSubview(validUptoLabel)
        self.addSubview(trainerImageView)
        self.addSubview(trainerBadgeImageView)
        self.addSubview(nextImageView)
        self.addSubview(trainerDetailTitleLabel)
        self.addSubview(trainerNameLabel)
        self.addSubview(trainerTagsLabel)
        self.addSubview(timingLabel)
        self.addSubview(locationLabel)
        self.addSubview(locBtn)
        self.addSubview(qrCodeImageView)
        self.addSubview(footerLabel)
        
        // MARK: - Layout Constraints
        NSLayoutConstraint.activate([
            
            packageTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            packageTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
            packageTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
            
            // Package Label
            packageLabel.topAnchor.constraint(equalTo: packageTitleLabel.bottomAnchor, constant: 10),
            packageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
            packageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
            //            packageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            // Start Date and Valid Upto
            startDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            startDateLabel.topAnchor.constraint(equalTo: packageLabel.bottomAnchor, constant: 20),
            
            validUptoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            validUptoLabel.topAnchor.constraint(equalTo: packageLabel.bottomAnchor, constant: 20),
            
            // Trainer Section
            trainerDetailTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            trainerDetailTitleLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 20),
            
            trainerImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            trainerImageView.topAnchor.constraint(equalTo: trainerDetailTitleLabel.bottomAnchor, constant: 12),
            trainerImageView.widthAnchor.constraint(equalToConstant: 50),
            trainerImageView.heightAnchor.constraint(equalToConstant: 50),
            
            trainerNameLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerNameLabel.topAnchor.constraint(equalTo: trainerImageView.topAnchor),
            
            trainerBadgeImageView.leadingAnchor.constraint(equalTo: trainerNameLabel.trailingAnchor, constant: 2),
            trainerBadgeImageView.topAnchor.constraint(equalTo: trainerNameLabel.topAnchor, constant: 2),
            trainerBadgeImageView.widthAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.heightAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -10),
            
            nextImageView.widthAnchor.constraint(equalToConstant: 30),
            nextImageView.heightAnchor.constraint(equalToConstant: 30),
            nextImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            nextImageView.centerYAnchor.constraint(equalTo: trainerImageView.centerYAnchor),
            
            trainerTagsLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerTagsLabel.topAnchor.constraint(equalTo: trainerNameLabel.bottomAnchor, constant: 5),
            
            // Timing and Location
            timingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            timingLabel.topAnchor.constraint(equalTo: qrCodeImageView.topAnchor, constant: 2),
            
            locationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            locationLabel.topAnchor.constraint(equalTo: timingLabel.bottomAnchor, constant: 10),
            locationLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
            
            // QR Code
            qrCodeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            qrCodeImageView.topAnchor.constraint(equalTo: self.centerYAnchor, constant: self.circleYPosition + 10),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 100),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 100),
            
            
            // Footer Note
            footerLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            footerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            footerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            locBtn.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: footerLabel.topAnchor, multiplier: -12),
            locBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            locBtn.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: self.trailingAnchor, multiplier: -12),
            locBtn.heightAnchor.constraint(equalToConstant: 35),
            
        ])
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = .black // Adjust color as needed
        addSubview(topView)
        
    
        // Add height constraint for the topView
        topViewHeightConstraint = self.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
        topViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            topView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            topView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            topView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
            topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
        ])
        
    
        /*
         
         topView.translatesAutoresizingMaskIntoConstraints = false
         topView.backgroundColor = .black // Adjust color as needed
         addSubview(topView)
         
         //        // Billing Section
         //        billingSection.translatesAutoresizingMaskIntoConstraints = false
         //        billingSection.backgroundColor = .lightGray // Adjust color as needed
         //        addSubview(billingSection)
         
         // Add constraints for `topView` and `billingSection`
         NSLayoutConstraint.activate([
         // Top View initially centered
         topView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
         topView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
         topView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
         topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0),
         
         //                    // Billing Section initially off-screen
         //                    billingSection.centerXAnchor.constraint(equalTo: self.centerXAnchor),
         //                    billingSection.topAnchor.constraint(equalTo: self.bottomAnchor),
         //                    billingSection.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
         //                    billingSection.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.6)
         ])
         */
    }
    
    //-----------Top view setup

    
    // Animation Method
    func startAnimation(duration: TimeInterval = 0.5, delay: TimeInterval = 1, imageYOffset: CGFloat = -100, completion: (() -> Void)? = nil ) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            if let superview = self.superview {
                // Move the top view up
                self.topView.transform = CGAffineTransform(translationX: 0, y: -superview.bounds.height / 2 + self.topView.bounds.height / 2 + 20)
                
            }
        }) { _ in
            // After the animation completes, animate the appearance of the labels
            UIView.animate(withDuration: duration, animations: {
                
                self.topViewHeightConstraint = self.topView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
                self.topViewHeightConstraint?.isActive = true
                
                self.topLbl()
            })
            completion?()
        }
    }
    
    
    // setupTopUI
    private func setupTopUI() {
        topView.backgroundColor = UIColor.mainBg
        centerImageView.backgroundColor = .clear
        
        // Add shadow for depth
//        topView.layer.shadowColor = UIColor.red.cgColor
//        topView.layer.shadowOpacity = 1.0
//        topView.layer.shadowOffset = CGSize(width: 0, height: 15)
//        topView.layer.shadowRadius = 10
        
//        topView.applyShadow(fillColor: UIColor.mainBg, shadowColor: UIColor.red, shadowRadius: 0, opacity: 1.0, offset: CGSize(width: 0, height: 10), cornerRadius: 12)
        
       
        
        // Center Image
        centerImageView.contentMode = .scaleAspectFit
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(centerImageView)
        
        //        // Title Label
        //        titleLabel.textAlignment = .center
        //        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        //        titleLabel.textColor = .white
        //        titleLabel.alpha = 0 // Hidden initially
        //        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //        topView.addSubview(titleLabel)
        //
        //        // Description Label
        //        descriptionLabel.textAlignment = .center
        //        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        //        descriptionLabel.textColor = UIColor.txtDarkGray
        //        descriptionLabel.numberOfLines = 0
        //        descriptionLabel.alpha = 0 // Hidden initially
        //        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        //        topView.addSubview(descriptionLabel)
        
        // Add Constraints
        NSLayoutConstraint.activate([
            centerImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
//            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 50.0),
            centerImageView.widthAnchor.constraint(equalToConstant: 80),
            centerImageView.heightAnchor.constraint(equalToConstant: 80),
            
            //            titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
            //            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            //            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            //
            //            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            //            descriptionLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            //            descriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            //            // Add bottom constraint to description label (it will automatically adjust after topView height is changed)
            //            descriptionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -20)
        ])
        
    }
    
    private func topLbl(){
        // Title Label
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.alpha = 1 // Hidden initially
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(titleLabel)
        
        // Description Label
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.textColor = UIColor.txtDarkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.alpha = 1 // Hidden initially
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(descriptionLabel)
        // Add Constraints
        NSLayoutConstraint.activate([
            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: -30.0),
            titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            // Add bottom constraint to description label (it will automatically adjust after topView height is changed)
            descriptionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -20)
        ])
        
    }
    
    
    // Configuration Method
    func configure(title: String, description: String, imageName: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        centerImageView.image = UIImage(named: imageName)
    }
    
    
    //---------------------_****************
    // MARK: - Helper Functions
    private func createDetailLabel(title: String, value: String) -> UILabel {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(
            string: "\(title)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
        )
        attributedText.append(
            NSAttributedString(
                string: "\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                    .foregroundColor: UIColor.black
                ]
            )
        )
        attributedText.append(
            NSAttributedString(
                string: value,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor.black
                ]
            )
        )
        label.attributedText = attributedText
        label.numberOfLines = 3
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createTagView(tags: [String]) -> UIView {
        let tagStackView = UIStackView()
        tagStackView.axis = .horizontal
        tagStackView.spacing = 5
        tagStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for tag in tags {
            // Create the background view
            let tagBackgroundView = UIView()
            tagBackgroundView.backgroundColor = UIColor.black
            tagBackgroundView.layer.cornerRadius = 6
            tagBackgroundView.layer.masksToBounds = true
            tagBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            // Create the label
            let tagLabel = UILabel()
            tagLabel.text = tag
            tagLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            tagLabel.textColor = .white
            tagLabel.textAlignment = .center
            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Add the label to the background view
            tagBackgroundView.addSubview(tagLabel)
            
            // Set constraints for the label to center it within the background view
            NSLayoutConstraint.activate([
                tagLabel.leadingAnchor.constraint(equalTo: tagBackgroundView.leadingAnchor, constant: 8),
                tagLabel.trailingAnchor.constraint(equalTo: tagBackgroundView.trailingAnchor, constant: -8),
                tagLabel.topAnchor.constraint(equalTo: tagBackgroundView.topAnchor, constant: 4),
                tagLabel.bottomAnchor.constraint(equalTo: tagBackgroundView.bottomAnchor, constant: -4)
            ])
            
            
            // Add the background view to the stack view
            tagStackView.addArrangedSubview(tagBackgroundView)
        }
        
        
        return tagStackView
    }
    
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
}
*/



/*
class BillShape: UIView {
    
    
    //-------------------
    let packageTitleLabel = UILabel()
    let packageLabel = UILabel()
    let trainerDetailTitleLabel = UILabel()
    let trainerNameLabel = UILabel()
    let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
    let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
    let qrCodeImageView = UIImageView()
    let locBtn = UIButton(type: .custom)
    let footerLabel = UILabel()
    
    var trainerTags:[String]? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var startDate:(title:String,value:String)? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var timingTxt:(title:String,value:String)? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var locationTxt:(title:String,value:String)? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var validUptoDate:(title:String,value:String)? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var cornerSide:UIRectCorner? = .allCorners {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var cornerSize:CGSize = CGSize(width: 12, height: 12) {
        didSet{
            self.setNeedsDisplay()
        }
    }
    

    
    //-------------------------
    var path: UIBezierPath = UIBezierPath()
    var billBackgroundColor:UIColor? = UIColor.white {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var lineBgColor:UIColor? = UIColor.darkGray {
        didSet{
            self.setNeedsDisplay()
        }
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
        // Update layout of subviews or other properties here
        print("layoutSubviews is called")
    }
    
    // Set you circle position for verticle.
    var circleYPosition: CGFloat = 50 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        // Here apply shadow
//        setupUI()
    }
    
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .clear
            setupUI()
        }
    
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.backgroundColor = .clear
            setupUI()
        }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
       
//        setupUI()
        
        // 4 corners radious
//        UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 24, height: 24)).addClip()
        
        UIBezierPath(roundedRect: rect, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize).addClip()
        
        // Left - right circle
        path.move(to: CGPoint(x: 0, y: self.frame.size.height))
        
        //left side
        path.addArc(withCenter: CGPoint(x: 0, y: self.circleYPosition - 15),
            radius: 34,
            startAngle: CGFloat((90 * Double.pi) / 180),
            endAngle: CGFloat((270 * Double.pi) / 180),
            clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        path.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        //right side
        path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: self.circleYPosition - 15),
                    radius: 34,
                    startAngle: CGFloat((270 * Double.pi) / 180),
                    endAngle: CGFloat((90 * Double.pi) / 180),
                    clockwise: false)
        
        
        path.close()
//        UIColor.white.setFill()
        billBackgroundColor?.setFill()
        path.fill()
        
        // Center Dash path
        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: self.bounds.minX + 34, y: self.circleYPosition - 15))
        dashPath.addLine(to: CGPoint(x: self.bounds.maxX - 34, y: self.circleYPosition - 15))
        dashPath.setLineDash([5,5], count: 2, phase: 0.0)
        dashPath.lineWidth = 1.0
        dashPath.lineCapStyle = .butt
//        UIColor.green.set()
       
        if let lineBgColor = lineBgColor  {
            lineBgColor.set()
        }
       
        dashPath.stroke()
        
    }
    
    //---------------------------
    
    private func setupUI() {
        
        // MARK: - Labels and UI Elements
        // Package Title Label
//     packageTitleLabel = UILabel()
        packageTitleLabel.text = "Package"
        packageTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        packageTitleLabel.textColor = .darkGray
        packageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Package Label
//        let packageLabel = UILabel()
        packageLabel.text = "12 months, Elite Gym Membership"
        packageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        packageLabel.textColor = .black
        packageLabel.translatesAutoresizingMaskIntoConstraints = false
        packageLabel.numberOfLines = 2
        
        // Start Date Label
        //startDate
        let startDateLabel = createDetailLabel(title: startDate?.title ?? "", value: startDate?.value ?? "")  //createDetailLabel(title: "Start Date", value: "06/24")
        let validUptoLabel = createDetailLabel(title: validUptoDate?.title ?? "", value: validUptoDate?.value ?? "") //createDetailLabel(title: "Valid Upto", value: "06/25")
        
        // Trainer Section
        let trainerImageView = UIImageView(image: UIImage(named: "ic_trainer"))
        trainerImageView.contentMode = .scaleAspectFill
        trainerImageView.layer.cornerRadius = 25
        trainerImageView.clipsToBounds = true
        trainerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Trainer detail Title Label
//        let trainerDetailTitleLabel = UILabel()
        trainerDetailTitleLabel.text = "Trainer Details"
        trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        trainerDetailTitleLabel.textColor = .darkGray
        trainerDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        let trainerNameLabel = UILabel()
        trainerNameLabel.text = "Christene De Koning"
        trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        trainerNameLabel.textColor = .black
        trainerNameLabel.numberOfLines = 2
        trainerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
        trainerBadgeImageView.contentMode = .scaleAspectFill
        trainerBadgeImageView.layer.cornerRadius = 10
        trainerBadgeImageView.clipsToBounds = true
        trainerBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
//        let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
        nextImageView.contentMode = .scaleAspectFill
        nextImageView.layer.cornerRadius = 15
        nextImageView.clipsToBounds = true
        nextImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //trainerTags
        //["Cardio", "Pilates", "+3"]
        let trainerTagsLabel = createTagView(tags: trainerTags ?? [])
        
        // Timing and Location
        let timingLabel = createDetailLabel(title: timingTxt?.title ?? "", value: timingTxt?.value ?? "") //createDetailLabel(title: "Timing", value: "10:00 to 11:00")
        let locationLabel = createDetailLabel(title: locationTxt?.title ?? "", value: locationTxt?.value ?? "") //createDetailLabel(title: "Location", value: "MyPT Dubai")
        
        
        // QR Code
//        let qrCodeImageView = UIImageView()
        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //Get Direction
//        let locBtn = UIButton(type: .custom)
        locBtn.backgroundColor = UIColor.clear
        locBtn.setTitle("Get Direction", for: .normal)
        locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
        //        locBtn.tintColor = UIColor.blue //rgba(73, 129, 242, 1)
        locBtn.setTitleColor(UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1), for: .normal)
        locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        locBtn.translatesAutoresizingMaskIntoConstraints = false
        // Set semanticContentAttribute to force right-to-left layout
        locBtn.semanticContentAttribute = .forceRightToLeft
        
        // Optional: Adjust spacing between image and title
        locBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        locBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -8)
        
        // Footer Note
//        let footerLabel = UILabel()
        footerLabel.text = "Scan the QR code to access the gym premises."
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        footerLabel.textColor = .gray
        footerLabel.textAlignment = .center
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Subviews to Ticket Container
        self.addSubview(packageTitleLabel)
        self.addSubview(packageLabel)
        self.addSubview(startDateLabel)
        self.addSubview(validUptoLabel)
        self.addSubview(trainerImageView)
        self.addSubview(trainerBadgeImageView)
        self.addSubview(nextImageView)
        self.addSubview(trainerDetailTitleLabel)
        self.addSubview(trainerNameLabel)
        self.addSubview(trainerTagsLabel)
        self.addSubview(timingLabel)
        self.addSubview(locationLabel)
        self.addSubview(locBtn)
        self.addSubview(qrCodeImageView)
        self.addSubview(footerLabel)
        
        // MARK: - Layout Constraints
        NSLayoutConstraint.activate([
            
            packageTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            packageTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
            packageTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
            
            // Package Label
            packageLabel.topAnchor.constraint(equalTo: packageTitleLabel.bottomAnchor, constant: 10),
            packageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12.0),
            packageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
            //            packageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            // Start Date and Valid Upto
            startDateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            startDateLabel.topAnchor.constraint(equalTo: packageLabel.bottomAnchor, constant: 20),
            
            validUptoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            validUptoLabel.topAnchor.constraint(equalTo: packageLabel.bottomAnchor, constant: 20),
            
            // Trainer Section
            trainerDetailTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            trainerDetailTitleLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 20),
            
            trainerImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            trainerImageView.topAnchor.constraint(equalTo: trainerDetailTitleLabel.bottomAnchor, constant: 12),
            trainerImageView.widthAnchor.constraint(equalToConstant: 50),
            trainerImageView.heightAnchor.constraint(equalToConstant: 50),
            
            
            trainerNameLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerNameLabel.topAnchor.constraint(equalTo: trainerImageView.topAnchor),
            
            trainerBadgeImageView.leadingAnchor.constraint(equalTo: trainerNameLabel.trailingAnchor, constant: 2),
            trainerBadgeImageView.topAnchor.constraint(equalTo: trainerNameLabel.topAnchor, constant: 2),
            trainerBadgeImageView.widthAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.heightAnchor.constraint(equalToConstant: 20),
            trainerBadgeImageView.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -10),
            
            nextImageView.widthAnchor.constraint(equalToConstant: 30),
            nextImageView.heightAnchor.constraint(equalToConstant: 30),
            nextImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            nextImageView.centerYAnchor.constraint(equalTo: trainerImageView.centerYAnchor),
            
            trainerTagsLabel.leadingAnchor.constraint(equalTo: trainerImageView.trailingAnchor, constant: 10),
            trainerTagsLabel.topAnchor.constraint(equalTo: trainerNameLabel.bottomAnchor, constant: 5),
            
            // Timing and Location
            timingLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            timingLabel.topAnchor.constraint(equalTo: qrCodeImageView.topAnchor, constant: 2),
            
            locationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            locationLabel.topAnchor.constraint(equalTo: timingLabel.bottomAnchor, constant: 10),
            locationLabel.trailingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: -10),
            
            // QR Code
            qrCodeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            qrCodeImageView.topAnchor.constraint(equalTo: self.centerYAnchor, constant: self.circleYPosition + 10),
            qrCodeImageView.widthAnchor.constraint(equalToConstant: 100),
            qrCodeImageView.heightAnchor.constraint(equalToConstant: 100),
            
            
            // Footer Note
            footerLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            footerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            footerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            locBtn.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: footerLabel.topAnchor, multiplier: -12),
            locBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            locBtn.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: self.trailingAnchor, multiplier: -12),
            locBtn.heightAnchor.constraint(equalToConstant: 35),
            
        ])
    }

        // MARK: - Helper Functions
        private func createDetailLabel(title: String, value: String) -> UILabel {
            let label = UILabel()
            let attributedText = NSMutableAttributedString(
                string: "\(title)\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor.gray
                ]
            )
            attributedText.append(
                NSAttributedString(
                    string: "\n",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                        .foregroundColor: UIColor.black
                    ]
                )
            )
            attributedText.append(
                NSAttributedString(
                    string: value,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                        .foregroundColor: UIColor.black
                    ]
                )
            )
            label.attributedText = attributedText
            label.numberOfLines = 3
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }
    
    private func createTagView(tags: [String]) -> UIView {
        let tagStackView = UIStackView()
        tagStackView.axis = .horizontal
        tagStackView.spacing = 5
        tagStackView.translatesAutoresizingMaskIntoConstraints = false

        for tag in tags {
            // Create the background view
            let tagBackgroundView = UIView()
            tagBackgroundView.backgroundColor = UIColor.black
            tagBackgroundView.layer.cornerRadius = 6
            tagBackgroundView.layer.masksToBounds = true
            tagBackgroundView.translatesAutoresizingMaskIntoConstraints = false

            // Create the label
            let tagLabel = UILabel()
            tagLabel.text = tag
            tagLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            tagLabel.textColor = .white
            tagLabel.textAlignment = .center
            tagLabel.translatesAutoresizingMaskIntoConstraints = false

            // Add the label to the background view
            tagBackgroundView.addSubview(tagLabel)

            // Set constraints for the label to center it within the background view
            NSLayoutConstraint.activate([
                tagLabel.leadingAnchor.constraint(equalTo: tagBackgroundView.leadingAnchor, constant: 8),
                tagLabel.trailingAnchor.constraint(equalTo: tagBackgroundView.trailingAnchor, constant: -8),
                tagLabel.topAnchor.constraint(equalTo: tagBackgroundView.topAnchor, constant: 4),
                tagLabel.bottomAnchor.constraint(equalTo: tagBackgroundView.bottomAnchor, constant: -4)
            ])
            

            // Add the background view to the stack view
            tagStackView.addArrangedSubview(tagBackgroundView)
        }
        

        return tagStackView
    }


        private func generateQRCode(from string: String) -> UIImage? {
            let data = string.data(using: String.Encoding.ascii)
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                if let output = filter.outputImage?.transformed(by: transform) {
                    return UIImage(ciImage: output)
                }
            }
            return nil
        }

}
*/


/*
 class BillShape: UIView {
     
     private let scrollView = UIScrollView()
     private let contentView = UIView()
     
     let packageTitleLabel = UILabel()
     let packageLabel = UILabel()
     let trainerDetailTitleLabel = UILabel()
     let trainerNameLabel = UILabel()
     let trainerBadgeImageView = UIImageView(image: UIImage(named: "ic_trainerBadge"))
     let nextImageView = UIImageView(image: UIImage(named: "ic_right_arrow_withCircle"))
     let qrCodeImageView = UIImageView()
     let locBtn = UIButton(type: .custom)
     let footerLabel = UILabel()
     
     var trainerTags:[String]? {
         didSet { self.setNeedsLayout() }
     }
     
     var startDate:(title:String,value:String)? {
         didSet { self.setNeedsLayout() }
     }
     
     var timingTxt:(title:String,value:String)? {
         didSet { self.setNeedsLayout() }
     }
     
     var locationTxt:(title:String,value:String)? {
         didSet { self.setNeedsLayout() }
     }
     
     var validUptoDate:(title:String,value:String)? {
         didSet { self.setNeedsLayout() }
     }
     
     var cornerSide:UIRectCorner? = .allCorners {
         didSet { self.setNeedsLayout() }
     }
     
     var cornerSize:CGSize = CGSize(width: 12, height: 12) {
         didSet { self.setNeedsLayout() }
     }
     
     override init(frame: CGRect) {
         super.init(frame: frame)
         self.backgroundColor = .clear
         setupUI()
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         self.backgroundColor = .clear
         setupUI()
     }
     
     private func setupUI() {
         addSubview(scrollView)
         scrollView.addSubview(contentView)
         
         scrollView.translatesAutoresizingMaskIntoConstraints = false
         contentView.translatesAutoresizingMaskIntoConstraints = false

         NSLayoutConstraint.activate([
             scrollView.topAnchor.constraint(equalTo: self.topAnchor),
             scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
             scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
             scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

             contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
             contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
             contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
             contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
             contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Ensure same width
         ])
         
         setupContent()
     }
     
     private func setupContent() {
         let stackView = UIStackView()
         stackView.axis = .vertical
         stackView.spacing = 15
         stackView.translatesAutoresizingMaskIntoConstraints = false
         
         contentView.addSubview(stackView)
         
         NSLayoutConstraint.activate([
             stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
             stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
             stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
             stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
         ])
         
         packageTitleLabel.text = "Package"
         packageTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
         packageTitleLabel.textColor = .darkGray
         
         packageLabel.text = "12 months, Elite Gym Membership"
         packageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
         packageLabel.textColor = .black
         packageLabel.numberOfLines = 2
         
         trainerDetailTitleLabel.text = "Trainer Details"
         trainerDetailTitleLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
         trainerDetailTitleLabel.textColor = .darkGray
         
         trainerNameLabel.text = "Christene De Koning"
         trainerNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
         trainerNameLabel.textColor = .black
         trainerNameLabel.numberOfLines = 2
         
         qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
         qrCodeImageView.contentMode = .scaleAspectFit
         qrCodeImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
         qrCodeImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
         
         locBtn.setTitle("Get Direction", for: .normal)
         locBtn.setImage(UIImage(named: "ic_arrow_right_blue"), for: .normal)
         locBtn.setTitleColor(UIColor.blue, for: .normal)
         locBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
         
         footerLabel.text = "Scan the QR code to access the gym premises."
         footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
         footerLabel.textColor = .gray
         footerLabel.textAlignment = .center
         
         stackView.addArrangedSubview(packageTitleLabel)
         stackView.addArrangedSubview(packageLabel)
         stackView.addArrangedSubview(trainerDetailTitleLabel)
         stackView.addArrangedSubview(trainerNameLabel)
         stackView.addArrangedSubview(qrCodeImageView)
         stackView.addArrangedSubview(locBtn)
         stackView.addArrangedSubview(footerLabel)
     }
     
     private func generateQRCode(from string: String) -> UIImage? {
         let data = string.data(using: String.Encoding.ascii)
         if let filter = CIFilter(name: "CIQRCodeGenerator") {
             filter.setValue(data, forKey: "inputMessage")
             let transform = CGAffineTransform(scaleX: 10, y: 10)
             if let output = filter.outputImage?.transformed(by: transform) {
                 return UIImage(ciImage: output)
             }
         }
         return nil
     }
 }

 */



