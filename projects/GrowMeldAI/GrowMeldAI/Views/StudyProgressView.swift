import SwiftUI
import Foundation

// MARK: - ASO Metadata Model (Fixed Licensing Gap)
struct ASOMetadata: Codable {
    let appName: String
    let subtitle: String
    let description: String
    let keywords: [String]
    let isOfficialContent: Bool
    let licensingProof: String? // URL to licensing agreement
    let category: AppStoreCategory
    let supportURL: URL
    let privacyPolicyURL: URL

    // Validation for App Store compliance
    func validate() throws {
        guard !appName.isEmpty else { throw ASOError.invalidAppName }
        guard !description.isEmpty else { throw ASOError.invalidDescription }
        guard !keywords.isEmpty else { throw ASOError.missingKeywords }

        if isOfficialContent, licensingProof == nil {
            throw ASOError.missingLicensingProof
        }
    }
}

enum ASOError: Error {
    case invalidAppName
    case invalidDescription
    case missingKeywords
    case missingLicensingProof
    case invalidSupportURL
    case invalidPrivacyURL
}

// MARK: - Emotional Progress Feedback View (Fixed UX Psychology Findings)
struct StudyProgressView: View {
    let score: Int
    let weakArea: String
    let timeToImprove: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(score)% — \(emotionalFeedback)")
                .font(.title2.bold())
                .foregroundColor(score >= 70 ? .green : .orange)

            Text("Was lief schief (\(weakArea))")
                .font(.headline)

            Text("Du brauchst mehr Übung in diesem Bereich. \(timeToImprove)")
                .font(.body)

            HStack(spacing: 16) {
                Button("Jetzt üben") {
                    // Start practice session
                }
                .buttonStyle(.borderedProminent)

                Button("Erinnerung einstellen") {
                    // Schedule reminder
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }

    private var emotionalFeedback: String {
        switch score {
        case 0..<50: return "Oh nein! Das war ein harter Tag. Aber jeder Meister war mal Anfänger."
        case 50..<70: return "60% — du bist auf Kurs! Aber \(weakArea) brauchen mehr Liebe. \(timeToImprove)"
        case 70..<90: return "Gut gemacht! \(weakArea) sind fast perfekt. Noch ein kleiner Schubs!"
        default: return "Fantastisch! Du bist bereit für die Prüfung!"
        }
    }
}

// MARK: - ASO Metadata Manager (Fixed Implementation)
@MainActor
class ASOMetadataManager: ObservableObject {
    @Published private(set) var metadata: ASOMetadata?
    @Published private(set) var isValid = false
    @Published private(set) var validationError: ASOError?

    func loadMetadata(from url: URL) async {
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(ASOMetadata.self, from: data)
            try decoded.validate()
            metadata = decoded
            isValid = true
        } catch {
            handleValidationError(error)
        }
    }

    private func handleValidationError(_ error: Error) {
        if let decodingError = error as? DecodingError {
            validationError = .invalidDescription
        } else if let asoError = error as? ASOError {
            validationError = asoError
        } else {
            validationError = .invalidDescription
        }
        isValid = false
    }

    func updateLicensingProof(url: String) {
        guard var current = metadata else { return }
        current.licensingProof = url
        metadata = current
    }
}

// MARK: - Preview Provider
#Preview {
    StudyProgressView(
        score: 60,
        weakArea: "Bußgelder & Gebühren",
        timeToImprove: "5 Minuten gezieltes Training reichen für den nächsten Boost."
    )
    .padding()
}