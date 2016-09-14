//
//  ReverseGeocode
//
//  Created by Charlie Williams on 10/09/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import CoreLocation

struct ReverseGeocoder {
    
    static func findNearestSinging(toLocation location: CLLocation) -> (singing: Singing, supported: Bool) {
        
        // Find the closest singing location to the actual location.
        
        var minDistance = Double.infinity
        var closestSinging: Singing = Singing.known.first!
        
        for singing in Singing.known {
            
            let otherLocation = CLLocation(latitude: singing.location.latitude, longitude: singing.location.longitude)
            let distance = location.distance(from: otherLocation)
            if distance < minDistance {
                minDistance = distance
                closestSinging = singing
            }
        }
        
        let supported = Singing.supported.contains(where: { (other:Singing) -> Bool in
            closestSinging.facebookPageId == other.facebookPageId
        })
        
        // return that singing
        return (singing: closestSinging, supported: supported)
    }
}

