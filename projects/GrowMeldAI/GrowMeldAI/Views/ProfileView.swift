// Services/Data/ProgressRepository.swift

// Views/Profile/ProfileView.swift
struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        List {
            Section("Account") {
                Button("Delete Account & Data", role: .destructive) {
                    showDeleteConfirmation = true
                }
                .alert("Permanently Delete?", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        Task {
                            await viewModel.deleteAccountAndData()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
        }
    }
}
