//
//  FeatureToggleApplicationServiceTests.swift
//  CloudKitFeatureTogglesTests
//
//  Created by Jonas Reichert on 05.01.20.
//

import XCTest
@testable import CloudKitFeatureToggles

class FeatureToggleApplicationServiceTests: XCTestCase {
    
    var repository: MockToggleRepository!
    var subscriptor: MockFeatureToggleSubscriptor!
    var subject: FeatureToggleApplicationServiceProtocol!

    override func setUp() {
        repository = MockToggleRepository()
        subscriptor = MockFeatureToggleSubscriptor()
        subject = FeatureToggleApplicationService(featureToggleSubscriptor: subscriptor, featureToggleRepository: repository)
    }
    
    func testRegister() {
        #if canImport(UIKit)
        XCTAssertFalse(subscriptor.saveSubscriptionCalled)
        XCTAssertFalse(subscriptor.handleCalled)
        XCTAssertFalse(subscriptor.fetchAllCalled)
        
        subject.register(application: UIApplication.shared)
        
        XCTAssertTrue(subscriptor.saveSubscriptionCalled)
        XCTAssertFalse(subscriptor.handleCalled)
        XCTAssertTrue(subscriptor.fetchAllCalled)
        #endif
    }
    
    func testHandle() {
        #if canImport(UIKit)
        XCTAssertFalse(subscriptor.saveSubscriptionCalled)
        XCTAssertFalse(subscriptor.handleCalled)
        XCTAssertFalse(subscriptor.fetchAllCalled)
        
        subject.handleRemoteNotification(subscriptionID: "Mock", completionHandler: { result in
        
        })
        XCTAssertFalse(subscriptor.saveSubscriptionCalled)
        XCTAssertTrue(subscriptor.handleCalled)
        XCTAssertFalse(subscriptor.fetchAllCalled)
        #endif
    }

    static var allTests = [
        ("testRegister", testRegister),
        ("testHandle", testHandle),
    ]
}

class MockFeatureToggleSubscriptor: CloudKitSubscriptionProtocol {
    var subscriptionID: String = "Mock"
    var database: CloudKitDatabaseConformable = MockCloudKitDatabaseConformable()
    
    var saveSubscriptionCalled = false
    var handleCalled = false
    var fetchAllCalled = false
    
    func handleNotification() {
        handleCalled = true
    }
    
    func saveSubscription() {
        saveSubscriptionCalled = true
    }
    
    func fetchAll() {
        fetchAllCalled = true
    }
}
