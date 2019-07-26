//
//  BookPickerTableViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 10/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import Crashlytics

class BookPickerTableViewController: UITableViewController {
    
    var _books:[Book]?
    var books:[Book]? {
        get {
            if _books == nil {
                _books = CoreDataHelper.sharedHelper.books()
            }
            return _books
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 

        if let b = books {
            let book = b[indexPath.row]
            cell.textLabel?.text = book.title
            cell.detailTextLabel?.text = book.hashTag
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let cell = tableView.cellForRow(at: indexPath),
            let title = cell.textLabel?.text {
            
            Defaults.currentlySelectedBookTitle = title
            
//            print("Switched book to \(title)")
            Answers.logCustomEvent(withName: "Switched book", customAttributes: ["title":title])
            
        }
        
        _ = self.navigationController?.popViewController(animated: true)
    }
}
