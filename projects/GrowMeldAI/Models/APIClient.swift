// Sources/Services/Network/APIClient.swift

@MainActor
final class APIClient: ObservableObject {
    @Published var isOnline: Bool = true
    
    private let session: URLSession
    private let networkMonitor: NetworkMonitor
    
    init(networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 5.0
        self.session = URLSession(configuration: config)
    }
    
    func send(_ request: RetryQueue.PendingRequest) async throws -> (Data, URLResponse) {
        guard networkMonitor.isConnected else {
            throw NetworkError.offline
        }
        
        var urlRequest = try buildRequest(request)
        
        return try await withTimeout(5.0) {
            try await session.data(for: urlRequest)
        }
    }
    
    private func buildRequest(_ request: RetryQueue.PendingRequest) throws -> URLRequest {
        guard let url = URL(string: request.endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue.uppercased()
        urlRequest.httpBody = request.payload
        
        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return urlRequest
    }
    
    private func withTimeout<T>(
        _ interval: TimeInterval,
        block: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await block()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                throw NetworkError.timeout
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}
