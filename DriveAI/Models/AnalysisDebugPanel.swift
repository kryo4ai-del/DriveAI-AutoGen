import SwiftUI

struct AnalysisDebugPanel: View {
    @StateObject private var viewModel = AnalysisDebugPanelViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Analysis Debug Panel")
                    .font(.title)
                    .padding()
                List(viewModel.debugLogs) { log in
                    HStack {
                        Text(log.timestamp, formatter: dateFormatter)
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text(log.message)
                            .font(.body)
                            .foregroundColor(log.level == .error ? .red : .black)
                    }
                }
                .listStyle(PlainListStyle()) // Improved list appearance
                .padding(.top)
            }
            .navigationBarTitle("Debug Info", displayMode: .inline)
            .padding()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }
}