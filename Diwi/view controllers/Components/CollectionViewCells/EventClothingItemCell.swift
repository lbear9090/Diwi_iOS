//
//  EventClothingItemCell.swift
//  Diwi
//
//  Created by Dominique Miller on 12/6/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import Kingfisher

class EventClothingItemCell: UICollectionViewCell {
    
    static var identifier: String = "Cell"
    // view props
    weak var textLabel: UILabel!
    let box = UIImageView()
    
    // internal props
    var item = EventClothingItem()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = UIColor.Diwi.gray
        box.layer.cornerRadius = 19
        box.contentMode = .scaleAspectFill
        box.clipsToBounds = true
        
        contentView.addSubview(box)
        
        NSLayoutConstraint.activate([
            box.widthAnchor.constraint(equalToConstant: 98),
            box.heightAnchor.constraint(equalToConstant: 110),
            box.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            box.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImage() {
        if let thumb = item.thumbnail {
            box.kf.setImage(with: URL(string: thumb), options: [])
        } else if let img = item.image {
            box.kf.setImage(with: URL(string: img), options: [])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}

