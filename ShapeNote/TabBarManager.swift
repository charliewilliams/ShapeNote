//
//  TabBarManager.swift
//  ShapeNote
//
//  Created by Charlie Williams on 22/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

enum TabBarIndex: Int {
    case songs
    case quiz
    case favorites
}

class TabBarManager {
    
    static let instance = TabBarManager()
    
    var tabBarController: UITabBarController!
    
    fileprivate func badgeTabAtIndex(_ index:TabBarIndex, badged:Bool) {
        
        if let tabArray = tabBarController.tabBar.items {
            let tabItem = tabArray[index.rawValue]
            tabItem.badgeValue = badged ? " " : nil
        }
    }
}
