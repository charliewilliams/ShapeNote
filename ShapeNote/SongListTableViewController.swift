//
//  SongListTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

class SongListTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var _songs:[Song]?
    var songs:[Song] {
        get {
            if _songs != nil { return _songs! }
            
            _songs = CoreDataHelper.sharedHelper.songs()
            
            navigationItem.title = _songs!.first?.book.title
            return _songs!
        }
    }
    var activeFilters = [FilterType]()
    var popularityFilter:PopularityFilterPair?
    
    var searchController: UISearchController!
    var searchTableView: SearchResultsTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "SongListTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        searchTableView = SearchResultsTableViewController()
        searchTableView.tableView.delegate = self
        searchController = UISearchController(searchResultsController: searchTableView)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _songs = nil
        tableView.reloadData()
        tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
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
                case .Notes:
                    return song.notes?.characters.count > 0
                case .NoNotes:
                    return song.notes == nil || song.notes?.characters.count == 0
                }
            })
        }
        
        if let popularityFilter = popularityFilter {
            filteredSongs = filteredSongs.filter({ (song:Song) -> Bool in
                
                let percentage = song.popularityAsPercentOfTotalSongs(songs.count)
                return percentage <= popularityFilter.maxValue && percentage >= popularityFilter.minValue
            })
        }
        // TODO show something in the background if you've filtered out everything
        
        return filteredSongs
    }
    
    // MARK: - Pull to search
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {

        let searchResults = songs
        
        let fullSearchText = searchController.searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let searchItems = fullSearchText.componentsSeparatedByString(" ") as [String]
        
        // Build all the "AND" expressions for each value in the searchString.
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            // Each searchString creates an OR predicate for: name, yearIntroduced, introPrice.
            //
            // Example if searchItems contains "iphone 599 2007":
            //      name CONTAINS[c] "iphone"
            //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
            //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
            //
            var searchItemsPredicate = [NSPredicate]()
            
            // Below we use NSExpression represent expressions in our predicates.
            // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value).
            
            for field in ["title", "lyrics", "number", "composer", "lyricist"] {
                
                let expression = NSExpression(forKeyPath: field)
                let searchStringExpression = NSExpression(forConstantValue: searchString)
                let searchComparisonPredicate = NSComparisonPredicate(leftExpression: expression, rightExpression: searchStringExpression, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
                searchItemsPredicate.append(searchComparisonPredicate)
            }
            
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .NoStyle
            numberFormatter.formatterBehavior = .BehaviorDefault
            
            let targetNumber = numberFormatter.numberFromString(searchString)
            if targetNumber != nil {

                let targetNumberExpression = NSExpression(forConstantValue: targetNumber!)
                
                // search by year
                let yearSearchExpression = NSExpression(forKeyPath: "year")
                let yearPredicate = NSComparisonPredicate(leftExpression: yearSearchExpression, rightExpression: targetNumberExpression, modifier: .DirectPredicateModifier, type: .EqualToPredicateOperatorType, options: .CaseInsensitivePredicateOption)
                searchItemsPredicate.append(yearPredicate)
            }
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluateWithObject($0) }
        
        // Hand over the filtered results to our search results table.
        let resultsController = searchController.searchResultsController as! SearchResultsTableViewController
        resultsController.results = filteredResults
        resultsController.tableView.reloadData()
    }

    
    // MARK: - Table view data source
    
    var filtering:Bool {
        return activeFilters.count > 0 || popularityFilter != nil
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (filtering) {
            return filteredSongs.count
        }
        return songs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SongListTableViewCell
        let song:Song
        if (filtering) {
            song = filteredSongs[indexPath.row]
        } else {
            song = songs[indexPath.row]
        }
        cell.configureWithSong(song)
        cell.songListTableView = self.tableView

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
