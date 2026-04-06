@main

// Error UI with retry
struct InitializationErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("App konnte nicht initialisiert werden")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Erneut versuchen", action: onRetry)
                .buttonStyle(.filled)
            
            Button("Support kontaktieren") {
                // Open mailto
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}