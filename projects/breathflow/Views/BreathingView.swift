// Views/BreathingView.swift
struct BreathingView: View {
    @State var viewModel: BreathingViewModel
    @State private var showSessionComplete = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                HStack {
                    Button(action: { /* dismiss */ }) {
                        Image(systemName: "xmark")
                    }
                    Spacer()
                    Text(viewModel.selectedTechnique.displayName)
                        .font(.headline)
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Animated Circle
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 280, height: 280)
                    
                    // Animated fill circle
                    Circle()
                        .scaleEffect(0.5 + CGFloat(viewModel.progress) * 0.5)
                        .fill(phaseColor(viewModel.currentPhase))
                        .frame(width: 280, height: 280)
                        .animation(.easeInOut(duration: 0.05), value: viewModel.progress)
                        .opacity(0.6)
                    
                    // Center content
                    VStack(spacing: 12) {
                        // Phase label
                        Text(viewModel.currentPhase.rawValue.capitalized)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Time remaining
                        Text("\(viewModel.timeRemaining)s")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .contentTransition(.numericText())
                        
                        // Cycle count
                        Text("Cycle \(viewModel.completedCycles + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Instructions
                VStack(spacing: 4) {
                    Text(instructionText(viewModel.currentPhase))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 40)
                
                // Control buttons
                HStack(spacing: 20) {
                    if viewModel.isActive {
                        Button(action: { viewModel.pauseSession() }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 20))
                                .padding(12)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(Circle())
                        }
                    } else {
                        Button(action: { viewModel.startSession() }) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20))
                                .padding(12)
                                .background(Color.blue.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    
                    Button(action: {
                        viewModel.stopSession()
                        showSessionComplete = true
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 20))
                            .padding(12)
                            .background(Color.red.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
                    .frame(height: 20)
            }
            
            .navigationDestination(isPresented: $showSessionComplete) {
                SessionCompleteView()
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            if viewModel.isActive {
                viewModel.pauseSession()
            }
        }
    }
    
    private func phaseColor(_ phase: BreathPhase) -> Color {
        switch phase {
        case .inhale: return .blue
        case .hold: return .green
        case .exhale: return .orange
        }
    }
    
    private func instructionText(_ phase: BreathPhase) -> String {
        switch phase {
        case .inhale: return "Breathe in slowly through your nose"
        case .hold: return "Hold your breath"
        case .exhale: return "Exhale slowly through your mouth"
        }
    }
}