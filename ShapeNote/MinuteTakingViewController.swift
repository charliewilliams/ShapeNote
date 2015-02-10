//
//  MinuteTakingViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

class MinuteTakingViewController: UITableViewController {
    
    @IBOutlet weak var minutesTableView: UITableView!
    @IBOutlet weak var newSongButton: UIBarButtonItem!
    
    var minutes:Minutes? // the minutes object
    var _leadings:[Leading]?
    var leadings:[Leading]? { // all of the leadings from the minutes object
        get {
            
            assert(minutes != nil, "Need to have minutes set by now!")
            
            if _leadings == nil {
                
                var tempLeadings = [Leading]()
                if let loadedArray:NSOrderedSet = minutes?.songs {
                    
                    loadedArray.enumerateObjectsUsingBlock { (leading:AnyObject!, i, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                        
                        tempLeadings.append(leading as Leading)
                    }
                    _leadings = tempLeadings.sorted({ (first:Leading, second:Leading) -> Bool in
                        return first.date.timeIntervalSince1970 > second.date.timeIntervalSince1970
                    })
                }
            }
            return _leadings
        }
    }
    
    func setNeedsReload() {
        _leadings = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .MediumStyle
        
        navigationItem.title = "Minutes: " + dateFormatter.stringFromDate(NSDate())
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        setNeedsReload()
    }

    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        minutesTableView.reloadData()
    }
    
    @IBAction func newSongCalled(sender: UIBarButtonItem) {
        
        if let nvc = storyboard?.instantiateViewControllerWithIdentifier("NewLeadingViewController") as? NewLeadingViewController {
            
            nvc.minutes = minutes
            self.navigationController?.pushViewController(nvc, animated: false)
        }
    }
    
    @IBAction func donePressed(sender: UIBarButtonItem) {
        
        // save and dismiss
        CoreDataHelper.save()
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = leadings?.count {
            return count
        }
        return 0
    }
    
    // MARK: - Navigation
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("PushToShowMinutes", sender: self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .ShortStyle
            
            if let leading = leadings?[indexPath.row] {
                cell.textLabel!.text = leading.song.number + " " + leading.song.title + " – " + leading.leader.name
                cell.detailTextLabel!.text = dateFormatter.stringFromDate(leading.date)
            }
            
            return cell
    }
}
