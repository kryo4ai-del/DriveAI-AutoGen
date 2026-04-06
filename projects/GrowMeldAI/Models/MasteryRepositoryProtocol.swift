protocol MasteryRepositoryProtocol {
    func saveMastery(_ record: MasteryRecord)
    func fetchAll() -> [MasteryRecord]
    func fetchByCategory(id: String) -> MasteryRecord?
    func deleteAll()
}

final class MasteryRepository: MasteryRepositoryProtocol {
    private let localDataService: LocalDataService
    private let tableName = "mastery_records"
    
    init(localDataService: LocalDataService) {
        self.localDataService = localDataService
        createTableIfNeeded()
    }
    
    func saveMastery(_ record: MasteryRecord) {
        let encoder = JSONEncoder()
        if let json = try? encoder.encode(record) {
            localDataService.save(
                table: tableName,
                data: json,
                key: record.id.uuidString
            )
        }
    }
    
    func fetchAll() -> [MasteryRecord] {
        let decoder = JSONDecoder()
        let allRecords = localDataService.fetchAll(table: tableName)
        
        return allRecords.compactMap { jsonData in
            try? decoder.decode(MasteryRecord.self, from: jsonData)
        }
    }
    
    func fetchByCategory(id: String) -> MasteryRecord? {
        fetchAll().first { $0.categoryId == id }
    }
    
    func deleteAll() {
        localDataService.deleteAll(table: tableName)
    }
    
    // MARK: - Private
    
    private func createTableIfNeeded() {
        // Ensure SQLite table exists for mastery records
        // (Implementation depends on your LocalDataService schema)
    }
}