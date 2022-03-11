//
//  ProfileCollectionView.swift
//  Diwi
//
//  Created by Apple on 18/11/2021.
//  Copyright © 2021 Trim Agency. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import AVFoundation

class ProfileCollectionView: UICollectionViewCell{
    
    static var identifier: String = "Cell"
    
     var selectedItem = UIImageView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()

        }
    
    private func setupImageView(){
        selectedItem.translatesAutoresizingMaskIntoConstraints = false
        selectedItem.backgroundColor = UIColor.Diwi.gray
        selectedItem.layer.cornerRadius = 10
        selectedItem.contentMode = .scaleAspectFill
        selectedItem.clipsToBounds = true

        
        contentView.addSubview(selectedItem)
        
        NSLayoutConstraint.activate([
            selectedItem.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            selectedItem.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            selectedItem.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedItem.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//            selectedItem.heightAnchor.constraint(equalToConstant: 400),
//            selectedItem.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            ])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib(){
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
