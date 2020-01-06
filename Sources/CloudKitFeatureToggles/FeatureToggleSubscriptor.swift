//
//  FeatureSwitchHelper.swift
//  nSuns
//
//  Created by Jonas Reichert on 22.07.18.
//  Copyright © 2018 Jonas Reichert. All rights reserved.
//

import Foundation
import CloudKit

class FeatureToggleSubscriptor: CloudKitSubscriptionProtocol {
    
    private static let defaultsSuiteName = "featureToggleDefaultsSuite"
    private let featureToggleRecordID: String
    private let featureToggleNameFieldID: String
    private let featureToggleIsActiveFieldID: String
    
    private let toggleRepository: FeatureToggleRepository
    private let toggleMapper: FeatureToggleMappable
    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter
    
    let subscriptionID = "cloudkit-recordType-FeatureToggle"
    let database: CloudKitDatabaseConformable
    
    init(toggleRepository: FeatureToggleRepository = FeatureToggleUserDefaultsRepository(), toggleMapper: FeatureToggleMappable = FeatureToggleMapper(), featureToggleRecordID: String = "FeatureStatus", featureToggleNameFieldID: String = "featureName", featureToggleIsActiveFieldID: String = "isActive", defaults: UserDefaults = UserDefaults(suiteName: FeatureToggleSubscriptor.defaultsSuiteName) ?? .standard, notificationCenter: NotificationCenter = .default, cloudKitDatabaseConformable: CloudKitDatabaseConformable = CKContainer.default().publicCloudDatabase) {
        self.toggleRepository = toggleRepository
        self.toggleMapper = toggleMapper
        self.featureToggleRecordID = featureToggleRecordID
        self.featureToggleNameFieldID = featureToggleNameFieldID
        self.featureToggleIsActiveFieldID = featureToggleIsActiveFieldID
        self.defaults = defaults
        self.notificationCenter = notificationCenter
        self.database = cloudKitDatabaseConformable
    }
    
    func fetchAll() {
        fetchAll(recordType: featureToggleRecordID, handler: { (ckRecords) in
            self.updateRepository(with: ckRecords)
            self.sendNotification(records: ckRecords)
        })
    }
    
    func saveSubscription() {
        saveSubscription(subscriptionID: subscriptionID, recordType: featureToggleRecordID, defaults: defaults)
    }
    
    func handleNotification() {
        handleNotification(recordType: featureToggleRecordID) { (record) in
            self.updateRepository(with: [record])
            self.sendNotification(records: [record])
        }
    }
    
    private func updateRepository(with ckRecords: [CKRecord]) {
        ckRecords.forEach { (record) in
            if let active = record[featureToggleIsActiveFieldID] as? Int64, let featureName = record[featureToggleNameFieldID] as? String {
                toggleRepository.save(featureToggle: FeatureToggle(identifier: featureName, isActive: NSNumber(value: active).boolValue))
            }
        }
    }
    
    private func sendNotification(records: [CKRecord]) {
        notificationCenter.post(name: Notification.Name.onRecordsUpdated, object: nil, userInfo: ["records" : records.compactMap({ (record) -> FeatureToggle? in
            return toggleMapper.map(record: record)
        })])
    }
}
