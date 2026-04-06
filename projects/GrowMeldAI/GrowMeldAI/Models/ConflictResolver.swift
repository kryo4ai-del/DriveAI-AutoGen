protocol ConflictResolver {
    associatedtype Model
    func resolve(local: Model, remote: Model, context: ConflictContext) -> Model
}

struct ProgressConflictResolver: ConflictResolver {
    typealias Model = Progress
    
    func resolve(local: Progress, remote: Progress, context: ConflictContext) -> Progress {
        // Server timestamp always wins for answers
        return context.remoteTimestamp > context.localTimestamp ? remote : local
    }
}

struct ExamDateConflictResolver: ConflictResolver {
    typealias Model = User
    
    func resolve(local: User, remote: User, context: ConflictContext) -> User {
        // Client (user) owns exam date
        var merged = remote
        merged.examDate = local.examDate
        return merged
    }
}