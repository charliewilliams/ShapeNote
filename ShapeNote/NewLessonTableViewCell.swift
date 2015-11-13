//
//  NewLessonTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 13/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class NewLessonTableViewCell: UITableViewCell {
    
    @IBOutlet var rightTextLabel: UILabel!

    override var detailTextLabel: UILabel! {
        return rightTextLabel
    }

}
