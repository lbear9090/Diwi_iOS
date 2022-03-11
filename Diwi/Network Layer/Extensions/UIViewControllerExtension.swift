//
//  UIViewControllerExtension.swift
//  SEF
//
//  Created by Apple on 11/10/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }

    public func moveUIComponentWithValue(_ value: CGFloat, forLayoutConstraint: NSLayoutConstraint, forDuration: TimeInterval) {
        UIView.beginAnimations("MoveView", context: nil)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationDuration(forDuration)
        forLayoutConstraint.constant = value
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
    }

    public func animateUIComponentWithValue(_ value: CGFloat, forLayoutConstraint: NSLayoutConstraint, forDuration: TimeInterval) {

        forLayoutConstraint.constant = value

        UIView.animate(withDuration: forDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()

        }) { (_) -> Void in
            // do anything on completion
        }
    }

    func backViewController() -> UIViewController? {
        if let stack = self.navigationController?.viewControllers {
            for count in 0...stack.count - 1 {
                if(stack[count] == self) {
                    return stack[count-1]
                }
            }
        }
        return nil
    }

    func getToolBarWithDoneButton() -> UIToolbar {

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))

        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .redTheme
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(doneBarButtonAction(_:)))

        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        return toolBar

    }

    @objc private func doneBarButtonAction(_ button: UIButton) {
        view.endEditing(true)
    }

    /*func checkIfLocationServicesEnabled() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                
            case .denied:
                
                let _ = AlertViewController.alert("App Permission Denied", message: "To re-enable, please go to Settings and turn on Location Service for this app. We will be using the \"Financial District\" as your default location.", buttons: ["YES", "NO"], tapBlock: { (alertAction, index) in
                    if index == 0 {
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    }
                })
                
                break
            case .notDetermined, .restricted:
                logInfo("No access")
                let _ = AlertViewController.alert("", message: "Unable to update location, Please enable Location Services from your smartphone's settings menu. We will be using the \"Financial District\" as your default location.", buttons: ["YES", "NO"], tapBlock: { (alertAction, index) in
                    if index == 0 {
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    }
                })
                break
            case .authorizedAlways, .authorizedWhenInUse:
                logInfo("Access")
            }
        } else {
            
            let _ = AlertViewController.alert("", message: "Unable to update location, Please enable Location Services from your smartphone's settings menu. We will be using the \"Financial District\" as your default location.", buttons: ["YES", "NO"], tapBlock: { (alertAction, index) in
                if index == 0 {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            })
        }
    }
    
    func addressString(location: CLLocation, completionBlock: @escaping (String?) -> Void?) ->Void  {
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                logInfo("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                
                //address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                
                let addressString = placemark.name
                //logInfo("placemarks>>>>>>>>>>   \(placemarks)")
                // see more info via log for--- placemark, placemark.addressDictionary, placemark.region, placemark.country, placemark.locality (Extract the city name), placemark.name, placemark.ocean, placemark.postalCode, placemark.subLocality, placemark.location
                completionBlock(addressString)
            } else {
                logInfo("Problem with the data received from geocoder")
            }
        })

    }*/

    func configureNavigationBar(largeTitleColor: UIColor, backgoundColor: UIColor, tintColor: UIColor, title: String, preferredLargeTitle: Bool, searchController: UISearchController?) {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
            navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
            navBarAppearance.backgroundColor = backgoundColor

            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.compactAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

            navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = tintColor
            navigationItem.title = title
            navigationController?.navigationItem.searchController = searchController

        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.barTintColor = backgoundColor
            navigationController?.navigationBar.tintColor = tintColor
            navigationController?.navigationBar.isTranslucent = false
            navigationItem.title = title
            navigationController?.navigationItem.searchController = searchController
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Diwi.navigationButton]
    }
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
    func displaySpinner(onView: UIView, spinnerView: UIView) {
        spinnerView.backgroundColor = UIColor.Diwi.barneyFaded
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
    }
    
    func removeSpinner(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    func presentError(_ error: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: error,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    func presentMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    func hasNotch() -> Bool {
      return UIDevice.current.hasNotch
    }

}
