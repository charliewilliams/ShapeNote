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

class NewLessonViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITextFieldDelegate {

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
        dispatch_after(1, dispatch_get_main_queue()) { [weak self] () -> Void in
            self?.searchBar.becomeFirstResponder()
        }
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchAndScope()
    }
    
    func filterContentForSingerSearchText(searchText: String) {
        
        guard searchText.characters.count > 0 else { filteredSingers = singers; return }
        
        filteredSingers = singers.filter({(singer: Singer) -> Bool in
            return singer.name.rangeOfString(searchText, options: .CaseInsensitiveSearch, range: nil, locale: nil) != nil
        })
    }
    
    func filterContentForSongSearchText(searchText: String) {
        
        guard searchText.characters.count > 0 else { filteredSongs = songs; return }
        
        filteredSongs = songs.filter({(aSong: Song) -> Bool in
            return aSong.number.hasPrefix(searchText) || aSong.number.hasPrefix("0" + searchText)
        })
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
            
            searchController.active = false
            searchBar.showsScopeBar = true
            
        } else {
            
            searchBar.text = ""
            searchController.active = true
            searchBar.showsScopeBar = true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if addingDedication {
            dedication = textField.text
        } else if addingOther {
            otherEvent = textField.text
            if otherEvent?.characters.count > 0 {
                doneButton.enabled = true
            } else if chosenSong == nil || chosenSingers.count == 0 {
                doneButton.enabled = false
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: TableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active {
            
            if searchingSongs {
                return filteredSongs?.count ?? 0
            } else {
                if let count = filteredSingers?.count {
                    return count + 1
                }
                return 1
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
        
        if let singerCell = cell as? NewLessonTableViewCell where singerCell.parentTableViewController == nil {
            singerCell.parentTableViewController = self
        }
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
            let singerCell = cell as! NewLessonTableViewCell
            singerCell.leftTextLabel.text = "Leader"
            if chosenSingers.count > 0 && indexPath.row == chosenSingers.count {
                singerCell.addButton?.hidden = false
            } else {
                singerCell.addButton?.hidden = true
            }
            if indexPath.row < chosenSingers.count {
                singerCell.rightTextLabel?.text = chosenSingers[indexPath.row].name
            }
            else {
                singerCell.rightTextLabel?.text = nil
            }
            
        case .SearchSongs:
            let songCell = cell as! NewLessonTableViewCell
            songCell.leftTextLabel.text = "Song"
            songCell.rightTextLabel?.text = chosenSong?.title
            songCell.addButton.hidden = true
            
        case .AssistedBy:
            let assistantCell = cell as! NewLessonAssistantTableViewCell
            assistantCell.rightTextLabel?.text = assistant?.name
            
        case .Dedication:
            let dedicationCell = cell as! NewLessonTextEntryTableViewCell
            if dedication != nil {
                dedicationCell.textField.hidden = false
                dedicationCell.textField.text = dedication
            } else {
                dedicationCell.textField.hidden = true
            }
            
        case .Other:
            let cell = cell as! NewLessonTextEntryTableViewCell
            cell.leftTextLabel?.text = "Other Event"
            if otherEvent != nil {
                cell.textField.hidden = false
                cell.textField.text = otherEvent
            } else {
                cell.textField.hidden = true
            }
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
                
            }
            updateSearchAndScope()
            
        } else {
            
            guard let item = ScopeBarIndex(rawValue: indexPath.row) else { fatalError() }
            
            switch item {
            case .SearchSongs:
                searchingSongs = true
            case .SearchLeaders:
                
                if indexPath.row < chosenSingers.count {
                    chosenSingers.removeAtIndex(indexPath.row)
                }
                searchingSingers = true
                
            case .AssistedBy:
                
                addingAssistant = true
                
            case .Dedication:
                
                addingDedication = true
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewLessonTextEntryTableViewCell
                cell.textField.hidden = false
                cell.textField.becomeFirstResponder()
                
            case .Other:
                
                addingOther = true
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewLessonTextEntryTableViewCell
                cell.textField.hidden = false
                cell.textField.becomeFirstResponder()
            }
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
            
        // WARNING: This is now wrong.
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
        
        lesson.leader = NSOrderedSet(array: chosenSingers)
        
        // optional stuff
        lesson.dedication = dedication
        lesson.otherEvent = otherEvent
        
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
                
                let oneDayAgoSecs = -60*60*24
                let yesterday = NSDate(timeInterval: NSTimeInterval(oneDayAgoSecs), sinceDate: NSDate())
                let lastWeekPlusOneDay = NSTimeInterval(oneDayAgoSecs * 8)
                let singers = CoreDataHelper.sharedHelper.singers().sort({ (s1:Singer, s2:Singer) -> Bool in
                    return s1.lastSingDate > s2.lastSingDate // overall, most recent first
                })
                    
                let todaySingers = singers.filter({ (s:Singer) -> Bool in
                    return s.lastSingDate > yesterday.timeIntervalSince1970
                }).sort({ (s1:Singer, s2:Singer) -> Bool in
                    return s1.lastSingDate < s2.lastSingDate // of people who have sung today, go in reverse order
                })
                    
                let singersFromLastWeekButNotToday = singers.filter({ (s:Singer) -> Bool in
                    return todaySingers.indexOf(s) == nil && s.lastSingDate > lastWeekPlusOneDay
                })
                
                let allOtherSingers = singers.filter({ (s:Singer) -> Bool in
                    return todaySingers.indexOf(s) == nil && singersFromLastWeekButNotToday.indexOf(s) == nil
                })
                
                _singers = singersFromLastWeekButNotToday + todaySingers + allOtherSingers
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




