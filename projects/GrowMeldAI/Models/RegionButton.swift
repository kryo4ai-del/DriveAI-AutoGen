// File: RegionButton.swift
import SwiftUI

struct RegionButton: View {
    let region: Region
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(region.name)
                    .font(.system(.body, design: .default))
                    .foregroundColor(isSelected ? .white : .primary)

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Color.wcagCompliant.primaryAction : Color.clear)
            .cornerRadius(12)
        }
        .accessibleButton(
            label: region.name,
            hint: isSelected ? "Selected" : "Tap to select this region",
            value: isSelected ? "Selected" : ""
        )
        .minimumTouchTarget()
    }
}