import Foundation
import Combine

// MARK: - Firestore Protocol Abstraction (replaces FirebaseFirestore dependency)

protocol FirestoreDocumentProtocol {
    var documentID: String { get }
    var exists: Bool { get }
    func data<T: Decodable>(as type: T.Type) throws -> T
}

protocol FirestoreCollectionProtocol {
    func document(_ documentID: String) -> FirestoreDocumentRefProtocol
    func getDocuments() async throws -> FirestoreQuerySnapshotProtocol
    func whereField(_ field: String, isEqualTo value: Any) -> FirestoreQueryProtocol
    func addSnapshotListener(_ listener: @escaping (FirestoreQuerySnapshotProtocol?, Error?) -> Void) -> ListenerRegistrationProtocol
}

protocol FirestoreQueryProtocol {
    func getDocuments() async throws -> FirestoreQuerySnapshotProtocol
}

protocol FirestoreDocumentRefProtocol {
    func getDocument() async throws -> FirestoreDocumentSnapshotProtocol
    func setData<T: Encodable>(from data: T, merge: Bool) throws
    func updateData(_ fields: [String: Any]) async throws
    func delete() async throws
    func addSnapshotListener(_ listener: @escaping (FirestoreDocumentSnapshotProtocol?, Error?) -> Void) -> ListenerRegistrationProtocol
}

protocol FirestoreDocumentSnapshotProtocol {
    var documentID: String { get }
    var exists: Bool { get }
    func data<T: Decodable>(as type: T.Type) throws -> T
}

protocol FirestoreQuerySnapshotProtocol {
    var documents: [FirestoreDocumentSnapshotProtocol] { get }
}

protocol ListenerRegistrationProtocol {
    func remove()
}

protocol WriteBatchProtocol {
    func setData(_ data: [String: Any], forDocument ref: FirestoreDocumentRefProtocol, merge: Bool)
    func updateData(_ fields: [String: Any], forDocument ref: FirestoreDocumentRefProtocol)
    func deleteDocument(_ ref: FirestoreDocumentRefProtocol)
    func commit() async throws
}

protocol FirestoreDatabaseProtocol {
    func collection(_ path: String) -> FirestoreCollectionProtocol
    func batch() -> WriteBatchProtocol
}

// MARK: - Firestore Errors

enum FirestoreError: LocalizedError {
    case documentNotFound
    case decodingFailed(underlying: Error)
    case encodingFailed(underlying: Error)
    case permissionDenied
    case authenticationFailed
    case quotaExceeded
    case networkUnavailable
    case unknownError

    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "The requested document was not found."
        case .decodingFailed(let error):
            return "Failed to decode document: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Failed to encode document: \(error.localizedDescription)"
        case .permissionDenied:
            return "Permission denied."
        case .authenticationFailed:
            return "Authentication failed."
        case .quotaExceeded:
            return "Quota exceeded."
        case .networkUnavailable:
            return "Network is unavailable."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

// MARK: - Batch Write Operations Protocol

protocol BatchWriteOperation {
    func apply(to batch: WriteBatchProtocol, firestore: FirestoreDatabaseProtocol) throws
}

// MARK: - Network Monitor

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private init() {}

    func reachabilityUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            continuation.yield(true)
        }
    }
}

// MARK: - Mock Firestore Implementation (used when FirebaseFirestore is unavailable)

final class MockFirestoreDatabase: FirestoreDatabaseProtocol {
    func collection(_ path: String) -> FirestoreCollectionProtocol {
        return MockFirestoreCollection(path: path)
    }

    func batch() -> WriteBatchProtocol {
        return MockWriteBatch()
    }
}

final class MockFirestoreCollection: FirestoreCollectionProtocol {
    let path: String

    init(path: String) {
        self.path = path
    }

    func document(_ documentID: String) -> FirestoreDocumentRefProtocol {
        return MockFirestoreDocumentRef(path: "\(path)/\(documentID)")
    }

    func getDocuments() async throws -> FirestoreQuerySnapshotProtocol {
        return MockQuerySnapshot(documents: [])
    }

    func whereField(_ field: String, isEqualTo value: Any) -> FirestoreQueryProtocol {
        return MockFirestoreQuery()
    }

    func addSnapshotListener(_ listener: @escaping (FirestoreQuerySnapshotProtocol?, Error?) -> Void) -> ListenerRegistrationProtocol {
        listener(MockQuerySnapshot(documents: []), nil)
        return MockListenerRegistration()
    }
}

final class MockFirestoreQuery: FirestoreQueryProtocol {
    func getDocuments() async throws -> FirestoreQuerySnapshotProtocol {
        return MockQuerySnapshot(documents: [])
    }
}

