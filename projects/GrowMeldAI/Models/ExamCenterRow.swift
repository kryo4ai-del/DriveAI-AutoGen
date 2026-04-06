import SwiftUI

struct ExamCenterRow: View {
    let center: ExamCenter
    let distance: Double?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(center.name)
                    .font(.headline)
                Text(center.address)
                    .font(.body)
                    .foregroundColor(.secondary)
                if let distance = distance {
                    Text(String(format: "%.1f km", distance))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .buttonStyle(.plain)
    }
}
