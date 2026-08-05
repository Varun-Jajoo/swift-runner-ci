//
//  Extensions.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import UIKit
import ImageIO
import CoreImage

private var backImageViewTag: Int { return 1011 }
private var navBtnTag: Int { return 1012 }
private var backViewTag: Int { return 1013 }
private var centerImgTag: Int { return 1014 }
private var lockImgTag: Int { return 1015 }

/// Process-lifetime in-memory cache behind `UIImageView.loadImage(urlString:...)`.
///
/// `NSCache` (rather than a plain dictionary) so the system can evict entries
/// under memory pressure on its own.
enum RemoteImageCache {

    static let shared: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        // Generous but bounded — list thumbnails and hero art, not originals.
        cache.countLimit = 240
        return cache
    }()

    /// Resized variants are cached separately from the full-size image, since
    /// `loadImage` can be asked for either at the same URL.
    static func key(for urlString: String, resize: CGSize?) -> NSString {
        guard let resize = resize else { return urlString as NSString }
        return "\(urlString)@\(Int(resize.width))x\(Int(resize.height))" as NSString
    }
}


func createGrayBlurImage(from image: UIImage, blurRadius:Float = 5.0) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }

    // Convert to grayscale
    let grayscaleFilter = CIFilter(name: "CIPhotoEffectMono")!
    grayscaleFilter.setValue(ciImage, forKey: kCIInputImageKey)
    guard let grayscaleOutputImage = grayscaleFilter.outputImage else { return nil }

    // Apply blur effect
    let blurFilter = CIFilter(name: "CIGaussianBlur")!
    blurFilter.setValue(grayscaleOutputImage, forKey: kCIInputImageKey)
    blurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey) // Adjust blur radius as needed //
    guard let outputImage = blurFilter.outputImage else { return nil }

    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(outputImage,
 from: outputImage.extent) else { return nil }
    let blurredImage = UIImage(cgImage: cgImage)

    return blurredImage

}


func addGradientBackgroundToImage(image: UIImage, colors: [CGColor], locations: [CGFloat]) -> UIImage? {
    // 1. Create a gradient image
    let gradientSize = image.size
    UIGraphicsBeginImageContextWithOptions(gradientSize, false, 0.0)
    guard let gradientContext = UIGraphicsGetCurrentContext() else { return nil }

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)


    let startPoint = CGPoint.zero
    let endPoint
      = CGPoint(x: gradientSize.width, y: gradientSize.height)
     gradientContext.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])

    let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()


    // 2. Combine images
    UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else { return nil
 }

    // Draw the gradient image as background
    gradientImage?.draw(in: CGRect(origin: .zero, size: gradientSize))

    // Draw the original image on top
    image.draw(in: CGRect(origin: .zero, size: image.size))

    let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return combinedImage
}

//func createGradientImage(size: CGSize, colors: [CGColor], locations: [NSNumber]) -> UIImage? {
//    // Create a new image context
//    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
//    guard let context = UIGraphicsGetCurrentContext() else { return nil }
//
//    // Create a color space
//    let colorSpace = CGColorSpaceCreateDeviceRGB()
//
//    // Convert NSNumber locations to CGFloat
//    let cgLocations = locations.map { CGFloat($0.doubleValue) }
//
//    // Create a gradient
//    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: cgLocations)
//
//    // Draw the gradient
//    let startPoint = CGPoint(x: 0, y: 0)
//    let endPoint = CGPoint(x: size.width, y: size.height)
//    context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options:
// [])
//
//    // Create the image
//    let image = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//
//    return image
//}

extension UIButton {
    func loadImage(urlString: String?, placeholder: UIImage?, for state: UIControl.State = .normal, imageSize: CGSize? = CGSize(width: 30.0, height: 30.0)) {
        self.setImage(placeholder, for: state)
        guard let urlString = urlString, let url = URL(string: urlString) else { return }

        Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self?.setImage(image.resized(to: imageSize ?? CGSize(width: 30.0, height: 30.0)), for: state)
                    }
                }
            } catch {
                print("Image loading error: \(error)")
            }
        }
    }
}


//MARK: ----------------------- Extension for UIView
extension UIView{
    
    func makeCircular() {
        self.layoutIfNeeded() // ensures frame is updated
        let radius = min(self.frame.width, self.frame.height) / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    //-------for getting superview
    func findSuperview<T: UIView>(of type: T.Type) -> T? {
        var superview = self.superview
        while let view = superview {
            if let matchingView = view as? T {
                return matchingView
            }
            superview = view.superview
        }
        return nil
    }
    
    //MARK: ------------- SET BACKGROUND IMAGE
    
    func setComingSoon(mainVTop: CGFloat? = 0.0, mainVBottom: CGFloat? = 0.0, centerY: CGFloat? = 0.0,
                       bgColor: UIColor? = .clear,
                       centerImgName centerImageName: String,
                       lockImgName: String = "lock_icon",
                       title: String? = "Title",
                       desc: String? = "Description",
                       titleFont: UIFont? = AppFont.medium.size(24.0, familyName: familyClashDisplay),
                       descFont: UIFont? = AppFont.semibold.size(14.0, familyName: familyManrope),
                       titleTextColor: UIColor? = UIColor.appWhite,
                       descTextcolor: UIColor? = UIColor.txtDarkGray
    ) {
        // Remove existing view if already added
        if let existing = self.viewWithTag(backViewTag) {
            existing.removeFromSuperview()
        }
        
        let backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = bgColor
        backView.tag = backViewTag
        self.addSubview(backView)
        
        let centerImageView = UIImageView()
        centerImageView.tag = centerImgTag
        centerImageView.image = UIImage(named: centerImageName)
        centerImageView.contentMode = .scaleAspectFill
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        centerImageView.isUserInteractionEnabled = false
        centerImageView.backgroundColor = .clear
        backView.addSubview(centerImageView)
        
        let lockImageView = UIImageView()
        lockImageView.tag = lockImgTag
        lockImageView.image = UIImage(named: lockImgName)
        lockImageView.contentMode = .scaleAspectFill
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        lockImageView.isUserInteractionEnabled = false
        lockImageView.backgroundColor = .clear
        centerImageView.addSubview(lockImageView)
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = titleFont
        titleLbl.textColor = titleTextColor
        titleLbl.numberOfLines = 0
        titleLbl.textAlignment = .center
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(titleLbl)
        
        let descLbl = UILabel()
        descLbl.text = desc
        descLbl.font = descFont
        descLbl.textColor = descTextcolor
        descLbl.numberOfLines = 0
        descLbl.textAlignment = .center
        descLbl.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(descLbl)
        
        NSLayoutConstraint.activate([
            //            backView.topAnchor.constraint(equalTo: self.topAnchor),
            //            backView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backView.topAnchor.constraint(equalTo: self.topAnchor, constant: mainVTop ?? 0.0),
            backView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(mainVBottom ?? 0.0)),
            backView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            centerImageView.centerXAnchor.constraint(equalTo: backView.centerXAnchor),
            //            centerImageView.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
            
            centerImageView.centerYAnchor.constraint(equalTo: backView.centerYAnchor, constant: centerY ?? 0.0) ,
            lockImageView.centerXAnchor.constraint(equalTo: centerImageView.centerXAnchor),
            lockImageView.centerYAnchor.constraint(equalTo: centerImageView.centerYAnchor),
            
            titleLbl.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 10),
            titleLbl.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 76),
            titleLbl.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -76),
            
            descLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 12),
            descLbl.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 76),
            descLbl.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -76),
            descLbl.bottomAnchor.constraint(lessThanOrEqualTo: backView.bottomAnchor, constant: -20)
        ])
    }
    
    
    //MARK: ------------- SET BACKGROUND IMAGE
    func setTopBackgroundImage(named imageName: String) {
        let backgroundImageView = UIImageView()
        if let imageView = self.viewWithTag(backImageViewTag) {
            imageView.removeFromSuperview()
        }
        backgroundImageView.tag = backImageViewTag
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.isUserInteractionEnabled = false // So it doesn't block touches
        
        self.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    // MARK: - Add Top Navigation Button
    
    func addTopNavigationButton(title: String? = "Back", image: UIImage? = nil, target: Any?, action: Selector? = nil) {
        let button = UIButton(type: .system)
        button.tag = navBtnTag
        
        self.viewWithTag(navBtnTag)?.removeFromSuperview()
        
        button.setTitleColor(UIColor.appWhite, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        if let titleStr = title, let image = image {
            button.setTitle("  " + titleStr, for: .normal)
            button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            button.setTitle(title, for: .normal)
        }
        
        if let action = action, let target = target {
            button.addTarget(target, action: action, for: .touchUpInside)
        }else{
            button.addTarget(target, action: #selector(backButtonTapped(sender: )), for: .touchUpInside)
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 2),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    //MARK: ------------REMOVE COMMING SOON
    @objc func backButtonTapped(sender: UIButton) {
        if let backView = self.viewWithTag(backViewTag) {
            backView.removeFromSuperview()
        }
        
        if let navButton = self.viewWithTag(navBtnTag) {
            navButton.removeFromSuperview()
        }
        if let imageView = self.viewWithTag(backImageViewTag) {
            imageView.removeFromSuperview()
        }
    }
    
    //    func addTopShadow(to view: UIView) {
    //        view.layer.masksToBounds = false
    //        view.layer.shadowColor = UIColor.white.withAlphaComponent(0.3).cgColor
    //        view.layer.shadowOpacity = 0.3
    //        view.layer.shadowOffset = CGSize(width: 0, height: -3) // Negative Y value for top shadow
    //        view.layer.shadowRadius = 4
    //
    //        // Define the shadow path for the top side
    //        let shadowPath = UIBezierPath()
    //        shadowPath.move(to: CGPoint(x: 0, y: 0)) // Start at top-left
    //        shadowPath.addLine(to: CGPoint(x: view.bounds.width, y: 0)) // Move to top-right
    //        shadowPath.addLine(to: CGPoint(x: view.bounds.width, y: 3)) // Extend down slightly
    //        shadowPath.addLine(to: CGPoint(x: 0, y: 3)) // Move left
    //        shadowPath.close()
    //
    //        view.layer.shadowPath = shadowPath.cgPath
    //    }
    
    
    
    //MARK: --------- FOR ADD SHADOW
    func applyShadow(
        fillColor: UIColor = .white,
        shadowColor: UIColor = .black,
        shadowRadius: CGFloat = 10.0,
        opacity: Float = 0.5,
        offset: CGSize = CGSize(width: 0, height: 2),
        cornerRadius: CGFloat = 0.0
    ) {
        let shadowLayer = CAShapeLayer()
        // Remove existing shadow layers if needed to avoid duplications
        layer.sublayers?
            .filter { $0.name == "apply_Shadow" }.forEach({$0.removeFromSuperlayer()})
        /*
         layer.sublayers?
         .filter { $0 is CAShapeLayer }
         .forEach { $0.removeFromSuperlayer() }
         */
        
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.name = "apply_Shadow"
        shadowLayer.fillColor = fillColor.cgColor
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = offset
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius
        layer.insertSublayer(shadowLayer, at: 0)
        
    }
    
    func roundBottomCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.clipsToBounds = true
    }

    
//    func roundBottomCorners(radius: CGFloat) {
//        let maskPath = UIBezierPath(roundedRect: self.bounds,
//                                    byRoundingCorners: [.bottomLeft, .bottomRight],
//                                    cornerRadii: CGSize(width: radius, height: radius))
//        let shape = CAShapeLayer()
//        shape.path = maskPath.cgPath
//        self.layer.mask = shape
//    }
    
    func roundSideCorners(radius: CGFloat, cornerSide:UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: cornerSide,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
        
    func applyCornerRadius(_ radius: CGFloat = 12) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    
    
    /*
     view.cornersWithBorder(radius: 24.0, corners: [.bottomLeft, .bottomRight], borderColor: UIColor(red: 62.0/255.0, green: 132.0/255.0, blue: 255.0/255.0, alpha: 1.0), borderWidth: 1.0)
     */
    func cornersWithBorder(
           radius: CGFloat,
           corners: UIRectCorner,
           borderColor: UIColor = .clear,
           borderWidth: CGFloat = 0
       ) {
           // Rounded corner mask
           let maskPath = UIBezierPath(
               roundedRect: bounds,
               byRoundingCorners: corners,
               cornerRadii: CGSize(width: radius, height: radius)
           )
           let maskLayer = CAShapeLayer()
           maskLayer.path = maskPath.cgPath
           layer.mask = maskLayer

           // Remove old border layers
           layer.sublayers?.filter { $0.name == "rounded_border_layer" }
               .forEach { $0.removeFromSuperlayer() }

           // Border layer that follows the same rounded path
           let borderLayer = CAShapeLayer()
           borderLayer.name = "rounded_border_layer"
           borderLayer.path = maskPath.cgPath
           borderLayer.fillColor = UIColor.clear.cgColor
           borderLayer.strokeColor = borderColor.cgColor
           borderLayer.lineWidth = borderWidth
           borderLayer.frame = bounds

           layer.addSublayer(borderLayer)
       }
    
    
    /* usess
     myView.roundSideCornersWithBorder(
           radius: 16,
           cornerSide: [.topLeft, .topRight],
           borderColor: .red,
           borderWidth: 2,
           borderSides: [.left, .right, .bottom]
       )
     */
    
    func roundSideCornersWithBorder(
            radius: CGFloat,
            cornerSide: UIRectCorner,
            borderColor: UIColor = .clear,
            borderWidth: CGFloat = 1,   // default 1pt
            borderSides: UIRectEdge = .all
        ) {
            // Rounded corner mask
            let maskPath = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: cornerSide,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            layer.mask = maskLayer
            
            // Remove old border layers
            layer.sublayers?.filter { $0.name == "round_corner_border" }
                .forEach { $0.removeFromSuperlayer() }
            
            // Full rounded border path
            let borderLayer = CAShapeLayer()
            borderLayer.name = "round_corner_border"
            borderLayer.path = maskPath.cgPath
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = borderColor.cgColor
            borderLayer.lineWidth = borderWidth
            borderLayer.frame = bounds
            
            if borderSides != .all {
                // Mask out only the selected sides
                let visiblePath = UIBezierPath()
                
                if borderSides.contains(.top) {
                    visiblePath.append(UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: borderWidth * 2)))
                }
                if borderSides.contains(.bottom) {
                    visiblePath.append(UIBezierPath(rect: CGRect(x: 0, y: bounds.height - borderWidth * 2, width: bounds.width, height: borderWidth * 2)))
                }
                if borderSides.contains(.left) {
                    visiblePath.append(UIBezierPath(rect: CGRect(x: 0, y: 0, width: borderWidth * 2, height: bounds.height)))
                }
                if borderSides.contains(.right) {
                    visiblePath.append(UIBezierPath(rect: CGRect(x: bounds.width - borderWidth * 2, y: 0, width: borderWidth * 2, height: bounds.height)))
                }
                
                let mask = CAShapeLayer()
                mask.path = visiblePath.cgPath
                borderLayer.mask = mask
            }
            
            layer.addSublayer(borderLayer)
            
        }
    
//    func roundSideCornersWithBorder(
//        radius: CGFloat,
//        cornerSide: UIRectCorner,
//        borderColor: UIColor = .clear,
//        borderWidth: CGFloat = 1,
//        borderSides: UIRectEdge = .all
//    ) {
//        // Rounded corner mask
//        let maskPath = UIBezierPath(
//            roundedRect: bounds,
//            byRoundingCorners: cornerSide,
//            cornerRadii: CGSize(width: radius, height: radius)
//        )
//        
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = maskPath.cgPath
//        layer.mask = maskLayer
//        
//        // Remove old border layers
//        layer.sublayers?.filter { $0.name == "round_corner_border" }
//            .forEach { $0.removeFromSuperlayer() }
//        
//        // Draw separate border paths per side
//        let borderLayer = CAShapeLayer()
//        borderLayer.name = "round_corner_border"
//        borderLayer.fillColor = UIColor.clear.cgColor
//        borderLayer.strokeColor = borderColor.cgColor
//        borderLayer.lineWidth = borderWidth
//        borderLayer.frame = bounds
//        
//        let visiblePath = UIBezierPath()
//        
//        if borderSides.contains(.top) {
//            visiblePath.move(to: CGPoint(x: 0, y: 0))
//            visiblePath.addLine(to: CGPoint(x: bounds.width, y: 0))
//        }
//        if borderSides.contains(.bottom) {
//            visiblePath.move(to: CGPoint(x: 0, y: bounds.height))
//            visiblePath.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
//        }
//        if borderSides.contains(.left) {
//            visiblePath.move(to: CGPoint(x: 0, y: 0))
//            visiblePath.addLine(to: CGPoint(x: 0, y: bounds.height))
//        }
//        if borderSides.contains(.right) {
//            visiblePath.move(to: CGPoint(x: bounds.width, y: 0))
//            visiblePath.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
//        }
//        
//        borderLayer.path = visiblePath.cgPath
//        layer.addSublayer(borderLayer)
//    }
        
    func setCornerRadius(borderWidth:CGFloat = 0.0, borderColor:UIColor? = nil, cornerRadious:CGFloat = 0.0){
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
        self.layer.cornerRadius = cornerRadious
        self.layer.masksToBounds = true
    }
    
    /*
     func addTopShadow(shadowColor: UIColor, shadowOpacity: Float, shadowRadius: CGFloat, offset: CGSize) {
     self.layer.shadowColor = shadowColor.cgColor
     selflayer.shadowOffset = offset
     self.layer.shadowOpacity = shadowOpacity
     self.layer.shadowRadius = shadowRadius
     self.clipsToBounds = false
     }
     */
    
    func setCornerWithShadow(borderWidth:CGFloat = 0.0, borderColor:UIColor? = nil, shadowColor:UIColor? = UIColor.black, offSet:CGSize, opacity:Float = 0.4, shadowRadius:CGFloat = 0.0, cornerRadious:CGFloat = 0.0){
        
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor?.cgColor
        self.layer.cornerRadius = cornerRadious
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor?.cgColor
        self.layer.shadowOffset = offSet
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = shadowRadius
        
        /*
         var shadowLayer: CAShapeLayer!
         let fillColor: UIColor = .white
         
         if shadowLayer == nil {
         shadowLayer = CAShapeLayer()
         shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: shadowRadius).cgPath
         shadowLayer.fillColor = fillColor.cgColor
         shadowLayer.shadowColor = shadowColor?.cgColor
         shadowLayer.shadowPath = shadowLayer.path
         shadowLayer.shadowOffset = offSet
         shadowLayer.shadowOpacity = opacity
         shadowLayer.shadowRadius = shadowRadius
         
         layer.insertSublayer(shadowLayer, at: 0)
         }
         */
        
        //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        //        self.layer.shouldRasterize = true
        //        self.layer.rasterizationScale = UIScreen.main.scale //scale ? UIScreen.main.scale : 1
        
        
    }
    
    
    func rotate360Degrees(duration: CFTimeInterval = 1, repeatCount: Float = .infinity) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = repeatCount
        layer.add(rotateAnimation, forKey: nil)
    }
    
    // Call this if using infinity animation
    func stopRotation360Degrees () {
        layer.removeAllAnimations()
    }
    
    
    ///     /*----------- uses
    ///      self.backImgView.addRotationAnimation(axis: "y", angle: CGFloat.pi, duration: 1.0, isCumulative: true, repeatCount: 0) {
    ///    print("Y-axis rotation animation completed!")
    ///}
    ///   /// Adds a rotation animation to the view's layer along a specified axis.
    /// - Parameters:
    ///   - axis: The axis of rotation ("x", "y", or "z").
    ///   - angle: The rotation angle in radians. Use `Double.pi` for 180 degrees, etc.
    ///   - duration: Duration of the animation (default is 1 second).
    ///   - isCumulative: Whether the animation should be cumulative (default is false).
    ///   - repeatCount: Number of times the animation repeats (default is 0, no repeat).
    ///   - completion: An optional completion handler executed after the animation ends.
    func addRotationAnimation(axis: String,
                              angle: CGFloat = Double.pi,
                              duration: CFTimeInterval = 1.0,
                              isCumulative: Bool = false,
                              repeatCount: Float = 0,
                              completion: (() -> Void)? = nil) {
        // Validate the axis input
        guard ["x", "y", "z"].contains(axis.lowercased()) else {
            print("Invalid axis. Use 'x', 'y', or 'z'.")
            return
        }
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.\(axis.lowercased())")
        rotation.fromValue = 0
        rotation.toValue = angle
        rotation.duration = duration
        rotation.isCumulative = isCumulative
        rotation.repeatCount = repeatCount
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = false
        
        self.layer.add(rotation, forKey: "\(axis.lowercased())RotationAnimation")
        
        // Execute the completion handler after the animation ends.
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                completion()
            }
        }
    }
    
    
    //MARK: --------------- MAKE GRADIENT BORDER
    
    func setGradientMultiBorder(cornerRadius: CGFloat, width: CGFloat,
                                colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
                                endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        
        let borderLayerName = "gradientBorderLayer_MultiLayer"
        // Remove the last added gradient border (if it exists)
        layer.sublayers?.removeAll(where: { $0.name == borderLayerName })
        
        // Create a new gradient border layer
        let border = CAGradientLayer()
        border.name = borderLayerName
        border.frame = bounds
        border.colors = colors.map { $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.red.cgColor
        mask.lineWidth = width
        
        border.mask = mask
        
        // Add the new gradient border
        layer.addSublayer(border)
    }
    
    func setGradientCellBorder(cornerRadius: CGFloat, width: CGFloat,
                               colors: [UIColor],
                               startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
                               endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        
        let borderLayerName = "gradientBorderLayer_MultiLayer"
        
        // Remove any existing border layers
        layer.sublayers?.removeAll(where: { $0.name == borderLayerName })
        
        // Gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = borderLayerName
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        // Shape layer (stroke only, no fill)
        let shapeLayer = CAShapeLayer()
        let insetRect = bounds.insetBy(dx: width / 2, dy: width / 2)
        shapeLayer.path = UIBezierPath(roundedRect: insetRect, cornerRadius: cornerRadius - width / 2).cgPath
        shapeLayer.lineWidth = width
        shapeLayer.strokeColor = UIColor.black.cgColor // This doesn't matter; it's overridden by gradient
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        gradientLayer.mask = shapeLayer
        
        // Add to main layer
        layer.addSublayer(gradientLayer)
    }
    
    
    private static let kLayerNameGradientBorder = "GradientBorderLayer"
    
    func setGradientBorder(cornerRadious:CGFloat, width: CGFloat,
                           colors: [UIColor],
                           startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
                           endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
    ) {
        let existedBorder = gradientBorderLayer()
        let border = existedBorder ?? CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadious).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.red.cgColor
        mask.lineWidth = width
        
        border.mask = mask
        
        let exists = existedBorder != nil
        if !exists {
            layer.addSublayer(border)
        }
    }
    
    func removeGradientBorder() {
        self.gradientBorderLayer()?.removeFromSuperlayer()
    }
    
    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
    
    
    //MARK: --------------- AddGradient LAYER
    
    /*
     (0,0) is the top-left corner
     (1,0) is the top-right corner
     (0,1) is the bottom-left corner
     (1,1) is the bottom-right corner
     */
    
    /*
     let colors: [UIColor] = [.blue, .white, .red]
     let locations: [NSNumber] = [0.0, 0.2, 1.0]
     
     (0,0) -------- (1,0)
     |            |
     |            |
     (0,1) -------- (1,1)
     
     1-
     startPoint = CGPoint(x: 0.0, y: 0.5)  // Left-center
     endPoint = CGPoint(x: 1.0, y: 0.5)    // Right-center
     
     2-
     startPoint = CGPoint(x: 0.5, y: 0.0)  // Top-center
     endPoint = CGPoint(x: 0.5, y: 1.0)    // Bottom-center
     
     3-
     startPoint = CGPoint(x: 0.0, y: 1.0)  // Bottom-left
     endPoint = CGPoint(x: 1.0, y: 0.0)    // Top-right
     
     4-
     startPoint = CGPoint(x: 0.0, y: 0.0)  // Top-left
     endPoint = CGPoint(x: 1.0, y: 1.0)    // Bottom-right
     
     */
    
    //    func addGradient(
    //        colors: [UIColor] = [.blue, .white],
    //        locations: [NSNumber] = [0, 1],
    //        startPoint: CGPoint = CGPoint(x: 0.0, y: 1.0),
    //        endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0)
    //    ) {
    //        let gradient = CAGradientLayer()
    //        gradient.frame = self.bounds // Use bounds to match the view's size
    //        gradient.colors = colors.map { $0.cgColor }
    //        gradient.locations = locations
    //        gradient.startPoint = startPoint
    //        gradient.endPoint = endPoint
    //        
    //        // Ensure no duplicate gradient layers are added
    //        if let sublayers = self.layer.sublayers, sublayers.contains(where: { $0 is CAGradientLayer }) {
    //            return
    //        }
    //        
    //        self.layer.insertSublayer(gradient, at: 0)
    //    }
    
    
    /*
     func addGradient(
     colors: [UIColor] = [.blue, .white],
     locations: [NSNumber] = [0, 1],
     startPoint: CGPoint = CGPoint(x: 0.0, y: 1.0),
     endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0),
     cornerRadius: CGFloat = 0.0
     ) {
     DispatchQueue.main.async {
     self.layer.sublayers?
     .filter { $0.name == "addGradient" }
     .forEach { $0.removeFromSuperlayer() }
     
     let gradient = CAGradientLayer()
     gradient.name = "addGradient"
     gradient.frame = self.bounds
     gradient.colors = colors.map { $0.cgColor }
     gradient.locations = locations
     gradient.startPoint = startPoint
     gradient.endPoint = endPoint
     
     self.layer.insertSublayer(gradient, at: 0)
     
     self.layer.cornerRadius = cornerRadius
     self.layer.masksToBounds = true
     }
     }
     */
    
    
    func addGradient(
        colors: [UIColor] = [.blue, .white],
        locations: [NSNumber] = [0, 1],
        startPoint: CGPoint = CGPoint(x: 0.0, y: 1.0),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0),
        cornerRadius: CGFloat = 0.0
    ) {
        DispatchQueue.main.async {
            self.layer.sublayers?
                .filter { $0.name == "addGradient" }
                .forEach { $0.removeFromSuperlayer() }
            
            let gradient = CAGradientLayer()
            gradient.name = "addGradient"
            gradient.frame = self.bounds
            gradient.colors = colors.map { $0.cgColor }
            gradient.locations = locations
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
            
            if let imageView = self as? UIImageView {
                imageView.layer.mask = gradient // Set gradient as mask
            } else {
                self.layer.insertSublayer(gradient, at: 0)
            }
            
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    //MARK: ---------------------ADD GRADIENT LAYER
    func addGradientLayer(
        colors: [UIColor] = [.blue, .white],
        locations: [NSNumber] = [0, 1],
        startPoint: CGPoint = CGPoint(x: 0.0, y: 1.0),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0),
        cornerRadius: CGFloat = 0.0
    ){
        // Create gradient overlay
        self.layer.sublayers?
            .filter { $0.name == "layer_gradient" }
            .forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "layer_gradient"
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        /*
         gradientLayer.frame = self.bounds
         gradientLayer.colors = [
         UIColor.blue.cgColor,
         UIColor.clear.cgColor
         ]
         gradientLayer.startPoint = CGPoint(x: 0, y: 1)
         gradientLayer.endPoint = CGPoint(x: 1, y: 1)
         */
        
        // Optional: round corners
        //            gradientLayer.cornerRadius = 12
        //            bookTrainerAtHomeBtn.layer.cornerRadius = 12
        
        // Add gradient on top
        self.layer.addSublayer(gradientLayer)
    }
    
    
    func addGradientWithHeight(
        colors: [UIColor] = [.blue, .white],
        locations: [NSNumber] = [0, 1],
        startPoint: CGPoint = CGPoint(x: 0.0, y: 1.0),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0),
        gradientHeight: CGFloat = 0.25 // Default height for the top-center area (25% of view's height)
    ) {
        DispatchQueue.main.async {
            self.layer.sublayers?
                .filter { $0.name == "addGradient_height" }
                .forEach { $0.removeFromSuperlayer() }
            
            let gradient = CAGradientLayer()
            gradient.name = "addGradient_height"
            
            // Set the frame to cover only the top-center area
            let gradientHeightInView = self.bounds.height * gradientHeight
            let gradientWidthInView = self.bounds.width
            gradient.frame = CGRect(
                x: 0,
                y: 0,
                width: gradientWidthInView,
                height: gradientHeightInView
            )
            
            gradient.colors = colors.map { $0.cgColor }
            gradient.locations = locations
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
            
            /*
             // Ensure no duplicate gradient layers are added
             if let sublayers = self.layer.sublayers, sublayers.contains(where: { $0 is CAGradientLayer }) {
             return
             }
             */
            
            self.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    
    func drawLine(start: CGPoint, toPoint end: CGPoint) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = path.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.red.cgColor]
        gradientLayer.mask = {
            let layer = CAShapeLayer()
            layer.path = UIBezierPath(ovalIn: path.bounds).cgPath
            return layer
        }()
        
        self.layer.addSublayer(gradientLayer)
    }
    
    
    //MARK: --------------- MAKE GRADIENT LAYER
    func layerGradient(startPoint:CAGradientPoint, endPoint:CAGradientPoint ,colorArray:[CGColor], type:CAGradientLayerType ) {
        //        let gradient = CAGradientLayer(start: .topLeft, end: .topRight, colors: colorArray, type: type)
        let gradient = CAGradientLayer(start: startPoint, end: endPoint, colors: colorArray, type: type)
        gradient.frame.size = self.frame.size
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    //MARK: ===================LINE VIEW
    
    //    func drawLineProgress(progressfill: CGFloat = 0.0, fillLineColor: UIColor?, cornerRadius: CGFloat) {
    //        // Create a container view for the progress bar and label
    //        let progressContainer = UIView(frame: bounds)
    //        progressContainer.clipsToBounds = false  // Allow subviews to be visible even when clipping
    //        
    //        // Remove any existing progress layers or subviews
    ////        self.subviews.forEach { $0.removeFromSuperview() }
    //        
    //    self.layer.sublayers?.filter { $0.name == "progress_line" || $0.name == "progress_line_mask" }.forEach({$0.removeFromSuperlayer()})
    //        
    //        // Add your label as a subview on top of the container view
    //        let label = UILabel(frame: bounds)
    //        label.text = ""  // Set your label's text
    //        label.textAlignment = .center
    //        label.textColor = .black  // Set label text color
    //        progressContainer.addSubview(label)
    //        
    //        // Create the progress bar layer
    //        let shapeLayer = CAShapeLayer()
    //        shapeLayer.name = "progress_line_mask"
    //        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
    //        shapeLayer.path = path.cgPath
    //        
    //        // Create the progress bar layer
    //        let progressRect = CGRect(origin: .zero, size: CGSize(width: self.frame.size.width * progressfill, height: self.frame.size.height))
    //        let progressLayer = CALayer()
    //        progressLayer.name = "progress_line"
    //        progressLayer.frame = progressRect
    //        progressLayer.cornerRadius = cornerRadius
    //        progressContainer.layer.addSublayer(progressLayer)
    //        
    //        // Set the background color for the progress bar
    //        guard let fillLineColor = fillLineColor else { return }
    //        progressLayer.backgroundColor = fillLineColor.cgColor
    //        
    //        // Apply the mask only to the progress layer, not the entire container or label
    //        progressLayer.mask = shapeLayer
    //        
    //        // Add the container view (progress bar + label) as a subview to the main view
    //        self.addSubview(progressContainer)
    //    }
    
    func drawLineProgress(progressfill:CGFloat = 0.0, fillLineColor:UIColor?, cornerRadius:CGFloat) {
        //        self.layer.sublayers?.removeAll()
        
        self.layer.sublayers?
            .filter { $0.name == "progress_line" }.forEach({$0.removeFromSuperlayer()})
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "progress_line"
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        shapeLayer.path = path.cgPath
        layer.mask = shapeLayer
        let progressRect = CGRect(origin: .zero, size: CGSize(width: self.frame.size.width*progressfill, height: self.frame.size.height))
        let prLayer = CALayer()
        prLayer.name = "progress_line"
        prLayer.frame = progressRect
        prLayer.cornerRadius = cornerRadius
        self.layer.addSublayer(prLayer)
        guard let fillLineColor = fillLineColor else { return }
        prLayer.backgroundColor = fillLineColor.cgColor
    }
    
    func centerAnimatedProgress(progressfill: CGFloat = 0.0, fillLineColor: UIColor?, cornerRadius: CGFloat) {
        // Remove any existing progress line layers
        self.layer.sublayers?
            .filter { $0.name == "progress_Center" }.forEach({$0.removeFromSuperlayer()})
        
        // Create a shape layer to mask the progress bar with rounded corners
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "progress_Center"
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        shapeLayer.path = path.cgPath
        layer.mask = shapeLayer
        
        // Create the progress layer (this will be animated)
        let progressRect = CGRect(origin: .zero, size: CGSize(width: self.frame.size.width * progressfill, height: self.frame.size.height))
        let prLayer = CALayer()
        prLayer.name = "progress_Center"
        prLayer.frame = progressRect
        prLayer.cornerRadius = cornerRadius
        
        // Add the progress layer to the main layer
        self.layer.addSublayer(prLayer)
        
        // Set the fill color for the progress layer
        guard let fillLineColor = fillLineColor else { return }
        prLayer.backgroundColor = fillLineColor.cgColor
        
        // Create and configure the animation
        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = 0  // Start from 0 width
        animation.toValue = progressRect.width  // Animate to the desired width
        animation.duration = 0.5  // Duration of the animation
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        
        // Apply the animation to the progress layer
        prLayer.add(animation, forKey: "progressFillAnimation")
        
        // Optionally, update the layer's frame after animation completes
        prLayer.frame.size.width = progressRect.width
    }
    
    
    /// Animates the view to show by sliding it up.
    /// - Parameters:
    ///   - duration: The duration of the animation.
    ///   - delay: The delay before starting the animation.
    ///   - completion: An optional completion handler.
    func animShow(duration: TimeInterval = 0.5, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        self.isHidden = true
        self.alpha = 0
        self.layoutIfNeeded() // Ensures the layout is correct before animation
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseIn], animations: {
            self.alpha += 1
            self.isHidden = false
            self.center.y -= self.bounds.height
            self.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }
    
    //        /// Animates the view to hide by sliding it down.
    //        /// - Parameters:
    //        ///   - duration: The duration of the animation.
    //        ///   - delay: The delay before starting the animation.
    //        ///   - completion: An optional completion handler.
    //        func animHide(duration: TimeInterval = 0.5, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
    //            UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
    //                self.center.y += self.bounds.height
    //                self.layoutIfNeeded()
    //            }, completion: { _ in
    //                self.isHidden = true
    //                completion?()
    //            })
    //        }
    //    
    
    /// Animates the view to hide by sliding it down.
    /// - Parameters:
    ///   - duration: The duration of the animation.
    ///   - delay: The delay before starting the animation.
    ///   - completion: An optional completion handler.
    func animHide(duration: TimeInterval = 0.5, delay: TimeInterval = 0, isTopDirection:Bool? = false, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
            if let isTopDirection = isTopDirection {
                (isTopDirection ? (self.center.y -= self.bounds.height): (self.center.y += self.bounds.height))
            }else{
                (self.center.y += self.bounds.height)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            self.isHidden = true
            completion?()
        })
    }
    
    func aninLeftRightHide(duration: TimeInterval = 0.5, delay: TimeInterval = 0, isLeftDirection:Bool? = false, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
            if let isLeftDirection = isLeftDirection {
                (isLeftDirection ? (self.center.x -= self.bounds.width): (self.center.x += self.bounds.width))
            }else{
                (self.center.y += self.bounds.height)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            self.isHidden = true
            completion?()
        })
    }
    
    
    func animTopBottom(duration: TimeInterval = 0.5, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        self.center.y = 0
        self.isHidden = true
        UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
            self.isHidden = false
            self.center.y += self.bounds.height/2.0
            self.layoutIfNeeded()
        }, completion: { _ in
            //Logic when completed show
            completion?()
        })
    }
    
    //    func animBottomTop(duration: TimeInterval = 0.5, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
    //        self.center.y = self.bounds.height
    //        self.isHidden = true
    //        UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
    //            self.isHidden = false
    //            self.center.y -= self.bounds.height / 2.0
    //            self.layoutIfNeeded()
    //        }, completion: { _ in
    //            completion?()
    //        })
    //    }
    
    
    //use this someView.applyTransition(type: .fade, duration: 1.0, timingFunction: .easeOut)
    //    func applyTransition(type: CATransitionType = .moveIn, subtype: CATransitionSubtype = .fromTop, duration: TimeInterval = 0.8, timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,completion: (() -> Void)? = nil) {
    //        let transition = CATransition()
    //        transition.duration = duration
    //        transition.timingFunction = CAMediaTimingFunction(name: timingFunction)
    //        transition.type = type
    //        transition.subtype = subtype
    //        self.layer.add(transition, forKey: nil)
    //        completion?()
    //    }
    
    func applyTransition(type: CATransitionType = .moveIn,
                         subtype: CATransitionSubtype = .fromTop,
                         duration: TimeInterval = 0.8,
                         timingFunction: CAMediaTimingFunctionName = .easeInEaseOut,
                         completion: (() -> Void)? = nil) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: timingFunction)
        transition.type = type
        transition.subtype = subtype
        self.layer.add(transition, forKey: "customTransition")
        
        // Ensure the completion block is executed on the main thread
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: completion)
        }
    }
    
    
    /*uses
     UIView.addDashedBorder(UIColor.txtDarkGray, filledColor: UIColor.clear, withWidth: 1.5, cornerRadius: 3.0, dashPattern: [6,2])
     */
    //MARK: ------------DASHLINE
    func addDashedBorder(_ borderColor: UIColor = UIColor.black, filledColor:UIColor = UIColor.clear , withWidth width: CGFloat = 2, cornerRadius: CGFloat = 5, dashPattern: [NSNumber] = [3,6]) {
        self.removeDashBorder()
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "Dash_DashBorder"
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        shapeLayer.fillColor = filledColor.cgColor
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineJoin = .round 
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        self.layer.masksToBounds = false
        self.layer.addSublayer(shapeLayer)
    }
    
    func removeDashBorder() {
        _ = self.layer.sublayers?.filter({$0.name == "Dash_DashBorder"}).map({$0.removeFromSuperlayer()})
    }
    
    //MARK: ----------------- AddDashedLine
    /*
     // Add dashed line
     dashedView.addDashedLine(strokeColor: .red, lineWidth: 2, dashPattern: [6, 3])
     */
    
    func addDashedLine(strokeColor: UIColor, lineWidth: CGFloat, dashPattern: [NSNumber]) {
        self.layer.sublayers?
            .filter { $0.name == "dash_line" }.forEach({$0.removeFromSuperlayer()})
        
        let dashedLayer = CAShapeLayer()
        dashedLayer.name = "dash_line"
        dashedLayer.strokeColor = strokeColor.cgColor
        dashedLayer.lineWidth = lineWidth
        dashedLayer.lineDashPattern = dashPattern
        
        // Create a path
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: self.bounds.height / 2)) // Start at the left middle
        path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height / 2)) // End at the right middle
        
        dashedLayer.path = path.cgPath
        dashedLayer.frame = self.bounds
        
        // Remove old dashed layers if needed
        //            self.layer.sublayers?.removeAll(where: { $0 is CAShapeLayer })
        
        self.layer.addSublayer(dashedLayer)
    }
    
    //MARK: ---------------ADD BLURE VIEW
    func addBlurView(viewShow:UIView?, alphBlur:Float = 0.2, bgColor:UIColor = .mainBg){
        self.removeAddedBlurView(viewShow: viewShow)
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = viewShow?.bounds ?? .zero
        blurView.backgroundColor = bgColor
        blurView.alpha = 0.2
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewShow?.insertSubview(blurView, at: 1)
    }
    
    
    func removeAddedBlurView(viewShow:UIView?){
        viewShow?.subviews.forEach { view in
            if view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        }
    }
}

