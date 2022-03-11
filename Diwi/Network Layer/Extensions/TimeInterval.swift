//
//  TimeInterval.swift
//  SEF
//
//  Created by Apple on 06/02/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation


extension TimeInterval {
    func formattedString() -> String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours < 1 {
            return String(format: "%02d:%02d", minutes, seconds)
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
