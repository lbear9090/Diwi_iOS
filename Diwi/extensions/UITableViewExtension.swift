//
//  UITableViewExtension.swift
//  Diwi
//
//  Created by Shane Work on 12/2/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

/** This protocol is simply a way to auto generate reuseIds for classes so that we can auto register/dequeue cells */
public protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

extension Reusable where Self: UIView {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

private struct AssociatedObjectKey {
    static var registeredCells = "registeredCells"
    static var registeredHeaderFooterViews = "registeredHeaderFooterViews"
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}


/** Adding ability to auto register cells when dequeue is called on table views*/
extension UITableView {
    
    private var registeredCells: Set<String> {
        get {
            if objc_getAssociatedObject(self, &AssociatedObjectKey.registeredCells) as? Set<String> == nil {
                self.registeredCells = Set<String>()
            }
            return (objc_getAssociatedObject(self, &AssociatedObjectKey.registeredCells) as? Set<String>) ?? []
        } set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.registeredCells, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var registeredHeaderFooterViews: Set<String> {
        get {
            if objc_getAssociatedObject(self, &AssociatedObjectKey.registeredHeaderFooterViews) as? Set<String> == nil {
                self.registeredHeaderFooterViews = Set<String>()
            }
            return (objc_getAssociatedObject(self, &AssociatedObjectKey.registeredHeaderFooterViews) as? Set<String>) ?? []
        } set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.registeredHeaderFooterViews, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func register(_ type: UITableViewCell.Type) {
        let bundle = Bundle(for: type.self)
        
        if bundle.path(forResource: type.reuseIdentifier, ofType: "nib") != nil {
            let nib = UINib(nibName: type.reuseIdentifier, bundle: bundle)
            register(nib, forCellReuseIdentifier: type.reuseIdentifier)
        } else {
            register(type.self, forCellReuseIdentifier: type.reuseIdentifier)
        }
    }
    
    private func registerSupplementaryView<T: UITableViewHeaderFooterView>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        
        if bundle.path(forResource: T.reuseIdentifier, ofType: "nib") != nil {
            let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
            register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /** Dequeue a cell and automatically register it */
    public func dequeueReusableCell<T: UITableViewCell>() -> T {
        
        guard let cell = dequeueReusableCell(withType: T.self) as? T else {
            fatalError("Error dequeuing cell with reuse identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
    
    public func dequeueReusableCell(withType type: UITableViewCell.Type) -> UITableViewCell {
        if !self.registeredCells.contains(type.reuseIdentifier) {
            self.registeredCells.insert(type.reuseIdentifier)
            self.register(type)
        }
        guard let cell = dequeueReusableCell(withIdentifier: type.reuseIdentifier) else {
            fatalError("Error dequeuing cell with reuse identifier: \(type.reuseIdentifier)")
        }
        
        return cell
    }
    
    public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        if !self.registeredHeaderFooterViews.contains(T.reuseIdentifier) {
            self.registeredHeaderFooterViews.insert(T.reuseIdentifier)
            self.registerSupplementaryView(T.self)
        }
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
            fatalError("Error dequeuing reusable view with reuse identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}
