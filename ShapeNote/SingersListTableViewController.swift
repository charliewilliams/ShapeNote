//
//  SingersListTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

class SingersListTableViewController: UITableViewController {

    var singers:[Singer] {
        let s:[Singer] = CoreDataHelper.sharedHelper.singers() as [Singer]
        let sortedSingers = s.sort { (a:Singer, b:Singer) -> Bool in
            
//            // group by voice type
//            if (a.voice == b.voice) {
                return a.name < b.name
//            } else {
//                return a.voice < b.voice
//            }
        }
        return sortedSingers
    }
    
    @IBOutlet var noSingersYetView: UIView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
        updateNoSingersView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        TabBarManager.sharedManager.clearSingersTab()
    }
    
    func updateNoSingersView() {
        
        if singers.count > 0 {
            noSingersYetView.hidden = true
            tableView.scrollEnabled = true
        } else {
            noSingersYetView.hidden = false
            tableView.scrollEnabled = false
            var height = UIScreen.mainScreen().bounds.size.height
            height -= UIApplication.sharedApplication().statusBarFrame.height
            if let navBarHeight = navigationController?.navigationBar.bounds.size.height,
                let tabBarHeight = tabBarController?.tabBar.bounds.size.height {
                    height -= navBarHeight + tabBarHeight
            }
            
            noSingersYetView.hidden = false
            noSingersYetView.bounds.size.height = height
        }
    }
    
    @IBAction func changeGroupButtonPressed(sender: UIBarButtonItem) {
        
        let pickerVC = GroupsPickerViewController(nibName:"GroupsPickerViewController", bundle: nil)
        self.presentViewController(pickerVC, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        let singer = singers[indexPath.row]
        if let firstName = singer.firstName {
            if let lastName = singer.lastName {
                cell.textLabel?.text = "\(firstName) \(lastName)"
            } else {
                cell.textLabel?.text = firstName
            }
        } else {
            cell.textLabel?.text = "(#Error in Core Data — swipe left to delete this row)"
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {

            let s = singers[indexPath.row]
            CoreDataHelper.managedContext.deleteObject(s)
            CoreDataHelper.sharedHelper.saveContext()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    // MARK: - Navigation
    
    @IBAction func loginToFacebookButtonPressed(sender: UIButton) {
        
        let loginModalViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
        self.presentViewController(loginModalViewController, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let dvc:UIViewController = segue.destinationViewController 
        
        if let svc = dvc as? SingerViewController {

            if let indexPath = tableView.indexPathForSelectedRow {
                let s = singers[indexPath.row]
                svc.singer = s
            }
        }
    }

}
