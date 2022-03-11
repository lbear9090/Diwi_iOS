//
//  NewLookImageTableViewCell.swift
//  Diwi
//
//  Created by Shane Work on 12/1/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

protocol LookHeaderImageDelegate {
    func didTapDelete()
    func didTapAddPhoto()
}

class NewLookImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var diwiPageControll: UIPageControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    static let identifier = "NewLookImageTableViewCell"
    var delegate: LookHeaderImageDelegate?
    var screenSize = UIScreen.main.bounds.size
    let collectionViewFlowLayout = SnapCenterLayout()
    var lookImages: [UIImage]?
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupCollectionView()
    }
    
    func setupUI() {
        diwiPageControll.currentPageIndicatorTintColor = UIColor.Diwi.azure
        diwiPageControll.pageIndicatorTintColor = UIColor.gray
    }
    
    func setupCollectionView() {
        let collectionViewSize = collectionView.frame.size
        let screenSize = UIScreen.main.bounds.size
        
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionViewFlowLayout.itemSize = CGSize(width: screenSize.width - 10, height: collectionViewSize.height)
        collectionViewFlowLayout.minimumLineSpacing = 2.0
        collectionViewFlowLayout.minimumInteritemSpacing = 5.0

        collectionView.collectionViewLayout = collectionViewFlowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: "LookHeaderCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "LookHeaderCollectionViewCell")
    }
    
    func reload() {
        self.collectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.didTapDelete()
    }
    
    @IBAction func addPhotoTapped(_ sender: Any) {
        delegate?.didTapAddPhoto()
    }
}

extension NewLookImageTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LookHeaderCollectionViewCell", for: indexPath) as! LookHeaderCollectionViewCell
        if lookImages != nil  {
            cell.backgroundImage.image = lookImages?[indexPath.row]
        } else {
            cell.backgroundImage.image = #imageLiteral(resourceName: "sample_image")
        }
        return cell
    }
    
    //Not working need to update selected index
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        diwiPageControll.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
}
