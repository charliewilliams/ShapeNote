//
//  NSManagedObject.swift
//  ShapeNote
//
//  Created by Charlie Williams on 18/12/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import CoreData

extension NSManagedObject {
    
    convenience init(className: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: className, in: context)!
        self.init(entity: entity, insertInto: context)
    }
}
