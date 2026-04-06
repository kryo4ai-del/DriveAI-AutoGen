struct QuotaExhaustedOverlay: View {
    @Binding var isPresented: Bool
    @FocusState private var focusedButton: FocusButton?
    
    enum FocusButton {
        case upgrade, later
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Deine Tagesquota ist erschöpft")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Upgraden Sie zu Premium für unbegrenzte Fragen")
                    .font(.body)
                
                Button(action: { /* Payment */ }) {
                    Text("Upgraden")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.prominent)
                .focused($focusedButton, equals: .upgrade)
                .accessibilityLabel("Zu Premium upgraden")
                .accessibilityHint("Öffnet den Upgrade-Flow")
                
                Button(action: { isPresented = false }) {
                    Text("Später")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .focused($focusedButton, equals: .later)
                .accessibilityLabel("Später upgraden")
                .accessibilityHint("Schließt diese Benachrichtigung")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(.isModal)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedButton = .upgrade  // Move focus to primary action
                }
            }
        }
        .accessibilityViewIsModal(true)
    }
}