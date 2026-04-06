// Views/PlantIdentificationView.swift
import SwiftUI

struct PlantIdentificationView: View {
    @StateObject var viewModel: PlantIdentificationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                switch viewModel.state {
                case .idle, .capturing:
                    CameraCaptureView(image: $viewModel.capturedImage)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()

                case .processing:
                    ProgressView("Erkenne Pflanze...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(1.5)

                case .result(let identification):
                    IdentificationResultView(
                        identification: identification,
                        userConfidence: $viewModel.userConfidence,
                        selectedPlant: $viewModel.selectedPlant
                    )
                    .transition(.opacity)

                case .error(let error):
                    ErrorView(error: error) {
                        viewModel.reset()
                    }

                case .finished:
                    SuccessView {
                        viewModel.reset()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Pflanze erkennen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadHistory()
            }
        }
    }
}

private struct IdentificationResultView: View {
    let identification: PlantIdentification
    @Binding var userConfidence: Double
    @Binding var selectedPlant: Plant?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PlantImageView(imageData: identification.imageData)

                if let plant = selectedPlant {
                    PlantDetailsView(plant: plant)

                    ConfidenceSlider(value: $userConfidence, label: "Wie sicher bist du?")

                    if identification.confidence > 0.7 {
                        Text("Die KI ist sich sehr sicher")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}

private struct PlantImageView: View {
    let imageData: Data?

    var body: some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .foregroundStyle(.secondary)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct PlantDetailsView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(plant.commonName)
                .font(.title)
                .fontWeight(.bold)

            Text(plant.scientificName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Familie: \(plant.family)")
                Text("Essbar: \(plant.isEdible ? "Ja" : "Nein")")
                Text("Giftig: \(plant.isToxic ? "Ja" : "Nein")")
            }
            .font(.subheadline)

            Divider()

            Text("Beschreibung")
                .font(.headline)

            Text(plant.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

private struct ConfidenceSlider: View {
    @Binding var value: Double
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)

            Slider(value: $value, in: 0...1, step: 0.1)
                .tint(.green)

            HStack {
                Text("Unsicher")
                Spacer()
                Text("Sicher")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

private struct ErrorView: View {
    let error: PlantError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)

            Text("Fehler")
                .font(.title)
                .fontWeight(.bold)

            Text(error.errorDescription ?? "Unbekannter Fehler")
                .multilineTextAlignment(.center)
                .padding()

            Button("Erneut versuchen", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

private struct SuccessView: View {
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Erfolgreich gespeichert!")
                .font(.title)
                .fontWeight(.bold)

            Text("Deine Pflanzenerkennung wurde gespeichert.")
                .multilineTextAlignment(.center)

            Button("Fertig", action: onDone)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}