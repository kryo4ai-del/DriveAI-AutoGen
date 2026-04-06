// MARK: - CameraView: Camera capture UI
struct CameraView: View {
    let capturedImage: Binding
    let onCapture: Any
    let onDismiss: Any

    @StateObject var viewModel: CameraViewModel
    @State private var showPermissionDenied = false
    
    var body: some View {
        ZStack {
            // Camera preview (AVFoundation wrapper)
            CameraPreviewView { image in
                viewModel.captureImage(image)
            }
            .ignoresSafeArea()
            
            // Overlay: tap-to-capture button + focus indicator
            VStack {
                HStack {
                    Button(action: { /* dismiss */ }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Capture button
                Button(action: { /* trigger auto-capture */ }) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 3)
                        )
                }
                .padding(.bottom, 50)
            }
            
            // Loading spinner during inference
            if viewModel.isProcessing {
                VStack {
                    ProgressView()
                        .scaleEffect(2)
                    Text("Erkennungsvorgang läuft...")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.4))
            }
        }
        .sheet(item: $viewModel.recognitionResult) { result in
            RecognitionResultView(result: result)
        }
        .alert(isPresented: $viewModel.error != nil) {
            if case .lowConfidence(let confidence) = viewModel.error {
                return Alert(
                    title: Text("Unsicher?"),
                    message: Text("Zuversicht: \(Int(confidence * 100))%. Versuchen Sie einen anderen Winkel."),
                    dismissButton: .default(Text("Erneut versuchen"))
                )
            }
            return Alert(title: Text("Fehler"), message: Text(viewModel.error?.localizedDescription ?? ""))
        }
    }
}

// MARK: - RecognitionResultView: Display recognized sign + related questions
struct RecognitionResultView: View {
    let result: SignRecognitionResult
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Recognized sign (image + name)
            VStack {
                Image(result.signID) // from Assets
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                
                Text(result.signName)
                    .font(.headline)
            }
            
            // Confidence score (visual progress ring)
            VStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(result.confidence))
                        .stroke(
                            result.confidence >= 0.85 ? Color.green : Color.yellow,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(result.confidence * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(width: 100, height: 100)
                
                Text("Erkennungssicherheit")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Learning context: how many questions feature this sign
            VStack(alignment: .leading, spacing: 8) {
                Text("Dieses Zeichen erscheint in \(result.recognizedQuestions.count) Prüfungsfragen")
                    .font(.body)
                    .fontWeight(.semibold)
                
                // CTA: practice related questions
                Button(action: {
                    // Navigate to quiz with pre-filtered questions
                    dismiss()
                }) {
                    Text("\(result.recognizedQuestions.count) Fragen dazu üben")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
            
            // Disclaimer
            Text("Überprüfe alle Erkennungen gegen offizielle Materialien. KI-Ergebnisse können fehlerhaft sein.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Button(action: { dismiss() }) {
                Text("Schließen")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}