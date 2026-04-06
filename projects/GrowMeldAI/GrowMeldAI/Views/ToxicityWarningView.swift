// File: ToxicityWarning.swift
import Foundation

/// Represents a toxicity warning for hazardous substances that may affect children or pets
/// Conforms to Identifiable, Codable, and Hashable for persistence and UI integration
struct ToxicityWarning: Identifiable, Codable, Hashable {
    let id: UUID
    let substanceName: String
    let warningLevel: WarningLevel
    let affectedGroups: [AffectedGroup]
    let safetyMessage: String
    let motivationalPrompt: String
    let examRelevance: ExamRelevance

    /// Creates a toxicity warning with all required safety and motivational context
    /// - Parameters:
    ///   - substanceName: The name of the hazardous substance
    ///   - warningLevel: The severity level of the warning
    ///   - affectedGroups: Groups at risk (children, pets, etc.)
    ///   - examRelevance: How this relates to driver's license exam questions
    init(
        substanceName: String,
        warningLevel: WarningLevel,
        affectedGroups: [AffectedGroup],
        examRelevance: ExamRelevance
    ) {
        self.id = UUID()
        self.substanceName = substanceName
        self.warningLevel = warningLevel
        self.affectedGroups = affectedGroups
        self.examRelevance = examRelevance

        // Generate emotionally resonant safety message
        self.safetyMessage = Self.generateSafetyMessage(
            substance: substanceName,
            groups: affectedGroups,
            level: warningLevel
        )

        // Generate motivational prompt for exam preparation
        self.motivationalPrompt = Self.generateMotivationalPrompt(
            substance: substanceName,
            examRelevance: examRelevance
        )
    }

    private static func generateSafetyMessage(
        substance: String,
        groups: [AffectedGroup],
        level: WarningLevel
    ) -> String {
        let groupNames = groups.map { $0.displayName }.joined(separator: " und ")
        let warningPrefix: String

        switch level {
        case .low:
            warningPrefix = "Vorsicht!"
        case .medium:
            warningPrefix = "Achtung!"
        case .high:
            warningPrefix = "Warnung!"
        }

        return "\(warningPrefix) Diese Substanz (\(substance)) ist gefährlich für \(groupNames)."
    }

    private static func generateMotivationalPrompt(
        substance: String,
        examRelevance: ExamRelevance
    ) -> String {
        let examTip: String

        switch examRelevance {
        case .direct:
            examTip = "Achte besonders auf Fragen zu gefährlichen Stoffen in der Theorieprüfung!"
        case .indirect:
            examTip = "Dieses Wissen könnte in der Theorieprüfung relevant sein."
        case .none:
            examTip = "Merke dir diese Information für sicheres Fahren im Alltag."
        }

        return "\(examTip) Schütze deine Lieben und bereite dich gut vor!"
    }
}

/// Defines the severity level of a toxicity warning
enum WarningLevel: String, Codable, Hashable, Comparable {
    case low
    case medium
    case high

    var displayName: String {
        switch self {
        case .low: return "Niedrig"
        case .medium: return "Mittel"
        case .high: return "Hoch"
        }
    }

    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "red"
        }
    }
}

/// Groups of people/animals that may be affected by toxic substances
enum AffectedGroup: String, Codable, Hashable {
    case children
    case pets
    case elderly
    case pregnant
    case generalPublic

    var displayName: String {
        switch self {
        case .children: return "Kinder"
        case .pets: return "Haustiere"
        case .elderly: return "ältere Menschen"
        case .pregnant: return "Schwangere"
        case .generalPublic: return "alle"
        }
    }
}

/// Indicates how relevant this warning is to the driver's license exam
enum ExamRelevance: String, Codable, Hashable {
    case direct   // Directly appears in official question catalog
    case indirect // Related but not directly tested
    case none     // Not exam-relevant but important for safety
}

// MARK: - View Components

/// A view that displays a toxicity warning with appropriate styling
struct ToxicityWarningView: View {
    let warning: ToxicityWarning

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(warning.safetyMessage)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(warning.warningLevel.displayName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(4)
                    .background(Color(warning.warningLevel.color))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }

            Text(warning.motivationalPrompt)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if warning.examRelevance != .none {
                ExamRelevanceBadge(relevance: warning.examRelevance)
            }

            if !warning.affectedGroups.isEmpty {
                HStack {
                    Text("Betroffene Gruppen:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(warning.affectedGroups, id: \.self) { group in
                        Text(group.displayName)
                            .font(.caption)
                            .padding(4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.orange.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

/// A badge showing the exam relevance of a warning
private struct ExamRelevanceBadge: View {
    let relevance: ExamRelevance

    var body: some View {
        Text(relevance.rawValue.capitalized)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(4)
            .background(
                relevance == .direct ? Color.blue :
                relevance == .indirect ? Color.orange : Color.gray
            )
            .foregroundColor(.white)
            .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    let sampleWarning = ToxicityWarning(
        substanceName: "Ethylenglykol",
        warningLevel: .high,
        affectedGroups: [.children, .pets],
        examRelevance: .direct
    )

    return NavigationStack {
        List {
            ToxicityWarningView(warning: sampleWarning)
        }
        .listStyle(.plain)
        .navigationTitle("Gefahrstoffwarnung")
    }
}