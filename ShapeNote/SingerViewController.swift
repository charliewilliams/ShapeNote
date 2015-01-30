//
//  SingerViewController.swift
//  ShapeNote
//
//  Created by Charlie Williams on 30/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

class SingerViewController: UIViewController {
    
    var singer:Singer?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var homeSingingTextField: UITextField!
    @IBOutlet weak var twitterHandleTextField: UITextField!
    @IBOutlet weak var tagOnFacebookSwitch: UISwitch!
    @IBOutlet weak var voiceTypeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (singer != nil) {
            
            nameTextField.text = singer?.name
            displayNameTextField.text = singer?.shortName
            homeSingingTextField.text = singer?.group.name
            twitterHandleTextField.text = singer?.twitter
            tagOnFacebookSwitch.on = singer?.facebook != nil
            voiceTypeTextField.text = singer?.voiceType
        }
    }
    
    
}
