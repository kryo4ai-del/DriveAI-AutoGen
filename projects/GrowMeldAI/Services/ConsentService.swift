import Foundation

class ConsentService {
    static let shared = ConsentService()
    func hasConsent(for type: String) -> Bool { false }
    func grantConsent(for type: String) {}
    func revokeConsent(for type: String) {}
}
