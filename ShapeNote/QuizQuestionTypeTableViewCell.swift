//
//  QuizQuestionTypeTableViewCell.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

let checkmark = "✔︎"

class QuizQuestionTypeTableViewCell: UITableViewCell {
    
    @IBOutlet var selectionButton: UIButton!
    @IBOutlet var label: UILabel!
    
    var _selected = false
    var questionType:QuizOption?
    var parentTableViewController:QuizSetupViewController?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionButton.setTitle(" ", forState: .Normal)
    }
    
    @IBAction func selectionButtonPressed(sender: UIButton) {
        self.selected = !_selected
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
        
        guard let questionType = questionType else { fatalError() }
        
        if selected {
            selectionButton.setTitle(checkmark, forState: .Normal)
            QuizQuestionProvider.sharedProvider.selectedQuestions.insert(questionType)
            parentTableViewController?.didChangeSelection()
        } else if !selected && _selected {
            selectionButton.setTitle(" ", forState: .Normal)
            QuizQuestionProvider.sharedProvider.selectedQuestions.remove(questionType)
            parentTableViewController?.didChangeSelection()
        }
        
        _selected = selected
    }
}
