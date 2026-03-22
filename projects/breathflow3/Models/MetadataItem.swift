// Models/MetadataItem.swift
import SwiftUI

struct MetadataItem: View {
    let icon: String
    let value: String
    let color: Color
    let label: String  // "questions", "minutes", "attempts"

    var body: some View {
        Label {
            Text(value)
                .font(.caption)
                .foregroundColor(.secondary)
        } icon: {
            Image(systemName: icon)
                .foregroundColor(color)
        }
        .accessibilityLabel("\(label): \(value)")
    }
}
