//
//  IntroHandler.swift
//  ShapeNote
//
//  Created by Charlie Williams on 10/10/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

protocol IntroHandler {
    func handleFirstRun()
}

extension IntroHandler where Self: UIViewController {
    
    func handleFirstRun() {
        
        guard Defaults.isFirstRun == true else {
            return
        }
        
        let introVC = UIStoryboard(name: "Intro", bundle: nil).instantiateInitialViewController() as! IntroPopupViewController
        _ = introVC.view
        introVC.doneButton.isHidden = false
        
        DispatchQueue.main.async { () -> Void in
            self.present(introVC, animated: false, completion: nil)
        }
    }
}
