import Foundation

protocol UserRepositoryProtocol {
    func fetchCurrentUser() async throws -> User
    func updateExamDate(_ date: Date) async throws
    func deleteUser() async throws
}