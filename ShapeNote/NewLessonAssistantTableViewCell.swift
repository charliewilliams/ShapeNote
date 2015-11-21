//
//  NewLessonAssistantTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 14/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class NewLessonAssistantTableViewCell: UITableViewCell {

    
    @IBOutlet var leftTextLabel: UILabel!
    @IBOutlet var rightTextLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        addButton.hidden = true
    }
}
