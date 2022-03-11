//
//  LooksCollectionViewCell.swift
//  Diwi
//
//  Created by Shane Work on 11/11/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

class LooksCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        
    }
}
