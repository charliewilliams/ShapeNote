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
    case SearchLeaders = 0
    case SearchSongs = 1
    case AssistedBy = 2
    case Dedication = 3
    case Other = 4
}

let minCellCount = 5

enum CellIdentifiers:String {
    case Leader = "Leader"
    case AssistedBy = "AssistedBy"
    case Dedication = "Dedication"
}

typealias CellType = (reuseIdentifier:CellIdentifiers, index:ScopeBarIndex)
let blueColor = UIColor(colorLiteralRed: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)

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

//        navigationController?.navigationBar.opaque = true
//        navigationController?.navigationBar.translucent = false
//        definesPresentationContext = true
    }
    
    func buildSearchBar() {
        searchBar = searchController.searchBar
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        searchBar.scopeButtonTitles = ["Leader", "Song", "Assisted by", "Dedication"]
        searchBar.selectedScopeButtonIndex = ScopeBarIndex.SearchLeaders.rawValue
        tableView.tableHeaderView = searchBar
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchController.active = true
//        navigationController?.navigationBarHidden = true
        
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
        
        if searchText.characters.count == 0 {
    
            filteredSingers = singers
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
            
            filteredSongs = songs
            searchBar.placeholder = "enter song number"
            searchBar.keyboardType = UIKeyboardType.NumberPad
            
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
            
//            navigationController?.navigationBarHidden = false
            searchController.active = false
            searchBar.showsScopeBar = true
            
        } else {
            
            searchBar.text = ""
//            navigationController?.navigationBarHidden = true
            searchController.active = true
            searchBar.showsScopeBar = true
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
            
        } else if chosenSingers.count == 0 {
            return minCellCount
        } else {
            return minCellCount + chosenSingers.count - 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = identifierForCellAtIndexPath(indexPath)

        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        cell.textLabel?.textColor = UIColor.blackColor()

        if searchController.active {

            if searchingSongs {
                let song = filteredSongs![indexPath.row]
                let rawNumber = song.number
                let number = rawNumber.hasPrefix("0") ? rawNumber.substringFromIndex(rawNumber.startIndex.advancedBy(1)) : rawNumber
                cell.textLabel?.text = number + " " + song.title
            } else if indexPath.row < filteredSingers?.count {
                let singer = filteredSingers![indexPath.row]
                cell.textLabel?.text = singer.name
            } else {
                // New singer cell
                cell.textLabel?.text = "+ New Singer"
                cell.textLabel?.textColor = blueColor
            }
            
        } else {
            configureCell(cell, forIndexPath: indexPath)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if searchController.active { return 44 }
        
        let cellTypeIndex = adjustedIndexForIndexPath(indexPath)
        
        switch cellTypeIndex {
        case .SearchLeaders: fallthrough
        case .SearchSongs:
            return 70
        case .AssistedBy: fallthrough
        case .Dedication: fallthrough
        case .Other:
            return 44
        }
    }
    
    func identifierForCellAtIndexPath(indexPath:NSIndexPath) -> String {
        
        if searchController.active { return "SearchCell" }
        
        let index = adjustedIndexForIndexPath(indexPath)
        switch index {
        case .SearchLeaders: fallthrough
        case .SearchSongs:
            return CellIdentifiers.Leader.rawValue
        case .AssistedBy:
            return CellIdentifiers.AssistedBy.rawValue
        case .Dedication: fallthrough
        case .Other:
            return CellIdentifiers.Dedication.rawValue
        }
    }
    
    func adjustedIndexForIndexPath(indexPath:NSIndexPath) -> ScopeBarIndex {
        
        let numberOfSingers = chosenSingers.count
        if indexPath.row < numberOfSingers || (numberOfSingers <= 1 && indexPath.row == 0) {
            ScopeBarIndex.SearchLeaders
        }
        let adjustment = numberOfSingers > 0 ? numberOfSingers - 1 : 0
        return ScopeBarIndex(rawValue: indexPath.row - adjustment)!
    }
    
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        
        let type = adjustedIndexForIndexPath(indexPath)
        cell.textLabel?.textColor = blueColor
        
        switch type {
        case .SearchLeaders:
            cell.textLabel?.text = "Leader"
            if indexPath.row < chosenSingers.count {
                cell.detailTextLabel?.text = chosenSingers[indexPath.row].name
            } else {
                cell.detailTextLabel?.text = nil
            }
        case .SearchSongs:
            cell.textLabel?.text = "Song"
            cell.detailTextLabel?.text = chosenSong?.title
        case .AssistedBy:
            cell.textLabel?.text = "Assisted by"
            cell.detailTextLabel?.text = assistant?.name ?? "tap to search…"
        case .Dedication:
            cell.textLabel?.text = "Dedication"
            cell.textLabel?.text = dedication ?? "enter name or names"
        case .Other:
            cell.textLabel?.text = "Other Events"
            cell.detailTextLabel?.text = otherEvent ?? "break, announcements, etc."
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
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //MARK: Button actions
    
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
                
                let yesterday = NSDate(timeInterval: -60*60*24, sinceDate: NSDate())
                let singers = CoreDataHelper.sharedHelper.singers().sort({ (s1:Singer, s2:Singer) -> Bool in
                    return s1.lastSingDate > s2.lastSingDate && s1.lastSingDate > yesterday.timeIntervalSince1970
                })
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




