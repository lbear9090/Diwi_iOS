//
//  ReusableView.swift
//  Diwi
//
//  Created by Dominique Miller on 4/2/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
