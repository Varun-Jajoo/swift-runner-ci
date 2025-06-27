//
//  SocialShareOpen.swift
//  MyPT
//
//  Created by techsaga corp on 21/06/25.
//

import UIKit

func navigateUniversalLink(_ url: URL, window: UIWindow?) {
    // Navigate to screen
        guard let rootNav = window?.rootViewController as? UINavigationController else {
            return
        }
    let pathComponents = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        let queryDict = queryItems?.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
    if pathComponents.count >= 3 {
        let type = pathComponents[0]
        let id = pathComponents[1]
        let action = pathComponents[2]
        // Route user accordingly
        if action.lowercased() == "class" {
            let vc: ClassDetailsViewController = ClassDetailsViewController.instantiate(appStoryboard: .dashboard)
            vc.scheludeIdStr = id
            rootNav.pushViewController(vc, animated: true)
        }else{
            let vc:GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
            vc.inputStudioId = id
            vc.inputType = type
            vc.gymDetailsFlow = calendarFlow.from(string: action)
            rootNav.pushViewController(vc, animated: true)
        }
        
        //        let vc:GymDetailsViewController = GymDetailsViewController.instantiate(appStoryboard: .booking)
        //        vc.inputStudioId = id
        //        vc.inputType = type
        //        vc.gymDetailsFlow = calendarFlow.from(string: action)
        //        rootNav.pushViewController(vc, animated: true)
        
        return
    }
}
