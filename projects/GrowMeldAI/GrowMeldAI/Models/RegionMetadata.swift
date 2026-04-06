import Foundation

struct RegionMetadata: Identifiable, Codable {
    let id: String
    let region: Region
    let questionCount: Int
    let categoryCount: Int
    let examDuration: Int // minutes
    let questionsPerExam: Int
    let passingScore: Int // percentage
    
    static func metadata(for region: Region) -> RegionMetadata {
        switch region {
        case .dach:
            return RegionMetadata(
                id: "dach",
                region: .dach,
                questionCount: 1000,
                categoryCount: 10,
                examDuration: 60,
                questionsPerExam: 30,
                passingScore: 75
            )
        case .au_victoria:
            return RegionMetadata(
                id: "au_victoria",
                region: .au_victoria,
                questionCount: 850,
                categoryCount: 12,
                examDuration: 45,
                questionsPerExam: 40,
                passingScore: 80
            )
        case .ca_ontario:
            return RegionMetadata(
                id: "ca_ontario",
                region: .ca_ontario,
                questionCount: 750,
                categoryCount: 9,
                examDuration: 50,
                questionsPerExam: 40,
                passingScore: 80
            )
        }
    }
}