import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            MultipleChoiceView(viewModel: MultipleChoiceViewModel())
                .navigationBarTitle("DriveAI", displayMode: .inline)
        }
    }
}