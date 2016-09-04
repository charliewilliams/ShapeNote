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
        guard let s = CoreDataHelper.sharedHelper.singersInCurrentGroup() else {
            // handle no singers here!
            return [Singer]()
        }
        let sortedSingers = s.sorted { (a:Singer, b:Singer) -> Bool in
            
            if a.lastSingDate != b.lastSingDate {
                return a.lastSingDate > b.lastSingDate
            }
            return a.name < b.name
        }
        return sortedSingers
    }
    
    @IBOutlet var noSingersYetView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = Defaults.currentGroupName
        self.tableView.reloadData()
        
        updateNoSingersView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabBarManager.sharedManager.clearSingersTab()
    }
    
    func updateNoSingersView() {
        
        if singers.count > 0 {
            noSingersYetView.isHidden = true
            tableView.isScrollEnabled = true
        } else {
            noSingersYetView.isHidden = false
            tableView.isScrollEnabled = false
            var height = UIScreen.main.bounds.size.height
            height -= UIApplication.shared.statusBarFrame.height
            if let navBarHeight = navigationController?.navigationBar.bounds.size.height,
                let tabBarHeight = tabBarController?.tabBar.bounds.size.height {
                    height -= navBarHeight + tabBarHeight
            }
            
            noSingersYetView.isHidden = false
            noSingersYetView.bounds.size.height = height
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        let singer = singers[(indexPath as NSIndexPath).row]
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

            let s = singers[(indexPath as NSIndexPath).row]
            CoreDataHelper.managedContext.delete(s)
            CoreDataHelper.sharedHelper.saveContext()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let dvc:UIViewController = segue.destination 
        
        if let svc = dvc as? SingerViewController {

            if let indexPath = tableView.indexPathForSelectedRow {
                let s = singers[(indexPath as NSIndexPath).row]
                svc.singer = s
            }
        }
    }

}
