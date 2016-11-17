//
//  NewLessonTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 13/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class NewLessonTableViewCell: UITableViewCell {
    
    @IBOutlet var leftTextLabel: UILabel!
    @IBOutlet var rightTextLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    
    weak var parentTableViewController: NewLessonViewController!
    
    func configure(leftText: String, rightText: String?, hideAddButton: Bool) {
        
        leftTextLabel.text = leftText
        rightTextLabel.text = rightText
        
        // TODO support multiple singers
        addButton.isHidden = true //hideAddButton
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let rightTextLabel = rightTextLabel {
            rightTextLabel.text = nil
        }
        addButton.isHidden = true
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        parentTableViewController.searchBar.selectedScopeButtonIndex = ScopeBarIndex.searchLeaders.rawValue
        parentTableViewController.tableView.reloadData()
    }
}