final class MockFirestoreDocumentRef: FirestoreDocumentRefProtocol {
    let path: String

    init(path: String) {
        self.path = path
    }

    func getDocument() async throws -> FirestoreDocumentSnapshotProtocol {
        return MockDocumentSnapshot(documentID: path.components(separatedBy: "/").last ?? "", exists: false)
    }

    func setData<T: Encodable>(from data: T, merge: Bool) throws {
        // No-op in mock
    }

    func updateData(_ fields: [String: Any]) async throws {
        // No-op in mock
    }

    func delete() async throws {
        // No-op in mock
    }

    func addSnapshotListener(_ listener: @escaping (FirestoreDocumentSnapshotProtocol?, Error?) -> Void) -> ListenerRegistrationProtocol {
        listener(MockDocumentSnapshot(documentID: path.components(separatedBy: "/").last ?? "", exists: false), nil)
        return MockListenerRegistration()
    }
}

final class MockDocumentSnapshot: FirestoreDocumentSnapshotProtocol {
    let documentID: String
    let exists: Bool
    private let rawData: [String: Any]

    init(documentID: String, exists: Bool, data: [String: Any] = [:]) {
        self.documentID = documentID
        self.exists = exists
        self.rawData = data
    }

    func data<T: Decodable>(as type: T.Type) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: rawData)
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}

final class MockQuerySnapshot: FirestoreQuerySnapshotProtocol {
    let documents: [FirestoreDocumentSnapshotProtocol]

    init(documents: [FirestoreDocumentSnapshotProtocol]) {
        self.documents = documents
    }
}

final class MockListenerRegistration: ListenerRegistrationProtocol {
    func remove() {}
}

final class MockWriteBatch: WriteBatchProtocol {
    func setData(_ data: [String: Any], forDocument ref: FirestoreDocumentRefProtocol, merge: Bool) {}
    func updateData(_ fields: [String: Any], forDocument ref: FirestoreDocumentRefProtocol) {}
    func deleteDocument(_ ref: FirestoreDocumentRefProtocol) {}
    func commit() async throws {}
}

// MARK: - FirestoreService

@MainActor
final class FirestoreService: ObservableObject {
    private let db: FirestoreDatabaseProtocol
    @Published private(set) var isOnline: Bool = true

    private var networkMonitorTask: Task<Void, Never>?

    init(database: FirestoreDatabaseProtocol = MockFirestoreDatabase()) {
        self.db = database
        setupNetworkMonitoring()
    }

    deinit {
        networkMonitorTask?.cancel()
    }

    private func setupNetworkMonitoring() {
        networkMonitorTask = Task {
            for await isReachable in NetworkMonitor.shared.reachabilityUpdates() {
                self.isOnline = isReachable
            }
        }
    }

    // MARK: - Single Document Operations

    nonisolated func fetchDocument<T: Decodable>(
        from collection: String,
        documentID: String,
        as type: T.Type
    ) async throws -> T {
        do {
            let document = try await db.collection(collection)
                .document(documentID)
                .getDocument()

            guard document.exists else {
                throw FirestoreError.documentNotFound
            }

            do {
                return try document.data(as: T.self)
            } catch {
                throw FirestoreError.decodingFailed(underlying: error)
            }
        } catch {
            throw mapError(error)
        }
    }

    nonisolated func saveDocument<T: Encodable>(
        _ data: T,
        to collection: String,
        documentID: String,
        merge: Bool = true
    ) async throws {
        do {
            try db.collection(collection)
                .document(documentID)
                .setData(from: data, merge: merge)
        } catch {
            throw mapError(error)
        }
    }

    nonisolated func updateDocument(
        in collection: String,
        documentID: String,
        fields: [String: Any]
    ) async throws {
        do {
            try await db.collection(collection)
                .document(documentID)
                .updateData(fields)
        } catch {
            throw mapError(error)
        }
    }

