//
//  LooksDummyData.swift
//  Diwi
//
//  Created by Shane Work on 11/11/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit


class DummyLooks {
    
    static let shared = DummyLooks()
    
    func getLooks() -> [Look] {
        var looks = [Look]()
        for _ in 0 ... 10 {
            let look = Look()
            look.createdAt = Date()
            looks.append(look)
        }
        return looks
    }
}
