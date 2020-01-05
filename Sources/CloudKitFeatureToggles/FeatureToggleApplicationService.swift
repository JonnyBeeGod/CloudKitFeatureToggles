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
    func handleNotification(subscriptionID: String, completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    #endif
}

public class FeatureToggleApplicationService: FeatureToggleApplicationServiceProtocol {
    
    private let featureToggleSubscriptor: CloudKitSubscriptionProtocol
    private (set) public var featureToggleRepository: FeatureToggleRepository
    
    public convenience init(featureToggleRepository: FeatureToggleRepository = FeatureToggleUserDefaultsRepository()) {
        self.init(featureToggleSubscriptor: FeatureToggleSubscriptor(toggleRepository: featureToggleRepository), featureToggleRepository: featureToggleRepository)
        self.featureToggleRepository = featureToggleRepository
    }
    
    init(featureToggleSubscriptor: CloudKitSubscriptionProtocol = FeatureToggleSubscriptor(), featureToggleRepository: FeatureToggleRepository) {
        self.featureToggleSubscriptor = featureToggleSubscriptor
        self.featureToggleRepository = featureToggleRepository
    }
    
    #if canImport(UIKit)
    public func register(application: UIApplication) {
        application.registerForRemoteNotifications()
        featureToggleSubscriptor.saveSubscriptions()
        featureToggleSubscriptor.fetchAllProviders()
    }
    
    public func handleNotification(subscriptionID: String, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        featureToggleSubscriptor.handleNotification(subscriptionID: notification.subscriptionID, completionHandler: completionHandler)
    }
    #endif
}

#if canImport(UIKit)
extension FeatureToggleApplicationService: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        register(application: application)
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {
            return
        }
        
        handleNotification(subscriptionID: notification.subscriptionID, completionHandler: completionHandler)
    }
}
#endif
