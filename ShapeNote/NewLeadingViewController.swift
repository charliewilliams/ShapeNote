//
//  NewLeadingViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 02/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

enum ScopeBarIndex:Int {
    case SearchSongs = 0
    case SearchLeaders = 1
}

class NewLeadingViewController: UITableViewController, UISearchDisplayDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var filteredSingers:[Singer]?
    var filteredSongs:[Song]?
    var chosenSinger:Singer?
    var chosenSong:Song?
    var minutes:Minutes?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
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
        
        if (searchText.utf16Count == 0) {
            self.filteredSingers = self.singers
            return
        }
        
        self.filteredSingers = self.singers.filter({(singer: Singer) -> Bool in
            return singer.name.rangeOfString(searchText, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
        })
    }
    
    func filterContentForSongSearchText(searchText: String) {
        
        if (searchText.utf16Count == 0) {
            self.filteredSongs = self.songs
            return
        }
        
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
        
        let complete = (chosenSong != nil && chosenSinger != nil)
        doneButton.enabled = complete
        
        if complete == true {
            
            searchDisplayController?.setActive(false, animated: true)
        } else {
            
            searchBar.text = ""
            searchDisplayController?.searchResultsTableView.reloadData()
            searchDisplayController?.setActive(true, animated: true)
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            
            let index = indexPath.row
            
            if searchingSongs() {
                chosenSong = filteredSongs![index]
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchLeaders.rawValue
            } else if index < filteredSingers?.count {
                chosenSinger = filteredSingers![index]
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchSongs.rawValue
            } else {
                popAlertForNewSinger()
            }
            updateSearchAndScope()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tableView.reloadData()
    }
    
    func popAlertForNewSinger() {
        
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "New Singer", message: "Ok, what's their name?", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Done", style: .Default, handler: { (action:UIAlertAction!) -> Void in
            
            if action.style == .Cancel {
                return
            }
            
            if let text = inputTextField?.text as String? {
                let newSinger = NSEntityDescription.insertNewObjectForEntityForName("Singer", inManagedObjectContext: CoreDataHelper.sharedHelper.managedObjectContext!) as? Singer
                newSinger?.name = text
                self.chosenSinger = newSinger!
                CoreDataHelper.save()
                self.tableView.reloadData()
                self.updateSearchAndScope()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action:UIAlertAction!) -> Void in
            
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addTextFieldWithConfigurationHandler({ (textField:UITextField!) -> Void in
            textField.placeholder = "Name"
            inputTextField = textField
        })
        self.presentViewController(alert, animated: true, completion: nil)
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
                    return filtered.count + 1 // for New Singer
                } else {
                    return 1
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
            } else if indexPath.row < filteredSingers?.count {
                var singer = filteredSingers![indexPath.row]
                cell.textLabel?.text = singer.name
            } else {
                // New singer cell
                cell.textLabel?.text = "+ New Singer"
                cell.textLabel?.textColor = UIColor.blueColor()
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
        
        let leading = NSEntityDescription.insertNewObjectForEntityForName("Leading", inManagedObjectContext: CoreDataHelper.managedContext!) as Leading
        leading.date = NSDate()
        leading.song = chosenSong!
        leading.leader = chosenSinger!
        
        if minutes == nil {
            minutes = NSEntityDescription.insertNewObjectForEntityForName("Minutes", inManagedObjectContext: CoreDataHelper.managedContext!) as? Minutes
            minutes?.date = NSDate()
            minutes?.book = CoreDataHelper.sharedHelper.books().first!
        }
        
        leading.minutes = minutes!
        
        CoreDataHelper.save()
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}







