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
        
        view.backgroundColor = backgroundImageColor
    }

    @IBAction func showAllButtonPressed(_ sender: UIBarButtonItem) {
        quizQuestionProvider.filtering = !quizQuestionProvider.filtering
        
        if quizQuestionProvider.filtering {
            showAllButton.title = "Show All"
        } else {
            showAllButton.title = "Popular"
        }
        
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.fillMode = kCAFillModeForwards
        transition.duration = 0.5
        transition.subtype = quizQuestionProvider.filtering ? kCATransitionFromTop : kCATransitionFromBottom
        self.tableView.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
        
        self.tableView.reloadData()
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
        
        cell.questionType = questionsForType[indexPath.row]
        
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33
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