//MARK: ---------------- Extension UITextfield
extension UITextField {
    
    func setLeftRightPadding(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = rightPaddingView
        self.rightViewMode = .always
    }
    
    func setLeftPaddingPoint(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setLeftPaddingWithImage(_ amount:CGFloat, _ lineheigth:CGFloat, _ setImg:UIImage? = nil,_ setTitle:String? = nil){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
        if let getTitle = setTitle {
            let btN = UIButton()
            btN.frame = paddingView.bounds
            btN.setImage(setImg, for: .normal)
            btN.setTitle(getTitle, for: .normal)
            btN.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
            btN.setTitleColor(UIColor.white, for: .normal)
            btN.isUserInteractionEnabled = false
            btN.backgroundColor = .clear
            paddingView.addSubview(btN)
            btN.contentHorizontalAlignment = .left
            btN.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            
            let lineV = UIView(frame: CGRect(x: paddingView.frame.width-8, y: (paddingView.frame.size.height-lineheigth)/2, width: 1.5, height: lineheigth))
            lineV.backgroundColor = UIColor.appDarkGray
            paddingView.addSubview(lineV)
        }else{
            let imgView = UIImageView(image: setImg)
            imgView.center = paddingView.center
            paddingView.addSubview(imgView)
        }
       
    }
    
    func setRightPaddingPoint(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setRightPaddingWithImage(_ amount:CGFloat, _ setImg:UIImage?){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        paddingView.backgroundColor = .clear
        self.rightViewMode = .always
        let imgView = UIImageView(image: setImg)
        imgView.center = paddingView.center
        paddingView.addSubview(imgView)
        imgView.backgroundColor = .clear
        
    }

    
    func placeholderSet(placeHolder : String , color : UIColor) {
        self.attributedPlaceholder =  NSAttributedString(string: placeHolder,
                                                         attributes: [NSAttributedString.Key.foregroundColor:color])
    }
        
    func setPlaceholder(text: String, font: UIFont, color: UIColor = .lightGray) {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color
            ]
            self.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
        }
    
    func setMultiColorPlaceholder(firstStr: String, firstColor: UIColor, firstfont: UIFont, secondStr: String, secondColor: UIColor, secondfont: UIFont) {
        let attributedString = NSMutableAttributedString()
        
        // Add the first string with its attributes
        let firstAttributedString = NSAttributedString(
            string: firstStr,
            attributes: [NSAttributedString.Key.foregroundColor: firstColor, NSAttributedString.Key.font: firstfont]
        )
        attributedString.append(firstAttributedString)
        
        let spaceAttr = NSAttributedString(
            string: " ",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.clear]
        )
        
        // Add the second string with its attributes
        let secondAttributedString = NSAttributedString(
            string: secondStr,
            attributes: [NSAttributedString.Key.foregroundColor: secondColor, NSAttributedString.Key.font: secondfont]
        )
        attributedString.append(spaceAttr)
        attributedString.append(secondAttributedString)
        // Set the attributed placeholder
        self.attributedPlaceholder = attributedString
    }
    
}

