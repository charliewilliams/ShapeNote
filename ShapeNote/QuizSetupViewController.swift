//
//  QuizSetupViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class QuizSetupViewController: UITableViewController {
    
    @IBOutlet var showAllButton: UIBarButtonItem!
    @IBOutlet var goTakeQuizButton: UIBarButtonItem!

    let quizQuestionProvider = QuizQuestionProvider.sharedProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goTakeQuizButton.enabled = false
    }
    
    @IBAction func showAllButtonPressed(sender: UIBarButtonItem) {
        quizQuestionProvider.filtering = !quizQuestionProvider.filtering
        
        if quizQuestionProvider.filtering {
            showAllButton.title = "Show All"
        } else {
            showAllButton.title = "Popular"
        }
        
        tableView.reloadData()
    }
    
    func didChangeSelection() {
        
        if quizQuestionProvider.selectedQuestions.count > 0 {
            goTakeQuizButton.enabled = true
        } else {
            goTakeQuizButton.enabled = false
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? QuizQuestionTypeTableViewCell else { fatalError() }
        
        cell.parentTableViewController = self
        
        let questionType = quizQuestionProvider.questionTypes[indexPath.section]
        guard let questionsForType = quizQuestionProvider.quizOptions[questionType] else { fatalError() }
        let q = questionsForType[indexPath.row]
        cell.questionType = q
        let description = q.itemStringForQuestionPair
        cell.label.text = description
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Given the \(quizQuestionProvider.questionTypes[section])…"
    }
        
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let questionType = quizQuestionProvider.questionTypes[section]
        guard let questionsForType = quizQuestionProvider.quizOptions[questionType] else { fatalError() }
        return questionsForType.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return quizQuestionProvider.quizOptions.count
    }


}
