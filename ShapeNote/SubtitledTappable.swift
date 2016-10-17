//
//  UILabel.swift
//  ShapeNote
//
//  Created by Charlie Williams on 16/10/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

protocol SubtitledTappable: class {
    
    var headerLabel: UILabel? { get set }
    var headerTapGestureRecognizer: UITapGestureRecognizer! { get set }
    
    func buildHeaderLabel()
    func setTitle(title: String?, subtitle: String?)
}

extension SubtitledTappable where Self: UIViewController {
    
    func buildHeaderLabel() {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.attributedText = nil
        label.isUserInteractionEnabled = true
        
        headerTapGestureRecognizer = UITapGestureRecognizer()
        label.addGestureRecognizer(headerTapGestureRecognizer)
        
        headerLabel = label
        navigationItem.titleView = label
    }
    
    func setTitle(title: String?, subtitle: String?) {
    
        let title = title ?? ""
        let subtitle = subtitle ?? ""
        let titleAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15.0)]
        let subtitleAttributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont.systemFont(ofSize: 12.0)]
        
        let attributedTitle = NSMutableAttributedString(string: title + "\n", attributes: titleAttributes)

        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        attributedTitle.append(subtitleString)
        
//        headerLabel.frame.width = attributedTitle.size().width
        headerLabel?.attributedText = attributedTitle
        
        headerLabel?.setNeedsLayout()
    }
}
