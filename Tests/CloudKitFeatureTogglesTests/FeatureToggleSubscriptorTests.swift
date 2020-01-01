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
    
    var subject: FeatureToggleSubscriptor!
    var cloudKitDatabase: CloudKitDatabaseConformable!
    let defaults = UserDefaults(suiteName: "testSuite") ?? .standard

    override func setUp() {
        super.setUp()
        
        cloudKitDatabase = MockCloudKitDatabaseConformable()
        subject = FeatureToggleSubscriptor(toggleRepository: MockToggleRepository(), defaults: defaults, cloudKitDatabaseConformable: cloudKitDatabase)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "testSuite")
        
        super.tearDown()
    }
    
    func testFetchAll() {
        
    }
    
    func testSaveSubscription() {
        
    }
    
    func testHandleNotification() {
        
    }
    
    static var allTests = [
        ("testFetchAll", testFetchAll),
        ("testSaveSubscription", testSaveSubscription),
        ("testHandleNotification", testHandleNotification),
    ]

}

class MockToggleRepository: FeatureToggleRepository {
    var toggles: [String: FeatureToggleRepresentable] = [:]
    
    func save(featureToggle: FeatureToggleRepresentable) {
        toggles[featureToggle.identifier] = featureToggle
    }
    
    func retrieve(identifiable: FeatureToggleIdentifiable) -> FeatureToggleRepresentable {
        return toggles[identifiable.identifier] ?? MockToggleRepresentable(identifier: identifiable.identifier, isActive: identifiable.fallbackValue)
    }
}

struct MockToggleRepresentable: FeatureToggleRepresentable {
    var identifier: String
    var isActive: Bool
}

class MockCloudKitDatabaseConformable: CloudKitDatabaseConformable {
    func add(_ operation: CKDatabaseOperation) {
        
    }
    
    func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
        completionHandler(nil, nil)
    }
}
