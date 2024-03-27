//
//  Utilities.swift
//  TailTrail
//
//  Created by Antony Bluemel on 2/7/24.
//

import UIKit

final class Utilities {
    static let shared = Utilities()
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        // Start with the provided controller or find the root UIViewController
        let rootController: UIViewController? = controller ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .compactMap { $0.keyWindow?.rootViewController }
            .last
        
        // Recursively find the top UIViewController
        if let navigationController = rootController as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = rootController as? UITabBarController, let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }
        if let presented = rootController?.presentedViewController {
            return topViewController(controller: presented)
        }
        return rootController
    }
}
