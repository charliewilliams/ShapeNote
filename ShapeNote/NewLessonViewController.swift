//
//  NewLessonViewController.swift
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
    case Dedication = 2
    case Other = 3
}

class NewLessonViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    var searchController: UISearchController
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var filteredSingers:[Singer]?
    var filteredSongs:[Song]?
    var chosenSingers:[Singer]
    var chosenSong:Song?
    var minutes:Minutes?
    var dedication:String?
    
    required init?(coder aDecoder: NSCoder) {
        chosenSingers = []
        searchController = UISearchController()
        super.init(coder: aDecoder)
        searchController = UISearchController(searchResultsController: self)
    }
    
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
                
                let bookTitle = Defaults.currentlySelectedBookTitle
                let songs = CoreDataHelper.sharedHelper.songs(bookTitle)
                _songs = songs
            }
            return _songs!
        }
    }
    
    func filterContentForSingerSearchText(searchText: String) {
        
        let yesterday = NSDate(timeInterval: -60*60*24, sinceDate: NSDate())
        
        if searchText.characters.count == 0 {
    
            filteredSingers = singers.sort({ (s1:Singer, s2:Singer) -> Bool in
                return s1.lastSingDate > s2.lastSingDate && s1.lastSingDate > yesterday.timeIntervalSince1970
            })
            return
        }
        
        filteredSingers = singers.filter({(singer: Singer) -> Bool in
            return singer.name.rangeOfString(searchText, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
        })
    }
    
    func filterContentForSongSearchText(searchText: String) {
        
        if searchText.characters.count == 0 {
            filteredSongs = songs
            return
        }
        
        filteredSongs = songs.filter({(aSong: Song) -> Bool in
            return aSong.number.hasPrefix(searchText) || aSong.number.hasPrefix("0" + searchText)
        }).sort({ (song1:Song, song2:Song) -> Bool in
            return Int(song1.strippedNumber) < Int(song2.strippedNumber)
        })
    }
    
    func searchingSongs() -> Bool {
        return searchBar.selectedScopeButtonIndex == ScopeBarIndex.SearchSongs.rawValue
    }
    
    func searchingSingers() -> Bool {
        return searchBar.selectedScopeButtonIndex == ScopeBarIndex.SearchLeaders.rawValue
    }
    
    func addingDedication() -> Bool {
        return searchBar.selectedScopeButtonIndex == ScopeBarIndex.Dedication.rawValue
    }
    
    func addingOther() -> Bool {
        return searchBar.selectedScopeButtonIndex == ScopeBarIndex.Other.rawValue
    }
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        
        if searchingSongs() {
            filterContentForSongSearchText(searchString)
        } else if searchingSingers() {
            filterContentForSingerSearchText(searchString)
        }
        return true
    }
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        
        guard let text = controller.searchBar.text else {
            return false
        }
        
        if searchingSongs() {
            filterContentForSongSearchText(text)
        } else if searchingSingers() {
            filterContentForSingerSearchText(text)
        }
        updateSearchAndScope()
        return true
    }
    
    func updateSearchAndScope() {
        
        let index = ScopeBarIndex(rawValue: searchBar.selectedScopeButtonIndex)!
        searchBar.keyboardType = UIKeyboardType.ASCIICapable
        
        switch (index) {
            
            case .SearchSongs:
                searchBar.placeholder = "enter song number"
                searchBar.keyboardType = UIKeyboardType.NumberPad
                self.filteredSongs = self.songs

            case .SearchLeaders:
                searchBar.placeholder = "enter name"
                self.filteredSingers = self.singers

            case .Dedication:
                
                if dedication == nil {
                    searchBar.placeholder = "enter dedication"
                    popAlertForDedication()
                }
            
            case .Other:
                searchBar.placeholder = "what's happening now?"
                
        }
        
        searchBar.reloadInputViews()
        
        let complete = (chosenSong != nil && chosenSingers.count != 0)
        doneButton.enabled = complete
        
        if complete == true {
            
            searchController.active = false
            
        } else {
            
            searchBar.text = ""
            searchController.searchResultsUpdater?.updateSearchResultsForSearchController(searchController)
            searchController.active = true
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let vc = searchController.searchResultsController else {
            return
        }
        
        if tableView == vc.view {
            
            let index = indexPath.row
            
            if searchingSongs() {
                chosenSong = filteredSongs![index]
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchLeaders.rawValue
                
            } else if searchingSingers() && index < filteredSingers?.count {
                
                let singer = filteredSingers![index]
                singer.lastSingDate = NSDate().timeIntervalSince1970
                chosenSingers.append(singer)
                
                if chosenSong == nil {
                    searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchSongs.rawValue
                }
                
            } else if searchingSingers() {
                popAlertForNewSinger()
            } else if addingDedication() {
                // nothing?
            } else if addingOther() {
                // TODO
            }
            updateSearchAndScope()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
            
        case .Delete:
            if indexPath.row < chosenSingers.count {
                chosenSingers.removeAtIndex(indexPath.row)
            } else if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text?.hasPrefix("Song") != nil {
                chosenSong = nil
            } else {
                dedication = nil
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        default:
            break
        }
        
    }
    
    func popAlertForNewSinger() {
        
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "New Singer", message: "Ok, what's their name?", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Done", style: .Default, handler: { (action:UIAlertAction) -> Void in
            
            if action.style == .Cancel {
                return
            }
            
            if let text = inputTextField?.text as String? {
                let newSinger = NSEntityDescription.insertNewObjectForEntityForName("Singer", inManagedObjectContext: CoreDataHelper.sharedHelper.managedObjectContext!) as! Singer
                newSinger.name = text
                self.chosenSingers.append(newSinger)
                CoreDataHelper.sharedHelper.saveContext()
                self.tableView.reloadData()
                self.updateSearchAndScope()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action:UIAlertAction) -> Void in
            
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addTextFieldWithConfigurationHandler({ (textField:UITextField) -> Void in
            textField.placeholder = "Name"
            textField.text = self.searchBar.text
            inputTextField = textField
        })
        self.presentViewController(alert, animated: true, completion: {
            
            self.view.setNeedsLayout()
        })
    }
    
    func popAlertForDedication() {
        
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "Dedication", message: "Enter dedication text, i.e. 'For...'", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Done", style: .Default, handler: { (action:UIAlertAction) -> Void in
            
            if let text = inputTextField?.text as String? {
                self.dedication = text
                self.tableView.reloadData()
                self.updateSearchAndScope()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action:UIAlertAction) -> Void in
            //
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.addTextFieldWithConfigurationHandler({ (textField:UITextField) -> Void in
            textField.placeholder = "For Name"
            textField.text = self.searchBar.text
            inputTextField = textField
        })
        
        alert.becomeFirstResponder()
        self.presentViewController(alert, animated: true, completion: {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                alert.view.center = CGPointMake(alert.view.center.x, alert.view.center.y - 70)
            })
        })

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.searchController.searchResultsController {
            
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
            var count = chosenSingers.count ?? 0
            if chosenSong != nil {
                count++
            }
            if dedication != nil {
                count++
            }
            return count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        guard let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") else {
            print("Couldn't dequeue cell!")
            abort()
        }
        
        if let _searchDisplayController = self.searchDisplayController where tableView == _searchDisplayController.searchResultsTableView {

            if searchingSongs() {
                let song = filteredSongs![indexPath.row]
                cell.textLabel?.text = song.number + " " + song.title
            } else if indexPath.row < filteredSingers?.count {
                let singer = filteredSingers![indexPath.row]
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
        
        if indexPath.row < chosenSingers.count {
            cell.textLabel?.text = "Leader: " + chosenSingers[indexPath.row].name
        } else if indexPath.row == chosenSingers.count {
            if let title = chosenSong?.title {
                cell.textLabel?.text = "Song: " + title
            }
        } else if dedication != nil {
            cell.textLabel?.text = dedication
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        
        let lesson = NSEntityDescription.insertNewObjectForEntityForName("Lesson", inManagedObjectContext: CoreDataHelper.managedContext) as! Lesson
        lesson.date = NSDate()
        lesson.minutes = minutes!
        
        if let song = chosenSong {
            lesson.song = song
        }
        
        print(lesson.leader)
        lesson.leader = NSOrderedSet(array: chosenSingers)
        
        // optional stuff
        lesson.dedication = self.dedication
        
        minutes?.singers.addObjectsFromArray(chosenSingers)
        
        TwitterShareHelper.sharedHelper.postLesson(lesson)
        
        CoreDataHelper.sharedHelper.saveContext()
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}







