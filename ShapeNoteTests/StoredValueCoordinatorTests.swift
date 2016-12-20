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
        var testSong2: Song!
        
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
        testCoreDataHelper.testSong.number = "49t"
        
        testCoreDataHelper.testSong2 = Song(book: testCoreDataHelper.testBook, context: context)
        testCoreDataHelper.testSong2.number = "591"
    }
    
    /*
     Tests for reading locally stored values from Core Data
     */
    
    func testReadsFavorite() {

//        let expectedData = ["The Sacred Harp (1991)": ["49t": ["fav": "true"]]]
        testCoreDataHelper.testSong.favorited = true
        
        let storedData = StoreCoordinator().locallyStoredValues(coreDataHelper: testCoreDataHelper)
        
        XCTAssertEqual(storedData.keys.first, "The Sacred Harp (1991)")
        let value = storedData["The Sacred Harp (1991)"]!
    
        XCTAssertEqual(value.keys.first, "49t")
        let info = value["49t"]!
        
        XCTAssertEqual(info.keys.first, "fav")
        XCTAssertEqual(info["fav"], "true")
    }
    
    func testDoesNotReadUntouchedSong() {
        
        let storedData = StoreCoordinator().locallyStoredValues(coreDataHelper: testCoreDataHelper)
        
        XCTAssertNil(storedData.keys.first)
    }
    
    func testRemovesUnfavoritedSong() {
        
        testCoreDataHelper.testSong.favorited = true
        _ = StoreCoordinator().locallyStoredValues(coreDataHelper: testCoreDataHelper)
        
        testCoreDataHelper.testSong.favorited = false
        let storedData = StoreCoordinator().locallyStoredValues(coreDataHelper: testCoreDataHelper)
        
        XCTAssertNil(storedData.keys.first)
    }
    
    func testReadsNote() {
        
        let testNote = "This is a test note."
        testCoreDataHelper.testSong.notes = testNote
        
        let storedData = StoreCoordinator().locallyStoredValues(coreDataHelper: testCoreDataHelper)
        
        XCTAssertEqual(storedData.keys.first, "The Sacred Harp (1991)")
        let value = storedData["The Sacred Harp (1991)"]!
        
        XCTAssertEqual(value.keys.first, "49t")
        let info = value["49t"]!
        
        XCTAssertEqual(info.keys.first, "note")
        XCTAssertEqual(info["note"], testNote)
    }
    
    func testReadsNoteAndFav() {
        
        let testNote = "This is a test note."
        testCoreDataHelper.testSong.notes = testNote
        testCoreDataHelper.testSong.favorited = true
        
        let storedData = StoreCoordinator().locallyStoredValues(coreDataHelper: testCoreDataHelper)
        
        XCTAssertEqual(storedData.keys.first, "The Sacred Harp (1991)")
        let value = storedData["The Sacred Harp (1991)"]!
        
        XCTAssertEqual(value.keys.first, "49t")
        let info = value["49t"]!
        
        XCTAssertTrue(info.keys.contains("note"))
        XCTAssertTrue(info.keys.contains("fav"))
        
        XCTAssertEqual(info["note"], testNote)
        XCTAssertEqual(info["fav"], "true")
    }
    
    func testTwoSongsHaveIndepdendentState() {
        
        let testNote = "This is a test note."
        testCoreDataHelper.testSong.notes = testNote
        let testNote2 = "This also is such a thing."
        testCoreDataHelper.testSong2.notes = testNote2
        
        testCoreDataHelper.testSong.favorited = true
        testCoreDataHelper.testSong2.favorited = true
        
        _ = StoreCoordinator().locallyStoredValues(coreDataHelper: testCoreDataHelper)
        
        testCoreDataHelper.testSong2.favorited = false
        
        let storedData = StoreCoordinator().locallyStoredValues(coreDataHelper: testCoreDataHelper)
        
        XCTAssertEqual(storedData.keys.first, "The Sacred Harp (1991)")
        let value = storedData["The Sacred Harp (1991)"]!
        
        XCTAssertTrue(value.keys.contains("49t"))
        XCTAssertTrue(value.keys.contains("591"))
        let info = value["49t"]!
        
        XCTAssertTrue(info.keys.contains("note"))
        XCTAssertTrue(info.keys.contains("fav"))
        
        XCTAssertEqual(info["note"], testNote)
        XCTAssertEqual(info["fav"], "true")
        
        let info2 = value["591"]!
        XCTAssertTrue(info2.keys.contains("note"))
        XCTAssertFalse(info2.keys.contains("fav"))
        
        XCTAssertEqual(info2["note"], testNote2)
        XCTAssertEqual(info2["fav"], nil)
    }
    
    /*
     Tests for reading remotely stored values from iCloud
     */
    
    
    
    
    /*
     Tests for merging remote and local data
     */
    
    
    
    
    
    /*
     Tests for writing remote values to iCloud
     */
}
