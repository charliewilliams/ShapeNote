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
    var questionType:QuizOption! {
        didSet {
            label.text = questionType.itemStringForQuestionPair
        }
    }
    var parentTableViewController:QuizSetupViewController!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionButton.setTitle(" ", for: UIControlState())
    }
    
    @IBAction func selectionButtonPressed(_ sender: UIButton) {
        self.isSelected = !_selected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
        
        guard let questionType = questionType else { fatalError() }
        
        if selected {
            selectionButton.setTitle(checkmark, for: UIControlState())
            QuizQuestionProvider.sharedProvider.selectedQuestions.insert(questionType)
            parentTableViewController.didChangeSelection()
        } else if !selected && _selected {
            selectionButton.setTitle(" ", for: UIControlState())
            QuizQuestionProvider.sharedProvider.selectedQuestions.remove(questionType)
            parentTableViewController.didChangeSelection()
        }
        
        _selected = selected
    }
}
