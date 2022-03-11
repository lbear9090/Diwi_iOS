//
//  FriendsTableViewCell.swift
//  Diwi
//
//  Created by Shane Work on 12/17/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

protocol FreindsTableViewCellDelegate {
    func goToFriends()
    func updateFriends(_ friends: [String], index: Int, lookingPosts: Bool)
}

class FriendsTableViewCell: UITableViewCell {
    
    static let identifier = "FriendsTableViewCell"
    let collectionViewFlowLayout = SnapCenterLayout()
    var delegate: FreindsTableViewCellDelegate?
    var addfriends = [String]()
    var showRemoveButton: Bool = true

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupCollectionView()
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(self.friendsAdded),
//            name: NSNotification.Name(rawValue: friendsAddedString),
//            object: nil)
    }

//    @objc private func friendsAdded(notification: NSNotification) {
//        //do stuff using the userInfo property of the notification object
//        collectionView.reloadData()
//    }

    func configureCell(_ friends:[String],_ delegate: FreindsTableViewCellDelegate) {
        addfriends = friends
        self.delegate = delegate
        collectionView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCollectionView() {
        //let collectionViewSize = collectionView.frame.size
        //let screenSize = UIScreen.main.bounds.size
        
        collectionViewFlowLayout.scrollDirection = .horizontal
        //collectionViewFlowLayout.itemSize = CGSize(width: 200, height: collectionView.frame.height)
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: 80, height: collectionView.frame.height-10)
        collectionViewFlowLayout.minimumLineSpacing = 2.0
        collectionViewFlowLayout.minimumInteritemSpacing = 5.0

        collectionView.collectionViewLayout = collectionViewFlowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //collectionView.register(FriendsCollectionViewCell.self, forCellWithReuseIdentifier: "FriendsCollectionViewCell")
        let nib = UINib(nibName: "FriendsCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "FriendsCollectionViewCell")
    }
    
    func setupUI() {
        
    }
}

extension FriendsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addfriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsCollectionViewCell", for: indexPath) as! FriendsCollectionViewCell
        cell.nameLabel.text = addfriends[indexPath.row]
        cell.removeButton.isHidden = !showRemoveButton
        cell.buttonWidthConstraint.constant = cell.removeButton.isHidden ? 5 : 30
        if !showRemoveButton
        {
            cell.nameLabel.textColor = UIColor.Diwi.azure
            cell.containerView.backgroundColor = .clear
        }else
        {
            cell.nameLabel.textColor = UIColor.white
            cell.containerView.backgroundColor = UIColor.Diwi.azure
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if showRemoveButton
        {
            self.addfriends.remove(at: indexPath.item)
            self.collectionView.deleteItems(at: [indexPath])
            delegate?.updateFriends(addfriends, index: indexPath.row, lookingPosts: false)
        }else
        {
            delegate?.updateFriends([], index: indexPath.row, lookingPosts: true)
        }
    }

}
