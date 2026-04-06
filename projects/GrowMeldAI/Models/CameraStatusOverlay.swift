import SwiftUI

struct CameraStatusOverlay: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var focusMode: String = "Auto"
    var zoomLevel: Double = 1.0
    var capturedFrameCount: Int = 0

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Fokus:")
                    .font(.body)

                Text(focusMode)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .accessibilityElement(children: .combine)

            HStack {
                Text("Zoom:")
                    .font(.body)

                Text("\(Int(zoomLevel * 100))%")
                    .font(.title3)
                    .monospacedDigit()
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue("\(Int(zoomLevel * 100)) Prozent")

            HStack {
                Image(systemName: "photo")
                    .accessibilityHidden(true)

                Text("\(capturedFrameCount) Frames")
                    .font(.caption)
            }
            .accessibilityLabel("Aufgenommene Frames: \(capturedFrameCount)")
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(8)
        .lineLimit(dynamicTypeSize >= .xxxLarge ? 2 : 1)
        .minimumScaleFactor(0.8)
    }
}

#Preview {
    CameraStatusOverlay()
        .environment(\.dynamicTypeSize, .xxxLarge)
}