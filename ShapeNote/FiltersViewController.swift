//
//  FiltersViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {
    
    var songListViewController: SongListTableViewController?
    
    @IBOutlet weak var favoritedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var majorMinorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var plainFugueSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dupleTripleSegmentedControl: UISegmentedControl!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let filters = songListViewController?.activeFilters else { return }
        for filter in filters {
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
            }
        }
    }
    
    func add(toAdd:FilterType, remove toRemove:FilterType) {
        guard var filters = songListViewController?.activeFilters else { return }
        if let index = filters.indexOf(toRemove) { filters.removeAtIndex(index) }
        filters.append(toRemove)
        songListViewController?.activeFilters = filters
    }
    
    func remove(toRemove:[FilterType]) {
        guard var filters = songListViewController?.activeFilters else { return }
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
    }

    @IBAction func doneBarButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func donePressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