//MARK: --------- Extension UILabel

enum TrailingContent {
    case readmore
    case readless

    var text: String {
        switch self {
        case .readmore: return " Read More"
        case .readless: return " Read Less"
        }
    }
}


extension UILabel {
    
    func renderedLineCount(containerWidth: CGFloat) -> Int {
            guard let text = self.text, let font = self.font else { return 0 }

            let textStorage = NSTextStorage(string: text)
            let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))
            textContainer.lineFragmentPadding = 0.0
            textContainer.lineBreakMode = self.lineBreakMode
            textContainer.maximumNumberOfLines = self.numberOfLines

            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            textStorage.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))

            layoutManager.glyphRange(for: textContainer)

            var lineCount = 0
            var index = 0
            var lineRange = NSRange(location: 0, length: 0)

            while index < layoutManager.numberOfGlyphs {
                layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
                index = NSMaxRange(lineRange)
                lineCount += 1
            }

            return lineCount
        }
    
    /// Animates the label to scroll through an array of strings.
    /// - Parameters:
    ///   - strings: The array of strings to scroll through.
    ///   - selectedIndex: The index of the string to display initially.
    ///   - animationDuration: The duration of the animation for each change.
    ///   - completion: A closure that gets called when the scrolling is complete (optional).
    func animateTextScroll(
        strings: [String],
        selectedIndex: Int = 0,
        animationDuration: TimeInterval = 0.5,
        completion: (() -> Void)? = nil
    ) {
        guard !strings.isEmpty else { return }
        let currentIndex = selectedIndex % strings.count
        
        self.center.y = 0
        self.isHidden = true
        UIView.animate(withDuration: animationDuration, delay: 0.1, options: [.curveLinear], animations: {
            self.isHidden = false
            self.center.y += self.bounds.height
            self.text = strings[currentIndex]
            self.layoutIfNeeded()
        }, completion: { _ in
            //Logic when completed show
            completion?()
        })
        
    }
    
    //MARK: -------------FOR GRADIENT TEXT OF LABEL
