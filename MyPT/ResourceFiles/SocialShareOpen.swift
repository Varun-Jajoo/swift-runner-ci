//
//  SocialShareOpen.swift
//  MyPT
//
//  Created by techsaga corp on 21/06/25.
//

import UIKit

// Generic app-screen router fed by the backend's catch-all deeplink route
// (routes/web.php: `/{type}/{id?}`). Adding a new screen only needs a new
// case here (and the matching case in Android's DeepLinkRouter) - no
// backend change required. `type` is the first path segment, `id` the
// second (optional), `action` a third segment kept only for gym's existing
// calendar-flow suffix (e.g. `/gym/123/booking`).
func navigateUniversalLink(_ url: URL, window: UIWindow?) {
    guard let rootNav = resolveTopNavigationController(window: window) else {
        return
    }

    let pathComponents = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
    guard let screenType = pathComponents.first?.lowercased() else {
        return
    }
    let id = pathComponents.count > 1 ? pathComponents[1] : nil
    let action = pathComponents.count > 2 ? pathComponents[2] : nil

    switch screenType {
    case "class":
        guard let id = id, !id.isEmpty else { return }
        var tapThrough = GroupClassTapThroughData()
        tapThrough.scheduleId = id

        let vc = GroupTrainingDetailViewController()
        vc.tapThrough = tapThrough
        vc.hidesBottomBarWhenPushed = true
        rootNav.pushViewController(vc, animated: true)

    case "gym":
        let vc: GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
        vc.inputStudioId = id
        vc.inputType = screenType
        if let action = action {
            vc.gymDetailsFlow = calendarFlow.from(string: action)
        }
        rootNav.pushViewController(vc, animated: true)

    case "pt-booking":
        guard let id = id else { return }
        let vc: BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
        vc.bookingIdStr = id
        vc.detailsFlow = .defaultDetails
        rootNav.pushViewController(vc, animated: true)

    case "sgpt-pricing":
        let vc: SgptPricingViewController = .instantiate(appStoryboard: .sgpt)
        rootNav.pushViewController(vc, animated: true)

    default:
        return
    }
}

private func resolveTopNavigationController(window: UIWindow?) -> UINavigationController? {
    let keyWindow = window ?? UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }

    var root = keyWindow?.rootViewController
    if let nav = root as? UINavigationController {
        if let tab = nav.viewControllers.first as? UITabBarController,
           let selectedNav = tab.selectedViewController as? UINavigationController {
            return selectedNav
        }
        return nav
    }
    if let tab = root as? UITabBarController {
        if let selectedNav = tab.selectedViewController as? UINavigationController {
            return selectedNav
        }
        root = tab.selectedViewController
    }
    
    var candidate = root
    while let current = candidate {
        if let nav = current as? UINavigationController {
            return nav
        }
        candidate = current.presentedViewController ?? current.children.first
    }
    return root as? UINavigationController
}
