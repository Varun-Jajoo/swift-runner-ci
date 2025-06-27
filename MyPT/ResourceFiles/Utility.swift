//
//  Utility.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit
import SVProgressHUD


class Utility: NSObject {
    static let shared = Utility()
    private override init() {
    }
    
    class func showLoader(message: String? = nil) {
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setBackgroundColor(UIColor.appWhite)
        SVProgressHUD.setForegroundColor(UIColor.appGreen)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        SVProgressHUD.show(withStatus: message)
        
        /*
        // Auto-dismiss after 90 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 90) {
            if SVProgressHUD.isVisible() {
                SVProgressHUD.dismiss()
                AlertHelper.shared.showCustomeAlert(message: "Request timed out. Please try again.")
            }
        }
        */
    }
    
    
    // This method hide the MBProgressHUD loader and can be invoked from any ViewController
    class func hideLoader() {
        SVProgressHUD.dismiss()
    }
    
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
