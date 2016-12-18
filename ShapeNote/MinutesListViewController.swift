//
//  MinutesListViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

let tableViewHeaderHeight: CGFloat = 124
let tableViewRowHeight: CGFloat = 44

class MinutesListViewController: UITableViewController {

    @IBOutlet weak private var minutesListTableView: UITableView!
    @IBOutlet fileprivate var noMinutesYetView: UIView!
    
    static let dateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.timeStyle = .none
        d.dateStyle = .full
        return d
    }()
    
    fileprivate var _allMinutes: [Minutes]?
    fileprivate var allMinutes: [Minutes] {
        if _allMinutes == nil {
            
            guard let group = CoreDataHelper.sharedHelper.currentlySelectedGroup else {
                return []
            }
            
            navigationItem.title = group.name + ": Minutes"
            if let m = CoreDataHelper.sharedHelper.minutes(group) {
                _allMinutes = m.filter({ $0.songs.count > 0 }).sorted { $0.date > $1.date }
            }
        }
        return _allMinutes!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _allMinutes = nil
        tableView.reloadData()
        
        updateNoMinutesView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CoreDataHelper.sharedHelper.currentlySelectedGroup == nil || Defaults.currentGroupName == nil {
            showGroupSelectionUI()
        } else {
            updateNoMinutesView()
        }
    }
}

// MARK: - Table view data source
extension MinutesListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMinutes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MinutesTableViewCell
        
        let minute = allMinutes[indexPath.row]
        cell.configureWithMinutes(minute, dateFormatter: MinutesListViewController.dateFormatter)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "HeaderCell")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let minutesViewController = minuteTakingViewControllerForIndexPath(indexPath)
        navigationController?.pushViewController(minutesViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete, indexPath.row < allMinutes.count else { return }
        
        tableView.beginUpdates()
        
        var minutes = allMinutes
        let toDelete = minutes.remove(at: indexPath.row)
        
        CoreDataHelper.sharedHelper.managedObjectContext?.delete(toDelete)
        
        _allMinutes = minutes
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete minutes"
    }
}

// MARK: Navigation
extension MinutesListViewController {

    @IBAction func newMinutesButtonPressed(_ sender: UIButton) {
        
        if let _ = CoreDataHelper.sharedHelper.currentlySelectedGroup,
            let vc = storyboard?.instantiateViewController(withIdentifier: "MinuteTakingViewController") {
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let mtvc = segue.destination as? MinuteTakingViewController, mtvc.minutes == nil {
            mtvc.minutes = Minutes()
            mtvc.minutes?.book = CoreDataHelper.sharedHelper.currentlySelectedBook
            CoreDataHelper.sharedHelper.saveContext()
        }
    }
}

private extension MinutesListViewController {
    
    func updateNoMinutesView() {
        
        if allMinutes.count > 0 {
            noMinutesYetView.isHidden = true
            tableView.isScrollEnabled = true
        } else {
            tableView.isScrollEnabled = false
            noMinutesYetView.isHidden = false
            var height = UIScreen.main.bounds.size.height
            height -= UIApplication.shared.statusBarFrame.height
            height -= tableViewHeaderHeight
            if let navBarHeight = navigationController?.navigationBar.bounds.size.height,
                let tabBarHeight = tabBarController?.tabBar.bounds.size.height {
                height -= navBarHeight + tabBarHeight
            }
            
            noMinutesYetView.bounds.size.height = height
        }
    }
    
    func showGroupSelectionUI() {
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "GroupSelectionTableViewController") as! GroupSelectionTableViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func minuteTakingViewControllerForIndexPath(_ indexPath:IndexPath) -> MinuteTakingViewController {
        
        let m = allMinutes[indexPath.row]
        let minutesViewController = storyboard?.instantiateViewController(withIdentifier: "MinuteTakingViewController") as! MinuteTakingViewController
        minutesViewController.minutes = m
        
        return minutesViewController
    }
}
