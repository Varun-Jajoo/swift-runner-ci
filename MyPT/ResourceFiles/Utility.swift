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

    }
    
    // This method hide the MBProgressHUD loader and can be invoked from any ViewController
    class func hideLoader() {
        SVProgressHUD.dismiss()
    }
    
    //MARK: -----------------------MAKING FOR SOCIAL SHARE
    func shareSocial(viewController: UIViewController, textToShare: String, imageToShare: UIImage, urlShareStr: String){
        DispatchQueue.main.async {
            
            let urlToShare = URL(string: urlShareStr)
            
            // Create an array of items to share
            var itemsToShare = [Any]()
            itemsToShare.append(textToShare)
            itemsToShare.append(imageToShare)
            if let url = urlToShare { itemsToShare.append(url) }
            
            // Create a UIActivityViewController
            let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            
            // Exclude certain activities (optional)
            activityViewController.excludedActivityTypes = [
                .addToReadingList,
                .assignToContact
            ]
            
            // Present the activity view controller
            viewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

