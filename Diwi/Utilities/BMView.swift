//
//  ViewSubclass.swift
//  Blyott Mobile App
//
//  Created by Nitin Agnihotri on 14/05/20.
//  Copyright © 2020 ChicMic. All rights reserved.
//

import UIKit

class BMView: UIView {
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    func setup () {
        backgroundColor = AppColor.hexToUIColor(hex: Colors.appThemeColor)
    }
}