//    func applyGradientLabel(startColor: UIColor, endColor: UIColor) {
    
    func applyGradientLabel(colors: [UIColor] = [.blue, .white], locations: [CGFloat] = [0, 1]) {
        guard let text = self.text, let font = self.font else { return  }
        
        let textSize = text.size(withAttributes: [.font: font])
        let width = textSize.width
        let height = textSize.height
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        
        guard let context = UIGraphicsGetCurrentContext(),
              let rgbColorspace = CGColorSpaceCreateDeviceRGB() as CGColorSpace? else {
            UIGraphicsEndImageContext()
            return
        }
        
        let locations: [CGFloat] = locations // [0.0, 0.3, 1.0]
        let colors = colors.map { $0.cgColor } // [startColor.cgColor, startColor.cgColor, endColor.cgColor] as CFArray
        
        guard let glossGradient = CGGradient(colorsSpace: rgbColorspace, colors: colors as CFArray, locations: locations) else {
            UIGraphicsEndImageContext()
            return
        }
        
        let topCenter = CGPoint(x: 0, y: 0)
        let bottomCenter = CGPoint(x: 0, y: height)
        context.drawLinearGradient(glossGradient, start: topCenter, end: bottomCenter, options: [])
        
        guard let gradientImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        UIGraphicsEndImageContext()
        
        self.textColor = UIColor(patternImage: gradientImage)
    }
    
    //---------------------
    
    private var minimumLines: Int { return 3 }
    private var highlightColor: UIColor { return UIColor(red: 246.0/255.0, green: 170.0/255.0, blue: 84.0/255.0, alpha: 1.0) }
    
    private var attributes: [NSAttributedString.Key: Any] {
        return [.font: self.font ?? .systemFont(ofSize: 15)]
    }
    
    public func requiredHeight(for text: String) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = minimumLines
        label.lineBreakMode = .byTruncatingTail
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func appendReadmore(after text: String, trailingContent: TrailingContent) {
        self.numberOfLines = minimumLines
        let truncatedText = truncateText(text, trailingContent: trailingContent)
        setAttributedText(truncatedText, trailingText: trailingContent.text)
    }
    
    func appendReadLess(after text: String, trailingContent: TrailingContent) {
        self.numberOfLines = 0
        let fullText = text + trailingContent.text
        setAttributedText(fullText, trailingText: trailingContent.text)
    }
    
    private func setAttributedText(_ text: String, trailingText: String) {
        let attributedString = NSMutableAttributedString(string: text)
        
        if let range = text.range(of: trailingText) {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.foregroundColor, value: highlightColor, range: nsRange)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        }
        
        self.attributedText = attributedString
    }
    
    private func truncateText(_ text: String, trailingContent: TrailingContent) -> String {
        let twoLineText = "\n" //"\n\n\n"
        let fourlineHeight = requiredHeight(for: twoLineText)
        
        let sentenceText = NSString(string: text)
        var endIndex = sentenceText.length
        var truncatedSentence = sentenceText
        
        let size = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        
        while truncatedSentence.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size.height >= fourlineHeight {
            if endIndex == 0 { break }
            endIndex -= 1
            truncatedSentence = NSString(string: sentenceText.substring(to: endIndex))
            truncatedSentence = (truncatedSentence as String + "... " + trailingContent.text) as NSString
        }
        
        return truncatedSentence as String
    }
    
    func addReadMoreTapGesture(target: Any, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
    }
    
    func getTappedTextIndex(_ tapLocation: CGPoint) -> Int? {
        guard let attributedText = self.attributedText else { return nil }
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: self.bounds.size)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        
        let locationOfTouchInLabel = tapLocation
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textOffset = CGPoint(x: (bounds.width - textBoundingBox.width) * 0.5 - textBoundingBox.origin.x,
                                 y: (bounds.height - textBoundingBox.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textOffset.x,
                                                     y: locationOfTouchInLabel.y - textOffset.y)
        let characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                          in: textContainer,
                                                          fractionOfDistanceBetweenInsertionPoints: nil)
        
        return characterIndex
    }
}


extension String {
    
    var ordinal: String {
         guard let number = Int(self) else { return self }

         let ones = number % 10
         let tens = (number / 10) % 10

         let suffix: String
         if tens == 1 {
             suffix = "th"
         } else {
             switch ones {
             case 1: suffix = "st"
             case 2: suffix = "nd"
             case 3: suffix = "rd"
             default: suffix = "th"
             }
         }

         return "\(number)\(suffix)"
     }

