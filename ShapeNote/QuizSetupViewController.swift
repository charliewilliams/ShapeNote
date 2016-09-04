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
        goTakeQuizButton.isEnabled = false
    }
    
    @IBAction func showAllButtonPressed(_ sender: UIBarButtonItem) {
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
            goTakeQuizButton.isEnabled = true
        } else {
            goTakeQuizButton.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? QuizQuestionTypeTableViewCell else { fatalError() }
        
        cell.parentTableViewController = self
        
        let questionType = quizQuestionProvider.questionTypes[(indexPath as NSIndexPath).section]
        guard let questionsForType = quizQuestionProvider.quizOptions[questionType] else { fatalError() }
        let q = questionsForType[(indexPath as NSIndexPath).row]
        cell.questionType = q
        let description = q.itemStringForQuestionPair
        cell.label.text = description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let headerView = view as? UITableViewHeaderFooterView {
            
            headerView.contentView.backgroundColor = blueColor
            headerView.textLabel?.textColor = UIColor.white
            headerView.textLabel?.text = "Given the \(quizQuestionProvider.questionTypes[section])…"
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UITableViewHeaderFooterView()
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let questionType = quizQuestionProvider.questionTypes[section]
        guard let questionsForType = quizQuestionProvider.quizOptions[questionType] else { fatalError() }
        return questionsForType.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return quizQuestionProvider.quizOptions.count
    }


}
