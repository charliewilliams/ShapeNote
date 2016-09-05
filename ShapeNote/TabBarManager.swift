//
//  TabBarManager.swift
//  ShapeNote
//
//  Created by Charlie Williams on 22/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

enum TabBarIndex:Int {
    case minutes = 0
    case songs = 1
    case singers = 2
    case quiz = 3
}

class TabBarManager {
    
    var tabBarController:UITabBarController?
    
    class var sharedManager : TabBarManager {
        struct Static {
            static let instance:TabBarManager = TabBarManager()
        }

        return Static.instance
    }
    
    fileprivate func badgeTabAtIndex(_ index:TabBarIndex, badged:Bool) {
        
        guard let tabBarController = tabBarController else { return }
        
        let tabArray = tabBarController.tabBar.items as NSArray!
        let tabItem = tabArray?.object(at: index.rawValue) as! UITabBarItem
        tabItem.badgeValue = badged ? " " : nil
    }
    
    func badgeSingersTab() {
        Defaults.badgedSingersTabOnce = true
        badgeTabAtIndex(.singers, badged: true)
    }
    
    func clearSingersTab() {
        badgeTabAtIndex(.singers, badged: false)
    }
}
