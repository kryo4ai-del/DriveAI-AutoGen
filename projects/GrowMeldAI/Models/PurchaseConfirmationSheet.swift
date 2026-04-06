// PurchaseConfirmationSheet.swift
import SwiftUI

struct PurchaseConfirmationSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(spacing: 24) {
            if reduceMotion {
                // Static celebration icon for users with motion sensitivity
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            } else {
                // Play animated Lottie for users without motion sensitivity
                LottieView(animationName: "celebration")
                    .frame(height: 200)
            }
            
            Text("Geschafft!")
                .font(.headline)
            
            Button("Weiter") { dismiss() }
        }
    }
}