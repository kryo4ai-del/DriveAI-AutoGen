import SwiftUI

struct ScannedDocumentView: View {
    let document: ScannedDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(document.text)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Text("Scanned on: \(document.timestamp.formatted(date: .long, time: .shortened))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Scanned Document")
        .navigationBarTitleDisplayMode(.inline)
    }
}
