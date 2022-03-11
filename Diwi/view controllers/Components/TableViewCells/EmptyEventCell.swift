//
//  EmptyEventCell.swift
//  Diwi
//
//  Created by Jae Lee on 10/25/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit

class EmptyEventCell: UITableViewCell {
    static var identifier: String = "EmptyEventCell"
    let placeHolderTitle = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.Diwi.azure
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        placeHolderTitle.translatesAutoresizingMaskIntoConstraints = false
        placeHolderTitle.font = UIFont.Diwi.floatingButton
        placeHolderTitle.textColor = .white
        placeHolderTitle.textAlignment = .center
        placeHolderTitle.numberOfLines = 3
        placeHolderTitle.text = TextContent.Labels.noEvents
        contentView.addSubview(placeHolderTitle)
        NSLayoutConstraint.activate([
            placeHolderTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            placeHolderTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeHolderTitle.widthAnchor.constraint(equalToConstant: 250),
            placeHolderTitle.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

}
