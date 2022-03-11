//
//  ButtonExtension.swift
//  SEF
//
//  Created by Apple on 11/10/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

extension UIButton {

    func underLine(state: UIControl.State = .normal) {

        if let title = self.title(for: state) {

            let color = self.titleColor(for: state)

            let attrs = [
                NSAttributedString.Key.foregroundColor.rawValue: color ?? UIColor.blue,
                NSAttributedString.Key.underlineStyle: 1] as [AnyHashable: Any]

            let buttonTitleStr = NSMutableAttributedString(string: title, attributes: (attrs as! [NSAttributedString.Key: Any]))
            self.setAttributedTitle(buttonTitleStr, for: state)

        }
    }

    func normalLoad(_ string: String) {

//        if let url = URL(string: string) {
//            //self.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")!, options: .refreshCached)
//            self.sd_setImage(with: url, for: .normal, completed: nil)
//        } else {
//            self.setImage(UIImage(named: "placeholder")!, for: .normal)
//        }
    }
}
