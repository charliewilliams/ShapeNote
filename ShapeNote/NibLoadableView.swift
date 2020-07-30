//
//  NibLoadableView.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/07/2020.
//  Copyright © 2020 Charlie Williams. All rights reserved.
//

import UIKit

protocol NibLoadable { }

extension UIView: NibLoadable {
    
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func loadFromNib() -> Self? {
        
        /// Filter out alpha = 0 bc ScrollView has indicator views by default and so is never empty.
        guard subviews.filter({ $0.alpha > 0 }).isEmpty else { return self }
        
        guard let newView = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: nil, options: nil)?.first as? Self else { return nil }
        
        for constraint in constraints {
            if constraint.secondItem != nil {
                newView.addConstraint(NSLayoutConstraint(item: newView, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: newView, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
            } else {
                newView.addConstraint(NSLayoutConstraint(item: newView, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: constraint.constant))
            }
        }
        
        return newView
    }
}

class NibLoadableView: UIView {
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        loadFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class NibLoadableControl: UIControl {
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        loadFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        translatesAutoresizingMaskIntoConstraints = false
    }
}

class NibLoadableCollectionView: UICollectionView {
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        loadFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        translatesAutoresizingMaskIntoConstraints = false
    }
}
