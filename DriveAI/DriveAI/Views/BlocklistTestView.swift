import SwiftUI

struct BlocklistTestView: View {
    @StateObject private var viewModel = BlocklistViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Wird geladen...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    if viewModel.blocklistItems.isEmpty {
                        Text("Die Blockliste ist leer.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List(viewModel.blocklistItems) { item in
                            VStack(alignment: .leading) {
                                Text(item.question)
                                    .font(.headline)
                                Text("Grund: \(item.reason)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Blockliste")
            .onAppear {
                viewModel.loadBlocklist()
            }
        }
    }
}

struct BlocklistTestView_Previews: PreviewProvider {
    static var previews: some View {
        BlocklistTestView()
    }
}