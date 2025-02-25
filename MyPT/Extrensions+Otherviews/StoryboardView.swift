//
//  StoryboardView.swift
//  MyPT
//
//  Created by techsaga corp on 23/10/24.
//

import UIKit

enum AppStoryboard: String {
    case main = "Main"
    case dashboard = "Dashboard"
    case booking = "Booking"
    case calendar = "Calendar"
    case library = "Library"
    case more = "More"
    case shop = "Shop"
}

extension UIViewController {

    class func instantiate<T: UIViewController>(appStoryboard: AppStoryboard) -> T {

        let storyboard = UIStoryboard(name: appStoryboard.rawValue, bundle: nil)
        let identifier = String(describing: self)
        
        if let storyboardVC = storyboard.instantiateViewController(withIdentifier: identifier) as? T {
            
            return storyboardVC
        }else {
            return T()
        }
        
//        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
}
