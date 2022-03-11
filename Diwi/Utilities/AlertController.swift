//
//  AlertController.swift
//  SEF
//
//  Created by Apple on 11/10/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

open class AlertController {

    // MARK: - Singleton

    static let instance = AlertController()

    // MARK: - Private Functions

    fileprivate func topMostController() -> UIViewController? {

        var presentedVC = UIApplication.shared.keyWindow?.rootViewController
        while let pVC = presentedVC?.presentedViewController {
            presentedVC = pVC
        }

        if presentedVC == nil {
            //print("AlertController Error: You don't have any views set. You may be calling in viewdidload. Try viewdidappear.")
        }
        return presentedVC
    }

    // MARK: - Class Functions

    open class func alert(title: String) {
        return alert(title: title, message: "")
    }

    open class func alert(message: String) {
        return alert(title: "", message: message)
    }

    open class func alert(title: String, message: String) {

        return alert(title: title, message: message, acceptMessage: "OK") { () -> Void in
            // Do nothing
        }
    }

    open class func alert(title: String, message: String, acceptMessage: String, acceptBlock: @escaping () -> Void) {

        DispatchQueue.main.async(execute: {

            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let acceptButton = UIAlertAction(title: acceptMessage, style: .default, handler: { (_: UIAlertAction) in
                acceptBlock()
            })
            alert.addAction(acceptButton)

            instance.topMostController()?.present(alert, animated: true, completion: nil)
            //return alert
        })
    }

    open class func alert(title: String, message: String, buttons: [String], tapBlock: ((UIAlertAction, Int) -> Void)?) {

        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert, buttons: buttons, tapBlock: tapBlock)

            instance.topMostController()?.present(alert, animated: true, completion: nil)
            //return alert
        })

    }

    open class func actionSheet(title: String, message: String, sourceView: UIView, actions: [UIAlertAction]) {

        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
            for action in actions {
                alert.addAction(action)
            }

            alert.popoverPresentationController?.sourceView = sourceView
            alert.popoverPresentationController?.sourceRect = sourceView.bounds
            instance.topMostController()?.present(alert, animated: true, completion: nil)
            //return alert
        })
    }

    open class func actionSheet(title: String, message: String, sourceView: UIView, buttons: [String], tapBlock: ((UIAlertAction, Int) -> Void)?) {

        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .actionSheet,
                                          buttons: buttons,
                                          tapBlock: tapBlock)
            alert.popoverPresentationController?.sourceView = sourceView
            alert.popoverPresentationController?.sourceRect = sourceView.bounds
            instance.topMostController()?.present(alert, animated: true, completion: nil)
            //return alert
        })
    }
    
    open class func actionSheetWithDestructive(title: String, message: String, sourceView: UIView, buttons: [String],destructiveButtonTitle:String?,cancelButtonTitle:String?, tapBlock: ((UIAlertAction, Int) -> Void)?) {

        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .actionSheet,
                                          buttons: buttons,
                                          tapBlock: tapBlock)
            if let destBtn = destructiveButtonTitle {
                alert.addAction(UIAlertAction(title: destBtn, style: .destructive, handler: { (alertAction) in
                    tapBlock!(alertAction, 1)
                }))
            }
            
            if let canBtn = cancelButtonTitle {
                alert.addAction(UIAlertAction(title: canBtn, style: .cancel, handler: { (alertAction) in
                    tapBlock!(alertAction, 2)
                }))
            }
            alert.popoverPresentationController?.sourceView = sourceView
            alert.popoverPresentationController?.sourceRect = sourceView.bounds
            instance.topMostController()?.present(alert, animated: true, completion: nil)
            //return alert
        })
    }

    open class func showAlert(title:String,
                              message: String,
                              buttons:[String],
                              tapBlock: ((Int) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: buttons[0], style: .default , handler:{ (UIAlertAction)in
            if let block = tapBlock {
                block(0)
            }
        }))
        
        alert.addAction(UIAlertAction(title: buttons[1], style: .destructive , handler:{ (UIAlertAction)in
            if let block = tapBlock {
                block(1)
            }
        }))
        
        instance.topMostController()?.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
}

private extension UIAlertController {
    convenience init(title: String?, message: String?, preferredStyle: UIAlertController.Style, buttons: [String], tapBlock: ((UIAlertAction, Int) -> Void)?) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        var buttonIndex = 0
        for buttonTitle in buttons {
            let action = UIAlertAction(title: buttonTitle, preferredStyle: .default, buttonIndex: buttonIndex, tapBlock: tapBlock)
            buttonIndex += 1
            self.addAction(action)
        }
    }
}

private extension UIAlertAction {
    convenience init(title: String?, preferredStyle: UIAlertAction.Style, buttonIndex: Int, tapBlock: ((UIAlertAction, Int) -> Void)?) {
        self.init(title: title, style: preferredStyle) {
            (action: UIAlertAction) in
            if let block = tapBlock {
                block(action, buttonIndex)
            }
        }
    }
}
