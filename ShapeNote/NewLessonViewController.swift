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
    case AssistedBy = 2
    case Dedication = 3
    case Other = 4
}

let minCellCount = 5

enum CellIdentifiers:String {
    case Leader = "Leader"
    case Song = "Song"
    case AssistedBy = "AssistedBy"
    case Dedication = "Dedication"
    case OtherEvent = "Other"
}

typealias CellType = (reuseIdentifier:CellIdentifiers, index:ScopeBarIndex)

class NewLessonViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    var searchBar: UISearchBar
    var searchController: UISearchController
    var minutes:Minutes?
    var filteredSingers:[Singer]?
    var filteredSongs:[Song]?
    var chosenSingers:[Singer]
    var chosenSong:Song?
    var dedication:String?
    var assistant:Singer?
    var otherEvent:String?
    
    required init?(coder aDecoder: NSCoder) {
        chosenSingers = []
        searchBar = UISearchBar() // dummy so we don't need an optional property, blarg.
        searchController = UISearchController() // dummy so we don't need an optional property, blarg.
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buildSearchController()
        extendedLayoutIncludesOpaqueBars = true
        doneButton.enabled = false
    }
    
    func buildSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        buildSearchBar()

        navigationController?.navigationBar.opaque = true
//        definesPresentationContext = true
    }
    
    func buildSearchBar() {
        searchBar = searchController.searchBar
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.whiteColor()
        searchBar.opaque = true
        searchBar.scopeButtonTitles = ["Song", "Leader", "Assisted by", "Dedication"]
        searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchLeaders.rawValue
        tableView.tableHeaderView = searchBar
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchController.active = true
        navigationController?.navigationBarHidden = true
        
        dispatch_after(1, dispatch_get_main_queue()) { [weak self] () -> Void in
            self?.searchBar.becomeFirstResponder()
        }
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchAndScope()
    }
    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        filterContentForSingerSearchText(searchText)
