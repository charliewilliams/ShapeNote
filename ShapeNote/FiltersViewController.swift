//
//  FiltersViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

enum FilterType {
    case Unfavorited
    case Favorited
    case Fugue
    case Plain
    case Major
    case Minor
    case Duple
    case Triple
    case Notes
    case NoNotes
}

enum PopularityFilterType:Int {
    case Top10Pct = 0
    case Top20Pct
    case Top50Pct
    case Bottom50Pct
    case Bottom20Pct
}

class FiltersViewController: UIViewController {
    
    var songListViewController: SongListTableViewController!
    @IBOutlet var filteredSongsCountLabel: UILabel!
    
    @IBOutlet weak var favoritedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var majorMinorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var plainFugueSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dupleTripleSegmentedControl: UISegmentedControl!
    @IBOutlet var notesSegmentedControl: UISegmentedControl!
    @IBOutlet var popularitySegmentedControl: UISegmentedControl!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        for filter in songListViewController.activeFilters {
            switch filter {
            case .Unfavorited:
                favoritedSegmentedControl.selectedSegmentIndex = 2
            case .Favorited:
                favoritedSegmentedControl.selectedSegmentIndex = 0
            case .Fugue:
                plainFugueSegmentedControl.selectedSegmentIndex = 2
            case .Plain:
                plainFugueSegmentedControl.selectedSegmentIndex = 0
            case .Major:
                majorMinorSegmentedControl.selectedSegmentIndex = 0
            case .Minor:
                majorMinorSegmentedControl.selectedSegmentIndex = 2
            case .Duple:
                dupleTripleSegmentedControl.selectedSegmentIndex = 0
            case .Triple:
                dupleTripleSegmentedControl.selectedSegmentIndex = 2
            case .Notes:
                notesSegmentedControl.selectedSegmentIndex = 0
            case .NoNotes:
                notesSegmentedControl.selectedSegmentIndex = 2
            }
        }
        if let popularityFilter = songListViewController.popularityFilter {
            popularitySegmentedControl.selectedSegmentIndex = popularityFilter.rawValue
        }
        updateCount()
    }
    
    func add(toAdd:FilterType, remove toRemove:FilterType) {
        var filters = songListViewController.activeFilters
        if let index = filters.indexOf(toRemove) { filters.removeAtIndex(index) }
        filters.append(toAdd)
        songListViewController?.activeFilters = filters
    }
    
    func remove(toRemove:[FilterType]) {
        var filters = songListViewController.activeFilters
        for filter in toRemove {
            if let index = filters.indexOf(filter) { filters.removeAtIndex(index) }
        }
        songListViewController?.activeFilters = filters
    }

    @IBAction func favoriteStatusChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.Favorited, remove: .Unfavorited)
        case 1:
            remove([.Favorited, .Unfavorited])
        case 2:
            add(.Unfavorited, remove: .Favorited)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }
    
    @IBAction func majorMinorStatusChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.Major, remove: .Minor)
        case 1:
            remove([.Major, .Minor])
        case 2:
            add(.Minor, remove: .Major)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }

    @IBAction func plainFugueStatusChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.Plain, remove: .Fugue)
        case 1:
            remove([.Plain, .Fugue])
        case 2:
            add(.Fugue, remove: .Plain)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }

    @IBAction func dupleTripleStatusChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.Duple, remove: .Triple)
        case 1:
            remove([.Duple, .Triple])
        case 2:
            add(.Triple, remove: .Duple)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }
    
    @IBAction func notesStatusChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.Notes, remove: .NoNotes)
        case 1:
            remove([.Notes, .Notes])
        case 2:
            add(.Notes, remove: .Notes)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }
    
    @IBAction func popularityStatusChanged(sender: UISegmentedControl) {
        // "All" makes a nil filter
        songListViewController.popularityFilter = PopularityFilterType(rawValue: sender.selectedSegmentIndex)
        updateCount()
    }
    
    func updateCount() {
        guard let tableView = self.songListViewController?.tableView else { return }
        tableView.reloadData()
        let count = tableView.numberOfRowsInSection(0)
        self.filteredSongsCountLabel.text = "\(count) songs"
    }
    
    @IBAction func doneBarButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func donePressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
