//
//  NewLeadingViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 02/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

enum ScopeBarIndex:Int {
    case SearchSongs = 0
    case SearchLeaders = 1
}

class NewLeadingViewController: UITableViewController, UISearchDisplayDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var filteredSingers:[Singer]?
    var filteredSongs:[Song]?
    var chosenSinger:Singer?
    var chosenSong:Song?
    
    var _singers:[Singer]?
    var singers:[Singer] {
        get {
            if _singers == nil {
                
                let group = CoreDataHelper.sharedHelper.groupWithName("Bristol")
                let singers = CoreDataHelper.sharedHelper.singers()
                _singers = singers
            }
            return _singers!
        }
    }
    
    var _songs:[Song]?
    var songs:[Song] {
        get {
            if _songs == nil {
                
                let songs = CoreDataHelper.sharedHelper.songs(nil)
                _songs = songs
            }
            return _songs!
        }
    }
    
    func filterContentForSingerSearchText(searchText: String) {
        
        self.filteredSingers = self.singers.filter({(singer: Singer) -> Bool in
            return singer.name.rangeOfString(searchText, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
        })
    }
    
    func filterContentForSongSearchText(searchText: String) {
        
        self.filteredSongs = self.songs.filter({(aSong: Song) -> Bool in
            return aSong.number.hasPrefix(searchText) || aSong.number.hasPrefix("0" + searchText)
        })
    }
    
    func searchingSongs() -> Bool {
        return searchBar.selectedScopeButtonIndex == ScopeBarIndex.SearchSongs.rawValue
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        
        if searchingSongs() {
            filterContentForSongSearchText(searchString)
        } else {
            filterContentForSingerSearchText(searchString)
        }
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        
        if searchOption == ScopeBarIndex.SearchSongs.rawValue {
            filterContentForSongSearchText(searchDisplayController!.searchBar.text)
        } else {
            filterContentForSingerSearchText(searchDisplayController!.searchBar.text)
        }
        updateSearchAndScope()
        return true
    }
    
    func updateSearchAndScope() {
        
        if searchBar.selectedScopeButtonIndex == ScopeBarIndex.SearchSongs.rawValue {
            searchBar.placeholder = "enter song number"
        } else {
            searchBar.placeholder = "enter name"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            
            let index = indexPath.row
            
            if searchingSongs() {
                chosenSong = filteredSongs![index]
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchLeaders.rawValue
            } else {
                chosenSinger = filteredSingers![index]
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchSongs.rawValue
            }
            updateSearchAndScope()
            searchDisplayController?.setActive(false, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            
            if searchingSongs() {
                if let filtered = self.filteredSongs {
                    return filtered.count
                } else {
                    return 0
                }
            } else {
                if let filtered = self.filteredSingers {
                    return filtered.count
                } else {
                    return 0
                }
            }
            
        } else {
            var count = 0
            if chosenSinger != nil {
                count++
            }
            if chosenSong != nil {
                count++
            }
            return count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        if tableView == self.searchDisplayController!.searchResultsTableView {

            if searchingSongs() {
                var song = filteredSongs![indexPath.row]
                cell.textLabel?.text = song.number + " " + song.title
            } else {
                var singer = filteredSingers![indexPath.row]
                cell.textLabel?.text = singer.name
            }
            
        } else {
            configureCell(cell, forIndexPath: indexPath)
        }
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row == 0 && chosenSinger != nil) {
            if let name = chosenSinger?.name {
                cell.textLabel?.text = "Leader: " + name
            }
        } else {
            if let title = chosenSong?.title {
                cell.textLabel?.text = "Song: " + title
            }
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
    }
}
