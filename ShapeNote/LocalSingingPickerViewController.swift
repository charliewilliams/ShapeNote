//
//  LocalSingingPickerViewController
//
//  Created by Charlie Williams on 10/09/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import UIKit
import CoreLocation

let allowLocationPermissionsViewControllerIdentifier = "AllowLocationPermissionsViewController"
let locationPermissionsDeniedViewControllerIdentifier = "LocationPermissionsDeniedViewController"

class LocalSingingPickerViewController : UIViewController {
    
    var locationManager = CLLocationManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        locationManager.delegate = self
        
        // 1. If we don't have location permission, put up a screen saying "let's find your closest singing" with a preview/guide
        // ... and make a guess at their closest singing using whatever means we have, allowing them to just pick it if we've got it right
        guard CLLocationManager.locationServicesEnabled() else {
            showEnableLocationServicesUI()
            return
        }
        
        // 2. If permission is refused… put up a 'pout' screen saying the app works better if you enable location permissions
        // ... and make a guess at their closest singing using whatever means we have, allowing them to just pick it if we've got it right
        guard hasLocationPermission else {
            showAllowLocationPermissionUI()
            return
        }
        
        // 3. If permission is granted, auto-select the closest singing. Show a map and highlight it.
        // ... and allow them to hit "this isn't it" somehow
        if let location = locationManager.location {
            showSingingUI(forLocation: location)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func updateUI() {
    
    
    }
}

extension LocalSingingPickerViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        showSingingUI(forLocation: locations.first!)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        dismiss(animated: true) { self.updateUI() }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
    }
}

private extension LocalSingingPickerViewController {
    
    var hasLocationPermission: Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    func showEnableLocationServicesUI() {
    
        // show it with an auto-dismiss when the status changes
        let vc = self.storyboard!.instantiateViewController(withIdentifier: allowLocationPermissionsViewControllerIdentifier)
        present(vc, animated: false, completion: nil)
    }
    
    func showAllowLocationPermissionUI() {
        
        // One way to estimate user location: time zone
        let timeZone = NSTimeZone.local
        if timeZone.identifier.components(separatedBy: "/").count > 1 {
            
            let cityName = timeZone.identifier.components(separatedBy: "/").reversed().joined(separator: ", ")
            CLGeocoder().geocodeAddressString(cityName, completionHandler: { [weak self] (placemarks:[CLPlacemark]?, error:Error?) in
                
                if let location = placemarks?.first?.location {
                    self?.showSingingUI(forLocation: location)
                }
            })
        }
        
        // Another way is
        
        /*
         
         // OR //
         
         http://dev.maxmind.com/geoip/geoip2/geolite2/
         */
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: locationPermissionsDeniedViewControllerIdentifier)
        present(vc, animated: false, completion: nil)
    }
    
    func showSingingUI(forLocation location: CLLocation) {
        
        let (singing, supported) = ReverseGeocoder.findNearestSinging(toLocation: location)
            
        // 4. If that singing is supported in the app, add an option to pick this one as the 'home' singing
        if supported {
            
            showAvailablePicker(forSinging: singing)
        }
            // 5. If that singing isn't supported, show a "coming soon" screen with some kind of social media link or whatever.
        else {
            
            showComingSoonScreen(forSinging: singing)
        }
    }
    
    func showComingSoonScreen(forSinging singing: Singing) {
        
        
    }
    
    func showAvailablePicker(forSinging singing: Singing) {
        
        
    }
}

