//
//  NavHeader.swift
//  Diwi
//
//  Created by Dominique Miller on 3/31/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NavHeader: UIView {
    enum Style {
        case normal, tabBar, backButtonOnly
    }
    
    // View props
    let leftButton  = UIButton()
    let rightButton = UIButton()
    let navTitle    = UILabel()
    
    // internal props
    let backButtonIcon   = UIImage.Diwi.backIconWhite
    let diwiHomeIcon     = UIImage.Diwi.homePageIcon
    let globalSearchIcon = UIImage.Diwi.searchIcon
    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(backgroundColor: UIColor, style: Style, navTitle: String) {
        self.backgroundColor = backgroundColor
        setupSearchIcon()
        setupNavTitle(with: navTitle)
        
        switch style {
        case .normal:
            setupLeftButton(image: backButtonIcon)
        case .tabBar:
            setupLeftButton(image: diwiHomeIcon)
        case .backButtonOnly:
            rightButton.isHidden = true
            setupLeftButton(image: backButtonIcon)
        }
    }
    
    private func setupSearchIcon() {
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setImage(globalSearchIcon, for: .normal)
        
        rightButton.rx.tap.bind { [unowned self] in
             self.rightButtonAction?()
        }.disposed(by: disposeBag)
        
        addSubview(rightButton)
        
        var paddingTop = CGFloat(25)
        
        if (hasNotch()) {
            paddingTop += 30
        }
        
        NSLayoutConstraint.activate([
            rightButton.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            rightButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            rightButton.widthAnchor.constraint(equalToConstant: 28),
            rightButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func setupNavTitle(with title: String) {
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.text = title
        navTitle.font = UIFont.Diwi.titleBold
        
        addSubview(navTitle)
               
        NSLayoutConstraint.activate([
            navTitle.centerYAnchor.constraint(equalTo: rightButton.centerYAnchor),
            navTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    private func setupLeftButton(image: UIImage) {
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.setImage(image, for: .normal)
        
        leftButton.rx.tap.bind { [unowned self] in
             self.leftButtonAction?()
        }.disposed(by: disposeBag)
        
        addSubview(leftButton)
        
        var paddingTop = CGFloat(25)
        
        if (hasNotch()) {
            paddingTop += 30
        }
        
        NSLayoutConstraint.activate([
            leftButton.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            leftButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            leftButton.widthAnchor.constraint(equalToConstant: 28),
            leftButton.heightAnchor.constraint(equalToConstant: 28)
            ])
    }
}
