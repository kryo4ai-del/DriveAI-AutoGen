import Foundation

// MARK: - Domain Models

struct FamilienfreigabeSetup: Identifiable, Codable {
    let id: UUID
    var parentEmail: String
    var childAccounts: [ChildAccount]
    var sharedPermissions: FamilienfreigabePermissions
    var isActive: Bool
    var createdAt: Date
    var lastModifiedAt: Date
    
    init(parentEmail: String) {
        self.id = UUID()
        self.parentEmail = parentEmail
        self.childAccounts = []
        self.sharedPermissions = FamilienfreigabePermissions()
        self.isActive = false
        self.createdAt = Date()
        self.lastModifiedAt = Date()
    }
}

struct ChildAccount: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var dateOfBirth: Date
    var isActive: Bool
    var lastSyncedAt: Date?
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
    init(name: String, email: String, dateOfBirth: Date) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.dateOfBirth = dateOfBirth
        self.isActive = true
        self.lastSyncedAt = nil
    }
}

struct FamilienfreigabePermissions: Codable {
    var canViewProgress: Bool = false
    var canViewAnswers: Bool = false
    var canSetReminders: Bool = false
    var canLimitPlayTime: Bool = false
    var canSeeDetailedStats: Bool = false
    var dataResidency: String = "EEA-only" // GDPR compliance
    var shareRecommendations: Bool = false
    
    mutating func resetToDefaults() {
        self = FamilienfreigabePermissions()
    }
}

struct ParentDashboardData: Identifiable {
    let id: UUID = UUID()
    let child: ChildAccount
    let progressPercentage: Double
    let questionsAnswered: Int
    let correctAnswers: Int
    let streak: Int
    let estimatedExamDate: Date?
    let lastActivity: Date?
    
    var score: Double {
        questionsAnswered > 0 ? Double(correctAnswers) / Double(questionsAnswered) * 100 : 0
    }
    
    var isActive: Bool {
        lastActivity != nil && Calendar.current.dateComponents([.day], from: lastActivity!, to: Date()).day ?? 0 < 7
    }
}

// MARK: - Accessibility Constants

enum AccessibilityIdentifier {
    static let familienfreigabeSetupFlow = "familienfreigabe.setup.flow"
    static let permissionToggle = "familienfreigabe.permission.toggle"
    static let childSelector = "familienfreigabe.child.selector"
    static let statusIndicator = "familienfreigabe.status.indicator"
    static let parentDashboard = "familienfreigabe.parent.dashboard"
}