//
//  FeatureToggleSubscriptorTests.swift
//  CloudKitFeatureTogglesTests
//
//  Created by Jonas Reichert on 02.01.20.
//

import XCTest
import CloudKit
@testable import CloudKitFeatureToggles

class FeatureToggleSubscriptorTests: XCTestCase {
    
    enum TestError: Error {
        case generic
    }
    
    var subject: FeatureToggleSubscriptor!
    var cloudKitDatabase: MockCloudKitDatabaseConformable!
    var repository: MockToggleRepository!
    let defaults = UserDefaults(suiteName: "testSuite") ?? .standard

    override func setUp() {
        super.setUp()
        
        cloudKitDatabase = MockCloudKitDatabaseConformable()
        repository = MockToggleRepository()
        subject = FeatureToggleSubscriptor(toggleRepository: repository, featureToggleRecordID: "TestFeatureStatus", featureToggleNameFieldID: "toggleName", featureToggleIsActiveFieldID: "isActive",  defaults: defaults, cloudKitDatabaseConformable: cloudKitDatabase)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "testSuite")
        
        super.tearDown()
    }
    
    func testFetchAll() {
        XCTAssertNil(cloudKitDatabase.recordType)
        XCTAssertEqual(repository.toggles.count, 0)
        
        cloudKitDatabase.recordFetched["isActive"] = 1
        cloudKitDatabase.recordFetched["toggleName"] = "Toggle1"
        
        subject.fetchAll()
        
        XCTAssertEqual(repository.toggles.count, 1)
        guard let toggle = repository.toggles.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(toggle.identifier, "Toggle1")
        XCTAssertTrue(toggle.isActive)
        
        cloudKitDatabase.recordFetched["isActive"] = 0
        cloudKitDatabase.recordFetched["toggleName"] = "Toggle1"
        
        subject.fetchAll()
        
        XCTAssertEqual(repository.toggles.count, 1)
        
        guard let toggle2 = repository.toggles.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(toggle2.identifier, "Toggle1")
        XCTAssertFalse(toggle2.isActive)
    }
    
    func testFetchAllError() {
        cloudKitDatabase.error = TestError.generic
        
        XCTAssertNil(cloudKitDatabase.recordType)
        XCTAssertEqual(repository.toggles.count, 0)
        
        cloudKitDatabase.recordFetched["isActive"] = 1
        cloudKitDatabase.recordFetched["toggleName"] = "Toggle1"
        
        subject.fetchAll()
        
        XCTAssertNil(cloudKitDatabase.recordType)
        XCTAssertEqual(repository.toggles.count, 0)
    }
    
    func testSaveSubscription() {
        XCTAssertNil(cloudKitDatabase.subscriptionsToSave)
        XCTAssertFalse(defaults.bool(forKey: subject.subscriptionID))
        
        subject.saveSubscription()
        
        guard let firstSubscription = cloudKitDatabase.subscriptionsToSave?.first else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(firstSubscription.subscriptionID, subject.subscriptionID)
        XCTAssertTrue(defaults.bool(forKey: subject.subscriptionID))
        XCTAssertEqual(cloudKitDatabase.addCalledCount, 1)
        
        subject.saveSubscription()
        XCTAssertEqual(firstSubscription.subscriptionID, subject.subscriptionID)
        XCTAssertTrue(defaults.bool(forKey: subject.subscriptionID))
        XCTAssertEqual(cloudKitDatabase.addCalledCount, 1)
    }
    
    func testSaveSubscriptionError() {
        cloudKitDatabase.error = TestError.generic
        
        XCTAssertNil(cloudKitDatabase.subscriptionsToSave)
        XCTAssertFalse(defaults.bool(forKey: subject.subscriptionID))
        
        subject.saveSubscription()
        
        XCTAssertFalse(defaults.bool(forKey: subject.subscriptionID))
    }
    
    func testHandleNotification() {
        XCTAssertNil(cloudKitDatabase.recordType)
        XCTAssertEqual(cloudKitDatabase.addCalledCount, 0)
        XCTAssertEqual(repository.toggles.count, 0)
        
        cloudKitDatabase.recordFetched["isActive"] = 1
        cloudKitDatabase.recordFetched["toggleName"] = "Toggle1"
        
        subject.handleNotification()
        
        XCTAssertEqual(cloudKitDatabase.addCalledCount, 1)
        XCTAssertEqual(cloudKitDatabase.recordType, "TestFeatureStatus")
        XCTAssertEqual(repository.toggles.count, 1)
        guard let toggle = repository.toggles.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(toggle.identifier, "Toggle1")
        XCTAssertTrue(toggle.isActive)
        
        cloudKitDatabase.recordFetched["isActive"] = 0
        cloudKitDatabase.recordFetched["toggleName"] = "Toggle1"
        
        subject.handleNotification()
        
        XCTAssertEqual(cloudKitDatabase.addCalledCount, 2)
        XCTAssertEqual(cloudKitDatabase.recordType, "TestFeatureStatus")
        XCTAssertEqual(repository.toggles.count, 1)
        
        guard let toggle2 = repository.toggles.first else {
            XCTFail()
            return
        }
        XCTAssertEqual(toggle2.identifier, "Toggle1")
        XCTAssertFalse(toggle2.isActive)
    }
    
    static var allTests = [
        ("testFetchAll", testFetchAll),
        ("testSaveSubscription", testSaveSubscription),
        ("testHandleNotification", testHandleNotification),
    ]

}

class MockToggleRepository: FeatureToggleRepository {
    var toggles: [FeatureToggleRepresentable] = []
    
    func save(featureToggle: FeatureToggleRepresentable) {
        toggles.removeAll { (representable) -> Bool in
            representable.identifier == featureToggle.identifier
        }
        toggles.append(featureToggle)
    }
    
    func retrieve(identifiable: FeatureToggleIdentifiable) -> FeatureToggleRepresentable {
        toggles.first { (representable) -> Bool in
            representable.identifier == identifiable.identifier
        } ?? MockToggleRepresentable(identifier: identifiable.identifier, isActive: identifiable.fallbackValue)
    }
}

struct MockToggleRepresentable: FeatureToggleRepresentable {
    var identifier: String
    var isActive: Bool
}

class MockCloudKitDatabaseConformable: CloudKitDatabaseConformable {
    var addCalledCount = 0
    var subscriptionsToSave: [CKSubscription]?
    var recordType: CKRecord.RecordType?
    
    var recordFetched = CKRecord(recordType: "TestFeatureStatus")
    var error: Error?
    
    func add(_ operation: CKDatabaseOperation) {
        if let op = operation as? CKModifySubscriptionsOperation {
            subscriptionsToSave = op.subscriptionsToSave
            op.modifySubscriptionsCompletionBlock?(nil, nil, error)
        } else if let op = operation as? CKQueryOperation {
            recordType = op.query?.recordType
            op.recordFetchedBlock?(recordFetched)
        }
        addCalledCount += 1
    }
    
    func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
        if let error = error {
            completionHandler(nil, error)
        } else {
            completionHandler([recordFetched], error)
        }
    }
}
