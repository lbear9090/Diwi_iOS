//
//  TextFieldExtension.swift
//  SEF
//
//  Created by Apple on 11/10/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

extension UITextField {

   func setBottomBorder() {
            self.borderStyle = .none
            self.layer.backgroundColor = UIColor.white.cgColor

            self.layer.masksToBounds = false
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 0.0
    }

    func nameType(_ returnKeyType: UIReturnKeyType = .next) {
        self.autocapitalizationType = .words
        setupWith(.asciiCapable, returnKeyType: returnKeyType)
    }

    func emailType(_ returnKeyType: UIReturnKeyType = .next) {
        setupWith(.emailAddress, returnKeyType: returnKeyType)
    }

    func passwordType(_ returnKeyType: UIReturnKeyType = .next) {
        self.autocapitalizationType = .words
        self.isSecureTextEntry = true
        setupWith(.asciiCapable, returnKeyType: returnKeyType)
    }

    func mobileNumberType(_ returnKeyType: UIReturnKeyType = .next) {
        setupWith(.phonePad, returnKeyType: returnKeyType)
    }

    func numberType(_ returnKeyType: UIReturnKeyType = .next) {
        setupWith(.numberPad, returnKeyType: returnKeyType)
    }

    // MARK: - Private function >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    private func setupWith(_ keyBoardType: UIKeyboardType, returnKeyType: UIReturnKeyType) {

        self.returnKeyType = returnKeyType
        self.keyboardType = keyBoardType

        self.autocorrectionType = .no
        self.spellCheckingType = .no
    }

    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    //HideToolbar
    func hideToolBar() {
        self.autocorrectionType = .no
        let shortcut: UITextInputAssistantItem? = self.inputAssistantItem
        shortcut?.leadingBarButtonGroups = []
        shortcut?.trailingBarButtonGroups = []
    }
    
    func showRightBtn(image: UIImage,
                     target: Any?,
                     action: Selector) {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(30), height: CGFloat(25))
        button.addTarget(target, action: action, for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    func showRightBtn(text: String,
                      textColor: UIColor,
                     target: Any?,
                     action: Selector,
                     width: Int = 50) {
        let button = UIButton(type: .custom)
        button.setTitle(text, for:  .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(width), height: CGFloat(25))
        button.addTarget(target, action: action, for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
}
