//
//  FavouritesTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 24/09/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

class FavouritesTableViewController : SongListTableViewController, NoContentViewDisplaying {
    
    @IBOutlet var noContentView: UIView!
    
    override var navigationItem: UINavigationItem {
        
        let item = super.navigationItem
        let shortTitle = CoreDataHelper.sharedHelper.currentlySelectedBook.shortTitle
        item.title = "Favourites: \(shortTitle)"
        
        return item
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        TabBarManager.instance.tabBarController = tabBarController!
        
        // Always be filterin'
        activeFilters = [.favorited]
        
        // Keep the custom title centered
        let rightItem = UIBarButtonItem(customView: UIView(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44))))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleFirstRun()
        updateNoContentView(dataCount: filteredSongs.count, noContentView: noContentView)
    }
}
