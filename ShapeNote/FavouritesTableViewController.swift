//
//  FavouritesTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 24/09/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

class FavouritesTableViewController : SongListTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Always be filterin'
        activeFilters = [.favorited]
        navigationController?.navigationItem.rightBarButtonItem = nil
    }
    
}
