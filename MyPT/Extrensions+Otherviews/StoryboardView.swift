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
    case profile = "Profile"
    case purchase = "Purchase"
    case homepage = "Homepage"
}

private var backgroundImageViewTag: Int { return 9991 }
private var navigationButtonTag: Int { return 9992 }

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
    
    //MARK: ------------- SET BACKGROUND IMAGE
    func setTopBackgroundImage(named imageName: String) {
        let backgroundImageView = UIImageView()
        if let imageView = view.viewWithTag(backgroundImageViewTag) {
            imageView.removeFromSuperview()
        }
        backgroundImageView.tag = backgroundImageViewTag
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.isUserInteractionEnabled = false // So it doesn't block touches

        view.addSubview(backgroundImageView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Add Top Navigation Button
    func addTopNavigationButton(title: String? = "Back", image: UIImage? = nil, action: Selector? = nil) {
        let button = UIButton(type: .system)
        button.tag = navigationButtonTag
        if let button = view.viewWithTag(navigationButtonTag) {
            button.removeFromSuperview()
        }
        button.setTitleColor(UIColor.appWhite, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        if let titleStr = title, let image = image {
            button.setTitle("  " + titleStr, for: .normal)
            button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
          
        }else{
            button.setTitle(title, for: .normal)
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func handleTopButtonTapped() {
        // Remove the background image view
        if let imageView = view.viewWithTag(backgroundImageViewTag) {
            imageView.removeFromSuperview()
        }
        
        // Remove the button
        if let button = view.viewWithTag(navigationButtonTag) {
            button.removeFromSuperview()
        }
    }

}
