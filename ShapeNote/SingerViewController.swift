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
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var displayNameTextField: UITextField!
    @IBOutlet var homeSingingTextField: UITextField!
    @IBOutlet var voiceTypeTextField: UITextField!
    @IBOutlet var twitterHandleTextField: UITextField!
    @IBOutlet var tagOnFacebookSwitch: UISwitch!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "SingerViewController", bundle: nibBundleOrNil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let singer = singer else {
            title = "New Singer"
            return
        }
        
        title = singer.firstName
        nameTextField.text = singer.firstName
        lastNameTextField.text = singer.lastName
        displayNameTextField.text = singer.displayName
        homeSingingTextField.text = singer.group?.name
        
        if let firstName = singer.firstName,
            let lastName = singer.lastName, singer.displayName == nil {
                let lastInitial = lastName.substring(to: lastName.characters.index(lastName.startIndex, offsetBy: 1))
                displayNameTextField.placeholder = "Display name (optional — i.e. \(firstName) \(lastInitial))"
        }
        
        twitterHandleTextField.text = singer.twitter
//        tagOnFacebookSwitch.on = singer.facebookId != nil
        voiceTypeTextField.text = singer.voice
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        
        guard let name = nameTextField.text, name.characters.count > 0 else {
            return
        }
        
        if singer == nil {
            singer = Singer()
        }
        
        guard let singer = singer else { fatalError() }
        singer.firstName = name
        singer.lastName = lastNameTextField.text
        
        if let displayName = displayNameTextField.text {
            singer.displayName = displayName
        }
        
        if let homeSingingName = homeSingingTextField.text {
            singer.group = CoreDataHelper.sharedHelper.groupWithName(homeSingingName)
        }
        else {
            singer.group = CoreDataHelper.sharedHelper.currentlySelectedGroup
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
        
        CoreDataHelper.sharedHelper.saveContext()
    }
    
    func validatedVoiceType(_ voiceType:String) -> Voice {
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
    
    @IBAction func tagOnFacebookSwitchChanged(_ sender: UISwitch) {
        
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    var textFields: [UITextField] {
        return [nameTextField, displayNameTextField, homeSingingTextField, voiceTypeTextField, twitterHandleTextField]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField != twitterHandleTextField {
            
            let index = textFields.index(of: textField)!
            let newField = textFields[index+1]
            newField.becomeFirstResponder()
            
            return false
        }
        
        textField.resignFirstResponder()
        donePressed(textField)
        return true
    }
    
}
