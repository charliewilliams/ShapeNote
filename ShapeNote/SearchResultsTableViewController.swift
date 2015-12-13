//
//  SearchResultsTableView.swift
//  ShapeNote
//
//  Created by Charlie Williams on 13/12/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class SearchResultsTableViewController : UITableViewController {
    
    var results:[Song]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(SongListTableViewCell.self, forCellReuseIdentifier: "Cell")

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 08
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let song = results![indexPath.row]
        cell.textLabel?.text = "\(song.number) — \(song.title)"
        
        return cell
    }
}