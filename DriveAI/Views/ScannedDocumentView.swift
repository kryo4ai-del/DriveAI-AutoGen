import SwiftUI

struct ScannedDocumentView: View {
    let document: ScannedDocument

    var body: some View {
        VStack(alignment: .leading) {
            Text("Scanned Document")
                .font(.title)
            Text(document.text)
                .padding()
            Spacer()
            Text("Scanned on: \(document.timestamp, formatter: DateFormatter())")
                .font(.footnote)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
        .navigationTitle("Document Details")
    }
}