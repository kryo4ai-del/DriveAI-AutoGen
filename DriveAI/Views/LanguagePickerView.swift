import SwiftUI

struct LanguagePickerView: View {
    @Binding var selectedLanguage: String
    let languages = ["de": "German", "en": "English", "fr": "French"] // Example languages

    var body: some View {
        NavigationView {
            List {
                ForEach(languages.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    Button(action: {
                        selectedLanguage = key
                    }) {
                        HStack {
                            Text(value)
                            Spacer()
                            if selectedLanguage == key {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}