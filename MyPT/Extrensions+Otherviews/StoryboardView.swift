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
    
    /// Scrolls the nearest UIScrollView to bring the given view into visibility
    func scrollToView(_ targetView: UIView, fromYPosition: CGFloat = 50.0, animated: Bool = true) {
        // Find the UIScrollView in the view hierarchy
        guard let scrollView = self.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView else {
            print("No UIScrollView found in the view hierarchy")
            return
        }
        
        // Convert target view’s position relative to UIScrollView
        let targetY = scrollView.convert(targetView.frame.origin, from: targetView.superview).y - fromYPosition
        
        // Ensure we don't scroll beyond the allowed range
        let maxOffsetY = max(0, min(targetY, scrollView.contentSize.height - scrollView.bounds.height))
        
        // Scroll to the calculated position
        scrollView.setContentOffset(CGPoint(x: 0, y: maxOffsetY), animated: animated)
    }
}
