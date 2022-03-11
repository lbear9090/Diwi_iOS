//
//  TwoButtonSwitch.swift
//  Diwi
//
//  Created by Dominique Miller on 4/7/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift

class TwoButtonSwitch: UIView {
    
    // view props
    let leftButton = UIButton()
    let rightButton = UIButton()
    let leftUnderline = UIView()
    let rightUnderline = UIView()
    
    // internal props
    private let leftText: String!
    private let rightText: String!
    var leftButtonPress: (() -> Void)?
    var rightButtonPress: (() -> Void)?
    let disposeBag = DisposeBag()
    var leftHeightAnchor: NSLayoutConstraint = NSLayoutConstraint()
    var rightHeightAnchor: NSLayoutConstraint = NSLayoutConstraint()
    
    
    init(leftText: String, rightText: String) {
        self.leftText = leftText
        self.rightText = rightText
        super.init(frame: CGRect.zero)
        setup()
        // set right button as default selected
        rightButtonSelected()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    private func setup() {
        backgroundColor = .clear
        setupLeftButton()
        setupLeftUnderline()
        setupRightButton()
        setupRightUnderline()
    }
    
    private func setupLeftButton() {
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.setTitle(leftText, for: .normal)
        leftButton.titleLabel?.font = UIFont.Diwi.floatingButton
        leftButton.contentVerticalAlignment = .bottom
        leftButton.rx.tap.bind { [unowned self] in
            self.leftButtonSelected()
            self.leftButtonPress?()
        }.disposed(by: disposeBag)
        
        addSubview(leftButton)
        
        NSLayoutConstraint.activate([
            leftButton.leftAnchor.constraint(equalTo: leftAnchor),
            leftButton.heightAnchor.constraint(equalToConstant: 46),
            leftButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            leftButton.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    private func setupLeftUnderline() {
        leftUnderline.translatesAutoresizingMaskIntoConstraints = false
        leftUnderline.backgroundColor = UIColor.Diwi.lightWhite
        
        addSubview(leftUnderline)
        leftHeightAnchor = leftUnderline.heightAnchor.constraint(equalToConstant: 1)
        NSLayoutConstraint.activate([
            leftHeightAnchor,
            leftUnderline.topAnchor.constraint(equalTo: leftButton.bottomAnchor),
            leftUnderline.widthAnchor.constraint(equalTo: leftButton.widthAnchor),
            leftUnderline.leftAnchor.constraint(equalTo: leftAnchor)
        ])
    }
    
    private func setupRightButton() {
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.setTitle(rightText, for: .normal)
        rightButton.titleLabel?.font = UIFont.Diwi.floatingButton
        rightButton.contentVerticalAlignment = .bottom
        rightButton.rx.tap.bind { [unowned self] in
            self.rightButtonSelected()
            self.rightButtonPress?()
        }.disposed(by: disposeBag)
        
        addSubview(rightButton)
        
        NSLayoutConstraint.activate([
            rightButton.rightAnchor.constraint(equalTo: rightAnchor),
            rightButton.heightAnchor.constraint(equalToConstant: 46),
            rightButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            rightButton.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    private func setupRightUnderline() {
        rightUnderline.translatesAutoresizingMaskIntoConstraints = false
        rightUnderline.backgroundColor = UIColor.Diwi.lightWhite
        
        addSubview(rightUnderline)
        rightHeightAnchor = rightUnderline.heightAnchor.constraint(equalToConstant: 1)
        NSLayoutConstraint.activate([
            rightHeightAnchor,
            rightUnderline.topAnchor.constraint(equalTo: rightButton.bottomAnchor),
            rightUnderline.widthAnchor.constraint(equalTo: rightButton.widthAnchor),
            rightUnderline.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    private func leftButtonSelected() {
        self.animateUnderline(underline: self.leftUnderline,
                              color: .white,
                              height: 2,
                              heightAnchor: self.leftHeightAnchor)
        self.animateUnderline(underline: self.rightUnderline,
                              color: UIColor.Diwi.lightWhite,
                              height: 1,
                              heightAnchor: self.rightHeightAnchor)
    }
    
    private func rightButtonSelected() {
        self.animateUnderline(underline: self.rightUnderline,
                              color: .white,
                              height: 2,
                              heightAnchor: self.rightHeightAnchor)
        self.animateUnderline(underline: self.leftUnderline,
                              color: UIColor.Diwi.lightWhite,
                              height: 1,
                              heightAnchor: self.leftHeightAnchor)
    }
    
    private func animateUnderline(underline: UIView,
                                  color: UIColor,
                                  height: CGFloat,
                                  heightAnchor: NSLayoutConstraint) {
        heightAnchor.constant = height
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            underline.backgroundColor = color
            self.layoutIfNeeded()
        })
    }
}
