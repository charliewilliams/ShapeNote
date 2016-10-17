//
//  UIViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 17/10/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

extension UITableViewController {
    
    func updateNoContentView(dataCount: Int, noContentView: UIView) {
        
        if dataCount > 0 {
            noContentView.isHidden = true
            tableView.isScrollEnabled = true
        } else {
            noContentView.isHidden = false
            tableView.isScrollEnabled = false
            var height = UIScreen.main.bounds.size.height
            height -= UIApplication.shared.statusBarFrame.height
            if let tabBarHeight = tabBarController?.tabBar.bounds.size.height {
                height -= tabBarHeight
            }
            
            noContentView.backgroundColor = backgroundImageColor
            noContentView.isHidden = false
            noContentView.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: height))
            
            tableView.addSubview(noContentView)
        }
    }
}