//    }
    
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
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        
        if searchingSongs {
            filterContentForSongSearchText(searchString)
        } else if searchingSingers {
            filterContentForSingerSearchText(searchString)
        }
        return true
    }
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        
        guard let text = controller.searchBar.text else {
            return false
        }
        
        if searchingSongs {
            filterContentForSongSearchText(text)
        } else if searchingSingers {
            filterContentForSingerSearchText(text)
        }
        updateSearchAndScope()
        return true
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {

        let index = ScopeBarIndex(rawValue: searchBar.selectedScopeButtonIndex)!
        guard let searchText = searchBar.text else { return }

        switch index {
            
        case .SearchSongs:
            filterContentForSongSearchText(searchText)
            
        case .SearchLeaders:
            filterContentForSingerSearchText(searchText)
            
        case .Dedication:
            filterContentForSingerSearchText(searchText)
            
        case .AssistedBy:
            fallthrough
            
        case .Other:
            return
        }
        
        tableView.reloadData()
    }
    
    func updateSearchAndScope() {
        
        let index = ScopeBarIndex(rawValue: searchBar.selectedScopeButtonIndex)!
        searchBar.keyboardType = UIKeyboardType.ASCIICapable
        
        switch index {
            
        case .SearchSongs:
            searchBar.placeholder = "enter song number"
            searchBar.keyboardType = UIKeyboardType.NumberPad
            self.filteredSongs = self.songs
            
        case .SearchLeaders:
            searchBar.placeholder = "enter name"
            self.filteredSingers = self.singers
            
        case .Dedication:
            break
            
        case .AssistedBy:
            searchBar.placeholder = "enter assistant's name"
            
        case .Other:
            searchBar.placeholder = "what's happening now?"
        }
        
        searchBar.reloadInputViews()
        
        let complete = (chosenSong != nil && chosenSingers.count != 0)
        doneButton.enabled = complete
        
        if complete {
            
            navigationController?.navigationBarHidden = false
            searchController.active = false
            
        } else {
            
            searchBar.text = ""
            navigationController?.navigationBarHidden = true
            searchController.active = true
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if searchController.active {
            
            let index = indexPath.row
            
            if searchingSongs {
                
                chosenSong = filteredSongs![index]
                
                if chosenSingers.count == 0 {
                    searchingSingers = true
                }
                
            } else if searchingSingers && index < filteredSingers?.count {
                
                let singer = filteredSingers![index]
                singer.lastSingDate = NSDate().timeIntervalSince1970
                chosenSingers.append(singer)
                
                if chosenSong == nil {
                    searchingSongs = true
                }
                
            } else if searchingSingers {
                
                popAlertForNewSinger() // This isn't great, we should put a text field on the cell with a done button
                
            } else if addingDedication {

                let singer = filteredSingers![index]
                dedication = singer.name

            } else if addingOther {
                
                // get text from cell like above
                
            }
            updateSearchAndScope()
            
        } else {
            
            guard let item = ScopeBarIndex(rawValue: indexPath.row) else { return }
                
            switch item {
            case .SearchSongs:
                searchingSongs = true
            case .SearchLeaders:
                searchingSingers = true
            case .AssistedBy:
                addingAssistant = true
            case .Dedication:
                addingDedication = true
            case .Other:
                addingOther = true
            }
            
            self.searchBar.becomeFirstResponder()
        }
        
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        self.tableView.reloadData()
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
    
    //MARK: TableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active {
            
            if searchingSongs {
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
            return minCellCount + chosenSingers.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = identifierForCellAtIndexPath(indexPath)

        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!

        if searchController.active {

            if searchingSongs {
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
    
    func identifierForCellAtIndexPath(indexPath:NSIndexPath) -> String {
        
        if searchController.active {
            return "SearchCell"
        }
        
        let index = adjustedIndexForIndexPath(indexPath)
        switch index {
        case .SearchLeaders:
            return CellIdentifiers.Leader.rawValue
        case .SearchSongs:
            return CellIdentifiers.Song.rawValue
        case .AssistedBy:
            return CellIdentifiers.AssistedBy.rawValue
        case .Dedication:
            return CellIdentifiers.Dedication.rawValue
        case .Other:
            return CellIdentifiers.OtherEvent.rawValue
        }
    }
    
    func adjustedIndexForIndexPath(indexPath:NSIndexPath) -> ScopeBarIndex {
        
        let numberOfSingers = chosenSingers.count
        if numberOfSingers > 0 {
            if indexPath.row <= numberOfSingers {
                return ScopeBarIndex.SearchLeaders
            }
            return ScopeBarIndex(rawValue: indexPath.row - numberOfSingers)!
        }
        return ScopeBarIndex(rawValue: indexPath.row)!
    }
    
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        
        let type = adjustedIndexForIndexPath(indexPath)
        
        switch type {
        case .SearchLeaders:
            if indexPath.row < chosenSingers.count {
                cell.detailTextLabel?.text = chosenSingers[indexPath.row].name
            } else {
                cell.detailTextLabel?.text = nil
            }
        case .SearchSongs:
            cell.detailTextLabel?.text = chosenSong?.title
        case .AssistedBy:
            cell.detailTextLabel?.text = assistant?.name
        case .Dedication:
            cell.textLabel?.text = dedication
        case .Other:
            cell.detailTextLabel?.text = otherEvent
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
    
    //MARK: fancy getters & setters
    
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
    
    var searchingSongs:Bool {
        get {
            return searchBar.selectedScopeButtonIndex == ScopeBarIndex.SearchSongs.rawValue
        }
        set {
            if newValue {
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchSongs.rawValue
            }
        }
    }
    
    var searchingSingers:Bool {
        get {
            return searchBar.selectedScopeButtonIndex == ScopeBarIndex.SearchLeaders.rawValue
        }
        set {
            if newValue {
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchLeaders.rawValue
            }
        }
    }
    
    var addingAssistant:Bool {
        get {
            return searchBar.selectedScopeButtonIndex == ScopeBarIndex.AssistedBy.rawValue
        }
        set {
            if newValue {
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.AssistedBy.rawValue
            }
        }
    }
    
    var addingDedication:Bool {
        get {
            return searchBar.selectedScopeButtonIndex == ScopeBarIndex.Dedication.rawValue
        }
        set {
            if newValue {
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.Dedication.rawValue
            }
        }
    }
    
    var addingOther:Bool {
        get {
            return searchBar.selectedScopeButtonIndex == ScopeBarIndex.Other.rawValue
        }
        set {
            if newValue {
                searchBar.selectedScopeButtonIndex = ScopeBarIndex.Other.rawValue
            }
        }
    }
}




