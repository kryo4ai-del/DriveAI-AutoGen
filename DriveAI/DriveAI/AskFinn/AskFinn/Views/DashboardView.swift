import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Dein Fortschritt")
                    .font(.headline)

                ProgressView("Vorbereitet für die Prüfung", value: viewModel.progress, total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                viewModel.loadProgress()
            }
        }
    }
}
