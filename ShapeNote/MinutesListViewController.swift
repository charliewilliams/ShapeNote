//
//  MinutesListViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

class MinutesListViewController: UITableViewController {

    @IBOutlet weak var minutesListTableView: UITableView!
    
    var _allMinutes:[Minutes]?
    var allMinutes:[Minutes] {
        get {
            if _allMinutes == nil {
                
                let group = CoreDataHelper.sharedHelper.currentlySelectedGroup
                    
                navigationItem.title = group.name + ": Minutes"
                if let m = CoreDataHelper.sharedHelper.minutes(group) {
                    
                    _allMinutes = m.sort { (a:Minutes, b:Minutes) -> Bool in
                        
                        return a.date.timeIntervalSince1970 > b.date.timeIntervalSince1970
                    }
                }
            }
            return _allMinutes!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _allMinutes = nil
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMinutes.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return tableView.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MinutesTableViewCell
        
        let minute = allMinutes[indexPath.row - 1]
        cell.configureWithMinutes(minute)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: - Navigation
    
    func minuteTakingViewControllerForIndexPath(indexPath:NSIndexPath?) -> MinuteTakingViewController {
        
        var m:Minutes
        if let indexPath = indexPath where indexPath.row > 0 {
            m = allMinutes[indexPath.row - 1]
        } else {
            m = NSEntityDescription.insertNewObjectForEntityForName("Minutes", inManagedObjectContext: CoreDataHelper.sharedHelper.managedObjectContext!) as! Minutes
        }

        let minutesViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MinuteTakingViewController") as! MinuteTakingViewController
        minutesViewController.minutes = m
        
        return minutesViewController
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let minutesViewController = minuteTakingViewControllerForIndexPath(indexPath)
        self.navigationController?.pushViewController(minutesViewController, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let dvc = segue.destinationViewController 
        if let mtvc = dvc as? MinuteTakingViewController {
            
            if mtvc.minutes != nil {
                return
            }
            mtvc.minutes = NSEntityDescription.insertNewObjectForEntityForName("Minutes", inManagedObjectContext: CoreDataHelper.sharedHelper.managedObjectContext!) as? Minutes
        }
    }
}
