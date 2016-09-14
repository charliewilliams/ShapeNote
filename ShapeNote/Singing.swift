//
//  Singing
//
//  Created by Charlie Williams on 10/09/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import CoreLocation

let bristol = Singing(name: "Bristol", facebookPageId: "", location: CLLocationCoordinate2D(latitude: 51.4494273, longitude: -2.5937547), radiusKm: 40)
let paloAlto = Singing(name: "Palo Alto", facebookPageId: "", location: CLLocationCoordinate2D(latitude: 37.419574, longitude: -122.114692), radiusKm: 50)

struct Singing {
    
    var name: String
    var facebookPageId: String
    var location: CLLocationCoordinate2D
    var radiusKm: Float
    
    static var supported: [Singing] {
        
        return [bristol]
    }
    
    static var known: [Singing] {
        
        return [bristol, paloAlto]
    }
}


