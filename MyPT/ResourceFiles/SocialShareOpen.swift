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
    guard let rootNav = window?.rootViewController as? UINavigationController else {
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
        let vc: ClassDetailsViewController = ClassDetailsViewController.instantiate(appStoryboard: .dashboard)
        vc.scheludeIdStr = id
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
