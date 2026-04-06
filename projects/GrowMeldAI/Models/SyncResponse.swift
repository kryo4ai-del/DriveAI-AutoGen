import Foundation
struct SyncResponse: Codable, Equatable {
    let success: Bool
    let message: String
    let syncedAt: Date
    let examResultId: UUID
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case syncedAt = "synced_at"
        case examResultId = "exam_result_id"
    }
    
    static func mockSuccess(
        examResultId: UUID = UUID()
    ) -> SyncResponse {
        SyncResponse(
            success: true,
            message: "Erfolgreich synchronisiert",
            syncedAt: Date(),
            examResultId: examResultId
        )
    }
}
