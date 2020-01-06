//
//  FeatureToggleMapperTests.swift
//  CloudKitFeatureTogglesTests
//
//  Created by Jonas Reichert on 06.01.20.
//

import XCTest
import CloudKit
@testable import CloudKitFeatureToggles

class FeatureToggleMapperTests: XCTestCase {
    
    var subject: FeatureToggleMappable!

    override func setUp() {
        subject = FeatureToggleMapper(featureToggleNameFieldID: "featureName", featureToggleIsActiveFieldID: "isActive")
    }
    
    func testMapInvalidInput() {
        let everythingWrong = CKRecord(recordType: "RecordType", recordID: CKRecord.ID(recordName: "identifier"))
        everythingWrong["bla"] = true
        everythingWrong["muh"] = 1283765
        
        XCTAssertNil(subject.map(record: everythingWrong))
        
        let wrongFields = CKRecord(recordType: "FeatureStatus", recordID: CKRecord.ID(recordName: "identifier2"))
        wrongFields["bla"] = true
        wrongFields["muh"] = 1283765
        
        XCTAssertNil(subject.map(record: wrongFields))
        
        let wrongIsActiveField = CKRecord(recordType: "FeatureStatus", recordID: CKRecord.ID(recordName: "identifier3"))
        wrongIsActiveField["bla"] = true
        wrongIsActiveField["featureName"] = 1283765
        
        XCTAssertNil(subject.map(record: wrongIsActiveField))
        
        let wrongFeatureNameField = CKRecord(recordType: "FeatureStatus", recordID: CKRecord.ID(recordName: "identifier4"))
        wrongFeatureNameField["isActive"] = true
        wrongFeatureNameField["muh"] = 1283765
        
        XCTAssertNil(subject.map(record: wrongFeatureNameField))
        
        let wrongIsActiveType = CKRecord(recordType: "FeatureStatus", recordID: CKRecord.ID(recordName: "identifier5"))
        wrongIsActiveType["isActive"] = "true"
        wrongIsActiveType["featureName"] = "1283765"
        
        XCTAssertNil(subject.map(record: wrongIsActiveType))
        
        let wrongFeatureNameType = CKRecord(recordType: "FeatureStatus", recordID: CKRecord.ID(recordName: "identifier6"))
        wrongFeatureNameType["isActive"] = true
        wrongFeatureNameType["featureName"] = 1283765
        
        XCTAssertNil(subject.map(record: wrongFeatureNameType))
    }
    
    func testMap() {
        let expectedIdentifier = "1283765"
        let expectedIsActive = true
        
        let record = CKRecord(recordType: "FeatureStatus", recordID: CKRecord.ID(recordName: "identifier"))
        record["isActive"] = expectedIsActive
        record["featureName"] = expectedIdentifier
        
        let result = subject.map(record: record)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, FeatureToggle(identifier: expectedIdentifier, isActive: expectedIsActive))
    }
    
    func testMap2() {
        let expectedIdentifier = "akjshgdjaskd(/(/&%$§"
        let expectedIsActive = false
        
        let record = CKRecord(recordType: "FeatureStatus", recordID: CKRecord.ID(recordName: "identifier"))
        record["isActive"] = expectedIsActive
        record["featureName"] = expectedIdentifier
        
        let result = subject.map(record: record)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, FeatureToggle(identifier: expectedIdentifier, isActive: expectedIsActive))
    }
    
    static var allTests = [
        ("testMapInvalidInput", testMapInvalidInput),
        ("testMap", testMap),
        ("testMap2", testMap2),
    ]

}
