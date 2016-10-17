//
//  TabBarManager.swift
//  ShapeNote
//
//  Created by Charlie Williams on 22/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

enum TabBarIndex:Int {
    case favorites = 0
    case songs = 1
    case quiz = 2
    case minutes = 3
}

class TabBarManager {
    
    var tabBarController: UITabBarController!
    
    class var sharedManager: TabBarManager {
        struct Static {
            static let instance:TabBarManager = TabBarManager()
        }

        return Static.instance
    }
    
    fileprivate func badgeTabAtIndex(_ index:TabBarIndex, badged:Bool) {
        
        let tabArray = tabBarController.tabBar.items as NSArray!
        let tabItem = tabArray?.object(at: index.rawValue) as! UITabBarItem
        tabItem.badgeValue = badged ? " " : nil
    }
}
