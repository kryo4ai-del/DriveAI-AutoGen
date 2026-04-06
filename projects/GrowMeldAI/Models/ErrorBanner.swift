// Models/AppError.swift
import SwiftUI

// Views/ErrorBanner.swift
struct ErrorBanner: View {
    @Binding var error: AppError?
    
    var body: some View {
        if let error = error {
            VStack {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text(error.localizedDescription)
                    Spacer()
                    Button("Dismiss") { self.error = nil }
                }
                .padding(DesignTokens.Spacing.md)
                .background(ColorPalette.current.error.opacity(0.1))
                .cornerRadius(DesignTokens.Radius.md)
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}