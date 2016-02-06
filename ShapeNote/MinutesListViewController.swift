//
//  MinutesListViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

let tableViewHeaderHeight:CGFloat = 50

class MinutesListViewController: UITableViewController {

    @IBOutlet weak var minutesListTableView: UITableView!
    @IBOutlet var noMinutesYetView: UIView!
    
    var _allMinutes:[Minutes]?
    var allMinutes:[Minutes] {
        get {
            if _allMinutes == nil {
                
                guard let group = CoreDataHelper.sharedHelper.currentlySelectedGroup else { return [] }
                    
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
    
    override func viewWillAppear(animated: Bool) {
        
        TabBarManager.sharedManager.tabBarController = tabBarController
        
        super.viewWillAppear(animated)
        
        if Defaults.isFirstRun {
            handleFirstRun()
            return
        }
        _allMinutes = nil
        self.tableView.reloadData()
        
        updateNoMinutesView()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        updateNoMinutesView()
    }
    
    func updateNoMinutesView() {
        
        if allMinutes.count > 0 {
            noMinutesYetView.hidden = true
            tableView.scrollEnabled = true
        } else {
            tableView.scrollEnabled = false
            noMinutesYetView.hidden = false
            var height = UIScreen.mainScreen().bounds.size.height
            height -= UIApplication.sharedApplication().statusBarFrame.height
            height -= tableViewHeaderHeight
            if let navBarHeight = navigationController?.navigationBar.bounds.size.height,
                let tabBarHeight = tabBarController?.tabBar.bounds.size.height {
                    height -= navBarHeight + tabBarHeight
            }
            
            noMinutesYetView.bounds.size.height = height
        }
    }
    
    func handleFirstRun() {
        let introVC = UIStoryboard(name: "Intro", bundle: nil).instantiateInitialViewController() as! IntroPopupViewController
        let _ = introVC.view
        introVC.doneButton.hidden = false
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(introVC, animated: false, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMinutes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MinutesTableViewCell
        
        let minute = allMinutes[indexPath.row]
        cell.configureWithMinutes(minute)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCellWithIdentifier("HeaderCell")
    }
    
    // MARK: - Navigation
    
    func minuteTakingViewControllerForIndexPath(indexPath:NSIndexPath) -> MinuteTakingViewController {
        
        let m = allMinutes[indexPath.row]
        let minutesViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MinuteTakingViewController") as! MinuteTakingViewController
        minutesViewController.minutes = m
        
        return minutesViewController
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let minutesViewController = minuteTakingViewControllerForIndexPath(indexPath)
        self.navigationController?.pushViewController(minutesViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewHeaderHeight
    }
    
    // MARK: Navigation
    @IBAction func newMinutesButtonPressed(sender: UIButton) {
        
        if let _ = CoreDataHelper.sharedHelper.currentlySelectedGroup,
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MinuteTakingViewController") {
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
            let vc = GroupsPickerViewController()
            self.navigationController?.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let mtvc = segue.destinationViewController as? MinuteTakingViewController where mtvc.minutes == nil {
            mtvc.minutes = NSEntityDescription.insertNewObjectForEntityForName("Minutes", inManagedObjectContext: CoreDataHelper.managedContext) as? Minutes
            mtvc.minutes?.book = CoreDataHelper.sharedHelper.currentlySelectedBook
            CoreDataHelper.sharedHelper.saveContext()
        }
    }
}