        func attributedStringWithGradient(
            _ gradientColors: [UIColor],
            frame: CGRect,
            font: UIFont,
            //Add startPoint and endPoint as parameters with default values for a vertical gradient
            startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), // Default: Top-center
            endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)    // Default: Bottom-center
        ) -> NSAttributedString {

            // 1. Create a gradient layer
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = frame
            gradientLayer.colors = gradientColors.map { $0.cgColor }

            // Set the start and end points for the linear gradient direction
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            // gradientLayer.type = .axial // This is the default, so explicitly setting it is optional for linear

            // 2. Create a pattern from the gradient layer
            UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, 0) // Use gradientLayer.bounds.size
            if let context = UIGraphicsGetCurrentContext() {
                gradientLayer.render(in: context)
                guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                    UIGraphicsEndImageContext()
                    // Return a basic attributed string in case of image creation failure
                    return NSAttributedString(string: self, attributes: [.font: font])
                }
                UIGraphicsEndImageContext()
                let patternColor = UIColor(patternImage: image)

                // 3. Create an attributed string
                let attributedString = NSMutableAttributedString(string: self)
                let fullRange = NSRange(location: 0, length: self.count)

                // Set the gradient color and font
                attributedString.addAttribute(.foregroundColor, value: patternColor, range: fullRange)
                attributedString.addAttribute(.font, value: font, range: fullRange)

                return attributedString
            } else {
                UIGraphicsEndImageContext() // Ensure context is ended even if UIGraphicsGetCurrentContext returns nil
                // Return a basic attributed string in case of context failure
                return NSAttributedString(string: self, attributes: [.font: font])
            }
        }
}


//MARK: --------- Extension UIImageView
extension UIImageView {
    
    /// Adds a gradient overlay to the image view
    func addGradientImgV(colors: [UIColor], locations: [NSNumber] = [0, 1], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.name = "gradientLayerImgV" // Prevent duplicates
        gradientLayer.contents = self.image?.cgImage

        // Ensure gradient frame updates correctly
        DispatchQueue.main.async {
            gradientLayer.frame = self.bounds

            // Remove any existing gradient layers
            self.layer.sublayers?.removeAll(where: { $0.name == "gradientLayerImgV" })

            // Insert gradient **above** image layer but below other content
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    
//    func addCellImgGradient(colors: [UIColor],
//                        locations: [NSNumber] = [0, 1],
//                        startPoint: CGPoint = CGPoint(x: 0, y: 0),
//                        endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
//           
//           // Remove any existing gradient layers
//           layer.sublayers?.removeAll(where: { $0.name == "cellGradientLayerImgV" })
//           
//           let gradientLayer = CAGradientLayer()
//           gradientLayer.name = "cellGradientLayerImgV"
//           gradientLayer.colors = colors.map { $0.cgColor }
//           gradientLayer.locations = locations
//           gradientLayer.startPoint = startPoint
//           gradientLayer.endPoint = endPoint
//           
//           // Important: set frame in layout cycle
//           gradientLayer.frame = bounds
//           
//           layer.insertSublayer(gradientLayer, at: 0)
//       }
    
    func addCellImgGradient(
        colors: [UIColor],
        locations: [NSNumber] = [0, 1],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 1),
        cornerRadius: CGFloat = 12  // default radius
    ) {
        // Remove any existing gradient layers
        layer.sublayers?.removeAll(where: { $0.name == "cellGradientLayerImgV" })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "cellGradientLayerImgV"
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.masksToBounds = true   // ensures corners are clipped
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
       
       // Call this in case the view resizes
       override open func layoutSubviews() {
           super.layoutSubviews()
           layer.sublayers?.filter { $0.name == "cellGradientLayerImgV" }
               .forEach { $0.frame = bounds }
       }
    
    
    //MARK: ---------------IMAGE GETTING FROM URL
    /// Loads a remote image, serving already-fetched ones straight from an
    /// in-memory cache.
    ///
    /// This used to assign `placeholder` unconditionally and then re-download on
    /// every call, so any `reloadData()` (or simply navigating back to a screen
    /// and having its list rebuilt) blanked every visible image for the length of
    /// a network round trip — the visible "flicker". A cache hit now assigns
    /// synchronously, so a re-display is seamless; the placeholder is only shown
    /// when there is genuinely nothing to show yet.
    func loadImage(urlString: String?, placeholder: UIImage?, resize: CGSize? = nil) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }

        let cacheKey = RemoteImageCache.key(for: urlString, resize: resize)
        if let cached = RemoteImageCache.shared.object(forKey: cacheKey) {
            self.image = cached
            return
        }

        self.image = placeholder

        Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    let finalImage = resize.map { image.resized(to: $0) } ?? image
                    if let finalImage = finalImage {
                        RemoteImageCache.shared.setObject(finalImage, forKey: cacheKey)
                        self?.image = finalImage
                    } else {
                        self?.image = placeholder
                    }
                } else {
                    self?.image = resize.flatMap { placeholder?.resized(to: $0) } ?? placeholder
                }
            } catch {
                self?.image = resize.flatMap { placeholder?.resized(to: $0) } ?? placeholder
            }
        }
    }

    //MARK: ---------------IMAGE GETTING FROM URL
    func loadImageWithRatio(urlString: String?, placeholder: UIImage?, resizeRatio: CGFloat? = nil) {
        self.image = placeholder
        guard let urlString = urlString, let url = URL(string: urlString) else { return }

        Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
//                    self?.image = image
                    if let resizeRatio = resizeRatio {
                        self?.image = self?.resizeToRatio(image: image, targetRatio: resizeRatio)
                    }else{
                        self?.image = image
                    }
                } else {
                    if let resizeRatio = resizeRatio {
                        self?.image = self?.resizeToRatio(image: self?.image, targetRatio: resizeRatio)
                    }else{
                        self?.image = placeholder
                    }
                }
            } catch {
                if let resizeRatio = resizeRatio {
                    self?.image = self?.resizeToRatio(image: self?.image, targetRatio: resizeRatio)
                }else{
                    self?.image = placeholder
                }
            }
        }
    }
    
    func resizeToRatio(image: UIImage?, targetRatio: CGFloat?) -> UIImage {
        guard let image = image, let targetRatio = targetRatio else {
            return UIImage() // or some placeholder
        }

        let height = image.size.height
        let width = height * targetRatio
        let newSize = CGSize(width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized ?? image
    }
    
    func setImageColor(_ color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
    
    func imageWith(_ name: String?, _ textColor: UIColor? = nil, inputBgColor bgColor:UIColor? = nil ) {
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = bgColor
        nameLabel.textColor = textColor
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        var initials = ""
        if let initialsArray = name?.components(separatedBy: " ") {
            if let firstWord = initialsArray.first {
                if let firstLetter = firstWord.first {
                    initials += String(firstLetter).capitalized }
            }
            if initialsArray.count > 1, let lastWord = initialsArray.last {
                if let lastLetter = lastWord.first { initials += String(lastLetter).capitalized
                }
            }
        }
        nameLabel.text = initials
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            
            self.image = nameImage
        }
    }
    
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
}

//MARK: ----------------- EXTENSION FOR UIIMAGE
extension UIImage {
    
    func rotatedBy(degree: CGFloat) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        defer { UIGraphicsEndImageContext() }
        UIColor.white.setFill()
        context.fill(.init(origin: .zero, size: size))
        context.translateBy(x: size.width/2, y: size.height/2)
        context.scaleBy(x: 1, y: -1)
        context.rotate(by: -degree * .pi / 180)
        context.draw(cgImage, in: CGRect(origin: .init(x: -size.width/2, y: -size.height/2), size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func rotated(degrees: CGFloat) -> UIImage? {

       let degreesToRadians: (CGFloat) -> CGFloat = { (degrees: CGFloat) in
         return degrees / 180.0 * CGFloat.pi
       }

       // Calculate the size of the rotated view's containing box for our drawing space
       let rotatedViewBox: UIView = UIView(frame: CGRect(origin: .zero, size: size))
       rotatedViewBox.transform = CGAffineTransform(rotationAngle: degreesToRadians(degrees))
       let rotatedSize: CGSize = rotatedViewBox.frame.size

       // Create the bitmap context
       UIGraphicsBeginImageContextWithOptions(rotatedSize, false, 0.0)

       guard let bitmap: CGContext = UIGraphicsGetCurrentContext(), let unwrappedCgImage: CGImage = cgImage else {
         return nil
       }

       // Move the origin to the middle of the image so we will rotate and scale around the center.
       bitmap.translateBy(x: rotatedSize.width/2.0, y: rotatedSize.height/2.0)

       // Rotate the image context
       bitmap.rotate(by: degreesToRadians(degrees))

       bitmap.scaleBy(x: CGFloat(1.0), y: -1.0)

       let rect: CGRect = CGRect(
           x: -size.width/2,
           y: -size.height/2,
           width: size.width,
           height: size.height)

       bitmap.draw(unwrappedCgImage, in: rect)

       guard let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
         return nil
       }

       UIGraphicsEndImageContext()

       return newImage
     }
  
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image
        { _ in
            draw(in: CGRect(origin: .zero,
                            size: size))
        }
    }
    
    func resized2(to size: CGSize) -> UIImage {
           UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
           self.draw(in: CGRect(origin: .zero, size: size))
           let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return resizedImage ?? self
       }
    
    func roundedImage() -> UIImage {
        let imageView: UIImageView = UIImageView(image: self)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = imageView.frame.width / 2
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    
    //-------------------------************** for GIFs
    
    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
          .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    @available(iOS 9.0, *)
    public class func gif(asset: String) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }

