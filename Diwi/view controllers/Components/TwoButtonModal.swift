//
//  TwoButtonModal.swift
//  Diwi
//
//  Created by Dominique Miller on 3/19/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TwoButtonModal: UIView {
    
    // view props
    let closeBtn        = UIButton()
    let buttonContainer = UIStackView()
    let topBtn          = AppButton()
    let bottomBtn       = AppButton()
    
    // internal props
    var finished: (() -> Void)?
    var topBtnPressed: (() -> Void)?
    var bottomBtnPressed: (() -> Void)?
    var topBtnText: String?
    var bottomBtnText: String?
    let disposeBag = DisposeBag()
    
    init(topBtnText: String, bottomBtnText: String) {
        self.topBtnText = topBtnText
        self.bottomBtnText = bottomBtnText
        // setting default size to size of screen
        super.init(frame: UIScreen.main.bounds);
        self.setupView()
        self.setupBindings()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Setup bindings
extension TwoButtonModal {
    private func setupBindings() {
        closeBtn.rx.tap.bind { [unowned self] in
            self.finished?()
        }.disposed(by: disposeBag)
        
        topBtn.rx.tap.bind { [unowned self] in
            self.topBtnPressed?()
        }.disposed(by: disposeBag)
        
        bottomBtn.rx.tap.bind { [unowned self] in
            self.bottomBtnPressed?()
        }.disposed(by: disposeBag)
    }
}

// MARK: - View setup
extension TwoButtonModal {
    private func setupView() {
        backgroundColor = .black
        self.gradientBackground(startColor: UIColor.gray, endColor: UIColor.Diwi.fadedGray)
        setupCloseBtn()
        setupButtonContainer()
        setupTopBtn()
        setupBottomBtn()
    }
    
    private func setupCloseBtn() {
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.setImage(UIImage.Diwi.closeBtn, for: .normal)
        
        self.addSubview(closeBtn)
        
        NSLayoutConstraint.activate([
            closeBtn.heightAnchor.constraint(equalToConstant: 28),
            closeBtn.widthAnchor.constraint(equalToConstant: 28),
            closeBtn.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
        ])
    }
    
    private func setupButtonContainer() {
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.axis = .vertical
        buttonContainer.alignment = .center
        buttonContainer.spacing = 10
        
        self.addSubview(buttonContainer)
        
        NSLayoutConstraint.activate([
            buttonContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30),
            buttonContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30),
            buttonContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func setupTopBtn() {
        topBtn.translatesAutoresizingMaskIntoConstraints = false
        topBtn.setTitle(topBtnText, for: .normal)
        
        buttonContainer.addArrangedSubview(topBtn)
        
        NSLayoutConstraint.activate([
            topBtn.heightAnchor.constraint(equalToConstant: 50),
            topBtn.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30),
            topBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30)
        ])
        
    }
    
    private func setupBottomBtn() {
        bottomBtn.translatesAutoresizingMaskIntoConstraints = false
        bottomBtn.setTitle(bottomBtnText, for: .normal)
        
        buttonContainer.addArrangedSubview(bottomBtn)
        
        NSLayoutConstraint.activate([
            bottomBtn.heightAnchor.constraint(equalToConstant: 50),
            bottomBtn.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 30),
            bottomBtn.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -30)
        ])
    }
}
