//
//  TabBarController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 17/10/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if CoreDataHelper.sharedHelper.songs().filter({ (s:Song) -> Bool in
            return s.favorited
        }).count == 0 {
        
            selectedIndex = TabBarIndex.songs.rawValue
        }
    }
}
