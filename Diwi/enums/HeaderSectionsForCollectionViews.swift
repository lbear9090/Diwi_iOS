//
//  HeaderSectionsForCollectionViews.swift
//  Diwi
//
//  Created by Dominique Miller on 4/9/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

enum HeaderSectionsForCollectionViews {
    case closet(String),
         events(String),
         dates(String),
         contacts(String)
    
    private var appTextFieldView: AppTextFieldView {
        let view = AppTextFieldView()
        switch self {
        case .closet(let text):
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setImage(UIImage.Diwi.pinkHanger, height: 16, width: 22)
            view.setTitle(text)
            view.textField.isEnabled = false
            return view
        case .events(let text):
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setImage(UIImage.Diwi.pinkChampagne, height: 19, width: 22)
            view.setTitle(text)
            view.textField.isEnabled = false
            return view
        case .dates(let text):
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setImage(UIImage.Diwi.pinkIconEvent, height: 24, width: 24)
            view.setTitle(text)
            view.textField.isEnabled = false
            return view
        case .contacts(let text):
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setImage(UIImage.Diwi.pinkContacts, height: 24, width: 24)
            view.setTitle(text)
            view.textField.isEnabled = false
            return view
        }
    }
    
    func view() -> AppTextFieldView {
        return appTextFieldView
    }
}


