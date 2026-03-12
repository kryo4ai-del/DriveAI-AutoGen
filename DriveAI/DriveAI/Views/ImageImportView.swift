import SwiftUI
import PhotosUI

struct ImageImportView: View {
    @StateObject private var viewModel = ImageImportViewModel()
    @State private var selectedItem: PhotosPickerItem? // For image selection

    var body: some View {
        VStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .accessibilityLabel("Selected image for analysis")
                
                if let analysis = viewModel.analysisResult {
                    AnalysisResultView(result: analysis)
                }
            } else {
                Text("Select an image to analyze")
                    .font(.title)
                    .padding()
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .accessibilityLabel(errorMessage) // For better accessibility
            }

            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Import Image")
                    .accessibilityLabel("Tap to import an image from the library")
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    guard let selectedItem = newItem,
                          let data = try? await selectedItem.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data) else { return }
                    viewModel.importImage(uiImage)
                }
            }
        }
        .padding()
        .navigationTitle("Import Screenshot")
    }
}