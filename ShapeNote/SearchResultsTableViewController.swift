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
        
//        tableView.registerClass(SongListTableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        tableView.registerNib(UINib(nibName: "SongListTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SongListTableViewCell
        let song = results![indexPath.row]
        cell.configureWithSong(song)
        
        return cell
    }
}