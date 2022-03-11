//
//  UICollectionViewExtension.swift
//  Diwi
//
//  Created by Dominique Miller on 4/2/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError(TextContent.Errors.unAbleToDequeueCollectionCell)
        }

        return cell
    }
}
