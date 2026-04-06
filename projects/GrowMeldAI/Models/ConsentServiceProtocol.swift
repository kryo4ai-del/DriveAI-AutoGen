import Foundation
import SwiftUI

protocol ConsentServiceProtocol {
    func hasUserConsented(userId: UUID) async throws -> Bool
    func recordConsent(userId: UUID, timestamp: Date) async throws
    func getPrivacyPolicyText() -> String
}