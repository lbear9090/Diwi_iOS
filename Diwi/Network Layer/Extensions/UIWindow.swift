//
//  UIWindowExtensions.swift
//  SEF
//
//  Created by Apple on 11/10/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

extension UIWindow {

//    static var currentController: UIViewController? {
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        return appDelegate?.window.currentController
//    }

    var currentController: UIViewController? {
        if let vc = self.rootViewController {
            return getCurrentController(vc: vc)
        }
        return nil
    }

    func getCurrentController(vc: UIViewController) -> UIViewController {

        if let pc = vc.presentedViewController {
            return getCurrentController(vc: pc)
        }/* else if let slidePanel = vc as? MASliderViewController {
            
            return getCurrentController(vc: slidePanel.centerViewController!)
            
        }*/ else if let nc = vc as? UINavigationController {
            if nc.viewControllers.count > 0 {
                return getCurrentController(vc: nc.viewControllers.last!)
            } else {
                return nc
            }
        } else {
            return vc
        }
    }
    
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
