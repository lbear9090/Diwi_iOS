//
//  UIImageViewExtension.swift
//  Diwi
//
//  Created by Dominique Miller on 11/13/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit

extension UIImageView {
    
    enum Direction {
        case down, right
    }
    
    func rotate(direction: Direction) {
        switch direction {
        case .down:
            UIView.animate(withDuration: 0.25) {
                self.transform = CGAffineTransform(rotationAngle: 0)
            }
        case .right:
            UIView.animate(withDuration: 0.25) {
                self.transform = CGAffineTransform(rotationAngle: (-90.0 * .pi) / 180.0)
            }
        }
    }

}
