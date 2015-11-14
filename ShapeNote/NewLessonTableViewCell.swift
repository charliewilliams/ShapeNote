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
    @IBOutlet var textField: UITextField!
    @IBOutlet var addButton: UIButton!
    
    var parentTableViewController:NewLessonViewController? {
        didSet {
            if parentTableViewController != nil {
                addButton?.addTarget(parentTableViewController, action: "addSingerTapped:", forControlEvents: .TouchUpInside)
            }
        }
    }

    override var detailTextLabel: UILabel! {
        return rightTextLabel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let rightTextLabel = rightTextLabel {
            rightTextLabel.text = nil
        }
        if let textField = textField {
            textField.placeholder = nil
        }
        addButton?.hidden = true
    }
}