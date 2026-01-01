//
//  Utility.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit
import SVProgressHUD

// MARK: - Utility Loader
class Utility: NSObject {

    static let shared = Utility()
    private override init() {}

    private static var loaderView: UIView?
    private static var messageLabel: UILabel?
    private var backgroundGradient: CAGradientLayer?

    class func showLoader(
        message: String = "We're preparing your personalised training experience",
        fullScreen: Bool = true
    ) {
        guard let window = UIApplication.shared
            .windows.first(where: { $0.isKeyWindow }) else { return }

        hideLoader()

        let overlay = UIView(frame: window.bounds)
        overlay.isUserInteractionEnabled = true
        overlay.backgroundColor = .clear   // important

        // ⭐ Add gradient to overlay
        addGradientBackground(to: overlay)

        // Loader (TOP)
        let loader = DotRingLoaderView()
        loader.translatesAutoresizingMaskIntoConstraints = false

        // Label (BOTTOM)
        let label = UILabel()
        label.text = message
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        messageLabel = label

        let stack = UIStackView(arrangedSubviews: [loader, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        overlay.addSubview(stack)

        NSLayoutConstraint.activate([
            loader.widthAnchor.constraint(equalToConstant: 60),
            loader.heightAnchor.constraint(equalToConstant: 60),

            stack.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),

            label.widthAnchor.constraint(lessThanOrEqualToConstant: 260)
        ])

        window.addSubview(overlay)
        loaderView = overlay
    }

    class func hideLoader() {
        loaderView?.removeFromSuperview()
        loaderView = nil
        messageLabel = nil
    }

    class func updateLoaderMessage(_ text: String) {
        messageLabel?.text = text
    }
    
    private static func addGradientBackground(to view: UIView) {

        // remove old gradient if any
        view.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        let gradient = CAGradientLayer()
        gradient.frame = view.bounds

        gradient.colors = [
            UIColor.black.cgColor,
            UIColor(hex: "#0A1A10").cgColor,
            UIColor.black.cgColor
        ]

        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1.0)

        view.layer.insertSublayer(gradient, at: 0)
    }

    
//    class func showLoader(message: String? = nil) {
//        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
//        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
//        SVProgressHUD.setBackgroundColor(UIColor.appWhite)
//        SVProgressHUD.setForegroundColor(UIColor.appGreen)
//        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
//        SVProgressHUD.show(withStatus: message)
//        
//        /*
//        // Auto-dismiss after 90 seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + 90) {
//            if SVProgressHUD.isVisible() {
//                SVProgressHUD.dismiss()
//                AlertHelper.shared.showCustomeAlert(message: "Request timed out. Please try again.")
//            }
//        }
//        */
//    }
//    
//    
//    // This method hide the MBProgressHUD loader and can be invoked from any ViewController
//    class func hideLoader() {
//        SVProgressHUD.dismiss()
//    }
    
    //MARK: -----------------------MAKING FOR SOCIAL SHARE
    func shareSocial(
        viewController: UIViewController,
        textToShare: String,
        imageToShare: UIImage?,
        urlShareStr: String,
        sourceView: UIView? = nil
    ) {
        showLoadingIndicator(on: viewController.view)
        let group = DispatchGroup()
        var activityItems: [Any] = [textToShare]
        // Start compressing image in background
        if let image = imageToShare {
            group.enter()
            DispatchQueue.global().async {
                if let compressedData = image.jpegData(compressionQuality: 0.2),
                   let compressedImage = UIImage(data: compressedData) {
                    activityItems.append(compressedImage)
                }
                group.leave()
            }
        }
        // Add URL (sync)
        if let url = URL(string: urlShareStr) {
            group.enter()
            activityItems.append(url)
            group.leave()
        }
        // Once all async tasks are done
        group.notify(queue: .main) {
            hideLoadingIndicator()
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityVC.excludedActivityTypes = [
                .addToReadingList,
                .assignToContact,
                .print,
                .saveToCameraRoll
            ]
            // For iPad compatibility
            if let popover = activityVC.popoverPresentationController {
                let source = sourceView ?? viewController.view
                popover.sourceView = source
                if let source = source {
                    popover.sourceRect = CGRect(x: source.bounds.midX, y: source.bounds.midY, width: 0, height: 0)
                }
                popover.permittedArrowDirections = []
            }
            viewController.present(activityVC, animated: true)
        }
    }
    
