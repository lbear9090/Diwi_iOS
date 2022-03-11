//
//  UIStoryboard+Loader.swift
//  SEF
//
//  Created by Apple on 04/05/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

private enum StoryboardEnum: String {

    case progressPhoto = "ProgressPhoto"
}

fileprivate extension UIStoryboard {

    // instantiating view controller from a specific storyboard
    static func load(from storyboard: StoryboardEnum, identifier: String) -> UIViewController {
        let uiStoryboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        return uiStoryboard.instantiateViewController(withIdentifier: identifier)
    }
}

// MARK: - App View Controllers

extension UIStoryboard {

    // MARK: - Progress photo Flow

//    class func loadProgressPhotoVC() -> ProgressPhotoVC? {
//        return load(from: .progressPhoto, identifier: ProgressPhotoVC.identifier) as? ProgressPhotoVC
//    }

    
}
