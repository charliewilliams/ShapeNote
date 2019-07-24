//
//  NewLessonViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 02/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics

enum ScopeBarIndex: Int {
    case searchLeaders = 0
    case searchSongs = 1
    case assistedBy = 2
    case dedication = 3
    case other = 4
    
    var placeholderText: String {
        return [
                "enter name",
                "enter song number",
                "enter assistant's name",
                "enter dedication, i.e. \"for Sue Jones\"",
                "what's happening now?"
            ][self.rawValue]
    }
}

let minCellCount = 5

enum CellIdentifier: String {
    case leader = "Leader"
    case assistedBy = "AssistedBy"
    case dedication = "Dedication"
    case search = "SearchCell"
    case twitter = "TwitterCell"
}

typealias CellType = (reuseIdentifier:CellIdentifier, index:ScopeBarIndex)
let blueColor = UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)

class NewLessonViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITextFieldDelegate {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    var searchBar: UISearchBar!
    var searchController: UISearchController!
    var minutes: Minutes?
    var filteredSingers: [Singer]?
    var filteredSongs: [Song]?
    var chosenSingers = [Singer]()
    var chosenSong: Song?
    var dedication: String?
    var assistant: Singer?
    var otherEvent: String?
    var songs: [Song] = CoreDataHelper.sharedHelper.songs().sorted {
        $0.numberForSorting < $1.numberForSorting
    }
    lazy var singers: [Singer] = {
        
        guard let allSingers = CoreDataHelper.sharedHelper.singersInCurrentGroup()?.sorted(by: {
            $0.lastSingDate > $1.lastSingDate // overall, most recent first
        }) else {
            return []
        }
        
        let todaySingers = allSingers.filter({
            return $0.lastSingDate > yesterday.timeIntervalSince1970
        }).sorted(by: {
            return $0.lastSingDate < $1.lastSingDate // of people who have sung today, go in reverse order
        })
        
        let singersFromLastWeekButNotToday = allSingers.filter {
            return todaySingers.firstIndex(of: $0) == nil && $0.lastSingDate > lastWeekPlusOneDay
        }
        
        let allOtherSingers = allSingers.filter {
            return todaySingers.firstIndex(of: $0) == nil && singersFromLastWeekButNotToday.firstIndex(of: $0) == nil
        }
        
        return singersFromLastWeekButNotToday + todaySingers + allOtherSingers
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Answers.logContentView(withName: String(describing: self.classForCoder), contentType: nil, contentId: nil, customAttributes: ["group":Defaults.currentGroupName ?? "none"])
        
        buildSearchController()
        buildSearchBar()
        
        extendedLayoutIncludesOpaqueBars = true
        doneButton.isEnabled = false
    }
    
    func buildSearchController() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
    }
    
    func buildSearchBar() {
        
        searchBar = searchController.searchBar
        searchBar.showsScopeBar = false // annoying but setting this to true screws up the layout
        searchBar.delegate = self
        searchBar.scopeButtonTitles = ["Leader", "Song", "Assisted by", "Dedication"]
        searchBar.selectedScopeButtonIndex = ScopeBarIndex.searchLeaders.rawValue
        tableView.tableHeaderView = searchBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.isActive = true

        // TODO why is this? 
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] () -> Void in
        
            guard let searchBar = self?.searchBar else { return }
            searchBar.becomeFirstResponder()
        }
    }
}

