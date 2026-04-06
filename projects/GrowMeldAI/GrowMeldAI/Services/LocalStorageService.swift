import Foundation

@MainActor
class LocalStorageService {
    private let storageQueue = DispatchQueue(
        label: "com.driveai.storage",
        attributes: .concurrent
    )
    private let defaults = UserDefaults.standard
    
    func incrementStreak() throws {
        var error: Error?
        storageQueue.sync(flags: .barrier) { [weak self] in
            do {
                var user = self?.getUser() ?? User()
                user.currentStreak += 1
                user.lastAnsweredDate = Date()
                try self?.saveUser(user)
            } catch {
                error = error  // Capture error
            }
        }
        if let error = error { throw error }
    }
    
    func resetStreak() throws {
        var error: Error?
        storageQueue.sync(flags: .barrier) { [weak self] in
            do {
                var user = self?.getUser() ?? User()
                user.currentStreak = 0
                try self?.saveUser(user)
            } catch {
                error = error
            }
        }
        if let error = error { throw error }
    }
}