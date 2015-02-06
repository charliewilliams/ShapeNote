//
//  TwitterShareHelper.swift
//  ShapeNote
//
//  Created by Charlie Williams on 03/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit
import Social
import Accounts

class TwitterShareHelper: NSObject {
    
    let twitterAPIKey = "ttsZGpXqhmcqX4eDH1Avwhiay"
    let twitterSecret = "XkZ8LzMOhAchwLjwiMNuQpiVdD3YB3DkbHtQkpcVoD3HdLQjoi"
    var twitterAccount:ACAccount?
    var leading:Leading?
    
    class var sharedHelper : TwitterShareHelper {
        struct Static {
            static let instance : TwitterShareHelper = TwitterShareHelper()
        }
        return Static.instance
    }
    
    func postLeading(leading:Leading) {
        
        self.leading = leading
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        let completion:ACAccountStoreRequestAccessCompletionHandler = {(granted:Bool, error:NSError?) -> Void in
        
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                if granted == false {
                    println("Access not granted")
                    return
                }
                
                let accounts = accountStore.accountsWithAccountType(accountType) as [ACAccount]
                
                if accounts.count == 1 {
                    
                    self.tweetFromAccount(accounts.first)
                }
                
                else {
                    
                    let actionSheet = UIAlertController(title: "Select an account:", message: nil, preferredStyle: .ActionSheet)

                    for account:ACAccount in accounts {
                        
                        let accountButton = UIAlertAction(title: account.username, style: .Default, handler: { (action:UIAlertAction!) -> Void in
                            
                            self.tweetFromAccount(account)
                        })
                        actionSheet.addAction(accountButton)
                    }
                    
                    let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action:UIAlertAction!) -> Void in
                        
                    })
                    actionSheet.addAction(cancel)
                    
                    
                    // show it
                }
            })
        }
    }
    
    func tweetFromAccount(account: ACAccount!) {
        
        twitterAccount = account // store this
        let twitter:STTwitterAPI = STTwitterAPI.twitterAPIOSWithAccount(account)
        
        twitter.verifyCredentialsWithSuccessBlock({ (username:String!) -> Void in
            
            twitter.postStatusUpdate(self.leading?.twitterString(), inReplyToStatusID: "", latitude: "", longitude: "", placeID: "", displayCoordinates: 0, trimUser: 0, successBlock: { (response: [NSObject:AnyObject]!) -> Void in
                
                println(response)
                
                }, errorBlock: { (error:NSError!) -> Void in
                    
                    println(error)
            })
            
            }, errorBlock: { (error:NSError!) -> Void in
            println(error)
        })
    }
   
}
