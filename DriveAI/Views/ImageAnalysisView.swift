// Views/ImageAnalysisView.swift
import SwiftUI

struct ImageAnalysisView: View {
    @StateObject private var viewModel: ImageAnalysisViewModel

    init(viewModel: ImageAnalysisViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            loadingView
            imageView
            resultView
            errorView
        }
        .navigationTitle("Bildanalyse")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var loadingView: some View {
        if viewModel.isLoading {
            ProgressView("Analysiere...")
        }
    }

    private var imageView: some View {
        if let image = viewModel.selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
        }
    }

    private var resultView: some View {
        if let sign = viewModel.analyzedSign {
            Text("Übereinstimmendes Schild: \(sign.name)")
                .font(.headline)
            Text(sign.description)
                .font(.subheadline)
                .padding()
        }
    }

    private var errorView: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
        }
    }
}