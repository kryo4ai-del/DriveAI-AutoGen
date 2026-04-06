import SwiftUI
import Foundation
struct ConsentCard: View {
    @State private var isExpanded = false
    @State private var isProcessing = false  // ← Guard against double-submit
    
    let onAccept: () -> Void
    let onDefer: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ... existing content ...
            
            HStack(spacing: 12) {
                Button(action: {
                    guard !isProcessing else { return }
                    isProcessing = true
                    onDefer()
                    // Debounce: re-enable after 1s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isProcessing = false
                    }
                }) {
                    Text("Später entscheiden")
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(.gray.opacity(0.2))
                        .foregroundStyle(.primary)
                        .clipShape(.rect(cornerRadius: 8))
                }
                .disabled(isProcessing)
                .opacity(isProcessing ? 0.5 : 1.0)
                
                Button(action: {
                    guard !isProcessing else { return }
                    isProcessing = true
                    onAccept()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isProcessing = false
                    }
                }) {
                    Text("Ja, gerne!")
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(isProcessing ? .gray : .green)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 8))
                }
                .disabled(isProcessing)
            }
        }
    }
}