import SwiftUI

struct LocationFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        VStack {
            TextField("Nach Region suchen", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()
                .accessibilityLabel("Nach Region suchen")

            Spacer()

            Button("Bestätigen") { dismiss() }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .padding()
        }
    }
}