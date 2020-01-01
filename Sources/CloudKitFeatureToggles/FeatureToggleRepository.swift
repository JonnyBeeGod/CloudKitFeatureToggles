//
//  FeatureToggleManager.swift
//  CloudKitFeatureToggles
//
//  Created by Jonas Reichert on 01.01.20.
//

import Foundation

public protocol FeatureToggleRepresentable {
    var identifier: String { get }
    var isActive: Bool { get }
}

public protocol FeatureToggleIdentifiable {
    var identifier: String { get }
    var fallbackValue: Bool { get }
}

public protocol FeatureToggleRetrievable {
    /// retrieves a stored `FeatureToggleRepresentable` from the underlying store.
    func retrieve(identifiable: FeatureToggleIdentifiable) -> FeatureToggleRepresentable
}

protocol FeatureToggleRepository: FeatureToggleRetrievable {
    /// saves a supplied `FeatureToggleRepresentable` to the underlying store
    func save(featureToggle: FeatureToggleRepresentable)
}

struct FeatureToggle: FeatureToggleRepresentable {
    let identifier: String
    let isActive: Bool
}

public class FeatureToggleUserDefaultsRepository {
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
}

extension FeatureToggleUserDefaultsRepository: FeatureToggleRepository {
    public func retrieve(identifiable: FeatureToggleIdentifiable) -> FeatureToggleRepresentable {
        let isActive = defaults.value(forKey: identifiable.identifier) as? Bool
        
        return FeatureToggle(identifier: identifiable.identifier, isActive: isActive ?? identifiable.fallbackValue)
    }
    
    func save(featureToggle: FeatureToggleRepresentable) {
        defaults.set(featureToggle.isActive, forKey: featureToggle.identifier)
    }
}
