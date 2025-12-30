//
//  HalfBillShape.swift
//  MyPT
//
//  Created by techsaga corp on 30/07/25.
//

import UIKit

class HalfBillShape: UIView {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
   private let lineSubView = UIView()

   let topTitleView = UIView()
   let startView = UIView()
   let customerDatailsView = UIView()
   let addressMView = UIView()
   
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
           self.updateConstrnt()
           self.setNeedsLayout()
       }
   }
  
   private func updateConstrnt(){
       // Remove any existing constraint that uses a multiplier
       if let existingConstraint = startView.constraints.first(where: {
           ($0.firstItem as? UILabel) == startDateLabl && $0.firstAttribute == .width
       }) {
           startView.removeConstraint(existingConstraint)
       }

       // Determine the multiplier based on the validUptoLabel text
       let trimmedText = validUptoLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
       let isValidUptoEmpty = trimmedText?.isEmpty ?? true
       let multiplier: CGFloat = isValidUptoEmpty ? 1.0 : 0.5
       
       // Recreate width constraint with new multiplier
       let newWidthConstraint = startDateLabl.widthAnchor.constraint(equalTo: startView.widthAnchor, multiplier: multiplier)
       newWidthConstraint.isActive = true

       // Show/hide validUptoLabel as needed
       validUptoLabel.isHidden = isValidUptoEmpty
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
   
   var isDirection:Bool? = true {
       didSet {
           locBtn.isHidden = isDirection ?? true
           self.setNeedsLayout()
       }
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
       trainerDetailTitleLabel.font = AppFont.semibold.size(12.0, familyName: familyManrope)
       trainerDetailTitleLabel.textColor = UIColor.txtDarkGray
       trainerDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
   
       trainerNameLabel.font = AppFont.medium.size(18.0, familyName: familyClashDisplay)
       trainerNameLabel.textColor = UIColor.mainBg
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
       addressMView.backgroundColor = UIColor.red
       stackView.addArrangedSubview(addressMView)
       addressMView.isHidden = true
       
       // QR Code
       qrCodeImageView.contentMode = .scaleAspectFit

       //Get Direction
       locBtn.backgroundColor = UIColor.clear
       locBtn.setTitleColor(UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1), for: .normal)
       locBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
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
           locBtn.isHidden = isDirection
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
           locBtn.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor, constant: 0),
           locBtn.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: qrCodeImageView.leadingAnchor, multiplier: -12),
           locBtn.heightAnchor.constraint(equalToConstant: 25),
           locBtn.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: addressMView.bottomAnchor, multiplier: -12)
       ])
       
       
       //---------------################
      
       packageTitleLabel.font = AppFont.semibold.size(12.0, familyName: familyManrope)
       packageTitleLabel.textColor = UIColor.txtDarkGray
       
       packageLabel.font = AppFont.medium.size(18.0, familyName: familyClashDisplay)
       packageLabel.textColor = UIColor.mainBg
       packageLabel.numberOfLines = 0
       
       trainerDetailTitleLabel.font = AppFont.semibold.size(12.0, familyName: familyManrope)
       trainerDetailTitleLabel.textColor = UIColor.txtDarkGray
       
       trainerNameLabel.font = AppFont.medium.size(18.0, familyName: familyClashDisplay)
       trainerNameLabel.textColor = UIColor.mainBg
       trainerNameLabel.numberOfLines = 2
       
//        qrCodeImageView.image = generateQRCode(from: "https://www.myptdubai.com")
       qrCodeImageView.contentMode = .scaleAspectFit
       qrCodeImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
       qrCodeImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
       
       locBtn.setTitleColor(UIColor(red: 73/255.0, green: 129/255.0, blue: 242/255.0, alpha: 1), for: .normal)
       locBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
       footerLabel.font = AppFont.semibold.size(12.0, familyName: familyManrope)
       footerLabel.textColor = UIColor.txtDarkGray
       footerLabel.textAlignment = .center
       
       stackView.addArrangedSubview(footerLabel)
       footerLabel.isHidden = true
       
   }
   
   override func layoutSubviews() {
       super.layoutSubviews()
       
   }
   
   override func draw(_ rect: CGRect) {
       super.draw(rect)
              
       print("qrCodeImageView frame: \(qrCodeImageView.frame)")
       if let qrView = qrCodeImageView.superview {
           print("qrView frame: \(qrView.frame)")
           print("qrView.frame.origin.y: \(qrView.frame.origin.y)")
           
           self.circleYPosition = qrView.frame.origin.y
       }

       let frameSet  = CGRect( x: 0, y: self.contentView.frame.minY, width: self.contentView.frame.width, height: self.contentView.frame.height - 55)
       
       
       UIBezierPath(roundedRect: frameSet, byRoundingCorners: cornerSide ?? .allCorners, cornerRadii: cornerSize).addClip()
       
       // Left - right circle
       path.move(to: CGPoint(x: 0, y: self.contentView.frame.size.height))
       
       //left side
       path.addArc(withCenter: CGPoint(x: 0, y: self.circleYPosition - 15),
                   radius: 34,
                   startAngle: CGFloat((90 * Double.pi) / 180),
                   endAngle: CGFloat((270 * Double.pi) / 180),
                   clockwise: false)
       
       path.addLine(to: CGPoint(x: 0, y: 0))
       path.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
       path.addLine(to: CGPoint(x: self.frame.size.width, y: self.contentView.frame.size.height))
       
       path.move(to: CGPoint(x: self.frame.size.width, y: self.contentView.frame.size.height))
       
       //right side
       path.addArc(withCenter: CGPoint(x: self.frame.size.width, y: self.circleYPosition - 15),
                   radius: 34,
                   startAngle: CGFloat((270 * Double.pi) / 180),
                   endAngle: CGFloat((90 * Double.pi) / 180),
                   clockwise: false)
       path.close()
       billBackgroundColor?.setFill()
       path.fill()
       
       // Center Dash path
       let dashPath = UIBezierPath()
       dashPath.move(to: CGPoint(x: self.bounds.minX + 34, y: self.circleYPosition - 15))
       dashPath.addLine(to: CGPoint(x: self.bounds.maxX - 34, y: self.circleYPosition - 15))
       dashPath.setLineDash([5,5], count: 2, phase: 0.0)
       dashPath.lineWidth = 1.0
       dashPath.lineCapStyle = .butt
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
