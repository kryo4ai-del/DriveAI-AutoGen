import Foundation
import Security

protocol TrialPersistence {
    func saveTrialStart(_ date: Date) throws
    func getTrialStartDate() -> Date?
    func savePurchaseToken(_ token: String) throws
    func getPurchaseToken() -> String?
    func clear() throws
}

// MARK: - Keychain Service
