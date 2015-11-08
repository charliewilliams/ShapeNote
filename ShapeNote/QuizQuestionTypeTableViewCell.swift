//
//  QuizQuestionTypeTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class QuizQuestionTypeTableViewCell: UITableViewCell {
    
    @IBOutlet var selectionButton: UIButton!
    @IBOutlet var label: UILabel!
    
    @IBAction func selectionButtonPressed(sender: UIButton) {
        self.selected = !self.selected
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            selectionButton.setTitle("X", forState: .Normal)
        }
    }

}
