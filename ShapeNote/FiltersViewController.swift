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

    @IBAction func favoriteStatusChanged(sender: UISegmentedControl) {
        
        guard var filters = songListViewController?.activeFilters else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            if let index = filters.indexOf(.Unfavorited) { filters.removeAtIndex(index) }
            filters.append(.Favorited)
        case 1:
            if let index = filters.indexOf(.Favorited) { filters.removeAtIndex(index) }
            if let index = filters.indexOf(.Unfavorited) { filters.removeAtIndex(index) }
        case 2:
            if let index = filters.indexOf(.Favorited) { filters.removeAtIndex(index) }
            filters.append(.Unfavorited)
        default:
            fatalError("Storyboard incorrect")
        }
        songListViewController?.activeFilters = filters
    }
    
    @IBAction func majorMinorStatusChanged(sender: UISegmentedControl) {
        
        guard var filters = songListViewController?.activeFilters else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            if let index = filters.indexOf(.Minor) { filters.removeAtIndex(index) }
            filters.append(.Major)
        case 1:
            if let index = filters.indexOf(.Major) { filters.removeAtIndex(index) }
            if let index = filters.indexOf(.Minor) { filters.removeAtIndex(index) }
        case 2:
            if let index = filters.indexOf(.Major) { filters.removeAtIndex(index) }
            filters.append(.Minor)
        default:
            fatalError("Storyboard incorrect")
        }
        songListViewController?.activeFilters = filters
    }

    @IBAction func plainFugueStatusChanged(sender: UISegmentedControl) {
        
        guard var filters = songListViewController?.activeFilters else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            if let index = filters.indexOf(.Fugue) { filters.removeAtIndex(index) }
            filters.append(.Plain)
        case 1:
            if let index = filters.indexOf(.Plain) { filters.removeAtIndex(index) }
            if let index = filters.indexOf(.Fugue) { filters.removeAtIndex(index) }
        case 2:
            if let index = filters.indexOf(.Plain) { filters.removeAtIndex(index) }
            filters.append(.Fugue)
        default:
            fatalError("Storyboard incorrect")
        }
        songListViewController?.activeFilters = filters
    }

    @IBAction func dupleTripleStatusChanged(sender: UISegmentedControl) {
        
        guard var filters = songListViewController?.activeFilters else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            if let index = filters.indexOf(.Triple) { filters.removeAtIndex(index) }
            filters.append(.Duple)
        case 1:
            if let index = filters.indexOf(.Duple) { filters.removeAtIndex(index) }
            if let index = filters.indexOf(.Triple) { filters.removeAtIndex(index) }
        case 2:
            if let index = filters.indexOf(.Duple) { filters.removeAtIndex(index) }
            filters.append(.Triple)
        default:
            fatalError("Storyboard incorrect")
        }
        songListViewController?.activeFilters = filters
    }

    @IBAction func doneBarButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func donePressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