        return gif(data: dataAsset.data)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs
        // Check if one of them is nil
        if rhs == nil || lhs == nil {
            if rhs != nil {
                return rhs!
            } else if lhs != nil {
                return lhs!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if lhs! < rhs! {
            let ctp = lhs
            lhs = rhs
            rhs = ctp
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = lhs! % rhs!

            if rest == 0 {
                return rhs! // Found it
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }

    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        // Fill arrays
        for index in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
            }

            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(index),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        // Calculate full duration
        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
            }()

        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for index in 0..<count {
            frame = UIImage(cgImage: images[Int(index)])
            frameCount = Int(delays[Int(index)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)

        return animation
    }
    
    //------****************Image with Text
    
    class func textEmbededImage(image: UIImage?, string: String?, color: UIColor, imageAlignment: Int = 0, segFont: UIFont? = nil) -> UIImage? {
        guard let image = image else { return nil } // Handle nil image gracefully
        
        if string == nil || string?.isEmpty == true {
            // No text case: Return the original image
            return image
        }

        let font = segFont ?? UIFont.systemFont(ofSize: 16.0)
        let expectedTextSize: CGSize = (string! as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
        let width: CGFloat = expectedTextSize.width + image.size.width + 5.0
        let height: CGFloat = max(expectedTextSize.height, image.size.height)
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        
        let fontTopPosition: CGFloat = (height - expectedTextSize.height) / 2.0
        let textOrigin: CGFloat = (imageAlignment == 0) ? image.size.width + 5 : 0
        let textPoint: CGPoint = CGPoint(x: textOrigin, y: fontTopPosition)
        string?.draw(at: textPoint, withAttributes: [NSAttributedString.Key.font: font])
        
        let flipVertical: CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        context.concatenate(flipVertical)
        
        let alignment: CGFloat = (imageAlignment == 0) ? 0.0 : expectedTextSize.width + 5.0
        context.draw(image.cgImage!, in: CGRect(x: alignment, y: (height - image.size.height) / 2.0, width: image.size.width, height: image.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

extension UICollectionView{
    //MARK: -------------GET LAST CELL
    func isLastCell() -> Int? {
        let lastSectionIndex = self.numberOfSections - 1
        let lastRowIndex = self.numberOfItems(inSection: lastSectionIndex) - 1
        return lastRowIndex
    }
    
    //MARK: ------------- TO SHOW EMPTY ALERT
    func numberOfRows(count: Int? = 0, title: String? = nil, message: String? = nil, messageImage: UIImage? = nil, messageImageHeight: CGFloat? = nil, reloadBtnBgColor: UIColor? = UIColor.appWhite, reloadBtnTitleColor: UIColor? = UIColor.mainBg, reloadSetTitle: String? = nil,  target: Any? = nil, action: Selector? = nil, fromCenter: CGFloat? = -20, fromTop: CGFloat? = nil) -> Int {
        self.backgroundView = nil
        
        if count == 0 || count == nil {
            let imgMsgHeight: CGFloat = messageImageHeight ?? messageImage?.size.height ?? 80
            
            // Create the empty view
            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            emptyView.backgroundColor = UIColor.clear
            
            let messageImageView = UIImageView()
            let titleLabel = UILabel()
            let messageLabel = UILabel()
            let reloadBtn = UIButton()
            
            // Configure the subviews
            messageImageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            reloadBtn.translatesAutoresizingMaskIntoConstraints = false
            
            messageImageView.backgroundColor = .clear
            messageImageView.image = messageImage
            messageImageView.contentMode = .scaleAspectFill
            
            titleLabel.text = title
            titleLabel.textColor = UIColor.appWhite
            titleLabel.font = AppFont.medium.size(24, familyName: familyClashDisplay)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            
            messageLabel.text = message
            messageLabel.textColor = UIColor.txtDarkGray
            messageLabel.font = AppFont.semibold.size(14, familyName: familyManrope)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            
            if let reloadSetTitle = reloadSetTitle {
                reloadBtn.setTitle(reloadSetTitle, for: .normal)
                reloadBtn.setTitleColor(reloadBtnTitleColor, for: .normal)
                reloadBtn.backgroundColor = reloadBtnBgColor
                reloadBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
                reloadBtn.contentEdgeInsets = UIEdgeInsets(top: 17, left: 56, bottom: 17, right: 56)
                
                // Add target for reload button
                if let target = target , let action = action {
                    reloadBtn.addTarget(target, action: action, for: .touchUpInside)
                }
            }
            
            // Add subviews to the emptyView
            emptyView.addSubview(messageImageView)
            emptyView.addSubview(titleLabel)
            emptyView.addSubview(messageLabel)
            emptyView.addSubview(reloadBtn)
            
            // Initialize an array to hold constraints
            var constraints: [NSLayoutConstraint] = []
            
            // Add conditional constraints for messageImageView
            if let fromTop = fromTop {
                constraints.append(messageImageView.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: fromTop))
            } else {
                constraints.append(messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: fromCenter ?? -20))
            }
            
            // Add common constraints
            constraints.append(contentsOf: [
                messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                messageImageView.heightAnchor.constraint(equalToConstant: imgMsgHeight),
                
                // Title label constraints
                titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 12),
                titleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20),
                
                // Message label constraints
                messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                
                // Reload button constraints
                reloadBtn.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
                reloadBtn.bottomAnchor.constraint(lessThanOrEqualTo: emptyView.bottomAnchor, constant: -12),
                reloadBtn.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor, constant: 1),
                reloadBtn.heightAnchor.constraint(equalToConstant: 45)
            ])
            
            // Activate all constraints
            NSLayoutConstraint.activate(constraints)
            
            DispatchQueue.main.async {
                reloadBtn.layoutIfNeeded()
                reloadBtn.layer.cornerRadius = 12.0
                reloadBtn.layer.masksToBounds = true
                
            }
            
            // Set the empty view as the table view's background view
            self.backgroundView = emptyView
        } else {
            // Reset the background view and separator style
            self.backgroundView = nil
        }
        
        return count ?? 0
    }
}

//MARK: --------- Extension UITableView
extension UITableView {
    func isLastRow() -> Int? {
        
        let lastSectionIndex = self.numberOfSections - 1 // last section
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1
        return lastRowIndex
    }
    //        let lastSectionIndex = self.numberOfSections - 1 // last section
    //        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1 // last row
    //        self.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: animated)
    //    }
    
    
    //MARK: ------------- TO SHOW EMPTY ALERT
    func numberOfRows(count: Int? = 0, title: String? = nil, message: String? = nil, messageImage: UIImage? = nil, messageImageHeight: CGFloat? = nil, reloadBtnBgColor: UIColor? = UIColor.appWhite, reloadBtnTitleColor: UIColor? = UIColor.mainBg, reloadSetTitle: String? = nil, reloadBtnImg: UIImage? = nil , target: Any? = nil, action: Selector? = nil, fromCenter: CGFloat? = -20, fromTop: CGFloat? = nil) -> Int {
        self.backgroundView = nil
        self.separatorStyle = .none
        
        if count == 0 || count == nil {
            let imgMsgHeight: CGFloat = messageImageHeight ?? messageImage?.size.height ?? 80
            
            // Create the empty view
            let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            emptyView.backgroundColor = UIColor.clear
            
            let messageImageView = UIImageView()
            let titleLabel = UILabel()
            let messageLabel = UILabel()
            let reloadBtn = UIButton()
            
            // Configure the subviews
            messageImageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            reloadBtn.translatesAutoresizingMaskIntoConstraints = false
            
            messageImageView.backgroundColor = .clear
            messageImageView.image = messageImage
            messageImageView.contentMode = .scaleAspectFill
            messageImageView.clipsToBounds = true
            
            titleLabel.text = title
            titleLabel.textColor = UIColor.appWhite
            titleLabel.font = AppFont.medium.size(24, familyName: familyClashDisplay)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            
            messageLabel.text = message
            messageLabel.textColor = UIColor.txtDarkGray
            messageLabel.font = AppFont.semibold.size(14, familyName: familyManrope)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            
            if let reloadSetTitle = reloadSetTitle {
                reloadBtn.setTitle(reloadSetTitle, for: .normal)
//                reloadBtn.setImage(reloadBtnImg, for: .normal)
                reloadBtn.setTitleColor(reloadBtnTitleColor, for: .normal)
                reloadBtn.backgroundColor = reloadBtnBgColor
                reloadBtn.titleLabel?.font = AppFont.bold.size(16, familyName: familyManrope)
                reloadBtn.contentEdgeInsets = UIEdgeInsets(top: 17, left: 56, bottom: 17, right: 56)
                
                if let reloadBtnImg = reloadBtnImg {
                    reloadBtn.imageEdgeInsets = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 10)
                    reloadBtn.setImage(reloadBtnImg, for: .normal)
                }
                
                // Add target for reload button
                if let target = target , let action = action {
                    reloadBtn.addTarget(target, action: action, for: .touchUpInside)
                }
            }
            
            // Add subviews to the emptyView
            emptyView.addSubview(messageImageView)
            emptyView.addSubview(titleLabel)
            emptyView.addSubview(messageLabel)
            emptyView.addSubview(reloadBtn)
            
            // Initialize an array to hold constraints
            var constraints: [NSLayoutConstraint] = []
            
            // Add conditional constraints for messageImageView
            if let fromTop = fromTop {
                constraints.append(messageImageView.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: fromTop))
            } else {
                constraints.append(messageImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: fromCenter ?? -20))
            }
            
            // Add common constraints
            constraints.append(contentsOf: [
                messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                messageImageView.heightAnchor.constraint(equalToConstant: imgMsgHeight),
                
                // Title label constraints
                titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 12),
                titleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20),
                
                // Message label constraints
                messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                
                // Reload button constraints
                reloadBtn.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
                reloadBtn.bottomAnchor.constraint(lessThanOrEqualTo: emptyView.bottomAnchor, constant: -12),
                reloadBtn.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor, constant: 1),
                reloadBtn.heightAnchor.constraint(equalToConstant: 45)
            ])
            
            // Activate all constraints
            NSLayoutConstraint.activate(constraints)
            
            DispatchQueue.main.async {
                reloadBtn.layoutIfNeeded()
                reloadBtn.layer.cornerRadius = 12.0
                reloadBtn.layer.masksToBounds = true
                
            }
            
            // Set the empty view as the table view's background view
            self.backgroundView = emptyView
            self.separatorStyle = .none
        } else {
            // Reset the background view and separator style
            self.backgroundView = nil
            self.separatorStyle = .singleLine
        }
        
        return count ?? 0
    }
    
}

