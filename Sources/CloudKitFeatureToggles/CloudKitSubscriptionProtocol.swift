//
//  CloudKitSubscriptionProtocol.swift
//  nSuns
//
//  Created by Jonas Reichert on 01.09.18.
//  Copyright © 2018 Jonas Reichert. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitDatabaseConformable {
    func add(_ operation: CKDatabaseOperation)
    func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void)
}

extension CKDatabase: CloudKitDatabaseConformable {}

protocol CloudKitSubscriptionProtocol {
    var subscriptionID: String { get }
    var database: CloudKitDatabaseConformable { get }
    
    func fetchAll()
    func saveSubscription()
    func handleNotification()
}

extension CloudKitSubscriptionProtocol {
    func saveSubscription(subscriptionID: String, recordType: String, defaults: UserDefaults) {
        // Let's keep a local flag handy to avoid saving the subscription more than once.
        // Even if you try saving the subscription multiple times, the server doesn't save it more than once
        // Nevertheless, let's save some network operation and conserve resources
        let subscriptionSaved = defaults.bool(forKey: subscriptionID)
        guard !subscriptionSaved else {
            return
        }
        
        // Subscribing is nothing but saving a query which the server would use to generate notifications.
        // The below predicate (query) will raise a notification for all changes.
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: recordType, predicate: predicate, subscriptionID: subscriptionID, options: CKQuerySubscription.Options.firesOnRecordUpdate)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        // Set shouldSendContentAvailable to true for receiving silent pushes
        // Silent notifications are not shown to the user and don’t require the user's permission.
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        // Use CKModifySubscriptionsOperation to save the subscription to CloudKit
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        operation.modifySubscriptionsCompletionBlock = { (_, _, error) in
            guard error == nil else {
                return
            }
            defaults.set(true, forKey: subscriptionID)
        }
        operation.qualityOfService = .utility
        // Add the operation to the corresponding private or public database
        database.add(operation)
    }
    
    func handleNotification(recordType: String, recordFetchedBlock: @escaping (CKRecord) -> Void) {
        let queryOperation = CKQueryOperation(query: query(recordType: recordType))
        
        queryOperation.recordFetchedBlock = recordFetchedBlock
        queryOperation.qualityOfService = .utility
        
        database.add(queryOperation)
    }
    
    func fetchAll(recordType: String, handler: @escaping ([CKRecord]) -> Void) {
        database.perform(query(recordType: recordType), inZoneWith: nil) { (ckRecords, error) in
            guard error == nil, let ckRecords = ckRecords else {
                // don't update last fetched date, simply do nothing and try again next time
                return
            }
            
            handler(ckRecords)
        }
    }
    
    private func query(recordType: String) -> CKQuery {
        let predicate = NSPredicate(value: true)
        return CKQuery(recordType: recordType, predicate: predicate)
    }
}
