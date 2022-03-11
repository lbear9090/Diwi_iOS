//
//  GeneralExtension.swift
//  SEF
//
//  Created by Apple on 11/10/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

// MARK: - Array Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Array {
    func contains<T>(_ obj: T) -> Bool where T: Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

// MARK: - NSURL Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension URL {

    var isValid: Bool {
        return UIApplication.shared.canOpenURL(self)
    }
}

// MARK: - Int/Float/Double Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Int {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)d" as NSString, self) as String
    }
}

extension Double {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
}

extension Float {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
}

extension CGFloat {
    init?(_ str: String) {
        guard let float = Float(str) else { return nil }
        self = CGFloat(float)
    }
}
// MARK: - Dictionary Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Dictionary {
    mutating func unionInPlace(
        _ dictionary: Dictionary<Key, Value>) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }

    mutating func unionInPlace<S: Sequence>(_ sequence: S) where S.Iterator.Element == (Key, Value) {
        for (key, value) in sequence {
            self[key] = value
        }
    }

    func validatedValue(_ key: Key, expected: AnyObject) -> AnyObject {

        // checking if in case object is nil

        if let object = self[key] {

            // added helper to check if in case we are getting number from server but we want a string from it
            if object is NSNumber && expected is String {

                //logInfo("case we are getting number from server but we want a string from it")

                return "\(object)" as AnyObject
            }

                // checking if object is of desired class
            else if ((object as AnyObject).isKind(of: expected.classForCoder) == false) {
                //logInfo("case // checking if object is of desired class....not")

                return expected
            }

                // checking if in case object if of string type and we are getting nil inside quotes
            else if object is String {
                if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                    //logInfo("null string")
                    return "" as AnyObject
                }
            } else if object is Int {
                if ((object as! Int).description == "null" || (object as! Int).description == "<null>" || (object as! Int).description == "(null)") {
                    //logInfo("null string")
                    return 0 as AnyObject
                }
            } else if object is Float {
                if ((object as! Float).description == "null" || (object as! Float).description == "<null>" || (object as! Float).description == "(null)") {
                    //logInfo("null string")
                    return 0 as AnyObject
                }
            } else if object is Dictionary {
                if ((object as! Dictionary).description == "null" || (object as! Dictionary).description == "<null>" || (object as! Dictionary).description == "(null)") {
                    return [:] as AnyObject
                }
            } else if object is Array<Any> {
                if ((object as! Array<Any>).description == "null" || (object as! Array<Any>).description == "<null>" || (object as! Array<Any>).description == "(null)") {
                    return [] as AnyObject
                }
            } else if object is NSNumber {
                if ((object as! NSNumber).description == "null" || (object as! NSNumber).description == "<null>" || (object as! NSNumber).description == "(null)") {
                    return 0 as AnyObject
                }
            }
            return object as AnyObject
        } else {

            if expected is String {
                return "" as AnyObject
            } else if expected is Int || expected is Float {
                return 0 as AnyObject
            } else if expected is Dictionary {
                return [:] as AnyObject
            } else if expected is Array<Any> {
                return [] as AnyObject
            }

//            if expected is String || expected as! String == "" {
//                return "" as AnyObject
//            } else if expected is Int || expected as! Int == 0 || expected is Float {
//                return 0 as AnyObject
//            } else if expected is Dictionary {
//                return [:] as AnyObject
//            }

            return expected
        }
    }

}

// MARK: - UISlider Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UISlider {
    @IBInspectable var thumbImage: UIImage {
        get {
            return self.thumbImage(for: UIControl.State())!
        }
        set {
            self.setThumbImage(thumbImage, for: UIControl.State())
        }
    }
}

extension UIColor {

    class func  RGB(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) -> UIColor {

        return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }
}

extension UITextView {

    func numberOfLines() -> Int {
        if let fontUnwrapped = self.font {
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
    }
}
