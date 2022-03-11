//
//  FriendsListTableViewCell.swift
//  Diwi
//
//  Created by Shane Work on 12/18/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

class FriendsListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var selectedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupUI() {
        deleteButton.setBackgroundImage(#imageLiteral(resourceName: "trashDark"), for: .normal)
        selectedButton.setBackgroundImage(#imageLiteral(resourceName: "checkEmpty"), for: .normal)
        nameLabel.tintColor = UIColor.Diwi.barney
        selectedButton.tag = 1
        nameLabel.textColor = UIColor.Diwi.barney
    }
    
    @IBAction func deleteButtonTap(_ sender: Any) {
        
    }
    
    @IBAction func selectButtonTap(_ sender: Any) {
//        if selectedButton.tag == 1 {
//            selectedButton.setBackgroundImage(#imageLiteral(resourceName: "checkFilled"), for: .normal)
//            selectedButton.tag = 2
//            nameLabel.textColor = UIColor.gray
//        } else if selectedButton.tag == 2 {
//            selectedButton.setBackgroundImage(#imageLiteral(resourceName: "checkEmpty"), for: .normal)
//            selectedButton.tag = 1
//            nameLabel.textColor = UIColor.Diwi.barney
//        }
    }
}
