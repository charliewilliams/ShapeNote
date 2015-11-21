//
//  SingerViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import CoreData

class SingerViewController: UIViewController, UITextFieldDelegate {
    
    var singer:Singer?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var homeSingingTextField: UITextField!
    @IBOutlet weak var voiceTypeTextField: UITextField!
    @IBOutlet weak var twitterHandleTextField: UITextField!
    @IBOutlet weak var tagOnFacebookSwitch: UISwitch!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "SingerViewController", bundle: nibBundleOrNil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let singer = singer else {
            title = "New Singer"
            return
        }
        
        title = singer.firstName
        if let first = singer.firstName {
            nameTextField.text = first
            if let last = singer.lastName {
                nameTextField.text = first + " " + last
            }
        }
        displayNameTextField.text = singer.firstName
        
        if singer.group?.fault == false {
            homeSingingTextField.text = singer.group?.name
        }
        
        twitterHandleTextField.text = singer.twitter
        tagOnFacebookSwitch.on = singer.facebook != nil
        voiceTypeTextField.text = singer.voice
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        
        guard let name = nameTextField.text where name.characters.count > 0 else {
            return
        }
        
        if singer == nil {
            singer = NSEntityDescription.insertNewObjectForEntityForName("Singer", inManagedObjectContext: CoreDataHelper.managedContext) as? Singer
        }
        
        guard let singer = singer else { return }
        singer.firstName = name.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).first
        singer.lastName = name.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).last
        singer.displayName = displayNameTextField.text ?? singer.firstName
        
        if let homeSingingName = homeSingingTextField.text, let group = CoreDataHelper.sharedHelper.groupWithName(homeSingingName) {
            singer.group = group
        }
        
        if let voiceType = voiceTypeTextField.text {
            singer.voice = validatedVoiceType(voiceType).rawValue
        }
        
        if var twitter = twitterHandleTextField.text {
            if twitter.hasPrefix("@") == false {
                twitter = "@" + twitter
            }
            singer.twitter = twitter
        }

        singer.facebook = tagOnFacebookSwitch.on ? "Yes" : "No"
        
        CoreDataHelper.sharedHelper.saveContext()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func validatedVoiceType(voiceType:String) -> Voice {
        if (voiceType.hasPrefix("A")) {
            return Voice.Alto
        } else if (voiceType.hasPrefix("Te")) {
            return Voice.Tenor
        } else if (voiceType.hasPrefix("B")) {
            return Voice.Bass
        } else if (voiceType.hasPrefix("Tr")) {
            return Voice.Treble
        } else {
            return Voice.NotSpecified
        }
    }
    
    @IBAction func tagOnFacebookSwitchChanged(sender: UISwitch) {
        singer?.facebook = sender.on ? "Yes" : "No"
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    var textFields: [UITextField] {
        return [nameTextField, displayNameTextField, homeSingingTextField, voiceTypeTextField, twitterHandleTextField]
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField != twitterHandleTextField {
            
            let index = textFields.indexOf(textField)!
            let newField = textFields[index+1]
            newField.becomeFirstResponder()
            
            return false
        }
        
        textField.resignFirstResponder()
        donePressed(textField)
        return true
    }
    
}
