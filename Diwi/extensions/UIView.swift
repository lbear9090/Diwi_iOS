//
//  UIView.swift
//  Diwi
//
//  Created by Jae Lee on 10/24/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func roundAllCorners(radius:CGFloat, borderColor: UIColor) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1
    }

    func roundAllCorners(radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    func dropShadow(color:UIColor, shadowRadius:CGFloat, shadowOffset:CGSize) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = shadowRadius
    }
    
    func gradientBackground(startColor: UIColor, endColor: UIColor) {
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.frame.size
        gradientLayer.colors = [startColor.cgColor, endColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        self.layer.addSublayer(gradientLayer)
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func hasNotch() -> Bool {
        return (UIDevice.deviceModel == "iPhone X") || (UIDevice.deviceModel == "iPhone XR")
    }
}
