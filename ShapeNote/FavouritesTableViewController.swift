//
//  FavouritesTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 24/09/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

class FavouritesTableViewController : SongListTableViewController, IntroHandler {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TabBarManager.sharedManager.tabBarController = tabBarController!
        
        // Always be filterin'
        activeFilters = [.favorited]
        navigationController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleFirstRun()
    }
}
