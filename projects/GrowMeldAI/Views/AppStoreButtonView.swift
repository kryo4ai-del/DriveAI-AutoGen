// MARK: - AppStoreButtonView.swift
import SwiftUI

struct AppStoreButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image("apple-logo")
                    .resizable()
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Download on")
                        .font(.caption2)
                        .fontWeight(.medium)
                    Text("App Store")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Struct ScaleButtonStyle declared in Models/ScaleButtonStyle.swift
