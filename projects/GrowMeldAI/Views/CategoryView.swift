import SwiftUI

struct CategoryView: View {
    @Binding var navigationPath: NavigationPath

    var body: some View {
        List {
            Text("Categories")
                .font(.headline)
        }
        .navigationTitle("Categories")
    }
}