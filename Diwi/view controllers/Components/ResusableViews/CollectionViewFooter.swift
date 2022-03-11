//
//  CollectionViewFooter.swift
//  Diwi
//
//  Created by Dominique Miller on 1/9/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

enum FooterType {
    case normal, largeButton
}

class CollectionViewFooter: UICollectionReusableView {
    let textLabel   = UILabel()
    let dash        = UIView()
    let button      = UIButton()
    let largeButton = AppButton()
    var buttonPressed: (() -> Void)?
    
    static var reuseIdentifier: String {
        get { return "CollectionViewFooter"}
    }

    
    func setup(text: String, style: FooterType) {
        switch style {
        case .normal: normalSetup(text: text)
        case .largeButton: largeButtonSetup(text: text)
        }
    }
        
    @objc func handleButtonPressed() {
        buttonPressed?()
    }
    
    private func largeButtonSetup(text: String) {
        largeButton.translatesAutoresizingMaskIntoConstraints = false
        largeButton.setTitle(text, for: .normal)
        largeButton.enableButton()
        largeButton.addTarget(self, action: #selector(handleButtonPressed), for: .touchUpInside)
        
        addSubview(largeButton)
        
        NSLayoutConstraint.activate([
            largeButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 37),
            largeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -37),
            largeButton.topAnchor.constraint(equalTo: topAnchor),
            largeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)
        ])
        
    }
    
    private func normalSetup(text: String) {
        dash.translatesAutoresizingMaskIntoConstraints = false
               dash.backgroundColor = UIColor.Diwi.barney
               dash.layer.cornerRadius = 4
               
               addSubview(dash)
               
               NSLayoutConstraint.activate([
                   dash.heightAnchor.constraint(equalToConstant: 2),
                   dash.widthAnchor.constraint(equalToConstant: 14),
                   dash.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
                   dash.topAnchor.constraint(equalTo: topAnchor)
               ])
               
               textLabel.text = text
               textLabel.textColor = UIColor.Diwi.azure
               textLabel.font = UIFont.Diwi.button
               
               textLabel.translatesAutoresizingMaskIntoConstraints = false
               
               addSubview(textLabel)
               
               NSLayoutConstraint.activate([
                   textLabel.leftAnchor.constraint(equalTo: dash.rightAnchor, constant: 15),
                   textLabel.centerYAnchor.constraint(equalTo: dash.centerYAnchor)
               ])
               
               button.translatesAutoresizingMaskIntoConstraints = false
               button.backgroundColor = .clear
               button.addTarget(self, action: #selector(handleButtonPressed), for: .touchUpInside)
               
               addSubview(button)
               
               NSLayoutConstraint.activate([
                   button.leftAnchor.constraint(equalTo: leftAnchor),
                   button.rightAnchor.constraint(equalTo: rightAnchor),
                   button.topAnchor.constraint(equalTo: topAnchor),
                   button.bottomAnchor.constraint(equalTo: bottomAnchor)
               ])
    }
    
    
}
