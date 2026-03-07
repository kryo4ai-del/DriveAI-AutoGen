import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isLoading = true
    @State private var showErrorAlert = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    loadingView
                } else {
                    welcomeText
                    ProgressSummaryView(progress: viewModel.progress)
                    QuickStartButton {
                        startQuickQuiz()
                    }
                    Spacer()
                    navigationLinks
                }
            }
            .navigationTitle("Home")
            .padding()
            .onAppear {
                viewModel.loadProgress { result in
                    switch result {
                    case .success:
                        isLoading = false
                    case .failure(let error):
                        errorMessage = "Laden der Fortschritt fehlgeschlagen: \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Fehler"),
                    message: Text(errorMessage ?? "Unbekannter Fehler aufgetreten."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView("Lade Fortschritt...")
                .progressViewStyle(CircularProgressViewStyle())
            Text("Bitte warten…")
                .font(.subheadline)
                .padding(.top, 5)
        }
    }
    
    private var welcomeText: some View {
        Text("Willkommen bei DriveAI!")
            .font(.largeTitle)
            .padding()
    }
    
    private var navigationLinks: some View {
        VStack(spacing: 10) {
            NavigationLink(destination: CategoryOverviewView()) {
                Text("Fragen nach Kategorien")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
            }
            NavigationLink(destination: ProfileView()) {
                Text("Mein Profil")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
    }
    
    private func startQuickQuiz() {
        viewModel.startQuickQuiz()
        // Consider adding feedback here
    }
}

// ViewModel
class HomeViewModel: ObservableObject {
    @Published var progress: Float = 0.0

    enum LoadError: Error, LocalizedError {
        case dataFetchFailed

        var errorDescription: String? {
            switch self {
            case .dataFetchFailed:
                return "Daten konnten nicht geladen werden."
            }
        }
    }

    func loadProgress(completion: @escaping (Result<Void, LoadError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Simulating data load
            let success = true // Replace with actual logic
            if success {
                self.progress = 75.0 // Placeholder value
                completion(.success(()))
            } else {
                completion(.failure(.dataFetchFailed))
            }
        }
    }

    func startQuickQuiz() {
        print("Starting quick quiz...")
        // Optionally show button feedback or start an actual quiz
    }
}

// ProgressSummaryView.swift
struct ProgressSummaryView: View {
    let progress: Float

    var body: some View {
        VStack(alignment: .leading) {
            Text("Fortschritt")
                .font(.headline)
            ProgressView(value: progress, total: 100)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 20)
                .padding(.vertical)
            Text("\(Int(progress))% abgeschlossen")
                .font(.subheadline)
                .padding(.top, 5)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
    }
}

// QuickStartButton.swift
struct QuickStartButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
            // Optionally show button feedback
        }) {
            Text("Schnellstart")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .buttonStyle()
        }
        .padding(.vertical)
    }
}

// Button Style Extension
extension View {
    func buttonStyle() -> some View {
        self.padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

// Placeholder views for navigation
struct CategoryOverviewView: View {
    var body: some View {
        Text("Kategorieübersicht")
            .font(.largeTitle)
            .navigationTitle("Kategorien")
            .padding()
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Mein Profil")
            .font(.largeTitle)
            .navigationTitle("Profil")
            .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}