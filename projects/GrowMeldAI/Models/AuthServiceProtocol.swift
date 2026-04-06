// AuthServiceProtocol - simplified
import Foundation

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    func signOut() async throws
    var isAuthenticated: Bool { get }
}
