// Utilities/Environment/DeepLinkRouterKey.swift
import SwiftUI

struct DeepLinkRouterKey: EnvironmentKey {
    static let defaultValue: DeepLinkRouter = .shared
}

extension EnvironmentValues {
    var deepLinkRouter: DeepLinkRouter {
        get { self[DeepLinkRouterKey.self] }
        set { self[DeepLinkRouterKey.self] = newValue }
    }
}