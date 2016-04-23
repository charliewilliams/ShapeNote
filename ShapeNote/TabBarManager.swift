//
//  TabBarManager.swift
//  ShapeNote
//
//  Created by Charlie Williams on 22/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

enum TabBarIndex:Int {
    case Minutes = 0
    case Songs = 1
    case Singers = 2
    case Quiz = 3
    case Login = 4
}

class TabBarManager {
    
    var tabBarController:UITabBarController? {
        didSet {
            if Defaults.neverLoggedIn {
                badgeLoginTab()
            }
        }
    }
    
    class var sharedManager : TabBarManager {
        struct Static {
            static let instance:TabBarManager = TabBarManager()
        }

        return Static.instance
    }
    
    private func badgeTabAtIndex(index:TabBarIndex, badged:Bool) {
        
        guard let tabBarController = tabBarController else { return }
        
        let tabArray = tabBarController.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(index.rawValue) as! UITabBarItem
        tabItem.badgeValue = badged ? " " : nil
    }
    
    func badgeSingersTab() {
        Defaults.badgedSingersTabOnce = true
        badgeTabAtIndex(.Singers, badged: true)
    }
    
    func clearSingersTab() {
        badgeTabAtIndex(.Singers, badged: false)
    }
    
    func badgeLoginTab() {
        badgeTabAtIndex(.Login, badged: true)
    }
    
    func clearLoginTab() {
        badgeTabAtIndex(.Login, badged: false)
    }
}
