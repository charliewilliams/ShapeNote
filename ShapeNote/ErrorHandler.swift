//
//  ErrorHandler.swift
//  ShapeNote
//
//  Created by Charlie Williams on 17/12/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit

struct ErrorHandler {
    
    static func handleError(_ error:NSError?) {
        
        var message = "Please email Charlie a description of what just happened so he can fix it.\n\nThis problem might also be fixed by deleting and reinstalling the app. (Sorry.)"
        if let error = error,
            error.localizedDescription.characters.count > 4 {
            message = error.localizedDescription
        }
        let alert = UIAlertController(title: "Core Data Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        UIApplication.shared.keyWindow!.rootViewController!.present(alert, animated: true, completion: nil)
    }
}
