//
//  FeatureSwitchHelper.swift
//  nSuns
//
//  Created by Jonas Reichert on 22.07.18.
//  Copyright © 2018 Jonas Reichert. All rights reserved.
//

import Foundation
import CloudKit

class FeatureSwitchSubscriptor: CloudKitSubscriptionProtocol {
    
    private let featureToggleRecordID: String
    private let featureToggleNameFieldID: String
    private let featureToggleIsActiveFieldID: String
    
    private let toggleRepository: FeatureToggleRepository
    
    let subscriptionID = "cloudkit-recordType-FeatureToggle"
    
    init(toggleRepository: FeatureToggleRepository = FeatureToggleUserDefaultsRepository(), featureToggleRecordID: String = "FeatureStatus", featureToggleNameFieldID: String = "featureName", featureToggleIsActiveFieldID: String = "isActive") {
        self.toggleRepository = toggleRepository
        self.featureToggleRecordID = featureToggleRecordID
        self.featureToggleNameFieldID = featureToggleNameFieldID
        self.featureToggleIsActiveFieldID = featureToggleIsActiveFieldID
    }
    
    func fetchAll() {
        fetchAll(recordType: featureToggleRecordID, handler: { (ckRecords) in
            self.updateRepository(with: ckRecords)
        })
    }
    
    func saveSubscription() {
        saveSubscription(subscriptionID: subscriptionID, recordType: featureToggleRecordID)
    }
    
    func handleNotification() {
        handleNotification(recordType: featureToggleRecordID) { (record) in
            self.updateRepository(with: [record])
        }
    }
    
    private func updateRepository(with ckRecords: [CKRecord]) {
        ckRecords.forEach { (record) in
            if let active = record[featureToggleIsActiveFieldID] as? Int64, let featureName = record[featureToggleNameFieldID] as? String {
                toggleRepository.save(featureToggle: FeatureToggle(identifier: featureName, isActive: NSNumber(value: active).boolValue))
            }
        }
    }
}
