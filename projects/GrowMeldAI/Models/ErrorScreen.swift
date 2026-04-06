// Views/Screens/ErrorScreen.swift
struct ErrorScreen: View {
    let error: DataServiceError
    let retryAction: () async -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Fehler beim Laden")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(error.errorDescription ?? "Unbekannter Fehler")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: {
                Task { await retryAction() }
            }) {
                Text("Erneut versuchen")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorPalette.buttonBackground)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
}