//
//  NewClothingItemViewController.swift
//  Diwi
//
//  Created by Jae Lee on 11/18/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class NewClothingItemViewController: UIViewController, UITextFieldDelegate {
    let scrollView              = UIScrollView()
    let contentView             = UIView()
    let header                  = UIView()
    let subHeader               = UIView()
    let navTitle                = UILabel()
    let backIcon                = UIButton()
    let imageView:UIImageView   = UIImageView()
    let itemTitle               = MDCTextField()
    var itemTitleController     = MDCTextInputControllerUnderline()
    var itemType                = AppTextFieldView()
    let saveButton              = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
}


extension NewClothingItemViewController {
    private func setupView() {
        view.backgroundColor = UIColor.white
        setupHeader()
        setupNav()
        setupScrollView()
        setupContentView()
        setupItemTitle()
        setupSaveItemButton()
    }
    
    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = UIColor.Diwi.yellow
        view.addSubview(header)
        
        var height: NSLayoutConstraint
        if hasNotch() {
            height = header.heightAnchor.constraint(equalToConstant: 90)
        }
        else {
            height = header.heightAnchor.constraint(equalToConstant: 60)
        }
        
        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.rightAnchor.constraint(equalTo: view.rightAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor),
            height
            ])
    }
    private func setupNav() {
        backIcon.translatesAutoresizingMaskIntoConstraints = false
        backIcon.setImage(UIImage.Diwi.backIconWhite, for: .normal)
        header.addSubview(backIcon)
        
        var paddingTop = CGFloat(25)
        if hasNotch() {
            paddingTop += 30
        }
        
        NSLayoutConstraint.activate([
            backIcon.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            backIcon.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10),
            backIcon.widthAnchor.constraint(equalToConstant: 25),
            backIcon.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.text = TextContent.Labels.addEvent
        navTitle.font = UIFont.Diwi.titleBold
        header.addSubview(navTitle)
        
        NSLayoutConstraint.activate([
            navTitle.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            navTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor),
        ])
    }
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.Diwi.yellow
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        heightConstraint.priority = UILayoutPriority(250) //very important
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            heightConstraint,
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.height)
        ])
        
    }
   
    private func setupItemTitle() {
        itemTitle.translatesAutoresizingMaskIntoConstraints = false
        itemTitle.font? = UIFont.Diwi.textField
        itemTitle.tag = 0
        itemTitle.textColor = UIColor.Diwi.darkGray
        itemTitle.autocapitalizationType = .none
        itemTitle.autocorrectionType = .no
        itemTitle.delegate = self
        itemTitleController = MDCTextInputControllerUnderline(textInput: itemTitle)
        itemTitle.placeholder = TextContent.Placeholders.itemTitle
        itemTitleController.inlinePlaceholderColor = UIColor.Diwi.darkGray
        itemTitleController.floatingPlaceholderNormalColor = UIColor.Diwi.darkGray
        itemTitleController.floatingPlaceholderActiveColor = UIColor.Diwi.darkGray
        itemTitleController.activeColor = UIColor.Diwi.azure
        itemTitleController.normalColor = UIColor.Diwi.azure
        contentView.addSubview(itemTitle)
        NSLayoutConstraint.activate([
            itemTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            itemTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            itemTitle.heightAnchor.constraint(equalToConstant: 30),
            itemTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 31.5)
            ])
    }

    private func setupSaveItemButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.titleLabel?.font = UIFont.Diwi.floatingButton
        saveButton.setTitle(TextContent.Buttons.saveEvent, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor.Diwi.barney
        saveButton.roundAllCorners(radius: 25)
        contentView.addSubview(saveButton)

        let bottomConstraint = saveButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -75)
        bottomConstraint.priority = UILayoutPriority(500)
        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.widthAnchor.constraint(equalToConstant: 315),
            saveButton.topAnchor.constraint(equalTo: itemTitle.bottomAnchor, constant: -300),
            bottomConstraint
        ])
    }
    
    
    
}


