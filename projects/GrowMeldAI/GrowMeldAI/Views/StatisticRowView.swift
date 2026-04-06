// Sources/Shared/Components/StatisticRowView.swift
import SwiftUI

struct StatisticRowView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)

            Text(title)
                .font(.subheadline)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
        }
        .padding(.vertical, 8)
    }
}