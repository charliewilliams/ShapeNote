//
//  MinuteTakingViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData
import Social

class MinuteTakingViewController: UITableViewController {
    
    @IBOutlet weak var minutesTableView: UITableView!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    var minutes:Minutes? // the minutes object, which is a collection of lessons
    var _lessons:[Lesson]?
    var lessons:[Lesson]? { // all of the lessons from the minutes object
        get {
            
            if minutes == nil {
                minutes = NSEntityDescription.insertNewObject(forEntityName: "Minutes", into: CoreDataHelper.managedContext) as? Minutes
                minutes?.book = CoreDataHelper.sharedHelper.currentlySelectedBook
                CoreDataHelper.sharedHelper.saveContext()
            }
            
            if _lessons == nil {
                
                var templessons = [Lesson]()
                if let loadedArray:NSOrderedSet = minutes?.songs {
                    
                    loadedArray.forEach { (lesson:Any) in
                        
                        if let lesson = lesson as? Lesson {
                            templessons.append(lesson)
                        }
                    }
                    _lessons = templessons.sorted(by: { (first:Lesson, second:Lesson) -> Bool in
                        return first.date.timeIntervalSince1970 > second.date.timeIntervalSince1970
                    })
                }
            }
            return _lessons
        }
    }
    
    func setNeedsReload() {
        _lessons = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        
        if let date = minutes?.date {
            navigationItem.title = "Minutes: " + dateFormatter.string(from: date as Date)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        setNeedsReload() //?
        minutesTableView.reloadData()
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
    
        minutes?.complete = true
        CoreDataHelper.sharedHelper.saveContext()
        let shareVC = FacebookShareViewController()

        let alert = UIAlertController(title: "Post to Facebook?", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Post", style: .default) { (action:UIAlertAction) -> Void in
            
            shareVC.minutes = self.minutes!
            self.present(shareVC, animated: true, completion: {
                let _ = self.navigationController?.popViewController(animated: false)
            })
        }
        let cancel = UIAlertAction(title: "Don't post", style: .cancel) { (cancel:UIAlertAction!) -> Void in
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(cancel) // first
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let lessons = lessons {
            doneButton.isEnabled = true
            return lessons.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            
        if let lessons = lessons, lessons.count > indexPath.row {
            let lesson = lessons[indexPath.row]
            var string = lesson.song.number + " " + lesson.song.title + " – " + lesson.allLeadersString(useTwitterHandles: false)
            if let dedication = lesson.dedication {
                string += " (\(dedication))"
            }
            if let otherEvent = lesson.otherEvent {
                string = otherEvent
            }
            cell.textLabel?.text = string
            cell.detailTextLabel?.text = dateFormatter.string(from: lesson.date as Date)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: Header for new lesson
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if minutes?.complete == true {
            return nil
        }
        return tableView.dequeueReusableCell(withIdentifier: "HeaderCell")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if minutes?.complete == true {
            return 0
        }
        return tableViewHeaderHeight
    }
    
    
    // MARK: Navigation
    
    override func didMove(toParentViewController parent: UIViewController?) {
        
        if let minutes = minutes, parent == nil && minutes.songs.count == 0 {
            CoreDataHelper.managedContext.delete(minutes)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? NewLessonViewController {
            destinationVC.minutes = minutes
        }
    }
}
