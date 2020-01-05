//
//  FeatureToggleApplicationServiceTests.swift
//  CloudKitFeatureTogglesTests
//
//  Created by Jonas Reichert on 05.01.20.
//

import XCTest
@testable import CloudKitFeatureToggles

class FeatureToggleApplicationServiceTests: XCTestCase {
    
    let defaults = UserDefaults(suiteName: "testSuite") ?? .standard
    var repository: MockToggleRepository!
    var subscriptor: CloudKitSubscriptionProtocol!
    var subject: FeatureToggleApplicationServiceProtocol!

    override func setUp() {
        repository = MockToggleRepository()
        subscriptor = FeatureToggleSubscriptor(toggleRepository: repository, defaults: defaults, cloudKitDatabaseConformable: MockCloudKitDatabaseConformable())
        subject = FeatureToggleApplicationService(featureToggleSubscriptor: subscriptor, featureToggleRepository: repository)
    }
    
    func testRegister() {
        #if canImport(UIKit)
        subject.register(application: UIApplication.shared())
        
        #endif
    }
    
    func testHandle() {
        
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
    
    func handleNotification() {
        handleCalled = true
    }
    
    func saveSubscription() {
        saveSubscriptionCalled = true
    }
    
    func fetchAll() {
        
    }
}
