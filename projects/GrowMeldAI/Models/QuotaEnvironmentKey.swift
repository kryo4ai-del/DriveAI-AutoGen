// Features/Freemium/Environment/QuotaEnvironmentKey.swift

import SwiftUI

struct QuotaEnvironmentKey: EnvironmentKey {
    static var defaultValue: QuotaManager {
        QuotaManager(store: UserDefaultsQuotaStore())
    }
}

extension EnvironmentValues {
    var quotaManager: QuotaManager {
        get { self[QuotaEnvironmentKey.self] }
        set { self[QuotaEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Modifier for Easy Setup

struct WithQuotaManager: ViewModifier {
    let store: QuotaStore
    @StateObject private var quotaManager: QuotaManager
    
    init(store: QuotaStore) {
        self.store = store
        _quotaManager = StateObject(wrappedValue: QuotaManager(store: store))
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.quotaManager, quotaManager)
    }
}

extension View {
    func withQuotaManager(_ store: QuotaStore = UserDefaultsQuotaStore()) -> some View {
        modifier(WithQuotaManager(store: store))
    }
}