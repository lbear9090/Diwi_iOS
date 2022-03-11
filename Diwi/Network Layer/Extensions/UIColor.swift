//
//  UIColorExtension.swift
//  SEF
//
//  Created by Apple on 26/10/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

extension UIColor {

    static let redTheme: UIColor = UIColor(named: "Red Button Color") ?? UIColor(r: 243, g: 40, b: 54)
    static let titleColor: UIColor = UIColor(named: "Title Color") ?? UIColor(r: 71, g: 71, b: 71)
    static let backgroundColor: UIColor = UIColor(named: "Background Color") ?? UIColor(r: 247, g: 247, b: 247)
    static let darkTextColor: UIColor = UIColor(named: "DarkTextColor") ?? UIColor(r: 62, g: 62, b: 67)
    static let disableRedButton: UIColor = UIColor(named: "DisableRedButton") ?? UIColor(r: 249, g: 132, b: 140)
    static let lightGrayBorder: UIColor = UIColor(named: "LightGrayBorder") ?? UIColor(r: 227, g: 227, b: 227)
    static let lightText: UIColor = UIColor(named: "LightText") ?? UIColor(r: 145, g: 145, b: 149)
    static let progressInnerCircle: UIColor = UIColor(named: "ProgressInnerCircle") ?? UIColor(r: 205, g: 215, b: 227)
    static let timerBackground: UIColor = UIColor(named: "TimerBackground") ?? UIColor(r: 86, g: 201, b: 242)
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: 1.0)
    }
}

extension UIColor {

    static func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    static func color(from hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

//        if ((cString.length) != 6) {
//            return UIColor.gray
//        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
