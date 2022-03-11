//
//  TabBarExtension.swift
//  Diwi
//
//  Created by Dominique Miller on 3/23/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

extension UITabBar {
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 70
        return sizeThatFits
   }
}
