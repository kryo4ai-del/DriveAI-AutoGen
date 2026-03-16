import Foundation
protocol AssessmentPersistenceServiceProtocol: AnyObject {
    func save(_ assessment: ReadinessAssessment) async throws
    func fetchLatestAssessment() async throws -> ReadinessAssessment?
    func fetchAssessmentHistory(limit: Int) async throws -> [ReadinessAssessment]
    func deleteAssessment(_ id: UUID) async throws
}

@MainActor
final class AssessmentPersistenceService: AssessmentPersistenceServiceProtocol {
    private let fileManager = FileManager.default
    private let assessmentDir: URL
    
    init() throws {
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        assessmentDir = appSupport.appendingPathComponent("Assessments")
        try fileManager.createDirectory(at: assessmentDir, withIntermediateDirectories: true)
    }
    
    func save(_ assessment: ReadinessAssessment) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(assessment)
        let fileURL = assessmentDir.appendingPathComponent("\(assessment.id).json")
        try data.write(to: fileURL)
    }
    
    func fetchLatestAssessment() async throws -> ReadinessAssessment? {
        let files = try fileManager.contentsOfDirectory(at: assessmentDir, includingPropertiesForKeys: nil)
        let sorted = try files.sorted { url1, url2 in
            let attrs1 = try fileManager.attributesOfItem(atPath: url1.path)
            let attrs2 = try fileManager.attributesOfItem(atPath: url2.path)
            let date1 = attrs1[FileAttributeKey.modificationDate] as? Date ?? Date.distantPast
            let date2 = attrs2[FileAttributeKey.modificationDate] as? Date ?? Date.distantPast
            return date1 > date2
        }
        
        guard let latestURL = sorted.first else { return nil }
        let data = try Data(contentsOf: latestURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ReadinessAssessment.self, from: data)
    }
    
    func fetchAssessmentHistory(limit: Int) async throws -> [ReadinessAssessment] {
        let files = try fileManager.contentsOfDirectory(at: assessmentDir, includingPropertiesForKeys: nil)
        var assessments: [ReadinessAssessment] = []
        
        for url in files.prefix(limit) {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let assessment = try decoder.decode(ReadinessAssessment.self, from: data)
            assessments.append(assessment)
        }
        
        return assessments.sorted { $0.createdAt > $1.createdAt }
    }
    
    func deleteAssessment(_ id: UUID) async throws {
        let fileURL = assessmentDir.appendingPathComponent("\(id).json")
        try fileManager.removeItem(at: fileURL)
    }
}