    func checkForUpdate(completion: @escaping (_ oldVersion:String?, _ newVersion:String? ,Bool) -> Void) {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleID)"
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            completion(currentVersion, nil,true)
        }
        
//        guard let url = URL(string: urlString) else {
//            completion(nil,nil,false) // Ensure completion is always called
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                completion(nil,nil,false) // Ensure completion is always called
//                return
//            }
//            
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let results = json["results"] as? [[String: Any]],
////                   let appStoreVersion = results.first?["version"] as? String {
////                    
////                    DispatchQueue.main.async {
////                        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
////                            print("Current Version: \(currentVersion)")
////                            print("App Store Version: \(appStoreVersion)")
////                            
////                            // Corrected comparison: Show update only if the current version is OLDER
////                            //orderedAscending
//////                            if currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending {
//////                                guard let url = URL(string: "Need here is link of app store.") else { return }
//////                                
////////                                AlertHelper.shared.showCustomeAlert(title: "Update Required", message: "A new update of the app is available. Please update to continue.", actions: ["Update Now"], withCancel: false) { index in
////////                                    if index != nil {
////////                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
////////                                    }
////////                                }
//////                                
//////                                completion(currentVersion, appStoreVersion,true)
//////                            } else {
////                                completion(nil, nil,false)
////                            }
////                        } else {
////                            completion(nil, nil,false)
////                        }
////                    }
//                } else {
//                    completion(nil, nil,false)
//                }
//            } catch {
//                print("Error parsing app version: \(error.localizedDescription)")
//                completion(nil,nil,false)
//            }
//        }
//        task.resume()
    }
}


var loadingView: UIView?

func showLoadingIndicator(on view: UIView) {
    let loaderView = UIView(frame: view.bounds)
    loaderView.backgroundColor = UIColor(white: 0, alpha: 0.4)

    let indicator = UIActivityIndicatorView(style: .large)
    indicator.center = loaderView.center
    indicator.startAnimating()

    loaderView.addSubview(indicator)
    view.addSubview(loaderView)
    loadingView = loaderView
}

func hideLoadingIndicator() {
    loadingView?.removeFromSuperview()
    loadingView = nil
}

// MARK: - Dot Ring Loader
class DotRingLoaderView: UIView {

    private let replicatorLayer = CAReplicatorLayer()
    private let dot = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLoader()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLoader()
    }

    private func setupLoader() {

        let dotCount = 6
        let angle = (2 * CGFloat.pi) / CGFloat(dotCount)

        layer.addSublayer(replicatorLayer)
        replicatorLayer.instanceCount = dotCount
        replicatorLayer.instanceTransform =
            CATransform3DMakeRotation(angle, 0, 0, 1)
        replicatorLayer.instanceDelay = 0.1

        dot.backgroundColor = UIColor.white.cgColor
        dot.cornerRadius = 5
        replicatorLayer.addSublayer(dot)

        // Fade animation
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 1
        anim.toValue = 0.2
        anim.duration = 0.8
        anim.repeatCount = .infinity
        dot.add(anim, forKey: "opacity")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        replicatorLayer.frame = bounds

        let radius: CGFloat = 18
        let dotSize: CGFloat = 10

        dot.frame = CGRect(
            x: bounds.midX - dotSize/2,
            y: bounds.midY - radius - dotSize/2,
            width: dotSize,
            height: dotSize
        )
        dot.cornerRadius = dotSize / 2
    }
}

