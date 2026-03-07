import SwiftUI

struct SettingDetailView: View {
    var option: SettingOption
    
    var body: some View {
        VStack {
            Text(option.title)
                .font(.largeTitle)
            Text(option.description ?? "No description available.")
                .font(.body)
                .padding()
        }
        .navigationTitle(option.title)
    }
}

struct SettingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SettingDetailView(option: SettingOption(title: "Notifications", isOn: true, description: "Receive notifications about your exam progress."))
    }
}