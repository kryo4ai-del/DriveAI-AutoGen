// Models/AppPath.swift
import Foundation

/// Single source of truth for all app navigation paths
/// Type-safe, enables deep linking, testable
enum AppPath: Hashable, Identifiable {
    case home
    case onboarding
    case categoryList
    case categoryDetail(id: UUID)
    case question(id: UUID, categoryId: UUID)
    case examSimulation(sessionId: UUID)
    case examResult(sessionId: UUID)
    case profile
    
    var id: String {
        String(describing: self)
    }
    
    /// Enables NavigationStack to handle path correctly
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AppPath, rhs: AppPath) -> Bool {
        lhs.id == rhs.id
    }
}