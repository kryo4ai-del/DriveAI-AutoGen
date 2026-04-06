@MainActor
final class PlantDatabaseService: ObservableObject {
    private let queue = DispatchQueue(label: "com.driveai.plantdb")
    
    func savePlant(_ plant: PlantIdentity) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    let data = try encoder.encode(plant)
                    
                    let fileURL = self.plantsDirectory
                        .appendingPathComponent("\(plant.id.uuidString).json")
                    try data.write(to: fileURL, options: .atomic)
                    
                    DispatchQueue.main.async {
                        self.savedPlants.insert(plant, at: 0)
                        continuation.resume()
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func loadSavedPlants() {
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let files = try self.fileManager.contentsOfDirectory(
                    at: self.plantsDirectory,
                    includingPropertiesForKeys: nil
                ).filter { $0.pathExtension == "json" }
                
                let plants = try files
                    .compactMap { url in
                        try decoder.decode(PlantIdentity.self, 
                                          from: try Data(contentsOf: url))
                    }
                    .sorted { $0.recognizedAt > $1.recognizedAt }
                
                await MainActor.run {
                    self.savedPlants = plants
                }
            } catch {
                print("❌ Failed to load plants: \(error)")
            }
        }
    }
}