//
//  FeatureToggleApplicationService.swift
//  CloudKitFeatureToggles
//
//  Created by Jonas Reichert on 04.01.20.
//

import Foundation
import CloudKit
#if canImport(UIKit)
import UIKit
#endif

public protocol FeatureToggleApplicationServiceProtocol {
    var featureToggleRepository: FeatureToggleRepository { get }

    #if canImport(UIKit)
    func register(application: UIApplication)
    func handleRemoteNotification(subscriptionID: String?, completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    #endif
}

public class FeatureToggleApplicationService: NSObject, FeatureToggleApplicationServiceProtocol {
    
    private var featureToggleSubscriptor: CloudKitSubscriptionProtocol
    private (set) public var featureToggleRepository: FeatureToggleRepository
    
    public convenience init(featureToggleRepository: FeatureToggleRepository = FeatureToggleUserDefaultsRepository()) {
        self.init(featureToggleSubscriptor: FeatureToggleSubscriptor(toggleRepository: featureToggleRepository), featureToggleRepository: featureToggleRepository)
    }
    
    init(featureToggleSubscriptor: CloudKitSubscriptionProtocol, featureToggleRepository: FeatureToggleRepository) {
        self.featureToggleSubscriptor = featureToggleSubscriptor
        self.featureToggleRepository = featureToggleRepository
    }
    
    #if canImport(UIKit)
    public func register(application: UIApplication) {
        application.registerForRemoteNotifications()
        featureToggleSubscriptor.saveSubscription()
        featureToggleSubscriptor.fetchAll()
    }
    
    public func handleRemoteNotification(subscriptionID: String?, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let subscriptionID = subscriptionID, featureToggleSubscriptor.subscriptionID == subscriptionID {
            featureToggleSubscriptor.handleNotification()
            completionHandler(.newData)
        }
        else {
            completionHandler(.noData)
        }
    }
    #endif
}

#if canImport(UIKit)
extension FeatureToggleApplicationService: UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        register(application: application)
        
        return true
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo), let subscriptionID = notification.subscriptionID else {
            return
        }
        
        handleRemoteNotification(subscriptionID: subscriptionID, completionHandler: completionHandler)
    }
}
#endif
