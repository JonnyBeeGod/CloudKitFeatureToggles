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
    
    private let toggleRepository: FeatureToggleRepository
    private let toggleMapper: FeatureToggleMappable
    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter
    
    let subscriptionID = "cloudkit-recordType-FeatureToggle"
    let database: CloudKitDatabaseConformable
    
    init(toggleRepository: FeatureToggleRepository = FeatureToggleUserDefaultsRepository(), toggleMapper: FeatureToggleMappable? = nil, featureToggleRecordID: String = "FeatureStatus", featureToggleNameFieldID: String = "featureName", featureToggleIsActiveFieldID: String = "isActive", defaults: UserDefaults = UserDefaults(suiteName: FeatureToggleSubscriptor.defaultsSuiteName) ?? .standard, notificationCenter: NotificationCenter = .default, cloudKitDatabaseConformable: CloudKitDatabaseConformable = CKContainer.default().publicCloudDatabase) {
        self.toggleRepository = toggleRepository
        self.toggleMapper = toggleMapper ?? FeatureToggleMapper(featureToggleNameFieldID: featureToggleNameFieldID, featureToggleIsActiveFieldID: featureToggleIsActiveFieldID)
        self.featureToggleRecordID = featureToggleRecordID
        self.defaults = defaults
        self.notificationCenter = notificationCenter
        self.database = cloudKitDatabaseConformable
    }
    
    func fetchAll() {
        fetchAll(recordType: featureToggleRecordID, handler: { (ckRecords) in
            let toggles = ckRecords.compactMap { (record) -> FeatureToggle? in
                return self.toggleMapper.map(record: record)
            }
            
            self.updateRepository(with: toggles)
            self.sendNotification(with: toggles)
        })
    }
    
    func saveSubscription() {
        saveSubscription(subscriptionID: subscriptionID, recordType: featureToggleRecordID, defaults: defaults)
    }
    
    func handleNotification() {
        handleNotification(recordType: featureToggleRecordID) { (record) in
            guard let toggle = self.toggleMapper.map(record: record) else {
                return
            }
            
            self.updateRepository(with: [toggle])
            self.sendNotification(with: [toggle])
        }
    }
    
    private func updateRepository(with toggles: [FeatureToggle]) {
        toggles.forEach { (toggle) in
            toggleRepository.save(featureToggle: toggle)
        }
    }
    
    private func sendNotification(with toggles: [FeatureToggle]) {
        notificationCenter.post(name: Notification.Name.onRecordsUpdated, object: nil, userInfo: ["records" : toggles])
    }
}
