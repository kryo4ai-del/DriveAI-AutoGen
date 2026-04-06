import Foundation

protocol UserProgressProtocol {
    /// Total number of exam simulations completed by user
    var examSimulationCount: Int { get }
    
    /// Number of question categories user has unlocked (0-8)
    var unlockedCategoryCount: Int { get }
    
    /// Total questions answered across all sessions
    var totalQuestionsAnswered: Int { get }
    
    /// Date trial started for this user
    var trialStartDate: Date { get }
    
    /// Current correct answer rate (0.0 - 1.0)
    var accuracyRate: Double { get }
    
    /// Current exam streak (consecutive successful simulations)
    var examStreak: Int { get }
}