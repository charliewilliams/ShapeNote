//
//  FavouritesTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 24/09/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

class FavouritesTableViewController : SongListTableViewController, IntroHandler {
    
    @IBOutlet var noContentView: UIView!
    
    override var navigationItem: UINavigationItem {
        let item = super.navigationItem
        if let title = item.title,
            title.contains("Favourites") == false {
            item.title = "Favourites: \(title)"
        }
        return item
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        TabBarManager.sharedManager.tabBarController = tabBarController!
        
        // Always be filterin'
        activeFilters = [.favorited]
        navigationController?.navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleFirstRun()
        updateNoContentView(dataCount: filteredSongs.count, noContentView: noContentView)
    }
}