//MARK: --------- Extension UINavigationController
extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
      if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
          popToViewController(vc, animated: animated)
      } else if let firstVC = viewControllers.first {
          popToViewController(firstVC, animated: animated)
      }
      
//    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
//      popToViewController(vc, animated: animated)
//    }
  }
}

//MARK: --------- Extension UIColor
//enum AppColorName{
//    case app_mainBlue
//    case app_Gray
//    case app_lightBlueColor
//    
//}
//
//extension UIColor {
//    static func appColor(_ name: AppColorName) -> UIColor? {
//        switch name {
//        case .app_mainBlue:
//            return UIColor(named: "BlueMain")
//        case .app_Gray:
//            return UIColor(named: "appGray")
//        case .app_lightBlueColor:
//            return UIColor(named: "lightBlueColor")
//        }
//    }
//}

//MARK: ---------------UISlider
extension UISlider{
    
    func setSlider(gradientColors:[CGColor]){
        let tgl = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        tgl.frame = frame
        tgl.colors = gradientColors
        tgl.startPoint = CGPoint(x: 0.0, y: 0.5)
        tgl.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        UIGraphicsBeginImageContextWithOptions(tgl.frame.size, tgl.isOpaque, 0.0)
        tgl.render(in: UIGraphicsGetCurrentContext()!)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            
            let resizableImage = image.resizableImage(withCapInsets: .zero)
            
            // Apply the gradient image to the slider's track
            self.setMinimumTrackImage(resizableImage, for: .normal)
        }
    }
    
//    var thumbImageCenterX: CGFloat {
//        let trackRect = trackRect(forBounds: bounds)
//        let thumbRect = thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
//         return thumbRect.origin.x + thumbRect.width / 2 - frame.size.width / 2
//     }
    
//    /// Returns the absolute center X position of the thumb image in the slider's superview
//     var thumbImageCenterX: CGFloat {
//         let trackRect = self.trackRect(forBounds: self.bounds)
//         let thumbRect = self.thumbRect(forBounds: self.bounds, trackRect: trackRect, value: self.value)
//         return self.frame.origin.x + thumbRect.midX
//     }
//
//     /// Returns the absolute center point (X and Y) of the thumb image
//     var thumbImageCenter: CGPoint {
//         let trackRect = self.trackRect(forBounds: self.bounds)
//         let thumbRect = self.thumbRect(forBounds: self.bounds, trackRect: trackRect, value: self.value)
//         return CGPoint(
//             x: self.frame.origin.x + thumbRect.midX,
//             y: self.frame.origin.y + thumbRect.midY
//         )
//     }
    
//    func setCustomThumbImage(_ image: UIImage, size: CGSize) {
//          // Resize the image (if needed)
//          let resized = image.resized(to: size)
//
//          // Set image
//          self.setThumbImage(resized, for: .normal)
//          self.setThumbImage(resized, for: .highlighted)
//
//          // Adjust minimum/maximum track insets (optional for alignment)
//          let thumbOffset = size.width / 2
////          self.minimumTrackTintColor = .clear
////          self.maximumTrackTintColor = .clear
//
//        let minTrack = UIImage(color: .systemBlue, size: CGSize(width: 1, height: 4))?.resizableImage(withCapInsets: .zero)
//        let maxTrack = UIImage(color: .lightGray, size: CGSize(width: 1, height: 4))?.resizableImage(withCapInsets: .zero)
//
//          self.setMinimumTrackImage(minTrack, for: .normal)
//          self.setMaximumTrackImage(maxTrack, for: .normal)
//      }
    
//    func applyLargeThumbFix(thumb: UIImage, size: CGSize) {
//          // Resize thumb image
//          let thumbImage = thumb.resized(to: size)
//          self.setThumbImage(thumbImage, for: .normal)
//          self.setThumbImage(thumbImage, for: .highlighted)
//
//          // Create transparent paddings on track
//          let leftCap = Int(size.width / 2)
//        let minTrackImage = UIImage(color: .systemBlue, size: CGSize(width: 1, height: 4))?
//              .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: CGFloat(leftCap), bottom: 0, right: 0))
//
//        let maxTrackImage = UIImage(color: .lightGray, size: CGSize(width: 1, height: 4))?
//              .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(leftCap)))
//
//          self.setMinimumTrackImage(minTrackImage, for: .normal)
//          self.setMaximumTrackImage(maxTrackImage, for: .normal)
//      }
}

//MARK: ----------------Extension for UISearchBar
extension UISearchBar {
    public var textField: UITextField? {
        if #available(iOS 13, *) {
            return searchTextField
        }
        let subViews = subviews.flatMap { $0.subviews }
        guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else {
            return nil
        }
        return textField
    }
    
    func clearBackgroundColor() {
        guard let UISearchBarBackground: AnyClass = NSClassFromString("UISearchBarBackground") else { return }
        
        for view in subviews {
            for subview in view.subviews where subview.isKind(of: UISearchBarBackground) {
                subview.alpha = 0
            }
        }
    }
    
    public var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
    }
    
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    let newActivityIndicator = UIActivityIndicatorView(style: .gray)
                    newActivityIndicator.color = UIColor.gray
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = textField?.backgroundColor ?? UIColor.white
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width - newActivityIndicator.frame.width / 2,
                                                          y: leftViewSize.height / 2)
                }
            } else {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
    
    func changePlaceholderColor(_ color: UIColor) {
        guard let UISearchBarTextFieldLabel: AnyClass = NSClassFromString("UISearchBarTextFieldLabel"),
              let field = textField else {
            return
        }
        for subview in field.subviews where subview.isKind(of: UISearchBarTextFieldLabel) {
            (subview as! UILabel).textColor = color
        }
    }
    
    func setRightImage(normalImage: UIImage,
                       highLightedImage: UIImage) {
        showsBookmarkButton = true
        if let btn = textField?.rightView as? UIButton {
            btn.setImage(normalImage,
                         for: .normal)
            btn.setImage(highLightedImage,
                         for: .highlighted)
        }
    }
    
    func setLeftImage(_ image: UIImage,
                      with padding: CGFloat = 0,
                      tintColor: UIColor) {
        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.tintColor = tintColor
        
        if padding != 0 {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let paddingView = UIView()
            paddingView.translatesAutoresizingMaskIntoConstraints = false
            paddingView.widthAnchor.constraint(equalToConstant: padding).isActive = true
            paddingView.heightAnchor.constraint(equalToConstant: padding).isActive = true
            stackView.addArrangedSubview(paddingView)
            stackView.addArrangedSubview(imageView)
            textField?.leftView = stackView
            
        } else {
            textField?.leftView = imageView
        }
    }
    
    func setPlaceholderColor(_ color: UIColor) {
        let textField = self.value(forKey: "searchField") as? UITextField
        let placeholder = textField!.value(forKey: "placeholderLabel") as? UILabel
        placeholder?.textColor = color
    }
    
    //MARK: ------------ADD DONE BUTTON
    func addDoneButtonOnKeyboard() {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
            
            doneButton.action = #selector(self.dismissKeyboard)
            doneButton.target = self
            
            toolbar.items = [flexSpace, doneButton]
            textField.inputAccessoryView = toolbar
        }
    }
    
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
        self.endEditing(true)
    }
}

//MARK: -----------Extension UISegmentedControl
extension UISegmentedControl {

    func setTitleColor(_ color: UIColor, state: UIControl.State = .normal) {
        var attributes = self.titleTextAttributes(for: state) ?? [:]
        attributes[.foregroundColor] = color
        self.setTitleTextAttributes(attributes, for: state)
    }
    
    func setTitleFont(_ font: UIFont, state: UIControl.State = .normal) {
        var attributes = self.titleTextAttributes(for: state) ?? [:]
        attributes[.font] = font
        self.setTitleTextAttributes(attributes, for: state)
    }

}


extension Date{
    func DateToStr(format:String = "yyyy/MM/dd HH:mm:ss")->String{
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale.current
        timeFormatter.timeZone = TimeZone.current
        timeFormatter.dateFormat = format
        
        let nowTimestr = timeFormatter.string(from: self)
        return nowTimestr
    }
}

//MARK: -----------------CATransition
extension CATransition {

//New viewController will appear from bottom of screen.
func segueFromBottom() -> CATransition {
    self.duration = 0.375 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.moveIn
    self.subtype = CATransitionSubtype.fromTop
    return self
}
//New viewController will appear from top of screen.
func segueFromTop() -> CATransition {
    self.duration = 0.375 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.moveIn
    self.subtype = CATransitionSubtype.fromBottom
    return self
}
 //New viewController will appear from left side of screen.
func segueFromLeft() -> CATransition {
    self.duration = 0.1 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.moveIn
    self.subtype = CATransitionSubtype.fromLeft
    return self
}
//New viewController will pop from right side of screen.
func popFromRight() -> CATransition {
    self.duration = 0.1 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.reveal
    self.subtype = CATransitionSubtype.fromRight
    return self
}
//New viewController will appear from left side of screen.
func popFromLeft() -> CATransition {
    self.duration = 0.1 //set the duration to whatever you'd like.
    self.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    self.type = CATransitionType.reveal
    self.subtype = CATransitionSubtype.fromLeft
    return self
   }
}

extension UIVisualEffectView {
    static func disableAllBlur(in view: UIView) {
        view.subviews.forEach{ subview in
            if let blur = subview as? UIVisualEffectView {
                blur.effect = nil
                blur.backgroundColor = .clear
                blur.isHidden = true
            }
            disableAllBlur(in: subview)
        }
    }
}


extension UIView {
    
    func applyGradient(colors: [UIColor],
                       startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
                       endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        
        // Remove old gradient if exists
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
