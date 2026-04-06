import SwiftUI

struct ExperimentAssignmentItem: Identifiable {
    var id: String { experimentId }
    var experimentId: String
    var variantId: String
}

enum EventType: String {
    case impression
    case click
    case conversion
}

struct EventLogEntry: Identifiable {
    var id: UUID = UUID()
    var eventType: EventType
    var timestamp: Date
    var variantId: String
}

struct ExperimentDashboardView: View {
    var assignments: [ExperimentAssignmentItem] = []
    var eventLog: [EventLogEntry] = []

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Active Experiments")
                    .accessibilityLabel("Active A/B Testing Experiments")) {

                    ForEach(assignments, id: \.experimentId) { assignment in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(assignment.experimentId)
                                    .font(.headline)
                                    .accessibilityLabel("Experiment: \(assignment.experimentId)")

                                Text("Assigned Variant: \(assignment.variantId)")
                                    .font(.caption)
                                    .accessibilityValue(assignment.variantId)
                            }

                            Spacer()

                            // Manual variant switcher (QA tool)
                            Menu {
                                ForEach(["variant_a", "variant_b", "variant_c"], id: \.self) { variant in
                                    Button(variant) {
                                        switchVariant(assignment.experimentId, to: variant)
                                    }
                                    .accessibilityLabel("Switch to \(variant)")
                                }
                            } label: {
                                Label("Switch", systemImage: "arrow.triangle.swap")
                                    .accessibilityLabel("Switch variant for \(assignment.experimentId)")
                                    .accessibilityHint("Opens menu with available variants")
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                Section(header: Text("Event Log (Last 20)")
                    .accessibilityLabel("Recent event log entries")) {

                    ForEach(eventLog.prefix(20), id: \.id) { event in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.eventType.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .accessibilityLabel("Event type: \(event.eventType.rawValue)")

                                Text(event.timestamp.formatted(date: .omitted, time: .standard))
                                    .font(.caption)
                                    .accessibilityValue(event.timestamp.formatted())
                            }

                            Spacer()

                            Text(event.variantId)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .accessibilityLabel("Variant: \(event.variantId)")
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("A/B Testing Dashboard")
            .accessibilityLabel("Debug A/B Testing Dashboard")
        }
    }

    private func switchVariant(_ experimentId: String, to variant: String) {
        // Implementation
    }
}