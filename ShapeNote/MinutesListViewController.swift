//
//  MinutesListViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

let tableViewHeaderHeight:CGFloat = 94
let tableViewRowHeight:CGFloat = 44

class MinutesListViewController: UITableViewController {

    @IBOutlet weak private var minutesListTableView: UITableView!
    @IBOutlet fileprivate var noMinutesYetView: UIView!
    
    static let dateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.timeStyle = .none
        d.dateStyle = .full
        return d
    }()
    
    private var _allMinutes:[Minutes]?
    fileprivate var allMinutes:[Minutes] {
        get {
            if _allMinutes == nil {
                
                guard let group = CoreDataHelper.sharedHelper.currentlySelectedGroup else {
                    return []
                }
                
                navigationItem.title = group.name + ": Minutes"
                if let m = CoreDataHelper.sharedHelper.minutes(group) {
                    
                    _allMinutes = m.sorted { (a:Minutes, b:Minutes) -> Bool in
                        return a.date.timeIntervalSince1970 > b.date.timeIntervalSince1970
                    }
                }
            }
            return _allMinutes!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        _allMinutes = nil
        self.tableView.reloadData()
        
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
        self.navigationController?.pushViewController(minutesViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewRowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewHeaderHeight
    }
}

// MARK: Navigation
extension MinutesListViewController {

    @IBAction func newMinutesButtonPressed(_ sender: UIButton) {
        
        if let _ = CoreDataHelper.sharedHelper.currentlySelectedGroup,
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MinuteTakingViewController") {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let mtvc = segue.destination as? MinuteTakingViewController, mtvc.minutes == nil {
            mtvc.minutes = NSEntityDescription.insertNewObject(forEntityName: "Minutes", into: CoreDataHelper.managedContext) as? Minutes
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
        let minutesViewController = self.storyboard?.instantiateViewController(withIdentifier: "MinuteTakingViewController") as! MinuteTakingViewController
        minutesViewController.minutes = m
        
        return minutesViewController
    }
}
