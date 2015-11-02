//
//  SongListTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

enum FilterType {
    case Unfavorited
    case Favorited
    case Fugue
    case Plain
    case Major
    case Minor
    case Duple
    case Triple
}

class SongListTableViewController: UITableViewController {
    
    var _songs:[Song]?
    var songs:[Song] {
        get {
            if _songs != nil { return _songs! }
                
            let bookTitle = Defaults.currentlySelectedBookTitle
            let s:[Song] = CoreDataHelper.sharedHelper.songs(bookTitle) as [Song]
            _songs = s.sort { (a:Song, b:Song) -> Bool in
                
                // t and b are in the wrong order, alphabetically
                if (a.strippedNumber == b.strippedNumber) {
                    return a.number > b.number
                } else {
                    return Int(a.strippedNumber) < Int(b.strippedNumber)
                }
            }
            
            navigationItem.title = _songs!.first?.book.title
            return _songs!
        }
    }
    var activeFilters = [FilterType]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _songs = nil
        self.tableView.reloadData()
    }
    
    // MARK: - Filtering
    
    var filteredSongs:[Song] {
        
        var filteredSongs = songs
        for filter in activeFilters {
            filteredSongs = filteredSongs.filter({ (song:Song) -> Bool in
                switch filter {
                case .Unfavorited:
                    return !song.favorited
                case .Favorited:
                    return song.favorited
                case .Fugue:
                    return song.type == "Fugue"
                case .Plain:
                    return song.type == "Plain"
                case .Major:
                    return song.key == "Major"
                case .Minor:
                    return song.key == "Minor"
                case .Duple:
                    return song.isDuple()
                case .Triple:
                    return song.isTriple()
                }
            })
        }
        
        // TODO show something in the background if you've filtered out everything
        
        return filteredSongs
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (activeFilters.count > 0) {
            return filteredSongs.count
        }
        return songs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SongListTableViewCell
        let song:Song
        if (activeFilters.count > 0) {
            song = filteredSongs[indexPath.row]
        } else {
            song = songs[indexPath.row]
        }
        cell.configureWithSong(song)

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let identifier = segue.identifier else { return }
        if let selectedIndexPath = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) as? SongListTableViewCell,
            let destinationVC = segue.destinationViewController as? NotesViewController where identifier == "showNotes" {
                destinationVC.song = cell.song
        }
        if let destinationVC = segue.destinationViewController as? FiltersViewController where identifier == "editFilters" {
            destinationVC.songListViewController = self
        }
    }
}
