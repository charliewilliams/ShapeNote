//
//  FavoriteSongsTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/10/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import Foundation

class FavoriteSongsTableViewController: SongListTableViewController {
    
    var filteredSongs:[Song] {
        return songs.filter { (song:Song) -> Bool in
            song.favorited
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSongs.count
    }
}