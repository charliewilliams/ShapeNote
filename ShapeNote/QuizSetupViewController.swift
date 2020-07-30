//
//  QuizSetupViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 08/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class QuizSetupViewController: UITableViewController {
    
    @IBOutlet var goTakeQuizButton: UIBarButtonItem!

    let quizQuestionProvider = QuizQuestionProvider.sharedProvider
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundImageColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
    }
    
    func didChangeSelection() {
        
        goTakeQuizButton.isEnabled = (quizQuestionProvider.selectedQuestions.count > 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? QuizQuestionTypeTableViewCell else { fatalError() }
        
        cell.parentTableViewController = self
        cell.backgroundColor = .clear
        
        let questionType = quizQuestionProvider.questionTypes[indexPath.section]
        guard let questionsForType = quizQuestionProvider.quizOptions[questionType] else { fatalError() }

        if questionsForType.count > indexPath.row {
            cell.questionType = questionsForType[indexPath.row]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! QuizHeaderView
            
        headerView.titleLabel.text = "Given the \(quizQuestionProvider.questionTypes[section])…"
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UINib(nibName: "QuizHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! QuizHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false {
            tableView.deselectRow(at: indexPath, animated: true)
            return nil
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let questionType = quizQuestionProvider.questionTypes[section]
        guard let questionsForType = quizQuestionProvider.quizOptions[questionType] else { fatalError() }
        return questionsForType.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return quizQuestionProvider.questionTypes.count
    }
}
