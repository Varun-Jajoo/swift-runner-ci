//
//  AnimatedTopView.swift
//  MyPT
//
//  Created by techsaga corp on 29/11/24.
//

import UIKit


class AnimatedTopView: UIView {
    
    let topView = UIView()
    var topViewHeightConstraint: NSLayoutConstraint?
    
    private let centerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupTopUI()
        self.topView.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0), offSet: CGSize(width: 0, height: 15), opacity: 0.3, shadowRadius: 3, cornerRadious: 12)
        
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
    private func setupUI() {
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
    }
    //-----------Top view setup

    
    // Animation Method
    func startAnimation(duration: TimeInterval = 0.5, delay: TimeInterval = 1, imageYOffset: CGFloat = -100) {
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
        }
    }
    
    // setupTopUI
    private func setupTopUI() {
        topView.backgroundColor = UIColor.mainBg
        centerImageView.backgroundColor = .clear
        // Center Image
        centerImageView.contentMode = .scaleAspectFit
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(centerImageView)
        // Add Constraints
        NSLayoutConstraint.activate([
            centerImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
//            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 50.0),
            centerImageView.widthAnchor.constraint(equalToConstant: 80),
            centerImageView.heightAnchor.constraint(equalToConstant: 80),
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
    


    /*
    private let centerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // Setup UI
    private func setupUI() {
        self.backgroundColor = .red
        centerImageView.backgroundColor = .green
        
        // Add shadow for depth
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 10
        
        // Center Image
        centerImageView.contentMode = .scaleAspectFit
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(centerImageView)
        
        // Title Label
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.alpha = 0 // Hidden initially
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        
        // Description Label
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.alpha = 0 // Hidden initially
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(descriptionLabel)
        
        // Add Constraints
        NSLayoutConstraint.activate([
            centerImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            centerImageView.widthAnchor.constraint(equalToConstant: 100),
            centerImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    // Configuration Method
    func configure(title: String, description: String, imageName: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        centerImageView.image = UIImage(named: imageName)
    }
    
    // Animation Method
    func startAnimation(duration: TimeInterval = 1.0, delay: TimeInterval = 0, imageYOffset: CGFloat = -100) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            self.centerImageView.transform = CGAffineTransform(translationX: 0, y: imageYOffset)
        }) { _ in
            UIView.animate(withDuration: duration, animations: {
                self.titleLabel.alpha = 1
                self.descriptionLabel.alpha = 1
            })
        }
    }
    
    */
}


//class AnimatedTopView: UIView {
//    
//    private let centerImageView = UIImageView()
//    private let titleLabel = UILabel()
//    private let descriptionLabel = UILabel()
////    private let billShapeView = BillShape()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupUI()
//    }
//    
//    private func setupUI() {
//        self.backgroundColor = .black
//        
//        // Add shadow
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 0.2
//        self.layer.shadowOffset = CGSize(width: 0, height: 5)
//        self.layer.shadowRadius = 10
//        
//        // Center Image View
//        centerImageView.image = UIImage(named: "ic_success") // Replace with your image
//        centerImageView.contentMode = .scaleAspectFit
//        centerImageView.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(centerImageView)
//        
//        // Title Label
//        titleLabel.text = "Title Goes Here"
//        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        titleLabel.textColor = .white
//        titleLabel.textAlignment = .center
//        titleLabel.alpha = 0 // Initially hidden
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(titleLabel)
//        
//        // Description Label
//        descriptionLabel.text = "Description goes here. Add more details if needed."
//        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        descriptionLabel.textColor = .white
//        descriptionLabel.textAlignment = .center
//        descriptionLabel.numberOfLines = 0
//        descriptionLabel.alpha = 0 // Initially hidden
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(descriptionLabel)
//        
//        // Bill Shape View
////        billShapeView.translatesAutoresizingMaskIntoConstraints = false
////        billShapeView.alpha = 0 // Initially hidden
////        self.addSubview(billShapeView)
////        
////        self.translatesAutoresizingMaskIntoConstraints = false
////        self.alpha = 0 // Initially hidden
////        self.addSubview(billShapeView)
//        
//        // Constraints
//        NSLayoutConstraint.activate([
//            // Center Image
//            centerImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            centerImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            centerImageView.widthAnchor.constraint(equalToConstant: 100),
//            centerImageView.heightAnchor.constraint(equalToConstant: 100),
//            
//            // Title Label
//            titleLabel.topAnchor.constraint(equalTo: self.centerImageView.bottomAnchor, constant: 30),
//            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//            
//            // Description Label
//            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
//            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
//            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
//            
////            // Bill Shape View
////            billShapeView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
////            billShapeView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
////            billShapeView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
////            billShapeView.heightAnchor.constraint(equalToConstant: 200),
//        ])
//    }
//    
//    func startAnimation() {
//        // Animate the image to the top
//        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
//            self.centerImageView.transform = CGAffineTransform(translationX: 0, y: -self.bounds.height / 4)
//        }) { _ in
//            // Fade in title, description, and bill shape
//            UIView.animate(withDuration: 1.0, animations: {
//                self.titleLabel.alpha = 1
//                self.descriptionLabel.alpha = 1
////                self.billShapeView.alpha = 1
//            })
//        }
//    }
//}

