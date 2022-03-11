//
//  Debug.swift
//  Apple
//
//  Created by Apple on 13/10/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

// Logger for debug

final class Debug {

    static var isEnabled = false

    static func log(_ msg: @autoclosure () -> String = "", _ file: @autoclosure () -> String = #file, _ line: @autoclosure () -> Int = #line, _ function: @autoclosure () -> String = #function) {
        if isEnabled {
            let fileName = file().components(separatedBy: "/").last ?? ""
            print("[Debug] [\(fileName):\(line())]🍀🍀🍀: \(function()) \(msg())")
        }
    }
}
