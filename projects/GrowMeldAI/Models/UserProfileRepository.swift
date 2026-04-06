protocol UserProfileRepository: AnyObject {
    func fetchCurrentUser() async throws -> User
    func updateExamDate(_ date: Date) async throws
    func updateDisplayName(_ name: String) async throws
    var userPublisher: AnyPublisher<User?, Never> { get }
}