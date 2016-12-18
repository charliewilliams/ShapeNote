//
//  MinuteTakingViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics
import MessageUI

class MinuteTakingViewController: UITableViewController {
    
    @IBOutlet weak var minutesTableView: UITableView!
    @IBOutlet var doneButton: UIBarButtonItem!
    var minutes: Minutes? // the minutes object, which is a collection of lessons
    static let shortDateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.dateStyle = .none
        d.timeStyle = .short
        return d
    }()
    fileprivate var _lessons: [Lesson]?
    fileprivate var lessons: [Lesson]? { // all of the lessons from the minutes object
        get {
            
            if minutes == nil {
                minutes = Minutes()
                minutes?.book = CoreDataHelper.sharedHelper.currentlySelectedBook
                CoreDataHelper.sharedHelper.saveContext()
            }
            
            if _lessons == nil {
                
                var tempLessons = [Lesson]()
                if let loadedArray:NSOrderedSet = minutes?.songs {
                    
                    loadedArray.forEach { (lesson:Any) in
                        
                        if let lesson = lesson as? Lesson {
                            tempLessons.append(lesson)
                        }
                    }
                    _lessons = tempLessons.sorted() { $0.date > $1.date }
                }
            }
            return _lessons
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Answers.logContentView(withName: String(describing: self.classForCoder), contentType: nil, contentId: nil, customAttributes: ["group":Defaults.currentGroupName ?? "none"])
        
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
    
    func setNeedsReload() {
        _lessons = nil
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
    
        guard let minutes = minutes else {
            _ = navigationController?.popViewController(animated: true)
            return
        }
        
        let summaryVC = MinutesSummaryViewController(minutes: minutes)
        
//        if !minutes.complete {
//                
//                minutes.complete = true
//                CoreDataHelper.sharedHelper.saveContext()
//                _ = self.navigationController?.popViewController(animated: false)
//            }
//            
//        } else {
        
            navigationController?.pushViewController(summaryVC, animated: true)
//        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension MinuteTakingViewController {

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
        
        if let lessons = lessons, indexPath.row < lessons.count {
            
            let lesson = lessons[indexPath.row]
            var string = "\(lesson.allLeadersString(useTwitterHandles: false)) – \(lesson.song.number) \(lesson.song.title)"
            
            if let otherEvent = lesson.otherEvent, otherEvent.characters.count > 0 {
                string += " \(otherEvent)"
            }
            
            if let dedication = lesson.dedication, dedication.characters.count > 0 {
                string += " (\(dedication))"
            }
            
            cell.textLabel?.text = string
            cell.detailTextLabel?.text = MinuteTakingViewController.shortDateFormatter.string(from: lesson.date as Date)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: Header for new lesson
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let minutes = minutes, minutes.complete == true {
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
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete, var lessons = lessons, indexPath.row < lessons.count else { return }
        
        tableView.beginUpdates()
        
        let toDelete = lessons.remove(at: indexPath.row)
        
        CoreDataHelper.sharedHelper.managedObjectContext?.delete(toDelete)
        
        _lessons = lessons
        
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
        return "Delete lesson"
    }
}

// MARK: Navigation
extension MinuteTakingViewController {
    
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
