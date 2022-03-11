//
//  AppColor.swift
//  Blyott Mobile App
//
//  Created by Nitin Agnihotri on 14/05/20.
//  Copyright © 2020 ChicMic. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    static let appThemeColor = "#18182C"
    static let textFieldBorderColor = "C6C6C6"
    static let pinkColor = "C627B1"
    
}

class AppColor {
    
    static func hexToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

class UtilityClass {
    
    static func getStoryboard(_ storyboardId:String) -> UIStoryboard {
        return UIStoryboard(name: storyboardId, bundle: nil)
    }
}
