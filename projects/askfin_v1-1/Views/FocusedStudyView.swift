import SwiftUI

struct FocusedStudyView: View {
    let categoryId: String

    var body: some View {
        Text("Focused Study: \(categoryId)")
            .navigationTitle("Fokus-Lernen")
    }
}
