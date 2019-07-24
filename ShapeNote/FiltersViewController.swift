//
//  FiltersViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit
import JFADoubleSlider
import Crashlytics

enum FilterType: String {
    case unfavorited
    case favorited
    case fugue
    case plain
    case major
    case minor
    case duple
    case triple
    case notes = "with notes"
    case noNotes = "without notes"
}

typealias PopularityFilterPair = (minValue:Float, maxValue:Float)

class FiltersViewController: UIViewController, JFADoubleSliderDelegate {
    
    var songListViewController: SongListTableViewController!
    @IBOutlet var filteredSongsCountLabel: UILabel!
    
    @IBOutlet weak var favoritedSegmentedControl: UISegmentedControl!
    @IBOutlet weak var majorMinorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var plainFugueSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dupleTripleSegmentedControl: UISegmentedControl!
    @IBOutlet var notesSegmentedControl: UISegmentedControl!
    @IBOutlet var popularitySlider: JFADoubleSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundImageColor
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for filter in songListViewController.activeFilters {
            switch filter {
            case .unfavorited:
                favoritedSegmentedControl.selectedSegmentIndex = 2
            case .favorited:
                favoritedSegmentedControl.selectedSegmentIndex = 0
            case .fugue:
                plainFugueSegmentedControl.selectedSegmentIndex = 2
            case .plain:
                plainFugueSegmentedControl.selectedSegmentIndex = 0
            case .major:
                majorMinorSegmentedControl.selectedSegmentIndex = 0
            case .minor:
                majorMinorSegmentedControl.selectedSegmentIndex = 2
            case .duple:
                dupleTripleSegmentedControl.selectedSegmentIndex = 0
            case .triple:
                dupleTripleSegmentedControl.selectedSegmentIndex = 2
            case .notes:
                notesSegmentedControl.selectedSegmentIndex = 0
            case .noNotes:
                notesSegmentedControl.selectedSegmentIndex = 2
            }
        }
        if let popularityFilter = songListViewController.popularityFilter {
            popularitySlider.curMaxVal = popularityFilter.maxValue
            popularitySlider.curMinVal = popularityFilter.minValue
        }
        updateCount()
    }
    
    func add(_ toAdd:FilterType, remove toRemove:FilterType) {
        var filters = songListViewController.activeFilters
        if let index = filters.firstIndex(of: toRemove) { filters.remove(at: index) }
        filters.append(toAdd)
        songListViewController?.activeFilters = filters
    }
    
    func remove(_ toRemove:[FilterType]) {
        var filters = songListViewController.activeFilters
        for filter in toRemove {
            if let index = filters.firstIndex(of: filter) { filters.remove(at: index) }
        }
        songListViewController?.activeFilters = filters
    }

    @IBAction func favoriteStatusChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.favorited, remove: .unfavorited)
        case 1:
            remove([.favorited, .unfavorited])
        case 2:
            add(.unfavorited, remove: .favorited)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }
    
    @IBAction func majorMinorStatusChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.major, remove: .minor)
        case 1:
            remove([.major, .minor])
        case 2:
            add(.minor, remove: .major)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }

    @IBAction func plainFugueStatusChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.plain, remove: .fugue)
        case 1:
            remove([.plain, .fugue])
        case 2:
            add(.fugue, remove: .plain)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }

    @IBAction func dupleTripleStatusChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.duple, remove: .triple)
        case 1:
            remove([.duple, .triple])
        case 2:
            add(.triple, remove: .duple)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }
    
    @IBAction func notesStatusChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            add(.notes, remove: .noNotes)
        case 1:
            remove([.notes, .noNotes])
        case 2:
            add(.noNotes, remove: .notes)
        default:
            fatalError("Storyboard incorrect")
        }
        updateCount()
    }
    
    func minValueChanged(_ newValue:Float) {
        
        songListViewController.popularityFilter = (minValue:newValue, maxValue:songListViewController.popularityFilter?.maxValue ?? 1.0)
        updateCount()
    }
    
    func maxValueChanged(_ newValue:Float) {
        
        songListViewController.popularityFilter = (minValue:songListViewController.popularityFilter?.minValue ?? 0.0, maxValue:newValue)
        updateCount()
    }
    
    func updateCount() {
        guard let tableView = self.songListViewController?.tableView else { return }
        tableView.reloadData()
        let count = tableView.numberOfRows(inSection: 0)
        self.filteredSongsCountLabel.text = "\(count) songs"
    }
    
    @IBAction func clearAllButtonPressed(_ sender: UIBarButtonItem) {
        remove([.unfavorited, .favorited, .fugue, .plain, .major, .minor, .duple, .triple, .notes, .noNotes])
        for slider in [favoritedSegmentedControl, majorMinorSegmentedControl, plainFugueSegmentedControl, dupleTripleSegmentedControl, notesSegmentedControl] {
            slider?.selectedSegmentIndex = 1
        }
        popularitySlider.curMinVal = 0.0
        popularitySlider.curMaxVal = 1.0
    }
    
    @IBAction func doneBarButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
