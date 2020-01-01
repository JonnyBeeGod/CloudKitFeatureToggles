//
//  FeatureToggleRepositoryTests.swift
//  CloudKitFeatureTogglesTests
//
//  Created by Jonas Reichert on 01.01.20.
//

import XCTest
@testable import CloudKitFeatureToggles

class FeatureToggleRepositoryTests: XCTestCase {
    
    enum TestToggle: String, FeatureToggleIdentifiable {
        var identifier: String {
            return self.rawValue
        }
        
        var fallbackValue: Bool {
            switch self {
            case .feature1:
                return false
            case .feature2:
                return true
            }
        }
        
        case feature1
        case feature2
    }
    
    let suiteName = "repositoryTest"
    var defaults: UserDefaults!
    
    var subject: FeatureToggleRepository!
    
    override func setUp() {
        super.setUp()
        
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail()
            return
        }
        
        self.defaults = defaults
        self.subject = FeatureToggleUserDefaultsRepository(defaults: defaults)
    }
    
    override func tearDown() {
        self.defaults.removePersistentDomain(forName: suiteName)
        
        super.tearDown()
    }
    
    func testRetrieveBeforeSave() {
        XCTAssertEqual(subject.retrieve(identifiable: TestToggle.feature1).isActive, TestToggle.feature1.fallbackValue)
        XCTAssertEqual(subject.retrieve(identifiable: TestToggle.feature2).isActive, TestToggle.feature2.fallbackValue)
        
        XCTAssertFalse(subject.retrieve(identifiable: TestToggle.feature1).isActive)
        subject.save(featureToggle: FeatureToggle(identifier: TestToggle.feature1.rawValue, isActive: true))
        XCTAssertTrue(subject.retrieve(identifiable: TestToggle.feature1).isActive)
    }

    func testSaveAndRetrieve() {
        XCTAssertFalse(subject.retrieve(identifiable: TestToggle.feature1).isActive)
        XCTAssertTrue(subject.retrieve(identifiable: TestToggle.feature2).isActive)
        
        subject.save(featureToggle: FeatureToggle(identifier: TestToggle.feature1.rawValue, isActive: true))
        XCTAssertTrue(subject.retrieve(identifiable: TestToggle.feature1).isActive)
        XCTAssertTrue(subject.retrieve(identifiable: TestToggle.feature2).isActive)
        
        subject.save(featureToggle: FeatureToggle(identifier: TestToggle.feature2.rawValue, isActive: false))
        XCTAssertTrue(subject.retrieve(identifiable: TestToggle.feature1).isActive)
        XCTAssertFalse(subject.retrieve(identifiable: TestToggle.feature2).isActive)
    }
    
    static var allTests = [
        ("testSaveAndRetrieve", testSaveAndRetrieve),
        ("testRetrieveBeforeSave", testRetrieveBeforeSave),
    ]

}
