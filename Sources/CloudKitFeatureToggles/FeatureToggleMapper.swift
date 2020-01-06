//
//  FeatureToggleMapper.swift
//  CloudKitFeatureToggles
//
//  Created by Jonas Reichert on 06.01.20.
//

import Foundation
import CloudKit

public protocol FeatureToggleRepresentable {
    var identifier: String { get }
    var isActive: Bool { get }
}

public protocol FeatureToggleIdentifiable {
    var identifier: String { get }
    var fallbackValue: Bool { get }
}

public struct FeatureToggle: FeatureToggleRepresentable, Equatable {
    public let identifier: String
    public let isActive: Bool
}

protocol FeatureToggleMappable {
    func map(record: CKRecord) -> FeatureToggle?
}

class FeatureToggleMapper: FeatureToggleMappable {
    func map(record: CKRecord) -> FeatureToggle? {
        return nil
    }
}