    nonisolated func deleteDocument(
        from collection: String,
        documentID: String
    ) async throws {
        do {
            try await db.collection(collection)
                .document(documentID)
                .delete()
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Collection Operations

    nonisolated func fetchCollection<T: Decodable>(
        from collection: String,
        as type: T.Type
    ) async throws -> [T] {
        do {
            let documents = try await db.collection(collection).getDocuments()

            return documents.documents.compactMap { document in
                do {
                    return try document.data(as: T.self)
                } catch {
                    print("⚠️ Failed to decode document \(document.documentID): \(error)")
                    return nil
                }
            }
        } catch {
            throw mapError(error)
        }
    }

    nonisolated func fetchCollection<T: Decodable>(
        from collection: String,
        as type: T.Type,
        where field: String,
        isEqualTo value: Any
    ) async throws -> [T] {
        do {
            let documents = try await db.collection(collection)
                .whereField(field, isEqualTo: value)
                .getDocuments()

            return documents.documents.compactMap { document in
                do {
                    return try document.data(as: T.self)
                } catch {
                    print("⚠️ Failed to decode document \(document.documentID): \(error)")
                    return nil
                }
            }
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Batch Operations

    nonisolated func batchWrite(_ operations: [BatchWriteOperation]) async throws {
        let batch = db.batch()

        for operation in operations {
            try operation.apply(to: batch, firestore: db)
        }

        do {
            try await batch.commit()
        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Real-Time Listeners (Fixed Memory Leak)

    nonisolated func listenToCollection<T: Decodable>(
        from collection: String,
        as type: T.Type
    ) -> AnyPublisher<[T], Error> {
        Future<[T], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FirestoreError.unknownError))
                return
            }

            let listener = self.db.collection(collection)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        promise(.failure(self.mapError(error)))
                        return
                    }

                    guard let snapshot = snapshot else { return }

                    let documents = snapshot.documents.compactMap { document in
                        try? document.data(as: T.self)
                    }

                    promise(.success(documents))
                }

            // ✅ Return cancellable that removes listener
            _ = AnyCancellable {
                listener.remove()
            }
        }
        .share()
        .eraseToAnyPublisher()
    }

    nonisolated func listenToDocument<T: Decodable>(
        from collection: String,
        documentID: String,
        as type: T.Type
    ) -> AnyPublisher<T?, Error> {
        Future<T?, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FirestoreError.unknownError))
                return
            }

            let listener = self.db.collection(collection)
                .document(documentID)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        promise(.failure(self.mapError(error)))
                        return
                    }

                    guard let snapshot = snapshot else { return }

                    if snapshot.exists {
                        do {
                            let data = try snapshot.data(as: T.self)
                            promise(.success(data))
                        } catch {
                            promise(.failure(self.mapError(error)))
                        }
                    } else {
                        promise(.success(nil))
                    }
                }

            _ = AnyCancellable {
                listener.remove()
            }
        }
        .share()
        .eraseToAnyPublisher()
    }

    // MARK: - Error Mapping

    nonisolated func mapError(_ error: Error) -> FirestoreError {
        if let firestoreError = error as? FirestoreError {
            return firestoreError
        }

        // Check network errors
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost,
                 .timedOut:
                return .networkUnavailable
            default:
                return .unknownError
            }
        }

        // Check NSError domain for Firestore-like errors
        let nsError = error as NSError
        switch nsError.code {
        case 7:
            return .permissionDenied
        case 16:
            return .authenticationFailed
        case 5:
            return .documentNotFound
        case 8:
            return .quotaExceeded
        case 14, 4, 13:
            return .networkUnavailable
        default:
            return .unknownError
        }
    }
}

// MARK: - Batch Operations (Type-Safe)

struct SetBatchOperation<T: Encodable>: BatchWriteOperation {
    let collection: String
    let documentID: String
    let data: T
    let merge: Bool

    func apply(to batch: WriteBatchProtocol, firestore: FirestoreDatabaseProtocol) throws {
        let ref = firestore.collection(collection).document(documentID)
        do {
            let encoded = try encodeToDict(data)
            batch.setData(encoded, forDocument: ref, merge: merge)
        } catch {
            throw FirestoreError.encodingFailed(underlying: error)
        }
    }

    private func encodeToDict(_ value: T) throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(value)
        let obj = try JSONSerialization.jsonObject(with: jsonData)
        guard let dict = obj as? [String: Any] else {
            throw FirestoreError.encodingFailed(underlying: NSError(domain: "Encoding", code: -1))
        }
        return dict
    }
}

struct UpdateBatchOperation: BatchWriteOperation {
    let collection: String
    let documentID: String
    let fields: [String: Any]

    func apply(to batch: WriteBatchProtocol, firestore: FirestoreDatabaseProtocol) throws {
        let ref = firestore.collection(collection).document(documentID)
        batch.updateData(fields, forDocument: ref)
    }
}

struct DeleteBatchOperation: BatchWriteOperation {
    let collection: String
    let documentID: String

    func apply(to batch: WriteBatchProtocol, firestore: FirestoreDatabaseProtocol) throws {
        let ref = firestore.collection(collection).document(documentID)
        batch.deleteDocument(ref)
    }
}