//
//  NewLessonViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 02/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum ScopeBarIndex:Int {
    case searchLeaders = 0
    case searchSongs = 1
    case assistedBy = 2
    case dedication = 3
    case other = 4
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
    var searchBar: UISearchBar!
    var searchController: UISearchController!
    var minutes:Minutes?
    var filteredSingers:[Singer]?
    var filteredSongs:[Song]?
    var chosenSingers = [Singer]()
    var chosenSong:Song?
    var dedication:String?
    var assistant:Singer?
    var otherEvent:String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buildSearchController()
        extendedLayoutIncludesOpaqueBars = true
        doneButton.isEnabled = false
    }
    
    func buildSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        buildSearchBar()
    }
    
    func buildSearchBar() {
        searchBar = searchController.searchBar
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        searchBar.scopeButtonTitles = ["Leader", "Song", "Assisted by", "Dedication"]
        searchBar.selectedScopeButtonIndex = ScopeBarIndex.searchLeaders.rawValue
        tableView.tableHeaderView = searchBar
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 128))
        let width = UIScreen.main.bounds.size.width
        searchBar.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width))
//        view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        
        // TODO 
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] () -> Void in
            
            guard let searchBar = self?.searchBar else { return }
            searchBar.becomeFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchAndScope()
    }
    
    func filterContentForSingerSearchText(_ searchText: String) {
        
        guard searchText.characters.count > 0 else { filteredSingers = singers; return }
        
        filteredSingers = singers.filter({(singer: Singer) -> Bool in
            return singer.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
    }
    
    func filterContentForSongSearchText(_ searchText: String) {
        
        guard searchText.characters.count > 0 else { filteredSongs = songs; return }
        
        filteredSongs = songs.filter({(aSong: Song) -> Bool in
            return aSong.number.hasPrefix(searchText) || aSong.number.hasPrefix("0" + searchText)
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {

        let index = ScopeBarIndex(rawValue: searchBar.selectedScopeButtonIndex)!
        guard let searchText = searchBar.text else { return }

        switch index {
            
        case .searchSongs:
            filterContentForSongSearchText(searchText)
            
        case .searchLeaders:
            filterContentForSingerSearchText(searchText)
            
        case .dedication:
            filterContentForSingerSearchText(searchText)
            
        case .assistedBy:
            fallthrough
            
        case .other:
            return
        }
        
        tableView.reloadData()
    }
    
    func updateSearchAndScope() {
        
        let index = ScopeBarIndex(rawValue: searchBar.selectedScopeButtonIndex)!
        searchBar.keyboardType = UIKeyboardType.asciiCapable
        
        switch index {
            
        case .searchSongs:
            
            filteredSongs = songs
            searchBar.placeholder = "enter song number"
            searchBar.keyboardType = UIKeyboardType.numberPad
            
        case .searchLeaders:
            searchBar.placeholder = "enter name"
            self.filteredSingers = self.singers
            
        case .dedication:
            break
            
        case .assistedBy:
            searchBar.placeholder = "enter assistant's name"
            
        case .other:
            searchBar.placeholder = "what's happening now?"
        }
        
        searchBar.reloadInputViews()
        
        let complete = (chosenSong != nil && chosenSingers.count != 0)
        doneButton.isEnabled = complete
        
        if complete {
            
            searchController.isActive = false
            searchBar.showsScopeBar = true
            
        } else {
            
            searchBar.text = ""
            searchController.isActive = true
            searchBar.showsScopeBar = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if addingDedication {
            
            dedication = textField.text
            
        } else if addingOther {
            
            otherEvent = textField.text
            if otherEvent?.characters.count > 0 {
                doneButton.isEnabled = true
            } else if chosenSong == nil || chosenSingers.count == 0 {
                doneButton.isEnabled = false
            }
            
        } else if let newSingerName = textField.text {
            
            let newSinger = NSEntityDescription.insertNewObject(forEntityName: "Singer", into: CoreDataHelper.managedContext) as! Singer
            
            var components = newSingerName.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            newSinger.firstName = components.first
            if components.count > 1 {
                components.remove(at: 0)
                newSinger.lastName = components.joined(separator: " ")
            }
            CoreDataHelper.sharedHelper.saveContext()
            chosenSingers.append(newSinger)
            searchingSingers = false
            searchController.isActive = false;
            updateSearchAndScope()
        }
        
        textField.resignFirstResponder()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return true
    }
    
    //MARK: TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = identifierForCellAtIndexPath(indexPath)

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        
        if let singerCell = cell as? NewLessonTableViewCell, singerCell.parentTableViewController == nil {
            singerCell.parentTableViewController = self
        }
        cell.textLabel?.textColor = UIColor.black

        if searchController.isActive {

            if searchingSongs {
                
                let song = filteredSongs![(indexPath as NSIndexPath).row]
                let rawNumber = song.number
                let number = rawNumber.hasPrefix("0") ? rawNumber.substring(from: rawNumber.characters.index(rawNumber.startIndex, offsetBy: 1)) : rawNumber
                cell.textLabel?.text = number + " " + song.title
                
            } else if (indexPath as NSIndexPath).row < filteredSingers?.count {
                
                let singer = filteredSingers![(indexPath as NSIndexPath).row]
                cell.textLabel?.text = singer.name
                
            } else {
                
                let newSingerCell = tableView.dequeueReusableCell(withIdentifier: "Dedication") as! NewLessonTextEntryTableViewCell
                newSingerCell.leftTextLabel?.text = "+New Singer"
                newSingerCell.textField.placeholder = "enter name"
                return newSingerCell
            }
            
        } else {
            configureCell(cell, forIndexPath: indexPath)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if searchController.isActive { return 44 }
        
        let cellTypeIndex = adjustedIndexForIndexPath(indexPath)
        
        switch cellTypeIndex {
        case .searchLeaders: fallthrough
        case .searchSongs:
            return 70
        case .assistedBy: fallthrough
        case .dedication: fallthrough
        case .other:
            return 44
        }
    }
    
    func identifierForCellAtIndexPath(_ indexPath:IndexPath) -> String {
        
        if searchController.isActive { return "SearchCell" }
        
        let index = adjustedIndexForIndexPath(indexPath)
        switch index {
        case .searchLeaders: fallthrough
        case .searchSongs:
            return CellIdentifiers.Leader.rawValue
        case .assistedBy:
            return CellIdentifiers.AssistedBy.rawValue
        case .dedication: fallthrough
        case .other:
            return CellIdentifiers.Dedication.rawValue
        }
    }
    
    func adjustedIndexForIndexPath(_ indexPath:IndexPath) -> ScopeBarIndex {
        
        let numberOfSingers = chosenSingers.count
        if (indexPath as NSIndexPath).row < numberOfSingers || (numberOfSingers <= 1 && (indexPath as NSIndexPath).row == 0) {
            return ScopeBarIndex.searchLeaders
        }
        let adjustment = numberOfSingers > 0 ? numberOfSingers - 1 : 0
        return ScopeBarIndex(rawValue: (indexPath as NSIndexPath).row - adjustment)!
    }
    
    func configureCell(_ cell: UITableViewCell, forIndexPath indexPath: IndexPath) {
        
        let type = adjustedIndexForIndexPath(indexPath)
        cell.textLabel?.textColor = blueColor
        
        switch type {
            
        case .searchLeaders:
            let singerCell = cell as! NewLessonTableViewCell
            singerCell.leftTextLabel.text = "Leader"
            if chosenSingers.count > 0 && (indexPath as NSIndexPath).row == chosenSingers.count {
                singerCell.addButton?.isHidden = false
            } else {
                singerCell.addButton?.isHidden = true
            }
            if (indexPath as NSIndexPath).row < chosenSingers.count {
                singerCell.rightTextLabel?.text = chosenSingers[(indexPath as NSIndexPath).row].name
            }
            else {
                singerCell.rightTextLabel?.text = nil
            }
            
        case .searchSongs:
            let songCell = cell as! NewLessonTableViewCell
            songCell.leftTextLabel.text = "Song"
            songCell.rightTextLabel?.text = chosenSong?.title
            songCell.addButton.isHidden = true
            
        case .assistedBy:
            let assistantCell = cell as! NewLessonAssistantTableViewCell
            assistantCell.leftTextLabel.text = "Assisted by"
            assistantCell.rightTextLabel?.text = assistant?.name
            
        case .dedication:
            let dedicationCell = cell as! NewLessonTextEntryTableViewCell
            dedicationCell.leftTextLabel.text = "Dedication"
            if dedication != nil {
                dedicationCell.textField.isHidden = false
                dedicationCell.textField.text = dedication
            } else {
                dedicationCell.textField.text = nil
                dedicationCell.textField.isHidden = true
            }
            
        case .other:
            let cell = cell as! NewLessonTextEntryTableViewCell
            cell.leftTextLabel?.text = "Other Event"
            if otherEvent != nil {
                cell.textField.isHidden = false
                cell.textField.text = otherEvent
            } else {
                cell.textField.isHidden = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive {
            
            let index = (indexPath as NSIndexPath).row
            
            if searchingSongs {
                
                chosenSong = filteredSongs![index]
                
                if chosenSingers.count == 0 {
                    searchingSingers = true
                }
                
            } else if searchingSingers && index < filteredSingers?.count {
                
                let singer = filteredSingers![index]
                singer.lastSingDate = Date().timeIntervalSince1970
                chosenSingers.append(singer)
                
                if chosenSong == nil {
                    searchingSongs = true
                }
                
            } else if searchingSingers {
                
                let cell = tableView.cellForRow(at: indexPath) as! NewLessonTextEntryTableViewCell
                cell.textField.isHidden = false
                cell.textField.placeholder = "enter name"
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { () -> Void in
                    cell.textField.becomeFirstResponder()
                }
            }
            updateSearchAndScope()
            
        } else {
            
            guard let item = ScopeBarIndex(rawValue: (indexPath as NSIndexPath).row) else { fatalError() }
            
            switch item {
            case .searchSongs:
                searchingSongs = true
                searchController.isActive = true
                
            case .searchLeaders:
                
                if (indexPath as NSIndexPath).row < chosenSingers.count {
                    chosenSingers.remove(at: (indexPath as NSIndexPath).row)
                }
                searchingSingers = true
                searchController.isActive = true
                
            case .assistedBy:
                
                addingAssistant = true
                searchController.isActive = true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] () -> Void in
                    self?.searchBar.becomeFirstResponder()
                }
                
            case .dedication:
                
                addingDedication = true
                let cell = tableView.cellForRow(at: indexPath) as! NewLessonTextEntryTableViewCell
                cell.textField.isHidden = false
                cell.textField.becomeFirstResponder()
                
            case .other:
                
                addingOther = true
                let cell = tableView.cellForRow(at: indexPath) as! NewLessonTextEntryTableViewCell
                cell.textField.isHidden = false
                cell.textField.becomeFirstResponder()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? NewLessonTextEntryTableViewCell {
            cell.textField.resignFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath as NSIndexPath).row < chosenSingers.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            if (indexPath as NSIndexPath).row < chosenSingers.count {
                chosenSingers.remove(at: (indexPath as NSIndexPath).row)
            } else if tableView.cellForRow(at: indexPath)?.textLabel?.text?.hasPrefix("Song") != nil {
                chosenSong = nil
            } else {
                dedication = nil
            }
            tableView.reloadData()
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //MARK: Button actions
    
    @IBAction func donePressed(_ sender: AnyObject) {
        
        guard let minutes = minutes else { fatalError() }
        
        if minutes.managedObjectContext == nil {
            CoreDataHelper.managedContext.refresh(minutes, mergeChanges: true)
        }
        
        let lesson = NSEntityDescription.insertNewObject(forEntityName: "Lesson", into: minutes.managedObjectContext!) as! Lesson
        lesson.date = Date()
        lesson.minutes = minutes
        
        if let song = chosenSong {
            lesson.song = song
        }
        
        lesson.leader = NSOrderedSet(array: chosenSingers)
        
        // optional stuff
        lesson.dedication = dedication
        lesson.otherEvent = otherEvent
        
        minutes.singers.addObjects(from: chosenSingers)
        
        TwitterShareHelper.sharedHelper.postLesson(lesson)
        
        CoreDataHelper.sharedHelper.saveContext()
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: fancy getters & setters
    
    lazy var singers:[Singer] = {
        
        guard let allSingers = CoreDataHelper.sharedHelper.singersInCurrentGroup()?.sorted(by: { (s1:Singer, s2:Singer) -> Bool in
            return s1.lastSingDate > s2.lastSingDate // overall, most recent first
        }) else { return [] }
        
        let todaySingers = allSingers.filter({ (s:Singer) -> Bool in
            return s.lastSingDate > yesterday.timeIntervalSince1970
        }).sorted(by: { (s1:Singer, s2:Singer) -> Bool in
            return s1.lastSingDate < s2.lastSingDate // of people who have sung today, go in reverse order
        })
        
        let singersFromLastWeekButNotToday = allSingers.filter({ (s:Singer) -> Bool in
            return todaySingers.index(of: s) == nil && s.lastSingDate > lastWeekPlusOneDay
        })
        
        let allOtherSingers = allSingers.filter({ (s:Singer) -> Bool in
            return todaySingers.index(of: s) == nil && singersFromLastWeekButNotToday.index(of: s) == nil
        })
        
        return singersFromLastWeekButNotToday + todaySingers + allOtherSingers
    }()
    
    lazy var songs:[Song] = {
        let bookTitle = Defaults.currentlySelectedBookTitle
        return CoreDataHelper.sharedHelper.songs(bookTitle)
    }()
    
    var searchingSongs:Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.searchSongs.rawValue }
        set {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.searchSongs.rawValue }
        }
    }
    
    var searchingSingers:Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.searchLeaders.rawValue }
        set {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.searchLeaders.rawValue }
        }
    }
    
    var addingAssistant:Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.assistedBy.rawValue }
        set {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.assistedBy.rawValue }
        }
    }
    
    var addingDedication:Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.dedication.rawValue }
        set {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.dedication.rawValue }
        }
    }
    
    var addingOther:Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.other.rawValue }
        set {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.other.rawValue }
        }
    }
}




