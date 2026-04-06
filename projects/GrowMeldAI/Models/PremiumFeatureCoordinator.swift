// PremiumFeatureCoordinator.swift
import SwiftUI

@MainActor
struct PremiumFeatureCoordinator: View {
    @State private var isPresented: Bool = true

    var body: some View {
        NavigationStack {
            PremiumFeatureView()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { isPresented = false }) {
                            Text("Schließen")
                        }
                    }
                }
        }
    }
}

#Preview {
    PremiumFeatureCoordinator()
}