import SwiftUI

struct TrafficSignRecognitionView: View {
    @StateObject private var viewModel = TrafficSignRecognitionViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                imageSection
                if viewModel.isAnalyzing {
                    analyzingIndicator
                } else if let result = viewModel.recognitionResult {
                    resultSection(result)
                } else if viewModel.selectedImage == nil {
                    placeholderPrompt
                }
            }
            .padding()
        }
        .navigationTitle("Traffic Signs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.showImagePicker = true }) {
                    Image(systemName: "photo.badge.plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            TrafficSignImagePicker { image in
                viewModel.selectImage(image)
            }
        }
    }

    // MARK: - Image section

    private var imageSection: some View {
        Group {
            if let image = viewModel.selectedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 260)
                        .cornerRadius(12)
                        .shadow(radius: 4)

                    Button(action: { viewModel.clearImage() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                }
            } else {
                Button(action: { viewModel.showImagePicker = true }) {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text("Import Traffic Sign Image")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Placeholder

    private var placeholderPrompt: some View {
        VStack(spacing: 8) {
            Image(systemName: "sign.yield")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("Import an image of a traffic sign to identify it.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Analyzing

    private var analyzingIndicator: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Analyzing sign…")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - Result

    private func resultSection(_ result: TrafficSignRecognitionResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Sign name + category
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    categoryBadge(result.signCategory)
                    Spacer()
                    confidenceBadge(result)
                }
                Text(result.signName)
                    .font(.title2)
                    .bold()
            }

            Divider()

            // Explanation
            VStack(alignment: .leading, spacing: 6) {
                Text("Explanation")
                    .font(.headline)
                Text(result.explanation)
                    .font(.body)
                    .foregroundColor(.primary)
            }

            // Confidence bar
            VStack(alignment: .leading, spacing: 6) {
                Text("Confidence")
                    .font(.headline)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(.systemGray5))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(confidenceColor(result.confidence))
                            .frame(width: geo.size.width * result.confidence, height: 10)
                    }
                }
                .frame(height: 10)
                Text("\(result.confidenceLabel) – \(result.confidencePercentage)%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private func categoryBadge(_ category: TrafficSignCategory) -> some View {
        Text(category.rawValue)
            .font(.caption)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor(category).opacity(0.15))
            .foregroundColor(categoryColor(category))
            .cornerRadius(6)
    }

    private func confidenceBadge(_ result: TrafficSignRecognitionResult) -> some View {
        Text("\(result.confidencePercentage)%")
            .font(.caption)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(confidenceColor(result.confidence).opacity(0.15))
            .foregroundColor(confidenceColor(result.confidence))
            .cornerRadius(6)
    }

    private func categoryColor(_ category: TrafficSignCategory) -> Color {
        switch category {
        case .prohibitory:   return .red
        case .mandatory:     return .blue
        case .warning:       return .orange
        case .priority:      return .yellow
        case .informational: return .green
        case .unknown:       return .gray
        }
    }

    private func confidenceColor(_ score: Double) -> Color {
        switch score {
        case 0.75...: return .green
        case 0.40...: return .orange
        default:      return .red
        }
    }
}

// MARK: - Image Picker wrapper

struct TrafficSignImagePicker: UIViewControllerRepresentable {
    let onPick: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onPick: (UIImage) -> Void
        init(onPick: @escaping (UIImage) -> Void) { self.onPick = onPick }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onPick(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
