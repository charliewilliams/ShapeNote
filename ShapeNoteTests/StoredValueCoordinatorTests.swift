//
//  StoredValueCoordinatorTests.swift
//  ShapeNote
//
//  Created by Charlie Williams on 18/12/2016.
//  Copyright © 2016 Charlie Williams. All rights reserved.
//

import XCTest
import CoreData
@testable import ShapeNote

class StoredValueCoordinatorTests: XCTestCase {
    
    var context: NSManagedObjectContext! = {
        
        let model = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        do {
            try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding persistent store coordinator failed!")
        }
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        return context
    }()
    
    private class MockCoreDataHelper: CoreDataHelper {
        
        var testBook: Book!
        var testSong: Song!
        
        override func books() -> [Book] {
            return [testBook]
        }
    }
    
    private var testCoreDataHelper: MockCoreDataHelper = {
        MockCoreDataHelper()
    }()
    
    override func setUp() {
        super.setUp()
        
        testCoreDataHelper.testBook = Book(identifier: .sacredHarp, context: context)
        testCoreDataHelper.testSong = Song(book: testCoreDataHelper.testBook, context: context)
    }
    
    func testSVCReadsFavorite() {

        testCoreDataHelper.testSong.favorited = true
        
        let storedData = StoreCoordinator().locallyStoredValues(coreDataHelper: testCoreDataHelper)
        
        print(storedData)
    }
}
