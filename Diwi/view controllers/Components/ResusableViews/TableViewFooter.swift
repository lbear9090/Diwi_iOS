//
//  TableViewFooter.swift
//  Diwi
//
//  Created by Dominique Miller on 1/10/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

class TableViewFooter: UITableViewHeaderFooterView {
    let titleLabel           = UILabel()
    let dash                 = UIView()
    let button               = UIButton()
    let largeButton          = AppButton()
    let customBackgroundView = UIView()
    var buttonPressed: (() -> Void)?
    
    static let reuseIdentifier: String = String(describing: self)

    func setup(text: String, style: FooterType, textColor: UIColor = UIColor.Diwi.azure) {
        customBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        customBackgroundView.backgroundColor = textColor == UIColor.Diwi.azure ? .white : UIColor.Diwi.azure
        contentView.addSubview(customBackgroundView)
        
        NSLayoutConstraint.activate([
            customBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            customBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        switch style {
        case .normal: normalSetup(text: text, textColor: textColor)
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
        
        customBackgroundView.addSubview(largeButton)
        
        NSLayoutConstraint.activate([
            largeButton.leftAnchor.constraint(equalTo: customBackgroundView.leftAnchor, constant: 37),
            largeButton.rightAnchor.constraint(equalTo: customBackgroundView.rightAnchor, constant: -37),
            largeButton.topAnchor.constraint(equalTo: customBackgroundView.topAnchor),
            largeButton.bottomAnchor.constraint(equalTo: customBackgroundView.bottomAnchor, constant: -25)
        ])
        
    }
    
    private func normalSetup(text: String, textColor: UIColor) {
        dash.translatesAutoresizingMaskIntoConstraints = false
        dash.backgroundColor = textColor == UIColor.Diwi.azure ? UIColor.Diwi.barney : textColor
        dash.layer.cornerRadius = 4
               
        customBackgroundView.addSubview(dash)
               
        NSLayoutConstraint.activate([
            dash.heightAnchor.constraint(equalToConstant: 2),
            dash.widthAnchor.constraint(equalToConstant: 14),
            dash.leftAnchor.constraint(equalTo: customBackgroundView.leftAnchor, constant: 0),
            dash.topAnchor.constraint(equalTo: customBackgroundView.topAnchor, constant: 25)
        ])
               
        titleLabel.text = text
        titleLabel.textColor = textColor
        titleLabel.font = UIFont.Diwi.button
            
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
               
        customBackgroundView.addSubview(titleLabel)
               
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: dash.rightAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: dash.centerYAnchor)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(handleButtonPressed), for: .touchUpInside)
               
        customBackgroundView.addSubview(button)
               
            NSLayoutConstraint.activate([
                button.leftAnchor.constraint(equalTo: customBackgroundView.leftAnchor),
                button.rightAnchor.constraint(equalTo: customBackgroundView.rightAnchor),
                button.topAnchor.constraint(equalTo: customBackgroundView.topAnchor),
                button.bottomAnchor.constraint(equalTo: customBackgroundView.bottomAnchor)
            ])
    }
    
    
}
