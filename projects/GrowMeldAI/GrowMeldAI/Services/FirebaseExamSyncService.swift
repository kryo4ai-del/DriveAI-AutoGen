class FirebaseExamSyncService: ExamSyncService {
    private let functions = Functions.functions()
    
    // Create fresh instances per call
    private var decoder: Firestore.Decoder {
        Firestore.Decoder()
    }
    
    private var encoder: Firestore.Encoder {
        Firestore.Encoder()
    }
    
    func submitExamResult(_ result: ExamResult) async throws -> SyncResponse {
        do {
            let encoded = try encoder.encode(result) // Fresh encoder
            let callable = functions.httpsCallable("submitExamResult")
            let result = try await callable.call(with: encoded as? [String: Any] ?? [:])
            
            guard let data = result.data as? [String: Any] else {
                throw CloudFunctionError.invalidResponse(statusCode: 200)
            }
            
            let response = try decoder.decode(SyncResponse.self, from: data) // Fresh decoder
            return response
        } catch let error as NSError {
            throw CloudFunctionError(from: error)
        } catch {
            throw CloudFunctionError.unknown(error.localizedDescription)
        }
    }
}