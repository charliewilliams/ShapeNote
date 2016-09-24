//
//  SongListTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
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
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SongListTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
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
    
    override func viewWillAppear(_ animated: Bool) {
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
                case .unfavorited:
                    return !song.favorited
                case .favorited:
                    return song.favorited
                case .fugue:
                    return song.type == "Fugue"
                case .plain:
                    return song.type == "Plain"
                case .major:
                    return song.key == "Major"
                case .minor:
                    return song.key == "Minor"
                case .duple:
                    return song.isDuple
                case .triple:
                    return song.isTriple
                case .notes:
                    return song.notes?.characters.count > 0
                case .noNotes:
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {

        let searchResults = songs
        
        let fullSearchText = searchController.searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        let searchItems = fullSearchText.components(separatedBy: " ") as [String]
        
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
                let searchComparisonPredicate = NSComparisonPredicate(leftExpression: expression, rightExpression: searchStringExpression, modifier: .direct, type: .contains, options: .caseInsensitive)
                searchItemsPredicate.append(searchComparisonPredicate)
            }
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .none
            numberFormatter.formatterBehavior = .default
            
            let targetNumber = numberFormatter.number(from: searchString)
            if targetNumber != nil {

                let targetNumberExpression = NSExpression(forConstantValue: targetNumber!)
                
                // search by year
                let yearSearchExpression = NSExpression(forKeyPath: "year")
                let yearPredicate = NSComparisonPredicate(leftExpression: yearSearchExpression, rightExpression: targetNumberExpression, modifier: .direct, type: .equalTo, options: .caseInsensitive)
                searchItemsPredicate.append(yearPredicate)
            }
            
            // Add this OR predicate to our master AND predicate.
            let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate)
            
            return orMatchPredicate
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }
        
        // Hand over the filtered results to our search results table.
        let resultsController = searchController.searchResultsController as! SearchResultsTableViewController
        resultsController.results = filteredResults
        resultsController.tableView.reloadData()
    }

    
    // MARK: - Table view data source
    
    var filtering:Bool {
        return activeFilters.count > 0 || popularityFilter != nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (filtering) {
            return filteredSongs.count
        }
        return songs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongListTableViewCell
        let song:Song
        if (filtering) {
            song = filteredSongs[(indexPath as NSIndexPath).row]
        } else {
            song = songs[(indexPath as NSIndexPath).row]
        }
        cell.configureWithSong(song)
        cell.songListTableView = self.tableView

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        if let selectedIndexPath = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: selectedIndexPath) as? SongListTableViewCell,
            let destinationVC = segue.destination as? NotesViewController, identifier == "showNotes" {
                destinationVC.song = cell.song
        }
        if let destinationVC = segue.destination as? FiltersViewController, identifier == "editFilters" {
            destinationVC.songListViewController = self
        }
    }
}
