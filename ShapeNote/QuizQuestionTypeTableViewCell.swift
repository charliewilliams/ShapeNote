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
    
    var questionType:QuizOption?
    
    @IBAction func selectionButtonPressed(sender: UIButton) {
        self.selected = !self.selected
        
        guard let questionType = questionType else { fatalError() }
        
        if !self.selected {
            selectionButton.setTitle("O", forState: .Normal)
            QuizQuestionProvider.sharedProvider.selectedQuestions.remove(questionType)
            
            print(QuizQuestionProvider.sharedProvider.selectedQuestions)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard let questionType = questionType else { fatalError() }
        
        if selected {
            selectionButton.setTitle("X", forState: .Normal)
            QuizQuestionProvider.sharedProvider.selectedQuestions.insert(questionType)
        }
    }

}
