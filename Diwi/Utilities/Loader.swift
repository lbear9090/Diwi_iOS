//
//  Loader.swift
//  Diwi
//
//  Created by Apple on 2021-01-19.
//  Copyright © 2021 Trim Agency. All rights reserved.
//

import SVProgressHUD

class Loader {
    /// Show activity indicator
    class func show() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
            SVProgressHUD.setDefaultMaskType(.clear)
        }
    }
    
    /// Hide activity indicatore
    class func hide() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
}
