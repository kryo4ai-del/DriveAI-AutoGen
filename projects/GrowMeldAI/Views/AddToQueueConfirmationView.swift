struct AddToQueueConfirmationView: View {
    let sign: RecognizedSign
    @ObservedObject var viewModel: SignRecognitionViewModel
    @Binding var isPresented: Bool
    @State private var isAddingToQueue = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Sign preview
                if let imageName = sign.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .accessibilityLabel("Schild: \(sign.nameDE)")
                }
                
                VStack(spacing: 8) {
                    Text(sign.nameDE)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(sign.descriptionDE)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // Review timing options
                VStack(spacing: 12) {
                    Text("Wann möchten Sie wiederholen?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach([ReviewTiming.tonight, .tomorrow, .threeDays, .weakSigns], id: \.self) { timing in
                        ReviewTimingOption(
                            timing: timing,
                            isSelected: viewModel.selectedReviewTiming == timing,
                            action: { viewModel.selectedReviewTiming = timing }
                        )
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: { Task { await addToQueue() } }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Zur Lernwarteschlange hinzufügen")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isAddingToQueue)
                    
                    Button(action: { isPresented = false }) {
                        Text("Abbrechen")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundColor(.accentColor)
                    }
                }
                
                if isAddingToQueue {
                    ProgressView()
                        .tint(.accentColor)
                }
            }
            .padding(24)
            .navigationTitle("Zum Training hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addToQueue() async {
        isAddingToQueue = true
        await viewModel.addToLearningQueue()
        isAddingToQueue = false
        isPresented = false
    }
}

struct ReviewTimingOption: View {
    let timing: ReviewTiming
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(timingLabel)
                        .fontWeight(.semibold)
                    Text(timingDetail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .foregroundColor(.primary)
    }
    
    var timingLabel: String {
        switch timing {
        case .tonight: return "Heute Abend"
        case .tomorrow: return "Morgen"
        case .threeDays: return "In 3 Tagen"
        case .weakSigns: return "Schwache Punkte"
        }
    }
    
    var timingDetail: String {
        switch timing {
        case .tonight: return "In 4 Stunden"
        case .tomorrow: return "In 24 Stunden"
        case .threeDays: return "In 72 Stunden"
        case .weakSigns: return "Höchste Priorität"
        }
    }
}