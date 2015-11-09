//
//  NotesViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 01/11/2015.
//  Copyright © 2015 Charlie Williams. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    var song:Song?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = song?.notes
        navigationController?.navigationItem.title = song?.title
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if let song = song {
            song.notes = textView.text
            CoreDataHelper.sharedHelper.saveContext()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let song = song {
            song.notes = textView.text
            CoreDataHelper.sharedHelper.saveContext()
        }
    }
}
