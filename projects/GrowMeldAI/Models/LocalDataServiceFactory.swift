final class LocalDataServiceFactory {
    static func create(at path: String? = nil) throws -> LocalDataService {
        let actor = LocalDataService()
        try await actor.initialize(path: path)
        return actor
    }
}
