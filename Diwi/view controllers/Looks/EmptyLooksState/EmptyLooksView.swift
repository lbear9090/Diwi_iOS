//
//  EmptyLooksView.swift
//  Diwi
//
//  Created by Shane Work on 10/30/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

protocol EmptyLooksViewDelegate {
    func createNewLook() 
}

class EmptyLooksView: UIView {
    
    let headerImageView = UIImageView()
    let headerLabel = UILabel()
    let subHeaderLabel = UILabel()
    let createLookButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        setupView()
    }
    
    func setupView() {
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        subHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        createLookButton.translatesAutoresizingMaskIntoConstraints = false
        
        headerImageView.image = UIImage(named: TextContent.Images.cameraIcon)
        
        self.addSubview(headerImageView)
        self.addSubview(headerLabel)
        self.addSubview(subHeaderLabel)
        self.addSubview(createLookButton)
        
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 100)
        ])
    }

}
