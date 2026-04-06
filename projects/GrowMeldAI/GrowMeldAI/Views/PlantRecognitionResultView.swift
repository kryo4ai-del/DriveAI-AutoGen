import SwiftUI

struct PlantRecognitionResultView: View {
    let result: PlantRecognitionResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(result.plantName)
                    .font(.title)
                    .fontWeight(.bold)

                Text("Erkennungswahrscheinlichkeit: \(Int(result.confidence * 100))%")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                Text("Beschreibung")
                    .font(.headline)

                Text(result.description)
                    .font(.body)

                Divider()

                Text("Weiterführende Theorie")
                    .font(.headline)

                Text(result.relatedTheory)
                    .font(.body)
                    .foregroundStyle(.blue)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Pflanzenerkennung")
        .navigationBarTitleDisplayMode(.inline)
    }
}