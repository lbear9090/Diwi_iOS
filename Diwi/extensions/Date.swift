//
//  Date.swift
//  Diwi
//
//  Created by Jae Lee on 11/5/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation

extension Date {
    func toString(_ format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter.string(from: self)
        
    }
}
