// MARK: - QuestionIdentificationView.swift
import SwiftUI
import Vision
import CoreML

struct QuestionIdentificationView: View {
    @StateObject private var viewModel = QuestionIdentificationViewModel()
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerView()
                        
                        // State-specific content
                        contentView()
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
                    .onChange(of: selectedImage) { newImage in
                        if let image = newImage {
                            Task {
                                await viewModel.analyzeImage(image)
                            }
                        }
                    }
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
                    .onChange(of: selectedImage) { newImage in
                        if let image = newImage {
                            Task {
                                await viewModel.analyzeImage(image)
                            }
                        }
                    }
            }
            .navigationTitle("Frage identifizieren")
        }
        .accessibilityElement(children: .contain)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("KI-Identifikation")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Fotografieren Sie eine Prüfungsfrage")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        switch viewModel.state {
        case .idle:
            idleView()
        case .processing:
            processingView()
        case .analyzing:
            analyzingView()
        case .success(let question):
            successView(question: question)
        case .fallback:
            fallbackView()
        case .timeout:
            timeoutView()
        case .error(let message):
            errorView(message: message)
        }
    }
    
    @ViewBuilder
    private func idleView() -> some View {
        VStack(spacing: 16) {
            // Camera button (primary)
            Button(action: { showingCamera = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mit Kamera fotografieren")
                            .font(.body)
                            .fontWeight(.semibold)
                        Text("<3 Sekunden")
                            .font(.caption)
                            .opacity(0.7)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .accessibilityLabel("Mit Kamera fotografieren. Identifizierung dauert weniger als 3 Sekunden.")
            
            // Photo library button (secondary)
            Button(action: { showingImagePicker = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Aus Galerie wählen")
                            .font(.body)
                            .fontWeight(.semibold)
                        Text("Gespeicherte Fotos")
                            .font(.caption)
                            .opacity(0.7)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
            .accessibilityLabel("Foto aus Galerie wählen")
            
            // Tips card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    Text("Tipps für beste Ergebnisse")
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    tipItem("Gute Beleuchtung")
                    tipItem("Keine Unschärfe")
                    tipItem("Komplette Frage sichtbar")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.orange.opacity(0.08))
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private func tipItem(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.small")
                .font(.system(size: 12))
                .foregroundColor(.orange)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private func processingView() -> some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.3)
            
            Text("Bild wird verarbeitet...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func analyzingView() -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(
                        Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: viewModel.elapsedTime
                    )
            }
            
            VStack(spacing: 4) {
                Text("Frage wird analysiert...")
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(String(format: "%.1f / 3.0 Sekunden", viewModel.elapsedTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func successView(question: Question) -> some View {
        VStack(spacing: 16) {
            // Success badge
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.green)
                
                VStack(spacing: 4) {
                    Text("Frage gefunden!")
                        .font(.headline)
                    
                    if viewModel.elapsedTime < 3.0 {
                        Label(
                            String(format: "%.2f Sekunden", viewModel.elapsedTime),
                            systemImage: "bolt.fill"
                        )
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.green.opacity(0.08))
            .cornerRadius(12)
            
            // Question preview
            VStack(alignment: .leading, spacing: 8) {
                Text("Gefundene Frage")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(question.text)
                        .font(.body)
                        .lineLimit(3)
                    
                    HStack {
                        Label(question.category, systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Spacer()
                        Text("ID: \(question.id)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { viewModel.resetState() }) {
                    Label("Neue Frage", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
                
                NavigationLink(destination: QuestionDetailView(question: question)) {
                    Label("Öffnen", systemImage: "chevron.right")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    @ViewBuilder
    private func fallbackView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            VStack(spacing: 4) {
                Text("Frage nicht erkannt")
                    .font(.headline)
                Text(viewModel.fallbackReason ?? "Bitte versuchen Sie es erneut oder nutzen Sie die manuelle Suche.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 8) {
                Button(action: { viewModel.resetState() }) {
                    Label("Erneut versuchen", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                NavigationLink(destination: CategoryBrowserView()) {
                    Label("Manuelle Suche", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.orange.opacity(0.08))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func timeoutView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.xmark.fill")
                .font(.system(size: 32))
                .foregroundColor(.red)
            
            VStack(spacing: 4) {
                Text("Analyse hat zu lange gedauert")
                    .font(.headline)
                Text("Bitte versuchen Sie ein klareres Foto oder nutzen Sie die manuelle Suche.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 8) {
                Button(action: { 
                    viewModel.resetState()
                    showingCamera = true 
                }) {
                    Label("Erneut fotografieren", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                NavigationLink(destination: CategoryBrowserView()) {
                    Label("Zur manuellen Suche", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.red.opacity(0.08))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.red)
            
            VStack(spacing: 4) {
                Text("Ein Fehler ist aufgetreten")
                    .font(.headline)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { viewModel.resetState() }) {
                Label("Zurück", systemImage: "arrow.left")
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.red.opacity(0.08))
        .cornerRadius(12)
    }
}

#Preview {
    QuestionIdentificationView()
}