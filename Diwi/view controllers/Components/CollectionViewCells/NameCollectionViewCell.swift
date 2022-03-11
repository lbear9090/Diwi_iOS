//
//  NameCollectionViewCell.swift
//  Diwi
//
//  Created by Jae Lee on 10/31/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit

class NameCollectionViewCell: UICollectionViewCell {
    var name = UILabel()
    var button = UIButton()
    var tagId:Int?
    
    var removeTag: ((String) -> Void)?
    
    override init(frame: CGRect) {
      super.init(frame: frame)
        contentView.roundAllCorners(radius: 32/2)
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 0.3
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        setupName()
        setupButton()
    }
    
    fileprivate func setupName() {
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = UIFont.Diwi.floatingButton
        name.textColor = UIColor.Diwi.azure
        contentView.addSubview(name)
        NSLayoutConstraint.activate([
            name.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant:13),
            name.topAnchor.constraint(equalTo: contentView.topAnchor),
            name.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            name.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    fileprivate func setupButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.Diwi.removePinkIcon, for: .normal)
        button.addTarget(self, action: #selector(self.remove), for: .touchUpInside)
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: name.rightAnchor),
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:0),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    @objc func remove() {
        guard let name = self.name.text else {return}
        removeTag?(name)
    }
    
    
    func configure(_ tag:Tag) {
        self.tagId = tag.id
        name.text = tag.title
    }
}
