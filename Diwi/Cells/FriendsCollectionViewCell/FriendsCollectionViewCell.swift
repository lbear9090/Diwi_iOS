//
//  FriendsCollectionViewCell.swift
//  Diwi
//
//  Created by Shane Work on 12/17/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

protocol FriendsCollectionViewDelegate {
    func didTapDelete()
}

class FriendsCollectionViewCell: UICollectionViewCell {
    
    var delegate: FriendsCollectionViewDelegate?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction func removeButtonTap(_ sender: Any) {
        self.delegate?.didTapDelete()
    }
    
    func setupUI() {
        removeButton.isUserInteractionEnabled = false
        containerView.backgroundColor = UIColor.Diwi.azure
        containerView.layer.cornerRadius = 12
        
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .center
        nameLabel.sizeToFit()
        
        let image = #imageLiteral(resourceName: "removePink").withRenderingMode(.alwaysTemplate)
        removeButton.setImage(image, for: .normal)
        removeButton.tintColor = UIColor.white
    }
    
}
