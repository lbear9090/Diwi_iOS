//
//  CollectionViewsConfig.swift
//  Diwi
//
//  Created by Dominique Miller on 4/9/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//
// Setup for all collections except for setting delegate and datasource

import UIKit

enum CollectionsConfig {
    case closet, events, dates, contacts, closetIndex
    
    var referenceSizeForFooterInSection: CGSize {
        let screenWidth = UIScreen.main.bounds.width
        switch self {
        case .closetIndex:
            return CGSize(width: screenWidth, height: 150)
        default:
            return CGSize(width: screenWidth, height: 150)
        }
    }
    
    var insetForSectionAt: UIEdgeInsets {
        switch self {
        case .closet:
            return UIEdgeInsets(top: 26, left: 20, bottom: 36, right: 20)
        case .closetIndex:
            return UIEdgeInsets(top: 26, left: 20, bottom: 36, right: 20)
        case .events:
            return UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        case .dates:
            return UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        case .contacts:
            return UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        }
    }
    
    var minimumLineSpacingForSectionAt: CGFloat {
        switch self {
        case .closet:
            return 20
        case .closetIndex:
            return 20
        default:
            return 10
        }
    }
    
    var cgSizeForItem: CGSize {
        switch self {
        case .closet:
            return CGSize(width: 110, height: heightForItem)
        case .closetIndex:
            return CGSize(width: 98, height: 110)
        case .events:
            return CGSize(width: (UIScreen.main.bounds.width/2) - 40 , height: heightForItem)
        case .dates:
            return CGSize(width: (UIScreen.main.bounds.width/2) - 40 , height: heightForItem)
        case .contacts:
            return CGSize(width: (UIScreen.main.bounds.width/2) - 40 , height: heightForItem)
        }
    }
    
    var heightForItem: CGFloat {
        switch self {
        case .closet:
            return 98
        default:
            return 32
        }
    }
    
    var minimumLineSpacing: CGFloat {
        switch self {
        case .closet:
            return 10
        default:
            return 10
        }
    }
    
    private var flowLayout: UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        switch self {
        case .closet:
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumLineSpacing = minimumLineSpacing
            flowLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            return flowLayout
        case .events:
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumLineSpacing = minimumLineSpacing
            flowLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            return flowLayout
        case .dates:
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumLineSpacing = minimumLineSpacing
            flowLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            return flowLayout
        case .contacts:
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumInteritemSpacing = 10
            flowLayout.minimumLineSpacing = minimumLineSpacing
            flowLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            return flowLayout
        default:
            return flowLayout
        }
    }
    
    private var collectionViewConfig: UICollectionView {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        switch self {
        case .closet:
            cv.register(ClosetCell.self, forCellWithReuseIdentifier: ClosetCell.reuseIdentifier)
            cv.alwaysBounceVertical = false
            cv.showsHorizontalScrollIndicator = false
            cv.backgroundColor = .white
            cv.isScrollEnabled = true
            cv.translatesAutoresizingMaskIntoConstraints = false
            return cv
        case .closetIndex:
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.register(ClosetCell.self, forCellWithReuseIdentifier: ClosetCell.reuseIdentifier)
            cv.register(CollectionViewFooter.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                        withReuseIdentifier: CollectionViewFooter.reuseIdentifier)
            cv.alwaysBounceVertical = true
            cv.backgroundColor = .white
            return cv
        case .events:
            cv.register(OblongCollectionViewCell.self,
                        forCellWithReuseIdentifier: OblongCollectionViewCell.reuseIdentifier)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.showsHorizontalScrollIndicator = false
            cv.showsVerticalScrollIndicator = false
            cv.isScrollEnabled = false
            cv.backgroundColor = .white
            return cv
        case .dates:
            cv.register(OblongCollectionViewCell.self,
                        forCellWithReuseIdentifier: OblongCollectionViewCell.reuseIdentifier)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.showsHorizontalScrollIndicator = false
            cv.showsVerticalScrollIndicator = false
            cv.isScrollEnabled = false
            cv.backgroundColor = .white
            return cv
        case .contacts:
            cv.register(OblongCollectionViewCell.self,
                        forCellWithReuseIdentifier: OblongCollectionViewCell.reuseIdentifier)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.showsHorizontalScrollIndicator = false
            cv.showsVerticalScrollIndicator = false
            cv.isScrollEnabled = false
            cv.backgroundColor = .white
            return cv
        }
    }
    
    func collectionView() -> UICollectionView {
        return collectionViewConfig
    }
    
    func viewHeightCalculator(numberOfItems:Int) -> CGFloat {
        switch self {
        case .events:
             if numberOfItems % 2 == 1 {
                return CGFloat(numberOfItems/2) * (heightForItem + minimumLineSpacing) + (heightForItem + minimumLineSpacing)
             } else {
                return CGFloat(numberOfItems/2) * (heightForItem + minimumLineSpacing)
            }
        case .dates:
            if numberOfItems % 2 == 1 {
                return CGFloat(numberOfItems/2) * (heightForItem + minimumLineSpacing) + (heightForItem +   minimumLineSpacing)
            } else {
                return CGFloat(numberOfItems/2) * (heightForItem + minimumLineSpacing)
            }
        case .closet:
            if numberOfItems % 3 == 1 || numberOfItems % 3 == 2 {
                return CGFloat(numberOfItems/3) * (heightForItem + minimumLineSpacing) + (heightForItem + minimumLineSpacing)
             } else {
                return CGFloat(numberOfItems/3) * (heightForItem + minimumLineSpacing)
            }
        case .contacts:
            if numberOfItems % 2 == 1 {
                return CGFloat(numberOfItems/2) * (heightForItem + minimumLineSpacing) + (heightForItem +   minimumLineSpacing)
            } else {
                return CGFloat(numberOfItems/2) * (heightForItem + minimumLineSpacing)
            }
        default:
            return 0
        }
    }
}
