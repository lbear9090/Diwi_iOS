//
//  FriendsListTableViewCell.swift
//  Diwi
//
//  Created by Shane Work on 12/18/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

class CollectionHeaderCell: UICollectionReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectedButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
     }

     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = "All looks, newest to oldest"
        selectedButton.setBackgroundImage(UIImage(named: "filter_descend"), for: .normal)
        selectedButton.tintColor = UIColor.darkGray
        selectedButton.tag = 2
    }
    
    func updateLabel()  {
        if selectedButton.tag == 1 {
            nameLabel.text = "All looks, newest to oldest"
            selectedButton.setBackgroundImage(UIImage(named: "filter_descend"), for: .normal)
            selectedButton.tintColor = UIColor.darkGray
            selectedButton.tag = 2

        } else if selectedButton.tag == 2 {
            nameLabel.text = "All looks, oldest to newest"
            selectedButton.setBackgroundImage(UIImage(named: "filter_ascend"), for: .normal)
            selectedButton.tintColor = UIColor.darkGray
            selectedButton.tag = 1
        }
    }
   
    
    @IBAction func selectButtonTap(_ sender: Any) {
        if selectedButton.tag == 1 {
            nameLabel.text = "All looks, newest to oldest"
            selectedButton.setBackgroundImage(UIImage(named: "filter_descend"), for: .normal)
            selectedButton.tintColor = UIColor.darkGray
            selectedButton.tag = 2

        } else if selectedButton.tag == 2 {
            nameLabel.text = "All looks, oldest to newest"
            selectedButton.setBackgroundImage(UIImage(named: "filter_ascend"), for: .normal)
            selectedButton.tintColor = UIColor.darkGray
            selectedButton.tag = 1
        }
    }
            
}
