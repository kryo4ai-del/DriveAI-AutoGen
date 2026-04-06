import SwiftUI
struct CameraStatusOverlay: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(spacing: 12) {
            // ✅ USE SEMANTIC FONT SIZES
            HStack {
                Text("Fokus:")
                    .font(.body)  // Scales with Dynamic Type
                
                Text(viewModel.focusMode.description)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .accessibilityElement(children: .combine)
            
            // ✅ ZOOM DISPLAY (responsive to Dynamic Type)
            HStack {
                Text("Zoom:")
                    .font(.body)
                
                Text("\(Int(viewModel.zoomLevel * 100))%")
                    .font(.title3)
                    .monospacedDigit() // Better digit alignment
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue("\(Int(viewModel.zoomLevel * 100)) Prozent")
            
            // ✅ FRAME COUNT (accessibility label)
            HStack {
                Image(systemName: "photo")
                    .accessibilityHidden(true)
                
                Text("\(viewModel.capturedFrameCount) Frames")
                    .font(.caption)
            }
            .accessibilityLabel("Aufgenommene Frames: \(viewModel.capturedFrameCount)")
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(8)
        
        // ✅ LAYOUT ADJUSTS TO LARGE TEXT
        .lineLimit(dynamicTypeSize >= .xxxLarge ? 2 : 1)
        .minimumScaleFactor(0.8)
    }
}

// ✅ PREVIEW WITH LARGE DYNAMIC TYPE
#Preview {
    CameraStatusOverlay()
        .environment(\.dynamicTypeSize, .xxxLarge)
}