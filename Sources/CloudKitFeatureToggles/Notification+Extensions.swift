//
//  Notification+Extensions.swift
//  CloudKitFeatureToggles
//
//  Created by Jonas Reichert on 06.01.20.
//

import Foundation

extension Notification.Name {
    public static let onRecordsUpdated = Notification.Name("ckFeatureTogglesRecordsUpdatedNotification")
}

extension Notification {
    public static let featureTogglesUserInfoKey = "featureToggles"
}