extension NewLessonViewController {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchAndScope()
    }
    
    func filterContentForSingerSearchText(_ searchText: String) {
        
        guard searchText.count > 0 else { filteredSingers = singers; return }
        
        filteredSingers = singers.filter {
            $0.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
    }
    
    func filterContentForSongSearchText(_ searchText: String) {
        
        guard searchText.count > 0 else { filteredSongs = songs; return }
        
        filteredSongs = songs.filter {
            return $0.number.hasPrefix(searchText) || $0.number.hasPrefix("0" + searchText)
        }
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
        searchBar.keyboardType = .asciiCapable
        searchBar.placeholder = index.placeholderText
        
        switch index {
            
        case .searchLeaders:
            filteredSingers = singers
            
        case .searchSongs:
            filteredSongs = songs
            searchBar.keyboardType = .numberPad

        default:
            break
        }
        
        searchBar.reloadInputViews()
        
        let complete = (chosenSong != nil && chosenSingers.count != 0)
        doneButton.isEnabled = complete
        
        if complete {
            
            searchController.isActive = false
            
        } else {
            
            searchBar.text = ""
            searchController.isActive = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if addingDedication {
            
            dedication = textField.text
            
        } else if addingOther {
            
            otherEvent = textField.text
            if let otherEvent = otherEvent, otherEvent.count > 0 {
                doneButton.isEnabled = true
            } else if chosenSong == nil || chosenSingers.count == 0 {
                doneButton.isEnabled = false
            }
            
        } else if let newSingerName = textField.text {
            
            let newSinger = Singer()
            
            var components = newSingerName.components(separatedBy: .whitespacesAndNewlines)
            newSinger.firstName = components.first
            if components.count > 1 {
                components.remove(at: 0)
                newSinger.lastName = components.joined(separator: " ")
            }
            singers.append(newSinger)
            chosenSingers.append(newSinger)
            CoreDataHelper.sharedHelper.saveContext()
            searchingSingers = false
            searchController.isActive = false
            updateSearchAndScope()
        }
        
        textField.resignFirstResponder()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return true
    }
}

//MARK: TableView
extension NewLessonViewController {

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
        
        if let singerCell = cell as? NewLessonTableViewCell {
            singerCell.parentTableViewController = self
        }
        cell.textLabel?.textColor = UIColor.black

        if searchController.isActive {

            if searchingSongs {
                
                let song = filteredSongs![indexPath.row]
                let rawNumber = song.number
                let number = rawNumber.hasPrefix("0") ? rawNumber.substring(from: rawNumber.index(rawNumber.startIndex, offsetBy: 1)) : rawNumber
                cell.textLabel?.text = number + " " + song.title
                
            } else if let filteredSingers = filteredSingers, indexPath.row < filteredSingers.count {
                
                let singer = filteredSingers[indexPath.row]
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
        case .searchLeaders,
             .searchSongs:
            return 70
        case .assistedBy,
             .dedication:
            return 44
        case .other:
            return 88
        }
    }
    
    func identifierForCellAtIndexPath(_ indexPath:IndexPath) -> String {
        
        if searchController.isActive { return "SearchCell" }
        
        let index = adjustedIndexForIndexPath(indexPath)
        switch index {
        case .searchLeaders: fallthrough
        case .searchSongs:
            return CellIdentifier.leader.rawValue
        case .assistedBy:
            return CellIdentifier.assistedBy.rawValue
        case .dedication: fallthrough
        case .other:
            return CellIdentifier.dedication.rawValue
        }
    }
    
    func adjustedIndexForIndexPath(_ indexPath:IndexPath) -> ScopeBarIndex {
        
        let numberOfSingers = chosenSingers.count
        if indexPath.row < numberOfSingers || (numberOfSingers <= 1 && indexPath.row == 0) {
            return ScopeBarIndex.searchLeaders
        }
        let adjustment = numberOfSingers > 0 ? numberOfSingers - 1 : 0
        return ScopeBarIndex(rawValue: indexPath.row - adjustment)!
    }
    
    func configureCell(_ cell: UITableViewCell, forIndexPath indexPath: IndexPath) {
        
        let type = adjustedIndexForIndexPath(indexPath)
        cell.textLabel?.textColor = blueColor
        
        switch type {
            
        case .searchLeaders:
            let singerCell = cell as! NewLessonTableViewCell
            let singerName = indexPath.row < chosenSingers.count ? chosenSingers[indexPath.row].name : ""
            let hideAddButton = chosenSingers.count > 0 && indexPath.row == chosenSingers.count
            
            singerCell.configure(leftText: "Leader", rightText: singerName, hideAddButton: hideAddButton)
            
        case .searchSongs:
            let songCell = cell as! NewLessonTableViewCell
            
            songCell.configure(leftText: "Song", rightText: chosenSong?.title, hideAddButton: true)
            
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
            cell.leftTextLabel?.text = "Other Event\n(own composition,\nmemorial lesson,\netc.)"
            cell.leftTextLabel.numberOfLines = 0
            cell.leftTextLabel.font = UIFont.systemFont(ofSize: 10)
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
            
            tableViewDidSelect(rowForSearchAtIndexPath: indexPath)
            
        } else {
            
            tableViewDidSelect(nonSearchRowAtIndexPath: indexPath)
        }
    }
    
    private func tableViewDidSelect(rowForSearchAtIndexPath indexPath: IndexPath) {
        
        let index = indexPath.row
        
        if searchingSongs {
            
            chosenSong = filteredSongs![index]
            
            if chosenSingers.count == 0 {
                searchingSingers = true
            }
            
        } else if let filteredSingers = filteredSingers, searchingSingers == true && index < filteredSingers.count {
            
            let singer = filteredSingers[index]
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
    }
    
    private func tableViewDidSelect(nonSearchRowAtIndexPath indexPath: IndexPath) {
        
        guard let item = ScopeBarIndex(rawValue: indexPath.row) else { fatalError() }
        
        switch item {
        case .searchSongs:
            searchingSongs = true
            searchController.isActive = true
            
        case .searchLeaders:
            
            if indexPath.row < chosenSingers.count {
                chosenSingers.remove(at: indexPath.row)
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
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? NewLessonTextEntryTableViewCell {
            cell.textField.resignFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < chosenSingers.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            if indexPath.row < chosenSingers.count {
                chosenSingers.remove(at: indexPath.row)
            } else if let cell = tableView.cellForRow(at: indexPath),
                let text = cell.textLabel?.text, text.hasPrefix("Song") {
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
}

//MARK: Button actions
extension NewLessonViewController {
    
    @IBAction func donePressed(_ sender: AnyObject) {
        
        defer {
            _ = navigationController?.popViewController(animated: true)
        }
        
        guard let minutes = self.minutes,
            let song = chosenSong else {
                return
        }
        
        if minutes.managedObjectContext == nil {
            CoreDataHelper.managedContext.refresh(minutes, mergeChanges: true)
        }
        
        // optional stuff
        // A bit hacky here with the magic numbers…
        let dedicationCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! NewLessonTextEntryTableViewCell
        let otherEventcell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! NewLessonTextEntryTableViewCell
        
        let dedication = dedicationCell.textField.text
        let otherEvent = otherEventcell.textField.text
        //
        
        let lesson = Lesson(song: song, minutes: minutes, leaders: chosenSingers, dedication: dedication, otherInfo: otherEvent)
        
        
        minutes.singers.addObjects(from: chosenSingers)
        
        TwitterShareHelper.postLesson(lesson)
        
        CoreDataHelper.sharedHelper.saveContext()
    }
}

//MARK: fancy getters & setters
extension NewLessonViewController {
    
    var searchingSongs: Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.searchSongs.rawValue }
        set(newValue) {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.searchSongs.rawValue }
        }
    }
    
    var searchingSingers: Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.searchLeaders.rawValue }
        set(newValue) {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.searchLeaders.rawValue }
        }
    }
    
    var addingAssistant: Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.assistedBy.rawValue }
        set(newValue) {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.assistedBy.rawValue }
        }
    }
    
    var addingDedication: Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.dedication.rawValue }
        set(newValue) {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.dedication.rawValue }
        }
    }
    
    var addingOther: Bool {
        get { return searchBar.selectedScopeButtonIndex == ScopeBarIndex.other.rawValue }
        set(newValue) {
            if newValue { searchBar.selectedScopeButtonIndex = ScopeBarIndex.other.rawValue }
        }
    }
}




